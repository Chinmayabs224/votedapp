//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <blockchain_integration_plugin/blockchain_integration_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) blockchain_integration_plugin_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "BlockchainIntegrationPlugin");
  blockchain_integration_plugin_register_with_registrar(blockchain_integration_plugin_registrar);
}
