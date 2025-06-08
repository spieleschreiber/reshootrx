
struct GUIContext
{
  void (*Dispose)(struct GUIContext *gui);
  void (*Attach)(struct GUIContext *gui,struct Window *win);
  int BorderTop,BorderLeft;
  int BorderRight,BorderBottom;
  int InnerWidth,InnerHeight;
  int TabStop;
  void *VisualInfo;
  struct Gadget *ContextGadget,*LastGadget;
  struct Window *Window;
  int BackgroundPen,ShinePen,ShadowPen,FillPen;
  struct Screen *Screen;
  struct TextAttr *TextAttr;
  ULONG IDCMP;
};

struct GUIContext *GUI_Create(struct Screen *screen,struct TextAttr *ta,int initwidth,int initheight);

struct Gadget *GUI_BuildButton(struct GUIContext *gui,char *text,long id);
struct Gadget *GUI_BuildWideButton(struct GUIContext *gui,char *text,long id);
struct Gadget *GUI_BuildText(struct GUIContext *gui,char *text);
struct Gadget *GUI_BuildCheckBox(struct GUIContext *gui,char *text,long id);
struct Gadget *GUI_BuildSlider(struct GUIContext *gui,char *text,int min,int max,int level,long id);
struct Gadget *GUI_BuildSliderFormatted(struct GUIContext *gui,char *text,int min,int max,int level,long id);
struct Gadget *GUI_BuildCycleGadget(struct GUIContext *gui,char *text,char **options,long id);
struct Gadget *GUI_BuildString(struct GUIContext *gui,char *text,int len,long id);
struct Gadget *GUI_BuildInteger(struct GUIContext *gui,char *text,int len,long id);

int GUI_MaxStringWidth(struct GUIContext *gui,char **strings);
void GUI_StringTab(struct GUIContext *gui,char **text);

