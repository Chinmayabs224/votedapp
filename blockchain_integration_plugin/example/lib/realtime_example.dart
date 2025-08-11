import 'package:flutter/material.dart';
import 'package:blockchain_integration_plugin/blockchain_integration_plugin.dart';
import 'package:blockchain_integration_plugin/src/services/blockchain_realtime_service.dart';

class RealtimeExample extends StatefulWidget {
  const RealtimeExample({super.key});

  @override
  State<RealtimeExample> createState() => _RealtimeExampleState();
}

class _RealtimeExampleState extends State<RealtimeExample> {
  final _blockchainPlugin = BlockchainIntegrationPlugin('http://localhost:9000');
  late BlockchainRealtimeService _realtimeService;
  final List<String> _events = [];
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;

  @override
  void initState() {
    super.initState();
    _initRealtimeService();
  }

  void _initRealtimeService() {
    // Get the realtime service from the plugin
    _realtimeService = _blockchainPlugin.getRealtimeService();
    
    // Listen for blockchain events
    _realtimeService.eventStream.listen((event) {
      setState(() {
        _events.add('${event.timestamp}: ${event.type} - ${event.data}');
        // Keep only the last 20 events
        if (_events.length > 20) {
          _events.removeAt(0);
        }
      });
    });
    
    // Listen for connection status changes
    _realtimeService.connectionStream.listen((status) {
      setState(() {
        _connectionStatus = status;
      });
    });
    
    // Initialize the service
    _realtimeService.initialize();
  }

  @override
  void dispose() {
    // Dispose the plugin when no longer needed
    _blockchainPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blockchain Realtime Example'),
      ),
      body: Column(
        children: [
          // Connection status indicator
          Container(
            padding: const EdgeInsets.all(16),
            color: _getStatusColor(_connectionStatus),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Connection Status: ${_connectionStatus.toString().split('.').last}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                _connectionStatus == ConnectionStatus.disconnected
                    ? ElevatedButton(
                        onPressed: () => _realtimeService.start(),
                        child: const Text('Connect'),
                      )
                    : ElevatedButton(
                        onPressed: () => _realtimeService.stop(),
                        child: const Text('Disconnect'),
                      ),
              ],
            ),
          ),
          
          // Events list
          Expanded(
            child: ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_events[_events.length - 1 - index]),
                  dense: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        return Colors.orange;
      case ConnectionStatus.error:
        return Colors.red;
      case ConnectionStatus.disconnected:
      default:
        return Colors.grey;
    }
  }
}