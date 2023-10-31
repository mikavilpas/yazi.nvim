#pragma once

enum class ShiftDirection {
	Left,
	Up,
	Down,
	Right,
};

void dispatch_focusdir(std::string arg);
void dispatch_toggleoverview(std::string arg);
void dispatch_enteroverview(std::string arg);
void dispatch_leaveoverview(std::string arg);

void registerDispatchers();
