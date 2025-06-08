

;PX  25. 5. 2025
; Copyright (c) 2025 spieleschreiber UG | Richard Löwenstein



;{ <- this lines only purpose is to keep indents and formatting in Xcode right
								PRINTT
								PRINTT				"*** Compiling RRX.S"


								INCDIR				source/system/																																																								; search these folders for includes
								INCDIR				source/copperCode/
								INCDIR				source/animCode/
								INCDIR				source/customCode/
								INCDIR				source/
								INCDIR				include/
								INCDIR				include/system/



								INCLUDE				targetControl.i																																																								; define important target vars
								INCLUDE				cia.i
								INCLUDE				custom.i
								INCLUDE				exec_lib.i
								INCLUDE				dos_lib.i
								INCLUDE				intuition_lib.i
								INCLUDE				graphics_lib.i
								INCLUDE				constants.i

								SECTION				CODE


								INCLUDE				macro.s


_start
	
								clr.w				d3
						
								move.l				4.w,a6																																																										; a6 = ExecBase
								move.w				$14(a6),d7
								move.b				20(a6),d0																																																									; AttnFlags auslesen
								andi.b				#$F8,d0																																																										; nur die oberen 5 Bits
								cmpi.b				#$70,d0																																																										; Kickstart 2.0 = $70
        
        ; Ist mindestens KS 2.0
				
.loop
								move.w				d3,$dff180
								add.w				#1,d3
								lea					startUpGame,a0
						

								INCLUDE				startUp.s




	INCLUDE		loadFile.s

						
	INCLUDE		errorMessengers.s
	INCLUDE		inputHandler.s
	INCLUDE		saveState.s
	INCLUDE		preparations.s
	INCLUDE		colorManager.s
	INCLUDE		opening.s
	INCLUDE		titleManager.s
	INCLUDE		initLevelManager.s

	INCLUDE		mainManager.s
	
	INCLUDE		commons.s

	INCLUDE		initGameManager.s
	INCLUDE		mainGameLoop.s
	INCLUDE		blitterManager.s
	INCLUDE		fillManager.s
	INCLUDE		interruptManager.s
	INCLUDE		screenManager.s
	INCLUDE				 rasterListManager.s
	INCLUDE		particleManager.s
	INCLUDE		spriteManager.s
	INCLUDE		parallaxManager.s
	INCLUDE		playerManager.s
	INCLUDE		objectMoveManager.s
	INCLUDE		objectListManager.s	
	INCLUDE		objectListPrep.s
	INCLUDE		collissionManager.s
	INCLUDE			objectInitManager.s	 
	INCLUDE				 launchManager.s
	INCLUDE				 scoreManager.s
	



	INCLUDE		exit.s
	IFNE		SANITYCHECK
	INCLUDE		sanityCheck.s
	ENDIF



; #MARK: - FILENAME DEFINITIONS

tempFilename
								FILENAMEPREFIX
tempFilenameVar
								blk.b				64,0
tempFilenameVarEOF
								even
levDefFilename
								FILENAMEPREFIX
								dc.b				"levDefs/"
levDefFileVar
								blk.b				10,0
								even

mapDefsFile
								dc.b				"mapFoes0.tmx",0
animDefsFile
								dc.b				"anims0.plist",0
objectDefsFile
								dc.b				"objects0.plist",0
vfxDefsFile
								dc.b				"vfx.raw",0
tilePixelData
								dc.b				"mainTiles0.int",0																																																							; approx. 131 KB
colorDefsFile
    ;FILENAMEPREFIX
								dc.b				"mainColors0.pal",0
introPicture
								dc.b				"intropic.raw",0
introLogo	; 8 sprites 64 x 39 pixels, saved with ctrl words
								dc.b				"intro_spieleschreiber.raw",0


parallaxSpriteA
	;#FIXME: Map filename def´d the hard way temporaily
								dc.b				"parSprite0.raw",0
    ;FILENAMEPREFIX
    ;dc.b    "parSprite0.raw",0     ; ca. 4 KB (*32)
parallaxSpriteB
	;#FIXME: Map filename def´d the hard way temporaily
								dc.b				"parSpritB0.raw",0
    ;FILENAMEPREFIX
    ;dc.b    "parSprite0.raw",0     ; ca. 4 KB (*32)
								even


; #MARK: - GAME VARIABLES

gfxTileGridOffset				blk.l				$100


scr2Offset
								SCR2MOD				0
								SCR2MOD				1
								SCR2MOD				2
								SCR2MOD				3
								SCR2MOD				4
								SCR2MOD				5
								SCR2MOD				6
								SCR2MOD				7
								SCR2MOD				8


scr2LastOffset
								dc.l				0
scr2Flag
								dc.w				0
scr2StartPos
								dc.w				0
								even


; #MARK: - TEXT DEFINITIONS
titleHighInitials
								dc.b				"AAA"
titleCursor
								dc.b				0
titleCursorFlash
								dc.b				0
titleCursorOld
								dc.b				0
titleHighFlag
								dc.b				0
titleViewIndx
								dc.b				0


								rts

	


sineTable   ; 128 values, maxAmp=128, 1 oscillation, generated http://www.daycounter.com/Calculators/Sine-Generator-Calculator.phtml
								dc.b				64,67,70,73,76,79,82,85,88,91,93,96,99,101,104,106,108,111,113,115,116,118,120,121,122,123,124,125,126,126,127,127,127,127,127,126,126,125,124,123,122,121,120,118,116,115,113,111,108,106,104,101,99,96,93,91,88,85,82,79,76,73,70,67
								dc.b				64,60,57,54,51,48,45,42,39,36,34,31,28,26,23,21,19,16,14,12,11,9,7,6,5,4,3,2,1,1,0,0,0,0,0,1,1,2,3,4,5,6,7,9,11,12,14,16,19,21,23,26,28,31,34,36,39,42,45,48,51,54,57,60


tanTable	; transform angle/anim offset table in relation to x- and y-vector/acc. resolution 32 x 32 positions. Generated using createObjAngleVectorTable.cpp
								dc.b				24,24,24,24,26,26,26,26,28,28,30,30,30,30,32,32,32,32,32,34,34,36,36,36,36,38,38,38,38,40,40,40																																				; row 0
								dc.b				24,24,24,24,26,26,26,26,28,28,28,28,30,30,32,32,32,34,34,34,34,36,36,38,38,38,38,40,40,40,40,40
								dc.b				24,24,24,24,26,26,26,26,28,28,28,28,30,30,32,32,32,34,34,34,34,36,36,38,38,38,38,40,40,40,40,40
								dc.b				22,22,24,24,24,24,26,26,26,26,28,28,30,30,32,32,32,34,34,34,34,36,36,38,38,38,38,40,40,40,40,42
								dc.b				22,22,24,24,24,24,26,26,26,26,28,28,30,30,32,32,32,34,34,34,34,36,36,38,38,38,38,40,40,40,40,42
								dc.b				22,22,22,22,24,24,24,24,26,26,28,28,30,30,32,32,32,34,34,36,36,38,38,38,38,40,40,40,40,42,42,42																																				; row 5
								dc.b				22,22,22,22,24,24,24,24,26,26,28,28,30,30,32,32,32,34,34,36,36,38,38,38,38,40,40,40,40,42,42,42
								dc.b				20,20,22,22,22,22,24,24,24,24,26,26,30,30,32,32,32,34,34,36,36,38,38,40,40,42,42,42,42,42,42,44
								dc.b				20,20,22,22,22,22,24,24,24,24,26,26,30,30,32,32,32,34,34,36,36,38,38,40,40,42,42,42,42,42,42,44
								dc.b				20,20,20,20,20,20,22,22,24,24,26,26,28,28,32,32,32,34,34,38,38,40,40,42,42,42,42,44,44,44,44,44
								dc.b				20,20,20,20,20,20,22,22,24,24,26,26,28,28,32,32,32,34,34,38,38,40,40,42,42,42,42,44,44,44,44,44																																				; row 10
								dc.b				18,18,18,18,20,20,20,20,22,22,24,24,26,26,32,32,32,36,36,40,40,42,42,44,44,44,44,44,44,46,46,46
								dc.b				18,18,18,18,20,20,20,20,22,22,24,24,26,26,32,32,32,36,36,40,40,42,42,44,44,44,44,44,44,46,46,46
								dc.b				16,16,16,18,18,18,18,18,18,18,20,20,24,24,32,32,32,40,40,44,44,44,44,46,46,46,46,46,46,46,46,46
								dc.b				16,16,16,18,18,18,18,18,18,18,20,20,24,24,32,32,32,40,40,44,44,44,44,46,46,46,46,46,46,46,46,46
								dc.b				18,18,18,18,18,18,18,18,18,18,18,18,18,18,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48																																				; row 15
								dc.b				18,18,18,18,18,18,18,18,18,18,18,18,18,18,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
								dc.b				18,18,18,18,18,18,18,18,18,18,18,18,18,18,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
								dc.b				16,16,16,16,16,16,14,14,14,14,12,12,10,10,0,0,0,56,56,54,54,52,52,50,50,50,50,50,50,50,50,50
								dc.b				16,16,16,16,16,16,14,14,14,14,12,12,10,10,0,0,0,56,56,54,54,52,52,50,50,50,50,50,50,50,50,50
								dc.b				14,14,14,14,14,14,12,12,12,12,10,10,6,6,0,0,0,60,60,56,56,54,54,54,54,52,52,52,52,52,52,50																																					; row 20
								dc.b				14,14,14,14,14,14,12,12,12,12,10,10,6,6,0,0,0,60,60,56,56,54,54,54,54,52,52,52,52,52,52,50
								dc.b				14,14,12,12,12,12,10,10,10,10,6,6,4,4,0,0,0,62,62,58,58,56,56,54,54,54,54,54,54,52,52,52
								dc.b				14,14,12,12,12,12,10,10,10,10,6,6,4,4,0,0,0,62,62,58,58,56,56,54,54,54,54,54,54,52,52,52
								dc.b				12,12,12,12,10,10,10,10,8,8,6,6,4,4,0,0,0,62,62,60,60,58,58,56,56,56,56,54,54,54,54,54
								dc.b				12,12,12,12,10,10,10,10,8,8,6,6,4,4,0,0,0,62,62,60,60,58,58,56,56,56,56,54,54,54,54,54																																						; row 25
								dc.b				10,10,10,10,10,10,8,8,6,6,4,4,2,2,0,0,0,62,62,60,60,60,60,58,58,56,56,56,56,54,54,54
								dc.b				10,10,10,10,10,10,8,8,6,6,4,4,2,2,0,0,0,62,62,60,60,60,60,58,58,56,56,56,56,54,54,54
								dc.b				10,10,10,10,8,8,6,6,6,6,4,4,2,2,0,0,0,0,0,62,62,60,60,58,58,58,58,56,56,56,56,54
								dc.b				10,10,10,10,8,8,6,6,6,6,4,4,2,2,0,0,0,0,0,62,62,60,60,58,58,58,58,56,56,56,56,54
								dc.b				10,10,8,8,8,8,6,6,6,6,4,4,2,2,0,0,0,0,0,62,62,60,60,60,60,58,58,58,58,56,56,56
								dc.b				10,10,8,8,8,8,6,6,6,6,4,4,2,2,0,0,0,0,0,62,62,60,60,60,60,58,58,58,58,56,56,56
tanTableEnd
								if					(tanTableEnd-tanTable)!=1024
								PRINTT				"WARNING Tantable MUST contain 1024 bytes!"
								ENDIF







			; MARK: - Score Vars

scoreNew					=	0
scoreAdd					=	4
scoreOld					=	8


score
								dc.l				0																																																											; 4 bytes in bcd-format for 8 digits
								dc.l				0																																																											; 4 add-bytes in bcd-format
								dc.l				0																																																											; old score, needed for comparison
scoreHigh
								dc.l				0
scoreHighStatus
								dc.b				0,0
scoreHighEncoded
								dc.b				"X"
								blk.b				8,0
								dc.b				"X"
scoreHighDelta
								dc.l				0
scoreAdder
								dc.w				0
scoreMultiplier ; 0.w = countdown, 2.b = score multiplier 3.b = old multiplier, 4.l pointer to last successful bullet
								dc.l				0,0
scoreHighSuccessFlag
								dc.b				0
								even



;                                SPRxCTL
 ;                              ---------
  ;        Bits 15-8       The low eight bits of VSTOP
   ;       Bit 7           (Used in attachment)
    ;      Bits 6-3        Unused (make zero)
     ;     Bit 2           The VSTART high bit
      ;    Bit 1           The VSTOP high bit
       ;   Bit 0           The HSTART low bit

font	;  save font using PICCON, Imageformat "SNES modes",2-bit characters, no redundancy. This packs each char into a set of 8 consecutive bytes
								INCBIN				incbin/font.raw
fontEnd


			; MARK:  - PLAYER DEFINITIONS
								RSRESET
plyPosX							rs.l				1
plyPosY							rs.l				1
plyPosAcclX						rs.w				1
plyPosAcclY						rs.w				1
plyAcclXABS						rs.w				1
plyAcclYABS						rs.w				1
plyInitiated					rs.w				1
plyCollided						rs.w				1
plyShotCnt						rs.b				1
plyFire1Auto					rs.b				1
plyFire1Flag					rs.b				1
plyFire1Hold					rs.b				1
plyDistortionMode				rs.b				1
plyExitReached					rs.b				1
plyWeapUpgrade					rs.b				1
plyWeapSwitchFlag				rs.b				1
plyAVAIL						rs.b				1
plyAVAILB						rs.b				1
plyAcclXCap						rs.w				1
plyAcclYCap						rs.w				1
plyPosXDyn						rs.w				1
plyviewLeftClip					rs.w				1
plyviewRightClip				rs.w				1
plyJoyCode						rs.w				4
plyDiffBulletDelta				rs.w				1
plyPosYABS						rs.w				1
plyShotsFired					rs.w				1
plyShotsHitObject				rs.w				1
plyWaveBonus					rs.w				1
plyHitShotRatio					rs.w				1
plyBossBonus					rs.w				1
plyRemXPos						rs.w				16
plyCheatEnabled					rs.b				1
plyFire1AutoB					rs.b				1
plyAcclXMin					=	$6
plyAcclYMin					=	$6
plyWeapUpgrMax					SET					2

plyBase
plyPos
								blk.l				(plyFire1AutoB/4)+1,0




	; #MARK:  - Key game vars


    ; #MARK: - viewPosition AND FRAMECOMPARE VARS


								RSRESET
viewPositionScrollspeed			rs.l				1
viewPositionAdd					rs.l				1
viewPositionPointer				rs.l				1
vPyAccConvertWorldToView		rs.w				1
viewPositionPointerLaunchBuf	rs.w				1
vfxPosition						rs.w				1
vfxPositionAdd					rs.w				1
vfxAnimSpeed					rs.w				1
viewPosition
								blk.l				6,0																																																											;2.longword = scrolldirection 3.word = y-pointer, 3.w store
	; #MARK:  - TILE STORAGE
tileDefs
tilemapConvertedSize			dc.w				0
tilemapBckConvertedSize			dc.w				0
tilemapHeight					dc.w				0
tileMapWidth					dc.w				0
tilemapBckHeight				dc.w				0
tilemapBckWidth					dc.w				0
tilemapBckNoMaps				dc.w				0,-1



	; #MARK:  - OBJECT COUNTERS
								cnop				0,4																																																											; align on quad adress
vars
	; #MARK:  - Key Game Vars



gameStatus
								dc.b				0
optionStatus
								dc.b				0
loadedLevelStatus
								dc.b				0
gameInActionF	; bit0=runIntcodeFlag; bit1=pauseModeFlag
								dc.b				0
gameStatusLevel
								dc.w				0

	; #MARK:  - Blitter control vars - reset each game
blitterManagerFinished
								dc.b				0
blitterManagerLaunch
								dc.b				0
								even

	; #MARK:  - MIXED VARS

fastRandomSeed
								dc.l				$3E50B28C,$D461A7F9
forceQuitFlag
								dc.b				0
forceExit
								dc.b				0

escalateIsActive
								dc.b				0
dialogueIsActive
								dc.b				0
killShakeIsActive
								dc.b				0
introLaunched
								dc.b				0
								even

homeShotHead
								dc.l				0

objCount
								dc.w				0

spriteCount	; 1.w = static counter,2.w temp counter
								dc.w				0,0
shotCount
								dc.w				0
bobCount
								dc.w				0,0																																																											; 1.w = static counter,2.w temp counter
bobCountHitable
								dc.w				0,0																																																											;	1.w = countup, 2.w store number
objectWarning
								dc.w				0																																																											; , 0.b = true -> too many bobs, 1.b = true -> too many sprites
	; #MARK:  - Temp vars - use only locally

rasterBarNow
								dc.w				0
								IFNE				SHOWRASTERBARS
rasterBarMax
								dc.w				0
								ENDIF

tempVar							blk.l				10,0

	; #MARK:  - Object and anim vars

objectDefsSize					dc.l				0
animDefsSize					dc.l				0
animDefsAmount					dc.w				0
objectDefsAmount				dc.w				0


	; #MARK: - MEMORY POINTERS BEGINS


memoryPointers
								cnop				0,4																																																											; align on quad adress
								IFEQ				(RELEASECANDIDATE||DEMOBUILD)
memorySum						dc.l				0
memoryCount						dc.l				0
								ENDIF

artworkBitplane                 ; share memory
mainPlanes						dc.l				0,0,0,0																																																										; offset needed for memory restore in _exit
mainPlanesPointer				blk.l				3,0																																																											; pointer to mainPlanes plus current y-offset, three buffers
mainPlanesPointerAsync			dc.l				0,0
mainPlaneOneSize				dc.l				0
mainPlaneAllSize				dc.l				0
fxPlanePointer					dc.l				0,0,0,0
copperGame						dc.l				0
copperGameNext					dc.l				0
copperDialogueColors			dc.l				0
copInitColorswitch				dc.l				0																																																											; filled in runtime -> points to end of game copperlist
diskBuffer						dc.l				0,0
diskBufferSize					dc.l				0
tileSource						dc.l				0
tilemapConverted				dc.l				0
tilemapBckConverted				dc.l				0
artworkPalette                  ; share memory
bobSource						dc.l				0,0
objectList						dc.l				0,0,0,0
bobDrawList						blk.l				5,0
bobRestoreList					blk.l				3,0
collidingList					dc.l				0,0,0
copSpriteLists					blk.l				10,0
copBplLists						dc.l				0,0
copSplitList					dc.l				0,0
copLinePrecalc					dc.l				0
colorFadeTable					dc.l				0
spriteDMAMem					dc.l				0,0,0
spritePosMem					dc.l				0
spritePosFirst					dc.l				0
spritePlayerDMA					dc.l				0,0,0,0,0
spriteParallaxBuffer			dc.l				0,0,0
launchTable						dc.l				0
launchTableBuffer				dc.l				0,0
objectDefs						dc.l				0
animTable						dc.l				0
animDefs						dc.l				0
audioWavTable					dc.l				0
audioFXHero						dc.l				0
audioFXBaddie					dc.l				0
musicMemory						dc.l				0																																																											; total music memory
musicTrackB						dc.l				0																																																											; pointer to Track B

;fib_tilePixelFingerprint	dc.l 	0

								IFNE				DEBUG
spritePosLast					dc.l				0
								ENDIF

tempBuffer
								dc.l				0																																																											; secondary pointer to bobsource mem
tempBufferAnimPointers	; secondary pointer to spriteDMAMem
								dc.l				0
tempMemoryPointersXML	; ""
								dc.l				0,0
tempStoreXML			; ""
								dc.l				0
    ; Coplist pointers
escalateEntry					dc.l				0
escalateExit					dc.l				0
dialogueEntry					dc.l				0
dialogueExit					dc.l				0
achievementsEntry				dc.l				0
achievementsQuit				dc.l				0
bpl2modReversal					dc.l				0
gameFinEntry					dc.l				0
lowerScoreEntry					dc.l				0
colorBullet						dc.l				0,0,0,0
copColSprite					dc.l				0
copPriority						dc.l				0
copSPR6PTH						dc.l				0
copSpr6pos						dc.l				0,0,0
copSpr6posChk
; coplist pointers cleared in rasterlist code, dependent on memorypointersEnd
memoryPointersEnd
animTriggers					dc.l				0
launchTableEntryLength			dc.l				0
launchTableNoOfEntrys			dc.l				0
launchTableSize
								dc.l				0

    ; #MARK: MEMORY POINTERS END


    ; #MARK: - frameCountERS

frameCount
								dc.w				0																																																											; refresh rate counter
								dc.w				0																																																											; total no of frames (Main Game)
								dc.w				0																																																											;	 total no of frames (IRQ)
								dc.w				0																																																											; store refresh rate

frameCompare    ; 0.w = target framerate, 1.w = actual framerate
								dc.w				0,0




AddressOfYPosTable 		; Convert y-coord to bitplane y-addr-offset
.temp							SET					0
								REPT				257
								dc.w				.temp
.temp							SET					.temp+mainPlaneDepth*mainPlaneWidth
								ENDR
AddYSmoothScroll
.clip							SET					(mainPlaneWidth*mainPlaneDepth)*(viewUpClip)
								REPT				4
								dc.w				.clip
.clip							SET					.clip+mainPlaneDepth*mainPlaneWidth
								ENDR

attrIsNoRefresh				=	0
attrIsKillBorderExit		=	1
attrIsLink					=	2
attrIsAvailB				=	3
attrIsYadd					=	4
attrIsNotHitable			=	5
attrIsOpaq					=	6																																																																; add "attribs 64" to object definition for object without no mask, to save memory and blitter dma cycles
attrIsBonus					=	6																																																																; bit 6 has two tasks. IsBonus is used with sprites only, therefore IsOpaq is meaningless in such cases
attrIsSprite				=	7

attrIsNoRefreshF			=	1<<attrIsNoRefresh
attrIsKillBorderExitF		=	1<<attrIsKillBorderExit
attrIsLinkF					=	1<<attrIsLink
attrIsAvailBF				=	1<<attrIsAvailB
attrIsYaddF					=	1<<attrIsYadd
attrIsNotHitableF			=	1<<attrIsNotHitable
attrIsOpaqF					=	1<<attrIsOpaq
attrIsBonusF				=	1<<attrIsBonus
attrIsSpriteF				=	1<<attrIsSprite

																																																		;	$7f

								Include				animCodeMain.s
								Include				customMain.s



	;    Incbin reshoot:data/scoreExtras

colorAlphaTable ;pseudo colorRegs which define brightness of bplCol0, bplCol1 etc. 16 values per Col

								dc.w				$00,$01,$04,$05,$10,$11,$14,$15
								dc.w				$40,$41,$44,$45,$50,$51,$54,$55

								dc.w				$02,$03,$06,$07,$12,$13,$16,$17
								dc.w				$42,$43,$46,$47,$52,$53,$56,$57

								dc.w				$08,$09,$0c,$0d,$18,$19,$1c,$1d
								dc.w				$48,$49,$4c,$4d,$58,$59,$5c,$5d

								dc.w				$0a,$0b,$0e,$0f,$1a,$1b,$1e,$1f
								dc.w				$4a,$4b,$4e,$4f,$5a,$5b,$5e,$5f

								dc.w				$20,$21,$24,$25,$30,$31,$34,$35
								dc.w				$60,$61,$64,$65,$70,$71,$74,$75

								dc.w				$22,$23,$26,$27,$32,$33,$36,$37
								dc.w				$62,$63,$66,$67,$72,$73,$76,$77

								dc.w				$28,$29,$2c,$2d,$38,$39,$3c,$3d
								dc.w				$68,$69,$6c,$6d,$78,$79,$7c,$7d

								dc.w				$2a,$2b,$2e,$2f,$3a,$3b,$3e,$3f
								dc.w				$6a,$6b,$6e,$6f,$7a,$7b,$7e,$7f

								dc.w				$80,$81,$84,$85,$90,$91,$94,$95
								dc.w				$c0,$c1,$c4,$c5,$d0,$d1,$d4,$d5

								dc.w				$82,$83,$86,$87,$92,$93,$96,$97
								dc.w				$c2,$c3,$c6,$c7,$d2,$d3,$d6,$d7

								dc.w				$88,$89,$8c,$8d,$98,$99,$9c,$9d
								dc.w				$c8,$c9,$cc,$cd,$d8,$d9,$dc,$dd

								dc.w				$8a,$8b,$8e,$8f,$9a,$9b,$9e,$9f
								dc.w				$ca,$cb,$ce,$cf,$da,$db,$de,$df

;continueBitmap
;	Incbin incbin/misc/continue.raw
;continueBitmapE



playerShotColors
								Incbin				incbin/palettes/playerShots.pal
        ; obtained color data by using PicCon, creating palette and saving it as 8 bit copperlist; import into xcode and delete all BPLCON and COLOR entrys.


coplineAnimPointers
								blk.l				noOfCoplineAnims,0
								even

								Include				alert.s

								INCLUDE				audioManager.s

								SECTION				CHIPSTUFF, DATA_C


								Include				copperCode/coplist.s



; - Misc Data -
								cnop				0,8
								blk.l				spriteLineOffset/4
infoPanelScore
								blk.l				spriteScoreHeight*spriteLineOffset/4
								blk.l				spriteLineOffset/4
infoPanelStatus	; save as sprite, 64 pixel wide, 25 pixel high, no ctrl bytes
								INCBIN				incbin/infoPanel.raw
	;blk.l spriteScoreHeight*spriteLineOffset/4	; empty display

; MARK: - Level Data -

								cnop				0,8
titleSprites            ; 6 sprites 64 x 40 pixels. Save as 64 px wide sprites, 40 px high, ctrl words
								Incbin				incbin/title/logo_letters.raw
titleSpritesOffset			=	(*-titleSprites)/6
titleNumber
								Incbin				incbin/title/logo_number.raw
titleSpritesPalette
								Incbin				incbin/palettes/titleSprites.pal
titleSpieleschreiber
								Incbin				incbin/title/spieleschreiber.raw
titleSpieleschreiberEnd

								cnop				0,8
escalationBitmap
								INCBIN				incbin/escalation.raw

								cnop				0,8
spritePlayerContainer; pixel data 64 px wide, 52 px high, save as 32 pixel wide sprites, no attach, no ctrlword
	;REPT 16
	;dc.l 0,-1,-1,-1,-1,-1,-1,0
	;ENDR
	;blk.b 512,-1
								Incbin				incbin/player/weaponContainer.raw
								IFNE				PLAYERSPRITEDITHERED
spritePlayerBasic	; save as 32 px high, 64 px wide attached sprite, no ctrl words
								Incbin				incbin/player/shipDith_0a.raw
								Incbin				incbin/player/shipIll_0a.raw
spritePlayerBasicEnd
								Incbin				incbin/player/shipDith_0b.raw																																																				; move left
								Incbin				incbin/player/shipIll_0b.raw
								Incbin				incbin/player/shipDith_0c.raw																																																				; move right
								Incbin				incbin/player/shipIll_0c.raw
								ELSE
spritePlayerBasic	; save as 32 px high, 64 px wide attached sprite, no ctrl words
								Incbin				incbin/player/ship_0a.raw
								Incbin				incbin/player/shipIll_0a.raw
spritePlayerBasicEnd
								Incbin				incbin/player/ship_0b.raw																																																					; move left
								Incbin				incbin/player/shipIll_0b.raw
								Incbin				incbin/player/ship_0c.raw																																																					; move right
								Incbin				incbin/player/shipIll_0c.raw
								ENDIF
infoPanelMultiDisplay	; mirrored version of bitmap in infoPanelMultiply, fading out
								blk.b				infoPanelDidIt-infoPanelMultiply,0
								PRINTV				infoPanelDidIt-infoPanelMultiply

    ;}



