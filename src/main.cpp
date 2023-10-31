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

#undef CONF

	static const auto *enable_hotarea_config = &HyprlandAPI::getConfigValue(PHANDLE, "plugin:hycov:enable_hotarea")->intValue;
  	static const auto *hotarea_size_config = &HyprlandAPI::getConfigValue(PHANDLE, "plugin:hycov:hotarea_size")->intValue;
	static const auto *swipe_fingers_config = &HyprlandAPI::getConfigValue(PHANDLE, "plugin:hycov:swipe_fingers")->intValue;
	static const auto *move_focus_distance_config = &HyprlandAPI::getConfigValue(PHANDLE, "plugin:hycov:move_focus_distance")->intValue;
	
	enable_hotarea = *enable_hotarea_config;
	hotarea_size = *hotarea_size_config;
	swipe_fingers = *swipe_fingers_config;
	move_focus_distance = *move_focus_distance_config;

	g_GridLayout = std::make_unique<GridLayout>();
	HyprlandAPI::addLayout(PHANDLE, "grid", g_GridLayout.get());

	registerGlobalEventHook();
	registerDispatchers();

	return {"hycov", "clients overview", "DreamMaoMao", "0.1"};
}

APICALL EXPORT void PLUGIN_EXIT() {}
