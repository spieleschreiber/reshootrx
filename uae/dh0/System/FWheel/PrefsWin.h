
struct PrefsWinContext
{
  void (*Dispose)(struct PrefsWinContext *pwc);
  BOOL (*Handle)(struct PrefsWinContext *pwc,unsigned long sigs);
  unsigned long Signals;
  BOOL (*Show)(struct PrefsWinContext *pwc);
  void (*Hide)(struct PrefsWinContext *pwc);
  struct PrefsGroup *Prefs;
  struct GUIContext *GUI;
  struct Window *Window;
  struct Screen *Screen;
  BOOL Visible;
  struct ButtonWinContext *ButtonWin;
  struct ScrollWinContext *ScrollWin;
};

struct PrefsWinContext *PrefsWin_Create(struct PrefsGroup *pg);


