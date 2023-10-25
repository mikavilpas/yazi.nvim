#pragma once

#include <hyprland/src/debug/Log.hpp>

template <typename... Args>
void hycov_log(LogLevel level, std::format_string<Args...> fmt, Args &&...args)
{
	auto msg = std::vformat(fmt.get(), std::make_format_args(args...));
	Debug::log(level, "[hycov] {}", msg);
}
