/*
 * -----------------------------------
 *
 *	Program title:		PeelNewTools
 *	Author:						Erik Østlyngen
 *	Version:					1.5
 *
 * -----------------------------------
 */

#define ARRAYSIZE 1000

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <exec/types.h>
#include <exec/memory.h>
#include <libraries/dos.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/icon_protos.h>
#include <dos/rdargs.h>

char version[]="VER: PeelNewTools V1.5";
char filename[40];
char longdirname[160];
char template[]="File/A/M,R=Recursive/S,L=Log/S";
LONG argarray[4];
char **newtools;
struct RDArgs *rdargs;

#define TMP_FILES 0
#define TMP_REC 1
#define TMP_LOG 2

BOOL infoname(char *name)
{
	int length=strlen(name);

	if(strlen(name)<5)
		return(FALSE);
	if(stricmp(name+length-5,".info"))
		return(FALSE);
	return(TRUE);
}

void pferror( void )
{
		PrintFault(IoErr(),"ERROR");
}

void safeexit(int x)
{
	if(newtools)
		FreeMem(newtools,ARRAYSIZE);

	FreeArgs(rdargs);
	exit(x);
}

int cleantools(char *filename)
{
	struct DiskObject *icon;
	char **tools1,**tools2,**oldtools;
	int error=0;

	if(!(icon=GetDiskObject(filename))) {
		printf("ERROR: Failed reading info file\n");
		return(5);
	}

	if(tools1=oldtools=icon->do_ToolTypes) {
		tools2=newtools;

		while(*tools1)
			if(stpblk(*tools1)[0]==0)
				tools1++;
			else
				if(!(strncmp(*tools1,"IM1=",4))) {
					tools1++;
				}
				else
					if(!(strncmp(*tools1,"IM2=",4))) {
						tools1++;
					}
					else
						if(!(strcmp(*tools1,"*** DON'T EDIT THE FOLLOWING LINES!! ***"))) {
							tools1++;
						}
						else
							*(tools2++)=*(tools1++);

		*tools2=NULL;

		icon->do_ToolTypes=newtools;
		if(!(PutDiskObject(filename,icon))) {
			printf("ERROR: Failed writing info file\n");
			error=5;
		}

		icon->do_ToolTypes=oldtools;
	}

	FreeDiskObject(icon);
	return(error);
}

void exitscan(BPTR oldlock,BPTR dirlock,struct FileInfoBlock *fblock)
{
	if(oldlock)
		CurrentDir(oldlock);
	FreeMem(fblock,sizeof(struct FileInfoBlock));
	UnLock(dirlock);
}

int scandir(char *dirname)
{
	BPTR	dirlock,oldlock=NULL;
	struct FileInfoBlock *fiblock=NULL;
	char *fname;
	int error=0,errror;
	int longlength,oldlength;

	if(!(dirlock=Lock(dirname,ACCESS_READ))) {
		printf("WARNING: Directory %s is locked.\n",dirname);
		return(5);
	}

	if(!(fiblock = AllocMem( sizeof( struct FileInfoBlock ),
									MEMF_PUBLIC | MEMF_CLEAR ))) {
		UnLock(dirlock);
		PutStr("ERROR: Out of memory.\n");
		return(20);
	}

	if(!(Examine(dirlock,fiblock))) {
		pferror();
		exitscan(NULL,dirlock,fiblock);
		return(5);
	}

	if(fiblock->fib_DirEntryType<=0) {
		printf("ERROR: %s is not a directory.\n",dirname);
		exitscan(NULL,dirlock,fiblock);
		return(10);
	}

	oldlength=strlen(longdirname);
	strcat(longdirname,dirname);
	longlength=strlen(longdirname);
	if(longdirname[longlength-1]!='/') {
		longdirname[longlength++]='/';
		longdirname[longlength]='\0';
	}

	oldlock=CurrentDir(dirlock);

	while(ExNext(dirlock,fiblock)) {
		fname=fiblock->fib_FileName;
		if(!(strcmp(fname,".info")))
			continue;
		if((fiblock->fib_DirEntryType>0)&&argarray[2]) {
			errror=scandir(fname);
			if(errror==20) {
				PutStr("Aborting..\n");
				exitscan(oldlock,dirlock,fiblock);
				return(20);
			}
			error=(errror>error)? errror : error;  /* ;-) */
		}
		else
			if(infoname(fname)) {
				if(argarray[TMP_LOG])
					printf("%s%s...\n",longdirname,fname);
				fname[strlen(fname)-5]=0;
				error=(cleantools(fname)>error)? 5 : error;
			}
	}
	longdirname[oldlength]=0;
	exitscan(oldlock,dirlock,fiblock);
	return(error);
}

int main(int argc, char *argv[])
{
	int error,totalerror=0;
	char **files;

	if(!(newtools=(char **)AllocMem(ARRAYSIZE,MEMF_ANY))) {
		PutStr("ERROR: Out of memory.\n");
		safeexit(20);
	}

	if(!(rdargs=ReadArgs(template,argarray,NULL)))
		safeexit(5);

	files=(char **)argarray[TMP_FILES];

	if(argarray[TMP_REC]) {
		if(argarray[TMP_LOG])
			PutStr("\nCleaning files:\n");
		while(*files) {
			strncpy(filename,*files++,39);
			longdirname[0]='\0';
			error=scandir(filename);
			totalerror=(totalerror>error)? totalerror: error;
		}
		if(argarray[TMP_LOG]) {
			PutStr("\nDone..\n\n");
			if(totalerror)
				PutStr("Operation not entirely successful.\n\n");
			else
				PutStr("Operation successful.\n\n");
		}
	}
	else
		while(*files) {
			strncpy(filename,*files++,39);
			if(infoname(filename))
				filename[strlen(filename)-5]=0;
			if(argarray[TMP_LOG])
				printf("Cleaning %s.info...\n",filename);
			error=cleantools(filename);
			totalerror=(totalerror>error)? totalerror: error;
		}

	safeexit(totalerror);
}
