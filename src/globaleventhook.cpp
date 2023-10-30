#include <hyprland/src/Compositor.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>
#include <hyprland/src/SharedDefs.hpp>
#include <regex>
#include <set>

#include "dispatchers.hpp"
#include "globals.hpp"
#include "GridLayout.hpp"

std::unique_ptr<HOOK_CALLBACK_FN> mouseMoveHookPtr = std::make_unique<HOOK_CALLBACK_FN>(GridLayout::mouseMoveHook);
std::unique_ptr<HOOK_CALLBACK_FN> mouseButtonHookPtr = std::make_unique<HOOK_CALLBACK_FN>(GridLayout::mouseButtonHook);

void GridLayout::toggle_hotarea(int x_root, int y_root)
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

  if (*enable_hotarea == 1 && !g_GridLayout->isInHotArea && y_root > hy &&
      x_root < hx && x_root >= m_x &&
      y_root <= (m_y + m_height))
  {
    hycov_log(LOG,"cursor enter hotarea");
    dispatch_toggleoverview(arg);
    g_GridLayout->isInHotArea = true;
  }
  else if (*enable_hotarea == 1 && g_GridLayout->isInHotArea &&
           (y_root <= hy || x_root >= hx || x_root < m_x ||
            y_root > (m_y + m_height)))
  {
    g_GridLayout->isInHotArea = false;
  }
}

void GridLayout::mouseMoveHook(void *, SCallbackInfo &info, std::any data)
{
  try {
    const Vector2D coordinate = std::any_cast<const Vector2D>(data);
    toggle_hotarea(coordinate.x, coordinate.y);
  } catch (std::bad_any_cast& e) { 
    std::string e_msg = e.what();
    HyprlandAPI::addNotification(PHANDLE, "[hycov] mouseMoveHook Exception:" + e_msg, CColor{0.f, 0.5f, 1.f, 1.f}, 5000); 
  }
}

void GridLayout::mouseButtonHook(void *, SCallbackInfo &info, std::any data)
{
  try {
    wlr_pointer_button_event *event = std::any_cast<wlr_pointer_button_event *>(data); // 这个事件的数据解析可以参考dwl怎么解析出是哪个按键的
    info.cancelled = false;
    switch (event->button)
    {
    case BTN_LEFT:
      if (g_GridLayout->isOverView && event->state == WLR_BUTTON_PRESSED)
      {
        dispatch_toggleoverview("");
        info.cancelled = true;
      }
      break;
    case BTN_RIGHT:
      if (g_GridLayout->isOverView && event->state == WLR_BUTTON_PRESSED)
      {
        g_pHyprRenderer->damageWindow(g_pCompositor->m_pLastWindow);
        g_pCompositor->closeWindow(g_pCompositor->m_pLastWindow);
        info.cancelled = true;
      }
      else if (g_GridLayout->isOverView && event->state == WLR_BUTTON_RELEASED)
      {
        if (g_GridLayout->m_lGridNodesData.empty())
        {
          dispatch_toggleoverview("");
        }
      }

      break;
    }
  } catch (std::bad_any_cast& e) { 
      std::string e_msg = e.what();
      HyprlandAPI::addNotification(PHANDLE, "[hycov] mouseButtonHook Exception:" + e_msg, CColor{0.f, 0.5f, 1.f, 1.f}, 5000); 
  }
}

void registerGlobalEventHook()
{
  g_GridLayout->isInHotArea = false;
  HyprlandAPI::registerCallbackStatic(PHANDLE, "mouseMove", mouseMoveHookPtr.get());
  HyprlandAPI::registerCallbackStatic(PHANDLE, "mouseButton", mouseButtonHookPtr.get());
}
