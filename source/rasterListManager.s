

; #MARK: - RASTERLIST MANAGER BEGINS
rasterListTitle:

				move.l		copSplitList(pc),a1
				move.l		(a1)+,a2																					; get adress of current subcoplist -> pointer to BPLCON1
				lea			-8(a2),a4																					; pointer to BPLMOD
				lea			coplineAnimPointers,a6
				andi		#$7f,d6
				move.l		(a6,d6*4),a5																				; get adress of anim table list

				move.l		4(a5),d5																					;; get first modulus
				move.w		(a1)+,d0
				move		d5,(a4,d0)
				lea			8(a5),a5
				move		copBPLCON1+2,d2																				; get value calc´d by basic scroll code
				andi		#$0f0f,d2
				swap		d5
				or			d2,d5

				move		d5,(a2,d0)
				move.w		#$7a,d7																						; no of scanlines/2
				lsr			#1,d7
				addq		#2,d7
.writeCopLine
				movem.l		(a5)+,d3-d4
				movem.w		(a1)+,d0-d1
				move		d3,(a4,d0)																					; write to BPLxMOD
				swap		d3
				or			d2,d3
				move		d3,(a2,d0)																					; write to BPL1CON
				move		d4,(a4,d1)
				swap		d4
				or			d2,d4
				move		d4,(a2,d1)
				dbra		d7,.writeCopLine
nilManager	; label needed in case of skipping subcode from irq code. Could use any rts
				rts


rasterListMove:
				lea			copSplitList(pc),a2

				move.l		(a2)+,a1																					; pointer to offset table
	;lea $6814BE04,a1
				move.w		(a2),d7																						; no of lines
				beq.b		nilManager

				move.l		(a1)+,a2																					; get adress of current subcoplist -> pointer to BPLCON1
				lea			coplineAnimPointers,a6

				lsr.w		d5,d6																						;modify anim speed

				move.w		plyBase+plyPosX(pc),d5
				lsr			#2,d5
				cmpi.w		#$39,d5
				bls			.sk
				move.w		#$39,d5
.sk
				move.l		(a6,d5*4),a5																				; get adress of anim table list. Full list contains an order of 12 (?) x-offsets -> x-scrolling


				move.w		frameCount+2(pc),d5
				asr			#2,d5
				andi		#$ff,d5
				lea			(a5,d5*2),a5																				; apply animation wave


				move		copBPLCON1+2,d2																				; get value calc´d by basic scroll code
				andi		#$0f0f,d2

				tst.b		escalateIsActive(pc)
				bne			.escalateMode

				tst.b		dialogueIsActive(pc)
				bne			.dialogueMode

	;move.b plyBase+plyDistortionMode(pc),d0

				tst.b		plyBase+plyDistortionMode(pc)
				bne.b		.distortionMode
;;	move.w copSplitList+4(pc),d7 ; how many lines in current copsublist?
				lsr			#2,d7
				sub			#1,d7
.writeCopLine
				movem.l		(a1)+,d0-d1
				movem.l		(a5)+,d3-d4
				eor			d2,d3
				move		d3,(a2,d0)																					; write to BPL1CON

				swap		d0
				swap		d3
				or			d2,d3
				move		d3,(a2,d0)

				or			d2,d4
				move		d4,(a2,d1)
				swap		d1
				swap		d4
				or			d2,d4
				move		d4,(a2,d1)

				dbra		d7,.writeCopLine
;	bra .quit
				movem.l		(a1)+,d0
				movem.l		(a5)+,d3

				or			d2,d3
				move		d3,(a2,d0)
				swap		d0
				swap		d3
				or			d2,d3
				move		d3,(a2,d0)
				rts
.distortionMode         ; shake screen a bit

				move.w		copSplitList+4(pc),d7
				subq		#1,d7
				clr.w		d3
				move.b		plyPos+plyDistortionMode(pc),d3
				lsr			#3,d3
				move		d3,d6
				lsl			#4,d6
				or			d6,d3
				moveq		#4,d6
.writeCopDistortion
				move.w		(a5)+,d4
    ;move d4,d5
				move.w		(a1)+,d0
				swap		d4
				or			d2,d4
				move.l		(a3),d1																						; AB
				move.l		4(a3),d5																					; CD
				swap		d5																							; DC
				add.l		d5,(a3)																						; AB + DC
				add.l		d1,4(a3)
				eor.b		d6,d1
				lsl			#1,d1
				move		d1,d5
				andi		#$0f,d5
				lsr			#1,d5
				ror			d6,d1
				move.b		d1,d5
				lsl			d6,d5
				or			d5,d1
				and			d3,d1
				eor.b		d1,d2
				tst.b		-2(a2,d0)																					; is $80?
	;beq.b .skip	; yes->skip shot/player split
				move.w		d4,(a2,d0)																					; write to BPL1CON
.skip
				dbra		d7,.writeCopDistortion
.quit
				rts
														; split view
.escalateMode
				moveq		#((escalateStart-displayWindowStart)/4),d6
.writeEscCopLow
				move.l		(a1)+,d0
				move.l		(a5)+,d3
				or			d2,d3
				move		d3,(a2,d0)																					; write to BPL1CON
				swap		d0
				swap		d3
				or			d2,d3
				move		d3,(a2,d0)
				dbra		d6,.writeEscCopLow

				move		#3,d4
				clr.w		d5
				move		d2,d3
				lea			$bfe601,a3
				move.b		escalateIsActive(pc),d1
				cmpi.b		#1,d1
				beq			.escalMore																					; first phase? Yes!
				move		d1,d4																						; text zoomed -> distort
				lsr.b		#5,d4
				cmpi.b		#4,d4
				bcs			.cap
				move.b		#3,d4
.cap
				move.b		$dff007,d1
.escalMore
				moveq		#(escalateHeight-4)/2,d6
				andi.w		#$fff,d3
				or.w		#%10<<14,d3

				lea			copGameEscalateSplits,a4
.writeEscCopCentre
	;move.l (a5)+,d3
				add.b		(a3),d1
				move.b		d1,d5
				lsr.b		d4,d5																						; modify strength of split line effect
				andi		#$f0,d5
				eor.b		d5,d3
				move		d3,6(a4)																					; write to BPL1CON
				lea			8(a4),a4
				dbra		d6,.writeEscCopCentre


				lea			26*2(a1),a1
				lea			26*2(a5),a5
	; modify two scanlines out of loop and write result to dialogue coplist too
				bsr			.modifySubViewBPL1CON
				move		d3,copGameEscExitBPLCON2+6																	; take care of last rastline escal view

				moveq		#($100+displayWindowStop-escalateStart+escalateHeight-195)/2,d7
	;lea -(escalateHeight-10)*2(a5),a5
	;lea escalateHeight-34(a1),a1
.writeEscCopHigh
				move.l		(a1)+,d0
				move.l		(a5)+,d3
	;moveq #-1,d3
				or			d2,d3
				move		d3,(a2,d0)																					; write to BPL1CON
				swap		d0
				swap		d3
				or			d2,d3
				move		d3,(a2,d0)
				dbra		d7,.writeEscCopHigh
				rts
.modifySubViewBPL1CON
				move.l		(a1)+,d0
				move.l		(a5)+,d3
				or			d2,d3
				move		d3,(a2,d0)																					; write to BPL1CON
				swap		d0
				swap		d3
				or			d2,d3
				move		d3,(a2,d0)
				rts

.dialogueMode
				lsr			#1,d7
				moveq		#((dialogueStart-displayWindowStart)/4),d6
				sub			d6,d7
.writeDialgCopLow
				move.l		(a1)+,d0
				move.l		(a5)+,d3
				or			d2,d3
				move		d3,(a2,d0)																					; write to BPL1CON
				swap		d0
				swap		d3
				or			d2,d3
				move		d3,(a2,d0)
				dbra		d6,.writeDialgCopLow

				move		#3,d4
				clr.w		d5
				move		d2,d3
				moveq		#(dialogueHeight-8)/4,d6
				sub			d6,d7
				andi.w		#$c0f,d3
				or.w		#%1000<<12!%101<<4,d3
.writeDialgCopCentre
				move.l		(a1)+,d0
				move		d3,(a2,d0)																					; write to BPL1CON
				swap		d0
				move		d3,(a2,d0)
				dbra		d6,.writeDialgCopCentre
				sub			#4,d7

	; modify two scanlines out of loop and write result to dialogue coplist too
				lea			40(a5),a5
				bsr			.modifySubViewBPL1CON
				move		d3,copGameDialgExitBPLCON0+6																; take care of last rastline dialogue view

.writeDialgCopHigh
				move.l		(a1)+,d0
				move.l		(a5)+,d3
				or			d2,d3
				move		d3,(a2,d0)																					; write to BPL1CON
				swap		d0
				swap		d3
				or			d2,d3
				move		d3,(a2,d0)
				dbra		d7,.writeDialgCopHigh
				rts



; #MARK: build raster list

rasterListBuild:          ; generate pointers to BPLCON1 in current copsublist. Called by macro COPPERSUBLIST
				lea			escalateEntry(pc),a0
				moveq		#(memoryPointersEnd-escalateEntry)/4-1,d7
.resetPointers
				clr.l		(a0)+
				dbra		d7,.resetPointers

				move.l		#tempVar+20,copColSprite																	; preload with harmless dummy value, in case no working entry is found

				move.l		copperGame(pc),a0
				move.l		copSplitList(pc),a1
				move.l		a0,(a1)+																					; store address of current coplist, pointers to all BPLCON1-regs behind
				clr.l		d0
				clr.l		d1
				clr.w		d3																							; used as counter for bulletColor. Do not modify!
				clr.w		d5																							; used as counter for spr7posEntry. Do not modify!
				lea			vars(pc),a5
.iterate
				addq.w		#4,d0
				move.l		(a0,d0),d6
				move.l		d6,d7
				swap		d6
				cmpi.w		#BPLCON1,d6																					; find entrys with scrolling regs
				beq			.scrolReg
				cmpi.w		#COPJMP1,d6																					; reached end of subcoplist
				beq.w		.finish
				cmpi.w		#NOOP,d6
				bne			.iterate
				move.w		.jT(pc,d7.w*2),d6																	; check for NOOP-cmd as initsignal for special copper fx
				
				jmp			.jT(pc,d6.w)
.jT
				dc.w		.iterate-.jT,.escalateEntry-.jT,.escalateExit-.jT,.gameFinEntry-.jT					; 0-3
				dc.w		.gameFinReturn-.jT,.iterate-.jT,.spr7pthEntry-.jT,.lowerScoreEntry-.jT				; 4-7
				dc.w		.iterate-.jT,.dialogueEntry-.jT,.dialogueExit-.jT,.achievementsEntry-.jT			;8-11
				dc.w		.achievementsQuit-.jT,.bpl2modReversal-.jT, .spr7posEntry-.jT, .colorBullet-.jT		;12-15
				dc.w		.availSlot-.jT
.scrolReg
				move		d0,d2
				addq		#2,d2
				move.w		d2,(a1)+																					; write pointer
				addq		#1,d1
				bra			.iterate
.spr7pthEntry
				lea			4(a0,d0.w),a2
				move.l		a2,copSPR6PTH-vars(a5)
				bra			.iterate
.spr7posEntry
				lea			4(a0,d0.w),a2
				IFEQ		(RELEASECANDIDATE||DEMOBUILD)																; overflow-errorcheck in pre-releasecode only
				cmpi		#(copSpr6posChk-copSpr6pos)/4-1,d5
				bls			.noError
.noError
				ENDIF
				move.l		a2,copSpr6pos-vars(a5,d5*4)
				addq		#1,d5
				bra			.iterate
.availSlot
				ILLEGAL
				bra			.iterate
.colorBullet
				lea			(a0,d0.w),a2
				move.l		a2,colorBullet-vars(a5,d3*4)
				addq		#1,d3
				bra			.iterate
.lowerScoreEntry
				lea			(a0,d0.w),a2
				move.l		a2,lowerScoreEntry-vars(a5)
				bra			.iterate
.gameFinEntry
				lea			(a0,d0.w),a2
				move.l		a2,gameFinEntry-vars(a5)
				move.l		#copGameFin,d2
				move		d2,10(a0,d0)
				swap		d2
				move		d2,6(a0,d0)
				move		#NOOP,12(a0,d0)																				; overwrite copJmp trigger
				bra			.iterate
.gameFinReturn
				lea			(a0,d0.w),a2
				move.l		a2,d2
				lea			copGameFinQuit,a2
				move.w		d2,6(a2)
				swap		d2
				move.w		d2,2(a2)																					; set return adress to main coplist in gamefin subcoplist
				bra			.iterate
.bpl2modReversal
				lea			6(a0,d0.w),a2
				move.l		a2,bpl2modReversal-vars(a5)
				bra			.iterate
.escalateEntry
				lea			(a0,d0.w),a2
				move.l		a2,escalateEntry-vars(a5)
				move.l		#copGameEscalate,d2
				move		d2,10(a0,d0)
				swap		d2
				move		d2,6(a0,d0)
				move		#NOOP,12(a0,d0)																				; overwrite copJmp trigger
				lea			escalateIsActive(pc),a2
				sf.b		(a2)
				add.w		#16,d0
				bra.w		.iterate

.escalateExit
				lea			(a0,d0.w),a2
				move.l		a2,escalateExit-vars(a5)
				add.w		#4,d0
				bra.w		.iterate

.modifyCopEnd
				lea			16(a0,d0.w),a6
				move.l		a6,d2
				move.w		d2,6(a2)
				swap		d2
				move.w		d2,2(a2)
				add.w		#16,d0
				bra.w		.iterate
.achievementsEntry
				lea			(a0,d0.w),a2
				move.l		a2,achievementsEntry-vars(a5)
				move.l		#copGameAchievements,d2
				move		d2,10(a0,d0)
				swap		d2
				move		d2,6(a0,d0)
				move		#NOOP,12(a0,d0)																				; overwrite copJmp trigger
				lea			copGameAchievementsEnd,a2
				bra			.modifyCopEnd
.achievementsQuit
				lea			(a0,d0.w),a2
				move.l		a2,achievementsQuit-vars(a5)
				move.l		#copGameAchievementsQuit,d2
				move		d2,10(a0,d0)
				swap		d2
				move		d2,6(a0,d0)
				move		#NOOP,12(a0,d0)																				; overwrite copJmp trigger
				lea			copGameAchievementsQuitEnd,a2
				bra			.modifyCopEnd

.dialogueEntry
				lea			(a0,d0.w),a2
				move.l		a2,dialogueEntry-vars(a5)
				move.l		#copGameDialogue,d2
				move		d2,10(a0,d0)
				swap		d2
				move		d2,6(a0,d0)
				move		#NOOP,12(a0,d0)																				; overwrite copJmp trigger
				lea			dialogueIsActive(pc),a2
				sf.b		(a2)
				add.w		#16,d0
				bra.w		.iterate

.dialogueExit
				lea			(a0,d0.w),a2
				move.l		a2,dialogueExit-vars(a5)
				add.w		#4,d0
				bra.w		.iterate

.colorMarker
				lea			10(a0,d0.w),a2
				move.l		a2,copColSprite-vars(a5)
				lea			4(a2),a2
				move.l		a2,copPriority-vars(a5)
				bra.w		.iterate
.finish
				clr.l		(a1)+

				move.w		#$18,d5
				move		d1,copSplitList+4																			; number of BPLCON1-regs in subcoplist
				lea			gameStatusLevel(pc),a0																		; preps - which kind of parallax anim?
				move.w		(a0),d0
				bpl.b		.titleCheck
				clr.w		d0
.titleCheck
				lea			rasListPrepJmpTbl(pc),a0
				move.w		(a0,d0*2),d6																				; fetch anim precalc jump offset

				move.l		copperGame(pc),a1
				move.l		(a1)+,a2																					; get adress of current subcoplist -> pointer to BPLCON1
    ;lea 4(a2),a4    ; pointer to BPLMOD
				suba.l		a4,a4
				lea			coplineAnimPointers,a6

				moveq		#8,d2																						; start value for 2nd scanline mod modifier
D7RASYCOUNT		EQUR		d7
D1frameCount	EQUR		d1
				move.l		(a6),a0																						; get adress of anim buffer
				moveq		#noOfCoplineAnims-1,D1frameCount															; build data for x anim / x-scroll frames
buildRasListFrame
				move		#(noOfCoplines*2)-1,D7RASYCOUNT																; build data for x coplines
	;move.w #$7f,d7
				move.l		(a6)+,a0																					; get adress of anim buffer
				move.w		#2,a5
buildRasList
				jmp			buildRasList(pc,d6.w)																; precalc PF2Hx and modulus for one frame
buildRasListMod
				adda		#2,a0
				dbra		d7,buildRasList
				adda		#noOfCoplines,a0
				dbra		d1,buildRasListFrame
				rts

rasListPrepJmpTbl	; precalc list offsets
				dc.w		.preStoreStage0-buildRasList
				dc.w		.preStoreStage1-buildRasList
				dc.w		.preStoreStage2-buildRasList
				dc.w		.preStoreStage3-buildRasList
				dc.w		.preStoreStage4-buildRasList
				dc.w		.preStoreStage5-buildRasList

.preStoreStage0
;	d1 = frames $3a - 0
;	d7 = coplines 0 - 127
				move		d7,d4
				asr			#1,d4
				clr.w		d2
				move.b		0+sineTable(pc,d4.w),d2																		; add sinus form
				asr			#1,d2
				muls		#30*3,d2
				divu		#27*3,d2
				move.w		d1,d4
				cmpi.b		#$10,d4
				blo			.skip
				move.b		#10,d4
.skip
				add.w		d1,d2
				move.w		scrollXbitsTable(pc,d2*2),d5
				bra			.pSS1
.preStoreStage1
;	d1 = frames 0-127
;	d7 = coplines 0 - 127
				move		d7,d4
				lsl			#2,d4
				andi.w		#$7f,d4
				clr.w		d2
				move.b		sineTable(pc,d4.w),d2																		; add sinus form
				move		#410,d3
				sub			d7,d3
				muls		d3,d2
				divu		#232<<4,d2
				add			d1,d2
				andi.w		#$7f,d2
				move.w		scrollXbitsTable+110(pc,d2*2),d5
.pSS1
				lsl			#4,d5
				move		d5,(a0)																						; prestore BPL1CON
				move		d5,noOfCoplines*2(a0)																		; prestore BPL1CON
				bra			buildRasListMod

.preStoreStage2
;	d1 = frames 0-127
;	d7 = coplines 0 - 127
				move.w		d1,d2
				muls		#9,d2
				lsr			#3,d2

				clr.w		d3
				move.w		d7,d3
				asr			#1,d3
				move.b		sineTable(pc,d3.w),d3																		; add sinus form
				asr			#1,d3
				add.b		d3,d2

				andi.w		#$7f,d2
				move.w		scrollXbitsTable+20(pc,d2*2),d5
				bra			.pSS1
.preStoreStage3

				move		d7,d4
				asr			#2,d4
				clr.w		d2
				move.b		0+sineTable(pc,d4.w),d2																		; add sinus form
				asr			#1,d2
				muls		#30*3,d2
				divu		#27*3,d2
				move.w		d1,d4
				cmpi.b		#$10,d4
				blo			.reachedBorder
				move.b		#10,d4
.reachedBorder
				add.w		d1,d2																						; background x-scrolling
				move		d7,d4
				add			d1,d4
				lsr			#2,d4
	;move d7,d4
	;lsr #2,d4

				andi		#$7,d4																						; d4 contains water ripple
				move.w		100+sineTable(pc,d4*2),d4																	; contains sidescrolling
				andi.w		#$f,d4

				move.w		scrollXbitsTable(pc,d2*2),d5																; contains sidescrolling
				lsl			#4,d4
				andi.w		#(%11<<8)|(%11<<4),d4
				add.w		d4,d5																						; add water ripple

				bra			.pSS1
.preStoreStage4
.preStoreStage5
;	d1 = frames 0-127
;	d7 = coplines 0 - 127
				move		d7,d4
				andi.w		#$7f,d4
				clr.w		d2
				move.b		sineTable(pc,d4.w),d2																		; add sinus form
				move.b		d2,d3
				lsr.b		#1,d2
				lsr.b		#4,d3
				add.b		d3,d2
				add			d1,d2
				andi.w		#$7f,d2
				move.w		scrollXbitsTable+50(pc,d2*2),d5
				bra			.pSS1
;.preStoreStage5
				move		d1,d4
				not			d4
				move		d7,d5
				lsr			#2,d5
				add			d5,d4
				andi		#$7f,d4
				move.b		80+sineTable(pc,d4.w),d3																	; add sinus form
				muls		#25,d3
				divu		#10,d3
				not.b		d3
				andi		#$7f,d3

				move.w		scrollXbitsTable(pc,d3*2),d5
				not.b		d5
				lsl			#4,d5
				andi		#$0f0,d5
				move		d5,(a0)																						; prestore BPL1CON
				bra			buildRasListMod
.preStoreNil
				bra			buildRasListMod

