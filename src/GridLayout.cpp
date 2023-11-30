
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

void GridLayout::onWindowCreatedTiling(CWindow *pWindow, eDirection direction)
{
    const auto pMonitor = g_pCompositor->getMonitorFromID(pWindow->m_iMonitorID); 

    const auto pNode = &m_lGridNodesData.emplace_back(); // make a new node in list back

    const auto pActiveWorkspace = g_pCompositor->getWorkspaceByID(pMonitor->activeWorkspace); 

    const auto pWindowOriWorkspace = g_pCompositor->getWorkspaceByID(pWindow->m_iWorkspaceID);

    pNode->workspaceID = pWindow->m_iWorkspaceID; // encapsulate window objects as node objects to bind more properties
    pNode->pWindow = pWindow;
    pNode->workspaceName = pWindowOriWorkspace->m_szName;
    
    //record the window stats which are used by restore
    pNode->ovbk_windowWorkspaceId = pWindow->m_iWorkspaceID;
    pNode->ovbk_windowFullscreenMode  = pWindowOriWorkspace->m_efFullscreenMode;
    pNode->ovbk_position = pWindow->m_vRealPosition.goalv();
    pNode->ovbk_size = pWindow->m_vRealSize.goalv();
    pNode->ovbk_windowIsFloating = pWindow->m_bIsFloating;
    pNode->ovbk_windowIsFullscreen = pWindow->m_bIsFullscreen;
    pNode->ovbk_windowWorkspaceName = pWindowOriWorkspace->m_szName;

    //change all client workspace to active worksapce 
    if (pWindowOriWorkspace->m_iID != pActiveWorkspace->m_iID || pWindowOriWorkspace->m_szName != pActiveWorkspace->m_szName)
    {
        pNode->workspaceID = pWindow->m_iWorkspaceID = pActiveWorkspace->m_iID;
        pNode->workspaceName = pActiveWorkspace->m_szName;
    }

    // clean fullscreen status
    if (pWindow->m_bIsFullscreen)
    {   
        pWindow->m_bIsFullscreen = false;
    }

    //clean floating status
    if (pWindow->m_bIsFloating)
    {        pWindow->m_bIsFloating = false;
        pWindow->updateDynamicRules();
    }

    recalculateMonitor(pWindow->m_iMonitorID);
}

void GridLayout::onWindowRemovedTiling(CWindow *pWindow)
{
    const auto pNode = getNodeFromWindow(pWindow);
    SGridNodeData lastNode;

    if (!pNode)
        return;
    m_lGridNodesData.remove(*pNode);

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
    const auto pWorksapce = g_pCompositor->getWorkspaceByID(ws); 
    SGridNodeData *pTempNodes[100];
    SGridNodeData *pNode;
    int i, n = 0;
    int cx, cy;
    int dx, cw, ch;;
    int cols, rows, overcols,NODECOUNT;

    if (!pWorksapce)
        return;

    NODECOUNT = getNodesNumOnWorkspace(pWorksapce->m_iID);          
    const auto pMonitor = g_pCompositor->getMonitorFromID(pWorksapce->m_iMonitorID); 

    if (NODECOUNT == 0) 
        return;

    static const auto *PBORDERSIZE = &HyprlandAPI::getConfigValue(PHANDLE, "general:border_size")->intValue;
    static const auto *GAPPO = &HyprlandAPI::getConfigValue(PHANDLE, "plugin:hycov:overview_gappo")->intValue;
    static const auto *GAPPI = &HyprlandAPI::getConfigValue(PHANDLE, "plugin:hycov:overview_gappi")->intValue;

    /*
    m is region that is moniotr,
    w is region that is monitor but don not contain bar  
    */
    int m_x = pMonitor->vecPosition.x;
    int m_y = pMonitor->vecPosition.y;
    int w_x = pMonitor->vecPosition.x;
    int w_y = pMonitor->vecReservedTopLeft.y;
    int m_width = pMonitor->vecSize.x;
    int m_height = pMonitor->vecSize.y;
    int w_width = pMonitor->vecSize.x;
    int w_height = pMonitor->vecSize.y - pMonitor->vecReservedTopLeft.y;

    for (auto &node : m_lGridNodesData)
    {
        if (node.workspaceID == ws)
        {
            pTempNodes[n] = &node;
            n++;
        }
    }

    pTempNodes[n] = NULL;

    if (NODECOUNT == 0)
        return;

    // one client arrange
    if (NODECOUNT == 1)
    {
        pNode = pTempNodes[0];
        cw = (w_width - 2 * (*GAPPO)) * 0.7;
        ch = (w_height - 2 * (*GAPPO)) * 0.8;
        resizeNodeSizePos(pNode, w_x + (int)((m_width - cw) / 2), w_y + (int)((w_height - ch) / 2),
                          cw - 2 * (*PBORDERSIZE), ch - 2 * (*PBORDERSIZE));
        return;
    }

    // two client arrange
    if (NODECOUNT == 2)
    {
        pNode = pTempNodes[0];
        cw = (w_width - 2 * (*GAPPO) - (*GAPPI)) / 2;
        ch = (w_height - 2 * (*GAPPO)) * 0.65;
        resizeNodeSizePos(pNode, m_x + cw + (*GAPPO) + (*GAPPI), m_y + (m_height - ch) / 2 + (*GAPPO),
                          cw - 2 * (*PBORDERSIZE), ch - 2 * (*PBORDERSIZE));
        resizeNodeSizePos(pTempNodes[1], m_x + (*GAPPO), m_y + (m_height - ch) / 2 + (*GAPPO),
                          cw - 2 * (*PBORDERSIZE), ch - 2 * (*PBORDERSIZE));
        return;
    }

    //more than two client arrange

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
    for (i = 0, pNode = pTempNodes[0]; pNode; pNode = pTempNodes[i + 1], i++)
    {
        cx = w_x + (i % cols) * (cw + (*GAPPI));
        cy = w_y + (int)(i / cols) * (ch + (*GAPPI));
        if (overcols && i >= (NODECOUNT-overcols))
        {
            cx += dx;
        }
        resizeNodeSizePos(pNode, cx + (*GAPPO), cy + (*GAPPO), cw - 2 * (*PBORDERSIZE), ch - 2 * (*PBORDERSIZE));
    }
}

void GridLayout::recalculateMonitor(const int &monid)
{
    const auto pMonitor = g_pCompositor->getMonitorFromID(monid);                       // 根据monitor id获取monitor对象
    const auto pWorksapce = g_pCompositor->getWorkspaceByID(pMonitor->activeWorkspace); // 获取当前workspace对象
    if (!pWorksapce)
        return;

    g_pHyprRenderer->damageMonitor(pMonitor); // Use local rendering

    calculateWorkspace(pWorksapce->m_iID); // calculate windwo's size and position
}

// set window's size and position
void GridLayout::applyNodeDataToWindow(SGridNodeData *pNode)
{ 

    const auto pWindow = pNode->pWindow;

    pWindow->m_vSize = pNode->size;
    pWindow->m_vPosition = pNode->position;

    auto calcPos = pWindow->m_vPosition;
    auto calcSize = pWindow->m_vSize;

    pWindow->m_vRealSize = calcSize;
    pWindow->m_vRealPosition = calcPos;
    g_pXWaylandManager->setWindowSize(pWindow, calcSize);

    pWindow->updateWindowDecos();
    // g_pCompositor->focusWindow(pWindow);
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
    CWindow *pWindow = nullptr;
    SGridNodeData *pNode;
    CWorkspace *pWorksapce;
    hycov_log(LOG,"changeToActivceSourceWorkspace");
    pWindow = g_pCompositor->m_pLastWindow;
    const auto pMonitor = g_pCompositor->getMonitorFromID(pWindow->m_iMonitorID); 
    pNode = getNodeFromWindow(pWindow);
    if(pNode) {
        pWorksapce = g_pCompositor->getWorkspaceByID(pNode->ovbk_windowWorkspaceId); 
        // pMonitor->activeWorkspace = pNode->ovbk_windowWorkspaceId;
    } else {
        pWorksapce = g_pCompositor->getWorkspaceByID(pWindow->m_iWorkspaceID); 
        // pMonitor->activeWorkspace = pWindow->m_iWorkspaceID;        
    }
    pMonitor->changeWorkspace(pWorksapce);
    hycov_log(LOG,"changeToWorkspace:{}",pWorksapce->m_iID);
    g_pEventManager->postEvent(SHyprIPCEvent{"workspace", pWorksapce->m_szName});
    EMIT_HOOK_EVENT("workspace", pWorksapce);
    // g_pCompositor->focusWindow(pWindow);
}

void GridLayout::moveWindowToSourceWorkspace()
{
    CWorkspace *pWorkspace;
    
    hycov_log(LOG,"moveWindowToSourceWorkspace");

    for (auto &nd : m_lGridNodesData)
    {
        if (nd.pWindow && (nd.pWindow->m_iWorkspaceID != nd.ovbk_windowWorkspaceId || nd.workspaceName != nd.ovbk_windowWorkspaceName ))
        {
            pWorkspace = g_pCompositor->getWorkspaceByID(nd.ovbk_windowWorkspaceId);
            if (!pWorkspace){
                hycov_log(LOG,"source workspace no exist");
                pWorkspace = g_pCompositor->createNewWorkspace(nd.ovbk_windowWorkspaceId, nd.pWindow->m_iMonitorID,nd.ovbk_windowWorkspaceName);
                hycov_log(LOG,"create workspace: id:{} monitor:{} name:{}",nd.ovbk_windowWorkspaceId,nd.pWindow->m_iMonitorID,nd.ovbk_windowWorkspaceName);
            }
            nd.workspaceID = nd.pWindow->m_iWorkspaceID = nd.ovbk_windowWorkspaceId;
            nd.workspaceName = nd.ovbk_windowWorkspaceName;
            nd.pWindow->m_vPosition = nd.ovbk_position;
            nd.pWindow->m_vSize = nd.ovbk_size;
            g_pHyprRenderer->damageWindow(nd.pWindow);
        }
    }
}

// it will exec once when change layout enable
void GridLayout::onEnable()
{
    for (auto &w : g_pCompositor->m_vWindows)
    {
        if (w->isHidden() || !w->m_bIsMapped || w->m_bFadingOut)
            continue;
        onWindowCreatedTiling(w.get());
    }
}

// it will exec once when change layout disable
void GridLayout::onDisable()
{
    //  m_lGridNodesData.clear();
}