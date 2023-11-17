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
typedef void (*origOnWindowRemovedTiling)(void*, CWindow *pWindow);

static double gesture_dx,gesture_previous_dx;
static double gesture_dy,gesture_previous_dy;

static void hkOnSwipeUpdate(void* thisptr, wlr_pointer_swipe_update_event* e) {
  if(g_isOverView){
    gesture_dx = gesture_dx + e->dx;
    gesture_dy = gesture_dy + e->dy;
    if(e->dx > 0 && gesture_dx - gesture_previous_dx > g_move_focus_distance){
      dispatch_focusdir("r");
      gesture_previous_dx = gesture_dx;
      hycov_log(LOG,"OnSwipeUpdate hook focus right");
    } else if(e->dx < 0 && gesture_previous_dx - gesture_dx > g_move_focus_distance){
      dispatch_focusdir("l");
      gesture_previous_dx = gesture_dx;
      hycov_log(LOG,"OnSwipeUpdate hook focus left");
    } else if(e->dy > 0 && gesture_dy - gesture_previous_dy > g_move_focus_distance){
      dispatch_focusdir("d");
      gesture_previous_dy = gesture_dy;
      hycov_log(LOG,"OnSwipeUpdate hook focus down");
    } else if(e->dy < 0 && gesture_previous_dy - gesture_dy > g_move_focus_distance){
      dispatch_focusdir("u");
      gesture_previous_dy = gesture_dy;
      hycov_log(LOG,"OnSwipeUpdate hook focus up");
    }
    return;
  }
  (*(origOnSwipeUpdate)g_pOnSwipeUpdateHook->m_pOriginal)(thisptr, e);
}

static void hkOnSwipeBegin(void* thisptr, wlr_pointer_swipe_begin_event* e) {
  if(e->fingers == g_swipe_fingers){
    g_isGestureBegin = true;
    return;
  } 
  hycov_log(LOG,"OnSwipeBegin hook toggle");
  (*(origOnSwipeBegin)g_pOnSwipeBeginHook->m_pOriginal)(thisptr, e);
}

static void hkOnSwipeEnd(void* thisptr, wlr_pointer_swipe_end_event* e) {
  gesture_dx = 0;
  gesture_previous_dx = 0;
  gesture_dy = 0;
  gesture_previous_dy = 0;
  
  if(g_isGestureBegin){
    g_isGestureBegin = false;
    dispatch_toggleoverview("");
    return;
  }
  hycov_log(LOG,"OnSwipeEnd hook toggle");
  (*(origOnSwipeEnd)g_pOnSwipeEndHook->m_pOriginal)(thisptr, e);
}

static void toggle_hotarea(int x_root, int y_root)
{
  CMonitor *pMonitor = g_pCompositor->m_pLastMonitor;
  std::string arg = "";

  auto m_x = pMonitor->vecPosition.x;
  auto m_y = pMonitor->vecPosition.y;
  auto m_height = pMonitor->vecSize.y;

  int hx = m_x + g_hotarea_size;
  int hy = m_y + m_height - g_hotarea_size;

  if (!g_isInHotArea && y_root > hy &&
      x_root < hx && x_root >= m_x &&
      y_root <= (m_y + m_height))
  {
    hycov_log(LOG,"cursor enter hotarea");
    dispatch_toggleoverview(arg);
    g_isInHotArea = true;
  }
  else if (g_isInHotArea &&
           (y_root <= hy || x_root >= hx || x_root < m_x ||
            y_root > (m_y + m_height)))
  {
    if(g_isInHotArea)
      g_isInHotArea = false;
  }
}

static void mouseMoveHook(void *, SCallbackInfo &info, std::any data)
{

  const Vector2D coordinate = std::any_cast<const Vector2D>(data);
  toggle_hotarea(coordinate.x, coordinate.y);
}

static void mouseButtonHook(void *, SCallbackInfo &info, std::any data)
{
  wlr_pointer_button_event *pEvent = std::any_cast<wlr_pointer_button_event *>(data); // 这个事件的数据解析可以参考dwl怎么解析出是哪个按键的
  info.cancelled = false;
  switch (pEvent->button)
  {
  case BTN_LEFT:
    if (g_isOverView && pEvent->state == WLR_BUTTON_PRESSED)
    {
      dispatch_toggleoverview("");
      info.cancelled = true;
    }
    break;
  case BTN_RIGHT:
    if (g_isOverView && pEvent->state == WLR_BUTTON_PRESSED)
    {
      g_pHyprRenderer->damageWindow(g_pCompositor->m_pLastWindow);
      g_pCompositor->closeWindow(g_pCompositor->m_pLastWindow);
      info.cancelled = true;
    }
    break;
  }
}

static void hkOnWindowRemovedTiling(void* thisptr, CWindow *pWindow) {
  (*(origOnWindowRemovedTiling)g_pOnWindowRemovedTilingHook->m_pOriginal)(thisptr, pWindow);

  if (g_isOverView && g_GridLayout->m_lGridNodesData.empty()) {
    hycov_log(LOG,"no tiling windwo,auto exit overview");
    dispatch_leaveoverview("");
  }
}

static void hkChangeworkspace(void* thisptr, std::string args) {
  hycov_log(LOG,"ChangeworkspaceHook hook toggle");
}

static void hkMoveActiveToWorkspace(void* thisptr, std::string args) {
  hycov_log(LOG,"MoveActiveToWorkspace hook toggle");
}

static void hkSpawn(void* thisptr, std::string args) {
  hycov_log(LOG,"Spawn hook toggle");
}

void registerGlobalEventHook()
{
  g_isInHotArea = false;
  g_isGestureBegin = false;
  g_isOverView = false;
  gesture_dx = 0;
  gesture_dy = 0;
  gesture_previous_dx = 0;
  gesture_previous_dy = 0;
  
  // HyprlandAPI::registerCallbackStatic(PHANDLE, "mouseMove", mouseMoveHookPtr.get());
  // HyprlandAPI::registerCallbackStatic(PHANDLE, "mouseButton", mouseButtonHookPtr.get());
  //create public function hook
  g_pOnSwipeBeginHook = HyprlandAPI::createFunctionHook(PHANDLE, (void*)&CInputManager::onSwipeBegin, (void*)&hkOnSwipeBegin);
  g_pOnSwipeEndHook = HyprlandAPI::createFunctionHook(PHANDLE, (void*)&CInputManager::onSwipeEnd, (void*)&hkOnSwipeEnd);
  g_pOnSwipeUpdateHook = HyprlandAPI::createFunctionHook(PHANDLE, (void*)&CInputManager::onSwipeUpdate, (void*)&hkOnSwipeUpdate);

  g_pOnWindowRemovedTilingHook = HyprlandAPI::createFunctionHook(PHANDLE, (void*)&GridLayout::onWindowRemovedTiling, (void*)&hkOnWindowRemovedTiling);
  g_pOnWindowRemovedTilingHook->hook();

  //create private function hook
  static const auto ChangeworkspaceMethods = HyprlandAPI::findFunctionsByName(PHANDLE, "changeworkspace");
  g_pChangeworkspaceHook = HyprlandAPI::createFunctionHook(PHANDLE, ChangeworkspaceMethods[0].address, (void*)&hkChangeworkspace);

  static const auto MoveActiveToWorkspaceMethods = HyprlandAPI::findFunctionsByName(PHANDLE, "moveActiveToWorkspace");
  g_pMoveActiveToWorkspaceHook = HyprlandAPI::createFunctionHook(PHANDLE, MoveActiveToWorkspaceMethods[0].address, (void*)&hkMoveActiveToWorkspace);

  static const auto SpawnMethods = HyprlandAPI::findFunctionsByName(PHANDLE, "spawn");
  g_pSpawnHook = HyprlandAPI::createFunctionHook(PHANDLE, SpawnMethods[0].address, (void*)&hkSpawn);

  if(g_enable_hotarea){
    //register pEvent hook
    HyprlandAPI::registerCallbackDynamic(PHANDLE, "mouseMove",[&](void* self, SCallbackInfo& info, std::any data) { mouseMoveHook(self, info, data); });
    HyprlandAPI::registerCallbackDynamic(PHANDLE, "mouseButton", [&](void* self, SCallbackInfo& info, std::any data) { mouseButtonHook(self, info, data); });
  }

  if(g_enable_gesture){
    //enabel function hook
    g_pOnSwipeBeginHook->hook();
    g_pOnSwipeEndHook->hook();
    g_pOnSwipeUpdateHook->hook();
  }

}
