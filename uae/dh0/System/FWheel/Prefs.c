
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <exec/types.h>

enum PrefsNodeTypes {TYPE_LONG,TYPE_STRING};
struct PrefsNode
{
  long Match1,Match2;
  enum PrefsNodeTypes Type;
  struct PrefsNode *Next,*Prev;
  long Data; /* String length if Type==TYPE_STRING */
};


#include "Prefs.h"

void Prefs_DigestID(char *str,unsigned long *id1,unsigned long *id2);
BOOL Prefs_MatchID(char *str,unsigned long id1,unsigned long id2);

void PrefsGroup_Dispose(struct PrefsGroup *pg);
BOOL PrefsGroup_Save(struct PrefsGroup *pg);
char *PrefsGroup_GetString(struct PrefsGroup *pg,char *ItemID,char *def);
long PrefsGroup_GetLong(struct PrefsGroup *pg,char *ItemID,long def);
BOOL PrefsGroup_SetString(struct PrefsGroup *pg,char *ItemID,char *data);
BOOL PrefsGroup_SetLong(struct PrefsGroup *pg,char *ItemID,long data);

struct PrefsNode *PrefsGroup_GetNode(struct PrefsGroup *pg,char *ItemID);

struct PrefsGroup *Prefs_GetGroup(char *GroupID);

void Prefs_DigestID(char *str,unsigned long *id1,unsigned long *id2)
{
  unsigned long id; int i,l;
  *id1=0; *id2=0;
  l=strlen(str);
  if(l>8) l=8;
  if(l>4)
  {
    id=0;
    for(i=0;i<4;++i) { id<<=8; id|=255&(*str++); }
    *id1=id; l-=4; id=0;
    for(i=0;i<l;++i) { id<<=8; id|=255&(*str++); }
    id<<=8*(4-l); *id2=id;
  }
  else
  {
    id=0;
    for(i=0;i<l;++i) { id<<=8; id|=255&(*str++); }
    id<<=8*(4-l); *id1=id; *id2=0;
  }
}


BOOL Prefs_MatchID(char *str,unsigned long id1,unsigned long id2)
{
  unsigned long id3,id4;
  Prefs_DigestID(str,&id3,&id4);
  id1&=0xdfdfdfdf; id2&=0xdfdfdfdf;
  id3&=0xdfdfdfdf; id4&=0xdfdfdfdf; /* Make test case-insensitive */
  if(id1!=id3) return(FALSE);
  if(id2!=id4) return(FALSE);
  return(TRUE);
}


struct PrefsGroup *Prefs_GetGroup(char *GroupID)
{
  struct PrefsGroup *pg;
  char *dest;
  FILE *fp;
  if(pg=malloc(sizeof(struct PrefsGroup)))
  {
    memset(pg,0,sizeof(struct PrefsGroup));
    pg->Dispose=PrefsGroup_Dispose;
    pg->Save=PrefsGroup_Save;
    pg->GetString=PrefsGroup_GetString;
    pg->GetLong=PrefsGroup_GetLong;
    pg->SetString=PrefsGroup_SetString;
    pg->SetLong=PrefsGroup_SetLong;
    pg->GetNode=PrefsGroup_GetNode;
    pg->FirstNode=NULL;
    dest=pg->Name;
    while(*dest++=*GroupID++);
  }
  if(fp=fopen(pg->Name,"rb"))
  {
    struct PrefsNode MyNode;
    while(fread(&MyNode,sizeof(struct PrefsNode),1,fp)==1)
    {
      char MyString[256];
      char ItemID[9]={0,0,0,0,0,0,0,0,0};
      unsigned long *ptr=(unsigned long *)ItemID;
      *ptr++=MyNode.Match1; *ptr++=MyNode.Match2;
      if(MyNode.Type==TYPE_STRING)
      {
        fread(&MyString,MyNode.Data,1,fp);
        pg->SetString(pg,ItemID,MyString);
      }
      else
        pg->SetLong(pg,ItemID,MyNode.Data);
    }
    fclose(fp);
  }
  return(pg);
}


void PrefsGroup_Dispose(struct PrefsGroup *pg)
{
  if(pg)
  {
    if(pg->FirstNode)
    {
      struct PrefsNode *node,*next;
      node=pg->FirstNode;
      while(node)
      {
        next=node->Next;
        free(node);
        node=next;
      }
    }
    free(pg);
  }
}


BOOL PrefsGroup_Save(struct PrefsGroup *pg)
{
  FILE *fp;
  if(fp=fopen(pg->Name,"wb"))
  {
    struct PrefsNode *pn;
    size_t size;
    pn=pg->FirstNode;
    while(pn)
    {
      size=sizeof(struct PrefsNode);
      if(pn->Type==TYPE_STRING)
        size+=pn->Data;
      fwrite(pn,size,1,fp);
      pn=pn->Next;
    }
    fclose(fp);
  }
  return(FALSE);
}


char *PrefsGroup_GetString(struct PrefsGroup *pg,char *ItemID,char *def)
{
  struct PrefsNode *pn;
  if(pn=pg->GetNode(pg,ItemID))
    if(pn->Type==TYPE_STRING)
      return(((char *)pn)+sizeof(struct PrefsNode));
  return(def);
}


long PrefsGroup_GetLong(struct PrefsGroup *pg,char *ItemID,long def)
{
  struct PrefsNode *pn;
  if(pn=pg->GetNode(pg,ItemID))
    if(pn->Type==TYPE_LONG)
      return(pn->Data);
  return(def);
}


BOOL PrefsGroup_SetString(struct PrefsGroup *pg,char *ItemID,char *data)
{
  struct PrefsNode *pn;
  char *dest;
  unsigned long id1,id2;
  if(pn=pg->GetNode(pg,ItemID))
  {
    if(pn->Prev)
      pn->Prev->Next=pn->Next;
    else
      pg->FirstNode=pn->Next;
    if(pn->Next)
      pn->Next->Prev=pn->Prev;
    free(pn);
  }
  pn=malloc(sizeof(struct PrefsNode)+1+strlen(data));
  if(!(pn))
    return(FALSE);
  pn->Type=TYPE_STRING;
  Prefs_DigestID(ItemID,&id1,&id2);
  pn->Match1=id1; pn->Match2=id2;
  pn->Data=strlen(data)+1;
  pn->Prev=NULL;
  if(pg->FirstNode)
    pg->FirstNode->Prev=pn;
  pn->Next=pg->FirstNode;
  pg->FirstNode=pn;
  dest=((char *)pn)+sizeof(struct PrefsNode);
  while(*dest++=*data++);
  return(TRUE);
}


BOOL PrefsGroup_SetLong(struct PrefsGroup *pg,char *ItemID,long data)
{
  struct PrefsNode *pn;
  unsigned long id1,id2;
  if(pn=pg->GetNode(pg,ItemID))
  {
    if(pn->Prev)
      pn->Prev->Next=pn->Next;
    else
      pg->FirstNode=pn->Next;
    if(pn->Next)
      pn->Next->Prev=pn->Prev;
    free(pn);
  }
  pn=malloc(sizeof(struct PrefsNode));
  if(!(pn))
    return(FALSE);
  pn->Type=TYPE_LONG;
  Prefs_DigestID(ItemID,&id1,&id2);
  pn->Match1=id1; pn->Match2=id2;
  pn->Data=data;
  pn->Prev=NULL;
  if(pg->FirstNode)
    pg->FirstNode->Prev=pn;
  pn->Next=pg->FirstNode;
  pg->FirstNode=pn;
  return(TRUE);
}


struct PrefsNode *PrefsGroup_GetNode(struct PrefsGroup *pg,char *ItemID)
{
  struct PrefsNode *pn=pg->FirstNode;
  while(pn)
  {
    if(Prefs_MatchID(ItemID,pn->Match1,pn->Match2))
      return(pn);
    pn=pn->Next;
  }
  return(NULL);
}


