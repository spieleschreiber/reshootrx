

; #MARK: - RASTERLIST MANAGER BEGINS
rasterListTitle:

				move.l		copFramesPointers(pc),a1
				move.l		(a1)+,a2																			; get adress of current subcoplist -> pointer to BPLCON1
				lea			-8(a2),a4																			; pointer to BPLMOD
				lea			coplineAnimPointers,a6
				andi		#$7f,d6
				move.l		(a6,d6*4),a5																		; get adress of anim table list

				move.l		4(a5),d5																			;; get first modulus
				move.w		(a1)+,d0
				move		d5,(a4,d0)
				lea			8(a5),a5
				move		copBPLCON1+2,d2																		; get value calc´d by basic scroll code
				andi		#$0f0f,d2
				swap		d5
				or			d2,d5

				move		d5,(a2,d0)
				move.w		#$7a,d7																				; no of scanlines/2
				lsr			#1,d7
				addq		#2,d7
.writeCopLine
				movem.l		(a5)+,d3-d4
				movem.w		(a1)+,d0-d1
				move		d3,(a4,d0)																			; write to BPLxMOD
				swap		d3
				or			d2,d3
				move		d3,(a2,d0)																			; write to BPL1CON
				move		d4,(a4,d1)
				swap		d4
				or			d2,d4
				move		d4,(a2,d1)
				dbra		d7,.writeCopLine
nilManager	; label needed in case of skipping subcode from irq code. Could use any rts


rasterListMove:
	
				lea			copFramesPointers(pc),a2

				move.l		(a2)+,a1
																									; pointer to offset table
	;lea $6814BE04,a1
				move.w		(a2),d7																				; no of lines
				beq.b		nilManager

				move.l		(a1)+,a2										
				lea			-8(a2),a4																			; pointer to BPLMOD
															; get adress of current subcoplist -> pointer to BPLCON1
				lea			coplineAnimPointers,a6

				lsr.w		d5,d6																				;modify anim speed

				move.w		plyBase+plyPosX(pc),d5
				
				lsr			#2,d5
				cmpi.w		#$39,d5
				bls			.sk
				move.w		#$39,d5
.sk
				;move.w		 frameCount+2($32,d5
				;move.l		(a6,d5*4),a5																				; get adress of anim table list. Full list contains an order of 12 (?) x-offsets -> x-scrolling
		
	lea	 viewPosition(pc),a3
				move.w		vfxPosition(a3),d5
				;move.w	 frameCount+2(pc),d5
				lsr	 #2,d5
				


				;add.w	 vfxPositionAdd(a3),d6
				;move.w	 d6,vfxPosition(a3)
							
								; update vfxPosition.w and vfxPositionAdd.w
	

				;clr.w	 d5
				;move.w		plyBase+plyPosX(pc),d5
				move.w	 d5,d4
				lsr			#3,d5
				
				andi		#$7f,d5
				
				;clr.w		d5																					; 13.06.2025 temp code to keep scrolling speed constant
				move.l		(a6,d5.w*4),a5
		;sub	 #8,d4
		lsr	 #3,d4
		;add	 #$01,d4
		andi.w	 #$7f,d4
				move.l		(a6,d4.w*4),a0

				move.w	 2(a5),d3;get first modulus
				move.w	 d3,vfxOffset(a3)											; write first modulus
				
				;TOSHELL d3,": Y"	
	;TOSHELL		a5,": X"												; apply animation wave
				;move		copBPLCON1+2,d2																		; get value calc´d by basic scroll code
				andi		#$0f0f,d2

				tst.b		escalateIsActive(pc)
				bne			.escalateMode

				tst.b		dialogueIsActive(pc)
				bne			.dialogueMode

	;move.b plyBase+plyDistortionMode(pc),d0
	
				tst.b		plyBase+plyDistortionMode(pc)
	bne		.distortionMode
;;	move.w copFramesPointers+4(pc),d7 ; how many lines in current copsublist?
		move.w frameCount+2(pc),d0
				;move.w		#$197+16*20,plyBase+plyPosY
				
				move.w		plyBase+plyPosY(pc),d5
			;sub.w	 #$197,d5
				
				move.w	 d5,d6
				lsr	 #4,d6
				lsr			#3,d5
				;sub.w	 #$18,d5
				;move.w	 #$1,d5
				add.w	 d6,d5
				lsr	 #1,d5
				sub.w	 #$24,d5
				;TOSHELL	 d5,": Y"
				clr.w	 d4
				
				
	;lea	 2(a1),a1

	move.l		(a0)+,d3
	move.w		(a1)+,d0
	move		d3,(a4,d0); BPL2MOD
	swap		d3
	or.w		 d2,d3
	move		d3,(a2,d0); BPL1CON
			;lea	-4(a0),a0
	
				move.w	 d5,d1
				sub	 #1,d1
.addupMods
				move.w	 6(a0),d3; fetch mod;
				sub	 #$14,d3
				add.w	 d3,d4
				lea	4(a0),a0
				dbra	 d1,.addupMods
	;		lea	 4(a0),a0
			add.w d4,vfxOffset(a3)

	lsr			#1,d7
	bcs	 .evenNoOfLines
	move.l		(a0)+,d3
	move.w		(a1)+,d0
						; apply animation wave
				;	TOSHELL	 d3,": MOD"
	;				clr.w	 d3
	move		d3,(a4,d0); BPL2MOD
	swap		d3
	or.w		 d2,d3
	move		d3,(a2,d0); BPL1CON
	sub	 #1,d7
.evenNoOfLines
	sub		#1,d7
.writeCopLine
	movem.l		(a0)+,d3-d4
	movem.w		(a1)+,d0-d1
						; apply animation wave
	move		d3,(a4,d0); BPL2MOD
	swap		d3
	or.w		 d2,d3
	move		d3,(a2,d0); BPL1CON
	move		d4,(a4,d1); BPL2MOD				
	swap		d4
	or			d2,d4
	move		d4,(a2,d1); BPL1CON
	dbra		d7,.writeCopLine
	rts

	rts


.distortionMode         ; shake screen a bit

				move.w		copFramesPointers+4(pc),d7
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
				move.l		(a3),d1																				; AB
				move.l		4(a3),d5																			; CD
				swap		d5																					; DC
				add.l		d5,(a3)																				; AB + DC
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
				tst.b		-2(a2,d0)																			; is $80?
	;beq.b .skip	; yes->skip shot/player split
				move.w		d4,(a2,d0)																			; write to BPL1CON
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
				move		d3,(a2,d0)																			; write to BPL1CON
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
				beq			.escalMore																			; first phase? Yes!
				move		d1,d4																				; text zoomed -> distort
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
				lsr.b		d4,d5																				; modify strength of split line effect
				andi		#$f0,d5
				eor.b		d5,d3
				move		d3,6(a4)																			; write to BPL1CON
				lea			8(a4),a4
				dbra		d6,.writeEscCopCentre


				lea			26*2(a1),a1
				lea			26*2(a5),a5
	; modify two scanlines out of loop and write result to dialogue coplist too
				bsr			.modifySubViewBPL1CON
				move		d3,copGameEscExitBPLCON2+6															; take care of last rastline escal view

				moveq		#($100+displayWindowStop-escalateStart+escalateHeight-195)/2,d7
	;lea -(escalateHeight-10)*2(a5),a5
	;lea escalateHeight-34(a1),a1
.writeEscCopHigh
				move.l		(a1)+,d0
				move.l		(a5)+,d3
	;moveq #-1,d3
				or			d2,d3
				move		d3,(a2,d0)																			; write to BPL1CON
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
				move		d3,(a2,d0)																			; write to BPL1CON
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
				move		d3,(a2,d0)																			; write to BPL1CON
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
				move		d3,(a2,d0)																			; write to BPL1CON
				swap		d0
				move		d3,(a2,d0)
				dbra		d6,.writeDialgCopCentre
				sub			#4,d7

	; modify two scanlines out of loop and write result to dialogue coplist too
				lea			40(a5),a5
				bsr			.modifySubViewBPL1CON
				move		d3,copGameDialgExitBPLCON0+6														; take care of last rastline dialogue view

.writeDialgCopHigh
				move.l		(a1)+,d0
				move.l		(a5)+,d3
				or			d2,d3
				move		d3,(a2,d0)																			; write to BPL1CON
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

				move.l		#tempVar+20,copColSprite															; preload with harmless dummy value, in case no working entry is found

				move.l		copperGame(pc),a0
				move.l		copFramesPointers(pc),a1
				move.l		a0,(a1)+																			; store address of current coplist, pointers to all BPLCON1-regs behind
				clr.l		d0
				clr.l		d1
				clr.w		d3																					; used as counter for bulletColor. Do not modify!
				clr.w		d5																					; used as counter for spr7posEntry. Do not modify!
				lea			vars(pc),a5
.iterate
				addq.w		#4,d0
				move.l		(a0,d0),d6
				move.l		d6,d7
				swap		d6
				cmpi.w		#BPLCON1,d6																			; find entrys with scrolling regs
				beq			.scrolReg
				cmpi.w		#COPJMP1,d6																			; reached end of subcoplist
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

				;move.w		#$18,-6(a0,d0)																		; reset playfield B modulus
				move		d0,d2
				addq		#2,d2
				move.w		d2,(a1)+																			; write pointer
				addq		#1,d1
				bra.b		.iterate

.spr7pthEntry
				lea			4(a0,d0.w),a2
				move.l		a2,copSPR6PTH-vars(a5)
				bra			.iterate
.spr7posEntry
				lea			4(a0,d0.w),a2
				IFEQ		(RELEASECANDIDATE||DEMOBUILD)														; overflow-errorcheck in pre-releasecode only
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
				move		#NOOP,12(a0,d0)																		; overwrite copJmp trigger
				bra			.iterate
.gameFinReturn
				lea			(a0,d0.w),a2
				move.l		a2,d2
				lea			copGameFinQuit,a2
				move.w		d2,6(a2)
				swap		d2
				move.w		d2,2(a2)																			; set return adress to main coplist in gamefin subcoplist
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
				move		#NOOP,12(a0,d0)																		; overwrite copJmp trigger
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
				move		#NOOP,12(a0,d0)																		; overwrite copJmp trigger
				lea			copGameAchievementsEnd,a2
				bra			.modifyCopEnd
.achievementsQuit
				lea			(a0,d0.w),a2
				move.l		a2,achievementsQuit-vars(a5)
				move.l		#copGameAchievementsQuit,d2
				move		d2,10(a0,d0)
				swap		d2
				move		d2,6(a0,d0)
				move		#NOOP,12(a0,d0)																		; overwrite copJmp trigger
				lea			copGameAchievementsQuitEnd,a2
				bra			.modifyCopEnd

.dialogueEntry
				lea			(a0,d0.w),a2
				move.l		a2,dialogueEntry-vars(a5)
				move.l		#copGameDialogue,d2
				move		d2,10(a0,d0)
				swap		d2
				move		d2,6(a0,d0)
				move		#NOOP,12(a0,d0)																		; overwrite copJmp trigger
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
				move		d1,copFramesPointers+4																; number of BPLCON1-regs in subcoplist
				lea			gameStatusLevel(pc),a0																; preps - which kind of parallax anim?
				move.w		(a0),d0
				bpl.b		.titleCheck
				clr.w		d0
.titleCheck
				lea			rasListPrepJmpTbl(pc),a0
				move.w		(a0,d0*2),d6																		; fetch anim precalc jump offset

				move.l		copperGame(pc),a1
				move.l		(a1)+,a2																			; get adress of current subcoplist -> pointer to BPLCON1
    ;lea 4(a2),a4    ; pointer to BPLMOD
				suba.l		a4,a4
				lea			coplineAnimPointers,a6

				moveq		#8,d2																				; start value for 2nd scanline mod modifier
				move.l		(a6),a0																moveq		#basicModulus,d0	
								; get adress of anim buffer
				moveq		#copFramesNoTotal-1,d1
buildRasListFrame
				moveq		#coplines-1,d7																		; build data for x coplines
	;moveq		 #2,d7
				move.l		(a6)+,a0																			; get adress of anim buffer
				lea	 2,a5	; prep a5 as flag
																				; preload basic modulus
buildRasList
				jmp			buildRasList(pc,d6.w)																; precalc PF2Hx and modulus for one frame
buildRasListMod
	IFNE	 DEVBUILD

.frameToTest SET	 $d;
.lineToTest SET	 $d;
	cmpi.w		 #$7f-.frameToTest,d1
	bne			 .noFrameB
	cmpi.w		 #$80-.lineToTest,d7
	bgt			 .noFrameB
	nop
	;move.w		 #$10,d5
.noFrameB

	cmpi.w		 #$18,d1
	beq			 .noFrame
	nop
	
.noFrame
	ENDIF
				move		d5,2(a0)	
				;sub.w		 #4,2(a0)				
										; prestore BPLxMOD
				adda		#4,a0
				dbra		d7,buildRasList
				dbra		d1,buildRasListFrame
				;rts
				lea			coplineAnimPointers,a6

				moveq		#copFramesNoTotal-1,d1
				moveq		#copFramesNoTotal-1,d5

		move.w				gameStatusLevel(pc),d0
		move.b				.uglyTransforms(pc,d0),d6
		ext.w	 d6

.uglyFlickerFix
	clr.w	 d7
	move.w	 d1,d2
	cmpi.w	 #$7f,d1
	beq	 .frameZero
	add.w	 #1,d2
	cmpi.w	 #$6e,d1
	beq	 .modifyModulus
	cmpi.w	 #$4d,d1
	bne	 .frameZero
.modifyModulus	
	move.w d6,d7
.frameZero
	andi.w	 #$7f,d2
	move.l	 (a6,d1*4),a0
	move.l	 (a6,d2*4),a1
	move.w	2(a0),d3
	add.w	 d7,d3
	
	move.w	 d3,2(a1)
	sub.w	 #1,d5
	dbra	 d1,.uglyFlickerFix
	rts
.uglyTransforms
	dc.b	 -4,0,0,0,0
	even

rasListPrepJmpTbl	; precalc list offsets
				dc.w		preStoreSpace-buildRasList
				dc.w		preStoreSun-buildRasList
				dc.w		preStoreSky-buildRasList
				dc.w		preStoreOcean-buildRasList
				dc.w		preStoreCity-buildRasList
				dc.w		preStoreOutro-buildRasList


basicModulus	SET			$14


preStoreBitsAndMod
; feed d3 with absolute line scroll value	
	move.l	 d3,d4
	;add.l	 #$3,d3; add 65536 to get positive value
	lsr.l  #5,d4;divide by 32 to get mod shift value 
	andi.w	 #$1f,d3; remainder for 0-31 pixel shifts

	lsl	#2,d3; multiply by 4 to skip subpixel bits
	move.w		scrollXbitsTable(pc,d3*2),d2
	lsl #4,d2
	move.w		d2,(a0)		; prestore BPL1CON
	
	cmp.w	 d4,d0
	beq	 .keepModulus
	bgt .shiftRight
.shiftLeft
	move.w	 d4,d5
	sub.w	 d0,d5
	lsl	 #2,d5
	add.w	 #basicModulus,d5
	;moveq	 #basicModulus+4,d5
	bra	 .gotIt
.shiftRight
	move.w	 d0,d3
	sub.w	 d4,d3
	lsl	 #2,d3
	move.w	 #basicModulus,d5
	sub.w	 d3,d5
	;moveq	 #basicModulus-4,d5
	bra	 .gotIt

.keepModulus
	moveq	 #basicModulus,d5
.gotIt
		move.w	 d0,d3
	move.w		 d4,d0; store abs x-value to next iter
	tst.w a5
	beq buildRasListMod	; modify first scanline modulus for correct appearance
	sub.l a5,a5	; first scanline done
	move.w	 d3,d5
	;move.w	 #-24+24,d5
	move.w	 d4,d5
	lsl.w	 #2,d5
	
	bra buildRasListMod

; d1 = frame 0-$3f, d7 =line 0-$7f, d5 = modulus. DONT USE D6!
; #MARK COPLIST CITY 
preStoreSpace
	
	clr.l	 d3
	move d1,d4
	
	andi #$7f,d4
	lea .space(pc),a3
	
	move.w	 #128,d3
	sub.w	 d7,d3
	andi #$7f,d3
	move.b (a3,d3),d3
	muls d4,d3
	lsr #6,d3		; if you change this ...
	
	bra preStoreBitsAndMod
.space
	;blk.b	 256,$20
	dc.b 	01,$7c,$7d
;@generated-datagen-start----------------
; This code was generated by Amiga Assembly extension
;
;----- parameters : modify ------
;expression(x as variable): round(-sin(x/43)*43)+128
;variable:
;   name:x
;   startValue:6
;   endValue:256
;   step:1
;outputType(B,W,L): B
;outputInHex: true
;valuesPerLine: 16
;--------------------------------
;- DO NOT MODIFY following lines -
 dc.b $7a, $79, $78, $77, $75, $74, $73, $72, $71, $70, $70, $6f, $6e, $6c
 dc.b $6b, $6a, $69, $68, $68, $67, $66, $65, $64, $64, $63, $62, $61, $61, $60, $5f
 dc.b $5f, $5e, $5e, $5d, $5c, $5c, $5b, $5b, $5a, $5a, $59, $59, $59, $58, $58, $57
 dc.b $57, $57, $57, $57, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56
 
 dc.b $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $57, $57, $57, $57, $58, $58, $58
 dc.b $58, $58, $5a, $5a, $5b, $5b, $5c, $5c, $5c, $5d, $5d, $5e, $5e,$5e,$5f, $5f, $60, $61, $61
 dc.b $62, $63, $64, $64, $65, $66, $67, $67, $68, $69, $6a, $6b, $6c, $6d, $6e, $6e
 dc.b $6f, $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7a, $7b, $7c, $7d, $7e
 dc.b $7f, $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $8a, $8b, $8c, $8d, $8e
 dc.b $8f, $90, $90, $91, $92, $93, $94, $95, $96, $97, $98, $98, $99, $9a, $9b, $9c
 dc.b $9c, $9d, $9e, $9f, $9f, $a0, $a1, $a1, $a2, $a2, $a3, $a4, $a4, $a5, $a5, $a6
 dc.b $a6, $a7, $a7, $a7, $a8, $a8, $a9, $a9, $a9, $a9, $aa, $aa, $aa, $aa, $aa, $ab
 dc.b $ab, $ab, $ab, $ab, $ab, $ab, $ab, $ab, $ab, $ab, $ab, $ab, $aa, $aa, $aa, $aa
 dc.b $aa, $a9, $a9, $a9, $a8, $a8, $a8, $a7, $a7, $a6, $a6, $a5, $a5, $a4, $a4, $a3
 dc.b $a3, $a2, $a1, $a1, $a0, $9f, $9f, $9e, $9d, $9d, $9c, $9b, $9a, $99, $99, $98
 dc.b $97, $96, $95, $94, $93, $93, $92, $91, $90, $8f, $8e
;@generated-datagen-end----------------

	even
; d1 = frame 0-$3f, d7 =line 0-$7f, d5 = modulus. DONT USE D6!
; #MARK COPLIST CITY 
preStoreCity
	clr.l	 d3
	move d1,d4
	
	andi #$7f,d4
	lea sinCity(pc),a3
	
	move.w	 #128,d3
	sub.w	 d7,d3
	andi #$7f,d3
	move.b (a3,d3),d3
	muls d4,d3
	lsr #6,d3		; if you change this ...
	bra preStoreBitsAndMod



sinCity
	;dc.b	 $0,$30,$30,$30
	;blk.b	 128,128
	;blk.b	 6,$55
	dc.b 	$55,$55,$56
;@generated-datagen-start----------------
; This code was generated by Amiga Assembly extension
;
;----- parameters : modify ------
;expression(x as variable): round(sin(x/49.1)*49.1)+78
;variable:
;   name:x
;   startValue:14
;   endValue:256
;   step:1
;outputType(B,W,L): B
;outputInHex: true
;valuesPerLine: 16
;--------------------------------
;- DO NOT MODIFY following lines -
 
 dc.b $56, $57, $59, $5a, $5b, $5d, $5e, $60, $61, $62, $63, $64, $65, $65, $67, $69
 dc.b $6a, $6b, $6c, $6d, $6d, $6e, $6f, $70, $70, $71, $72, $72, $73, $74, $74, $75
 dc.b $76, $76, $77, $77, $78, $78, $79, $79, $7a, $7a, $7b, $7b, $7b, $7c, $7c, $7d
 dc.b $7d, $7d, $7d, $7d, $7d, $7e, $7e, $7e, $7e, $7e, $7e, $7e, $7e, $7e, $7e, $7e
 dc.b $7e, $7e, $7e, $7e, $7e, $7e, $7e, $7e, $7e, $7e, $7e, $7e, $7d, $7d, $7d, $7d
 dc.b $7c, $7c, $7c, $7b, $7b, $7a, $7a, $79, $79, $78, $78, $77, $77, $76, $76, $75
 dc.b $74, $74, $73, $73, $72, $71, $70, $6f, $6e, $6d, $6d, $6c, $6b, $6a, $6a, $68
 dc.b $68, $67, $65, $64, $62, $61, $60, $5f, $5e, $5c, $5b, $5a,$59, $58, $5f, $f5
 ;@generated-datagen-end----------------





				even
preStoreSky

				move.w		#coplines*2-1,d3
				sub.w		d7,d3
				move		d1,d4
				lsl			#1,d4
				muls		d4,d3
				divu		#coplines*2+4,d3
				andi		#$7f,d3

				move		d3,d4
				move		d4,d5
				andi		#$0010,d5
				ror.w		#6,d5
				andi		#$f,d4
	;clr.w d4
				lsl			#4,d4
				or			d4,d5
	;clr.w d5
				move		d5,(a0)																				; prestore BPL1CON

				move		d3,d4
				add.w		#8,d4
				lsr			#3,d4																				; kill lower 32 pixels
				andi		#%111100,d4
				moveq		#$18,d5
				add.w		d4,d5
				cmp.w		d5,d0
				beq.b		.same
				bhi.b		.isHigher
				move		d5,d0
				moveq		#$14,d5
				bra.b		.write
.isHigher
				move		d5,d0
				bra.b		.write
.same
				moveq		#$18,d5
.write
				tst.w		a5
				beq			buildRasListMod																		; modify first scanline modulus for correct appearance
			; first scanline, modify modulus
				move.w		(a0),4(a0)																			; copy softscroll value
	;lea 4(a0),a0
				moveq		#$8,d5
				sub.l		a5,a5																				; first scanline done
				sub			d4,d5
				bra			buildRasListMod


preStoreOcean
				move		d1,d4
				move.w		#81,d3
				sub.w		d7,d3
				bpl.b		.sk1
				clr.w		d3
.sk1
				muls		d4,d3
				divu		#86,d3
				andi		#$7f,d3

				move		d3,d4
				move		d4,d5
				andi		#$0008,d5
				ror.w		#5,d5
				andi		#$7,d4
	;clr.w d4
				lsl			#5,d4
				or			d4,d5

	; add watery effect
				move		d5,(a0)																				; prestore BPL1CON
				move		d1,d5
				move		d7,d4
				not			d4
				andi		#$1f,d4
				andi		#$1f,d5
				cmp			d5,d4
				bne.b		preStorePerpB
				move		d7,d4
				lsr			#6,d4
				addq		#1,d4
				or			d4,(a0)
				bra.b		preStorePerpB

preStoreSun
				move		d1,d4
				move.w		#143,d3
				sub.w		d7,d3
				bpl.b		.sk1
				clr.w		d3
.sk1
				muls		d4,d3
				lea			sineTable(pc),a3
				move.b		(a3,d3),d5
				lsr			#1,d5
				add.w		d5,d3																				; add blur
				divu		#155,d3
				andi		#$7f,d3
				bra.b		preStorePerp
preStoreOutro
				move		d7,d3
				move		d1,d4
	;lsl #1,d4
				muls		d4,d3
				lsr			#7,d3
				andi		#$7f,d3
preStorePerp
				move		d3,d4																				;
				move		d4,d5
				andi		#$0008,d5
				ror.w		#5,d5
				andi		#$7,d4
	;clr.w d4
				lsl			#5,d4
				or			d4,d5
				move		d5,(a0)																				; prestore BPL1CON
preStorePerpB
				move		d3,d4
				add.w		#4,d4
				asr			#4,d4																				; kill lower 32 pixels
				andi		#%111,d4
				lsl			#2,d4
				move		d4,d5
				add			#basicModulus,d5
				cmp			d5,d0
				beq.b		.same
				bge.b		.isHigher
				move		d5,d0
				move		#(basicModulus-4)/2,d5
				bra.b		.write
.isHigher
																				; for testing only, should be $18
				move		d5,d0
				move		#(basicModulus+4)/2,d5
				bra.b		.write
.same
				move.w		#basicModulus,d5
.write
				tst.w		a5
				beq			buildRasListMod																		; modify first scanline modulus for correct appearance
				move.w		(a0),4(a0)																			; copy softscroll value
	;lea 4(a0),a0
				moveq		#$8,d5
				sub.l		a5,a5																				; first scanline done
				sub			d4,d5
				bra			buildRasListMod

preStoreSinewave
				move		d7,d4
				add			d1,d4
				andi.w		#$7f,d4

	;cc4
	;QUITPROGRAM

	;FIXME: Move LEA to init code to save cpu time?
				lea			sineTable(pc),a3
				clr.w		d3
				move.b		(a3,d4.w),d3																		; add sinus form
    ;lsl #1,d3            ; multiplicator for amplitude
				move		d3,d4
				move		d3,d5
    ;move d3,d2
				addq		#$8,d5
				andi		#$0010,d3
				ror.w		#6,d3
				andi		#$f,d4

				lsl			#4,d4
				or			d4,d3
				move		d3,(a0)																				; prestore BPL1CON
				not			d5
				andi		#%11100000,d5
				lsr.w		#3,d5

				move		d0,d3
				cmp			d5,d3
				beq			.keepMod
				cmp			d5,d3
				bge.b		.ss1
				move		d5,d0
				move		#$1c,d5
				bra.b		.safeMod
.ss1
				move		d5,d0
				move.w		#$14,d5
				bra.b		.safeMod
.keepMod
				move.w		#$18,d5
.safeMod
				tst.w		a5
				bne			.firstLines
				bra			buildRasListMod

.firstLines	; keep first scanline, modify modulus on second
				sub			#1,a5
				tst.w		a5
				beq			.secondRas
				bra			buildRasListMod
.secondRas
				cmpi		#$18,d5
				beq.s		.l3
				tst.b		(a4)
				bne.b		.l5
				cmpi.w		#$1c,d5
				bne.s		.l4
				move		d2,d5																				; add to modulus
				addq		#4,d5
				st.b		(a4)
				bra.s		.l6
.l4			; lower modulus
				move		d2,d5
				sub			#4,d5
				st.b		(a4)
	;move.w #$14,d5
				bra.s		.l6
.l3
				sf.b		(a4)
.l5
				move		d2,d5
.l6
				move		d5,d2
.safeMod2
				bra			buildRasListMod

