import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'blockchain_manager.dart';
import 'blockchain_service.dart';

/// Real-time service for blockchain updates and live data streaming
class BlockchainRealtimeService {
  final BlockchainManager _blockchainManager;
  
  WebSocketChannel? _webSocketChannel;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  Timer? _pollTimer;
  
  bool _isConnected = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _pollInterval = Duration(seconds: 2);

  final StreamController<BlockchainRealtimeEvent> _eventController = StreamController.broadcast();
  final StreamController<ConnectionStatus> _connectionController = StreamController.broadcast();

  BlockchainRealtimeService(this._blockchainManager);

  /// Stream of real-time blockchain events
  Stream<BlockchainRealtimeEvent> get eventStream => _eventController.stream;

  /// Stream of connection status changes
  Stream<ConnectionStatus> get connectionStream => _connectionController.stream;

  /// Current connection status
  bool get isConnected => _isConnected;

  /// Initialize the real-time service
  Future<void> initialize() async {
    // Listen to blockchain manager events
    _blockchainManager.eventStream.listen(_handleBlockchainEvent);
    
    // Listen to blockchain status changes
    _blockchainManager.statusStream.listen(_handleStatusChange);
    
    // Start polling for updates
    _startPolling();
    
    // Try to establish WebSocket connection (optional)
    _tryWebSocketConnection();
  }

  /// Start the real-time service
  Future<void> start() async {
    _shouldReconnect = true;
    _startPolling();
    _tryWebSocketConnection();
    _updateConnectionStatus(ConnectionStatus.connecting);
  }

  /// Stop the real-time service
  Future<void> stop() async {
    _shouldReconnect = false;
    _stopPolling();
    _closeWebSocket();
    _stopReconnectTimer();
    _stopHeartbeat();
    _updateConnectionStatus(ConnectionStatus.disconnected);
  }

  /// Handle blockchain manager events
  void _handleBlockchainEvent(BlockchainEvent event) {
    switch (event.type) {
      case 'newBlock':
        _emitEvent(BlockchainRealtimeEvent.newBlock(event.data, event.timestamp));
        break;
      case 'voteSubmitted':
        _emitEvent(BlockchainRealtimeEvent.voteSubmitted(event.data, event.timestamp));
        break;
      case 'started':
        _emitEvent(BlockchainRealtimeEvent.blockchainStarted(event.timestamp));
        _updateConnectionStatus(ConnectionStatus.connected);
        break;
      case 'stopped':
        _emitEvent(BlockchainRealtimeEvent.blockchainStopped(event.timestamp));
        _updateConnectionStatus(ConnectionStatus.disconnected);
        break;
      case 'error':
        _emitEvent(BlockchainRealtimeEvent.error(event.data['message'] as String, event.timestamp));
        break;
    }
  }

  /// Handle blockchain status changes
  void _handleStatusChange(BlockchainStatus status) {
    switch (status) {
      case BlockchainStatus.running:
        _updateConnectionStatus(ConnectionStatus.connected);
        _emitEvent(BlockchainRealtimeEvent.statusChanged('running', DateTime.now()));
        break;
      case BlockchainStatus.stopped:
        _updateConnectionStatus(ConnectionStatus.disconnected);
        _emitEvent(BlockchainRealtimeEvent.statusChanged('stopped', DateTime.now()));
        break;
      case BlockchainStatus.error:
        _updateConnectionStatus(ConnectionStatus.error);
        _emitEvent(BlockchainRealtimeEvent.statusChanged('error', DateTime.now()));
        break;
      case BlockchainStatus.starting:
        _updateConnectionStatus(ConnectionStatus.connecting);
        _emitEvent(BlockchainRealtimeEvent.statusChanged('starting', DateTime.now()));
        break;
      case BlockchainStatus.stopping:
        _updateConnectionStatus(ConnectionStatus.disconnecting);
        _emitEvent(BlockchainRealtimeEvent.statusChanged('stopping', DateTime.now()));
        break;
    }
  }

  /// Start polling for blockchain updates
  void _startPolling() {
    _stopPolling();
    
    _pollTimer = Timer.periodic(_pollInterval, (timer) async {
      if (!_blockchainManager.isRunning) return;
      
      try {
        // Poll for blockchain statistics
        final stats = await _blockchainManager.getBlockchainStats();
        _emitEvent(BlockchainRealtimeEvent.statsUpdate(stats, DateTime.now()));
        
        // Update connection status if needed
        if (!_isConnected && stats.isHealthy) {
          _updateConnectionStatus(ConnectionStatus.connected);
        } else if (_isConnected && !stats.isHealthy) {
          _updateConnectionStatus(ConnectionStatus.error);
        }
        
      } catch (e) {
        // Handle polling errors silently
        if (_isConnected) {
          _updateConnectionStatus(ConnectionStatus.error);
        }
      }
    });
  }

  /// Stop polling
  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Try to establish WebSocket connection (for future enhancement)
  void _tryWebSocketConnection() {
    if (!_shouldReconnect || _reconnectAttempts >= _maxReconnectAttempts) {
      return;
    }

    try {
      // For now, we'll skip WebSocket connection as the blockchain doesn't provide it
      // This is a placeholder for future WebSocket implementation
      _reconnectAttempts = 0;
      _startHeartbeat();
    } catch (e) {
      _handleWebSocketError(e);
    }
  }

  /// Handle WebSocket errors
  void _handleWebSocketError(dynamic error) {
    _closeWebSocket();
    _reconnectAttempts++;
    
    if (_shouldReconnect && _reconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnect();
    } else {
      _updateConnectionStatus(ConnectionStatus.error);
      _emitEvent(BlockchainRealtimeEvent.connectionError(
        'Failed to establish WebSocket connection after $_reconnectAttempts attempts',
        DateTime.now(),
      ));
    }
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    _stopReconnectTimer();
    _reconnectTimer = Timer(_reconnectDelay, () {
      if (_shouldReconnect) {
        _tryWebSocketConnection();
      }
    });
  }

  /// Start heartbeat to keep connection alive
  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_webSocketChannel != null && _isConnected) {
        try {
          _webSocketChannel!.sink.add(jsonEncode({'type': 'ping'}));
        } catch (e) {
          _handleWebSocketError(e);
        }
      }
    });
  }

  /// Stop heartbeat timer
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Stop reconnect timer
  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Close WebSocket connection
  void _closeWebSocket() {
    try {
      _webSocketChannel?.sink.close();
    } catch (e) {
      // Ignore close errors
    }
    _webSocketChannel = null;
    _isConnected = false;
  }

  /// Update connection status
  void _updateConnectionStatus(ConnectionStatus status) {
    _isConnected = status == ConnectionStatus.connected;
    _connectionController.add(status);
  }

  /// Emit a real-time event
  void _emitEvent(BlockchainRealtimeEvent event) {
    _eventController.add(event);
  }

  /// Dispose resources
  void dispose() {
    stop();
    _eventController.close();
    _connectionController.close();
  }
}

/// Real-time blockchain event
class BlockchainRealtimeEvent {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  BlockchainRealtimeEvent._(this.type, this.data, this.timestamp);

  factory BlockchainRealtimeEvent.newBlock(Map<String, dynamic> blockData, DateTime timestamp) {
    return BlockchainRealtimeEvent._('newBlock', blockData, timestamp);
  }

  factory BlockchainRealtimeEvent.voteSubmitted(Map<String, dynamic> voteData, DateTime timestamp) {
    return BlockchainRealtimeEvent._('voteSubmitted', voteData, timestamp);
  }

  factory BlockchainRealtimeEvent.blockchainStarted(DateTime timestamp) {
    return BlockchainRealtimeEvent._('blockchainStarted', {}, timestamp);
  }

  factory BlockchainRealtimeEvent.blockchainStopped(DateTime timestamp) {
    return BlockchainRealtimeEvent._('blockchainStopped', {}, timestamp);
  }

  factory BlockchainRealtimeEvent.statusChanged(String status, DateTime timestamp) {
    return BlockchainRealtimeEvent._('statusChanged', {'status': status}, timestamp);
  }

  factory BlockchainRealtimeEvent.statsUpdate(BlockchainStats stats, DateTime timestamp) {
    return BlockchainRealtimeEvent._('statsUpdate', {
      'blockHeight': stats.blockHeight,
      'totalTransactions': stats.totalTransactions,
      'isHealthy': stats.isHealthy,
    }, timestamp);
  }

  factory BlockchainRealtimeEvent.error(String message, DateTime timestamp) {
    return BlockchainRealtimeEvent._('error', {'message': message}, timestamp);
  }

  factory BlockchainRealtimeEvent.connectionError(String message, DateTime timestamp) {
    return BlockchainRealtimeEvent._('connectionError', {'message': message}, timestamp);
  }
}

/// Connection status enumeration
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
  reconnecting,
}

/// Connection status extensions
extension ConnectionStatusExtension on ConnectionStatus {
  String get displayName {
    switch (this) {
      case ConnectionStatus.disconnected:
        return 'Disconnected';
      case ConnectionStatus.connecting:
        return 'Connecting';
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.disconnecting:
        return 'Disconnecting';
      case ConnectionStatus.error:
        return 'Error';
      case ConnectionStatus.reconnecting:
        return 'Reconnecting';
    }
  }

  bool get isConnected => this == ConnectionStatus.connected;
  bool get isError => this == ConnectionStatus.error;
  bool get isConnecting => this == ConnectionStatus.connecting || this == ConnectionStatus.reconnecting;
}
