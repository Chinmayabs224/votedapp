import 'package:flutter_test/flutter_test.dart';
import 'package:blockchain_integration_plugin/blockchain_integration_plugin.dart';
import 'package:blockchain_integration_plugin/blockchain_integration_plugin_platform_interface.dart';
import 'package:blockchain_integration_plugin/blockchain_integration_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
// Removed app dependency to keep plugin tests self-contained

class MockBlockchainIntegrationPluginPlatform
    with MockPlatformInterfaceMixin
    implements BlockchainIntegrationPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  void initializeWithBaseUrl(String baseUrl) {}
}

void main() {
  final BlockchainIntegrationPluginPlatform initialPlatform = BlockchainIntegrationPluginPlatform.instance;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  test('$MethodChannelBlockchainIntegrationPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBlockchainIntegrationPlugin>());
  });

  test('getPlatformVersion', () async {
    MockBlockchainIntegrationPluginPlatform fakePlatform = MockBlockchainIntegrationPluginPlatform();
    BlockchainIntegrationPluginPlatform.instance = fakePlatform;

    expect(await BlockchainIntegrationPluginPlatform.instance.getPlatformVersion(), '42');
  });

  test('BlockchainIntegrationPlugin can be instantiated with baseUrl', () {
    const testBaseUrl = 'https://test-blockchain-api.com';
    expect(() => BlockchainIntegrationPlugin(testBaseUrl), returnsNormally);
  });

  test('BlockchainIntegrationPlugin has required methods', () {
    const testBaseUrl = 'https://test-blockchain-api.com';
    final plugin = BlockchainIntegrationPlugin(testBaseUrl);

    // Verify that the plugin has the expected methods
    expect(plugin.getTransactions, isA<Function>());
    expect(plugin.getLatestBlock, isA<Function>());
    expect(plugin.getNetworkState, isA<Function>());
    expect(plugin.sendTransaction, isA<Function>());
  });
}

