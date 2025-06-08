#include <stdio.h>

#include <exec/types.h>

#include <intuition/intuitionbase.h>
#include <intuition/intuition.h>
#include <intuition/screens.h>
#include <graphics/clip.h>
#include <devices/inputevent.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/layers_protos.h>

#include "WheelMouse.h"

#include "Scroll.h"
#include "RawKey.h"

extern struct IntuitionBase *IntuitionBase;

struct Window *WindowUnderPointer();

#define MUIWHEEL_IS_MUI_WINDOW 0x20000929

/* Fixes reported CyberGuard hits with MUI programs. */
struct
{
  char a,b,c,d;
} DeadKeyData;


void SendIDCMP(struct WheelMouseContext *wmc,int class,int code,int qualifier,struct IntuiMessage *im)
{
  struct Window *win=wmc->Window;
  struct Gadget *gg=wmc->Gadget;
  im->IDCMPWindow=win;
  if(class==IDCMP_RAWKEY)
    im->IAddress=&DeadKeyData;
  else
    im->IAddress=gg;
  im->Class=class;
  im->Code=code;
  im->Qualifier=qualifier;
  im->MouseX=win->MouseX;
  im->MouseY=win->MouseY;
  im->ExecMessage.mn_ReplyPort=wmc->ReplyPort;
  im->Seconds=IntuitionBase->Seconds; im->Micros=IntuitionBase->Micros;
  im->SpecialLink=NULL;
  PutMsg(win->UserPort,(struct Message *)im);
}


void NudgePropGadget(struct WheelMouseContext *wmc,int axis,int direction)
{
  struct Window *win=wmc->Window;
  struct Gadget *gg=wmc->Gadget;
  struct PropInfo *pi=(struct PropInfo *)gg->SpecialInfo;

  long current,offset;

  if(axis&FREEVERT)
  {
    current=pi->VertPot;
    offset=(direction*pi->VPotRes*wmc->ScrollSpeedY)/32;
    if(wmc->VertSwap)
      offset=-offset;
    current+=offset;
    if(current<0) current=0;
    if(current>0xffff) current=0xffff;
    pi->VertPot=current;
  }

  if(axis&FREEHORIZ)
  {
    current=pi->HorizPot;
    offset=(direction*pi->HPotRes*wmc->ScrollSpeedX)/32;
    if(wmc->HorizSwap)
      offset=-offset;
    current+=offset;
    if(current<0) current=0;
    if(current>0xffff) current=0xffff;
    pi->HorizPot=current;
  }

}


struct Gadget *FindPropGadget(struct Window *win,long type)
{
  struct Gadget *gg=win->FirstGadget,*bestgadget=NULL;
  int gx,gy,gt,gl,gw,gh,dd,distance=32767;
  while(gg)
  {
    if(((gg->GadgetType&GTYP_GTYPEMASK)==GTYP_PROPGADGET)&&(gg->Flags&GFLG_DISABLED)==0)
    {
      struct PropInfo *pi=(struct PropInfo *)gg->SpecialInfo;
      if(pi)
      {
        if(pi->Flags&type)
        {
          dd=32767;

          gl=gg->LeftEdge; gt=gg->TopEdge;
          gw=gg->Width; gh=gg->Height;
          if(gg->Flags&GFLG_RELRIGHT)
            gl+=win->Width;
          if(gg->Flags&GFLG_RELBOTTOM)
            gt+=win->Height;
          if(gg->Flags&GFLG_RELWIDTH)
            gw+=win->Width;
          if(gg->Flags&GFLG_RELHEIGHT)
            gh+=win->Height;

          if(pi->Flags&FREEVERT)
          {
            gx=gl+gw;

            dd=gx-win->MouseX;
            if(dd<0)
              dd=-dd+win->Width; /* bias to left of scrollbar */
            gy=(gt+gh)-win->MouseY;
            if((gt-win->MouseY)*(gt-win->MouseY)<(gy*gy))
              gy=gt-win->MouseY;
            if(gy<0)
              gy=-gy;
            dd+=gy;
          }
          if(pi->Flags&FREEHORIZ)
          {
            if(type==(FREEHORIZ|FREEVERT))
            {
              gx=win->MouseX-gl;
              gy=win->MouseY-gt;
              if((gx>=-2)&&(gy>=-2)&&(gx<=(gw+2))&&(gy<=(gh+2)))
                dd=1;
            }
            else
            {
              gy=gt+gh;

              dd=gy-win->MouseY;
              if(dd<0)
                dd=-dd+win->Height; /* bias to top of scrollbar */
              gy=(gl+gw)-win->MouseX;
              if((gt-win->MouseX)*(gt-win->MouseX)<(gy*gy))
                gy=gt-win->MouseX;
              if(gy<0)
                gy=-gy;
              dd+=gy;
            }
          }
          if(dd<0) dd=-dd;
          if(dd<distance)
          {
            distance=dd;
            bestgadget=gg;
          }
        }
      }
    }
    gg=gg->NextGadget;
  }
  return(bestgadget);
}


int DoScroll(struct WheelMouseContext *wmc,int axis,int direction)
{
  struct Window *win;
  unsigned long userdata;

  Forbid();
  if(wmc->WindowMode==OverWindow)
    win=wmc->Window=WindowUnderPointer();
  else
    win=wmc->Window=IntuitionBase->ActiveWindow;
  if(!(win))
    return(direction);
  wmc->Gadget=FindPropGadget(win,axis);
  if((!(wmc->Gadget))&&(wmc->WindowMode==OverWindow)&&((win->IDCMPFlags&IDCMP_RAWKEY)==0))
  {
    if(!(win=wmc->Window=IntuitionBase->ActiveWindow))
    {
      Permit();
      return(direction);
    }
    wmc->Gadget=FindPropGadget(win,axis);
  }

  /* Ignore MUI windows if MUIWheel is active... */
  userdata=(unsigned long)win->UserData;
  if((userdata==MUIWHEEL_IS_MUI_WINDOW)&&(wmc->IgnoreMUI))
  {
    Permit();
    return(direction);
  }

  if((wmc->Gadget)&&(wmc->NudgeProp))
  {
    if(win->UserPort->mp_SigTask!=wmc->MainTask)
    {
      NudgePropGadget(wmc,axis,direction);
      SendIDCMP(wmc,IDCMP_GADGETDOWN,0,0,&wmc->Msg1.eim_IntuiMessage);
      SendIDCMP(wmc,IDCMP_GADGETUP,0,0,&wmc->Msg2.eim_IntuiMessage);
      RefreshGList(wmc->Gadget,wmc->Window,NULL,1);
      Permit();
      WaitPort(wmc->ReplyPort);
      GetMsg(wmc->ReplyPort);
      WaitPort(wmc->ReplyPort);
      GetMsg(wmc->ReplyPort);
    }
    else
      Permit();
    return(direction);
  }
  else if((win->IDCMPFlags&IDCMP_RAWKEY)&&(wmc->ForgeRawKey))
  {
    int code,d,q=0;
    d=direction;
    if((axis==FREEHORIZ)&&(wmc->HorizSwap))
      d=-d;
    if((axis&FREEVERT)&&(wmc->VertSwap))
      d=-d;
    if(d>0)
    {
      if(axis&FREEVERT)
        code=RK_Down;
      else
        code=RK_Right;
    }
    else
    {
      if(axis&FREEVERT)
        code=RK_Up;
      else
        code=RK_Left;
      d=-d;
    }
    if((d>wmc->PageThreshold)&&(wmc->RawKeyPage))
      q=IEQUALIFIER_LSHIFT;
    else
      direction/=d; /* either 1 or -1 */

    if(win->UserPort->mp_SigTask!=wmc->MainTask)
    {
      SendIDCMP(wmc,IDCMP_RAWKEY,code,q,&wmc->Msg1.eim_IntuiMessage);
      SendIDCMP(wmc,IDCMP_RAWKEY,code|IECODE_UP_PREFIX,q,&wmc->Msg2.eim_IntuiMessage);
      Permit();
      WaitPort(wmc->ReplyPort);
      GetMsg(wmc->ReplyPort);
      WaitPort(wmc->ReplyPort);
      GetMsg(wmc->ReplyPort);
    }
    else
      Permit();
    return(direction);
  }
  Permit();
  return(direction);
}


struct Window *WindowUnderPointer()
{
  int x,y;
  struct Window *win=NULL;
  struct Screen *scr;
  struct Layer *layer;

  scr=IntuitionBase->FirstScreen;
  do
  {
    x=scr->MouseX; y=scr->MouseY;
    if((x<0) || (y<0))
      scr=scr->NextScreen;
  } while((scr!=NULL) && ((x<0)||(y<0)));

  if(!scr)
    return(NULL);

  layer=WhichLayer(&scr->LayerInfo,x,y);
  if(layer)
    win=layer->Window;
  return(win);
}

