
; #MARK: - BLITTERMANAGER

blitterManager
								clr.l					d0
								clr.l					d1
								clr.l					d2
								clr.l					d3
								clr.l					d4
								clr.l					d5
								clr.l					d6
								clr.l					d7


								clr.w					blitterManagerFinished																																																						; reset finish & launch flags
								lea						CUSTOM,a6
								clr.l					d0
								clr.l					d4
								move.w					#%00001001<<8+%11110000,d0
.drawZeroes
								swap					d0
								WAITBLIT
								move.l					d0,BLTCON0(a6)
								moveq					#-1,d0																																																										; prepare blitter for restoring pixels
								move.l					d0,BLTAFWM(a6)


								lea						bobRestoreList(pc),a5																																																						; keep two lists, one as buffer while screenmanager displays current framebuffer
								movem.l					(a5),d0-d1
								exg.l					d0,d1
								movem.l					d0-d1,(a5)																																																									; swap restore queue lists
								move.l					d0,a5

								move.w					#DMAF_SETCLR|DMAF_BLITHOG,CUSTOM+DMACON


								moveq					#%11111,d5
								moveq					#mainPlaneWidth/2,d6
								move.w					d6,a0
.bobClear
								movem.l					(a5)+,d0/d2																																																									; d2=bobRestoreListTarget
								tst.l					d0
								beq						.bobClearQuit
								WAITBLIT
.retDChannel
								movem.l					d0/d2,BLTAPTH(a6)
								move					d6,d1
								move.w					(a5)+,d0																																																									; bobRestoreListBlitSize
								sub						d0,d1
								and						d5,d1
								add						d1,d1
								move					d1,d2
								swap					d2
								move					d1,d2
								move.l					d2,BLTAMOD(a6)
								move					d0,BLTSIZE(a6)
								bra.b					.bobClear
.useDChannelOnly
								bclr					#15,d0
								move.w					#%00000001<<8+%11110000,BLTCON0(a6)
								sub						d0,d1
								and						d5,d1
								add						d1,d1
								move					d1,d2
								swap					d2
								move					d1,d2
								move.l					d2,BLTAMOD(a6)
								clr.l					BLTCDAT(a6)
								clr.w					BLTADAT(a6)
								move					d0,BLTSIZE(a6)
								movem.l					(a5)+,d0/d2																																																									; d2=bobRestoreListTarget
								tst.l					d0
								beq						.bobClearQuit
								WAITBLIT
								move.w					#%00001001<<8+%11110000,BLTCON0(a6)
								bra						.retDChannel

.bobClearQuit

								move					#$f000,d3
								clr.b					d3

								lea						CUSTOM,a6
								movem.l					mainPlanesPointer(pc),a1-a3																																																					; a1=draw, a2=restore
								lea						mainPlanesPointerAsync(pc),a5
								move.l					a3,(a5)+																																																									; pointer to blank background
								move.l					a1,(a5)																																																										; pointer to background

								move.l					bobDrawList(pc),a5																																																							; prime list -> draw
								move.l					bobRestoreList(pc),a4																																																						; secondary list -> buffer

								WAITBLIT
								move.w					#-1,BLTAFWM(a6)																																																								; set blitter mask only once before drawing stuff
.blitDrawLoop
								move.l					(a5),d7																																																										;bobDrawBLTMOD + bobDrawBLTSIZE
								beq.w					.bobDrawQuit																																																								; last bob already drawn? Prepare for restore code
								smi						d1
								ext.w					d1
								bclr					#31,d7
								move.l					d7,d0
								move.w					a0,d0
  	;move d4,d0		; calc screen modulus
								sub.b					d7,d0
								add						d0,d0
								WAITBLIT
								move.w					d1,BLTALWM(a6)
								move.l					d0,BLTAMOD(a6)																																																								; write to A & D
								swap					d0
								move.l					d0,BLTCMOD(a6)																																																								; modulus C & B

								movem.w					bobDrawBLTCON0(a5),d0/d2																																																					; get bltcon0 and source mask offset
								move					d0,d1
								and.w					d3,d1
								movem.w					d0/d1,BLTCON0(a6)

								clr.l					d0
								move.w					bobDrawTargetOffset(a5),d0
								lea						(a2,d0.l),a3
								move.l					bobDrawSource(a5),d1																																																						; get source adress
;.retForce
								move.l					a3,(a4)+																																																									; bobRestoreListSource; save mainplane source address for clearing code
								IFNE					DISABLEOPAQUEATTRIB
								tst.w					d2
								bmi						.forceBlitmode
								ENDIF
								lea						40(a1,d0.l),a3																																																								; get target adress bitmap 1 for background checking
								add.l					a1,d0
								tst.w					(a3)
								beq						.fastBlit																																																									; upper left sensor reports background clear? Switch to fastblit evaluation
.ret
								add.l					d1,d2																																																										; get mask adress
								lea						bobDrawListEntrySize(a5),a5
								move.l					d0,(a4)+																																																									; bobRestoreListTarget - save mainplane target address for clearing code
								move					d7,(a4)+																																																									;bobRestoreListBlitSize

								IFNE					BLITNORESTOREENABLED
								tst.w					d7
								bmi						.noRestore
.skipRestore
								ENDIF

								move.l					d0,d6
								movem.l					d0-d2/d6,BLTCPTH(a6)																																																						; feed blitter with memory pointers C=D=target,

								move					d7,BLTSIZE(a6)
								bra						.blitDrawLoop
								IFNE					DISABLEOPAQUEATTRIB
.forceBlitmode		; force cookie mode
								ext.w					d2																																																											; clear upper word
								ext.l					d2
								add.l					a1,d0
								move.w					bobDrawBLTCON0(a5),d6																																																						; get bltcon0
								bra						.retMask
								ENDIF

.fastBlit	; does object overlap with object/environment pixels? no->blit without mask, A/D only, much faster
.offset							SET						mainPlaneWidth
								move.w					d7,d5
								lsr.w					#8,d5																																																										; >>6 to get heigt, >> 2 for divide by number of bitplanes
								move.w					AddressOfYPosTable(pc,d5.w*2),d4																																																			; get adress offset lowest target bitmap
								lsr						d5
								move.w					AddressOfYPosTable(pc,d5.w*2),d5																																																			; get adress offset median target bitmap

								tst.w					-40(a3)																																																										; test median left
								bne						.ret
								tst.l					-40(a3,d5.l)																																																								; test median left
								bne						.ret
								tst.w					(a3,d5.l)																																																									; test median left
								bne						.ret
								tst.w					-40(a3,d4.l)																																																								; test lower left
								bne						.ret
								tst.w					(a3,d4.l)																																																									; test lower left
								bne						.ret
								move.w					d7,d6
								sub.b					#1,d6
								andi.w					#%111111,d6																																																									; get right border offset


								lea						(a3,d6.w*2),a3																																																								; source right border target adress
								tst.w					(a3)																																																										; test upper right
								bne						.ret
								tst.w					-40(a3)																																																										; test median right
								bne						.ret
								tst.w					(a3,d5.l)																																																									; test median right
								bne						.ret
								tst.w					-40(a3,d5.l)																																																								; test median right
								bne						.ret
								tst.w					(a3,d4.l)																																																									; test lower right
								bne						.ret
								tst.w					-40(a3,d4.l)																																																								; test lower right
								bne						.ret
.jmpin
								move.w					bobDrawBLTCON0(a5),d6																																																						; get bltcon0
								btst					#5,d6																																																										; test minterm. MaskDraw in Cookie Mode? Get Mask-Source not Bitmap-Source
								bne						.swapSourceMask
	;cmpi.b #1,d7	; uncomment to examine switch to word-aligned small blit (for upto 16 pixel wide objects)
	;beq .swapSourceMask
.retMask
								move.l					d0,(a4)+																																																									; bobRestoreListTarget - save mainplane target address for clearing code
								IFNE					BLITNORESTOREENABLED
								tst.w					d7
								bmi						.noRestoreFast
.retNoRestoreFast
								ENDIF
								move					d7,(a4)+																																																									;bobRestoreListBlitSize
								lea						bobDrawListEntrySize(a5),a5
								andi.w					#$f000,d6
								move.w					d6,BLTCON1(a6)
								or.w					#$9f0,d6
	;or.w #$fff,d6	;uncomment to blit bright full frame box
								move.w					d6,BLTCON0(a6)

								IFEQ					FASTBLITUNCOVER
								move.l					d1,BLTAPTH(a6)
								ELSE
								add.l					d1,d2
								move.l					d2,BLTAPTH(a6)
								ENDIF
								move.l					d0,BLTDPTH(a6)

								move					d7,BLTSIZE(a6)
								bra						.blitDrawLoop
.swapSourceMask
								add.l					d2,d1
								bra						.retMask
								IFNE					BLITNORESTOREENABLED
.noRestore
								bclr					#15,d7
								suba					#10,a4
								bra						.skipRestore
.noRestoreFast
								bclr					#15,d7
								suba					#10,a4
								bra						.retNoRestoreFast
								ENDIF
.bobDrawQuit
								clr.l					(a4)																																																										; mark end of blitter restore list
	;move.l mainPlanesPointer+8(pc),a1
	; write displayready main content to bitplanepointers@copperlist
.clip							SET						(mainPlaneWidth*mainPlaneDepth)*(viewUpClip-1)
								lea						.clip(a1),a1																																																								; do not display upper 8 lines of framebuffer
	;lea $a000(a1),a1
								move.l					a1,d0
								IF						1=1
								clr.l					d3
								move.b					plyPos+plyDistortionMode(pc),d3
								bne						.distortYshake
.retDistort
.noDistort


; #MARK: Write Bitplane Pointers

								lea						copBPLPT,a5
	;add.l #(40*4)*1,d0	;add.l (40*4)*1 is basic setting
								clr.w					d1
								moveq					#80,d2
								lsl						#2,d2


								move.b					killShakeIsActive(pc),d1
								bne						.doKillShakeY
.retKillShakeY
								add.l					d2,d0
								IFNE					1
	;lea $10000,a5
								WAITBLIT
								move.w					#DMAF_BLITHOG,CUSTOM+DMACON
								moveq					#mainPlaneWidth,d1
.tempVal						SET						6																																																											; write bplpt pointer mainplane to copsublist (small interleaved bitmap cant be scrolled by modyfing modulus)
								REPT					3
								move					d0,.tempVal(a5)
								swap					d0
								move					d0,.tempVal-4(a5)
.tempVal						SET						.tempVal+16
								swap					d0
								add.l					d1,d0
								ENDR
								move					d0,.tempVal(a5)
								swap					d0
								move					d0,.tempVal-4(a5)
								ENDIF
								ENDIF

	;tst.b dialogueIsActive(pc)
	;or.b escalateIsActive(pc)
	;bne .updateSecondaryPointers

								IFNE					0
								lea						bobDrawList(pc),a5
								movem.l					(a5),d0-d1
								exg.l					d0,d1
								movem.l					d0-d1,(a5)																																																									; swap drawing queue lists
								lea						12(a5),a5
								movem.l					(a5),d0-d1
								exg.l					d0,d1
								movem.l					d0-d1,(a5)																																																									; swap end of list comparators
								lea						blitterManagerFinished(pc),a0
								move.w					#-1,(a0)																																																									; set blitterManagerFinished, blitterManagerLaunch. Set active list now ready for drawing, set blitter frame finished
								ELSE
								lea						blitterManagerFinished(pc),a0																																																				; set blitter frame finished
								st.b					(a0)
								ENDIF
								rts
								IFNE					0
.updateSecondaryBplPointers
								lea						copGameDialgExitBPLPT,a1
   ; move.l mainPlanesPointer+4(pc),d7
								add.l					#(dialogueStart-displayWindowStart+dialogueHeight+1)*mainPlaneDepth*mainPlaneWidth,d7
								moveq					#40,d0
								bsr						updateBPLPT

updateBPLPT
								move					d7,6(a1)
								swap					d7
								move					d7,2(a1)
								swap					d7
								add.l					d0,d7
								move					d7,6+8(a1)
								swap					d7
								move					d7,2+8(a1)
								swap					d7
								add.l					d0,d7
								move					d7,6+16(a1)
								swap					d7
								move					d7,2+16(a1)
								swap					d7
								add.l					d0,d7
								move					d7,6+24(a1)
								swap					d7
								move					d7,2+24(a1)
								rts
								ENDIF
.doKillShakeY

								move.b					.killShakeY(pc,d1.w),d2
								ext.w					d2
								lsl.w					#2,d2
;	move.w #40*4*3,d2
								ext.l					d2
								bra						.retKillShakeY
.killShakeY
								dc.b					120,0,40,80,-40,80,0,120
								dc.b					40,-40,0,-40,40,-80,80,-120
.distortYshake
								move.w					fastRandomSeed(pc),d2
								andi					#%11,d2
								lsr						#2,d3
								not						d3
								andi					#3,d3
								lsr						d3,d2
								muls					#40*4,d2
								add.l					d2,d0
								bra						.retDistort
