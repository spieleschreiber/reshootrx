
; #MARK: - INIT GAME GLOBAL BEGINS
prepareInitGame
				WAITVBLANK

;	move.w #$41fa,chkBckCol;	enable col detection
				lea				 CUSTOM,a6
				lea				titleSprites,a0								; hide sprites
				moveq			#6,d0
				move			#$3000,d1
				move			#$f000,d2
.hideSprites
				move			d1,(a0)
				move			d2,8(a0)
				add.l			#titleSpritesOffset,a0
				dbra			d0,.hideSprites
				rts

initGameGlobal
	;bra.b .waitWelcome

   ; move.w #1,copBPLCON0+2    ; disable display
    ;move #%111111,copBPLCON2+2   ;video priority (sprites behind pf1)


	;move #0,copBPL2ModOffset+2		; adjust copperlist
    ;move #fxPlaneWidth-mainPlaneWidth,copBPL2MOD+2        ;bitplane modulos
	;move #mainPlaneWidth*(mainPlaneDepth-1),copBPL1MOD+2  ; basic modulus

				move.l			copPriority(pc),a0
				tst.l			a0
				beq				.skip
				move			#%011011,(a0)								; sprites to front
.skip

				IF				ALERTHANDLING=1								; reset alertvars
				clr.w			alertNumber
				clr.l			alertLine
				ENDIF


				jsr				prepareDisplay



				lea				CUSTOM,a6
				move			#$0,CLXCON2(a6)								; control sprite<->bck collissions
.clxcon			SET				$1<<14+$1<<13+$1<<12+$1<<6+1<<0
				move			#.clxcon,CLXCON(a6)							; control sprite<->bck collissions. Enable sprite 1 for player, 3 and 5 for ORing with sprite 2 and 4

	; #MARK: reset and rebuild preconfigured sprite dma list

				move.l			#(spritePosMemSize/4)-1,d0					;    reset sorting memory
				move.l			spritePosMem(pc),a0
.del2
				clr.l			(a0)+
				dbra			d0,.del2

				move.l			spritePlayerDMA(pc),a6
				move.l			#spritePlayerDMASize-4,d7
				jsr				CLEARMEMORY
				move.l			spriteDMAMem+8(pc),a6
				move.l			#spriteDMAMemSize,d7
				jsr				CLEARMEMORY

	;QUITNOW

;,fxPlaneWidth*fxPlaneHeightBig*fxPlaneDepth+16,d3	; clear all bitplanes - not needed anymore, as tileRenderer is doing the clearance



				lea				spriteBullet4pixels,a0
				moveq			#3,d4										; precalc 4 lists
.writeAllDMALists
				move.l			spriteDMAMem(pc),d0
				move.l			spriteDMAMem+4(pc),d2
				move.l			#spriteDMAListOffset,d7						; offset between each single sprite dma list
				lsl				#2,d7
				mulu			d4,d7
				add.l			d7,d0
				add.l			d7,d2
				moveq			#spriteDMAHeight-1,d1
.writeSingleDMAList
				move.l			d0,a1
				move.l			d2,a2
				move.w			#(bulletsMax-1)/4,d6
				move.w			#$1c18,(a1)+								; first sprite, not used ingame, used as restore source
				clr.l			(a1)+
				clr.w			(a1)+
				move.w			#$2000,(a1)+
				clr.l			(a1)+
				clr.w			(a1)+
				move.w			#$1c58,(a2)+								; first sprite, not used ingame, used as restore source
				clr.l			(a2)+
				clr.w			(a2)+
				move.w			#$2000,(a2)+
				clr.l			(a2)+
				clr.w			(a2)+
				bra.b			.firstSprite
.writeSingleSprite
				IF				1=1
				clr.l			(a1)										; reset position data all other dma sprites
				clr.l			4(a1)
				clr.l			8(a1)
				clr.l			12(a1)
				clr.l			(a2)
				clr.l			4(a2)
				clr.l			8(a2)
				clr.l			12(a2)
				ENDIF
.firstSprite
				IF				0=1											; 0=0 use predef´d numbers instead of bitplane data
				lea				.spriteTempNumbers,a3
				move			d4,d7
			;add.w d6,d7
			;andi #3,d7
				lsl				#4,d7
				lea				(a3,d7),a3
				bra				.skipTemp
.spriteTempNumbers
				dc.b			%00001100,0
				dc.w			0
				dc.b			%00010100,0
				dc.w			0
				dc.b			%00111100,0
				dc.w			0
				dc.b			%00000100,0
				dc.w			0

				dc.b			%00111000,0
				dc.w			0
				dc.b			%00000100,0
				dc.w			0
				dc.b			%00000100,0
				dc.w			0
				dc.b			%00111000,0
				dc.w			0

				dc.b			%00011000,0
				dc.w			0
				dc.b			%00000100,0
				dc.w			0
				dc.b			%00011000,0
				dc.w			0
				dc.b			%00111100,0
				dc.w			0

				dc.b			%00000100,0
				dc.w			0
				dc.b			%00001100,0
				dc.w			0
				dc.b			%00000100,0
				dc.w			0
				dc.b			%00000100,0
				dc.w			0
.skipTemp

				ELSE
				move.l			a0,a3
				ENDIF



				moveq			#spriteDMAHeight-1,d7
.writePixelRows
				movem.w			(a3),a4-a5									; read 1 line
;				move.w #$ffff,a4
;				move.w a4,a5
				move.w			a4,(a1)
				clr.w			2(a1)
				clr.l			4(a1)
				move.w			a5,8(a1)									; write 1 line
				clr.w			10(a1)
				clr.l			12(a1)

				movem.w			64(a3),a4-a5								; read 1 line
;				move.w #$ffff,a4
				move.w			a4,(a2)
				clr.w			2(a2)
				clr.l			4(a2)
				move.w			a5,8(a2)									; write 1 line
				clr.w			10(a2)
				clr.l			12(a2)
				addq			#4,a3
				adda			#spriteLineOffset,a1
				adda			#spriteLineOffset,a2
				dbra			d7,.writePixelRows
				lea				spriteLineOffset(a1),a1
				lea				spriteLineOffset(a2),a2
				dbra			d6,.writeSingleSprite
				clr.l			d6
				move.w			#spriteDMAListOffset,d6
				add.l			d6,d0
				add.l			d6,d2
				dbra			d1,.writeSingleDMAList
				lea				16(a0),a0
				dbra			d4,.writeAllDMALists


				lea				copSpriteDMA,a0								; write sprite DMA pointers to 8 sub copper lists. Have 4 lists for four sprite anim frames.

				move.l			spriteDMAMem(pc),d4
				move.l			#spriteDMAListOffset*4,d3
				move.l			#spriteDMAListOffset,d2
				moveq			#8,d1
				moveq			#3,d7
.wrtCopSpriteDMA			; write four lists
				move.l			a0,a1
				move.l			d4,d0
				moveq			#3,d6
.wrtSingleEntry				; write four entrys
				move			d0,6(a1)
				swap			d0
				move			d0,2(a1)
				swap			d0
				add.l			d1,a1
				add.l			d2,d0
				dbra			d6,.wrtSingleEntry
				add.l			d3,d4
				lea				copSpriteDMAOffset(a0),a0
				dbra			d7,.wrtCopSpriteDMA


				move.l			spriteDMAMem+4,d4							; prepare second set of copper sub lists, used for buffering / fast switching
				moveq			#3,d7
.wrtCopSpriteDMAB
				move.l			a0,a1
				move.l			d4,d0
				moveq			#3,d6
.wrtSingleEntryB
				move			d0,6(a1)
				swap			d0
				move			d0,2(a1)
				swap			d0
				add.l			d1,a1
				add.l			d2,d0
				dbra			d6,.wrtSingleEntryB
				add.l			d3,d4
				lea				copSpriteDMAOffset(a0),a0
				dbra			d7,.wrtCopSpriteDMAB

				lea				spriteCount(pc),a0
				clr.l			(a0)										; reset sprite dma lists
				bsr				spriteManager
				bsr				spriteManager

				move.w			scr2StartPos,d0								;write startposition all relevant pointers, reset player-flag
				add.w			#DisplayWindowHeight,d0
				swap			d0
				clr.w			d0
				lea				viewPosition,a3
				move.l			d0,viewPositionPointer(a3)
				move.l			viewPositionAdd(a3),d6
				moveq			#-1,d7
				clr.w			d7
				move.l			d7,viewPositionAdd(a3)


				move			#DisplayWindowHeight-1,d7
.drawLoop
				movem.l			d6/d7,-(sp)
				lea				viewPosition,a3
				move.l			viewPositionAdd(a3),d7
				add.l			d7,viewPositionPointer(a3)
				bsr				tileRenderer
				movem.l			(sp)+,d7/d6
				dbra			d7,.drawLoop

				lea				viewPosition,a3
				move.l			d6,viewPositionAdd(a3)
				move.w			scr2StartPos,d0								;write startposition all relevant pointers, reset player-flag
				swap			d0
				clr.w			d0
				move.l			d0,viewPositionPointer(a3)

				lea				plyBase(pc),a6								; setup player position, reset flags
				move			#254,d1
				swap			d1
				add.l			d1,d0
				move.l			d0,plyPosY(a6)
    ;clr.l plyPosAcclX(a6)
				move.w			#-640,d0
				move.w			d0,plyPosAcclY(a6)
				move.w			#122,d0										; centre x-position
				swap			d0
				move.l			d0,plyPosX(a6)
				clr.w			plyPosAcclX(a6)								; initial y-accl defined in playerController

				moveq			#90,d0
				move.w			d0,plyInitiated(a6)							; duration of init auto anim
				clr				plyCollided(a6)
				sf.b			plyExitReached(a6)
				st.b			plyFire1Auto(a6)
				st.b			plyFire1AutoB(a6)
    ;subq.b #1,plyFire1Auto(a6)
				sf.b			plyFire1Flag(a6)
				sf.b			plyFire1Hold(a6)
				sf.b			plyWeapUpgrade(a6)
				sf.b			plyWeapSwitchFlag(a6)
				sf.b			plyDistortionMode(a6)
				sf.b			plyShotCnt(a6)
				clr.l			plyShotsFired(a6)							;	 plyShotsFired+plyHitObjects
				clr.w			plyWaveBonus(a6)

				lea				plySprSaveCop(pc),a0
				clr.l			(a0)+
				clr.l			(a0)+
				clr.l			(a0)+
				clr.l			(a0)+


				moveq			#plyAcclXMin,d0
				move.w			d0,plyAcclXCap(a6)
				moveq			#plyAcclYMin+10,d0							; will be caped after auto init anim
				move.w			d0,plyAcclYCap(a6)

				lea				objectList+4(pc),a0
				move.l			(a0)+,(a0)									; reset dynamic objectList Pointer


				move.l			launchTable(pc),a0
				sub.l			launchTableEntryLength(pc),a0
				move.l			launchTableBuffer+4(pc),a1
				move.l			a1,launchTableBuffer


				move			viewPosition+viewPositionPointer(pc),d0
.animtabsrch
				add.l			launchTableEntryLength(pc),a0
				tst				(a0)
				bmi				.foundLastEntry
				move			launchTableY(a0),d1
				cmp				d1,d0
				bcs.b			.animtabsrch
				move.l			a0,a3
.animTabWrite
				move.l			launchTableEntryLength(pc),d7
				subq			#1,d7
.animtabwriteLoop
				move.b			(a3)+,(a1)+
				dbra			d7,.animtabwriteLoop
				bra				.animtabsrch
.foundLastEntry
				moveq			#-1,d7
				move.l			d7,(a1)

;	rts

; #MARK: Reset basic memory structures
				move.l			objectList(pc),a6
				move.l			#objectListSize,d7
				jsr				CLEARMEMORY
				lea				objCopyTable(pc),a6
				move.l			#objCopyEnd-objCopyTable,d7
				jsr				CLEARMEMORY
				movem.l			bobRestoreList(pc),a0/a1					; clear list of bobs to clear from background
				clr.l			(a0)
				clr.l			(a1)
				movem.l			bobDrawList(pc),a0/a1						; clear list of bobs to draw
				clr.l			(a0)
				clr.l			(a1)

				lea				vars(pc),a5
				clr				objCount-vars(a5)
				clr.l			spriteCount-vars(a5)
				clr				bulletLaunchSkipper-vars(a5)

				lea				bossVars-vars(a5),a1
				moveq			#(bossVarsSize/2)-1,d0
.resetBossVars	clr.w			(a1)+
				dbra			d0,.resetBossVars

				sf.b			forceExit-vars(a5)
				clr.l			frameCount-vars(a5)
				clr.l			frameCompare-vars(a5)						; set target framerate
	;move.l #$00010001,frameCompare
				move.w			#1,blitterManagerFinished-vars(a5)			; reset "" & blitterManagerLaunch

				tst				$dff00e										;   reset clxcon & collisionmarker

				lea				polyVars(pc),a1
				clr.l			xA1(a1)										; reset fillManagers xA1
				clr.l			polyBlitAddr(a1)
				clr.w			polyBlitAddr+4(a1)

				move.l			launchTableBuffer+4(pc),a1
				adda.l			launchTableSize(pc),a1
				sub.l			launchTableEntryLength(pc),a1
				moveq			#-1,d0
				move.l			d0,(a1)

				lea				particleBase(pc),a0
				moveq			#4,d0
.resetPartBase
				clr.l			(a0)+										; reset particle vars
				dbra			d0,.resetPartBase

				lea				particleTable,a6
				moveq			#partEntrySize,d6
				moveq			#particlesMaxNo,d7
				bra				.loop
.resetParticles
				clr.w			(a6)
				add.l			d6,a6
.loop
				dbra			d7,.resetParticles

; #MARK: Reset score variables

				lea				score(pc),a0
				IFEQ			INITWITH									; releaseversion:score reset in title code
				bsr				resetScores
				ENDIF
				move.l			#-1,scoreOld(a0)
				clr.l			scoreAdd(a0)
				clr.l			scoreMultiplier-score(a0)
				clr.b			scoreHighSuccessFlag-score(a0)


; #MARK: SCORE / HIGHSCORE SETTINGS -

				lea				scoreHigh(pc),a1
				move.l			(highDataLast.w,pc),d0
				addq.l			#1,d0
    ;move.l #$100003,d0; temp highscore setting
				move.l			d0,(a1)										; copy last hi table entry to highscore save var

	
				lea				copSprite67,a0								; write dma pointer sprite 0+1 -> coplist
				move.l			#infoPanelScore,d0
				subq			#8,d0
				subq			#8,d0
				move.l			d0,a1
				move.w			#spriteScoreCtlrWordLo,d1
				move.w			#spriteScoreCtlrWordHi,d2
				move.w			d1,(a1)
				move.w			d2,8(a1)
				move			d0,6(a0)
				swap			d0
				move			d0,2(a0)
				move.l			#infoPanelStatus,d0
				subq			#8,d0
				subq			#8,d0
				move.l			d0,a1
				move.b			#spriteStatusXPosition,d1

				move.w			d1,(a1)
				move.w			d2,8(a1)
				move			d0,6+8(a0)
				swap			d0
				move			d0,2+8(a0)

				clr.l			d0
				bsr				drawScore
				bsr				drawInfoPanel
				lea				score(pc),a0
				clr.l			scoreMultiplier-score(a0)					; do this here to avoid audio glitch
				rts


initGameSoundtrack
				lea				fxInit(pc),a0
				sf.b			(a0)										; fxInit
				st.b			d0

				bsr				installAudioDriver
				bra				initAudioTrack

; #MARK: INIT GAME GLOBAL ENDS
