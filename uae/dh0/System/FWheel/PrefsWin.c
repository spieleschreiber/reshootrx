
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
#include "ScrollWin.h"
#include "PrefsWin.h"

#define WINDOWMODE_ID 1
#define SAVE_ID 8
#define HIDE_ID 9
#define QUIT_ID 10
#define HOTKEY_ID 11
#define XSPEED_ID 12
#define YSPEED_ID 13
#define CLICKFRONT_ID 14
#define CLICKBACK_ID 15
#define SETBUTTONS_ID 16
#define SETSCROLL_ID 17

BOOL PrefsWin_Show(struct PrefsWinContext *pwc);
void PrefsWin_Hide(struct PrefsWinContext *pwc);
BOOL PrefsWin_Handle(struct PrefsWinContext *pwc,unsigned long sigs);
void PrefsWin_Dispose(struct PrefsWinContext *pwc);

extern struct WheelMouseContext *MyWM;
extern struct CxContext *MyCx;

char *PWinGadTitles[]=
{
  "Scroll window:",
  "Mouse speed X: %ld%%",
  "Mouse speed Y: %ld%%",
  "Click to front:",
  "Hot key:",
  "Click to back:",
  "Set buttons...",
  "Set scrolling...",
  NULL
};

#define SCROLLWINDOW_TITLE 0
#define MOUSESPEEDX_TITLE 1
#define MOUSESPEEDY_TITLE 2
#define CLICKFRONT_TITLE 3
#define HOTKEY_TITLE 4
#define CLICKBACK_TITLE 5
#define SETBUTTONS_TITLE 6
#define SETSCROLL_TITLE 7

BOOL PrefsWin_Show(struct PrefsWinContext *pwc)
{
  struct Gadget *gg;
  int width,width2,leftedge,topedge;
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

  GUI_StringTab(pwc->GUI,PWinGadTitles);

  width=GUI_MaxStringWidth(pwc->GUI,MyWM->WindowModeNames);
  width2=GUI_MaxStringWidth(pwc->GUI,MyWM->MidButton.ClickModeNames);
  if(width2>width) width=width2;
  width2=GUI_MaxStringWidth(pwc->GUI,MyWM->FourthButton.ClickModeNames);
  if(width2>width) width=width2;

  pwc->GUI->InnerWidth=pwc->GUI->TabStop+width+64;

  gg=GUI_BuildSliderFormatted(pwc->GUI,PWinGadTitles[MOUSESPEEDX_TITLE],33,300,100,XSPEED_ID);
  GT_SetGadgetAttrs(gg,NULL,NULL,GTSL_Level,
                    pwc->Prefs->GetLong(pwc->Prefs,"XMouseSpeed",100),TAG_DONE);

  gg=GUI_BuildSliderFormatted(pwc->GUI,PWinGadTitles[MOUSESPEEDY_TITLE],33,300,100,YSPEED_ID);
  GT_SetGadgetAttrs(gg,NULL,NULL,GTSL_Level,
                    pwc->Prefs->GetLong(pwc->Prefs,"YMouseSpeed",100),TAG_DONE);

  gg=GUI_BuildCheckBox(pwc->GUI,PWinGadTitles[CLICKFRONT_TITLE],CLICKFRONT_ID);
  GT_SetGadgetAttrs(gg,NULL,NULL,GTCB_Checked,
                    pwc->Prefs->GetLong(pwc->Prefs,"ClickFront",TRUE),TAG_DONE);

  gg=GUI_BuildCheckBox(pwc->GUI,PWinGadTitles[CLICKBACK_TITLE],CLICKBACK_ID);
  GT_SetGadgetAttrs(gg,NULL,NULL,GTCB_Checked,
                    pwc->Prefs->GetLong(pwc->Prefs,"ClickBack",FALSE),TAG_DONE);

  gg=GUI_BuildString(pwc->GUI,PWinGadTitles[HOTKEY_TITLE],255,HOTKEY_ID);
  GT_SetGadgetAttrs(gg,NULL,NULL,GTST_String,
                    pwc->Prefs->GetString(pwc->Prefs,"Hot Key","ctrl alt f"),TAG_DONE);

  GUI_StringTab(pwc->GUI,NULL);

  width=pwc->GUI->InnerWidth;
  leftedge=pwc->GUI->BorderLeft;
  topedge=pwc->GUI->InnerHeight;

  pwc->GUI->InnerWidth/=2;
  gg=GUI_BuildWideButton(pwc->GUI,PWinGadTitles[SETBUTTONS_TITLE],SETBUTTONS_ID);

  pwc->GUI->InnerHeight=topedge;
  pwc->GUI->BorderLeft+=width/2;
  gg=GUI_BuildWideButton(pwc->GUI,PWinGadTitles[SETSCROLL_TITLE],SETSCROLL_ID);

  pwc->GUI->BorderLeft=leftedge;
  pwc->GUI->InnerWidth=width;
  topedge=pwc->GUI->InnerHeight;

  pwc->GUI->InnerWidth=width/3;
  GUI_BuildWideButton(pwc->GUI,"Save",SAVE_ID);

  pwc->GUI->InnerHeight=topedge;
  pwc->GUI->BorderLeft+=width/3;
  GUI_BuildWideButton(pwc->GUI,"Hide",HIDE_ID);

  pwc->GUI->InnerHeight=topedge;
  pwc->GUI->BorderLeft+=width/3;
  GUI_BuildWideButton(pwc->GUI,"Quit",QUIT_ID);

  pwc->GUI->BorderLeft=leftedge;
  pwc->GUI->InnerWidth=width;

  if(!(pwc->GUI->LastGadget))
  {
    pwc->Hide(pwc);
    return(FALSE);
  }

  winleft=pwc->Prefs->GetLong(pwc->Prefs,"MainLeft",0);
  wintop=pwc->Prefs->GetLong(pwc->Prefs,"MainTop",1+pwc->Screen->BarHeight);

  if(!(pwc->Window=OpenWindowTags(NULL,WA_Left,winleft,
                                       WA_Top,wintop,
                                       WA_InnerWidth,pwc->GUI->InnerWidth,
                                       WA_InnerHeight,pwc->GUI->InnerHeight,
                                       WA_IDCMP,IDCMP_REFRESHWINDOW|IDCMP_CLOSEWINDOW|pwc->GUI->IDCMP,
                                       WA_SizeGadget,FALSE,WA_DragBar,TRUE,
                                       WA_DepthGadget,TRUE,WA_CloseGadget,TRUE,
                                       WA_NewLookMenus,TRUE,
                                       WA_Activate,FALSE,
                                       WA_Title,"FreeWheel V2.1",TAG_DONE)))
  {
    pwc->Hide(pwc);
    return(FALSE);
  }

  pwc->GUI->Attach(pwc->GUI,pwc->Window);

  pwc->Signals=1<<pwc->Window->UserPort->mp_SigBit;
  pwc->Signals|=pwc->ButtonWin->Signals;
  pwc->Signals|=pwc->ScrollWin->Signals;

  pwc->Visible=TRUE;
  return(TRUE);
}


void PrefsWin_Hide(struct PrefsWinContext *pwc)
{
  if(pwc->Window)
    CloseWindow(pwc->Window);
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

  if(pwc->ButtonWin)
    pwc->ButtonWin->Hide(pwc->ButtonWin);

  if(pwc->ScrollWin)
    pwc->ScrollWin->Hide(pwc->ScrollWin);

  pwc->Signals=0;
}


void PrefsWin_Dispose(struct PrefsWinContext *pwc)
{
  if(pwc)
  {
    if(pwc->Visible)
      pwc->Hide(pwc);
    if(pwc->ButtonWin)
      pwc->ButtonWin->Dispose(pwc->ButtonWin);
    if(pwc->ScrollWin)
      pwc->ScrollWin->Dispose(pwc->ScrollWin);
    free(pwc);
  }
}


struct PrefsWinContext *PrefsWin_Create(struct PrefsGroup *pg)
{
  struct PrefsWinContext *pwc;
  if(!(pwc=malloc(sizeof(struct PrefsWinContext))))
    return(NULL);
  memset(pwc,0,sizeof(struct PrefsWinContext));
  pwc->Dispose=PrefsWin_Dispose;
  pwc->Handle=PrefsWin_Handle;
  pwc->Hide=PrefsWin_Hide;
  pwc->Show=PrefsWin_Show;

  pwc->Prefs=pg;

  if(!(pwc->ButtonWin=ButtonWin_Create(pg)))
  {
    pwc->Dispose(pwc);
    return(NULL);
  }

  if(!(pwc->ScrollWin=ScrollWin_Create(pg)))
  {
    pwc->Dispose(pwc);
    return(NULL);
  }

  return(pwc);
}


BOOL PrefsWin_Handle(struct PrefsWinContext *pwc,unsigned long sigs)
{
  BOOL cont=TRUE,close=FALSE;
  long value;
  char *string;
  unsigned long mysigs=0;
  if(pwc)
  {
    if(pwc->Window)
      mysigs|=1<<pwc->Window->UserPort->mp_SigBit;
    if(sigs&mysigs)
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
              case HOTKEY_ID:
                GT_GetGadgetAttrs(gg,pwc->Window,NULL,GTST_String,&string,TAG_DONE);
                pwc->Prefs->SetString(pwc->Prefs,"Hot Key",string);
                MyCx->SetHotKey(MyCx,string);
                break;
              case XSPEED_ID:
                GT_GetGadgetAttrs(gg,pwc->Window,NULL,GTSL_Level,&value,TAG_DONE);
                pwc->Prefs->SetLong(pwc->Prefs,"XMouseSpeed",value);
                MyWM->MouseSpeedX=value;
                break;
              case YSPEED_ID:
                GT_GetGadgetAttrs(gg,pwc->Window,NULL,GTSL_Level,&value,TAG_DONE);
                pwc->Prefs->SetLong(pwc->Prefs,"YMouseSpeed",value);
                MyWM->MouseSpeedY=value;
                break;
              case CLICKFRONT_ID:
                GT_GetGadgetAttrs(gg,pwc->Window,NULL,GTCB_Checked,&value,TAG_DONE);
                pwc->Prefs->SetLong(pwc->Prefs,"ClickFront",value);
                MyWM->ClickToFront=value;
                break;
              case CLICKBACK_ID:
                GT_GetGadgetAttrs(gg,pwc->Window,NULL,GTCB_Checked,&value,TAG_DONE);
                pwc->Prefs->SetLong(pwc->Prefs,"ClickBack",value);
                MyWM->ClickToBack=value;
                break;
              case QUIT_ID:
                cont=FALSE;
                break;
              case HIDE_ID:
                close=TRUE;
                break;
              case SAVE_ID:
                pwc->Prefs->SetLong(pwc->Prefs,"MainTop",pwc->Window->TopEdge);
                pwc->Prefs->SetLong(pwc->Prefs,"MainLeft",pwc->Window->LeftEdge);
                if(pwc->ButtonWin->Window)
                {
                  pwc->Prefs->SetLong(pwc->Prefs,"ButtTop",pwc->ButtonWin->Window->TopEdge);
                  pwc->Prefs->SetLong(pwc->Prefs,"ButtLeft",pwc->Window->LeftEdge);
                }
                if(pwc->ScrollWin->Window)
                {
                  pwc->Prefs->SetLong(pwc->Prefs,"ScrollTop",pwc->ScrollWin->Window->TopEdge);
                  pwc->Prefs->SetLong(pwc->Prefs,"ScrollLeft",pwc->ScrollWin->Window->LeftEdge);
                }
                pwc->Prefs->Save(pwc->Prefs);
                break;
              case SETBUTTONS_ID:
                pwc->ButtonWin->Show(pwc->ButtonWin);
                break;
              case SETSCROLL_ID:
                pwc->ScrollWin->Show(pwc->ScrollWin);
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
    else
    {
      pwc->ButtonWin->Handle(pwc->ButtonWin,sigs);
      pwc->ScrollWin->Handle(pwc->ScrollWin,sigs);
    }
  }
  if(close)
    pwc->Hide(pwc);

  pwc->Signals=0;
  if(pwc->Window)
    pwc->Signals|=1<<pwc->Window->UserPort->mp_SigBit;
  pwc->Signals|=pwc->ButtonWin->Signals;
  pwc->Signals|=pwc->ScrollWin->Signals;

  return(cont);
}

