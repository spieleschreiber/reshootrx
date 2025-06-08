
struct ScrollWinContext
{
  void (*Dispose)(struct ScrollWinContext *pwc);
  BOOL (*Handle)(struct ScrollWinContext *pwc,unsigned long sigs);
  unsigned long Signals;
  BOOL (*Show)(struct ScrollWinContext *pwc);
  void (*Hide)(struct ScrollWinContext *pwc);
  struct PrefsGroup *Prefs;
  struct GUIContext *GUI;
  struct Window *Window;
  struct Screen *Screen;
  BOOL Visible;
};

struct ScrollWinContext *ScrollWin_Create(struct PrefsGroup *pg);


