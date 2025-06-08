

; #MARK:  prepare blitter objects



								moveq				#$1f,d0
								ror					#5,d0

bobPrepareDraw
								move.l				(a4),a0																																																										;objectDefSourcePointer
								adda.l				bobSource-vars(a5),a0																																																						; Adress of sourcebitmap
								andi				#$ff,d0
								jmp					([(animCases).w,pc,d0.w*8])																																																					; jump to specific anim code

;FIXME: Execute code only after draw-check
animReturn
								clr.l				d4
								clr.l				d7
								move.b				objectDefWidth(a4),d4																																																						; bob-Width in pixels
								move				d4,d5
								move				d4,d7
								addq				#7,d4
								lsr					#3,d4
								addq				#1,d4																																																										; bob-width for blitter

								clr.l				d6
								move				objectListX(a2),d6
								sub					d5,d6																																																										; center x-position


								move				objectListY(a2),a3
								tst.l				objectListMyParent(a2)
								bne					bobBlitIsChild
bobBlitChildReturn

								move				objectDefModulus(a4),d1
;	move d6,d0	; d6 = center coord
;	sub d5,d0	; d0 = leftmost x-coord
								add					d6,d5																																																										; d5 = rightmost x-coord

								move.l				collidingList+4(pc),a1
								move.l				a2,(a1)
								add.w				d5,d7
								movem.w				d6/d7,collTableXCoords(a1)																																																					; left / right border

	; check left clipping
								move				plyBase+plyviewLeftClip(pc),d0
								cmp.w				d0,d6																																																										;   bob outside left handside of view?
								ble					bobBlitCutLeft																																																								; yes - cut!

    ; check right clipping
								move				plyBase+plyviewRightClip(pc),d5
								cmp					d5,d7																																																										;leaves screen to the right?
								bgt					bobBlitCutRight

bobBlitDidHorizontalClip

								move				d1,(a6)																																																										;bobDrawBLTMOD
								clr.l				d0
								clr.l				d1
								clr.l				d5
								move.b				objectDefHeight(a4),d5
								move.b				d5,d0
								lsr					#1,d0

								move				a3,d1																																																										; y-pos relative
								sub					d2,d1																																																										; sub viewPositionPointer, get abs(y-pos)
								move				d1,d7
								add					d5,d7
								move.w				d1,collTableYCoords(a1)																																																						; write y-coord left corner to collission table
								moveq				#spriteDMAHeight-2,d0
								add					d7,d0
								move.w				d0,collTableYCoords+2(a1)																																																					; write y-coord right corner
				; d5 = bobhoee
				; d1 = bobypos

	;check clip view upper border
								move				#viewUpClip,d0
								cmp					d0,d1
								blt					bobBlitCutUp

	;check clip view lower border
								move.w				#viewDownClip,d0																																																							; attn.! value modified in player manager
								cmp					d0,d7
								bhi					bobBlitCutDown

addToColTable
								btst.b				#attrIsNotHitable,objectListAttr(a2)
								bne.b				.notHitable
								moveq				#collListEntrySize,d7
								add.l				d7,collidingList+4-vars(a5)
								addq				#1,bobCountHitable-vars(a5)
.notHitable

								move.w				AddressOfYPosTable(pc,d1*2),d1																																																				; get y-positions memory offset

								sub					#viewXOffset,d6
								move				d6,d0
								lsr					#3,d6

								subq.l				#4,d1
								add.l				d6,d1																																																										; add x-position to mainplane pointer
								bclr				#0,d1

								move				d0,d7
								moveq				#$f,d6
								and.l				d6,d7
								beq					blitZeroX																																																									; word-aligned blit, no pixelshift? Reduce blit size!

retBlitZeroX
								ror					#4,d7
								btst				#1,objectListHit+1(a2)																																																						; stamp
								bne					hitDisplay
								or					#$0fca,d7
drawBob
								move.l				a0,bobDrawSource(a6)																																																						; store source adress
								move.w				objectDefMask(a4),a0																																																						; get source mask offset
								movem.w				d1/d7/a0,bobDrawTargetOffset(a6)																																																			; store pointer to target adress, bltcon0, source mask offset,

								lsl					#8,d5																																																										; x 4 for 4 bitplanes, add bob height to blit control word
								or					d5,d4

								IFNE				DISABLEOPAQUEATTRIB
								btst.b				#attrIsOpaq,objectDefAttribs(a4)
								bne					blitEnableOpaque
retblitEnableOpaque
								ENDIF

								IFNE				BLITNORESTOREENABLED
								btst				#attrIsOpaq,objectDefAttribs(a4)
								bne					bobIsOpaque
bobRetIsOpaque
								ENDIF
								move				d4,bobDrawBLTSIZE(a6)
								add					#1,bobCount+2-vars(a5)
								cmp.l				bobDrawList+16(pc),a6
								bcc					objectListQuit
								lea					bobDrawListEntrySize(a6),a6

objectListNextEntry
								dbra				d3,bobBlitLoop

objectListQuit
								clr.l				(a6)																																																										;mark eof bobdrawlist

	; check amount of objects. If too many: forbid new objects spawning

								clr.w				objectWarning-vars(a5)
								move.w				spriteCount+2-vars(a5),d0
								move.w				d0,spriteCount-vars(a5)
								cmpi				#bulletsMax-1,d0
								bhi					issueWarningSprites

								move.w				bobCount+2-vars(a5),d0
								move.w				d0,bobCount-vars(a5)
								cmpi				#tarsMax,d0
								bhi					issueWarningBobs
								rts
blitZeroX
								sub					#1,d4																																																										; modify blitsize
								add					#2,(a6)																																																										; modify modulus
								bset				#15,(a6)																																																									; flag for use in blittermanager
								bra					retBlitZeroX
hitDisplay
								bchg				#0,objectListHit+1(a2)
								btst				#0,objectListHit+1(a2)
								beq.b				.keepHitMarker2
								andi.b				#$fc,objectListHit+1(a2)
.keepHitMarker2
								or					#$0ffa,d7
								bra					drawBob

bobBlitIsChild
								move.l				a2,a1																																																										; is children object -> add all parent coords
.readParent
								move.l				objectListMyParent(a1),a1
								tst.l				a1
								beq					bobBlitChildReturn
								add.w				objectListX(a1),d6
								add.w				objectListY(a1),a3
								bra.b				.readParent


bobBlitCutLeft
								move				d0,d7
								sub					d6,d7																																																										; left hangover

								add.w				plyBase+plyPosXDyn(pc),d6
								andi				#$f,d6
								add					d0,d6
								add					#1,d6																																																										; new x-coord

								lsr					#4,d7
								add					#1,d7
								sub					d7,d4																																																										; new blit x-size
								cmpi				#2,d4																																																										; x-blitsize < 2?
								blt					objectListNextEntry																																																							; yes - out of view
								lsl					#1,d7																																																										; only 2,4,6 ...
								add					d7,a0																																																										; modify bitplane fetch adress
								add					d7,d1																																																										; ... and modulo
								bra					bobBlitDidHorizontalClip
bobBlitCutRight
								sub					d5,d7
								lsr					#4,d7
								add					#1,d7
								sub					d7,d4
								cmpi				#2,d4																																																										; x-blitsize < 2?
								blt					objectListNextEntry																																																							; yes - out of view
								lsl					#1,d7
								add					d7,d1
								bra					bobBlitDidHorizontalClip

bobBlitCutUp
								sub					d0,d1
	;sub #3,d1
								neg					d1
								sub					d1,d5
								ble.w				objectListNextEntry
    ;add.l (a1,d1*4),a0
								clr.w				d0
								move.w				objectDefModulus(a4),d0
								addq				#2,d0
								clr.w				d7
								move.b				objectDefWidth(a4),d7
								lsr.w				#2,d7
								add.w				d7,d0
								lsl.w				#2,d0
								muls				d0,d1
								adda.w				d1,a0																																																										; modify source adress

								clr.l				d1
								move				#viewUpClip,d1																																																								; topmost y-coord
								bra					addToColTable
bobBlitCutDown
								sub					d0,d7
								sub					d7,d5
								bmi.w				objectListNextEntry
								addq				#1,d5
								bra					addToColTable

								IFNE				DISABLEOPAQUEATTRIB
blitEnableOpaque
								bset				#15,bobDrawMaskOffset(a6)
	;sub.b #1,d4		; modify blitsize
	;add #2,(a6)		; modify modulus
	;cmpi.b #$ca,d7
	;beq retblitEnableOpaque
								move.l				a0,d0
								add.l				d0,bobDrawSource(a6)																																																						; store source adress
								bra					retblitEnableOpaque
								ENDIF

								IFNE				BLITNORESTOREENABLED
bobIsOpaque
								bset				#15,d7
								bra					bobRetIsOpaque
								ENDIF

issueWarningSprites
								ALERT01				msgTooManySprites,spriteCount(pc)
								st.b				objectWarning+1-vars(a5)
								rts
issueWarningBobs
								ALERT01				msgTooManyObjects,bobCount(pc)
								st.b				objectWarning-vars(a5)
								rts

