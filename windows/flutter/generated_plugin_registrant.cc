//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <dart_discord_rpc/dart_discord_rpc_plugin.h>
#include <desktop_webview_auth/desktop_webview_auth_plugin.h>
#include <just_audio_windows/just_audio_windows_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  DartDiscordRpcPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DartDiscordRpcPlugin"));
  DesktopWebviewAuthPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DesktopWebviewAuthPlugin"));
  JustAudioWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("JustAudioWindowsPlugin"));
}
