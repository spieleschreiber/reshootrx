
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <exec/types.h>
#include <intuition/intuition.h>
#include <intuition/screens.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>

#include "Prefs.h"
#include "GUI.h"
#include "WheelMouse.h"

#include "ScrollWin.h"

#define HSCROLL_ID 1
#define VSCROLL_ID 2
#define NUDGEPROP_ID 3
#define FORGERAWKEY_ID 4
#define RAWKEYPAGE_ID 5
#define PAGETHRESHOLD_ID 6
#define FAKESCROLLSPEED_ID 7
#define WINDOWMODE_ID 8
#define HORIZSWAP_ID 9
#define VERTSWAP_ID 10
#define IGNOREMUI_ID 11

BOOL ScrollWin_Show(struct ScrollWinContext *pwc);
void ScrollWin_Hide(struct ScrollWinContext *pwc);
BOOL ScrollWin_Handle(struct ScrollWinContext *pwc,unsigned long sigs);
void ScrollWin_Dispose(struct ScrollWinContext *pwc);

extern struct WheelMouseContext *MyWM;

char *SWinGadTitles[]=
{
  "Prop Gadgets:",
  "H Speed:",
  "V Speed:",
  "Move->Scroll speed:",
  "Enabled:",
  "Shift paging:",
  "Page after %ld lines ",
  "Keypresses:",
  "Scroll Window:",
  "Mirror H Scroll:",
  "Mirror V Scroll:",
  "Ignore MUI:",
  NULL
};

#define PROPGADGETS_TITLE 0
#define HORIZSPEED_TITLE 1
#define VERTSPEED_TITLE 2
#define FAKESCROLLSPEED_TITLE 3
#define ENABLED_TITLE 4
#define KEYPAGING_TITLE 5
#define PAGETHRESHOLD_TITLE 6
#define KEYPRESSES_TITLE 7
#define WINDOWMODE_TITLE 8
#define HORIZSWAP_TITLE 9
#define VERTSWAP_TITLE 10
#define IGNOREMUI_TITLE 11

BOOL ScrollWin_Show(struct ScrollWinContext *pwc)
{
  struct Gadget *gg;
  int width,width2,topedge,tabstop;
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

  GUI_StringTab(pwc->GUI,SWinGadTitles);

  width=GUI_MaxStringWidth(pwc->GUI,MyWM->MidButton.ClickModeNames);
  width2=GUI_MaxStringWidth(pwc->GUI,MyWM->MidButton.DoubleClickModeNames);
  if(width2>width) width=width2;
  width2=GUI_MaxStringWidth(pwc->GUI,MyWM->MidButton.ClickRollModeNames);
  if(width2>width) width=width2;

  pwc->GUI->InnerWidth=pwc->GUI->TabStop+width+64;

  gg=GUI_BuildCycleGadget(pwc->GUI,SWinGadTitles[WINDOWMODE_TITLE],MyWM->WindowModeNames,WINDOWMODE_ID);
  GT_SetGadgetAttrs(gg,NULL,NULL,GTCY_Active,
                    pwc->Prefs->GetLong(pwc->Prefs,"WindowMode",0),TAG_DONE);

  gg=GUI_BuildSlider(pwc->GUI,SWinGadTitles[FAKESCROLLSPEED_TITLE],1,32,17,FAKESCROLLSPEED_ID);
  GT_SetGadgetAttrs(gg,NULL,NULL,GTSL_Level,
                    pwc->Prefs->GetLong(pwc->Prefs,"FakeScrollSpeed",17),TAG_DONE);

  topedge=pwc->GUI->InnerHeight;

  gg=GUI_BuildCheckBox(pwc->GUI,SWinGadTitles[HORIZSWAP_TITLE],HORIZSWAP_ID);
  GT_SetGadgetAttrs(gg,NULL,NULL,GTCB_Checked,
                    pwc->Prefs->GetLong(pwc->Prefs,"HorizSwap",FALSE),TAG_DONE);

  pwc->GUI->InnerHeight=topedge;
  tabstop=pwc->GUI->TabStop;

  pwc->GUI->TabStop=pwc->GUI->InnerWidth;
  pwc->GUI->TabStop-=gg->Width+8+pwc->GUI->BorderLeft+pwc->GUI->BorderRight;

  gg=GUI_BuildCheckBox(pwc->GUI,SWinGadTitles[VERTSWAP_TITLE],VERTSWAP_ID);
  GT_SetGadgetAttrs(gg,NULL,NULL,GTCB_Checked,
                    pwc->Prefs->GetLong(pwc->Prefs,"VertSwap",FALSE),TAG_DONE);

  pwc->GUI->TabStop=tabstop;

  gg=GUI_BuildCheckBox(pwc->GUI,SWinGadTitles[IGNOREMUI_TITLE],IGNOREMUI_ID);
  GT_SetGadgetAttrs(gg,NULL,NULL,GTCB_Checked,
                    pwc->Prefs->GetLong(pwc->Prefs,"IgnoreMUI",TRUE),TAG_DONE);

  pwc->GUI->InnerHeight+=6;

  gg=GUI_BuildCheckBox(pwc->GUI,SWinGadTitles[PROPGADGETS_TITLE],NUDGEPROP_ID);
  GT_SetGadgetAttrs(gg,NULL,NULL,GTCB_Checked,
                    pwc->Prefs->GetLong(pwc->Prefs,"NudgeProp",TRUE),TAG_DONE);

  gg=GUI_BuildSlider(pwc->GUI,SWinGadTitles[HORIZSPEED_TITLE],1,32,17,HSCROLL_ID);
  GT_SetGadgetAttrs(gg,NULL,NULL,GTSL_Level,
                    pwc->Prefs->GetLong(pwc->Prefs,"XScrollSpeed",17),TAG_DONE);

  gg=GUI_BuildSlider(pwc->GUI,SWinGadTitles[VERTSPEED_TITLE],1,32,17,VSCROLL_ID);
  GT_SetGadgetAttrs(gg,NULL,NULL,GTSL_Level,
                    pwc->Prefs->GetLong(pwc->Prefs,"YScrollSpeed",17),TAG_DONE);

  pwc->GUI->InnerHeight+=6;

  topedge=pwc->GUI->InnerHeight;

  gg=GUI_BuildCheckBox(pwc->GUI,SWinGadTitles[KEYPRESSES_TITLE],FORGERAWKEY_ID);
  GT_SetGadgetAttrs(gg,NULL,NULL,GTCB_Checked,
                    pwc->Prefs->GetLong(pwc->Prefs,"ForgeRawKey",TRUE),TAG_DONE);

  tabstop=pwc->GUI->TabStop;
  pwc->GUI->InnerHeight=topedge;

  pwc->GUI->TabStop=pwc->GUI->InnerWidth;
  pwc->GUI->TabStop-=gg->Width+8+pwc->GUI->BorderLeft+pwc->GUI->BorderRight;

  gg=GUI_BuildCheckBox(pwc->GUI,SWinGadTitles[KEYPAGING_TITLE],RAWKEYPAGE_ID);
  GT_SetGadgetAttrs(gg,NULL,NULL,GTCB_Checked,
                    pwc->Prefs->GetLong(pwc->Prefs,"RawKeyPage",TRUE),TAG_DONE);

  pwc->GUI->TabStop=tabstop;

  gg=GUI_BuildSliderFormatted(pwc->GUI,SWinGadTitles[PAGETHRESHOLD_TITLE],1,12,4,PAGETHRESHOLD_ID);
  GT_SetGadgetAttrs(gg,NULL,NULL,GTSL_Level,
                    pwc->Prefs->GetLong(pwc->Prefs,"PageThreshold",4),TAG_DONE);


  if(!(pwc->GUI->LastGadget))
  {
    pwc->Hide(pwc);
    return(FALSE);
  }

  winleft=pwc->Prefs->GetLong(pwc->Prefs,"ScrollLeft",0);
  wintop=pwc->Prefs->GetLong(pwc->Prefs,"ScrollTop",1+pwc->Screen->BarHeight);

  if(!(pwc->Window=OpenWindowTags(NULL,WA_Left,winleft,
                                       WA_Top,wintop,
                                       WA_InnerWidth,pwc->GUI->InnerWidth,
                                       WA_InnerHeight,pwc->GUI->InnerHeight,
                                       WA_IDCMP,IDCMP_REFRESHWINDOW|IDCMP_CLOSEWINDOW|pwc->GUI->IDCMP,
                                       WA_SizeGadget,FALSE,WA_DragBar,TRUE,
                                       WA_DepthGadget,TRUE,WA_CloseGadget,TRUE,
                                       WA_NewLookMenus,TRUE,
                                       WA_Activate,FALSE,
                                       WA_Title,"Scrolling settings...",TAG_DONE)))
  {
    pwc->Hide(pwc);
    return(FALSE);
  }

  pwc->GUI->Attach(pwc->GUI,pwc->Window);

  pwc->Signals=1<<pwc->Window->UserPort->mp_SigBit;

  pwc->Visible=TRUE;
  return(TRUE);
}


void ScrollWin_Hide(struct ScrollWinContext *pwc)
{
  if(pwc->Window)
  {
    pwc->Prefs->SetLong(pwc->Prefs,"ScrollTop",pwc->Window->TopEdge);
    pwc->Prefs->SetLong(pwc->Prefs,"ScrollLeft",pwc->Window->LeftEdge);
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


void ScrollWin_Dispose(struct ScrollWinContext *pwc)
{
  if(pwc)
  {
    if(pwc->Visible)
      pwc->Hide(pwc);
    free(pwc);
  }
}


struct ScrollWinContext *ScrollWin_Create(struct PrefsGroup *pg)
{
  struct ScrollWinContext *pwc;
  if(!(pwc=malloc(sizeof(struct ScrollWinContext))))
    return(NULL);
  memset(pwc,0,sizeof(struct ScrollWinContext));
  pwc->Dispose=ScrollWin_Dispose;
  pwc->Handle=ScrollWin_Handle;
  pwc->Hide=ScrollWin_Hide;
  pwc->Show=ScrollWin_Show;

  pwc->Prefs=pg;

  return(pwc);
}


BOOL ScrollWin_Handle(struct ScrollWinContext *pwc,unsigned long sigs)
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
              case HSCROLL_ID:
                GT_GetGadgetAttrs(gg,pwc->Window,NULL,GTSL_Level,&value,TAG_DONE);
                pwc->Prefs->SetLong(pwc->Prefs,"XScrollSpeed",value);
                MyWM->ScrollSpeedX=value;
                break;
              case VSCROLL_ID:
                GT_GetGadgetAttrs(gg,pwc->Window,NULL,GTSL_Level,&value,TAG_DONE);
                pwc->Prefs->SetLong(pwc->Prefs,"YScrollSpeed",value);
                MyWM->ScrollSpeedY=value;
                break;
              case FAKESCROLLSPEED_ID:
                GT_GetGadgetAttrs(gg,pwc->Window,NULL,GTSL_Level,&value,TAG_DONE);
                pwc->Prefs->SetLong(pwc->Prefs,"FakeScrollSpeed",value);
                MyWM->FakeScrollSpeed=value;
                break;
              case PAGETHRESHOLD_ID:
                GT_GetGadgetAttrs(gg,pwc->Window,NULL,GTSL_Level,&value,TAG_DONE);
                pwc->Prefs->SetLong(pwc->Prefs,"PageThreshold",value);
                MyWM->PageThreshold=value;
                break;
              case NUDGEPROP_ID:
                GT_GetGadgetAttrs(gg,pwc->Window,NULL,GTCB_Checked,&value,TAG_DONE);
                pwc->Prefs->SetLong(pwc->Prefs,"NudgeProp",value);
                MyWM->NudgeProp=value;
                break;
              case FORGERAWKEY_ID:
                GT_GetGadgetAttrs(gg,pwc->Window,NULL,GTCB_Checked,&value,TAG_DONE);
                pwc->Prefs->SetLong(pwc->Prefs,"ForgeRawKey",value);
                MyWM->ForgeRawKey=value;
                break;
              case RAWKEYPAGE_ID:
                GT_GetGadgetAttrs(gg,pwc->Window,NULL,GTCB_Checked,&value,TAG_DONE);
                pwc->Prefs->SetLong(pwc->Prefs,"RawKeyPage",value);
                MyWM->RawKeyPage=value;
                break;
              case WINDOWMODE_ID:
                GT_GetGadgetAttrs(gg,pwc->Window,NULL,GTCY_Active,&value,TAG_DONE);
                pwc->Prefs->SetLong(pwc->Prefs,"WindowMode",value);
                MyWM->WindowMode=value;
                break;
              case HORIZSWAP_ID:
                GT_GetGadgetAttrs(gg,pwc->Window,NULL,GTCB_Checked,&value,TAG_DONE);
                pwc->Prefs->SetLong(pwc->Prefs,"HorizSwap",value);
                MyWM->HorizSwap=value;
                break;
              case VERTSWAP_ID:
                GT_GetGadgetAttrs(gg,pwc->Window,NULL,GTCB_Checked,&value,TAG_DONE);
                pwc->Prefs->SetLong(pwc->Prefs,"VertSwap",value);
                MyWM->VertSwap=value;
                break;
              case IGNOREMUI_ID:
                GT_GetGadgetAttrs(gg,pwc->Window,NULL,GTCB_Checked,&value,TAG_DONE);
                pwc->Prefs->SetLong(pwc->Prefs,"IgnoreMUI",value);
                MyWM->IgnoreMUI=value;
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

