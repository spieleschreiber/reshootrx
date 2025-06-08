
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <exec/types.h>
#include <exec/io.h>

#include <devices/input.h>
#include <intuition/newmouse.h>

#include <clib/exec_protos.h>
#include <clib/input_protos.h>

#include "WheelMouse.h"
#include "Scroll.h"

char *WindowModeNames[]={"Window under pointer",
                         "Active window",NULL };

char *ClickModeNames[]={"Ignore",
                         "Shift",
                         "Shift + Left Button",
                         "Toggle Left Button",
                         "Movement -> Scroll",
                         "Move/Scroll Toggle",
                         "Cycle screens",NULL};

char *ClickRollModeNames[]={"Ignore",
                           "Depth Arrange Windows",
                           "Horizontal Scroll",NULL};

char *DoubleClickModeNames[]={"Ignore",
                              "Cycle Screens",
                              "Swap Axis",NULL};

void *InputBase;

BOOL WheelMouse_Handle(struct WheelMouseContext *wmc,unsigned long signals);
void WheelMouse_Dispose(struct WheelMouseContext *wmc);


void WheelMouse_Dispose(struct WheelMouseContext *wmc)
{
  if(wmc)
  {
    if(wmc->IOReq)
    {
      CloseDevice((struct IORequest *)wmc->IOReq);
      DeleteIORequest((struct IORequest *)wmc->IOReq);
      wmc->IOReq=NULL;
    }
    if(wmc->IOPort)
      DeleteMsgPort(wmc->IOPort);
    wmc->IOPort=NULL;

    if(wmc->ReplyPort)
      DeleteMsgPort(wmc->ReplyPort);

    if(wmc->SigBit>-1)
      FreeSignal(wmc->SigBit);
    free(wmc);
  }
}


struct WheelMouseContext *WheelMouse_Create()
{
  struct WheelMouseContext *wmc;
  if(!(wmc=malloc(sizeof(struct WheelMouseContext))))
    return(NULL);
  memset(wmc,0,sizeof(struct WheelMouseContext));

  wmc->Dispose=WheelMouse_Dispose;
  wmc->Handle=WheelMouse_Handle;

  wmc->WindowModeNames=WindowModeNames;
  wmc->MidButton.ClickModeNames=ClickModeNames;
  wmc->MidButton.ClickRollModeNames=ClickRollModeNames;
  wmc->MidButton.DoubleClickModeNames=DoubleClickModeNames;
  wmc->FourthButton.ClickModeNames=ClickModeNames;
  wmc->FourthButton.ClickRollModeNames=ClickRollModeNames;
  wmc->FourthButton.DoubleClickModeNames=DoubleClickModeNames;
  wmc->MouseSpeedX=wmc->MouseSpeedY=100;
  wmc->ClickToFront=FALSE;

  wmc->MainTask=FindTask(NULL);
  if((wmc->SigBit=AllocSignal(-1))==-1)
  {
    wmc->Dispose(wmc);
    return(NULL);
  }
  wmc->Signals=1<<wmc->SigBit;

  if(!(wmc->ReplyPort=CreateMsgPort()))
  {
    wmc->Dispose(wmc);
    return(NULL);
  }

  if(!(wmc->IOPort=CreateMsgPort()))
  {
    wmc->Dispose(wmc);
    return(NULL);
  }

  if(!(wmc->IOReq=(struct IOStdReq *)CreateIORequest(wmc->IOPort,sizeof(struct IOStdReq))))
  {
    wmc->Dispose(wmc);
    return(NULL);
  }

  if(OpenDevice("input.device",0,(struct IORequest *)wmc->IOReq,0))
  {
    DeleteIORequest((struct IORequest *)wmc->IOReq);
    wmc->IOReq=NULL;
    wmc->Dispose(wmc);
  }
  InputBase=wmc->IOReq->io_Device;

  wmc->IOReq->io_Command=IND_WRITEEVENT;
  wmc->IOReq->io_Length=sizeof(struct InputEvent);
  wmc->IOReq->io_Data=&wmc->Event;

  return(wmc);
}


void AddIntAtomic(int *a,int v)
{
  *a+=v;  /* Make sure your compiler generates a single instruction
             for this operation, i.e. add.l d0,(a0), and not
             move.l (a0),d1   add.l d0,d1   move.l d1,(a0) */
}


BOOL WheelMouse_Handle(struct WheelMouseContext *wmc,unsigned long signals)
{
  int distance;
  if(!(signals&wmc->Signals))
    return(TRUE);

  while(wmc->ScrollX||wmc->ScrollY||wmc->FakeX||wmc->FakeY)
  {
    if(distance=wmc->ScrollX)
    {
      distance=DoScroll(wmc,FREEHORIZ,distance);
      AddIntAtomic(&wmc->ScrollX,-distance);
    }

    if(distance=wmc->ScrollY)
    {
      distance=DoScroll(wmc,FREEHORIZ|FREEVERT,distance);
      AddIntAtomic(&wmc->ScrollY,-distance);
    }

    if(wmc->FakeX<0)
    {
      AddIntAtomic(&wmc->FakeX,1);
      wmc->Event.ie_Class=IECLASS_RAWKEY;
      wmc->Event.ie_Code=NM_WHEEL_LEFT;
      wmc->Event.ie_Qualifier=PeekQualifier();
      DoIO((struct IORequest *)wmc->IOReq);
      wmc->Event.ie_Class=IECLASS_NEWMOUSE;
      wmc->Event.ie_Code=NM_WHEEL_LEFT;
      wmc->Event.ie_Qualifier=PeekQualifier();
      DoIO((struct IORequest *)wmc->IOReq);
    }

    if(wmc->FakeX>0)
    {
      AddIntAtomic(&wmc->FakeX,-1);
      wmc->Event.ie_Class=IECLASS_RAWKEY;
      wmc->Event.ie_Code=NM_WHEEL_RIGHT;
      wmc->Event.ie_Qualifier=PeekQualifier();
      DoIO((struct IORequest *)wmc->IOReq);
      wmc->Event.ie_Class=IECLASS_NEWMOUSE;
      wmc->Event.ie_Code=NM_WHEEL_RIGHT;
      wmc->Event.ie_Qualifier=PeekQualifier();
      DoIO((struct IORequest *)wmc->IOReq);
    }

    if(wmc->FakeY<0)
    {
      AddIntAtomic(&wmc->FakeY,1);
      wmc->Event.ie_Class=IECLASS_RAWKEY;
      wmc->Event.ie_Code=NM_WHEEL_UP;
      wmc->Event.ie_Qualifier=PeekQualifier();
      DoIO((struct IORequest *)wmc->IOReq);
      wmc->Event.ie_Class=IECLASS_NEWMOUSE;
      wmc->Event.ie_Code=NM_WHEEL_UP;
      wmc->Event.ie_Qualifier=PeekQualifier();
      DoIO((struct IORequest *)wmc->IOReq);
    }

    if(wmc->FakeY>0)
    {
      AddIntAtomic(&wmc->FakeY,-1);
      wmc->Event.ie_Class=IECLASS_RAWKEY;
      wmc->Event.ie_Code=NM_WHEEL_DOWN;
      wmc->Event.ie_Qualifier=PeekQualifier();
      DoIO((struct IORequest *)wmc->IOReq);
      wmc->Event.ie_Class=IECLASS_NEWMOUSE;
      wmc->Event.ie_Code=NM_WHEEL_DOWN;
      wmc->Event.ie_Qualifier=PeekQualifier();
      DoIO((struct IORequest *)wmc->IOReq);
    }

  }
  return(TRUE);
}

