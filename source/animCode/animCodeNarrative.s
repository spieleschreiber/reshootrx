

	; #MARK: - Animate Dialogue

;May use d0,d4,d5,d6,d7,a1,a3

dialogue

	lea copGameDialogueExit,a1
	tst.b objectListTriggers(a2)
	bne .restoreCoplist
	SAVEREGISTERS
	lea copGameDialgExitBPLPT,a1
;    lea copBPLPT+2,a5
 ;   move.w (a5),d7
  ;  swap d7
   ; move.w 4(a5),d7

    move.l mainPlanesPointer+4(pc),d7
    add.l #(dialogueStart-displayWindowStart+dialogueHeight+1)*mainPlaneDepth*mainPlaneWidth,d7
	moveq #40,d0
	bsr .updateBPLPT

	tst.b plyBase+plyWeapUpgrade(pc)
	bmi .quit	; no dialogue while player dies

	lea copDialogueBPLPT,a1
	moveq #32,d7
	;clr.l d7
	add.l a0,d7
.add SET 256/8
	cmp.w 6(a1),d7
	beq .updateDone	; update bitplane pointers only if different
	moveq #32,d0
 	bsr .updateBPLPT
.updateDone

	lea copGameDialgExitBPLPT,a1 
	tst.b objectListTriggers+1(a2)
	beq .initBaddieColors

	move.l copperDialogueColors(pc),a0
	lea $50(a0),a0
	move.l a0,copInitColorswitch
	sf.b objectListTriggers+1(a2)

	tst.l _fxSpeechBaddie(pc)
	beq .initBaddieColors

	movem.l d0-d1/a0/a6,-(sp)
	lea CUSTOM,a6
	lea fxTable+(fxSpeechBaddie-1)*12(pc),a0
	bsr	_mt_playfx	; do not use PLAYFX macro to skip sanity check
	movem.l (sp)+,d0-d1/a0/a6

	;PLAYFX fxSpeechBaddie
.initBaddieColors

	tst.b dialogueIsActive(pc)
	bne .quit
.initCoplist		; first run -> init coplist
	move.l copperDialogueColors(pc),copInitColorswitch	; init hero colors @ vbi
	;WAITVBLANK
	WAITRASTER 200

    lea copGameDialogueExit,a1
    moveq #4,d2 
	add.l dialogueExit(pc),d2

    move.w d2,copGameDialgQuit+6-copGameDialogueExit(a1)
    swap d2
    move.w d2,copGameDialgQuit+2-copGameDialogueExit(a1)	; modify return jump to main coplist

	lea coplist,a0
    move.w copBPLCON0+2-coplist(a0),d0
    move.w copBPLCON2+2-coplist(a0),d1
	move.w d0,copGameDialgExitBPLCON0+2-copGameDialogueExit(a1)
    move.w d1,copGameDialgExitBPLCON2+2-copGameDialogueExit(a1)
	move.w #$54af,-4(a1)	; reset waitcmd for players cop-sublist split

	lea (viewStageTable,pc),a0
	lea copDialogueFlex,a2
	bsr subViewFlexFiller


;	WAITVBLANK

	move.l dialogueEntry(pc),a1
	move.w #COPJMP1,12(a1); overwrite copJmp trigger

	st.b dialogueIsActive
	tst.l _fxSpeechHero(pc)
	beq .quit
	lea CUSTOM,a6
	move #musicFullVolume/2,d0
	bsr _mt_mastervol	; lower music volume

	lea CUSTOM,a6
	lea fxTable+(fxSpeechHero-1)*12(pc),a0
	bsr	_mt_playfx	; do not use PLAYFX macro to skip sanity check

;	PLAYFX fxSpeechHero
.quit
	RESTOREREGISTERS
	bra objectListNextEntry
.restoreCoplist
	SAVEREGISTERS
	lea CUSTOM,a6
	move #musicFullVolume,d0
	bsr _mt_mastervol	; reset music volume

	sf.b dialogueIsActive
	move.l dialogueEntry(pc),a1
	move.w #NOOP,12(a1); overwrite copJmp trigger
	RESTOREREGISTERS
	bra objectListNextEntry
.updateBPLPT
	move d7,6(a1)
	swap d7
	move d7,2(a1)
	swap d7
	add.l d0,d7
    move d7,6+8(a1)
    swap d7
    move d7,2+8(a1)
    swap d7
    add.l d0,d7
    move d7,6+16(a1)
    swap d7
    move d7,2+16(a1)
	swap d7
    add.l d0,d7
    move d7,6+24(a1)
    swap d7
    move d7,2+24(a1)
	rts

subViewFlexFiller
	move.w gameStatusLevel(pc),d0
	move.w (a0,d0.w*2),d0
	lea (a0,d0.w),a0
	
	move.w #NOOP,d4
	move #10,d5	; no. of entrys in copDialogueFlex
	move.l (a0)+,d1
	move.l d1,(a2)+
.fetchCopFlex
	movem.w (a0)+,d0/d1
	cmp.w d4,d0
	beq .cleanUp
	movem.w d0/d1,(a2)
	lea 4(a2),a2
	dbra d5,.fetchCopFlex
.cleanUp
	move.w (a0)+,d0	; get exit COLOR00
	move.w #NOOP,d4
	swap d4
	clr.w d4
	bra .fillUpLoop
.loop
	move.l d4,(a2)+
.fillUpLoop
	dbra d5,.loop
	rts
viewStageTable	
	; dialogue table pointers
	dc.w .stage0-viewStageTable,.stage1Escalation-viewStageTable,.stage2-viewStageTable,.stage3-viewStageTable, .stage4-viewStageTable
	; escalation table pointers
	dc.w .stage0-viewStageTable-10,.stage1Dialogue-viewStageTable-10,.stage2-viewStageTable-10,.stage3-viewStageTable-10,.stage4-viewStageTable-10
.stage4
;	CMOVE COLOR00,0
	CMOVE BPLCON3,$a<<12|BRDRBLNKF|%111<<9
	CMOVE BPLCON3,$a<<12|BRDRBLNKF|%111<<9
	CMOVE BPLCON3,$a<<12|BRDRBLNKF|%111<<9
	CMOVE BPLCON3,$a<<12|BRDRBLNKF|%111<<9
	CMOVE NOOP,0
	dc.w $300
.stage1Escalation
	CMOVE BPLCON3,$0020
	CMOVE COLOR00,$b99
	CMOVE COLOR17,$caa
	CMOVE COLOR18,$da9
	CMOVE COLOR19,$dda
	CMOVE COLOR20,$cb9
	CMOVE COLOR21,$db9
	CMOVE COLOR22,$c99
	CMOVE COLOR23,$dcc
	CMOVE BPLCON3,$a<<12|BRDRBLNKF|%111<<9
	CMOVE BPL2MOD,-39*40
	CMOVE NOOP,0
	dc.w -1
.stage1Dialogue
	CMOVE BPLCON3,$0020
	CMOVE COLOR00,$744
	CMOVE COLOR17,$854
	CMOVE COLOR18,$a64
	CMOVE COLOR19,$aa6
	CMOVE COLOR20,$974
	CMOVE COLOR21,$a74
	CMOVE COLOR22,$743
	CMOVE COLOR23,$a99
	CMOVE BPLCON3,$a<<12|BRDRBLNKF|%111<<9
	CMOVE NOOP,0
 	dc.w $744
.stage2
	CMOVE BPLCON3,$a<<12|BRDRBLNKF|%111<<9
	CMOVE BPLCON3,$a<<12|BRDRBLNKF|%111<<9
	CMOVE BPLCON3,$a<<12|BRDRBLNKF|%111<<9
	CMOVE BPLCON3,$a<<12|BRDRBLNKF|%111<<9
	CMOVE NOOP,0
	dc.w $668
.stage3
	CMOVE BPLCON3,$B<<12|BRDRBLNKF
	CMOVE COLOR29,$200	; background sprites
	CMOVE COLOR30,$300
	CMOVE COLOR31,$400
	CMOVE BPLCON3,$a<<12|BRDRBLNKF|%111<<9
	CMOVE NOOP,0
	dc.w $010
.stage0
	CMOVE BPLCON3,$a<<12|BRDRBLNKF|%111<<9
	CMOVE BPLCON3,$a<<12|BRDRBLNKF|%111<<9
	CMOVE BPLCON3,$a<<12|BRDRBLNKF|%111<<9
	CMOVE BPLCON3,$a<<12|BRDRBLNKF|%111<<9
	CMOVE NOOP,0
	dc.w $56d
