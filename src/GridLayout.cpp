
#include <hyprland/src/Compositor.hpp>
#include "globals.hpp"
#include "GridLayout.hpp"

SGridNodeData *GridLayout::getNodeFromWindow(CWindow *pWindow)
{
    for (auto &nd : m_lGridNodesData)
    {
        if (nd.pWindow == pWindow)
            return &nd;
    }

    return nullptr;
}

int GridLayout::getNodesNumOnWorkspace(const int &ws)
{
    int no = 0;
    for (auto &n : m_lGridNodesData)
    {
        if (n.workspaceID == ws)
            no++;
    }

    return no;
}

void GridLayout::resizeNodeSizePos(SGridNodeData *node, int x, int y, int width, int height)
{
    node->size = Vector2D(width, height);
    node->position = Vector2D(x, y);
    applyNodeDataToWindow(node);
}

void GridLayout::moveWindowToWorkspaceSilent(CWindow *pWindow, const int &workspaceID)
{
    std::string workspaceName = "";

    if (!pWindow)
        return;

    g_pHyprRenderer->damageWindow(pWindow);

    auto pWorkspace = g_pCompositor->getWorkspaceByID(workspaceID);
    const auto OLDMIDDLE = pWindow->middle();

    if (pWorkspace)
    {
        g_pCompositor->moveWindowToWorkspaceSafe(pWindow, pWorkspace);
    }
    else
    {
        pWorkspace = g_pCompositor->createNewWorkspace(workspaceID, pWindow->m_iMonitorID, workspaceName);
        g_pCompositor->moveWindowToWorkspaceSafe(pWindow, pWorkspace);
    }

    if (const auto PATCOORDS = g_pCompositor->vectorToWindowIdeal(OLDMIDDLE); PATCOORDS && PATCOORDS != pWindow)
        g_pCompositor->focusWindow(PATCOORDS);
    else
        g_pInputManager->refocus();
}

void GridLayout::onWindowCreatedTiling(CWindow *pWindow, eDirection direction)
{
    const auto PMONITOR = g_pCompositor->getMonitorFromID(pWindow->m_iMonitorID); 

    const auto PNODE = &m_lGridNodesData.emplace_back(); // make a new node in list back

    const auto PACTIVEWORKSPACE = g_pCompositor->getWorkspaceByID(PMONITOR->activeWorkspace); 

    const auto PWINDOWORIWORKSPACE = g_pCompositor->getWorkspaceByID(pWindow->m_iWorkspaceID);

    PNODE->workspaceID = pWindow->m_iWorkspaceID; // encapsulate window objects as node objects to bind more properties
    PNODE->pWindow = pWindow;
    PNODE->workspaceName = PWINDOWORIWORKSPACE->m_szName;
    
    //record the window stats which are used by restore
    PNODE->ovbk_pWindow_workspaceID = pWindow->m_iWorkspaceID;
    PNODE->ovbk_pWindow_m_efFullscreenMode = PWINDOWORIWORKSPACE->m_efFullscreenMode;
    PNODE->ovbk_position = pWindow->m_vRealPosition.goalv();
    PNODE->ovbk_size = pWindow->m_vRealSize.goalv();
    PNODE->ovbk_pWindow_isFloating = pWindow->m_bIsFloating;
    PNODE->ovbk_pWindow_isFullscreen = pWindow->m_bIsFullscreen;
    PNODE->ovbk_pWindow_workspaceName = PWINDOWORIWORKSPACE->m_szName;


    if (isFirstTile) //only when original layout swith to overview do it once
    {
        if (PWINDOWORIWORKSPACE->m_iID != PACTIVEWORKSPACE->m_iID || PWINDOWORIWORKSPACE->m_szName != PACTIVEWORKSPACE->m_szName)
        {
            //change all client workspace to active worksapce 
            PNODE->workspaceID = pWindow->m_iWorkspaceID = PACTIVEWORKSPACE->m_iID;
            PNODE->workspaceName = PACTIVEWORKSPACE->m_szName;
        }

        if (pWindow->m_bIsFullscreen)
        {   
            // clean fullscreen status
            pWindow->m_bIsFullscreen = false;
        }

        if (pWindow->m_bIsFloating)
        {
            //clean floating status
            pWindow->m_bIsFloating = false;
            pWindow->updateDynamicRules();
        }

        isFirstTile = false;
    }

    recalculateMonitor(pWindow->m_iMonitorID);
}

void GridLayout::onWindowRemovedTiling(CWindow *pWindow)
{
    const auto PNODE = getNodeFromWindow(pWindow);
    SGridNodeData lastNode;

    if (!PNODE)
        return;
    m_lGridNodesData.remove(*PNODE);

    if(m_lGridNodesData.empty()){
        return;
    }
    recalculateMonitor(pWindow->m_iMonitorID);

    lastNode = m_lGridNodesData.back();

    g_pCompositor->focusWindow(lastNode.pWindow);
}

bool GridLayout::isWindowTiled(CWindow *pWindow)
{
    return false;
}

void GridLayout::calculateWorkspace(const int &ws)
{
    const auto PWORKSPACE = g_pCompositor->getWorkspaceByID(ws); 
    SGridNodeData *tempNodes[100];
    SGridNodeData *NODE;
    int i, n = 0;
    int cx, cy;
    int dx, cw, ch;;
    int cols, rows, overcols,NODECOUNT;

    if (!PWORKSPACE)
        return;

    NODECOUNT = getNodesNumOnWorkspace(PWORKSPACE->m_iID);          
    const auto PMONITOR = g_pCompositor->getMonitorFromID(PWORKSPACE->m_iMonitorID); 

    if (NODECOUNT == 0) 
        return;

    static const auto *PBORDERSIZE = &HyprlandAPI::getConfigValue(PHANDLE, "general:border_size")->intValue;
    static const auto *GAPPO = &HyprlandAPI::getConfigValue(PHANDLE, "plugin:hycov:overview_gappo")->intValue;
    static const auto *GAPPI = &HyprlandAPI::getConfigValue(PHANDLE, "plugin:hycov:overview_gappi")->intValue;

    int m_x = PMONITOR->vecPosition.x;
    int m_y = PMONITOR->vecPosition.y;
    int w_x = PMONITOR->vecPosition.x;
    int w_y = PMONITOR->vecReservedTopLeft.y;
    int m_width = PMONITOR->vecSize.x;
    int m_height = PMONITOR->vecSize.y;
    int w_width = PMONITOR->vecSize.x;
    int w_height = PMONITOR->vecSize.y - PMONITOR->vecReservedTopLeft.y;

    for (auto &node : m_lGridNodesData)
    {
        if (node.workspaceID == ws)
        {
            tempNodes[n] = &node;
            n++;
        }
    }
    tempNodes[n] = NULL;

    if (NODECOUNT == 0)
        return;
    if (NODECOUNT == 1)
    {
        NODE = tempNodes[0];
        cw = (w_width - 2 * (*GAPPO)) * 0.7;
        ch = (w_height - 2 * (*GAPPO)) * 0.8;
        resizeNodeSizePos(NODE, w_x + (int)((m_width - cw) / 2), w_y + (int)((w_height - ch) / 2),
                          cw - 2 * (*PBORDERSIZE), ch - 2 * (*PBORDERSIZE));
        return;
    }

    if (NODECOUNT == 2)
    {
        NODE = tempNodes[0];
        cw = (w_width - 2 * (*GAPPO) - (*GAPPI)) / 2;
        ch = (w_height - 2 * (*GAPPO)) * 0.65;
        resizeNodeSizePos(NODE, m_x + cw + (*GAPPO) + (*GAPPI), m_y + (m_height - ch) / 2 + (*GAPPO),
                          cw - 2 * (*PBORDERSIZE), ch - 2 * (*PBORDERSIZE));
        resizeNodeSizePos(tempNodes[1], m_x + (*GAPPO), m_y + (m_height - ch) / 2 + (*GAPPO),
                          cw - 2 * (*PBORDERSIZE), ch - 2 * (*PBORDERSIZE));
        return;
    }

    //Calculate the integer part of the square root of the number of nodes
    for (cols = 0; cols <= NODECOUNT / 2; cols++)
        if (cols * cols >= NODECOUNT)
            break;
    //The number of rows and columns multiplied by the number of nodes
    // must be greater than the number of nodes to fit all the Windows
    rows = (cols && (cols - 1) * cols >= NODECOUNT) ? cols - 1 : cols;

    //Calculate the width and height of the layout area based on 
    //the number of rows and columns
    ch = (int)((w_height - 2 * (*GAPPO) - (rows - 1) * (*GAPPI)) / rows);
    cw = (int)((w_width - 2 * (*GAPPO) - (cols - 1) * (*GAPPI)) / cols);

    //If the nodes do not exactly fill all rows, 
    //the number of Windows in the unfilled rows is
    overcols = NODECOUNT % cols;

    if (overcols)
        dx = (int)((w_width - overcols * cw - (overcols - 1) * (*GAPPI)) / 2) - (*GAPPO);
    for (i = 0, NODE = tempNodes[0]; NODE; NODE = tempNodes[i + 1], i++)
    {
        cx = w_x + (i % cols) * (cw + (*GAPPI));
        cy = w_y + (int)(i / cols) * (ch + (*GAPPI));
        if (overcols && i >= (NODECOUNT-overcols))
        {
            cx += dx;
        }
        resizeNodeSizePos(NODE, cx + (*GAPPO), cy + (*GAPPO), cw - 2 * (*PBORDERSIZE), ch - 2 * (*PBORDERSIZE));
    }
}

void GridLayout::recalculateMonitor(const int &monid)
{
    const auto PMONITOR = g_pCompositor->getMonitorFromID(monid);                       // 根据monitor id获取monitor对象
    const auto PWORKSPACE = g_pCompositor->getWorkspaceByID(PMONITOR->activeWorkspace); // 获取当前workspace对象
    if (!PWORKSPACE)
        return;

    g_pHyprRenderer->damageMonitor(PMONITOR); // Use local rendering

    calculateWorkspace(PWORKSPACE->m_iID); // calculate windwo's size and position
}

// set window's size and position
void GridLayout::applyNodeDataToWindow(SGridNodeData *pNode)
{ 

    const auto PWINDOW = pNode->pWindow;

    PWINDOW->m_vSize = pNode->size;
    PWINDOW->m_vPosition = pNode->position;

    auto calcPos = PWINDOW->m_vPosition;
    auto calcSize = PWINDOW->m_vSize;

    PWINDOW->m_vRealSize = calcSize;
    PWINDOW->m_vRealPosition = calcPos;
    g_pXWaylandManager->setWindowSize(PWINDOW, calcSize);

    PWINDOW->updateWindowDecos();
    // g_pCompositor->focusWindow(PWINDOW);
}

void GridLayout::recalculateWindow(CWindow *pWindow)
{
    ; // empty
}


void GridLayout::resizeActiveWindow(const Vector2D &pixResize, eRectCorner corner, CWindow *pWindow)
{
    ; // empty
}

void GridLayout::fullscreenRequestForWindow(CWindow *pWindow, eFullscreenMode mode, bool on)
{
    ; // empty
}

std::any GridLayout::layoutMessage(SLayoutMessageHeader header, std::string content)
{
    return "";
}

SWindowRenderLayoutHints GridLayout::requestRenderHints(CWindow *pWindow)
{
    return {};
}

void GridLayout::switchWindows(CWindow *pWindowA, CWindow *pWindowB)
{
    ; // empty
}

void GridLayout::alterSplitRatio(CWindow *pWindow, float delta, bool exact)
{
    ; // empty
}

std::string GridLayout::getLayoutName()
{
    return "grid";
}

void GridLayout::replaceWindowDataWith(CWindow *from, CWindow *to)
{
    ; // empty
}

void GridLayout::moveWindowTo(CWindow *, const std::string &dir)
{
    ; // empty
}

void GridLayout::changeToActivceSourceWorkspace()
{
    CWindow *PWINDOW = nullptr;
    SGridNodeData *Node;
    PWINDOW = g_pCompositor->m_pLastWindow;
    const auto PMONITOR = g_pCompositor->getMonitorFromID(PWINDOW->m_iMonitorID); 
    Node = getNodeFromWindow(PWINDOW);
    const auto PWORKSPACE = g_pCompositor->getWorkspaceByID(Node->ovbk_pWindow_workspaceID); 
    PMONITOR->activeWorkspace = Node->ovbk_pWindow_workspaceID;
    PMONITOR->changeWorkspace(PWORKSPACE);
    g_pEventManager->postEvent(SHyprIPCEvent{"workspace", PWORKSPACE->m_szName});
    EMIT_HOOK_EVENT("workspace", PWORKSPACE);
    // g_pCompositor->focusWindow(PWINDOW);
}

void GridLayout::moveWindowToSourceWorkspace()
{
    CWorkspace *pWorkspace;
    
    for (auto &nd : m_lGridNodesData)
    {
        if (nd.pWindow && (nd.pWindow->m_iWorkspaceID != nd.ovbk_pWindow_workspaceID || nd.workspaceName != nd.ovbk_pWindow_workspaceName ))
        {

            pWorkspace = g_pCompositor->getWorkspaceByID(nd.ovbk_pWindow_workspaceID);
            if (!pWorkspace)
                pWorkspace = g_pCompositor->createNewWorkspace(nd.ovbk_pWindow_workspaceID, nd.pWindow->m_iMonitorID,nd.ovbk_pWindow_workspaceName);

            nd.workspaceID = nd.pWindow->m_iWorkspaceID = nd.ovbk_pWindow_workspaceID;
            nd.workspaceName = nd.ovbk_pWindow_workspaceName;
            nd.pWindow->m_vPosition = nd.ovbk_position;
            nd.pWindow->m_vSize = nd.ovbk_size;
            g_pHyprRenderer->damageWindow(nd.pWindow);
        }
    }
}

void GridLayout::onEnable()
{
    for (auto &w : g_pCompositor->m_vWindows)
    {
        if (w->isHidden() || !w->m_bIsMapped || w->m_bFadingOut)
            continue;
        isFirstTile = true;
        onWindowCreatedTiling(w.get());
    }
}

void GridLayout::onDisable()
{
    //  m_lGridNodesData.clear();
}