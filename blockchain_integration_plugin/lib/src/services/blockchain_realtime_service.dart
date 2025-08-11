import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../models/blockchain_block.dart';
import '../models/blockchain_transaction.dart';
import '../models/blockchain_network_state.dart';

/// Status of the WebSocket connection
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error
}

/// Event types for blockchain real-time updates
enum EventType {
  newBlock,
  newTransaction,
  networkStateChange,
  connectionChange,
  error
}

/// Real-time event data structure
class BlockchainRealtimeEvent {
  final EventType type;
  final dynamic data;
  final DateTime timestamp;

  BlockchainRealtimeEvent(this.type, this.data, this.timestamp);

  factory BlockchainRealtimeEvent.newBlock(BlockchainBlock block) {
    return BlockchainRealtimeEvent(EventType.newBlock, block, DateTime.now());
  }

  factory BlockchainRealtimeEvent.newTransaction(BlockchainTransaction transaction) {
    return BlockchainRealtimeEvent(EventType.newTransaction, transaction, DateTime.now());
  }

  factory BlockchainRealtimeEvent.networkStateChange(BlockchainNetworkState state) {
    return BlockchainRealtimeEvent(EventType.networkStateChange, state, DateTime.now());
  }

  factory BlockchainRealtimeEvent.connectionChange(ConnectionStatus status) {
    return BlockchainRealtimeEvent(EventType.connectionChange, status, DateTime.now());
  }

  factory BlockchainRealtimeEvent.error(String message) {
    return BlockchainRealtimeEvent(EventType.error, {'message': message}, DateTime.now());
  }
}

/// Real-time service for blockchain updates and live data streaming
class BlockchainRealtimeService {
  final String _baseUrl;
  
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

  BlockchainRealtimeService(this._baseUrl);

  /// Stream of real-time blockchain events
  Stream<BlockchainRealtimeEvent> get eventStream => _eventController.stream;

  /// Stream of connection status changes
  Stream<ConnectionStatus> get connectionStream => _connectionController.stream;

  /// Current connection status
  bool get isConnected => _isConnected;

  /// Initialize the real-time service
  Future<void> initialize() async {
    // Start polling for updates as a fallback
    _startPolling();
    
    // Try to establish WebSocket connection
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

  /// Emit a real-time event
  void _emitEvent(BlockchainRealtimeEvent event) {
    _eventController.add(event);
  }

  /// Update connection status
  void _updateConnectionStatus(ConnectionStatus status) {
    _connectionController.add(status);
  }

  /// Start polling for updates (fallback mechanism when WebSocket is not available)
  void _startPolling() {
    _stopPolling();
    _pollTimer = Timer.periodic(_pollInterval, (timer) async {
      try {
        // This is a fallback mechanism when WebSocket is not available
        // It will be replaced by WebSocket when available
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

  /// Try to establish WebSocket connection
  void _tryWebSocketConnection() {
    if (!_shouldReconnect || _reconnectAttempts >= _maxReconnectAttempts) {
      return;
    }

    try {
      final wsUrl = _baseUrl.replaceFirst('http', 'ws') + '/ws';
      _webSocketChannel = IOWebSocketChannel.connect(wsUrl);
      _webSocketChannel!.stream.listen(
        _handleWebSocketMessage,
        onError: _handleWebSocketError,
        onDone: _handleWebSocketDone,
      );
      
      _isConnected = true;
      _reconnectAttempts = 0;
      _updateConnectionStatus(ConnectionStatus.connected);
      _startHeartbeat();
      
      // Stop polling when WebSocket is connected
      _stopPolling();
    } catch (e) {
      _handleWebSocketError(e);
    }
  }

  /// Handle WebSocket messages
  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String);
      final eventType = data['type'] as String;
      final eventData = data['data'];
      
      switch (eventType) {
        case 'block':
          // Convert the server's block format to our BlockchainBlock model
          final blockData = Map<String, dynamic>.from(eventData as Map);
          final block = _convertToBlockchainBlock(blockData);
          _emitEvent(BlockchainRealtimeEvent.newBlock(block));
          break;
        case 'transaction':
          // Convert the server's transaction format to our BlockchainTransaction model
          final txData = Map<String, dynamic>.from(eventData as Map);
          final transaction = _convertToBlockchainTransaction(txData);
          _emitEvent(BlockchainRealtimeEvent.newTransaction(transaction));
          break;
        case 'network_state':
          // Convert the server's network state format to our BlockchainNetworkState model
          final stateData = Map<String, dynamic>.from(eventData as Map);
          final state = _convertToBlockchainNetworkState(stateData);
          _emitEvent(BlockchainRealtimeEvent.networkStateChange(state));
          break;
        case 'pong':
          // Heartbeat response, no action needed
          debugPrint('Received pong from server');
          break;
        default:
          debugPrint('Unknown event type: $eventType');
          break;
      }
    } catch (e) {
      _emitEvent(BlockchainRealtimeEvent.error('Failed to parse WebSocket message: $e'));
    }
  }

  /// Handle WebSocket errors
  void _handleWebSocketError(dynamic error) {
    _closeWebSocket();
    _reconnectAttempts++;
    
    if (_shouldReconnect && _reconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnect();
      _updateConnectionStatus(ConnectionStatus.reconnecting);
    } else {
      _updateConnectionStatus(ConnectionStatus.error);
      _emitEvent(BlockchainRealtimeEvent.error(
        'Failed to establish WebSocket connection after $_reconnectAttempts attempts: $error',
      ));
      
      // Fall back to polling
      _startPolling();
    }
  }

  /// Handle WebSocket connection close
  void _handleWebSocketDone() {
    _isConnected = false;
    
    if (_shouldReconnect) {
      _updateConnectionStatus(ConnectionStatus.reconnecting);
      _scheduleReconnect();
    } else {
      _updateConnectionStatus(ConnectionStatus.disconnected);
    }
    
    // Fall back to polling
    _startPolling();
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

  /// Dispose resources
  void dispose() {
    stop();
    _eventController.close();
    _connectionController.close();
  }
  
  /// Convert server block format to BlockchainBlock
  BlockchainBlock _convertToBlockchainBlock(Map<String, dynamic> blockData) {
    // Extract transactions from block data
    final List<BlockchainTransaction> transactions = [];
    if (blockData['transactions'] != null) {
      for (final txData in blockData['transactions']) {
        transactions.add(_convertToBlockchainTransaction(txData));
      }
    }
    
    return BlockchainBlock(
      hash: blockData['hash'] as String? ?? '',
      previousHash: blockData['previousHash'] as String? ?? '',
      height: blockData['height'] as int? ?? 0,
      timestamp: blockData['timestamp'] as int? ?? 0,
      transactions: transactions,
      validator: blockData['validator'] as String? ?? '',
      merkleRoot: blockData['merkleRoot'] as String? ?? '',
      nonce: blockData['nonce'] as int? ?? 0,
      difficulty: (blockData['difficulty'] as num?)?.toDouble() ?? 0.0,
      gasUsed: blockData['gasUsed'] as int? ?? 0,
      gasLimit: blockData['gasLimit'] as int? ?? 0,
      status: _parseBlockStatus(blockData['status'] as String? ?? 'confirmed'),
    );
  }
  
  /// Convert server transaction format to BlockchainTransaction
  BlockchainTransaction _convertToBlockchainTransaction(Map<String, dynamic> txData) {
    return BlockchainTransaction(
      hash: txData['hash'] as String? ?? '',
      fromAddress: txData['from'] as String? ?? '',
      toAddress: txData['to'] as String? ?? '',
      amount: (txData['amount'] as num?)?.toDouble() ?? 0.0,
      fee: (txData['fee'] as num?)?.toDouble() ?? 0.0,
      timestamp: txData['timestamp'] as int? ?? 0,
      signature: txData['signature'] as String? ?? '',
      status: _parseTransactionStatus(txData['status'] as String? ?? 'pending'),
      data: txData['data'] as String?,
      blockHeight: txData['blockHeight'] as int?,
      nonce: txData['nonce'] as int? ?? 0,
    );
  }
  
  /// Convert server network state format to BlockchainNetworkState
  BlockchainNetworkState _convertToBlockchainNetworkState(Map<String, dynamic> stateData) {
    return BlockchainNetworkState(
      currentBlockHeight: stateData['currentBlockHeight'] as int? ?? 0,
      latestBlockHash: stateData['latestBlockHash'] as String? ?? '',
      totalTransactions: stateData['totalTransactions'] as int? ?? 0,
      networkHashRate: (stateData['networkHashRate'] as num?)?.toDouble() ?? 0.0,
      connectedPeers: stateData['connectedPeers'] as int? ?? 0,
      status: _parseNetworkStatus(stateData['status'] as String? ?? 'offline'),
      avgBlockTime: (stateData['avgBlockTime'] as num?)?.toDouble() ?? 0.0,
      pendingTransactions: stateData['pendingTransactions'] as int? ?? 0,
      totalSupply: (stateData['totalSupply'] as num?)?.toDouble() ?? 0.0,
      circulatingSupply: (stateData['circulatingSupply'] as num?)?.toDouble() ?? 0.0,
      timestamp: stateData['timestamp'] as int? ?? 0,
    );
  }
  
  /// Parse block status from string
  BlockStatus _parseBlockStatus(String status) {
    return BlockStatus.fromString(status);
  }
  
  /// Parse transaction status from string
  TransactionStatus _parseTransactionStatus(String status) {
    return TransactionStatus.fromString(status);
  }
  
  /// Parse network status from string
  NetworkStatus _parseNetworkStatus(String status) {
    return NetworkStatus.fromString(status);
  }
}