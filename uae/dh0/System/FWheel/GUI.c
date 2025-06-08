
#include <stdlib.h>
#include <string.h>

#include <exec/types.h>
#include <libraries/gadtools.h>
#include <intuition/GadgetClass.h>
#include <intuition/Screens.h>

#include <clib/gadtools_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>

#include "GUI.h"

struct TextAttr GUI_DefaultFont = { "topaz.font", 8, 0, 0};

void GUI_Dispose(struct GUIContext *gui);


void GUI_Attach(struct GUIContext *gui,struct Window *win)
{
  AddGList(win,gui->ContextGadget,0,-1,NULL);
  RefreshGList(gui->ContextGadget,win,NULL,-1);
  GT_RefreshWindow(win, NULL);
}


struct Gadget *GUI_BuildButton(struct GUIContext *gui,char *text,long id)
{
  struct NewGadget newgad;
  int topedge,leftedge,textwidth,gadgetheight;

  if(gui->LastGadget)
  {
    textwidth=32+TextLength(&gui->Screen->RastPort,text,strlen(text));

    topedge=gui->BorderTop+gui->InnerHeight;
    leftedge=gui->BorderLeft+gui->InnerWidth/2-textwidth/2;
    gadgetheight=gui->TextAttr->ta_YSize+6;
    gui->InnerHeight+=8+gadgetheight;

    newgad.ng_TextAttr   = gui->TextAttr;
    newgad.ng_VisualInfo = gui->VisualInfo;
    newgad.ng_LeftEdge   = leftedge;
    newgad.ng_TopEdge    = topedge;
    newgad.ng_Width      = textwidth;
    newgad.ng_Height     = gadgetheight;
    newgad.ng_GadgetText = text;
    newgad.ng_GadgetID   = id;
    newgad.ng_Flags      = 0;

    gui->LastGadget = CreateGadget(BUTTON_KIND, gui->LastGadget, &newgad,
                             GA_RelVerify,TRUE,
                             TAG_DONE);
    gui->IDCMP|=BUTTONIDCMP;
  }
  return(gui->LastGadget);
}


struct Gadget *GUI_BuildWideButton(struct GUIContext *gui,char *text,long id)
{
  struct NewGadget newgad;
  int topedge,leftedge,textwidth,gadgetheight;

  if(gui->LastGadget)
  {
    textwidth=16+TextLength(&gui->Screen->RastPort,text,strlen(text));
    if(textwidth<(gui->InnerWidth-16))
      textwidth=gui->InnerWidth-16;
    else
      gui->InnerWidth=textwidth+16;
    topedge=gui->BorderTop+gui->InnerHeight;
    leftedge=gui->BorderLeft+gui->InnerWidth/2-textwidth/2;
    gadgetheight=gui->TextAttr->ta_YSize+6;
    gui->InnerHeight+=8+gadgetheight;

    newgad.ng_TextAttr   = gui->TextAttr;
    newgad.ng_VisualInfo = gui->VisualInfo;
    newgad.ng_LeftEdge   = leftedge;
    newgad.ng_TopEdge    = topedge;
    newgad.ng_Width      = textwidth;
    newgad.ng_Height     = gadgetheight;
    newgad.ng_GadgetText = text;
    newgad.ng_GadgetID   = id;
    newgad.ng_Flags      = 0;

    gui->LastGadget = CreateGadget(BUTTON_KIND, gui->LastGadget, &newgad,
                             GA_RelVerify,TRUE,
                             TAG_DONE);
    gui->IDCMP|=BUTTONIDCMP;
  }
  return(gui->LastGadget);
}


struct Gadget *GUI_BuildText(struct GUIContext *gui,char *text)
{
  struct NewGadget newgad;
  int topedge,leftedge,textwidth,gadgetheight;

  if(gui->LastGadget)
  {
    textwidth=32+TextLength(&gui->Screen->RastPort,text,strlen(text));
    if(textwidth<(gui->InnerWidth-16))
      textwidth=gui->InnerWidth-16;
    else
      gui->InnerWidth=textwidth+16;

    topedge=gui->BorderTop+gui->InnerHeight;
    leftedge=gui->BorderLeft+gui->InnerWidth/2-textwidth/2;
    gadgetheight=gui->TextAttr->ta_YSize+6;
    gui->InnerHeight+=gadgetheight+4;

    newgad.ng_TextAttr   = gui->TextAttr;
    newgad.ng_VisualInfo = gui->VisualInfo;
    newgad.ng_LeftEdge   = leftedge;
    newgad.ng_TopEdge    = topedge;
    newgad.ng_Width      = textwidth;
    newgad.ng_Height     = gadgetheight;
    newgad.ng_GadgetText = 0;
    newgad.ng_GadgetID   = 0;
    newgad.ng_Flags      = 0;

    gui->LastGadget = CreateGadget(TEXT_KIND, gui->LastGadget, &newgad,
                             GTTX_Border,FALSE,
                             GTTX_Text,text,
                             GTTX_Justification,GTJ_LEFT,
                             GTTX_Clipped,TRUE,
                             TAG_DONE);
    gui->IDCMP|=TEXTIDCMP;
  }
  return(gui->LastGadget);
}


struct Gadget *GUI_BuildCheckBox(struct GUIContext *gui,char *text,long id)
{
  struct NewGadget newgad;
  int topedge,leftedge,textwidth,guiwidth,gadgetwidth,gadgetheight;

  textwidth=0;
  if(gui->LastGadget)
  {
    gadgetwidth=gadgetheight=gui->TextAttr->ta_YSize+8;
    if(text)
      textwidth=8+TextLength(&gui->Screen->RastPort,text,strlen(text));
    if(gui->TabStop>textwidth)
      textwidth=gui->TabStop;
    if(textwidth>(gui->InnerWidth-16))
      gui->InnerWidth=textwidth+gadgetwidth+16;
    guiwidth=gui->InnerWidth-16;

    topedge=gui->BorderTop+gui->InnerHeight;
    leftedge=8+gui->BorderLeft+textwidth;
    gui->InnerHeight+=6+gadgetheight;

    newgad.ng_TextAttr   = gui->TextAttr;
    newgad.ng_VisualInfo = gui->VisualInfo;
    newgad.ng_LeftEdge   = leftedge;
    newgad.ng_TopEdge    = topedge;
    newgad.ng_Width      = gadgetwidth;
    newgad.ng_Height     = gadgetheight;
    newgad.ng_GadgetText = text;
    newgad.ng_GadgetID   = id;
    newgad.ng_Flags      = PLACETEXT_LEFT;

    gui->LastGadget = CreateGadget(CHECKBOX_KIND, gui->LastGadget, &newgad,
                             GA_RelVerify,TRUE,
                             GTCB_Scaled,TRUE,
                             TAG_DONE);
    gui->IDCMP|=CHECKBOXIDCMP;
  }
  return(gui->LastGadget);
}


struct Gadget *GUI_BuildSlider(struct GUIContext *gui,char *text,int min,int max,int level,long id)
{
  struct NewGadget newgad;
  int topedge,leftedge,textwidth,guiwidth,gadgetwidth,gadgetheight;

  textwidth=0;
  if(gui->LastGadget)
  {
    if(text)
      textwidth=8+TextLength(&gui->Screen->RastPort,text,strlen(text));
    if(gui->TabStop>textwidth)
      textwidth=gui->TabStop;
    if(textwidth>(gui->InnerWidth-16))
      gui->InnerWidth=textwidth+100;
    guiwidth=gui->InnerWidth-16;

    gadgetwidth=guiwidth-textwidth;
    topedge=gui->BorderTop+gui->InnerHeight;
    leftedge=8+gui->BorderLeft+textwidth;
    gadgetheight=gui->TextAttr->ta_YSize+8;
    gui->InnerHeight+=6+gadgetheight;

    newgad.ng_TextAttr   = gui->TextAttr;
    newgad.ng_VisualInfo = gui->VisualInfo;
    newgad.ng_LeftEdge   = leftedge;
    newgad.ng_TopEdge    = topedge;
    newgad.ng_Width      = gadgetwidth;
    newgad.ng_Height     = gadgetheight;
    newgad.ng_GadgetText = text;
    newgad.ng_GadgetID   = id;
    newgad.ng_Flags      = PLACETEXT_LEFT;

    gui->LastGadget = CreateGadget(SLIDER_KIND, gui->LastGadget, &newgad,
                             GA_RelVerify,TRUE,
                             GTSL_Min,min,
                             GTSL_Max,max,
                             GTSL_Level,level,
                             TAG_DONE);
    gui->IDCMP|=SLIDERIDCMP;
  }
  return(gui->LastGadget);
}


struct Gadget *GUI_BuildSliderFormatted(struct GUIContext *gui,char *text,int min,int max,int level,long id)
{
  struct NewGadget newgad;
  int topedge,leftedge,textwidth,guiwidth,gadgetwidth,gadgetheight;

  textwidth=0;
  if(gui->LastGadget)
  {
    if(text)
      textwidth=8+TextLength(&gui->Screen->RastPort,text,strlen(text));
    if(gui->TabStop>textwidth)
      textwidth=gui->TabStop;
    if(textwidth>(gui->InnerWidth-16))
      gui->InnerWidth=textwidth+100;
    guiwidth=gui->InnerWidth-16;

    gadgetwidth=guiwidth-textwidth;
    topedge=gui->BorderTop+gui->InnerHeight;
    leftedge=8+gui->BorderLeft+textwidth;
    gadgetheight=gui->TextAttr->ta_YSize+8;
    gui->InnerHeight+=6+gadgetheight;

    newgad.ng_TextAttr   = gui->TextAttr;
    newgad.ng_VisualInfo = gui->VisualInfo;
    newgad.ng_LeftEdge   = leftedge;
    newgad.ng_TopEdge    = topedge;
    newgad.ng_Width      = gadgetwidth;
    newgad.ng_Height     = gadgetheight;
    newgad.ng_GadgetText = NULL;
    newgad.ng_GadgetID   = id;
    newgad.ng_Flags      = PLACETEXT_LEFT;

    gui->LastGadget = CreateGadget(SLIDER_KIND, gui->LastGadget, &newgad,
                             GA_RelVerify,TRUE,
                             GTSL_Min,min,
                             GTSL_Max,max,
                             GTSL_Level,level,
                             GTSL_LevelFormat,text,
                             GTSL_MaxLevelLen,strlen(text)+4,
                             TAG_DONE);
    gui->IDCMP|=SLIDERIDCMP;
  }
  return(gui->LastGadget);
}


struct Gadget *GUI_BuildCycleGadget(struct GUIContext *gui,char *text,char **options,long id)
{
  struct NewGadget newgad;
  int topedge,leftedge,textwidth,gadgetheight,gadgetwidth,guiwidth;

  if(gui->LastGadget)
  {
    textwidth=gui->InnerWidth-16;

    if(text)
      textwidth=8+TextLength(&gui->Screen->RastPort,text,strlen(text));
    if(gui->TabStop>textwidth)
      textwidth=gui->TabStop;
    if(textwidth>(gui->InnerWidth-16))
      gui->InnerWidth=textwidth+GUI_MaxStringWidth(gui,options)+48;
    guiwidth=gui->InnerWidth-16;

    gadgetwidth=guiwidth-textwidth;
    topedge=gui->BorderTop+gui->InnerHeight;
    leftedge=8+gui->BorderLeft+textwidth;
    gadgetheight=gui->TextAttr->ta_YSize+8;
    gui->InnerHeight+=6+gadgetheight;

    newgad.ng_TextAttr   = gui->TextAttr;
    newgad.ng_VisualInfo = gui->VisualInfo;
    newgad.ng_LeftEdge   = leftedge;
    newgad.ng_TopEdge    = topedge;
    newgad.ng_Width      = gadgetwidth;
    newgad.ng_Height     = gadgetheight;
    newgad.ng_GadgetText = text;
    newgad.ng_GadgetID   = id;
    newgad.ng_Flags      = 0;

    gui->LastGadget = CreateGadget(CYCLE_KIND, gui->LastGadget, &newgad,
                         GA_RelVerify,TRUE,
                         GTCY_Labels,options,TAG_DONE);

    gui->IDCMP|=CYCLEIDCMP;
  }
  return(gui->LastGadget);
}


struct Gadget *GUI_BuildString(struct GUIContext *gui,char *text,int len,long id)
{
  struct NewGadget newgad;
  int topedge,leftedge,textwidth,guiwidth,gadgetwidth,gadgetheight;
  textwidth=0;
  if(gui->LastGadget)
  {
    if(text)
      textwidth=8+TextLength(&gui->Screen->RastPort,text,strlen(text));
    if(gui->TabStop>textwidth)
      textwidth=gui->TabStop;
    if(textwidth>(gui->InnerWidth-16))
      gui->InnerWidth=textwidth+100;
    guiwidth=gui->InnerWidth-16;

    gadgetwidth=guiwidth-textwidth;
    topedge=gui->BorderTop+gui->InnerHeight;
    leftedge=8+gui->BorderLeft+textwidth;
    gadgetheight=gui->TextAttr->ta_YSize+8;
    gui->InnerHeight+=6+gadgetheight;

    newgad.ng_TextAttr   = gui->TextAttr;
    newgad.ng_VisualInfo = gui->VisualInfo;
    newgad.ng_LeftEdge   = leftedge;
    newgad.ng_Width      = gadgetwidth;
    newgad.ng_TopEdge    = topedge;
    newgad.ng_Height     = gadgetheight;
    newgad.ng_GadgetText = text;
    newgad.ng_GadgetID   = id;
    newgad.ng_Flags      = 0;

    gui->LastGadget = CreateGadget(STRING_KIND, gui->LastGadget, &newgad,
                         GTST_MaxChars,len,TAG_DONE);

    gui->IDCMP|=STRINGIDCMP;
  }
  return(gui->LastGadget);
}


struct Gadget *GUI_BuildInteger(struct GUIContext *gui,char *text,int len,long id)
{
  struct NewGadget newgad;
  int topedge,leftedge,textwidth,gadgetheight;

  if(gui->LastGadget)
  {
    textwidth=gui->InnerWidth-16;

    topedge=gui->BorderTop+gui->InnerHeight;
    leftedge=gui->BorderLeft+gui->InnerWidth/2-textwidth/2;
    gadgetheight=gui->TextAttr->ta_YSize+6;
    gui->InnerHeight+=8+gadgetheight;

    newgad.ng_TextAttr   = gui->TextAttr;
    newgad.ng_VisualInfo = gui->VisualInfo;
    newgad.ng_LeftEdge   = leftedge+textwidth/3;
    newgad.ng_TopEdge    = topedge;
    newgad.ng_Width      = (2*textwidth)/3;
    newgad.ng_Height     = gadgetheight;
    newgad.ng_GadgetText = text;
    newgad.ng_GadgetID   = id;
    newgad.ng_Flags      = 0;

    gui->LastGadget = CreateGadget(INTEGER_KIND, gui->LastGadget, &newgad,
                             GTIN_MaxChars,len,TAG_DONE);
    gui->IDCMP|=INTEGERIDCMP;
  }
  return(gui->LastGadget);
}


struct GUIContext *GUI_Create(struct Screen *screen,struct TextAttr *ta,int initwidth,int initheight)
{
  struct GUIContext *gui;
  struct DrawInfo *mydri;
  if(!(gui=malloc(sizeof(struct GUIContext))))
    return(NULL);
  memset(gui,0,sizeof(struct GUIContext));

  gui->Dispose=GUI_Dispose;
  gui->Attach=GUI_Attach;
  gui->Screen=screen;
  if(ta)
    gui->TextAttr=ta;
  else
    gui->TextAttr=&GUI_DefaultFont;

  gui->BackgroundPen=0; gui->ShinePen=1; gui->ShadowPen=3; gui->ShinePen=4;
  if(mydri=GetScreenDrawInfo(screen))
  {
    gui->BackgroundPen=mydri->dri_Pens[BACKGROUNDPEN];
    gui->ShinePen=mydri->dri_Pens[SHINEPEN];
    gui->ShadowPen=mydri->dri_Pens[SHADOWPEN];
    gui->FillPen=mydri->dri_Pens[FILLPEN];
    FreeScreenDrawInfo(screen,mydri);
  }

  gui->InnerWidth=initwidth; gui->InnerHeight=initheight;
  gui->VisualInfo=GetVisualInfo(screen,TAG_DONE);
  gui->BorderLeft = screen->WBorLeft;
  gui->BorderRight = screen->WBorRight;
  gui->BorderBottom = screen->WBorBottom;
  gui->BorderTop = screen->WBorTop + (screen->Font->ta_YSize + 1);
  gui->TabStop=0;

  if(!(gui->ContextGadget = CreateContext(&gui->LastGadget)))
  {
    gui->Dispose(gui);
    return(NULL);
  }

  gui->IDCMP=IDCMP_REFRESHWINDOW|IDCMP_CLOSEWINDOW;

  return(gui);
}


void GUI_Dispose(struct GUIContext *gui)
{
  if(gui)
  {
    if(gui->ContextGadget)
      FreeGadgets(gui->ContextGadget);
    if(gui->VisualInfo)
      FreeVisualInfo(gui->VisualInfo);
    free(gui);
  }
}


int GUI_MaxStringWidth(struct GUIContext *gui,char **strings)
{
  int maxwidth=0,textwidth;
  char *string;
  if(strings)
  {
    while(string=*strings++)
    {
      textwidth=TextLength(&gui->Screen->RastPort,string,strlen(string));
      if(textwidth>maxwidth) maxwidth=textwidth;
    }
  }
  return(maxwidth);
}


void GUI_StringTab(struct GUIContext *gui,char **text)
{
  gui->TabStop=GUI_MaxStringWidth(gui,text)+8;
}

