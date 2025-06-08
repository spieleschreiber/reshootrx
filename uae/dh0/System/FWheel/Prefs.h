#ifndef PREFS_H
#define PREFS_H

struct PrefsGroup
{
  void (*Dispose)(struct PrefsGroup *pg);
  BOOL (*Save)(struct PrefsGroup *pg);
  char *(*GetString)(struct PrefsGroup *pg,char *ItemID,char *def);
  long (*GetLong)(struct PrefsGroup *pg,char *ItemID,long def);
  BOOL (*SetString)(struct PrefsGroup *pg,char *ItemID,char *data);
  BOOL (*SetLong)(struct PrefsGroup *pg,char *ItemID,long data);
  /* Everything past this point is private! */
  struct PrefsNode *(*GetNode)(struct PrefsGroup *pg,char *ItemID);
  struct PrefsGroup *Next,*Prev;
  struct PrefsNode *FirstNode;
  char Name[32];
};

struct PrefsGroup *Prefs_GetGroup(char *GroupID);

#endif

