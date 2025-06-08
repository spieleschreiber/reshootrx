
#include <exec/types.h>
#include <devices/inputevent.h>
#include <libraries/commodities.h>
#include <intuition/newmouse.h>
#include <intuition/intuitionbase.h>
#include <intuition/screens.h>
#include <graphics/clip.h>
#include <graphics/layers.h>

#include <clib/exec_protos.h>
#include <clib/commodities_protos.h>
#include <clib/intuition_protos.h>
#include <clib/alib_protos.h>

#include "WheelMouse.h"
#include "Scroll.h"
#include "Cx.h"
#include "RawKey.h"

#include "CxCustom.h"

extern struct IntuitionBase *IntuitionBase;
extern struct WheelMouseContext *MyWM;
extern struct CxContext *Cx;

int AddIntAtomic(int *a,int v);

void HandleDoubleClick(struct ButtonData *bd,struct InputEvent *ie);
void HandleClickToFront(struct InputEvent *ie);
BOOL InWindowBorder(struct Window *win);


void CxDepthArrange(int dy)
{
  struct Window *win;
  if(win=WindowUnderPointer())
  {
    if(win->Flags&WFLG_DEPTHGADGET)
    {
      if(dy<0)
        WindowToBack(win);
      else
        WindowToFront(win);
    }
  }
}


void CxCustomRoutine(CxMsg *msg,CxObj *obj)
{
  static int xrem=0,yrem=0;
  static int scrxrem=0,scryrem=0;
  int x,y,dx,dy,msx,msy,fdx,fdy;
  BOOL send=FALSE;
  struct InputEvent *e=CxMsgData(msg);

  msx=MyWM->MouseSpeedX;
  msy=MyWM->MouseSpeedY;

  dx=dy=fdx=fdy=0;

  if(((MyWM->MidButton.State)&&(MyWM->MidButton.ClickMode==ClickShiftClick))
   ||((MyWM->FourthButton.State)&&(MyWM->FourthButton.ClickMode==ClickShiftClick)))
  {
    e->ie_Qualifier&=~IEQUALIFIER_MIDBUTTON;
    e->ie_Qualifier|=IEQUALIFIER_LEFTBUTTON|IEQUALIFIER_LSHIFT|IEQUALIFIER_RSHIFT;
  }

  switch(e->ie_Class)
  {
    case IECLASS_RAWMOUSE:
      x=e->ie_X; y=e->ie_Y;
      if(msx>100)
        if(x<3 && x>-3)
          msx=100;
      if(msy>100)
        if(y<3 && y>-3)
          msy=100;
      x=e->ie_X*msx+xrem; xrem=x; x/=100; xrem-=x*100; e->ie_X=x;
      y=e->ie_Y*msy+yrem; yrem=y; y/=100; yrem-=y*100; e->ie_Y=y;

      switch(e->ie_Code)
      {
        case IECODE_MBUTTON:
          HandleDoubleClick(&MyWM->MidButton,e);

          MyWM->MidButton.State=TRUE;
          switch(MyWM->MidButton.ClickMode)
          {
            case ClickShift:
              e->ie_Code=RK_LShift;
              e->ie_Class=IECLASS_RAWKEY;
              break;
            case ClickShiftClick:
              e->ie_Code=IECODE_LBUTTON;
              e->ie_Qualifier=IEQUALIFIER_LSHIFT|IEQUALIFIER_RSHIFT;
              break;
            case ClickCycleScreens:
              ScreenToBack(IntuitionBase->FirstScreen);
              break;
            case ClickMoveScrollToggle:
              MyWM->MidButton.ScrollToggle^=1;
              break;
            case ClickMoveToScroll:
              MyWM->MidButton.ScrollToggle=1;
              break;
            case ClickToggleLMB:
              if(MyWM->MidButton.LMBToggle)
              {
                e->ie_Code=IECODE_LBUTTON|IECODE_UP_PREFIX;
                MyWM->MidButton.LMBToggle=0;
              }
              else
              {
                e->ie_Code=IECODE_LBUTTON;
                MyWM->MidButton.LMBToggle=1;
              }
              break;
          }
          break; /* IECODE_MBUTTON */

        case IECODE_MBUTTON|IECODE_UP_PREFIX:

          MyWM->MidButton.State=FALSE;
          switch(MyWM->MidButton.ClickMode)
          {
            case ClickShift:
              e->ie_Class=IECLASS_RAWKEY;
              e->ie_Code=RK_LShift|IECODE_UP_PREFIX;
              break;
            case ClickShiftClick:
              e->ie_Code=IECODE_UP_PREFIX|IECODE_LBUTTON;
              e->ie_Qualifier=IEQUALIFIER_LSHIFT|IEQUALIFIER_RSHIFT;
              break;
            case ClickMoveToScroll:
              MyWM->MidButton.ScrollToggle=0;
              break;
          }
          break; /* IECODE_MBUTTON|IECODE_UP_PREFIX */

        case IECODE_LBUTTON:
          if(MyWM->ClickToFront||MyWM->ClickToBack)
            HandleClickToFront(e);
          break;

        case IECODE_LBUTTON|IECODE_UP_PREFIX:
            MyWM->MidButton.LMBToggle=0;
            MyWM->FourthButton.LMBToggle=0;
          break;
      }


      /* Generate scrolling movement from mouse movement:
         A remainder is maintained, so small movements will accumulate. */

      if((MyWM->MidButton.ScrollToggle)||(MyWM->FourthButton.ScrollToggle))
      {
        fdx=e->ie_X*MyWM->FakeScrollSpeed+scrxrem;
        scrxrem=fdx; fdx/=256; scrxrem-=fdx*256; e->ie_X=0;
        fdy=e->ie_Y*MyWM->FakeScrollSpeed+scryrem;
        scryrem=fdy; fdy/=256; scryrem-=fdy*256; e->ie_Y=0;
        AddIntAtomic(&MyWM->FakeY,fdy);
        AddIntAtomic(&MyWM->FakeX,fdx);
        Signal(MyWM->MainTask,MyWM->Signals);
      }

      break; /* IECLASS_RAWMOUSE */

    case IECLASS_RAWKEY:
      switch(e->ie_Code)
      {
        case NM_BUTTON_FOURTH:
          HandleDoubleClick(&MyWM->FourthButton,e);

          MyWM->FourthButton.State=TRUE;
          switch(MyWM->FourthButton.ClickMode)
          {
            case ClickShift:
              e->ie_Code=RK_LShift;
              e->ie_Class=IECLASS_RAWKEY;
              break;
            case ClickShiftClick:
              e->ie_Class=IECLASS_RAWMOUSE;
              e->ie_Code=IECODE_LBUTTON;
              e->ie_Qualifier=IEQUALIFIER_LSHIFT|IEQUALIFIER_RSHIFT;
              break;
            case ClickCycleScreens:
              ScreenToBack(IntuitionBase->FirstScreen);
              break;
            case ClickMoveScrollToggle:
              MyWM->FourthButton.ScrollToggle^=1;
              break;
            case ClickMoveToScroll:
              MyWM->FourthButton.ScrollToggle=1;
              break;
            case ClickToggleLMB:
              if(MyWM->FourthButton.LMBToggle)
              {
                e->ie_Class=IECLASS_RAWMOUSE;
                e->ie_Code=IECODE_LBUTTON|IECODE_UP_PREFIX;
                e->ie_X=e->ie_Y=0;
                MyWM->FourthButton.LMBToggle=0;
              }
              else
              {
                e->ie_Class=IECLASS_RAWMOUSE;
                e->ie_Code=IECODE_LBUTTON;
                e->ie_X=e->ie_Y=0;
                MyWM->FourthButton.LMBToggle=1;
              }
              break;
          }
          break;
        case NM_BUTTON_FOURTH|IECODE_UP_PREFIX:
          MyWM->FourthButton.State=FALSE;
          switch(MyWM->FourthButton.ClickMode)
          {
            case ClickShift:
              e->ie_Class=IECLASS_RAWKEY;
              e->ie_Code=RK_LShift|IECODE_UP_PREFIX;
              break;
            case ClickShiftClick:
              e->ie_Class=IECLASS_RAWMOUSE;
              e->ie_Code=IECODE_UP_PREFIX|IECODE_LBUTTON;
              e->ie_Qualifier=IEQUALIFIER_LSHIFT|IEQUALIFIER_RSHIFT;
              break;
            case ClickMoveToScroll:
              MyWM->FourthButton.ScrollToggle=0;
              break;
          }
          break;
        case NM_WHEEL_UP:
          dy=-1;
          break;
        case NM_WHEEL_DOWN:
          dy=1;
          break;
        case NM_WHEEL_LEFT:
          dx=-1;
          break;
        case NM_WHEEL_RIGHT:
          dx=1;
          break;
      }
      break; /* IECLASS_RAWKEY */
  }

  if(dx||dy)
  {
    if(dy&&(MyWM->MidButton.State)&&(MyWM->MidButton.ClickRollMode==ClickRollDepthArrange))
    {
      CxDepthArrange(dy);
      MyWM->MidButton.State=FALSE;
    }
    else if(dy&&(MyWM->FourthButton.State)&&(MyWM->FourthButton.ClickRollMode==ClickRollDepthArrange))
    {
      CxDepthArrange(dy);
      MyWM->FourthButton.State=FALSE;
    }
    else
    {
      if(dy&&(MyWM->MidButton.State)&&(MyWM->MidButton.ClickRollMode==ClickRollHorizontalScroll))
      {
        dx=dy; dy=0;
      }
      else if(dy&&(MyWM->FourthButton.State)&&(MyWM->FourthButton.ClickRollMode==ClickRollHorizontalScroll))
      {
        dx=dy; dy=0;
      }
      if((MyWM->MidButton.AxisToggle)||(MyWM->FourthButton.AxisToggle))
      {
        dx=dy; dy=0;
      }
      /* As long as this addition is atomic, it is safe for the main
         task to read the variables and this task to write them,
         without semaphore protection.  The main task will read the
         value, and then subtract the value it has just read (again
         with an atomic operation). */
/*      dx+=fdx; dy+=fdy;*/
      AddIntAtomic(&MyWM->ScrollY,dy);
      AddIntAtomic(&MyWM->ScrollX,dx);
      Signal(MyWM->MainTask,MyWM->Signals);
    }
  }

  if((MyWM->MidButton.ClickMode==ClickShift)&&(MyWM->MidButton.State))
  {
    e->ie_Qualifier|=IEQUALIFIER_LSHIFT;
    e->ie_Qualifier&=~IEQUALIFIER_MIDBUTTON;
  }

  if((MyWM->FourthButton.ClickMode==ClickShift)&&(MyWM->FourthButton.State))
    e->ie_Qualifier|=IEQUALIFIER_LSHIFT;
}


void HandleDoubleClick(struct ButtonData *bd,struct InputEvent *ie)
{
  if((bd->Count==1) && (DoubleClick(bd->Secs,bd->Microsecs,ie->ie_TimeStamp.tv_secs,ie->ie_TimeStamp.tv_micro)))
  {
    switch(bd->DoubleClickMode)
    {
      case DClickCycleScreens:
        ScreenToBack(IntuitionBase->FirstScreen);
        break;
      case DClickSwapAxis:
        bd->AxisToggle^=1;
        break;
    }
    bd->Count=0;
  }
  else
  {
    bd->Count=1;
    bd->Secs=ie->ie_TimeStamp.tv_secs;
    bd->Microsecs=ie->ie_TimeStamp.tv_micro;
  }
}


void HandleClickToFront(struct InputEvent *ie)
{
  static struct Window *win=0,*lastwin=0;
  static long secs=0,microsecs=0,count=0;

  win=WindowUnderPointer();
  if(InWindowBorder(win))
  {
    if((count==1) && (win==lastwin) && (DoubleClick(secs,microsecs,ie->ie_TimeStamp.tv_secs,ie->ie_TimeStamp.tv_micro)))
    {
      struct Window *topwin=NULL;
      if(win->WScreen->LayerInfo.top_layer)
        topwin=win->WScreen->LayerInfo.top_layer->Window;
      if((win==topwin)&&(MyWM->ClickToBack))
        WindowToBack(win);
      else
        WindowToFront(win);
      count=0;
    }
    else
    {
      count=1; lastwin=win;
      secs=ie->ie_TimeStamp.tv_secs;
      microsecs=ie->ie_TimeStamp.tv_micro;
    }
  }
}


BOOL InWindowBorder(struct Window *win)
{
  int x,y;
  if(!win)
    return(FALSE);
  x=win->MouseX; y=win->MouseY;
  if((win->Flags&WFLG_BORDERLESS)&&!(win->Flags&WFLG_BACKDROP))
  {
    if((x>0)&&(y>0)&&(x<win->Width)&&(y<win->Height))
      return(TRUE);
  }
  if(x<win->BorderLeft)
    return(TRUE);
  if(y<win->BorderTop)
    return(TRUE);
  if(x>(win->Width-win->BorderRight-1))
    return(TRUE);
  if(y>(win->Height-win->BorderBottom-1))
    return(TRUE);
  return(FALSE);
}

