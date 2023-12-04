#pragma once

#include <hyprland/src/layout/IHyprLayout.hpp>
#include <hyprland/src/SharedDefs.hpp>

struct SGridNodeData
{
  CWindow *pWindow = nullptr;
  int ovbk_windowWorkspaceId = -1;
  std::string ovbk_windowWorkspaceName;
  std::string workspaceName;
  bool ovbk_windowIsFloating = false;
  bool ovbk_windowIsFullscreen = false;
  eFullscreenMode ovbk_windowFullscreenMode ;
  Vector2D ovbk_position;
  Vector2D ovbk_size;
  Vector2D position;
  Vector2D size;

  int workspaceID = -1;

  bool operator==(const SGridNodeData &rhs) const
  {
    return pWindow == rhs.pWindow;
  }
};

class GridLayout : public IHyprLayout
{
public:
  virtual void onWindowCreatedTiling(CWindow *, eDirection direction = DIRECTION_DEFAULT);
  virtual void onWindowRemovedTiling(CWindow *);
  virtual bool isWindowTiled(CWindow *);
  virtual void recalculateMonitor(const int &);
  virtual void recalculateWindow(CWindow *);
  virtual void resizeActiveWindow(const Vector2D &, eRectCorner corner, CWindow *pWindow = nullptr);
  virtual void fullscreenRequestForWindow(CWindow *, eFullscreenMode, bool);
  virtual std::any layoutMessage(SLayoutMessageHeader, std::string);
  virtual SWindowRenderLayoutHints requestRenderHints(CWindow *);
  virtual void switchWindows(CWindow *, CWindow *);
  virtual void alterSplitRatio(CWindow *, float, bool);
  virtual std::string getLayoutName();
  virtual void replaceWindowDataWith(CWindow *from, CWindow *to);
  virtual void moveWindowTo(CWindow *, const std::string &dir);
  virtual void onEnable();
  virtual void onDisable();
  void applyNodeDataToWindow(SGridNodeData *);
  void calculateWorkspace(const int &);
  int getNodesNumOnWorkspace(const int &);
  SGridNodeData *getNodeFromWindow(CWindow *);
  void resizeNodeSizePos(SGridNodeData *, int, int, int, int);
  void moveWindowToWorkspaceSilent(CWindow *, const int &);
  std::list<SGridNodeData> m_lGridNodesData; 
  void moveWindowToSourceWorkspace();
  void changeToActivceSourceWorkspace();
private:
};