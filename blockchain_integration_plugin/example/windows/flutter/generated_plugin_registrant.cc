//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <blockchain_integration_plugin/blockchain_integration_plugin_c_api.h>
#include <connectivity_plus/connectivity_plus_windows_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  BlockchainIntegrationPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("BlockchainIntegrationPluginCApi"));
  ConnectivityPlusWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ConnectivityPlusWindowsPlugin"));
}
