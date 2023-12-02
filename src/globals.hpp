#pragma once

#include "GridLayout.hpp"
#include "log.hpp"

#include <hyprland/src/plugins/PluginAPI.hpp>

inline HANDLE PHANDLE = nullptr;
inline std::unique_ptr<GridLayout> g_GridLayout;

inline bool g_isOverView;
inline bool g_isInHotArea;
inline int g_enable_hotarea;
inline int g_hotarea_size;
inline int g_swipe_fingers;
inline int g_isGestureBegin;
inline int g_move_focus_distance;
inline int g_enable_gesture;
inline int g_disable_workspace_change;
inline int g_disable_spawn;
inline int g_auto_exit;
inline int g_auto_fullscreen;

inline CFunctionHook* g_pOnSwipeBeginHook = nullptr;
inline CFunctionHook* g_pOnSwipeEndHook = nullptr;
inline CFunctionHook* g_pOnSwipeUpdateHook = nullptr;
inline CFunctionHook* g_pOnWindowRemovedTilingHook = nullptr;
inline CFunctionHook* g_pChangeworkspaceHook = nullptr;
inline CFunctionHook* g_pMoveActiveToWorkspaceHook = nullptr;
inline CFunctionHook* g_pSpawnHook = nullptr;

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
