
; #MARK: - PLAYER MANAGER BEGINS

plyManager

								lea					plyBase(pc),a6
								lea					viewPosition(pc),a0
								move.l				viewPositionAdd(a0),d2
								add.l				d2,plyPosY(a6)

								move.l				plyPosY(a6),d0
								move.l				viewPositionPointer(a0),d1
								sub.l				d1,d0
								swap				d0
								move.w				d0,plyPosYABS(a6)
								asl.l				#8,d2
								swap				d2
								move.w				d2,vPyAccConvertWorldToView(a0)

								tst.w				plyCollided(a6)
								bne.w				plyHitAnim
								tst.b				plyExitReached(a6)
								bne					plyFinal
								move.w				plyJoyCode(a6),d7
								clr.l				d6

;!!!: handle scrolling- and player-x-acceleration
plyJumpIn 		; needed for debugging to avoid scrolling



;#MARK: player movement


handlePlayerMovement
								move.w				plyAcclXCap(a6),d4
								move				d4,d6
								asr					#1,d6
								add					d6,d4

								tst					plyInitiated(a6)
								bne.b				.plyInit
.plyUpDown
								IFNE				PLAYERSPRITEDITHERED																																																						; for player collission tests, player is snail-paced
								btst				#STICK_BUTTON_ONE,d7																																																						; check firebutton 1
								bne					.nofb

								move.w				#plyAcclYMin-5,plyAcclYCap(a6)																																																				; already got highest speed?
								move.w				#plyAcclYMin-5,plyAcclXCap(a6)																																																				; already got highest speed?
								bra					.cont
.nofb							move.w				#plyAcclYMin*2,plyAcclYCap(a6)																																																				; already got highest speed?
								move.w				#plyAcclYMin*2,plyAcclXCap(a6)																																																				; already got highest speed?
.cont
								ENDIF

								btst				#JOY_DOWN,d7
								beq					.plyQueryUp
.plyGoDown
								tst.w				plyPosAcclY(a6)
								bmi					.plyInitPosY
								add.w				d4,plyPosAcclY(a6)
								bra					.plyTstBoundDwn
.plyInit
								subq				#1,plyInitiated(a6)
								bne.b				.initRuns

								move.w				#plyAcclYMin,plyAcclYCap(a6)
.initRuns
								move.w				plyInitiated(a6),d6																																																							; initial inertia
								move.b				(sineTable+49,pc,d6),d6
								ror.l				#4,d6
								swap				d6
								add.l				d6,plyPosY(a6)
								bra					.plyQueryLeftRight
.plyInitPosY
								move.w				d4,plyPosAcclY(a6)
								bra.b				.plyTstBoundDwn

.plyQueryUp
								btst				#JOY_UP,d7
								beq.b				.plyZeroYAccl
.plyGoUp
								tst.w				plyPosAcclY(a6)
								bgt					.plyInitNegY
								sub.w				d4,plyPosAcclY(a6)
								bra					.plyTstBoundUp
.plyInitNegY
								neg.w				d4
								move.w				d4,plyPosAcclY(a6)
.plyTstBoundUp
								cmpi				#$15,d0
								bgt.b				.plyQueryLeftRight
								moveq				#$15,d6
								bra.b				.wrtYPos
.plyTstBoundDwn
								cmpi				#$dc,d0
								blt.b				.plyQueryLeftRight
								clr.l				d6
								move				#$dc,d6
.wrtYPos
								swap				d6
								add.l				viewPosition+viewPositionPointer(pc),d6
								move.l				d6,plyPosY(a6)
.plyZeroYAccl
								clr.w				plyPosAcclY(a6)

.plyQueryLeftRight
								btst				#JOY_RIGHT,d7
								beq.b				.plyQueryLeft
.plyGoRight
								tst.w				plyPosAcclX(a6)
								bmi.b				.plyInitPosX
								add.w				d4,plyPosAcclX(a6)
								bra.b				.plyTstBoundRgt
.plyInitPosX
								move.w				d4,plyPosAcclX(a6)
								bra.b				.plyTstBoundRgt

.plyQueryLeft
								btst				#JOY_LEFT,d7
								beq					.plyZeroXAccl
.plyGoLeft
								tst					plyPosAcclX(a6)
								bgt.b				.plyInitNegX
								sub.w				d4,plyPosAcclX(a6)
								bra.b				.plyTstBoundLft
.plyInitNegX
								neg.w				d4
								move.w				d4,plyPosAcclX(a6)
.plyTstBoundLft
								cmpi				#8,plyPosX(a6)
								bgt.b				.plyXfinish
								move				#8,d5
								bra.b				.wrtXPos
.plyTstBoundRgt
								cmpi				#232,plyPosX(a6)
								blt.b				.plyXfinish
								move				#232,d5
.wrtXPos
								swap				d5
								clr.w				d5
								move.l				d5,(a6)																																																										;plyPosX
.plyZeroXAccl
								clr.w				plyPosAcclX(a6)


.plyXfinish
	;clr.w plyPosAcclX(a6)
								moveq				#-7,d6
								add.w				plyPosX(a6),d6
    ;lsr #4,d6
    ;move.w d6,plyPosXDyn(a6); dynamic offset, used for horizontal scrolling    ;
	;subq #3,d6
	;move.w d6,plyPosXDynAlt(a6)
		;#FIXME: temp. disabled plyPosXDynAlt. Still needed?
								add.w				#viewDownClip-30,d6

;#MARK: Player shot control
.plyShotControl
	;move.b #3,plyWeapUpgrade(a6)
	;move #plyAcclXMin+2*3,plyAcclXCap(a6)
	;move #plyAcclXMin+2*3,plyAcclYCap(a6)

								IFEQ				(RELEASECANDIDATE||DEMOBUILD)
;   keypress 1 -> weap down, 2-> weap up
								tst.w				keyArray+Key2(pc)
								beq					.smooth1
								cmpi.b				#plyWeapUpgrMax,plyWeapUpgrade(a6)
								bge					.smooth2
								add.b				#1,plyWeapUpgrade(a6)
								add.w				#2,plyAcclXCap(a6)
								add.w				#2,plyAcclYCap(a6)
								move.b				plyWeapUpgrade(a6),d0
	;add.w #1,objCount
								subq.b				#1,d0
								lsl					#5,d0
								addq				#1,d0
								move.b				d0,plyWeapSwitchFlag(a6)
	;ADDSCORE 10
								PLAYFX				21
.smooth1
								tst.w				keyArray+Key1(pc)
								beq					.smooth2
								tst.b				plyWeapUpgrade(a6)
								beq					.smooth2
								sub.b				#1,plyWeapUpgrade(a6)
								sub.w				#2,plyAcclXCap(a6)
								sub.w				#2,plyAcclYCap(a6)
								move.b				plyWeapUpgrade(a6),d0
								add.b				#1,d0
								lsl					#5,d0
								bset				#7,d0
								subq.b				#1,d0
								PLAYFX				22

								move.b				d0,plyWeapSwitchFlag(a6)
	;ADDSCORE 10
.smooth2
								ENDIF


; keypress code ends

								clr.l				d6
								move.b				plyFire1Auto(a6),d6
								bpl					.autoShoot
								clr.w				d0
								IFNE				PLAYERAUTOFIRE
								bra					.fbPressed
								ENDIF
								btst				#STICK_BUTTON_ONE,d7																																																						; is primary firebutton tapped?
								beq					.released
.fbPressed
								addq				#1,d0																																																										; yes!
								add.b				d0,plyFire1Flag(a6)
								bra.b				.shotManager
.released
								clr.b				plyFire1Flag(a6)
	;andi.b #$1,plyShotCnt(a6)
.shotManager


								move.b				plyFire1Auto(a6),d6
								tst.b				d0
								beq					plyNoFire

								move.b				#1,plyFire1Flag(a6)
.plyShoot	; init player shot

								clr.w				d5
								move.b				plyWeapUpgrade(a6),d1
								andi				#3,d1																																																										; index to weapon upgrade
	;move.b (.addShots,pc,d1.w),d5
	;add.w d5,plyShotsFired(a6)	; queried in achievements screen

								cmpi.w				#FBHOLD,plyJoyCode+6(a6)
								shi					d4
								andi.w				#4,d4
								add.w				d4,d1

								move.b				(.freq.W,pc,d1.w),plyFire1AutoB(a6) shot frequency
								move.b				#20,plyFire1Auto(a6)																																																						; 32	; length of one fire burst
								bra					plyNoFire
;.addShots
;	dc.b 5,10,16,0

.autoShoot	; fire row of shots automatically after first init

								move.b				plyFire1Auto(a6),d0
								subq.b				#1,plyFire1Auto(a6)
								bmi.w				plyNoFire

								clr.w				d5
								clr.w				d1
								move.b				plyWeapUpgrade(a6),d1
								bne					.initXtraShot
.initMainShot
	;bra plyNoFire
								sub.b				#1,plyFire1AutoB(a6)																																																						; shot frequency
								bne					plyNoFire
								clr.w				d1
								move.b				plyWeapUpgrade(a6),d1

								cmpi.w				#FBHOLD,plyJoyCode+6(a6)
								shi					d4
								andi.w				#2,d4


								move.b				(.freq.W,pc,d1.w),d6
								add.b				d4,d6																																																										; double firerate if fb tapped

								move.b				d6,plyFire1AutoB(a6)
								bra					.initShot
.freq
								dc.b				4,4,4,0
.freqHold
								dc.b				7,7,6,0

.xtraFreq
								IFNE				0
								dc.b				-1,-1,-1,-1,-1,-1,-1,-1
								dc.b				-1,-1,-1,-1,-1,-1,-1,-1
								dc.b				-1,-1,-1,-1,-1,-1,-1,-1
								dc.b				-1,-1,-1,-1,-1,-1,-1,-1
								ENDIF

								dc.b				0,-1,-1,-1,-1,-1,-1,0
								dc.b				-1,-1,-1,-1,-1,-1,-1,-1
								dc.b				0,-1,-1,-1,-1,-1,-1,0
								dc.b				-1,-1,-1,-1,-1,-1,-1,-1

								dc.b				0,-1,-1,-1,-1,-1,-1,1
								dc.b				-1,-1,-1,-1,-1,-1,-1,-1
								dc.b				0,-1,-1,-1,-1,-1,-1,1
								dc.b				-1,-1,-1,-1,-1,-1,-1,-1

	;blk.b 256,-1
								dc.b				0,-1,-1,-1,-1,1,-1,-1
								dc.b				-1,-1,0,-1,-1,-1,-1,1
								dc.b				-1,-1,-1,-1,0,-1,-1,-1
								dc.b				-1,1,-1,-1,-1,-1,-1,-1
								even

.weapEmit
								dc.l				.initShot, .initShot,.initShot
.shotPointers
								dc.l				cPlyShtAAnimPointer,cPlyShtAAnimPointer,cPlyShtBAnimPointer, cPlyShtBAnimPointer
.xtraPointer
								dc.l				cPlyShtCAnimPointer, cPlyShtDAnimPointer
.xtraXMod
								dc.b				30,4,36,-10
.xtraXAcc
								dc.b				40,-40,95,-90
.initXtraShot
								lsl					#5,d1
								lea					(.xtraFreq,pc,d1),a1
								move				d0,d3
								andi				#$1f,d3
								move.b				(a1,d3),d1
								bmi					.initMainShot
								move.l				([.xtraPointer,pc,d1*4]),a5
								move.w				animTablePointer+2(a5),d4

								move.w				#147,d5
								add.b				(.xtraXMod,pc,d1),d5
								add					(a6),d5																																																										;plyPosX
								sub.w				plyPos+plyPosXDyn(pc),d5																																																					;Convert absolute to relative
								clr.l				d6

								move				plyPosY(a6),d6
								sub					#8,d6
								sf.b				d3
								bsr					objectInitShot
								tst.l				d6
								bmi.w				.initMainShot

								add.w				#1,plyShotsFired(a6)

								clr.b				objectListAttr(a4)																																																							; code read attribs from object defs


								move.b				(.xtraXAcc,pc,d1),d1
								ext.w				d1
								lsl					#4,d1
    ;move #-32<<6,d1
    ;clr.w d1
								move.w				d1,objectListAccX(a4)																																																						; no x-accl
    ;move.w #-30<<6,d1

								move.l				viewPosition+viewPositionAdd(pc),d1
								asr.l				#8,d1																																																										; get scroll speed -> tare y-velociy no matter how fast background moves
								sub.w				#30<<6,d1																																																									;32

								add					d1,objectListAccY(a4)																																																						; add y-accl
								bra					.initMainShot

.initShot

								move.l				([.shotPointers.W,pc,d1*4]),a5
								move.w				animTablePointer+2(a5),d4

								move.w				(.xMod,pc,d1*2),d5
								add					(a6),d5																																																										;plyPosX
								sub.w				plyPos+plyPosXDyn(pc),d5																																																					;Convert absolute to relative
								move				plyPosY(a6),d6
								sub					#1,d6
								sf.b				d3
								bsr					objectInitShot

								tst.l				d6
								bmi					plyNoFire

								lea					plyBase,a6
								add.w				#1,plyShotsFired(a6)

    ;move #,objectListHit(a4); hitpoints
								clr.b				objectListAttr(a4)																																																							; code read attribs from object defs


								move.l				viewPosition+viewPositionAdd(pc),d1
								asr.l				#8,d1																																																										; get scroll speed -> tare y-velociy no matter how fast background moves
								sub.w				#36<<6,d1																																																									;32
								move.w				d1,objectListAccY(a4)																																																						; add y-accl
								clr.w				objectListAccX(a4)																																																							; no x-accl
								PLAYFX				fxShot
								bra.b				plyNoFire
.xMod
								dc.w				165,165,163
plyShotYOffset      ; + = upper position
.y=39
;    dc.w .y,.y+4,.y-4,.y+2
;    dc.w .y-4,.y+6,.y-8,.y+8
								dc.w				.y,.y+2,.y,.y-2
								dc.w				.y-4,.y+3,.y+4,.y-3
plyNoFire

   ; fade colors of player shots when switching weaponry


								tst.b				plyWeapSwitchFlag(a6)
								beq.b				playerMovement																																																								; no colorfade going on
								bpl.b				.switchup																																																									; msb -> fade up or down

								sub.b				#1,plyWeapSwitchFlag(a6)
								bra.b				.switched
.switchup
								add.b				#1,plyWeapSwitchFlag(a6)
.switched
								clr.w				d0
								move.b				plyWeapSwitchFlag(a6),d0
								bclr				#7,d0
								lsr					#1,d0
								move.b				d0,d1
								andi.b				#%1111,d1
								bne.b				.playerColors
								clr.b				plyWeapSwitchFlag(a6)
								bra.w				playerMovement
.playerColors
								bsr					dynamicPlayerColors

playerMovement


								clr.w				d3
								clr.l				plyAcclXABS(a6)
								move.l				plyAcclXCap(a6),d5
								move.l				d5,d7
								move.l				plyPosAcclX(a6),d0																																																							; load x and y-accl
								move.l				d0,d4
								move				d0,d1
								beq.b				.chkXAccl
								smi					d6																																																											; moves up?
								ext.w				d6
								eor					d6,d5																																																										; yes - neg Y-acc
								eor					d6,d1
								cmp.w				d5,d1
								blt					.wrtYAccl
								move				d5,d0
								lsr					#1,d6
								addx				d3,d0																																																										; modify y-acc incase of moving up
.wrtYAccl
								move.w				d0,plyAcclYABS(a6)
								swap				d0
								clr.w				d0
								asr.l				#2,d0
								add.l				d0,plyPosY(a6)																																																								;plyPosY

.chkXAccl                       ; same for ply x-accl
								swap				d4
								swap				d7
								move				d4,d1
								beq.b				plyCollision
								smi					d6
								ext.w				d6
								eor					d6,d7
								eor					d6,d1
								cmp.w				d7,d1
								blt					.wrtXAccl
								move				d7,d4
								lsr					#1,d6
								addx				d3,d4																																																										; needed to
.wrtXAccl
								move.w				d4,plyAcclXABS(a6)
								swap				d4
								clr.w				d4
								asr.l				#2,d4
								add.l				d4,plyPosX(a6)																																																								;plyPosX

; #MARK: player collission
plyCollision

								move				$dff00e,d0

								IFEQ				PLAYERCOLL
								bra					plyColQuit
								ENDIF

								btst				#1,d0																																																										; hit background?
								bne					plyChkColBck
	;bra plyChkColBck
plyBulletCheck
								andi.w				#1<<10+1<<9,d0																																																								; registered sprite (2 or 4) collission?
								tst.w				d0
								bne					plyBulletHit
								rts
plyBulletHit
	; hardware registered player<->bullet hit. Recheck with bounding box!

								move.l				objectList(pc),a3
								moveq				#4,d4
								sub.l				d4,a3
								clr.w				d6
								clr.w				d1
								clr.w				d3
								move				(a6),a4																																																										;plyPosX
								sub.w				plyPos+plyPosXDyn(pc),a4																																																					;Convert
.hitboxXWidth					SET					16
.hitboxYWidth					SET					14
								clr.w				d2
								tst.w				plyBase+plyPosAcclX(pc)
								beq					.playerShipCentred
								smi.b				d2																																																											; adjust x-position if sprite tilts left or right
								andi				#2,d2																																																										; either 0 or 2
								sub.b				#1,d2																																																										; either -1 or 1
								ext.w				d2
.playerShipCentred
								lea					$aa+(.hitboxXWidth/4)(a4,d2),a4																																																				; higher preval -> move colbox to the right end of playership
    ; centre basic x val / tested = $ac

								move				plyPosY(a6),a5
								lea					$23(a5),a5																																																									; higher preval -> move colbox to the lower end of playership
								move.l				animDefs(pc),a6
								move				#-.hitboxXWidth,d2																																																							; hitbox x-width - need to adjust x-pos too; see code above
								move				#-.hitboxYWidth,d6																																																							; hitbox y-width
								move				objCount(pc),d7
								bra					.nextObject
;chkPlyCol
.checkEntry
								adda.w				d4,a3
								tst					(a3)																																																										;objectListAnimPtr
								beq.b				.checkEntry
								move				(a3),d1																																																										;objectListAnimPtr
								lea					(a6,d1),a2																																																									; Accelerate x and y - read from animDefAcc
								clr.w				d3
								move.b				animDefType(a2),d3
								lea					([(objectDefs).w,pc],d3*8),a2																																																				; Pointer to animDefinitions
								move.b				objectDefAttribs(a2),d0
								bpl.b				.nextObject																																																									; no sprite? Check right now
    ;#FIXME: Player shot chk needed?
								btst				#6,d0
								bne.b				.nextObject																																																									; bonus sprite icon? Skip too
.calcDist
								move.w				objectListY(a3),d0
								sub.w				a5,d0
								cmp.w				d6,d0																																																										; height of colbox
								blo					.nextObject
	;bra kick

								move.w				objectListX(a3),d1
								sub.w				a4,d1
								cmp.w				d2,d1
								bhi					playerHit
.nextObject
								dbra				d7,.checkEntry
fuckIt
								rts


    			; adjust colors in player aprite
dynamicPlayerColors
								lea					CUSTOM,a4

								move.l				colorFadeTable(pc),a0
								lea					128(a0),a1
								lea					2+(128*2)(a0),a2
						; write shot colors to color regs
								move.l				(a0,d0*4),d1
								move.w				(a2,d0*4),d2
								move.l				(a1,d0*4),d3
								move				#%1110000000000000,BPLCON3(a4)
    ; player shots

								movem.w				d1-d3,COLOR01(a4)																																																							; main weapon
								swap				d1
								swap				d2
								swap				d3
								move				#%1110001000100000,BPLCON3(a4)
								movem.w				d1-d3,COLOR01(a4)
								rts
plyChkColBck	; basic coldetection for playership -> check hit with bitplane0

								lea					AddressOfYPosTable(pc),a2
								move.l				mainPlanesPointer+8(pc),a1
								moveq				#11,d4																																																										;y-offset
								clr.l				d5
.HitBoxXWidth					SET					12																																																											; set bit 0 to 0
								move				#$168-((.HitBoxXWidth+1)/2),d5																																																				;x-offset
								sub.w				plyBase+plyPosXDyn(pc),d5
								move.w				#2*mainPlaneDepth*mainPlaneWidth,d3
.hitBckChk
								add.w				plyPosYABS(a6),d4																																																							; load player y-coords
								move.w				(a2,d4.w*2),d4																																																								; y bitmap offset
								lea					-40(a1,d4.l),a1


								add.w				plyPosX(a6),d5
								ror.l				#3,d5
								lea					(a1,d5.w),a1																																																								; add x-byte-offset
								clr.w				d5
								swap				d5
								rol					#3,d5																																																										; put bit pointer in place
								IFNE				0
								bfset				(a1){d5:.HitBoxXWidth}																																																						; set 8 bits
								bfset				2*mainPlaneDepth*mainPlaneWidth(a1,d3.w*2){d5:.HitBoxXWidth}																																												; set 8 bits
								bfset				4*mainPlaneDepth*mainPlaneWidth(a1,d3.w*4){d5:.HitBoxXWidth}																																												; set 8 bits
	;bra plyColQuit
								ENDIF
								bftst				(a1){d5:.HitBoxXWidth}
								bne					playerHit
								bftst				2*mainPlaneDepth*mainPlaneWidth(a1,d3.w*2){d5:.HitBoxXWidth}
								bne					playerHit
								bftst				4*mainPlaneDepth*mainPlaneWidth(a1,d3.w*4){d5:.HitBoxXWidth}
								bne					playerHit
.quit
								bra					plyBulletHit																																																								; no background hit. Now check bullet hit
; #MARK: player hit animation
playerHit
								move.b				plyDistortionMode(a6),d5
								lea					plyBase(pc),a6
								tst					plyInitiated(a6)
								bne					plyColQuit
								tst					plyCollided(a6)																																																								; is already dying
								bne					plyColQuit
								cmpi.b				#8,plyDistortionMode(a6)																																																					; hack to trigger deathseq incase of heat screen distortion (boss0)
								beq					.hitPlayer
								tst.b				plyDistortionMode(a6)																																																						; weapon downgrading?
								bne					plyColQuit
.hitPlayer

								IFNE				PLAYERSPRITEDITHERED																																																						; ATTN: Set PLAYERCOLL=1, SHOWRASTERBARS=1 Too!
								clr.w				CUSTOM+BPLCON3
								move				#-1,CUSTOM+COLOR00
								rts
								ENDIF
	;#!!!:Temp code to pause game when player is hit
	;lea gameInActionF(pc),a4
    ;bchg #0,(a4)

								move.l				weapDstrAnimPointer(pc),a4
								move.w				animTablePointer+2(a4),d4																																																					;add  object to control distortion mode
								move				objectListX(a0),d5
								add.w				#$15,d5
								moveq				#-40,d6
								add					collTableYCoords(a3),d6																																																						; get y-coord from shot
								st.b				d3
								bsr.w				objectInit
								tst.l				d6
								bmi.w				.quit

								subq.b				#1,plyWeapUpgrade(a6)																																																						; destroy current weapon
;    addq.b #1,plyWeapUpgrade(a6)         ; destroy current weapon
								bmi					.initDeath
.cheatRetPoint
								move.b				plyWeapUpgrade(a6),d1

								move				d1,d0
								addq.b				#1,d1
								lsl					#5,d1
								bset				#7,d1
								subq.b				#1,d1
								move.b				d1,plyWeapSwitchFlag(a6)
								PLAYFX				13

								cmpi.w				#plyAcclXMin,plyAcclXCap(a6)
								bls.b				.minReached
								sub.w				#2,plyAcclXCap(a6)
								sub.w				#2,plyAcclYCap(a6)
.minReached
	;move.l a6,a1
	;st plyDistortionMode
    ;lea plyPos(pc),a0           ; init particle rain
								move				#$66,d3
								sub.w				plyPosXDyn(a6),d3
								add.w				plyPosX(a6),d3																																																								;plyPosX
	    	;#FIXME: Check use  plyPosXABS
	;sub.w viewPosition+viewPositionPointer(pc),d3
								sub					#60,d3
								lsl					#4,d3
								move.w				plyPosY(a6),d4
								sub.w				viewPosition+viewPositionPointer(pc),d4
								add.w				#16,d4
								lsl					#8,d4
								clr.w				d5																																																											;x-acc
								clr.w				d6																																																											;y-acc
								lea					emitterExtraLoss(pc),a0

								jmp					particleSpawn																																																								; apawn particle rain after hit equipped ship

; #MARK: player death  animation
.cheater
								addq.b				#1,plyWeapUpgrade(a6)																																																						; destroy current weapon
								bra					.cheatRetPoint

.initDeath		; init death sequence
	;tst.b plyCheatEnabled(a6)
	;bne.b .cheater
								btst				#optionSFXBit,optionStatus(pc)
								bne.b				.keepMusic																																																									; fx switched off?

								SAVEREGISTERS
								lea					CUSTOM,a6
								move.b				#%0000,d0
								bsr					_mt_musicmask																																																								; enable all channels for sfx

								lea					CUSTOM,a6
								move				#musicPauseVolume,d0
								bsr					_mt_mastervol																																																								; lower music volume

								RESTOREREGISTERS
.keepMusic
								DEBUGBREAK
								cmpi.b				#statusLevel1+1,gameStatus(pc)																																																				; is stage 0 or stage 1? Do not spawn continue-sprite
								bls					.noContinueSprite

								move.l				instSpwnAnimPointer(pc),a4
								move.w				animTablePointer+2(a4),d4																																																					;add  object to control quick resume mode
								move				#258+16,d5
								sub.w				plyBase+plyPosXDyn(pc),d5
								moveq				#24,d6
								add.w				viewPosition+viewPositionPointer(pc),d6
								st.b				d3
								bsr.w				objectInit																																																									; spawn Instant Respawn sprite
.noContinueSprite
								move				#30,frameCompare+2
								move				#30,frameCompare
								move				#1,plyCollided(a6)																																																							; init playerhit animation

								clr.l				viewPosition+viewPositionAdd																																																				; stop scrolling
.quit
								rts
storePlayerPos
								dc.w				0,0
plyHitAnim                  ; animation fatal player was hit

								move				#1,frameCompare+2																																																							; slow down frame update
.noInitDebris

	; handle quick resume / respawn


								move.b				#statusLevel0,d7																																																							; quick respawn at stage0
								DEBUGBREAK
								move.b				gameStatus(pc),d7
								cmpi.b				#statusLevel1+1,d7																																																							; is stage 0 or stage 1? No continue
								bls					.retFBreleased
								sub.b				#1,d7																																																										; prepare for quick respawn at current stage

								add.b				#1,plyFire1Flag(a6)																																																							;Firebutton triggered -> respawn at stage0
								cmpi.b				#192,plyFire1Flag(a6)
								bhi					.quickRespawn																																																								; write d7 to gameStatus, leave
								btst				#STICK_BUTTON_ONE,plyJoyCode(a6)																																																			; check firebutton 1 from stick
								beq					.FBreleased
.retFBreleased
								move.b				#statusTitle,d7																																																								; return to title incase of NO quick respawn
								addq				#1,plyCollided(a6)
								lea					transitionFlag(pc),a1
								cmpi				#370,plyCollided(a6)
								beq					.initFade																																																									; write d7 to gameStatus, leave
								moveq				#5,d7																																																										; slow down frame
								cmpi				#200,plyCollided(a6)
								bhi					.frameRate
								moveq				#3,d7
								cmpi				#180,plyCollided(a6)
								bhi					.frameRate
								moveq				#2,d7
								cmpi				#160,plyCollided(a6)
								bhi					.frameRate
								cmpi				#70,plyCollided(a6)
								bhi					.spawnDebris																																																								; debris
								cmpi				#61,plyCollided(a6)
								beq					.hidePlayer																																																									; playership hide
								cmpi				#60,plyCollided(a6)
								beq					.bigExplosion																																																								; playership explodes

								movem.w				plyPosAcclX(a6),d4/d5																																																						; drift player vessel / modify x- and y-position while particles rain
								lsl.l				#4,d4
								add.l				d4,plyPosX(a6)
								lsl.l				#4,d5
								add.l				d5,plyPosY(a6)
								move.l				plyPosY(a6),d4
								move.l				viewPosition+viewPositionPointer(pc),d5
								sub.l				d5,d4
								swap				d4
								move.w				d4,plyPosYABS(a6)


								lea					emitterKillA(pc),a0
								cmpi				#20,plyCollided(a6)
								beq					.spawnParticles																																																								; init particle rain
								cmpi				#15,plyCollided(a6)																																																							; init particle rain
								beq					.spawnParticles

								lea					emitterKillB(pc),a0
								cmpi				#10,plyCollided(a6)
								beq					.spawnParticles

								lea					emitterKillC(pc),a0
								cmpi				#2,plyCollided(a6)
								beq					.spawnParticlesFX
	;move #30,frameCompare
.quit
								rts
.FBreleased

								sf.b				plyFire1Flag(a6)																																																							; set to zero
								bra					.retFBreleased
.frameRate
								lea					frameCompare+2(pc),a0
								move				d7,(a0)
								rts
.hidePlayer
								move.w				#0,plyPosY(a6)
								rts
.bigExplosion
								lea					storePlayerPos(pc),a5
								moveq				#$24,d5
								sub.w				plyPosXDyn(a6),d5
								add.w				plyPosX(a6),d5
								move.w				d5,(a5)
								move.w				plyPosY(a6),2(a5)																																																							; save players position

								PLAYFX				fxExplBig
								PLAYFX				fxExplMed
								PLAYFX				fxExplSmall
								move.l				cExplLrgAnimPointer(pc),a4
								move.w				animTablePointer+2(a4),d4
								lea					storePlayerPos(pc),a1
								move.w				(a1),d5																																																										;plyPosX
								add					#165,d5
								move.w				2(a1),d6
								sub.w				#10,d6
								st.b				d3
								bsr					objectInit																																																									; big explosion to cover loss of player sprite
								tst.l				d6
								bmi					.quit
								move.b				#attrIsNotHitableF,objectListAttr(a4)																																																		; attribs
								rts
.quickRespawn	; re-init after fatal death bypassing title screen
								bsr					resetScores
.initFade
								lea					forceExit(pc),a0
								tst.b				(a0)
								bne					.fadeActive
								st.b				(a0)																																																										; init fade and quit
								lea					gameStatus(pc),a0
								move.b				d7,(a0)
.fadeActive
								rts

.spawnParticlesFX
.spawnParticles
								PLAYFX				fxLoseVessel

								moveq				#$2c,d3
								sub.w				plyBase+plyPosXDyn(pc),d3
								add.w				plyBase+plyPosX(pc),d3

								move.w				plyBase+plyPosY(pc),d4
								lsl					#4,d3
								sub.w				viewPosition+viewPositionPointer(pc),d4
								move.w				plyBase+plyPosYABS(pc),d4
								add.w				#16,d4
								lsl					#8,d4
								clr.w				d5																																																											; x-acc
								clr.w				d6																																																											; y-acc
								jmp					particleSpawn(pc)

.spawnDebris

								lea					storePlayerPos(pc),a1
								move				plyCollided(a6),d1
								move				d1,d7
								lsr					#3,d1
								andi				#7,d1
								clr.l				d5
								movem.w				(a1),d5/d6																																																									;plyPosX/Y
								add					#165,d5
debrisEntry
								clr.w				d3
								jmp					([(.debrisCases).W,pc,d1.w*4])
.debrisCases
								dc.l				.debrisA,.debrisH,.debrisC,.debrisF
								dc.l				.debrisD,.debrisD,.debrisD,.debrisH
.debrisH
								move.b				#fxExplSmall-1,d3
								move.l				cExplSmlAnimPointer(pc),a4
								bra.b				.initObject
.debrisF
								move.b				#fxExplBig-1,d3
								move.l				cExplMedAnimPointer(pc),a4
	;sub #20,d5
								bra.b				.initObject
.debrisD
								move.w				#fxExplMed-1,d3
								move.l				cExplLrgAnimPointer(pc),a4
								bra.b				.initObject
.debrisC
								move.l				debrisA3AnimPointer(pc),a4
								bra.b				.initObject
.debrisA
								move.l				debrisA4AnimPointer(pc),a4
.initObject
	;move.l cExplLrgAnimPointer(pc),a4
								andi				#$3,d7
								bne					.noFX
								tst.w				d3
								beq					.noFX
								movem.l				d0-d1/a0/a6,-(sp)
								lea					CUSTOM,a6
								move				d3,d4
								lsl					#3,d3
								lsl					#2,d4
								add					d4,d3

								lea					fxTable(pc,d3),a0
								bsr					_mt_playfx
								movem.l				(sp)+,d0-d1/a0/a6
.noFX
								move.w				animTablePointer+2(a4),d4
								st.b				d3
								bsr					objectInit

								tst.l				d6
								bmi.b				.quit /was: .noInitDebris
								move.b				#attrIsNotHitableF|attrIsOpaqF,objectListAttr(a4)																																															; attribs
								lea					vars(pc),a0
								clr.w				d7
								move.b				$bfe601,d7
								move.b				$dff006,d6
								andi				#3,d6
								rol.b				d6,d7
								move				d7,d6
								lsr					#4,d6
								add.w				d6,objectListY(a4)
								move				d7,d6
								lsl					#2,d6
								lsl					#3,d7
								add					d6,d7
								sub					#1620,d7
								move				d7,objectListAccY(a4)
								move.b				#31,objectListCnt(a4)

								movem.l				fastRandomSeed-vars(a0),d6/d7
								swap				d7
								add.l				d6,fastRandomSeed-vars+4(a0)
								add.l				d7,fastRandomSeed-vars(a0)

	;move.w $dff006,d7
	;move.b $bfe601,d6
	;eor.b d6,d7
								andi				#$1f,d7
								moveq				#$f,d6
								sub					d7,d6
	;add #200,d6
								add.w				d6,objectListX(a4)
								lsl					#5,d6
								move				d6,objectListAccX(a4)
.quit
								rts
plyColQuit
plyColQuitFromScore
plyFinal
								rts
    ;bra irqRetPlyManager

; #MARK: PLAYER MANAGER ENDS
