
struct ButtonWinContext
{
  void (*Dispose)(struct ButtonWinContext *pwc);
  BOOL (*Handle)(struct ButtonWinContext *pwc,unsigned long sigs);
  unsigned long Signals;
  BOOL (*Show)(struct ButtonWinContext *pwc);
  void (*Hide)(struct ButtonWinContext *pwc);
  struct PrefsGroup *Prefs;
  struct GUIContext *GUI;
  struct Window *Window;
  struct Screen *Screen;
  BOOL Visible;
};

struct ButtonWinContext *ButtonWin_Create(struct PrefsGroup *pg);


