//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <desktop_lifecycle/desktop_lifecycle_plugin.h>
#include <desktop_multi_window/desktop_multi_window_plugin.h>
#include <tray_manager/tray_manager_plugin.h>
#include <url_launcher_linux/url_launcher_plugin.h>
#include <window_size/window_size_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) desktop_lifecycle_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "DesktopLifecyclePlugin");
  desktop_lifecycle_plugin_register_with_registrar(desktop_lifecycle_registrar);
  g_autoptr(FlPluginRegistrar) desktop_multi_window_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "DesktopMultiWindowPlugin");
  desktop_multi_window_plugin_register_with_registrar(desktop_multi_window_registrar);
  g_autoptr(FlPluginRegistrar) tray_manager_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "TrayManagerPlugin");
  tray_manager_plugin_register_with_registrar(tray_manager_registrar);
  g_autoptr(FlPluginRegistrar) url_launcher_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "UrlLauncherPlugin");
  url_launcher_plugin_register_with_registrar(url_launcher_linux_registrar);
  g_autoptr(FlPluginRegistrar) window_size_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "WindowSizePlugin");
  window_size_plugin_register_with_registrar(window_size_registrar);
}
