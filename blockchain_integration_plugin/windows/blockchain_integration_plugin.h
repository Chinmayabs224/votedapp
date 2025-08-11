#ifndef FLUTTER_PLUGIN_BLOCKCHAIN_INTEGRATION_PLUGIN_H_
#define FLUTTER_PLUGIN_BLOCKCHAIN_INTEGRATION_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace blockchain_integration_plugin {

class BlockchainIntegrationPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  BlockchainIntegrationPlugin();

  virtual ~BlockchainIntegrationPlugin();

  // Disallow copy and assign.
  BlockchainIntegrationPlugin(const BlockchainIntegrationPlugin&) = delete;
  BlockchainIntegrationPlugin& operator=(const BlockchainIntegrationPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace blockchain_integration_plugin

#endif  // FLUTTER_PLUGIN_BLOCKCHAIN_INTEGRATION_PLUGIN_H_
