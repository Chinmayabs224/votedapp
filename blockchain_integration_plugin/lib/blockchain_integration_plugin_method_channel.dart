import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'blockchain_integration_plugin_platform_interface.dart';

/// An implementation of [BlockchainIntegrationPluginPlatform] that uses method channels.
class MethodChannelBlockchainIntegrationPlugin extends BlockchainIntegrationPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('blockchain_integration_plugin');

  String? _baseUrl;

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
  
  @override
  void initializeWithBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
    methodChannel.invokeMethod<void>('initializeWithBaseUrl', {'baseUrl': baseUrl});
  }
}
