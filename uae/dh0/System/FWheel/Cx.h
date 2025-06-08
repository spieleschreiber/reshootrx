
#include <libraries/commodities.h>

struct CxContext
{
  void (*Dispose)(struct CxContext *cx);
  BOOL (*Handle)(struct CxContext *cx,unsigned long signals);
  void (*ShowCallback)(struct CxContext *cx);
  void (*HideCallback)(struct CxContext *cx);
  BOOL (*SetHotKey)(struct CxContext *cx,char *hotkey);
  BOOL (*SetCustom)(struct CxContext *cx,void (*rout)(CxMsg *msg,CxObj *obj));
  void *UserData;
  struct MsgPort *Port;
  void *Broker;
  void *CustomObject;
  void *HotKey;
  unsigned long Signals;
};

struct CxContext *CxContext_Create(char *name,char *title,char *descr,void *userdata);

