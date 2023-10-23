#pragma once

#include <hyprland/src/layout/IHyprLayout.hpp>
#include <hyprland/src/SharedDefs.hpp>

struct SGridNodeData {
    CWindow* pWindow = nullptr;
    int ovbk_pWindow_workspaceID = -1;
    bool ovbk_pWindow_isFloating = false;
    bool ovbk_pWindow_isFullscreen = false;
    Vector2D ovbk_position;
    Vector2D ovbk_size;
    Vector2D position;
    Vector2D size;

    int      workspaceID = -1;

    bool     operator==(const SGridNodeData& rhs) const {
        return pWindow == rhs.pWindow;
    }
};

class GridLayout : public IHyprLayout {
  public:
    virtual void                     onWindowCreatedTiling(CWindow*, eDirection direction = DIRECTION_DEFAULT);
    virtual void                     onWindowRemovedTiling(CWindow*);
    virtual bool                     isWindowTiled(CWindow*);
    virtual void                     recalculateMonitor(const int&);
    virtual void                     recalculateWindow(CWindow*);
    virtual void                     resizeActiveWindow(const Vector2D&, eRectCorner corner, CWindow* pWindow = nullptr);
    virtual void                     fullscreenRequestForWindow(CWindow*, eFullscreenMode, bool);
    virtual std::any                 layoutMessage(SLayoutMessageHeader, std::string);
    virtual SWindowRenderLayoutHints requestRenderHints(CWindow*);
    virtual void                     switchWindows(CWindow*, CWindow*);
    virtual void                     alterSplitRatio(CWindow*, float, bool);
    virtual std::string              getLayoutName();
    virtual void                     replaceWindowDataWith(CWindow* from, CWindow* to);
		virtual void										 moveWindowTo(CWindow *, const std::string& dir);


    virtual void                     onEnable();
    virtual void                     onDisable();
	  static void mouseMoveHook(void*, SCallbackInfo& info, std::any);
	  static void mouseButtonHook(void*, SCallbackInfo& info, std::any);
    static void        toggle_hotarea(int , int);
    void                              applyNodeDataToWindow(SGridNodeData*);
    void                              calculateWorkspace(const int&);
    int                               getNodesNumOnWorkspace(const int&);
    SGridNodeData*                    getNodeFromWindow(CWindow*);
    void                              changeToActivceSourceWorkspace();
    void                              resizeNodeSizePos(SGridNodeData * , int ,int,int,int);
    void                              moveWindowToWorkspaceSilent(CWindow *,const int&);
    std::list<SGridNodeData> m_lGridNodesData; //这个好像是所有被平铺的窗口所在的节点队列
    bool isFirstTile = true;
    void moveWindowToSourceWorkspace();
    bool isOverView;
    bool isInHotArea;

  private:
};