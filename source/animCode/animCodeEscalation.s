

    ;	#MARK: - Animate Escalation
	; ATTN	uses animTriggers+2, animTriggers+3
esclQuit        ; fade boss music
    SAVEREGISTERS

    lea objectListTriggers(a2),a1
    tst.b 2(a1)       ; fade music?
    bne .fadeInMain
    clr.w d1    ; fade out boss music
    move.w #255,d1
    sub.b objectListCnt(a2),d1
    lsr.b #2,d1
    move.w #musicFullVolume,d0
    sub.w d1,d0
    bpl .keep
    clr d0
.keep
	lea CUSTOM,a6
    bsr _mt_mastervol
    RESTOREREGISTERS
    bra animReturn
.fadeInMain
    clr.w d1
    move.b objectListCnt(a2),d1
    lsr #2,d1
    move.w #musicFullVolume,d0
    sub.w d1,d0
    bpl .keep
    clr d0
    bra.b .keep

esclThis            ; initialise excalation object
	;bra animReturn
	SAVEREGISTERS		; yes!

    lea objectListTriggers(a2),a1
    tst.b 2(a1)       ; fade music?
    bne .musicFaded
	clr.w d1
	move.w #255,d1
	sub.b objectListCnt(a2),d1
	lsr.b #2,d1
	move.w #musicFullVolume,d0
	sub.w d1,d0
    bpl.b .keep
    clr d0
.keep
	lea CUSTOM,a6
    bsr _mt_mastervol
	RESTOREREGISTERS
	bra objectListNextEntry
.musicFaded
	tst.b 3(a1)       ; distort escal text?
	beq.b .zoomText
						; yes!

	moveq #5,d4
    add.b objectListCnt(a2),d4
   	lea escalateIsActive(pc),a5
	move.b d4,(a5)
	bra .quitEscalate
.zoomText
	lea copEscalateBPLPT,a1
    tst plyPos+plyCollided
    bne .quitEscalate
	
	move.l #escalationBitmap,d7
	;sub #8,d7
	move #$f,d2
	moveq #-4,d0		; filter
	moveq #32,d4		; 32 bytes width*64 px height
	lsl #6,d4

    clr.l d5
    clr.l d6
    move d4,d5
    move d4,d6
.escalScale=15
.escalBase=30
	cmpi.b #.escalBase+.escalScale,objectListCnt(a2) ; big logo
	bhi.b .exitMedLogo
	add.l d4,d7
	clr.l d6
.exitMedLogo
	cmpi.b #.escalBase,objectListCnt(a2) ; med logo
    bhi.b .exitSmallLogo
    add.l d4,d7
    clr.l d5
    clr.l d6
.exitSmallLogo
    and.l d0,d7         : filter lower bits - otherwise wrong display on real AGA
	;move d7,6(a1)

;move d7,6+8(a1)             ; write adress to copper sublist
    move d7,6(a1)
	swap d7
	move d7,2(a1)
    swap d7
    cmpi.b #.escalBase+.escalScale*2,objectListCnt(a2)
    bhi.b .initMedLogo
       add.l d5,d7
.initMedLogo
;add.l d4,d7
    and.l d0,d7
    move d7,6+16(a1)

    swap d7
    move d7,2+16(a1)
    swap d7
    cmpi.b #.escalBase+.escalScale*3,objectListCnt(a2)
    bhi.b .initBigLogo
    add.l d6,d7
.initBigLogo
    and.l d0,d7
    move d7,6+8(a1)
    swap d7
    move d7,2+8(a1)
    swap d7
.quitEscalate
    lea copGameEscExitBPLPT,a1        ; write fxplane-pointers to BPLPT-coplist A and B lower viewport
    move.w #escalateStart-displayWindowStart,d0
    add.w #escalateHeight+1,d0

escalateModifyGameviewBplpt
    lea copBPLPT+4+6,a5
    move.w (a5),d1
    swap d1
    move.w 4(a5),d1
    muls #fxPlaneWidth,d0
    add.l d0,d1
    moveq #40,d0
	sub.l d0,d1
	moveq #12,d0
	moveq #-8,d3
    and.l d3,d1
   	lea gameStatusLevel(pc),a0	; preps - which kind of parallax anim?
	move.w gameStatusLevel(pc),d0
	move.w (.mod,pc,d0.w*2),d0	; get bitmap modulus
	
    move d1,6(a1)
    swap d1
    move d1,2(a1)
    swap d1
    add.l d0,d1

    move d1,6+8(a1)
    swap d1
    move d1,2+8(a1)
    swap d1
   	add.l d0,d1

    move d1,6+16(a1)
    swap d1
    move d1,2+16(a1)
    swap d1
    add.l d0,d1

    move d1,6+24(a1)
    swap d1
    move d1,2+24(a1)
    
   	RESTOREREGISTERS
    bra objectListNextEntry
.mod
	dc.w 	fxPlaneWidth*fxplaneHeight*1
	dc.w 	(fxPlaneWidth*fxplaneHeight)-0
	dc.w 	fxPlaneWidth*1024
	dc.w	fxPlaneWidth*fxplaneHeight*2
	dc.w 	fxPlaneWidth*fxplaneHeight
	even

