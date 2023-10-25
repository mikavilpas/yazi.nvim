#include <optional>

#include <hyprland/src/Compositor.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>

#include "dispatchers.hpp"
#include "globals.hpp"

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
}
