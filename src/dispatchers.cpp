#include <optional>

#include <hyprland/src/Compositor.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>

#include "dispatchers.hpp"
#include "globals.hpp"


void dispatch_toggleoverview(std::string arg) {
	if(g_GridLayout->isOverView){
		dispatch_leaveoverview(arg);
		g_GridLayout->isOverView = false;
	}else{
		dispatch_enteroverview(arg);
		g_GridLayout->isOverView = true;
	}
}

void dispatch_enteroverview(std::string arg) { //进入overview
    CWorkspace *PWORKSPACE;
	CWindow *PFULLWINDOW;
	for (auto& w : g_pCompositor->m_vWindows) {
        if (w->isHidden() || !w->m_bIsMapped || w->m_bFadingOut)
            continue;
		PWORKSPACE = g_pCompositor->getWorkspaceByID(w->m_iWorkspaceID);
		if (PWORKSPACE->m_bHasFullscreenWindow) {
    	    PFULLWINDOW = g_pCompositor->getFullscreenWindowOnWorkspace(PWORKSPACE->m_iID);
    	    g_pCompositor->setWindowFullscreen(PFULLWINDOW, false, FULLSCREEN_FULL);
    	}
	}
	g_pLayoutManager->switchToLayout("grid");
	return;
}

void dispatch_leaveoverview(std::string arg) { //离开overview
	std::string *configLayoutName = &HyprlandAPI::getConfigValue(PHANDLE, "general:layout")->strValue;
	if(!g_GridLayout->m_lGridNodesData.empty()){
		g_GridLayout->moveWindowToSourceWorkspace();
		g_GridLayout->changeToActivceSourceWorkspace();
	}
	g_pLayoutManager->switchToLayout(*configLayoutName);
	return;
}

void registerDispatchers() {
	g_GridLayout->isOverView = false;
	HyprlandAPI::addDispatcher(PHANDLE, "hycov:enteroverview", dispatch_enteroverview);
	HyprlandAPI::addDispatcher(PHANDLE, "hycov:leaveoverview", dispatch_leaveoverview);
	HyprlandAPI::addDispatcher(PHANDLE, "hycov:toggleoverview", dispatch_toggleoverview);

}
