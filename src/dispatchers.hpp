#pragma once
#include "globals.hpp"

enum class ShiftDirection {
	Left,
	Up,
	Down,
	Right,
};

bool want_auto_fullscren(CWindow *pWindow);
void dispatch_focusdir(std::string arg);
void dispatch_toggleoverview(std::string arg);
void dispatch_enteroverview(std::string arg);
void dispatch_leaveoverview(std::string arg);

void registerDispatchers();
