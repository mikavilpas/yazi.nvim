#pragma once

#include "log.hpp"
#include <hyprland/src/includes.hpp>
#include <any>

#define private public
#include <hyprland/src/Compositor.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>
#include <hyprland/src/managers/KeybindManager.hpp>
#undef private

#include "GridLayout.hpp"


inline HANDLE PHANDLE = nullptr;
inline std::unique_ptr<GridLayout> g_GridLayout;

inline bool g_isOverView;
inline bool g_isInHotArea;
inline int g_enable_hotarea;
inline int g_hotarea_size;
inline unsigned int g_swipe_fingers;
inline int g_isGestureBegin;
inline int g_move_focus_distance;
inline int g_enable_gesture;
inline int g_disable_workspace_change;
inline int g_disable_spawn;
inline int g_auto_exit;
inline int g_auto_fullscreen;
inline int g_only_active_workspace;
inline int g_only_active_monitor;
inline int g_enable_alt_release_exit;
inline int g_alt_toggle_auto_next;
inline bool g_isOverViewExiting;

inline CFunctionHook* g_pOnSwipeBeginHook = nullptr;
inline CFunctionHook* g_pOnSwipeEndHook = nullptr;
inline CFunctionHook* g_pOnSwipeUpdateHook = nullptr;
inline CFunctionHook* g_pOnWindowRemovedTilingHook = nullptr;
inline CFunctionHook* g_pChangeworkspaceHook = nullptr;
inline CFunctionHook* g_pMoveActiveToWorkspaceHook = nullptr;
inline CFunctionHook* g_pSpawnHook = nullptr;
inline CFunctionHook* g_pStartAnimHook = nullptr;
inline CFunctionHook* g_pFullscreenActiveHook = nullptr;
inline CFunctionHook* g_pOnKeyboardKeyHook = nullptr;

inline void errorNotif()
{
	HyprlandAPI::addNotificationV2(
		PHANDLE,
		{
			{"text", "Something has gone very wrong. Check the log for details."},
			{"time", (uint64_t)10000},
			{"color", CColor(1.0, 0.0, 0.0, 1.0)},
			{"icon", ICON_ERROR},
		});
}
