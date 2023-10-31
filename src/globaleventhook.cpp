#include <hyprland/src/Compositor.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>
#include <regex>
#include <set>

#include "dispatchers.hpp"
#include "globals.hpp"
#include "GridLayout.hpp"

// std::unique_ptr<HOOK_CALLBACK_FN> mouseMoveHookPtr = std::make_unique<HOOK_CALLBACK_FN>(mouseMoveHook);
// std::unique_ptr<HOOK_CALLBACK_FN> mouseButtonHookPtr = std::make_unique<HOOK_CALLBACK_FN>(mouseButtonHook);
typedef void (*origOnSwipeBegin)(void*, wlr_pointer_swipe_begin_event* e);
typedef void (*origOnSwipeEnd)(void*, wlr_pointer_swipe_end_event* e);
typedef void (*origOnSwipeUpdate)(void*, wlr_pointer_swipe_update_event* e);

static double gesture_dx,gesture_previous_dx;
static double gesture_dy,gesture_previous_dy;

void hkOnSwipeUpdate(void* thisptr, wlr_pointer_swipe_update_event* e) {
  if(isOverView){
    gesture_dx = gesture_dx + e->dx;
    gesture_dy = gesture_dy + e->dy;
    if(e->dx > 0 && gesture_dx - gesture_previous_dx > move_focus_distance){
      dispatch_focusdir("r");
      gesture_previous_dx = gesture_dx;
    } else if(e->dx < 0 && gesture_previous_dx - gesture_dx > move_focus_distance){
      dispatch_focusdir("l");
      gesture_previous_dx = gesture_dx;
    } else if(e->dy > 0 && gesture_dy - gesture_previous_dy > move_focus_distance){
      dispatch_focusdir("d");
      gesture_previous_dy = gesture_dy;
    } else if(e->dy < 0 && gesture_previous_dy - gesture_dy > move_focus_distance){
      dispatch_focusdir("u");
      gesture_previous_dy = gesture_dy;
    }
    hycov_log(LOG,"OnSwipeUpdate hook toggle gesture_dx:{}",gesture_dx);
    return;
  }
  (*(origOnSwipeUpdate)g_pOnSwipeUpdateHook->m_pOriginal)(thisptr, e);
}

void hkOnSwipeBegin(void* thisptr, wlr_pointer_swipe_begin_event* e) {
  if(e->fingers == swipe_fingers){
    isGestureBegin = true;
    return;
  } 
  hycov_log(LOG,"OnSwipeBegin hook toggle");
  (*(origOnSwipeBegin)g_pOnSwipeBeginHook->m_pOriginal)(thisptr, e);
}

void hkOnSwipeEnd(void* thisptr, wlr_pointer_swipe_end_event* e) {
  gesture_dx = 0;
  gesture_previous_dx = 0;
  gesture_dy = 0;
  gesture_previous_dy = 0;
  
  if(isGestureBegin){
    isGestureBegin = false;
    dispatch_toggleoverview("");
    return;
  }
  hycov_log(LOG,"OnSwipeEnd hook toggle");
  (*(origOnSwipeEnd)g_pOnSwipeEndHook->m_pOriginal)(thisptr, e);
}

static void toggle_hotarea(int x_root, int y_root)
{
  CMonitor *PMONITOR = g_pCompositor->m_pLastMonitor;
  std::string arg = "";

  auto m_x = PMONITOR->vecPosition.x;
  auto m_y = PMONITOR->vecPosition.y;
  auto m_height = PMONITOR->vecSize.y;

  int hx = m_x + hotarea_size;
  int hy = m_y + m_height - hotarea_size;

  if (enable_hotarea == 1 && !isInHotArea && y_root > hy &&
      x_root < hx && x_root >= m_x &&
      y_root <= (m_y + m_height))
  {
    hycov_log(LOG,"cursor enter hotarea");
    dispatch_toggleoverview(arg);
    isInHotArea = true;
  }
  else if (enable_hotarea == 1 && isInHotArea &&
           (y_root <= hy || x_root >= hx || x_root < m_x ||
            y_root > (m_y + m_height)))
  {
    isInHotArea = false;
  }
  else if(enable_hotarea != 1 && enable_hotarea != 0) {
    hycov_log(ERR,"unkonw enavle_hotarea value:{}",enable_hotarea);
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
        dispatch_leaveoverview("");
      }
    }
    break;
  }
}

void registerGlobalEventHook()
{
  isInHotArea = false;
  isGestureBegin = false;
  isOverView = false;
  gesture_dx = 0;
  gesture_dy = 0;
  gesture_previous_dx = 0;
  gesture_previous_dy = 0;
  
  // HyprlandAPI::registerCallbackStatic(PHANDLE, "mouseMove", mouseMoveHookPtr.get());
  // HyprlandAPI::registerCallbackStatic(PHANDLE, "mouseButton", mouseButtonHookPtr.get());
  g_pOnSwipeBeginHook = HyprlandAPI::createFunctionHook(PHANDLE, (void*)&CInputManager::onSwipeBegin, (void*)&hkOnSwipeBegin);
  g_pOnSwipeEndHook = HyprlandAPI::createFunctionHook(PHANDLE, (void*)&CInputManager::onSwipeEnd, (void*)&hkOnSwipeEnd);
  g_pOnSwipeUpdateHook = HyprlandAPI::createFunctionHook(PHANDLE, (void*)&CInputManager::onSwipeUpdate, (void*)&hkOnSwipeUpdate);

  if(enable_hotarea){
    HyprlandAPI::registerCallbackDynamic(PHANDLE, "mouseMove",[&](void* self, SCallbackInfo& info, std::any data) { mouseMoveHook(self, info, data); });
    HyprlandAPI::registerCallbackDynamic(PHANDLE, "mouseButton", [&](void* self, SCallbackInfo& info, std::any data) { mouseButtonHook(self, info, data); });
  }

  if(enable_gesture){
    g_pOnSwipeBeginHook->hook();
    g_pOnSwipeEndHook->hook();
    g_pOnSwipeUpdateHook->hook();
  }

}
