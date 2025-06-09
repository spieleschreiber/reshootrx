

; #MARK: - INTRO

mainIntro
    ; display artwork picture, then free memory and add some preparations

	IFNE			FASTINTRO
	WAITSECSSET		1
	ELSE
	WAITSECSSET		6													; show spieleschreiber logo for 6 secs
	ENDIF


	lea				gameStatusLevel(pc),a0
	move.w			#-1,(a0)											; reset level status pointer

	WAITVBLANK
	lea				CUSTOM,a6
	move.w			#DMAF_COPPER!DMAF_BPLEN!DMAF_SPRITE,DMACON(a6)		; copper,sprites and bpl dma off

	move			#BRDRBLNKF,BPLCON3(a6)								; 	black screen
	clr.w			COLOR00(a6)
	bsr				blankSprite
	jsr				prepareDisplay


; intro picture preps
	lea				introLogo(pc),a0
	move.l			a0,d1												; load spieleschreiber logo
	move.l			spriteDMAMem(pc),d2
	move.l			#artworkPictureSize,d3
	bsr				createFilePathOnStage
	jsr				loadFile


	tst.l			d0
	beq				errorDisk

	;move.b #statusLevel0,gameStatus
	;bra _Main

	; load and prepare artwork. 512 x 256 pixels, jpeg converted with ADPro, bitmap data and palette saved to raw with PicCon

	lea				introPicture(pc),a0
	move.l			a0,d1
	move.l			artworkBitplane(pc),d2
	move.l			#artworkPictureSize,d3
	bsr				createFilePathOnStage
	bsr				loadFile
	tst.l			d0
	beq				errorDisk



	lea				scrMngOffset(pc),a0
	move.w			#screenManagerLv0-jmpSrcMngOffset,(a0)

	lea				CUSTOM,a6											; setup copperlist for intro
	move			#0,BPL1MOD(a6)
	move			#0,BPL2MOD(a6)
	;clr.w copBPL2ModOffset+2
	move.w			#$2656,COPDIWSTRT+2									; window
	move.w			#$2100,COPDIWHIGH+2
	move.w			#$26a1,DIWSTOP(a6)
	move			#HAMF!ECSENAF!BPU3F!HIRESF!CONCOLF,copBPLCON0+2		; HAMF
	clr.w			copBPLCON1+2


	lea				(.introCopFilename,pc),a0
	bsr				loadMainCopList
	lea				copGameDefault,a0									; copy return address to coplist
	movem.l			(a0),d0-d3
	movem.l			d0-d3,(a1)											; copy return cmd chain to eof coplist

	lea				copBPLPT,a5
	move.l			artworkBitplane(pc),d1
	clr.l			d2
	move.w			#(artworkPictureSize/8),d2
	moveq			#7,d6
.prepBitplaneAdress
	move			d1,6(a5)
	swap			d1
	move			d1,2(a5)
	swap			d1
	add.l			d2,d1
	lea				8(a5),a5
	dbra			d6,.prepBitplaneAdress

	move.l			#coplist,COP1LC(a6)
	move.w			COPJMP1(a6),d0
	lea				CUSTOM,a6											; setup copperlist
	move			#DMAF_SETCLR!DMAF_COPPER,DMACON(a6)					;enable copper for wait-cmd. Disabled as it caused crash on CD32

	WAITVBLANK
	clr.l			d7
	move.l			spriteDMAMem(pc),a5									; init sprite-DMA / spieleschreiber logo
	move.l			#$9454ba00,d5
	move.w			#titleSpritesOffset-32,d7
	bsr				titleShowSprites

	lea				CUSTOM,a6
	move.w			#DMAF_SETCLR!DMAF_SPRITE,DMACON(a6)					; sprite dma -> on

								;WAITSECS																																																															; wait for spieleschreiber logo

	IFNE			FASTINTRO
	WAITSECSSET		1
	ELSE
	WAITSECSSET		8
	ENDIF

	move.w			#DMAF_SPRITE,DMACON(a6)								; kill logo

	lea				titleSprites,a5										; init sprite-DMA / title logo
	move.l			#$445e6d00,d5
	move.w			#titleSpritesOffset,d7
	jsr				titleShowSprites
	suba			d7,a0
	sub.b			#14,1(a0)
	suba			d7,a0
	sub.b			#14,1(a0)
	move.w			#DMAF_SETCLR!DMAF_BPLEN,DMACON(a6)					; show picture

	WAITSECS

	; init music
	sf.b			d0
	bsr				installAudioDriver
	bsr				initAudioTrack

	move			#musicFullVolume,d0
	lea				CUSTOM,a6
	jsr				_mt_mastervol
	move.w			#DMAF_SETCLR!DMAF_SPRITE,DMACON(a6)					; add sprite game logo to bitplane display

	IFNE			FASTINTRO
	WAITSECSSET		1
	ELSE
	WAITSECSSET		8													; black frame; should be
	ENDIF

	WAITSECS

; turn bitplane dma off and display title logo only

	move.w			#DMAF_BPLEN,DMACON(a6)

	WAITSECSSET		2
	WAITSECS

	lea				transitionFlag(pc),a1
	move			#transitionIn,(a1)									; init fadein

	lea				introLaunched(pc),a0
	st.b			(a0)												; keep music playing in title
	rts
.introCopFilename
	dc.b			"intro.cop",0
	even
titleShowSprites
	move			#$00ff,copBPLCON4+2									;Get SprColors from colorRegs 240ff
	move.l			a5,d0
	lea				copSprite01,a0
	move			d0,6(a0)
	swap			d0
	move			d0,2(a0)
	swap			d0
	add.l			d7,d0
	move			d0,14(a0)
	swap			d0
	move			d0,10(a0)
	swap			d0
	add.l			d7,d0

	lea				copSpriteDMA,a1
	clr.w			d3
	move.w			#copSpriteDMAOffset,d3
	moveq			#7,d1
.wrtFourLists
	move.l			d0,d4
	moveq			#3,d2
	move.l			a1,a0
.spriteDMAInit
	move			d4,6(a0)
	swap			d4
	move			d4,2(a0)
	swap			d4
	lea				8(a0),a0
	add.l			d7,d4
	dbra			d2,.spriteDMAInit
	adda.w			d3,a1
	dbra			d1,.wrtFourLists

	lea				copSprite67,a1
	move			d4,14(a1)
	swap			d4
	move			d4,10(a1)
	swap			d4
	add.l			d7,d4
	move			d4,6(a1)
	swap			d4
	move			d4,2(a1)
titlePosSprites
	move.l			a5,a0
    ;lea titleSprites,a0     ; show title sprites
	moveq			#7,d0
	move.w			d5,d6
	swap			d5
.wrtSprites
	move			d5,(a0)
	move			d6,8(a0)
	add				#$10,d5
	adda			d7,a0
	dbra			d0,.wrtSprites
	rts
titleHideSprites
	lea				SPR0PTH,a1
	moveq			#7,d7
.wrtPt
	move.l			d0,(a1)+
	dbra			d7,.wrtPt
	rts
.sprZero
	dc.l			$3000,0
	dc.l			0,0
	dc.l			$3200,0
	dc.l			0,0
prepareDisplay:
	lea				CUSTOM,a6
	move			#$38,DDFSTRT(a6)
	move			#$a0,DDFSTOP(a6)
	move			#displayWindowStart<<8+$08,DIWSTRT(a6)
	move			#displayWindowStop<<8+$9c,DIWSTOP(a6)				;Displaywindow, Datafetch
;	move #(mainPlaneWidth*(mainPlaneDepth-1)),BPL1MOD(a6)  ; basic modulus
;	move #0,BPL2MOD(a6)

	clr.w			CLXCON2(a6)											;Bitplanes 7 & 8-> no sprites collision
quitPrepareDisplay
	rts
