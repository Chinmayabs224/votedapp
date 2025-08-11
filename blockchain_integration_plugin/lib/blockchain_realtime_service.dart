import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Enum representing the connection status of the WebSocket
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error
}

/// Class representing a blockchain event received from the WebSocket
class BlockchainEvent {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  BlockchainEvent({
    required this.type,
    required this.data,
    required this.timestamp,
  });

  factory BlockchainEvent.fromJson(Map<String, dynamic> json) {
    return BlockchainEvent(
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'BlockchainEvent{type: $type, data: $data, timestamp: $timestamp}';
  }
}

/// Service for handling real-time blockchain updates via WebSocket
class BlockchainRealtimeService {
  final String _baseUrl;
  WebSocketChannel? _channel;
  final _eventStreamController = StreamController<BlockchainEvent>.broadcast();
  final _connectionStatusController = StreamController<ConnectionStatus>.broadcast();
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  Timer? _reconnectTimer;
  bool _autoReconnect = true;
  
  /// Stream of blockchain events
  Stream<BlockchainEvent> get eventStream => _eventStreamController.stream;
  
  /// Stream of connection status updates
  Stream<ConnectionStatus> get connectionStream => _connectionStatusController.stream;
  
  /// Current connection status
  ConnectionStatus get connectionStatus => _connectionStatus;

  /// Constructor
  BlockchainRealtimeService(this._baseUrl);

  /// Connect to the WebSocket server
  Future<void> connect() async {
    if (_connectionStatus == ConnectionStatus.connected ||
        _connectionStatus == ConnectionStatus.connecting) {
      return;
    }

    _updateConnectionStatus(ConnectionStatus.connecting);
    
    try {
      // Convert HTTP URL to WebSocket URL
      final wsUrl = _baseUrl.replaceFirst('http', 'ws') + '/ws';
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
      );
      
      _updateConnectionStatus(ConnectionStatus.connected);
    } catch (e) {
      _handleError(e);
    }
  }

  /// Disconnect from the WebSocket server
  void disconnect() {
    _autoReconnect = false;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _updateConnectionStatus(ConnectionStatus.disconnected);
  }

  /// Enable auto-reconnect
  void enableAutoReconnect() {
    _autoReconnect = true;
    if (_connectionStatus == ConnectionStatus.disconnected) {
      _scheduleReconnect();
    }
  }

  /// Disable auto-reconnect
  void disableAutoReconnect() {
    _autoReconnect = false;
    _reconnectTimer?.cancel();
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic message) {
    try {
      final Map<String, dynamic> jsonData = jsonDecode(message as String);
      final event = BlockchainEvent.fromJson(jsonData);
      _eventStreamController.add(event);
    } catch (e) {
      debugPrint('Error parsing WebSocket message: $e');
    }
  }

  /// Handle WebSocket errors
  void _handleError(dynamic error) {
    debugPrint('WebSocket error: $error');
    _updateConnectionStatus(ConnectionStatus.error);
    _scheduleReconnect();
  }

  /// Handle WebSocket connection closure
  void _handleDone() {
    if (_connectionStatus != ConnectionStatus.disconnected) {
      _updateConnectionStatus(ConnectionStatus.disconnected);
      _scheduleReconnect();
    }
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    if (!_autoReconnect) return;
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (_autoReconnect && _connectionStatus != ConnectionStatus.connected) {
        connect();
      }
    });
  }

  /// Update connection status and notify listeners
  void _updateConnectionStatus(ConnectionStatus status) {
    _connectionStatus = status;
    _connectionStatusController.add(status);
  }

  /// Send a message to the WebSocket server
  void sendMessage(Map<String, dynamic> message) {
    if (_connectionStatus == ConnectionStatus.connected) {
      _channel?.sink.add(jsonEncode(message));
    } else {
      debugPrint('Cannot send message: WebSocket not connected');
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _eventStreamController.close();
    _connectionStatusController.close();
  }
}