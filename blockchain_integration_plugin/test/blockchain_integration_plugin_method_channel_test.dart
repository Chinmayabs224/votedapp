import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blockchain_integration_plugin/blockchain_integration_plugin_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelBlockchainIntegrationPlugin platform = MethodChannelBlockchainIntegrationPlugin();
  const MethodChannel channel = MethodChannel('blockchain_integration_plugin');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
