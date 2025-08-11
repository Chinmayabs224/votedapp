#include "include/blockchain_integration_plugin/blockchain_integration_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "blockchain_integration_plugin.h"

void BlockchainIntegrationPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  blockchain_integration_plugin::BlockchainIntegrationPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
