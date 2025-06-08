/* Prototypes for the req.library for use with Lattice. */

#ifndef __NOPROTO
#ifndef __PROTO
#define __PROTO(a) a
#endif
#else
#ifndef __PROTO
#define __PROTO(a) ()
#endif
#endif


void __stdargs  SimpleRequest __PROTO((char *,...));
int  __stdargs  TwoGadRequest __PROTO((char *,...));
int  __stdargs  FileRequester __PROTO((struct FileRequester *));
void __stdargs  Center __PROTO((struct NewWindow *,int,int));
void __stdargs  PurgeFiles __PROTO((struct FileRequester *));
void __stdargs  ColorRequester __PROTO((long));
int  __stdargs	TextRequest __PROTO((struct TRStructure *));
char __stdargs	RawKeyToAscii __PROTO((short,short,char *));

