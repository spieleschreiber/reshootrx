/****************************************************************************

  Support routines for dealing with a program's icon.
  Simplifies the handling  of Tooltypes, and generally helps
  keep things tidy.

  © 1998 by Alastair M. Robinson.

  You may use the routines in this file as you like.

****************************************************************************/

#include <exec/types.h>
#include <workbench/icon.h>
#include <workbench/startup.h>
#include <dos/dos.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/icon_protos.h>

#include "Icon.h"

        /* I hope you won't need this global variable. */

struct DiskObject *MyDiskObject;


        /* The C Startup code usually defines the Workbench Startup Messge,
           though your compiler might call it something other than WBenchMsg */

extern struct WBStartup *WBenchMsg;


/****************************************************************************
  This is just a stub to the icon.library MatchToolValue function.
  Use it like this:

  if(MatchToolType("CX_POPUP","YES"))
    OpenMyGUI();

****************************************************************************/

BOOL MatchToolType(char *tooltype,char *value)
{
  char *val2;
  if(val2=GetStringToolType(tooltype))
  {
    return(MatchToolValue(val2,value));
  }
  return(FALSE);
}


/****************************************************************************
  Another stub routine, written partly to accompany GetNumericToolType, but
  mostly so that external modules don't have to know about the MyDiskObject
  global variable.  It just tidies things up, and makes it easier to re-use
  the code.  Example usage:

  printf("ToolType Channel0 is set to %s\n",GetStringToolType("Channel0"));

****************************************************************************/

char *GetStringToolType(char *tooltype)
{
  return(FindToolType((unsigned char **)MyDiskObject->do_ToolTypes,tooltype));
}


/****************************************************************************
  Cute little support routine to translate from ASCII to integer.  Called
  by the GetNumericToolType() routine.  This is used instead of sscanf()
  simply to avoid the need to link with the standard C library, thus reducing
  the size of the final executable.  The second parameter, defvalue is the
  number which will be returned if the string pointer turns out not to point
  to a valid number!
****************************************************************************/

int Ascii2Num(char *str,int defvalue)
{
  char c;
  int v=0;
  while(c=*str++)
  {
    if((c<48)||(c>57))
      return(defvalue);
    v*=10; v+=c-48;
  }
  return(v);
}


/****************************************************************************
  This nice little routine hunts out a tooltype, and converts it from ASCII
  to an integer, returning defvalue if anything goes wrong.
  Example:

  mc->Left=GetNumericToolType("Left0",63);

****************************************************************************/

int GetNumericToolType(char *tooltype,int defvalue)
{
  char *value;
  if(value=FindToolType((unsigned char **)MyDiskObject->do_ToolTypes,tooltype))
  {
    defvalue=Ascii2Num(value,defvalue);
  }
  return(defvalue);
}


/****************************************************************************
  This routine just grabs the DiskObject associated with the program.
  This is actually harder than you might think  -  the current directory
  might not necessarily be the directory which contains the program and its
  icon, though this can probably be assumed when running from Workbench.
****************************************************************************/

BOOL Icon_Setup()
{
  char name[64];

  if(WBenchMsg)
  {
    struct WBArg *wb=WBenchMsg->sm_ArgList;
    if(!(MyDiskObject=GetDiskObject(wb->wa_Name)))
      return(FALSE);
  }
  else
  {
    BPTR oldlock;
    oldlock=CurrentDir(GetProgramDir());
    GetProgramName(name,64);
    MyDiskObject=GetDiskObject(name);
    CurrentDir(oldlock);
    if(!MyDiskObject)
      return(FALSE);
  }
  return(TRUE);
}


/****************************************************************************
  Much simpler routine to free everything (!) allocated by Icon_Setup().
****************************************************************************/

void Icon_Cleanup()
{
  if(MyDiskObject)
    FreeDiskObject(MyDiskObject);
}

