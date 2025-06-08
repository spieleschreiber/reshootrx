
;         Written by Bruce Dawson, Copyright © 1989.
;
;         This  program  and  source  may  be  freely distributed as long as
; credit  to  the  original  author  is left in the source and documentation
; accompanying  the  executable.   This program may be modified for your own
; purposes.
;
;
;         This  program  is  designed to an example of how you can customize
; the  req.library  file  requester (or any of the other requesters) to suit
; your  own  personal tastes.  This program is designed to be used by people
; who  USE  programs  that  use  the  file  requester,  not people who WRITE
; programs that use the file requester.  This program patches into all calls
; to  the  file  requester  and  modifies  the  requester structure, without
; telling the calling program.
;         Note  that  this  program  opens  the  requester library but never
; closes  it.   This  is  necessary if the patch is to stay in effect.  This
; does,  however,  mean that the requester library can not be flushed out of
; memory.   In  addition,  this  program  must  stay  in memory forever.  To
; conserve  memory,  it  would  be  wise to run this program with as small a
; stack as possible.
;         This  technique of patching the requester library could be used to
; patch other functions in the requester library also.  Have fun customizing
; your system, while still using a 'standard' file requester.


	include	"libraries/reqbase.i"


SYS	MACRO
	XREF	_LVO\1
	JSR	_LVO\1(A6)
	ENDM

	dseg
_ReqBase	DC.L	0
OldLocation	DC.L	0
reqname		DC.B	"req.library",0
	cseg



	MOVE.L	4,A6	;Load SysBase.
	LEA	reqname,A1
	MOVEQ	#0,D0
	SYS	OpenLibrary
	MOVE.L	D0,_ReqBase
	BEQ	ErrorOpeningReqBase

	MOVE.L	D0,A1
	LEA	FileRequesterPatchFunction,A0
	MOVE.L	A0,D0
	MOVE.L	#_LVOFileRequester,A0
	SYS	SetFunction
	MOVE.L	D0,OldLocation

	MOVEQ	#-1,D0
	SYS	AllocSignal		;Allocate any signal.

	MOVEQ	#1,D1
	LSL.L	D0,D1
	MOVE.L	D1,D0
	SYS	Wait			;Wait for a signal that will never come.

ErrorOpeningReqBase
	RTS





FileRequesterPatchFunction
;         Here is where you adjust the file requester structure to suit your
; own  particular tastes.  Examples of things that you can safely adjust are
; the  color  fields  (dirnamescolor, devicenamescolor etc.), the numcolumns
; and  numlines  fields.  Most of the flags can safely be set from here, the
; exceptions  being  the EXTSELECT and CACHING flags, because if the calling
; program doesn't have the necessary code to deal with these (processing the
; extra  files  and purging buffers left by both flags) then some memory may
; not  get  freed  up.  These two flags can be safely cleared though, if you
; don't  want  extended select or caching.  I believe all of the other flags
; can safely be set or cleared or set.

		;If you like a particular width of file requester.
	MOVE.W	#20,frq_numcolumns(A0)

		;If you want the cache to be purged whenever the directory
		;modification date changes and if you don't want half read
		;directories to get cached.
	OR.L	#FRQCACHEPURGEM!FRQNOHALFCACHEM,frq_Flags(A0)
	MOVE.L	OldLocation,A1
	JMP	(A1)



