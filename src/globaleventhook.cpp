
#include "globaleventhook.hpp"
#include "dispatchers.hpp"
#include <regex>
#include <set>
#include <hyprland/src/SharedDefs.hpp>
#include "GridLayout.hpp"

// std::unique_ptr<HOOK_CALLBACK_FN> mouseMoveHookPtr = std::make_unique<HOOK_CALLBACK_FN>(mouseMoveHook);
// std::unique_ptr<HOOK_CALLBACK_FN> mouseButtonHookPtr = std::make_unique<HOOK_CALLBACK_FN>(mouseButtonHook);
typedef void (*origOnSwipeBegin)(void*, wlr_pointer_swipe_begin_event* e);
typedef void (*origOnSwipeEnd)(void*, wlr_pointer_swipe_end_event* e);
typedef void (*origOnSwipeUpdate)(void*, wlr_pointer_swipe_update_event* e);
typedef void (*origOnWindowRemovedTiling)(void*, CWindow *pWindow);
typedef void (*origStartAnim)(void*, bool in, bool left, bool instant);
typedef void (*origFullscreenActive)(std::string args);
typedef void (*origOnKeyboardKey)(void*, wlr_keyboard_key_event* e, SKeyboard* pKeyboard);

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
  // call the original function,Let it do what it should do
  (*(origOnSwipeUpdate)g_pOnSwipeUpdateHook->m_pOriginal)(thisptr, e);
}

static void hkOnSwipeBegin(void* thisptr, wlr_pointer_swipe_begin_event* e) {
  if(e->fingers == g_swipe_fingers){
    g_isGestureBegin = true;
    return;
  } 
  hycov_log(LOG,"OnSwipeBegin hook toggle");

  // call the original function,Let it do what it should do
  (*(origOnSwipeBegin)g_pOnSwipeBeginHook->m_pOriginal)(thisptr, e);
}

static void hkOnSwipeEnd(void* thisptr, wlr_pointer_swipe_end_event* e) {
  gesture_dx = 0;
  gesture_previous_dx = 0;
  gesture_dy = 0;
  gesture_previous_dy = 0;
  
  if(g_isGestureBegin){
    g_isGestureBegin = false;
    dispatch_toggleoverview("internalToggle");
    return;
  }
  hycov_log(LOG,"OnSwipeEnd hook toggle");
  // call the original function,Let it do what it should do
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
    dispatch_toggleoverview("internalToggle");
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
  if(!g_isOverView)
    return;
    
  wlr_pointer_button_event *pEvent = std::any_cast<wlr_pointer_button_event *>(data); // 这个事件的数据解析可以参考dwl怎么解析出是哪个按键的
  info.cancelled = false;
  CWindow *pTargetWindow = g_pCompositor->windowFromCursor();
  if(pTargetWindow)
    g_pCompositor->focusWindow(pTargetWindow);

  switch (pEvent->button)
  {
  case BTN_LEFT:
    if (g_isOverView && pEvent->state == WLR_BUTTON_PRESSED)
    {
      dispatch_toggleoverview("internalToggle");
      info.cancelled = true;  // Prevent the event from continuing to be passed to the client
    }
    break;
  case BTN_RIGHT:
    if (g_isOverView && pEvent->state == WLR_BUTTON_PRESSED)
    {
      g_pHyprRenderer->damageWindow(g_pCompositor->m_pLastWindow);
      g_pCompositor->closeWindow(g_pCompositor->m_pLastWindow);
      info.cancelled = true; // Prevent the event from continuing to be passed to the client
    }
    break;
  }
}

static void hkOnWindowRemovedTiling(void* thisptr, CWindow *pWindow) {
  // call the original function,Let it do what it should do
  (*(origOnWindowRemovedTiling)g_pOnWindowRemovedTilingHook->m_pOriginal)(thisptr, pWindow);

  // after done original thing,The workspace automatically exit overview if no client exists 
  auto nodeNumInSameMonitor = 0;
  auto nodeNumInSameWorkspace = 0;
	for (auto &n : g_GridLayout->m_lGridNodesData) {
		if(n.pWindow->m_iMonitorID == g_pCompositor->m_pLastMonitor->ID) {
			nodeNumInSameMonitor++;
		}
		if(n.pWindow->m_iWorkspaceID == g_pCompositor->m_pLastMonitor->activeWorkspace) {
			nodeNumInSameWorkspace++;
		}
	}

  if (g_isOverView && nodeNumInSameMonitor == 0) {
    hycov_log(LOG,"no tiling window in same monitor,auto exit overview");
    dispatch_leaveoverview("");
    return;
  }

  if (g_isOverView && nodeNumInSameWorkspace == 0 && g_only_active_workspace) {
    hycov_log(LOG,"no tiling windwo in same workspace,auto exit overview");
    dispatch_leaveoverview("");
    return;
  }

}

static void hkChangeworkspace(void* thisptr, std::string args) {
  // just log a message and do nothing, mean the original function is disabled
  hycov_log(LOG,"ChangeworkspaceHook hook toggle");
}

static void hkMoveActiveToWorkspace(void* thisptr, std::string args) {
  // just log a message and do nothing, mean the original function is disabled
  hycov_log(LOG,"MoveActiveToWorkspace hook toggle");
}

static void hkSpawn(void* thisptr, std::string args) {
  // just log a message and do nothing, mean the original function is disabled
  hycov_log(LOG,"Spawn hook toggle");
}

static void hkStartAnim(void* thisptr,bool in, bool left, bool instant = false) {
  // if is exiting overview, omit the animation of workspace change (instant = true)
  if (g_isOverViewExiting) {
    (*(origStartAnim)g_pStartAnimHook->m_pOriginal)(thisptr, in, left, true);
    hycov_log(LOG,"hook startAnim,disable workspace change anim,in:{},isOverview:{}",in,g_isOverView);
  } else {
    (*(origStartAnim)g_pStartAnimHook->m_pOriginal)(thisptr, in, left, instant);
    hycov_log(LOG,"hook startAnim,enable workspace change anim,in:{},isOverview:{}",in,g_isOverView);
  }
}

static void hkOnKeyboardKey(void* thisptr,wlr_keyboard_key_event* e, SKeyboard* pKeyboard) {

  // WL_KEYBOARD_KEY_STATE_RELEASED
  (*(origOnKeyboardKey)g_pOnKeyboardKeyHook->m_pOriginal)(thisptr, e, pKeyboard);
  // hycov_log(LOG,"alt key,keycode:{}",e->keycode);
  if(g_enable_alt_release_exit && g_isOverView && e->keycode == 56 && e->state == WL_KEYBOARD_KEY_STATE_RELEASED) {
    dispatch_leaveoverview("");
    hycov_log(LOG,"alt key release toggle leave overview");
  }

}

static void hkFullscreenActive(std::string args) {
  // auto exit overview and fullscreen window when toggle fullscreen in overview mode
  hycov_log(LOG,"FullscreenActive hook toggle");

  // (*(origFullscreenActive)g_pFullscreenActiveHook->m_pOriginal)(args);
  const auto pWindow = g_pCompositor->m_pLastWindow;

  if (!pWindow)
        return;

  if (g_pCompositor->isWorkspaceSpecial(pWindow->m_iWorkspaceID))
        return;

  if (g_isOverView && want_auto_fullscren(pWindow) && !g_auto_fullscreen) {
    dispatch_toggleoverview("internalToggle");
    g_pCompositor->setWindowFullscreen(pWindow, !pWindow->m_bIsFullscreen, args == "1" ? FULLSCREEN_MAXIMIZED : FULLSCREEN_FULL);
  } else if (g_isOverView && (!want_auto_fullscren(pWindow) || g_auto_fullscreen)) {
        dispatch_toggleoverview("internalToggle");
  } else {
    g_pCompositor->setWindowFullscreen(pWindow, !pWindow->m_bIsFullscreen, args == "1" ? FULLSCREEN_MAXIMIZED : FULLSCREEN_FULL);
  }
}

void registerGlobalEventHook()
{
  g_isInHotArea = false;
  g_isGestureBegin = false;
  g_isOverView = false;
  g_isOverViewExiting = false;
  gesture_dx = 0;
  gesture_dy = 0;
  gesture_previous_dx = 0;
  gesture_previous_dy = 0;
  
  // HyprlandAPI::registerCallbackStatic(PHANDLE, "mouseMove", mouseMoveHookPtr.get());
  // HyprlandAPI::registerCallbackStatic(PHANDLE, "mouseButton", mouseButtonHookPtr.get());
  
  //create public function hook

  // hook function of Swipe gesture event handle 
  g_pOnSwipeBeginHook = HyprlandAPI::createFunctionHook(PHANDLE, (void*)&CInputManager::onSwipeBegin, (void*)&hkOnSwipeBegin);
  g_pOnSwipeEndHook = HyprlandAPI::createFunctionHook(PHANDLE, (void*)&CInputManager::onSwipeEnd, (void*)&hkOnSwipeEnd);
  g_pOnSwipeUpdateHook = HyprlandAPI::createFunctionHook(PHANDLE, (void*)&CInputManager::onSwipeUpdate, (void*)&hkOnSwipeUpdate);

  // hook function of Gridlayout Remove a node from tiled list
  g_pOnWindowRemovedTilingHook = HyprlandAPI::createFunctionHook(PHANDLE, (void*)&GridLayout::onWindowRemovedTiling, (void*)&hkOnWindowRemovedTiling);

  // hook function of workspace change animation start
  g_pStartAnimHook = HyprlandAPI::createFunctionHook(PHANDLE, (void*)&CWorkspace::startAnim, (void*)&hkStartAnim);
  g_pStartAnimHook->hook();

  //  hook function of keypress
  g_pOnKeyboardKeyHook = HyprlandAPI::createFunctionHook(PHANDLE, (void*)&CInputManager::onKeyboardKey, (void*)&hkOnKeyboardKey);
  g_pOnKeyboardKeyHook->hook();

  //create private function hook

  // hook function of changeworkspace
  static const auto ChangeworkspaceMethods = HyprlandAPI::findFunctionsByName(PHANDLE, "changeworkspace");
  g_pChangeworkspaceHook = HyprlandAPI::createFunctionHook(PHANDLE, ChangeworkspaceMethods[0].address, (void*)&hkChangeworkspace);

  // hook function of moveActiveToWorkspace
  static const auto MoveActiveToWorkspaceMethods = HyprlandAPI::findFunctionsByName(PHANDLE, "moveActiveToWorkspace");
  g_pMoveActiveToWorkspaceHook = HyprlandAPI::createFunctionHook(PHANDLE, MoveActiveToWorkspaceMethods[0].address, (void*)&hkMoveActiveToWorkspace);

  // hook function of spawn (bindkey will call spawn to excute a command or a dispatch)
  static const auto SpawnMethods = HyprlandAPI::findFunctionsByName(PHANDLE, "spawn");
  g_pSpawnHook = HyprlandAPI::createFunctionHook(PHANDLE, SpawnMethods[0].address, (void*)&hkSpawn);

  //hook function of fullscreenActive
  static const auto FullscreenActiveMethods = HyprlandAPI::findFunctionsByName(PHANDLE, "fullscreenActive");
  g_pFullscreenActiveHook = HyprlandAPI::createFunctionHook(PHANDLE, FullscreenActiveMethods[0].address, (void*)&hkFullscreenActive);

  //register pEvent hook
  if(g_enable_hotarea){
    HyprlandAPI::registerCallbackDynamic(PHANDLE, "mouseMove",[&](void* self, SCallbackInfo& info, std::any data) { mouseMoveHook(self, info, data); });
    HyprlandAPI::registerCallbackDynamic(PHANDLE, "mouseButton", [&](void* self, SCallbackInfo& info, std::any data) { mouseButtonHook(self, info, data); });
  }

  //if enable gesture, apply hook Swipe function 
  if(g_enable_gesture){
    g_pOnSwipeBeginHook->hook();
    g_pOnSwipeEndHook->hook();
    g_pOnSwipeUpdateHook->hook();
  }

  //if enable auto_exit, apply hook RemovedTiling function
  if(g_auto_exit){
    g_pOnWindowRemovedTilingHook->hook();
  }

  // TODO: wait hyprland to support this function hook
  // enable hook fullscreenActive funciton
  g_pFullscreenActiveHook->hook();
}
