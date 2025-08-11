import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'blockchain_integration_plugin_method_channel.dart';

abstract class BlockchainIntegrationPluginPlatform extends PlatformInterface {
  /// Constructs a BlockchainIntegrationPluginPlatform.
  BlockchainIntegrationPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static BlockchainIntegrationPluginPlatform _instance = MethodChannelBlockchainIntegrationPlugin();

  /// The default instance of [BlockchainIntegrationPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelBlockchainIntegrationPlugin].
  static BlockchainIntegrationPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BlockchainIntegrationPluginPlatform] when
  /// they register themselves.
  static set instance(BlockchainIntegrationPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  
  /// Initializes the platform with the given base URL
  /// This is used for both HTTP and WebSocket connections
  void initializeWithBaseUrl(String baseUrl) {
    throw UnimplementedError('initializeWithBaseUrl() has not been implemented.');
  }
}
