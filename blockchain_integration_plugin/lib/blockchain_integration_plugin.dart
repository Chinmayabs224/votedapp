
import 'blockchain_integration_plugin_platform_interface.dart';
import 'src/services/blockchain_service.dart';
import 'src/services/blockchain_realtime_service.dart';
import 'src/models/blockchain_transaction.dart';
import 'src/models/blockchain_block.dart';
import 'src/models/blockchain_network_state.dart';

class BlockchainIntegrationPlugin {
  final BlockchainService _blockchainService;
  BlockchainRealtimeService? _realtimeService;

  BlockchainIntegrationPlugin([String baseUrl = ''])
      : _blockchainService = BlockchainService(baseUrl) {
    if (baseUrl.isNotEmpty) {
      BlockchainIntegrationPluginPlatform.instance.initializeWithBaseUrl(baseUrl);
    }
  }

  Future<List<BlockchainTransaction>> getTransactions() {
    return _blockchainService.fetchTransactions();
  }

  Future<BlockchainBlock> getLatestBlock() {
    return _blockchainService.fetchLatestBlock();
  }

  Future<BlockchainNetworkState> getNetworkState() {
    return _blockchainService.fetchNetworkState();
  }
  
  Future<String?> getPlatformVersion() {
    return BlockchainIntegrationPluginPlatform.instance.getPlatformVersion();
  }

  Future<void> sendTransaction(BlockchainTransaction transaction) {
    return _blockchainService.submitTransaction(transaction);
  }

  /// Initialize and get the real-time blockchain service
  /// This provides WebSocket-based real-time updates for blockchain events
  BlockchainRealtimeService getRealtimeService() {
    _realtimeService ??= BlockchainRealtimeService(_blockchainService.baseUrl);
    return _realtimeService!;
  }

  /// Check if real-time service is initialized
  bool get hasRealtimeService => _realtimeService != null;

  /// Dispose resources when plugin is no longer needed
  void dispose() {
    _realtimeService?.dispose();
    _realtimeService = null;
  }
}
