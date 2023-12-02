#include <optional>

#include <hyprland/src/Compositor.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>

#include "dispatchers.hpp"
#include "globals.hpp"
#include "globaleventhook.hpp"

APICALL EXPORT std::string PLUGIN_API_VERSION() { return HYPRLAND_API_VERSION; }

APICALL EXPORT PLUGIN_DESCRIPTION_INFO PLUGIN_INIT(HANDLE handle)
{
	PHANDLE = handle;

#define CONF(NAME, TYPE, VALUE) \
	HyprlandAPI::addConfigValue(PHANDLE, "plugin:hycov:" NAME, SConfigValue{.TYPE##Value = VALUE})

	CONF("overview_gappo", int, 60);
	CONF("overview_gappi", int, 24);
	CONF("hotarea_size", int, 10);
	CONF("enable_hotarea", int, 1);
	CONF("swipe_fingers", int, 4);
	CONF("move_focus_distance", int, 100);
	CONF("enable_gesture", int, 1);
	CONF("disable_workspace_change", int, 1);
	CONF("disable_spawn", int, 1);
	CONF("auto_exit", int, 1);
	CONF("auto_fullscreen", int, 1);


#undef CONF

	static const auto *pEnable_hotarea_config = &HyprlandAPI::getConfigValue(PHANDLE, "plugin:hycov:enable_hotarea")->intValue;
  	static const auto *pHotarea_size_config = &HyprlandAPI::getConfigValue(PHANDLE, "plugin:hycov:hotarea_size")->intValue;
	static const auto *pSwipe_fingers_config = &HyprlandAPI::getConfigValue(PHANDLE, "plugin:hycov:swipe_fingers")->intValue;
	static const auto *pMove_focus_distance_config = &HyprlandAPI::getConfigValue(PHANDLE, "plugin:hycov:move_focus_distance")->intValue;
	static const auto *pEnable_gesture_config = &HyprlandAPI::getConfigValue(PHANDLE, "plugin:hycov:enable_gesture")->intValue;
	static const auto *pDisable_workspace_change_config = &HyprlandAPI::getConfigValue(PHANDLE, "plugin:hycov:disable_workspace_change")->intValue;
	static const auto *pDisable_spawn_config = &HyprlandAPI::getConfigValue(PHANDLE, "plugin:hycov:disable_spawn")->intValue;
	static const auto *pAuto_exit_config = &HyprlandAPI::getConfigValue(PHANDLE, "plugin:hycov:auto_exit")->intValue;
	static const auto *pAuto_fullscreen = &HyprlandAPI::getConfigValue(PHANDLE, "plugin:hycov:auto_fullscreen")->intValue;


	g_enable_hotarea = *pEnable_hotarea_config;
	g_hotarea_size = *pHotarea_size_config;
	g_swipe_fingers = *pSwipe_fingers_config;
	g_move_focus_distance = *pMove_focus_distance_config;
	g_enable_gesture = *pEnable_gesture_config;
	g_disable_workspace_change = *pDisable_workspace_change_config;
	g_disable_spawn = *pDisable_spawn_config;
	g_auto_exit = *pAuto_exit_config;
	g_auto_fullscreen = *pAuto_fullscreen;


	g_GridLayout = std::make_unique<GridLayout>();
	HyprlandAPI::addLayout(PHANDLE, "grid", g_GridLayout.get());

	registerGlobalEventHook();
	registerDispatchers();

	return {"hycov", "clients overview", "DreamMaoMao", "0.1"};
}

APICALL EXPORT void PLUGIN_EXIT() {}
