#include <stdio.h>

#include <exec/types.h>
#include <exec/ports.h>
#include <intuition/intuition.h>
#include <dos/dos.h>

#include <clib/exec_protos.h>

#include "Icon.h"
#include "Prefs.h"
#include "PrefsWin.h"
#include "Cx.h"
#include "CxCustom.h"
#include "WheelMouse.h"

void *IntuitionBase,*LayersBase,*CxBase;
void *IconBase,*GfxBase,*GadToolsBase;
struct MsgPort *ReplyPort;

struct CxContext *MyCx;
struct WheelMouseContext *MyWM;
struct PrefsGroup *MyPrefs;
struct PrefsWinContext *MyPrefsWin;


void CxShowCallback(struct CxContext *cx)
{
  struct PrefsWinContext *pwc=cx->UserData;
  if(pwc)
  {
    pwc->Show(pwc);
  }
}


void CxHideCallback(struct CxContext *cx)
{
  struct PrefsWinContext *pwc=cx->UserData;
  if(pwc)
  {
    pwc->Hide(pwc);
  }
}


char *Main_Setup()
{
  if(!(IntuitionBase=OpenLibrary("intuition.library",37)))
    return("Can't open intuition.library");
  if(!(LayersBase=OpenLibrary("layers.library",37)))
    return("Can't open intuition.library");
  if(!(CxBase=OpenLibrary("commodities.library",37)))
    return("Can't open commodities.library");
  if(!(IconBase=OpenLibrary("icon.library",37)))
    return("Can't open icon.library");
  if(!(GfxBase=OpenLibrary("graphics.library",37)))
    return("Can't open graphics.library");
  if(!(GadToolsBase=OpenLibrary("gadtools.library",37)))
    return("Can't open gadtools.library");

  if(!(ReplyPort=CreateMsgPort()))
    return("Can't create message port");

  if(!(Icon_Setup()))
    return("Problems with the icon!");

  if(!(MyPrefs=Prefs_GetGroup("FreeWheel.cfg")))
    return("Problems with prefs!");

  if(!(MyPrefsWin=PrefsWin_Create(MyPrefs)))
    return("Can't create User Interface!");

  if(!(MyWM=WheelMouse_Create()))
    return("Can't create WheelMouse Context");

  if(!(MyCx=CxContext_Create("FreeWheel",
                             "Scrolling with WheelMice - 2.1",
                             "© 1999 - Alastair M. Robinson",MyPrefsWin)))
    return("Can't create CxContext!");

  if(!(MyCx->SetCustom(MyCx,CxCustomRoutine)))
    return("Can't create CxCustom object!");

  MyCx->ShowCallback=CxShowCallback;
  MyCx->HideCallback=CxHideCallback;

  return(NULL);
}


void Main_Cleanup()
{
  if(MyCx)
    MyCx->Dispose(MyCx);
  MyCx=NULL;

  if(MyWM)
    MyWM->Dispose(MyWM);
  MyWM=NULL;

  if(MyPrefsWin)
    MyPrefsWin->Dispose(MyPrefsWin);
  MyPrefsWin=NULL;

  if(MyPrefs)
    MyPrefs->Dispose(MyPrefs);
  MyPrefs=NULL;

  Icon_Cleanup();

  if(ReplyPort)
    DeleteMsgPort(ReplyPort);
  ReplyPort=NULL;

  if(GadToolsBase) CloseLibrary(GadToolsBase); GadToolsBase=NULL;
  if(GfxBase) CloseLibrary(GfxBase); GfxBase=NULL;
  if(IconBase) CloseLibrary(IconBase); IconBase=NULL;
  if(CxBase) CloseLibrary(CxBase); CxBase=NULL;
  if(IntuitionBase) CloseLibrary(IntuitionBase); IntuitionBase=NULL;
  if(LayersBase) CloseLibrary(LayersBase); LayersBase=NULL;
}


int main()
{
  char *error;
  if(error=Main_Setup())
  {
    printf("Error: %s\n",error);
  }
  else
  {
    BOOL cont=TRUE;
    unsigned long sigs;

    MyWM->WindowMode=MyPrefs->GetLong(MyPrefs,"WindowMode",OverWindow);

    MyWM->MidButton.ClickMode=MyPrefs->GetLong(MyPrefs,"MidClick",ClickIgnore);
    MyWM->MidButton.ClickRollMode=MyPrefs->GetLong(MyPrefs,"MidCRoll",ClickRollIgnore);
    MyWM->MidButton.DoubleClickMode=MyPrefs->GetLong(MyPrefs,"MidDClick",DClickIgnore);
    MyWM->FourthButton.ClickMode=MyPrefs->GetLong(MyPrefs,"4thClick",ClickIgnore);
    MyWM->FourthButton.ClickRollMode=MyPrefs->GetLong(MyPrefs,"4thCRoll",ClickRollIgnore);
    MyWM->FourthButton.DoubleClickMode=MyPrefs->GetLong(MyPrefs,"4thDClick",DClickIgnore);

    MyWM->MouseSpeedX=MyPrefs->GetLong(MyPrefs,"XMouseSpeed",100);
    MyWM->MouseSpeedY=MyPrefs->GetLong(MyPrefs,"YMouseSpeed",100);
    MyWM->ClickToFront=MyPrefs->GetLong(MyPrefs,"ClickFront",TRUE);
    MyWM->ClickToBack=MyPrefs->GetLong(MyPrefs,"ClickBack",FALSE);
    MyCx->SetHotKey(MyCx,MyPrefs->GetString(MyPrefs,"Hot Key","ctrl alt f"));

    MyWM->ScrollSpeedX=MyPrefs->GetLong(MyPrefs,"XScrollSpeed",17);
    MyWM->ScrollSpeedY=MyPrefs->GetLong(MyPrefs,"XScrollSpeed",17);

    MyWM->IgnoreMUI=MyPrefs->GetLong(MyPrefs,"IgnoreMUI",TRUE);

    MyWM->NudgeProp=MyPrefs->GetLong(MyPrefs,"NudgeProp",TRUE);
    MyWM->ForgeRawKey=MyPrefs->GetLong(MyPrefs,"ForgeRawKey",TRUE);
    MyWM->RawKeyPage=MyPrefs->GetLong(MyPrefs,"RawKeyPage",TRUE);
    MyWM->HorizSwap=MyPrefs->GetLong(MyPrefs,"HorizSwap",FALSE);
    MyWM->VertSwap=MyPrefs->GetLong(MyPrefs,"VertSwap",FALSE);
    MyWM->PageThreshold=MyPrefs->GetLong(MyPrefs,"PageThreshold",4);
    MyWM->FakeScrollSpeed=MyPrefs->GetLong(MyPrefs,"FakeScrollSpeed",7);

    while(cont)
    {
      sigs=SIGBREAKF_CTRL_C|MyCx->Signals|MyWM->Signals|MyPrefsWin->Signals;
      sigs=Wait(sigs);
      if(sigs&SIGBREAKF_CTRL_C)
        cont=FALSE;
      cont&=MyCx->Handle(MyCx,sigs);
      cont&=MyWM->Handle(MyWM,sigs);
      cont&=MyPrefsWin->Handle(MyPrefsWin,sigs);
    }
  }
  Main_Cleanup();
  return(0);
}

