#include <hyprland/src/Compositor.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>
#include <regex>
#include <set>

#include "dispatchers.hpp"
#include "globals.hpp"
#include "GridLayout.hpp"

static void toggle_hotarea(int x_root, int y_root)
{
  CMonitor *PMONITOR = g_pCompositor->m_pLastMonitor;
  std::string arg = "";
  static const auto *enable_hotarea = &HyprlandAPI::getConfigValue(PHANDLE, "plugin:hycov:enable_hotarea")->intValue;
  static const auto *hotarea_size = &HyprlandAPI::getConfigValue(PHANDLE, "plugin:hycov:hotarea_size")->intValue;

  auto m_x = PMONITOR->vecPosition.x;
  auto m_y = PMONITOR->vecPosition.y;
  auto m_height = PMONITOR->vecSize.y;

  int hx = m_x + *hotarea_size;
  int hy = m_y + m_height - *hotarea_size;

  if (*enable_hotarea == 1 && !isInHotArea && y_root > hy &&
      x_root < hx && x_root >= m_x &&
      y_root <= (m_y + m_height))
  {
    hycov_log(LOG,"cursor enter hotarea");
    dispatch_toggleoverview(arg);
    isInHotArea = true;
  }
  else if (*enable_hotarea == 1 && isInHotArea &&
           (y_root <= hy || x_root >= hx || x_root < m_x ||
            y_root > (m_y + m_height)))
  {
    isInHotArea = false;
  }
}

static void mouseMoveHook(void *, SCallbackInfo &info, std::any data)
{

  const Vector2D coordinate = std::any_cast<const Vector2D>(data);
  toggle_hotarea(coordinate.x, coordinate.y);
}

static void mouseButtonHook(void *, SCallbackInfo &info, std::any data)
{
  wlr_pointer_button_event *event = std::any_cast<wlr_pointer_button_event *>(data); // 这个事件的数据解析可以参考dwl怎么解析出是哪个按键的
  info.cancelled = false;
  switch (event->button)
  {
  case BTN_LEFT:
    if (isOverView && event->state == WLR_BUTTON_PRESSED)
    {
      dispatch_toggleoverview("");
      info.cancelled = true;
    }
    break;
  case BTN_RIGHT:
    if (isOverView && event->state == WLR_BUTTON_PRESSED)
    {
      g_pHyprRenderer->damageWindow(g_pCompositor->m_pLastWindow);
      g_pCompositor->closeWindow(g_pCompositor->m_pLastWindow);
      info.cancelled = true;
    }
    else if (isOverView && event->state == WLR_BUTTON_RELEASED)
    {
      if (g_GridLayout->m_lGridNodesData.empty())
      {
        dispatch_toggleoverview("");
      }
    }
    break;
  }
}

void registerGlobalEventHook()
{
  isInHotArea = false;
  HyprlandAPI::registerCallbackDynamic(PHANDLE, "mouseMove",[&](void* self, SCallbackInfo& info, std::any data) { mouseMoveHook(self, info, data); });
  HyprlandAPI::registerCallbackDynamic(PHANDLE, "mouseButton", [&](void* self, SCallbackInfo& info, std::any data) { mouseButtonHook(self, info, data); });
}
