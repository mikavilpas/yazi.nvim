#pragma once
#include "globals.hpp"

enum class ShiftDirection {
	Left,
	Up,
	Down,
	Right,
};

bool want_auto_fullscren(CWindow *pWindow);
bool isDirection(const std::string& arg);
CWindow *direction_select(std::string arg);
CWindow *get_circle_next_window (std::string arg);
void warpcursor_and_focus_to_window(CWindow *pWindow);
void switchToLayoutWithoutReleaseData(std::string layout);
void recalculateAllMonitor();

void dispatch_circle(std::string arg);
void dispatch_focusdir(std::string arg);

void dispatch_toggleoverview(std::string arg);
void dispatch_enteroverview(std::string arg);
void dispatch_leaveoverview(std::string arg);

void registerDispatchers();
