#pragma once

#include "GridLayout.hpp"
#include "log.hpp"

#include <hyprland/src/plugins/PluginAPI.hpp>

inline HANDLE PHANDLE = nullptr;
inline std::unique_ptr<GridLayout> g_GridLayout;

inline bool isOverView;
inline bool isInHotArea;
inline int enable_hotarea;
inline int hotarea_size;
inline int swipe_fingers;
inline int isGestureBegin;
inline int move_focus_distance;
inline int enable_gesture;

inline CFunctionHook* g_pOnSwipeBeginHook = nullptr;
inline CFunctionHook* g_pOnSwipeEndHook = nullptr;
inline CFunctionHook* g_pOnSwipeUpdateHook = nullptr;
inline CFunctionHook* g_pOnWindowRemovedTilingHook = nullptr;
inline CFunctionHook* g_pChangeworkspaceHook = nullptr;
inline CFunctionHook* g_pMoveActiveToWorkspaceHook = nullptr;

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
