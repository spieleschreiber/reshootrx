
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <exec/types.h>
#include <intuition/intuition.h>
#include <intuition/screens.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>

#include "Cx.h"
#include "Prefs.h"
#include "GUI.h"
#include "WheelMouse.h"

#include "ButtonWin.h"

#define MIDCLICK_ID 1
#define MIDCLICKROLL_ID 2
#define MIDDOUBLECLICK_ID 3
#define FOURTHCLICK_ID 4
#define FOURTHCLICKROLL_ID 5
#define FOURTHDOUBLECLICK_ID 6

BOOL ButtonWin_Show(struct ButtonWinContext *pwc);
void ButtonWin_Hide(struct ButtonWinContext *pwc);
BOOL ButtonWin_Handle(struct ButtonWinContext *pwc,unsigned long sigs);
void ButtonWin_Dispose(struct ButtonWinContext *pwc);

extern struct WheelMouseContext *MyWM;
extern struct CxContext *MyCx;

char *BWinGadTitles[]=
{
  "Middle button:",
  "Fourth button:",
  "Click:",
  "Click + Roll:",
  "Double Click:",
  NULL
};

#define MIDBUTTON_TITLE 0
#define FOURTHBUTTON_TITLE 1
#define CLICK_TITLE 2
#define CLICKROLL_TITLE 3
#define DOUBLECLICK_TITLE 4

BOOL ButtonWin_Show(struct ButtonWinContext *pwc)
{
  struct Gadget *gg;
  int width,width2;
  int winleft,wintop;

  if(pwc->Visible)
    return(FALSE);

  if(!(pwc->Screen=LockPubScreen(NULL)))
    return(FALSE);

  if(!(pwc->GUI=GUI_Create(pwc->Screen,pwc->Screen->Font,8,8)))
  {
    pwc->Hide(pwc);
    return(FALSE);
  }

  GUI_StringTab(pwc->GUI,BWinGadTitles);

  width=GUI_MaxStringWidth(pwc->GUI,MyWM->MidButton.ClickModeNames);
  width2=GUI_MaxStringWidth(pwc->GUI,MyWM->MidButton.DoubleClickModeNames);
  if(width2>width) width=width2;
  width2=GUI_MaxStringWidth(pwc->GUI,MyWM->MidButton.ClickRollModeNames);
  if(width2>width) width=width2;

  pwc->GUI->InnerWidth=pwc->GUI->TabStop+width+64;

  /* Middle mouse button stuff */

  gg=GUI_BuildText(pwc->GUI,BWinGadTitles[MIDBUTTON_TITLE]);

  gg=GUI_BuildCycleGadget(pwc->GUI,BWinGadTitles[CLICK_TITLE],MyWM->MidButton.ClickModeNames,MIDCLICK_ID);
  GT_SetGadgetAttrs(gg,NULL,NULL,GTCY_Active,
                    pwc->Prefs->GetLong(pwc->Prefs,"MidClick",0),TAG_DONE);

  gg=GUI_BuildCycleGadget(pwc->GUI,BWinGadTitles[CLICKROLL_TITLE],MyWM->MidButton.ClickRollModeNames,MIDCLICKROLL_ID);
  GT_SetGadgetAttrs(gg,NULL,NULL,GTCY_Active,
                    pwc->Prefs->GetLong(pwc->Prefs,"MidCRoll",0),TAG_DONE);

  gg=GUI_BuildCycleGadget(pwc->GUI,BWinGadTitles[DOUBLECLICK_TITLE],MyWM->MidButton.DoubleClickModeNames,MIDDOUBLECLICK_ID);
  GT_SetGadgetAttrs(gg,NULL,NULL,GTCY_Active,
                    pwc->Prefs->GetLong(pwc->Prefs,"MidDClick",0),TAG_DONE);

  /* Fourth mouse button stuff */

  gg=GUI_BuildText(pwc->GUI,BWinGadTitles[FOURTHBUTTON_TITLE]);

  gg=GUI_BuildCycleGadget(pwc->GUI,BWinGadTitles[CLICK_TITLE],MyWM->FourthButton.ClickModeNames,FOURTHCLICK_ID);
  GT_SetGadgetAttrs(gg,NULL,NULL,GTCY_Active,
                    pwc->Prefs->GetLong(pwc->Prefs,"4thClick",0),TAG_DONE);

  gg=GUI_BuildCycleGadget(pwc->GUI,BWinGadTitles[CLICKROLL_TITLE],MyWM->FourthButton.ClickRollModeNames,FOURTHCLICKROLL_ID);
  GT_SetGadgetAttrs(gg,NULL,NULL,GTCY_Active,
                    pwc->Prefs->GetLong(pwc->Prefs,"4thCRoll",0),TAG_DONE);

  gg=GUI_BuildCycleGadget(pwc->GUI,BWinGadTitles[DOUBLECLICK_TITLE],MyWM->FourthButton.DoubleClickModeNames,FOURTHDOUBLECLICK_ID);
  GT_SetGadgetAttrs(gg,NULL,NULL,GTCY_Active,
                    pwc->Prefs->GetLong(pwc->Prefs,"4thDClick",0),TAG_DONE);

  if(!(pwc->GUI->LastGadget))
  {
    pwc->Hide(pwc);
    return(FALSE);
  }

  winleft=pwc->Prefs->GetLong(pwc->Prefs,"ButtLeft",0);
  wintop=pwc->Prefs->GetLong(pwc->Prefs,"ButtTop",1+pwc->Screen->BarHeight);

  if(!(pwc->Window=OpenWindowTags(NULL,WA_Left,winleft,
                                       WA_Top,wintop,
                                       WA_InnerWidth,pwc->GUI->InnerWidth,
                                       WA_InnerHeight,pwc->GUI->InnerHeight,
                                       WA_IDCMP,IDCMP_REFRESHWINDOW|IDCMP_CLOSEWINDOW|pwc->GUI->IDCMP,
                                       WA_SizeGadget,FALSE,WA_DragBar,TRUE,
                                       WA_DepthGadget,TRUE,WA_CloseGadget,TRUE,
                                       WA_NewLookMenus,TRUE,
                                       WA_Activate,FALSE,
                                       WA_Title,"Button settings...",TAG_DONE)))
  {
    pwc->Hide(pwc);
    return(FALSE);
  }

  pwc->GUI->Attach(pwc->GUI,pwc->Window);

  pwc->Signals=1<<pwc->Window->UserPort->mp_SigBit;

  pwc->Visible=TRUE;
  return(TRUE);
}


void ButtonWin_Hide(struct ButtonWinContext *pwc)
{
  if(pwc->Window)
  {
    pwc->Prefs->SetLong(pwc->Prefs,"ButtTop",pwc->Window->TopEdge);
    pwc->Prefs->SetLong(pwc->Prefs,"ButtLeft",pwc->Window->LeftEdge);
    CloseWindow(pwc->Window);
  }
  pwc->Window=FALSE;
  pwc->Signals=0;

  if(pwc->GUI)
    pwc->GUI->Dispose(pwc->GUI);
  pwc->GUI=NULL;

  if(pwc->Screen)
    UnlockPubScreen(NULL,pwc->Screen);
  pwc->Screen=FALSE;

  if(pwc->Visible)
    pwc->Visible=FALSE;
}


void ButtonWin_Dispose(struct ButtonWinContext *pwc)
{
  if(pwc)
  {
    if(pwc->Visible)
      pwc->Hide(pwc);
    free(pwc);
  }
}


struct ButtonWinContext *ButtonWin_Create(struct PrefsGroup *pg)
{
  struct ButtonWinContext *pwc;
  if(!(pwc=malloc(sizeof(struct ButtonWinContext))))
    return(NULL);
  memset(pwc,0,sizeof(struct ButtonWinContext));
  pwc->Dispose=ButtonWin_Dispose;
  pwc->Handle=ButtonWin_Handle;
  pwc->Hide=ButtonWin_Hide;
  pwc->Show=ButtonWin_Show;

  pwc->Prefs=pg;

  return(pwc);
}


BOOL ButtonWin_Handle(struct ButtonWinContext *pwc,unsigned long sigs)
{
  BOOL cont=TRUE,close=FALSE;
  long value;
  if(pwc)
  {
    if(sigs&pwc->Signals)
    {
      struct IntuiMessage *im;
      while(im=GT_GetIMsg(pwc->Window->UserPort))
      {
        int class,code,id;
        struct Gadget *gg;
        class=im->Class;
        code=im->Code;
        switch(class)
        {
          case IDCMP_GADGETUP:
            gg=(struct Gadget *)im->IAddress;
            id=gg->GadgetID;
            GT_ReplyIMsg(im);
            switch(id)
            {
              case MIDCLICK_ID:
                GT_GetGadgetAttrs(gg,pwc->Window,NULL,GTCY_Active,&value,TAG_DONE);
                pwc->Prefs->SetLong(pwc->Prefs,"MidClick",value);
                MyWM->MidButton.ClickMode=value;
                break;
              case MIDCLICKROLL_ID:
                GT_GetGadgetAttrs(gg,pwc->Window,NULL,GTCY_Active,&value,TAG_DONE);
                pwc->Prefs->SetLong(pwc->Prefs,"MidCRoll",value);
                MyWM->MidButton.ClickRollMode=value;
                break;
              case MIDDOUBLECLICK_ID:
                GT_GetGadgetAttrs(gg,pwc->Window,NULL,GTCY_Active,&value,TAG_DONE);
                pwc->Prefs->SetLong(pwc->Prefs,"MidDClick",value);
                MyWM->MidButton.DoubleClickMode=value;
                break;
              case FOURTHCLICK_ID:
                GT_GetGadgetAttrs(gg,pwc->Window,NULL,GTCY_Active,&value,TAG_DONE);
                pwc->Prefs->SetLong(pwc->Prefs,"4thClick",value);
                MyWM->FourthButton.ClickMode=value;
                break;
              case FOURTHCLICKROLL_ID:
                GT_GetGadgetAttrs(gg,pwc->Window,NULL,GTCY_Active,&value,TAG_DONE);
                pwc->Prefs->SetLong(pwc->Prefs,"4thCRoll",value);
                MyWM->FourthButton.ClickRollMode=value;
                break;
              case FOURTHDOUBLECLICK_ID:
                GT_GetGadgetAttrs(gg,pwc->Window,NULL,GTCY_Active,&value,TAG_DONE);
                pwc->Prefs->SetLong(pwc->Prefs,"4thDClick",value);
                MyWM->FourthButton.DoubleClickMode=value;
                break;
            }
            break;
          case IDCMP_CLOSEWINDOW:
            GT_ReplyIMsg(im);
            close=TRUE;
            break;
          case IDCMP_REFRESHWINDOW:
            GT_ReplyIMsg(im);
            GT_BeginRefresh(pwc->Window);
            GT_EndRefresh(pwc->Window, TRUE);
            break;
          default:
            GT_ReplyIMsg(im);
            break;
        }
      }
    }
  }
  if(close)
    pwc->Hide(pwc);
  return(cont);
}

