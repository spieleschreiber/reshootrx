*************   VARIABLEN *********************

MODE_NEWFILE    =       1006
MODE_OLDFILE    =       1005
ACCESS_READ		=		-2

*************   HAUPTPROGRAMM *****************
loadFile
        move.l d1,filenamePointer
        move.l d2,buffer
        move.l d3,bufferSize

        move.l  filenamePointer,d1
        move.l  #MODE_OLDFILE,d2
        CALLDOS Open
        move.l  d0,FileHandle
        tst.l d0
        beq     Fehler
        move.l  FileHandle,d1
        move.l  buffer,d2
        move.l bufferSize,d3
        CALLDOS Read
        tst.l   d0
        beq     Fehler

        move.l  FileHandle(pc),d1
		CALLDOS Close
        moveq #1,d0
        rts

Fehler  
        move.l  FileHandle(pc),d1
		CALLDOS Close
        moveq #0,d0
        rts

;*******************************
	; provide full filepath 
createFilePath
	;	d1.w 	-> 	pointer to short filename
	;	a0.l	-> base filename
	;	-> d1	pointer to complete filepath
	; destroys a0
	movem.l a1/a2/d7,-(sp)
	move.l d1,a2
	lea tempFilenameVar(pc),a1
	move.l a1,d1
.copyCharBase
	move.b (a0)+,(a1)+
	bne .copyCharBase
	lea -1(a1),a1
.copyCharFile
	move.b (a2)+,(a1)+
	bne .copyCharFile
	IFNE SHELLHANDLING
	IFEQ (RELEASECANDIDATE||DEMOBUILD)
	sub.l d1,a1	; check if filepath too long
	cmpa #tempFilenameVarEOF-tempFilenameVar,a1
	bgt shellFilepathError
	ENDIF
	ENDIF
	movem.l (sp)+,a1/a2/d7
	rts

	; provide filepath to leveldata in stage-related folders
createFilePathOnStage
	;	d1.w 	-> 	pointer to short filename
	;	-> d1	pointer to complete filepath
	; destroys a0,a1,a2,d7
	move.l d1,a2
	move.w gameStatusLevel(pc),d7
	move.l (.filenamePointer+4,pc,d7.w*4),a0
	lea tempFilenameVar(pc),a1
	move.l a1,d1
.copyCharBase
	move.b (a0)+,(a1)+
	bne .copyCharBase
	lea -1(a1),a1
.copyCharFile
	move.b (a2)+,(a1)+
	bne .copyCharFile
	IFNE SHELLHANDLING
	IFEQ (RELEASECANDIDATE||DEMOBUILD)
	sub.l d1,a1	; check if filepath too long
	cmpa #tempFilenameVarEOF-tempFilenameVar,a1
	bgt shellFilepathError
	ENDIF
	ENDIF
	rts
.filenamePointer
		dc.l	.titleFilepath,.stage0Filepath,.stage1Filepath,.stage2Filepath,.stage3Filepath,.stage4Filepath,.stage5Filepath
.titleFilepath
	dc.b "PROGDIR:title/",0
.stage0Filepath
	dc.b "PROGDIR:stage0/",0
.stage1Filepath
	dc.b "PROGDIR:stage1/",0
.stage2Filepath
	dc.b "PROGDIR:stage2/",0
.stage3Filepath	
	dc.b "PROGDIR:stage3/",0
.stage4Filepath	
	dc.b "PROGDIR:stage4/",0
.stage5Filepath	
	dc.b "PROGDIR:stage5/",0
	even

GetFileInfo

;	Fetch filename info
;	d1 -> pointer to filename
;	-> d0	= 0	-> Error
;	-> d0	= 1 -> filedata in fileinfoblock

		move.l d1,filenamePointer

		move.l #ACCESS_READ,d2
		CALLDOS Lock

		tst.l d0
		beq .error
		move.l d0,fileLock

       	move.l d0,d1
    	lea fileinfoblock(pc),a0
    	move.l a0,d2
    	CALLDOS Examine
        tst.l   d0
        beq     .error

		move.l fileLock,d1
		CALLDOS UnLock
        moveq #1,d0
        rts
.error
	clr.l d0
	rts

; #MARK: - SEND FILE TO DISK -

writeMemToDisk

;	Write memorychunk to disk
;	d1 -> pointer to filename
;	-> d0	= 0	-> Error
;	-> d0	= 1 -> filedata in fileinfoblock

; 	write filename -> tempFilenameVar
; 	d2.l 	->	adress of memblock to save
; 	d3.l 	->	size of memblock

		lea .filename(pc),a0
		movem.l d2/d3,(a0)

		move.l  #levDefFilename,d1
		move.l  #MODE_NEWFILE,d2
		CALLDOS Open
        move.l  d0,FileHandle
        beq.s   .error
.isOpen
        move.l  FileHandle(pc),d1
		lea .filename(pc),a0
		movem.l (a0),d2/d3
		CALLDOS Write

        move.l  FileHandle(pc),d1
        CALLDOS Close
.error
        rts
.filename
	dc.l 	0,0



*************   Alert *************************
SysAlert
        move.l  DOSBase,a6
        moveq #0,d0
        move.l #errorLowMem,a0
        move #100,d1
        move #50,d7
        jmp     _LVOAlert(a6)

*************   Daten *************************

FileHandle     dc.l    1
fileLock		dc.l 	0
filenamePointer dc.l    0
bufferSize      dc.l    0
buffer          dc.l    0
	cnop 0,4		; align to quadbyte
fileinfoblock
	dc.l 0 ;   LONG   fib_DiskKey;
	dc.l 0 ;   LONG   fib_DirEntryType;  /* Type of Directory. If < 0, then a plain file.
				 * If > 0 a directory */
	blk.b 108,0 ;  ; char   fib_FileName[108]; /* Null terminated. Max 30 chars used for now */
	dc.l 0 ;LONG   fib_Protection;    /* bit mask of protection, rwxd are 3-0.      */
	dc.l 0 ;LONG   fib_EntryType;
fib_Size
    dc.l    0   ;   fib_Size
    dc.l 	0	; 	fib_NumBlocks;     /* Number of blocks in file */
fib_timeStamp
	dc.l	0	;/* Number of days since Jan. 1, 1978 */
	dc.l	0	;/* Number of minutes past midnight */
	dc.l	0	;/* Number of ticks past minute */
    blk.b 116,0	;   char	  fib_Comment[80];  char	  fib_Reserved[36];
    dc.l $fefe,$fefe

