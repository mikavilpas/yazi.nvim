
#include <hyprland/src/Compositor.hpp>
#include "globals.hpp"
#include "GridLayout.hpp"

//通过win对象获取node对象
SGridNodeData* GridLayout::getNodeFromWindow(CWindow* pWindow) {
    for (auto& nd : m_lGridNodesData) {
        if (nd.pWindow == pWindow)
            return &nd;
    }

    return nullptr;
}

int GridLayout::getNodesNumOnWorkspace(const int& ws) {
    int no = 0;
    for (auto& n : m_lGridNodesData) {
        if (n.workspaceID == ws)
            no++;
    }

    return no;
}

void GridLayout::resizeNodeSizePos(SGridNodeData *node, int x,int y,int width,int height){
    node->size =Vector2D(width, height);
    node->position = Vector2D(x, y);
    applyNodeDataToWindow(node);
}

void GridLayout::moveWindowToWorkspaceSilent(CWindow *pWindow,const int& workspaceID) {
    std::string workspaceName = "";

    if (!pWindow)
        return;

    g_pHyprRenderer->damageWindow(pWindow);

    auto       pWorkspace = g_pCompositor->getWorkspaceByID(workspaceID);
    const auto OLDMIDDLE  = pWindow->middle();

    if (pWorkspace) {
        g_pCompositor->moveWindowToWorkspaceSafe(pWindow, pWorkspace);
    } else {
        pWorkspace = g_pCompositor->createNewWorkspace(workspaceID, pWindow->m_iMonitorID, workspaceName);
        g_pCompositor->moveWindowToWorkspaceSafe(pWindow, pWorkspace);
    }

    if (const auto PATCOORDS = g_pCompositor->vectorToWindowIdeal(OLDMIDDLE); PATCOORDS && PATCOORDS != pWindow)
        g_pCompositor->focusWindow(PATCOORDS);
    else
        g_pInputManager->refocus();
}

void GridLayout::onWindowCreatedTiling(CWindow* pWindow, eDirection direction) {
        const auto         PMONITOR = g_pCompositor->getMonitorFromID(pWindow->m_iMonitorID); //从窗口中获取窗口当前所在的显示器id

        const auto PNODE = &m_lGridNodesData.emplace_back();  //根据配置在node容器前面或者后面建立新节点

        const auto PACTIVEWORKSPACE = g_pCompositor->getWorkspaceByID(PMONITOR->activeWorkspace); //获取当前活动workspace对象
  
        const auto PWORKSPACE = g_pCompositor->getWorkspaceByID(pWindow->m_iWorkspaceID); //获取当前活动workspace对象

        PNODE->workspaceID = pWindow->m_iWorkspaceID;  //将window封装成node,方便添加自定义绑定到window的字段
        PNODE->pWindow     = pWindow;
        // PNODE->ovbk_pWindow_isFloating = pWindow->m_bIsFloating;
        // PNODE->ovbk_pWindow_isFullscreen = pWindow->m_bIsFullscreen;
        int workspaceBack = pWindow->m_iWorkspaceID;
        Vector2D posBack = pWindow->m_vPosition;
        Vector2D sizeBack = pWindow->m_vSize;
        if(isFirstTile){
            if(pWindow->m_iWorkspaceID != PACTIVEWORKSPACE->m_iID){
                // moveWindowToWorkspaceSilent(PNODE->pWindow,PACTIVEWORKSPACE->m_iID);
                PNODE->workspaceID = pWindow->m_iWorkspaceID = PACTIVEWORKSPACE->m_iID;
            }
            isFirstTile = false;
        }
        PNODE->ovbk_pWindow_workspaceID = workspaceBack;
        PNODE->ovbk_position = posBack;
        PNODE->ovbk_size = sizeBack;


    if (PWORKSPACE->m_bHasFullscreenWindow) {
        const auto PFULLWINDOW = g_pCompositor->getFullscreenWindowOnWorkspace(PWORKSPACE->m_iID);
        g_pCompositor->setWindowFullscreen(PFULLWINDOW, false, FULLSCREEN_FULL);
    }
    // 显示器重新计算布局
    recalculateMonitor(pWindow->m_iMonitorID);

}

void GridLayout::onWindowRemovedTiling(CWindow* pWindow) {
    const auto PNODE = getNodeFromWindow(pWindow);
    SGridNodeData lastNode;

    if (!PNODE)
        return;
    m_lGridNodesData.remove(*PNODE);    

    recalculateMonitor(pWindow->m_iMonitorID);

    lastNode = m_lGridNodesData.back();

    g_pCompositor->focusWindow(lastNode.pWindow);
}

bool GridLayout::isWindowTiled(CWindow* pWindow) {
    return false;
}

void GridLayout::calculateWorkspace(const int& ws) {
    const auto PWORKSPACE = g_pCompositor->getWorkspaceByID(ws);  //通过工作区id获取工作区对象
    SGridNodeData *tempNodes[100];
    SGridNodeData *NODE;
    unsigned int i, n=0;
    unsigned int cx, cy, cw, ch;
    unsigned int dx;
    unsigned int cols, rows, overcols;

    if (!PWORKSPACE)
        return;

    const auto  NODECOUNT = getNodesNumOnWorkspace(PWORKSPACE->m_iID);  //获取工作区中的平铺节点  
    const auto  PMONITOR = g_pCompositor->getMonitorFromID(PWORKSPACE->m_iMonitorID); //获取工作区对应的显示器对象


    if (NODECOUNT == 0)  //没有平铺节点,直接返回
        return;


    static const auto* PBORDERSIZE = &HyprlandAPI::getConfigValue(PHANDLE, "general:border_size")->intValue;
    static const auto* GAPPO = &HyprlandAPI::getConfigValue(PHANDLE, "plugin:hycov:overview_gappo")->intValue;
    static const auto* GAPPI = &HyprlandAPI::getConfigValue(PHANDLE, "plugin:hycov:overview_gappi")->intValue;



    auto m_x = PMONITOR->vecPosition.x;
    auto m_y = PMONITOR->vecPosition.y;
    auto w_x = PMONITOR->vecReservedTopLeft.x;
    auto w_y = PMONITOR->vecReservedTopLeft.y;
    auto m_width = PMONITOR->vecSize.x;
    auto m_height = PMONITOR->vecSize.y;
    auto w_width = PMONITOR->vecSize.x;
    auto w_height = PMONITOR->vecSize.y - PMONITOR->vecReservedTopLeft.y;

    for (auto& node : m_lGridNodesData) {
        if (node.workspaceID == ws){
            tempNodes[n] = &node;
            n++;
        }
    }
    tempNodes[n] = NULL;

    if (NODECOUNT == 0)
      return;
    if (NODECOUNT == 1) {
      NODE = tempNodes[0];
      cw = (w_width - 2 * (*GAPPO)) * 0.7;
      ch = (w_height- 2 * (*GAPPO)) * 0.8;
      resizeNodeSizePos(NODE, w_x  + (int)((m_width  - cw) / 2), w_y + (int)((w_height- ch) / 2),
             cw - 2 * (*PBORDERSIZE), ch - 2 * (*PBORDERSIZE));
      return;
    }
    if (NODECOUNT == 2) {
      NODE = tempNodes[0];
      cw = (w_width - 2 * (*GAPPO) - (*GAPPI)) / 2;
      ch = (w_height- 2 * (*GAPPO)) * 0.65;
      resizeNodeSizePos(NODE, m_x  + cw + (*GAPPO) + (*GAPPI), m_y + (m_height - ch) / 2 + (*GAPPO),
             cw - 2 * (*PBORDERSIZE), ch - 2 * (*PBORDERSIZE));
      resizeNodeSizePos(tempNodes[1], m_x  + (*GAPPO), m_y + (m_height - ch) / 2 + (*GAPPO),
             cw - 2 * (*PBORDERSIZE), ch - 2 * (*PBORDERSIZE));
    
      return;
    }
    
    for (cols = 0; cols <= NODECOUNT / 2; cols++)
      if (cols * cols >= NODECOUNT)
        break;
    rows = (cols && (cols - 1) * cols >= NODECOUNT) ? cols - 1 : cols;
    ch = (w_height- 2 * (*GAPPO) - (rows - 1) * (*GAPPI)) / rows;
    cw = (w_width - 2 * (*GAPPO) - (cols - 1) * (*GAPPI)) / cols;
    
    overcols = NODECOUNT % cols;
    if (overcols)
      dx = (w_width - overcols * cw - (overcols - 1) * (*GAPPI)) / 2 - (*GAPPO);
    for (i = 0, NODE = tempNodes[0]; NODE; NODE = tempNodes[i+1], i++) {
      cx = w_x  + (i % cols) * (cw + (*GAPPI));
      cy = w_y + (i / cols) * (ch + (*GAPPI));
      if (overcols && i >= NODECOUNT - overcols) {
        cx += dx;
      }
      resizeNodeSizePos(NODE, cx + (*GAPPO), cy + (*GAPPO), cw - 2 * (*PBORDERSIZE), ch - 2 * (*PBORDERSIZE));
    }
}

void GridLayout::recalculateMonitor(const int& monid) {
    const auto PMONITOR   = g_pCompositor->getMonitorFromID(monid);  //根据monitor id获取monitor对象
    const auto PWORKSPACE = g_pCompositor->getWorkspaceByID(PMONITOR->activeWorkspace); //获取当前workspace对象
    if (!PWORKSPACE)   
        return;

    g_pHyprRenderer->damageMonitor(PMONITOR);  //不知道这个渲染动作是干嘛的,好像是要重新渲染的意思

    // 重新计算工作区布局
    calculateWorkspace(PWORKSPACE->m_iID);  //计算平铺当前的工作区的可平铺窗口
}

void GridLayout::applyNodeDataToWindow(SGridNodeData* pNode) { //将节点的数据应用到显示(大小位置,border等)

    const auto PWINDOW = pNode->pWindow;

    PWINDOW->m_vSize     = pNode->size;
    PWINDOW->m_vPosition = pNode->position;

    auto calcPos  = PWINDOW->m_vPosition;
    auto calcSize = PWINDOW->m_vSize;



    PWINDOW->m_vRealSize     = calcSize;
    PWINDOW->m_vRealPosition = calcPos;
    g_pXWaylandManager->setWindowSize(PWINDOW, calcSize);


    PWINDOW->updateWindowDecos();
    g_pCompositor->focusWindow(PWINDOW);
}

void GridLayout::recalculateWindow(CWindow* pWindow) {
    ; // empty
}

void GridLayout::resizeActiveWindow(const Vector2D& pixResize, eRectCorner corner, CWindow* pWindow) {
    ; // empty
}

void GridLayout::fullscreenRequestForWindow(CWindow* pWindow, eFullscreenMode mode, bool on) {
    ; // empty
}

std::any GridLayout::layoutMessage(SLayoutMessageHeader header, std::string content) {
    return "";
}

SWindowRenderLayoutHints GridLayout::requestRenderHints(CWindow* pWindow) {
    return {};
}

void GridLayout::switchWindows(CWindow* pWindowA, CWindow* pWindowB) {
    ; // empty
}

void GridLayout::alterSplitRatio(CWindow* pWindow, float delta, bool exact) {
    ; // empty
}

std::string GridLayout::getLayoutName() {
    return "grid";
}

void GridLayout::replaceWindowDataWith(CWindow* from, CWindow* to) {
    ; // empty
}

void GridLayout::moveWindowTo(CWindow *, const std::string& dir) {
    ; // empty
}

void GridLayout::changeToActivceSourceWorkspace(){
    CWindow* PWINDOW = nullptr;
    SGridNodeData *Node;
    PWINDOW = g_pCompositor->m_pLastWindow;
    const auto         PMONITOR = g_pCompositor->getMonitorFromID(PWINDOW->m_iMonitorID); //从窗口中获取窗口当前所在的显示器id
    const auto PNODE = getNodeFromWindow(PWINDOW);
    Node = getNodeFromWindow(PWINDOW);
    const auto PWORKSPACE = g_pCompositor->getWorkspaceByID(Node->ovbk_pWindow_workspaceID); //获取当前workspace对象
    PMONITOR->activeWorkspace = Node->ovbk_pWindow_workspaceID;
    PMONITOR->changeWorkspace(PWORKSPACE);
    g_pCompositor->focusWindow(PWINDOW);

}


void GridLayout::moveWindowToSourceWorkspace(){
    std::string workspaceName = "";
    CWorkspace       *pWorkspace;
    for (auto& nd : m_lGridNodesData) {
		if(nd.pWindow && nd.pWindow->m_iWorkspaceID != nd.ovbk_pWindow_workspaceID){

            pWorkspace = g_pCompositor->getWorkspaceByID(nd.ovbk_pWindow_workspaceID);

            if (!pWorkspace) 
                pWorkspace = g_pCompositor->createNewWorkspace(nd.ovbk_pWindow_workspaceID, nd.pWindow->m_iMonitorID, workspaceName);

            nd.workspaceID = nd.pWindow->m_iWorkspaceID = nd.ovbk_pWindow_workspaceID;
            nd.pWindow->m_vPosition = nd.ovbk_position;
            nd.pWindow-> m_vSize = nd.ovbk_size; 
            g_pHyprRenderer->damageWindow(nd.pWindow);	
		}
    }    
    

}

void GridLayout::onEnable() {
    for (auto& w : g_pCompositor->m_vWindows) {
        if (w->isHidden() || !w->m_bIsMapped || w->m_bFadingOut)
            continue;
        isFirstTile = true;
        onWindowCreatedTiling(w.get());
    }
}

void GridLayout::onDisable() {
  
     m_lGridNodesData.clear();
}