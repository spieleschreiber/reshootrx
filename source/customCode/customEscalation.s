

; #MARK: - Handle escalation -

initEscl
	;move.l escalateEntry(pc),a1
	lea copEscalateBPLPT,a1
	move.l #escalationBitmap,d0
	move.w d0,6(a1)
	move.w d0,8+6(a1)
	move.w d0,16+6(a1)
	swap d0
	move.w d0,2(a1)
	move.w d0,8+2(a1)
	move.w d0,16+2(a1)

	; reset split list, as this probably has been modified by player sprite code
	lea copGameEscalateSplits,a0
	move.w #escalateStart+4,d1
	move.w #((escalateHeight-1)/2)-1,d0
	move.w #$ff<<8+%11111110,d2
	move.w #BPLCON1,d3
	swap d3
	clr.w d3
.resetSplit
	move.b d1,(a0)+
	move.b #$b1,(a0)+
	move.w d2,(a0)+
	move.l d3,(a0)+
	add.b #2,d1
	dbra d0,.resetSplit

	pea .ret(pc)	; need to set BPLTPT7-pointer
	bra smEscalUpdateBPLPT
.ret
	lea (viewStageTable+10,pc),a0
	lea copEscalateFlex,a2
	bsr subViewFlexFiller

	lea coplist,a0
	lea copGameEscalateExit,a1
	move.w d0,copGameEscExitCOLOR00+6-copGameEscalateExit(a1) ;get BPL2MOD in d1 from subViewFlexFiller
	move.w d1,copGameEscExitBPL2MOD+2-copGameEscalateExit(a1)	; d7 set by subViewFlexFiller

    move.w copBPLCON0+2-coplist(a0),d0
    move.w copBPLCON2+2-coplist(a0),d1
    move.w copBPLCON3+2-coplist(a0),d2
	move.w d0,copGameEscExitBPLCON0+2-copGameEscalateExit(a1)
    move.w d1,copGameEscExitBPLCON2+2-copGameEscalateExit(a1)

	move.w d2,copGameEscExitBPLCON3+2-copGameEscalateExit(a1)
	
	moveq #4,d2
	add.l escalateExit(pc),d2
	move.w d2,copGameEscQuit+6-copGameEscalateExit(a1)
	swap d2
	move.w d2,copGameEscQuit+2-copGameEscalateExit(a1)	; modify return jump to main coplist
	PLAYFX 7

	WAITRASTER 200

;	WAITVBLANK	; wait one frame -> raslistmove built correct gamecoplist
	move.b #1,escalateIsActive
	move.l escalateEntry(pc),a1
	move.w #COPJMP1,12(a1); overwrite copJmp trigger

    jmp (a5)

muscEscl	; introduce boss music
	SAVEREGISTERS
	move.l musicMemory(pc),a0	; init boss music
	move.l musicTrackB(pc),a0	; init boss music
	bsr startAudioTrack
	RESTOREREGISTERS
	jmp (a5)
	
exitEscl

    sf.b escalateIsActive
	SAVEREGISTERS
    bsr rasterListMove
    RESTOREREGISTERS
	WAITRASTER 200

	;WAITVBLANK
	move.l escalateEntry(pc),a2
	move.w #NOOP,12(a2); overwrite copJmp trigger
    jmp (a5)
    
