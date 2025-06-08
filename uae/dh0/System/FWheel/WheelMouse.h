
#include <intuition/intuition.h>
#include <devices/inputevent.h>

extern char *WindowModeNames[];
extern char *ClickModeNames[];
extern char *ClickRollModeNames[];
extern char *DoubleClickModeNames[];

enum WindowModes {OverWindow,ActiveWindow};

enum ClickModes {ClickIgnore,ClickShift,ClickShiftClick,
                 ClickToggleLMB,ClickMoveToScroll,
                 ClickMoveScrollToggle,ClickCycleScreens};

enum ClickRollModes {ClickRollIgnore,ClickRollDepthArrange,ClickRollHorizontalScroll};

enum DoubleClickModes {DClickIgnore,DClickCycleScreens,DClickSwapAxis};


struct ButtonData
{
  enum ClickModes ClickMode;
  enum ClickRollModes ClickRollMode;
  enum DoubleClickModes DoubleClickMode;
  char **ClickModeNames;
  char **ClickRollModeNames;
  char **DoubleClickModeNames;
  BOOL State;
  long Count,Secs,Microsecs;  /* Used for double-click detection */
  BOOL LMBToggle,ScrollToggle,AxisToggle;
};


struct WheelMouseContext
{
  void (*Dispose)(struct WheelMouseContext *wm);
  BOOL (*Handle)(struct WheelMouseContext *wm,unsigned long signals);
  int ScrollX,ScrollY;
  int FakeX,FakeY;

  enum WindowModes WindowMode;
  char **WindowModeNames;
  struct ButtonData MidButton,FourthButton;
  int MouseSpeedX,MouseSpeedY;
  int ScrollSpeedX,ScrollSpeedY;
  int FakeScrollSpeed;
  BOOL ClickToFront,ClickToBack;
  BOOL NudgeProp,ForgeRawKey,RawKeyPage;
  BOOL HorizSwap,VertSwap;
  BOOL IgnoreMUI;
  int PageThreshold;

  struct Task *MainTask;
  unsigned long Signals;
  int SigBit;
  struct MsgPort *ReplyPort,*IOPort;
  struct IOStdReq *IOReq;

  struct Window *Window;
  struct Gadget *Gadget;
  struct ExtIntuiMessage Msg1;
  unsigned long pad11,pad12,pad13,pad14; /* struct might be extended further! */
  struct ExtIntuiMessage Msg2;
  unsigned long pad21,pad22,pad23,pad24;
  struct InputEvent Event;
};

struct WheelMouseContext *WheelMouse_Create();

