#include <optional>

#include <hyprland/src/Compositor.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>

#include "dispatchers.hpp"
#include "globals.hpp"

std::optional<ShiftDirection> parseShiftArg(std::string arg) {
	if (arg == "l" || arg == "left") return ShiftDirection::Left;
	else if (arg == "r" || arg == "right") return ShiftDirection::Right;
	else if (arg == "u" || arg == "up") return ShiftDirection::Up;
	else if (arg == "d" || arg == "down") return ShiftDirection::Down;
	else return {};
}

CWindow  *direction_select(std::string arg){
	CWindow *tempCWindows[100];
	CWindow *tc =  g_pCompositor->m_pLastWindow;
	CWindow *tempFocusCWindows = nullptr;
	int last = -1;
	if(!tc){
		return nullptr;
	}else if (tc->m_bIsFullscreen){
		return nullptr;
	}

    // for (auto &node : g_GridLayout->m_lGridNodesData)
    // {
    //     if (node.workspaceID == tc->m_iWorkspaceID)
    //     {
	// 		last++;
	// 		tempCWindows[last] = node.pWindow;
    //     }
    // }
    for (auto &w : g_pCompositor->m_vWindows)
    {
        if (tc == w.get() || w->isHidden() || !w->m_bIsMapped || w->m_bFadingOut || w->m_bIsFullscreen)
            continue;
			last++;
			tempCWindows[last] = w.get();			
    }
	
  	if (last < 0)
  	  return nullptr;
	hycov_log(LOG,"hy_log focus dir {}",last);
  	int sel_x = tc->m_vRealPosition.goalv().x;
  	int sel_y = tc->m_vRealPosition.goalv().y;
  	long long int distance = LLONG_MAX;
  	// int temp_focus = 0;

	auto values = CVarList(arg);
	auto shift = parseShiftArg(values[0]);
  	switch (shift.value()) {
  	case ShiftDirection::Up:
  	  for (int _i = 0; _i <= last; _i++) {
  	    if (tempCWindows[_i]->m_vRealPosition.goalv().y < sel_y ) {
  	      int dis_x = tempCWindows[_i]->m_vRealPosition.goalv().x - sel_x;
  	      int dis_y = tempCWindows[_i]->m_vRealPosition.goalv().y - sel_y;
  	      long long int tmp_distance = dis_x * dis_x + dis_y * dis_y; 
  	      if (tmp_distance < distance) {
  	        distance = tmp_distance;
  	        tempFocusCWindows = tempCWindows[_i];
  	      }
  	    }
  	  }
  	  break;
  	case ShiftDirection::Down:
  	  for (int _i = 0; _i <= last; _i++) {
  	    if (tempCWindows[_i]->m_vRealPosition.goalv().y > sel_y ) {
			hycov_log(LOG,"hy_log focus dir jj {}",tempCWindows[_i]);
  	      int dis_x = tempCWindows[_i]->m_vRealPosition.goalv().x - sel_x;
  	      int dis_y = tempCWindows[_i]->m_vRealPosition.goalv().y - sel_y;
  	      long long int tmp_distance = dis_x * dis_x + dis_y * dis_y; 
  	      if (tmp_distance < distance) {
			hycov_log(LOG,"hy_log focus dir kk {}",tempCWindows[_i]);
  	        distance = tmp_distance;
  	        tempFocusCWindows = tempCWindows[_i];
  	      }
  	    }
  	  }
  	  break;
  	case ShiftDirection::Left:
  	  for (int _i = 0; _i <= last; _i++) {
  	    if (tempCWindows[_i]->m_vRealPosition.goalv().x < sel_x ) {
  	      int dis_x = tempCWindows[_i]->m_vRealPosition.goalv().x - sel_x;
  	      int dis_y = tempCWindows[_i]->m_vRealPosition.goalv().y - sel_y;
  	      long long int tmp_distance = dis_x * dis_x + dis_y * dis_y; 
  	      if (tmp_distance < distance) {
  	        distance = tmp_distance;
  	        tempFocusCWindows = tempCWindows[_i];
  	      }
  	    }
  	  }
  	  break;
  	case ShiftDirection::Right:
  	  for (int _i = 0; _i <= last; _i++) {
  	    if (tempCWindows[_i]->m_vRealPosition.goalv().x > sel_x ) {
  	      int dis_x = tempCWindows[_i]->m_vRealPosition.goalv().x - sel_x;
  	      int dis_y = tempCWindows[_i]->m_vRealPosition.goalv().y - sel_y;
  	      long long int tmp_distance = dis_x * dis_x + dis_y * dis_y; 
  	      if (tmp_distance < distance) {
  	        distance = tmp_distance;
  	        tempFocusCWindows = tempCWindows[_i];
  	      }
  	    }
  	  }
  	  break;
  	}
  	return tempFocusCWindows;
}

void dispatch_focusdir(std::string arg)
{
	CWindow *pWindow;
	pWindow = direction_select(arg);
	if(pWindow)
		g_pCompositor->focusWindow(pWindow);
}

void dispatch_toggleoverview(std::string arg)
{
	if (g_GridLayout->isOverView)
	{
		dispatch_leaveoverview(arg);
		g_GridLayout->isOverView = false;
	}
	else
	{
		dispatch_enteroverview(arg);
		g_GridLayout->isOverView = true;
	}
}

void dispatch_enteroverview(std::string arg)
{ 
	//ali clients exit fullscreen status before enter overview
	CWindow *PFULLWINDOW;
	CWindow *ActiveWindow = g_pCompositor->m_pLastWindow;
	for (auto &w : g_pCompositor->m_vWorkspaces)
	{

		if (w.get()->m_bHasFullscreenWindow)
		{
			PFULLWINDOW = g_pCompositor->getFullscreenWindowOnWorkspace(w.get()->m_iID);
			g_pCompositor->setWindowFullscreen(PFULLWINDOW, false, FULLSCREEN_FULL);

			//let overview know it is a fullscreen before
			PFULLWINDOW->m_bIsFullscreen = true;
		}
	}
	//enter overview layout
	g_pLayoutManager->switchToLayout("grid");
	if(ActiveWindow){
		g_pCompositor->focusWindow(ActiveWindow); //restore the focus to before active window
	}

	return;
}

void dispatch_leaveoverview(std::string arg)
{ 
	std::string *configLayoutName = &HyprlandAPI::getConfigValue(PHANDLE, "general:layout")->strValue;

	if (!g_GridLayout->m_lGridNodesData.empty())
	{
		//move clients to it's original workspace 
		g_GridLayout->moveWindowToSourceWorkspace();
		//jump to target client's workspace
		g_GridLayout->changeToActivceSourceWorkspace();
	}

	for (auto &n : g_GridLayout->m_lGridNodesData)
	{	
		if (n.ovbk_pWindow_isFloating)
		{
			//make floating client restore it's floating status
			n.pWindow->m_bIsFloating = true;
			n.pWindow->updateDynamicRules();
			g_pLayoutManager->getCurrentLayout()->onWindowCreatedFloating(n.pWindow);

			// make floating client restore it's position and size
			n.pWindow->m_vRealSize = n.ovbk_size;
			n.pWindow->m_vRealPosition = n.ovbk_position;

			auto calcPos = n.ovbk_position;
			auto calcSize = n.ovbk_size;

			n.pWindow->m_vRealSize = calcSize;
			n.pWindow->m_vRealPosition = calcPos;

			g_pXWaylandManager->setWindowSize(n.pWindow, calcSize);

			continue;
		}
	}

	//exit overview layout,go back to old layout
	g_pLayoutManager->switchToLayout(*configLayoutName);

	for (auto &n : g_GridLayout->m_lGridNodesData)
	{
		//make all fullscrenn windwo restore it's status
		if (n.ovbk_pWindow_isFullscreen)
		{
			if (n.pWindow != g_pCompositor->m_pLastWindow && n.pWindow->m_iWorkspaceID == g_pCompositor->m_pLastWindow->m_iWorkspaceID)
			{
				continue;
			}
			auto FULLSCREENMODE = g_pCompositor->getWorkspaceByID(n.pWindow->m_iWorkspaceID)->m_efFullscreenMode;
			g_pCompositor->setWindowFullscreen(n.pWindow, true, FULLSCREENMODE);
		}
	}

	//clean overview layout node date
	g_GridLayout->m_lGridNodesData.clear();

	return;
}

void registerDispatchers()
{
	g_GridLayout->isOverView = false;
	HyprlandAPI::addDispatcher(PHANDLE, "hycov:enteroverview", dispatch_enteroverview);
	HyprlandAPI::addDispatcher(PHANDLE, "hycov:leaveoverview", dispatch_leaveoverview);
	HyprlandAPI::addDispatcher(PHANDLE, "hycov:toggleoverview", dispatch_toggleoverview);
	HyprlandAPI::addDispatcher(PHANDLE, "hycov:movefocus", dispatch_focusdir);

}
