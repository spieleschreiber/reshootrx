;//
;//  errorMessenger.s
;//  px
;//
;//  Created by Richard Löwenstein on 25.05.20.
;//  Copyright © 2020 spieleschreiber. All rights reserved.
;//



; #MARK: - SHELL TERMINAL MESSAGES

	IFNE SHELLHANDLING
shellNum		; send value.l in d0 to shell, msg-pointer a6
	SAVEREGISTERS
	lea 9(a6),a0
	bsr.w convertNumAscii
	move.l a6,a0
	bsr writeTerminal
	RESTOREREGISTERS
	rts
shellQuit
	lea .msg(pc),a0
	bra writeTerminal
.msg
	dc.b "Quit successfully",0
	even
	
shellSpriteMemError
	lea .msg(pc),a0
	bra writeTerminal
.msg
	dc.b "spriteposmem overflow",0
	even
shellSpriteDMAMemError
	lea .msg(pc),a0
	bra writeTerminal
.msg
	dc.b "spriteDMAmem overflow",0
	even
	
shellObjListLaunchlistError
	lea .msg(pc),a0
	bra writeTerminal
.msg
	dc.b "obInit launchlist error - too low pointer",0
	even
shellObjListRuntimeError
	lea .msg(pc),a0
	bra writeTerminal
.msg
	dc.b "obInit runtime error - too low pointer",0
	even

shellBufferWarning
	;SAVEREGISTERS
	lea .msg(pc),a0
	bra writeTerminal
	;RESTOREREGISTERS
	;rts
.msg
	dc.b "membuffer exceed warning",0
	even

shellLaunch
	lea .msg(pc),a0
	bra writeTerminal
	rts
	nop
.msg
	dc.b 10,13
	dc.b 'RESHOOT PROXIMA 3 launching',0
	even
shellMemoryAvail
	SAVEREGISTERS
	AVAILMEMORY
	lea .msg+8(pc),a0
	bsr.w convertNumAscii
	lea .msg(pc),a0
	bsr writeTerminal
	RESTOREREGISTERS
	rts
.msg
	dc.b "        KB chipmem available ",0
	even

shellMemoryFree
	lea .msg+8(pc),a0
	bsr.w convertNumAscii
	lea .msg(pc),a0
	bra writeTerminal
.msg
	dc.b "        KB dealloc´d",0
	even

shellAnimMissing
	lea .msg(pc),a0
	movem.l d2/d3,(a0)
	bra writeTerminal
.msg
	dc.b "          anim missing",0
	even
	
shellLoadError
		move.l filenamePointer(pc),a1
		lea .msg+18(pc),a0
		tst.l a1
		beq .skip
.fetchName
		move.b (a1)+,d0
		cmpi.b #"<",d0
		beq .skip	; found end of filename
		tst.b (a0)
		beq .skip	; max. lenth of message
		move.b d0,(a0)+
		bra .fetchName
.skip
		lea .msg(pc),a0
	bra writeTerminal
.msg
	dc.b "ERROR cannot load                                      ",0
.msgEnd
	even

shellOutOfMemError
	move.l tempVar(pc),d0	; fetch fail pc 
	lea .msg+27(pc),a0
	bsr.w convertNumAscii
	lea .msg(pc),a0
	bra writeTerminal
.msg
	dc.b "ALLOCMEM ERROR at $XXXXXXXX ",0
	even

shellTilemapError
	lea .msg(pc),a0
	bra writeTerminal
.msg
	dc.b "ERROR in tilemap data. Width, height, start mismatch",0
	even

shellFilepathError
	lea .msg(pc),a0
	bra writeTerminal
.msg
	dc.b "ERROR in filepath creation. Filename too long?",0
	even


shellTileAnimError
.findEntry
	sub.l #1,a0
	cmpi.l #"ame=",(a0)
	bne .findEntry
	movem.l 5(a0),d1-d2
	lea .msg(pc),a0
	movem.l d1-d2,.msgEnd-.msg-9(a0)
	bra writeTerminal
.msg
	dc.b "ERROR map-decoder can´t find anim XXXXXXXX",0
.msgEnd
	even
	
shellObjectMissing
	movem.l (a0),d1-d2
	movem.l 1(a4),d3-d4
	lea .msg(pc),a0
	movem.l d3-d4,11(a0)
	movem.l d1-d2,.msgEnd-.msg-9(a0)
	bra writeTerminal
.msg
	dc.b "ERROR anim XXXXXXXX can´t find object XXXXXXXX",0
.msgEnd
	even

shellCodeMissing
	movem.l -8(a4),d1-d2
.findEntry
	sub.l #1,a4
	cmpi.l #"nim:",(a4)
	bne .findEntry
	movem.l 4(a4),d3-d4
	lea .msg(pc),a0
	movem.l d3-d4,11(a0)
	movem.l d1-d2,.msgEnd-.msg-9(a0)
	bra writeTerminal
.msg
	dc.b "ERROR anim XXXXXXXX can´t find code XXXXXXXX",0
.msgEnd
	even

shellMemAllocd		; send msg to aux:, number in d0
	SAVEREGISTERS
	btst #1,d1
	beq .isFastOrAnyMem
	lea .msg+8(pc),a0
	bsr.w convertNumAscii
	lea .msg(pc),a0
	bsr writeTerminal
	RESTOREREGISTERS
	rts
.isFastOrAnyMem
	lea .msgB+8(pc),a0
	bsr.w convertNumAscii
	lea .msgB(pc),a0
	bsr writeTerminal
	RESTOREREGISTERS
	rts
.msg
	dc.b "         chipmem alloc´d",0
.msgB
	dc.b "         fastmem alloc´d",0
	even


shellChipMemUsed		; send msg to aux:, number in d0
	SAVEREGISTERS
	lea .msg+8(pc),a0
	bsr.w convertNumAscii
	lea .msg(pc),a0
	bsr writeTerminal
	RESTOREREGISTERS
	rts
.msg
	dc.b "         total MEMF_CHIPmem alloc´d",0
	even
shellFastMemUsed		; send msg to aux:, number in d0
	SAVEREGISTERS
	lea .msg+8(pc),a0
	bsr.w convertNumAscii
	lea .msg(pc),a0
	bsr writeTerminal
	RESTOREREGISTERS
	rts
.msg
	dc.b "         total fastmem alloc´d",0
	even
shellMainExeSize		; send msg to aux:, number in d0
	SAVEREGISTERS
	lea .msg+8(pc),a0
	bsr.w convertNumAscii
	lea .msg(pc),a0
	bsr writeTerminal
	RESTOREREGISTERS
	rts
.msg
	dc.b "         size of px.bin",0
	even
shellMemoryLeak		; send msg to aux:, number in d0
	SAVEREGISTERS
	lea .msg+8(pc),a0
	bsr.w convertNumAscii
	lea .msg(pc),a0
	bsr writeTerminal
	RESTOREREGISTERS
	rts
.msg
	dc.b "         Bytes missing. MEMORY LEAK DETECTED",0
	even
	
shellMemoryWarning		; send msg to aux:, number in d0
	SAVEREGISTERS
	lea .msg+8(pc),a0
	bsr.w convertNumAscii
	lea .msg(pc),a0
	bsr writeTerminal
	RESTOREREGISTERS
	rts
.msg
	dc.b "         TOO MUCH MEMORY. Reduce to $190000",0
	even
shellMemoryOkay		; send msg to aux:, number in d0
	SAVEREGISTERS
	lea .msg+8(pc),a0
	bsr.w convertNumAscii
	lea .msg(pc),a0
	bsr writeTerminal
	RESTOREREGISTERS
	rts
.msg
	dc.b "         total Memory Footprint. Great!",0
	even


; #MARK: - SEND TEXT TO AUX / SHELL TERMINAL

writeTerminal
	lea terminalMsg(pc),a1
	moveq #terminalMsgEnd-terminalMsg-2,d0
.copyChar
	move.b (a0)+,d1
	beq textToTerminal
	move.b d1,(a1)+
	dbra d0,.copyChar
textToTerminal
	move #terminalMsgEnd-terminalMsg-2,d7
	sub d0,d7
	move.b d7,terminalMsgSize
	
		
		move.l  #auxName,d1
		move.l  #MODE_OLDFILE,d2
		CALLDOS Open
        move.l  d0,ShellHandle
.isOpen
	WAITVBLANK
        move.l  ShellHandle(pc),d1	; print linefeed
	    move.l  #shellLinefeed,d2
	    moveq   #2,d3
	    CALLDOS Write

		move.l  ShellHandle(pc),d1	; print msg
		move.l #terminalMsg,d2
		clr.l d3
		move.b terminalMsgSize(pc),d3
		CALLDOS Write
      
		move.l ShellHandle,d1	
		CALLDOS Close
		rts


ShellHandle	dc.l    0
auxName	dc.b "AUX:",0
shellLinefeed       
       dc.b 10,13,"!!",0
       even
terminalMsgSize
	dc.b	0
terminalMsg
	blk.b 49,"a"
terminalMsgEnd
	
convertNumAscii
	; number d0, memPointer+7 a0
    move #7,d7
.wrtNum
    move.l d0,d1
    andi.b #$f,d1
    cmpi.b #10,d1
    blt .isNum
    add.b #"A"-10,d1
    bra .wrtChar
.isNum
    add.b #"0",d1
.wrtChar
    move.b d1,-(a0)
    asr.l #4,d0
    dbra d7,.wrtNum
	rts
	ENDIF


; #MARK: - SEND TEXT TO AMIGA WINDOW

printError
		clr.w d7
        move.b errorNo(pc),d7
        beq printQuit
        ext.w d7
        jmp ([errorCases,pc,d7.w*4])
lowMem
		lea errorLowMem(pc),a2
		move.l a2,d2
		moveq   #errorLowMemEnd-errorLowMem,d3
		bra.b printNow
diskRead
		move.l filenamePointer(pc),a0
		tst.l                a0
		beq .dskSkip
		movem.l (a0),d2-d7/a0/a2
		lea errorDiskRead(pc),a1
		movem.l d2-d7/a0/a2,(a1)
.dskSkip
		lea errorDiskRead(pc),a2
		move.l a2,d2
		moveq   #errorDiskReadEnd-errorDiskRead,d3
		bra.b printNow
xml
		lea errorXMLDecode(pc),a2
		move.l a2,d2
        moveq   #errorXMLDecodeEnd-errorXMLDecode,d3
        bra.b printNow
xmlNamespace
		lea errorXMLNamespace(pc),a2
		move.l a2,d2
		moveq   #errorXMLNamespaceEnd-errorXMLNamespace,d3
		bra.b printNow
config
		lea errorNoAGA(pc),a2
		move.l a2,d2
		moveq   #errorNoAGAEnd-errorNoAGA,d3
		bra.b printNow
bobMem
		lea errorBobMem(pc),a2
		move.l a2,d2
		moveq   #errorBobMemEnd-errorBobMem,d3
printNow
		ERRORBREAK
		movem.l d2/d3,-(sp)
        
		move.l  #window,d1
		move.l  #MODE_NEWFILE,d2
		CALLDOS Open
        move.l  d0,WindowHandle

		move.l  WindowHandle,d1	; print message
		movem.l (sp)+,d2/d3
		move.l  DOSBase(pc),a6  ; ExecBase
		jsr     _LVOWrite(a6)
      
      	move.l  DOSBase(pc),a6
		move   #3*60,d1
        jsr     _LVODelay(a6)
        
		move.l WindowHandle,d1
		CALLDOS Close
printQuit
		rts

; #MARK: - ERROR DEFINITIONS
errorBobMemory
	ERRORBREAK
    move #1,errorFlag
    moveq #_errorBobMem,d7
	move.b d7,errorNo
    QUITNOW
errorMemory
	ERRORBREAK
	IFNE SHELLHANDLING
    bsr shellOutOfMemError
    ENDIF
    move #1,errorFlag
    moveq #_errorLowMem,d7
	move.b d7,errorNo
	QUITNOW
errorDisk
	ERRORBREAK
	IFNE SHELLHANDLING
    bsr shellLoadError
    ENDIF
    move #1,errorFlag
    moveq #_errorDiskRead,d7
	move.b d7,errorNo
    QUITNOW
errorXML
    ERRORBREAK
	IFNE SHELLHANDLING
    bsr shellTilemapError
    ENDIF
    move #1,errorFlag
    moveq #_errorXMLDecode,d7
	move.b d7,errorNo
    QUITNOW
errorConfig
	ERRORBREAK
    move #1,errorFlag
    moveq #_errorNoAGA,d7
	move.b d7,errorNo
    QUITNOW
errorXMLAnim
	ERRORBREAK
	IFNE SHELLHANDLING
    bsr shellObjectMissing
    ENDIF
    move #1,errorFlag
    moveq #_errorXMLNamespace,d7
	move.b d7,errorNo
    QUITNOW
errorXMLMapObject
	ERRORBREAK
	IFNE SHELLHANDLING
    bsr shellTileAnimError
    ENDIF
    move #1,errorFlag
    moveq #_errorXMLNamespace,d7
	move.b d7,errorNo
    QUITNOW
errorXMLName
	ERRORBREAK
	IFNE SHELLHANDLING
    bsr shellCodeMissing
    ENDIF
    move #1,errorFlag
    moveq #_errorXMLNamespace,d7
	move.b d7,errorNo
    QUITNOW
errorMemoryOverrun
	ERRORBREAK
	IFNE SHELLHANDLING
    bsr shellBufferWarning
    ENDIF
    move #1,errorFlag
    moveq #_errorBobMem,d7
	move.b d7,errorNo
    QUITNOW
errorFlag
    dc.w 0

ENDOFMSG	MACRO
	dc.b 13,10,13,10,0
	even
	ENDM
_errorLowMem=0
errorLowMem
    dc.b    "Need 1.8 mb of chipmem. Please free memory"
    ENDOFMSG
errorLowMemEnd
    even
_errorDiskRead=1
errorDiskRead
    blk.b 32," "
    dc.b    " #"
    dc.b    "File not found. Please check media device"
    ENDOFMSG
errorDiskReadEnd

_errorXMLDecode=3
errorXMLDecode
    dc.b    "Fatal error in datatable"
    ENDOFMSG
errorXMLDecodeEnd
    even

_errorXMLNamespace=4
errorXMLNamespace
    dc.b    "Fatal error in datatable. Possible name-mismatch"
	ENDOFMSG
errorXMLNamespaceEnd

_errorNoAGA=5
errorNoAGA
    dc.b    "Game needs AGA-MEMF_CHIPset and 680020-cpu or better"
    ENDOFMSG
errorNoAGAEnd
    even
_errorBobMem=6
errorBobMem
    dc.b    "No more objectmemory available"
	ENDOFMSG

errorBobMemEnd
    even
errorCases
    dc.l lowMem, diskRead, xml, xml, xmlNamespace, config,bobMem


window
	dc.b    "con:10/10/600/80/RESHOOT PROXIMA ERROR"
	dc.b    "/AUTO/SIZE/DRAG/CLOSE",0
errorNo   dc.b 0
	even
WindowHandle
        dc.l    0

; #MARK: - EXCEPTION HANDLING / SHELL MESSAGES

access_fault
	IFNE SHELLHANDLING
	lea .msg(pc),a0
	lea .msgEnd-.msg-2(a0),a0
	move.l 2(sp),d0
	bsr.w convertNumAscii
	lea .msg(pc),a0
	bsr writeTerminal
	rte
.msg
	dc.b "ERROR Access Fault Exception at $XXXXXXXX",0
.msgEnd	even
	ENDIF
	rte
address_error
	IFNE SHELLHANDLING
	lea .msg(pc),a0
	lea .msgEnd-.msg-2(a0),a0
	move.l 2(sp),d0
	bsr.w convertNumAscii
	lea .msg(pc),a0
	bsr writeTerminal
	rte
.msg
	dc.b "ERROR Address Error Exception at $XXXXXXXX",0
.msgEnd	even
	ENDIF
	rte
illegal_instruction
	IFNE SHELLHANDLING
	lea .msg(pc),a0
	lea .msgEnd-.msg-2(a0),a0
	move.l 2(sp),d0
	bsr.w convertNumAscii
	lea .msg(pc),a0
	bsr writeTerminal
	add.l #2,2(sp)
	rte
.msg
	dc.b "ERROR Illegal Instruction Exception at $XXXXXXXX",0
.msgEnd	even
	ENDIF
	rte

divide_by_Zero
	IFNE SHELLHANDLING
	lea .msg(pc),a0
	lea .msgEnd-.msg-1(a0),a0
	move.l 2(sp),d0
	bsr.w convertNumAscii
	lea .msg(pc),a0
	bsr writeTerminal
	rte
.msg
	dc.b "ERROR Divide by Zero Exception at $XXXXXXXX",0
.msgEnd	even
	ENDIF
	rte
