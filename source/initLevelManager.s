
; #MARK: - INIT LEVEL BEGINS
; #MARK: welcome message
initLevelWelcome
								WAITVBLANK

								bsr						blankSprite

								WAITVBLANK

								lea						CUSTOM,a6
;	move #ECSENAF!CONCOLF,copGameWelcome+6
								move.w					#$b0,d0
								move.l					d0,d1
								andi					#$ff,d0
								or.w					#(displayWindowStart+50)<<8,d0
								lsr.l					#3,d1
								andi					#$20,d1
								or						#$3800,d1
								move.w					d0,COPDIWSTRT+2
								move.w					d1,COPDIWHIGH+2
								add						#$2400,d0
								move.w					d0,DIWSTOP(a6)

								move					#BPU0F!ECSENAF!CONCOLF,copGameWelcome+6

								lea						bobSourceSize-(mainPlaneWidth*mainPlaneDepth*5),a5																																															; use spare bytes of bobsource mem for text message
								add.l					bobSource(pc),a5
								move.l					a5,d0
								lea						copBPLPT,a2
								move.w					d0,6(a2)
								move.w					d0,CUSTOM+BPL1PT+2
								swap					d0
								move.w					d0,2(a2)
								move.w					d0,CUSTOM+BPL1PT+0

								lea						copGameWelcome,a0
								move					#BPLCON3,(a0)
								move.l					a0,d0
								lea						copMainInit,a0
								move.w					d0,6(a0)
								swap					d0
								move.w					d0,2(a0)

								clr.w					d0
								move.b					gameStatus(pc),d0
								sub.b					#(statusLevel0+1),d0
								move					d0,d1
								lsl						#4,d0
								lsl						#3,d1
								add						d1,d0	: text length = 24

								lea						.txt(pc,d0),a0
								moveq					#68,d0
								clr.w					d1
								bra						wrtTextOnePlane
.txt
								IFNE					DEMOBUILD
								dc.b					"RP3 LOVES AMIGA ADDICT ",0
								ELSE
								dc.b					"STAGE 1  HOSTILE SALUTE",0
								ENDIF
								dc.b					"STAGE 2  TRANQUIL SKIES",0
								dc.b					"STAGE 3 BURIED IN SANDS",0
								dc.b					"STAGE 4   DANGERS BELOW",0
								dc.b					"STAGE 5 FINAL ENCOUNTER",0
								dc.b					"    ARYNS SAVIOUR      ",0
								even
	    ; #MARK: INITGAME MAIN

initGame
								IF						DIFF_OVERRIDE=1
								lea						optionStatus(pc),a6
								bclr					#optionDiffBit,(a6)
								ENDIF
								IF						DIFF_OVERRIDE=2
								lea						optionStatus(pc),a6
								bset					#optionDiffBit,(a6)
								ENDIF
								lea						CUSTOM,a6
								move.w					#DMAF_COPPER|DMAF_BPLEN,DMACON(a6)																																																			; bpl and copper dma off

								IFNE					SHOWRASTERBARS
								clr.l					rasterBarNow
								ENDIF

								lea						gameInActionF(pc),a0
								sf.b					(a0)																																																										; disable gamecode in interrupt

								lea						frameCount+4(pc),a0
								clr.w					(a0)																																																										; reset frameCounter

								lea						animTriggers(pc),a0
								clr.l					(a0)																																																										; reset animTriggers, used to sync mixed and joined anims

								clr.w					d7
								move.b					gameStatus(pc),d7
								IFEQ					DEMOBUILD
								sub.b					#statusLevel0+1,d7
								move.b					.patchStageConverter(pc,d7),d7																																																				; implemented to switch positions of stage 0 and stage 1
								bra						.patchStageStructure
.patchStageConverter
								dc.b					1,0,2,3,4,5
								ELSE
								sub.b					#statusLevel0+0,d7
								ENDIF
.patchStageStructure
								lea						gameStatusLevel(pc),a0
								move.w					d7,(a0)
								moveq					#$40,d0																																																										; homing bullet - minimum proximity cutoff distance between player ship and hostile launcher

								lea						homeShot(pc),a0																																																								; modify homeshot pointer
								lea						homeShotPointer(pc),a1

								tst.b					optionStatus(pc)
								bpl						.skip																																																										; low diff level? skip!
								lea						homeShotLead(pc),a0																																																							; higher diff -> homing bullets with added lead
								sub.b					#$18,d0																																																										; high diff -> reduce cutoff distance
.skip
								move.l					a0,(a1)
								lea						plyBase+plyDiffBulletDelta(pc),a0
								move.w					d0,(a0)

								clr.l					d0
								move.b					.scrollSpeed(pc,d7),d0
								ror.l					#4,d0
								swap					d0
								neg.l					d0
								lea						viewPosition(pc),a0
								move.l					d0,viewPositionScrollspeed(a0)																																																				; basic scroll speed
								move.l					d0,viewPositionAdd(a0)

								bsr						prepareInitGame

								bsr						initLevelWelcome

								IFEQ					INITWITH
								WAITSECS				1
								ELSE
								WAITSECSSET				4
								ENDIF

								lea						CUSTOM,a6
								move.w					#DMAF_SETCLR|DMAF_COPPER,DMACON(a6)																																																			; copper dma on

								move.w					gameStatusLevel(pc),d7
								add.b					#"0",d7


								bsr						initPrepDataLoad																																																							; modify filenames, load and decode
								WAITVBLANK

								move.w					gameStatusLevel(pc),d0
								move.w					.screenManagerRun(pc,d0*2),d6
								lea						scrMngOffset(pc),a0																																																							;offset to screenManagerRun
								move.w					d6,(a0)
	;b1
								lea						sprMngOffset(pc),a0
								move.w					#spriteManager-jmpSprMngOffset-2,(a0)

	;QUITNOW

								bra						.fetchCoplists
		; #MARK: init levels 0-4 scrollspeed

.scrollSpeed
								dc.b					$08,$10,$12,$10,$10,$00																																																						; $20 = max!
								even
.screenManagerRun
								dc.w					screenManagerLv0-jmpSrcMngOffset-2																																																			;lv0
								dc.w					screenManagerLv1-jmpSrcMngOffset-2																																																			;lv1
								dc.w					screenManagerLv2-jmpSrcMngOffset-2
								dc.w					screenManagerLv3-jmpSrcMngOffset-2																																																			;lv3
								dc.w					screenManagerLv4-jmpSrcMngOffset-2
								dc.w					screenManagerLv5-jmpSrcMngOffset-2

	    ; #MARK: init coplists

.copMainFilename
								dc.b					"main?.cop",0
								even
.copDialgFilename
								dc.b					"dialogue?.cop",0
								even
.fetchCoplists
								move.w					gameStatusLevel(pc),d0
								add.b					#"0",d0
.getFileMain
								lea						.copMainFilename(pc),a0																																																						; get pointer to filename
								move.b					d0,4(a0)																																																									; modify filename
								bsr						loadMainCopList
								lea						copGameDefault,a0																																																							; copy return address to coplist
								movem.l					(a0),d0-d3
								movem.l					d0-d3,(a1)																																																									; copy return cmd chain to eof coplist

								moveq					#16,d2																																																										; load dialogue color coplist right behind main coplist. Stores TWO (!) 16 4-bit-color arrays in coplist format, each starting with 106a020, ending with $00840000 00860000 00880000
								add.l					a1,d2
								move.w					gameStatusLevel(pc),d0
								add.b					#"0",d0
.getFileDialogue
								lea						.copDialgFilename(pc),a0																																																					; get pointer to filename
								move.b					d0,8(a0)																																																									; modify filename
								bsr						loadCopList

								lea						copperDialogueColors(pc),a0
								move.l					d6,(a0)
								lea						-12(a1),a0
								lea						-$50(a0),a1

								move.l					#copGamePlyBody,d0																																																							; prepare copjmps within colors coplists
								move.w					d0,6(a0)
								move.w					d0,6(a1)
								swap					d0
								move.w					d0,2(a0)																																																									;
								move.w					d0,2(a1)																																																									;

								bsr						rasterListBuild																																																								; prepare rasterbased scrolling

								WAITVBLANK

								move.w					gameStatusLevel(pc),d7
								move.w					(.jmpTable,pc,d7.w*2),d7
.jmp							jmp						.jmp(pc,d7.w)
.jmpTable
								dc.w					.lv0sky-.jmpTable+2
								dc.w					.lv1sun-.jmpTable+2
								dc.w					.lv2desert-.jmpTable+2
								dc.w					.lv3ocean-.jmpTable+2
								dc.w					.lv4-.jmpTable+2
								dc.w					.lv5outro-.jmpTable+2
.sampleHero
								dc.b					"sound/vo_hero.iff",0
								even
.sampleBaddie
								dc.b					"sound/vo_baddie.iff",0
	; level specific init code
	; #MARK: init levels 0-4
								even
.lv4

								bsr						.loadVfxBitmap
								bsr						ParallaxManager																																																								; prep sprite plane data
								moveq					#0,d3
								move.l					#255<<16<<3,d4
								moveq					#16,d4																																																										; vfx scroll speed
								move					#BANK2F!BANK1F!BANK0F!BRDRBLNKF,d5
								move					#%011011,d6
								move					#ECSENAF|CONCOLF|BPU3F,d7
								bsr.b					.prepConRegs

								bra						.prepGlobals
.prepConRegs
	; -> d4 	scrollspeed vfx layer
								lea						coplist,a0
								move					d7,copBPLCON0-coplist+2(a0)
								move					d6,copBPLCON2-coplist+2(a0)
								move					d5,copBPLCON3-coplist+2(a0)
								move					#$00fe,copBPLCON4-coplist+2(a0)																																																				; lower 4 bits determine pointer to attach´d sprites, too
								lea						viewPosition(pc),a3
								move.l					d4,vfxPosition(a3)																																																							; set vfxposition.w and vfxPositionAdd.w
								move.w					d3,vfxAnimSpeed(a3)

								rts
.loadVfxBitmap
								lea						vfxDefsFile(pc),a2
								move.l					a2,d1																																																										; filenamePointer
								move.l					fxPlanePointer+4(pc),d2																																																						; quadword aligned memory base
								move.l					#(fxPlaneWidth*fxPlaneHeightBig*fxPlaneDepth)+16,d3																																															; max. buffer size
								bsr						createFilePathOnStage
								IFNE					0																																																											; set to 1 to clr vfx layer

								move.l					#(fxPlaneWidth*fxPlaneHeightBig*fxPlaneDepth)/4,d3																																															; max. buffer size

								move.l					fxPlanePointer+4(pc),a2																																																						;
.2
								move.l					#0,(a2)+
								dbra					d3,.2
								rts
								ELSE
								bra						loadFile																																																									; get raw bitplane data. 3 bitplanes, 320 x 512 pixels, non-interleaved
								ENDIF

	    ; #MARK: init level 1
.lv1sun
								bsr						.loadVfxBitmap
								bsr						ParallaxManager																																																								; prep sprite plane data
								moveq					#1,d3
								moveq					#2,d4																																																										; vfx scroll speed
								move					#BANK2F!BANK1F!BANK0F!PF2OF2F|BRDRBLNKF,d5
								move					#%011011,d6
								move					#ECSENAF|CONCOLF|BPU0F!BPU1F!BPU2F|DPFF,d7
								bsr.b					.prepConRegs
								bra						.prepGlobals
.lv2desert
								bsr						.loadVfxBitmap
								bsr						ParallaxManager																																																								; prep sprite plane data

								moveq					#1,d3
								move					#BANK2F!BANK1F!BANK0F!PF2OF2F|BRDRBLNKF,d5
								move					#%011011,d6
								move					#ECSENAF!CONCOLF!BPU0F!BPU1F!BPU2F,d7
								moveq					#12,d4																																																										; vfx scroll speed

								bsr						.prepConRegs
								bra						.prepGlobals

.lv3ocean
								bsr						.loadVfxBitmap
								bsr						ParallaxManager																																																								; prep sprite plane data

								moveq					#1,d3
								moveq					#20,d4																																																										; vfx scroll speed
								move					#BANK2F!BANK1F!BANK0F!BRDRBLNKF,d5
								move					#%011011,d6
								move					#ECSENAF|CONCOLF|BPU0F|BPU1F|BPU2F,d7
								bsr						.prepConRegs
								bra						.prepGlobals
.lv0sky
								bsr						.loadVfxBitmap
								bsr						ParallaxManager																																																								; prep sprite plane data

								moveq					#0,d3
								moveq					#6,d4																																																										; scroll speed
								move					#BANK2F!BANK1F!BANK0F!PF2OF2F|BRDRBLNKF,d5
								move					#%011011,d6
								move					#ECSENAF!CONCOLF!BPU3F,d7
								bsr						.prepConRegs
								lea						tempVar+4(pc),a0
								move.w					#$20,-4(a0)																																																									; set countdown to launch of first sprite
								move					#4,d7
.initSpriteScrollVars
								clr.l					(a0)+																																																										; clear area
								dbra					d7,.initSpriteScrollVars
								bra						.prepGlobals
.filename
								dc.b					"shp",0																																																										; main ship sprite for credits. Save as 64 pixel wide sprite, attached, no coords(?)
.filenameScroller
								dc.b					"crd",0																																																										; scroller sprite. Save as 3 x 64 pixel wide sprites, not attached, no coords
.lv5outro
								WAITSECSSET				7
								bsr						.loadVfxBitmap
								bsr						ParallaxManager																																																								; prep sprite plane data

								move.l					bobSource(pc),d5
								andi.b					#%11111000,d5
								move.l					#.filename,d1																																																								; load and prepare main ship object data to bobsource
								move.l					#$18000,d2
								add.l					d5,d2																																																										; load ship data to bobsource+$18000
								move.l					#$34c0,d3																																																									; filesize hardcoded. Modify if needed
								bsr						createFilePathOnStage
								bsr						loadFile
								tst.l					d0
								beq						errorDisk

								clr.l					d2
								move.l					#.filenameScroller,d1																																																						; load and prepare main ship object data
								moveq					#2,d2
								swap					d2																																																											; load scroller data to bobsource+$20000
								move.l					#132960,d3																																																									; filesize
								add.l					d5,d2																																																										; load credits scroller bitmap data

								IFNE					0
								move.l					d2,a6
								move.w					#122000/4,d7
.dd								clr.l					(a6)+
								clr.l					(a6)+
								move.l					#0,(a6)+
								move.l					#0,(a6)+
								dbra					d7,.dd
								ELSE
								bsr						createFilePathOnStage
								bsr						loadFile
								tst.l					d0
								beq						errorDisk
								ENDIF
								WAITSECS																																																															; music plays - blank screen for some moments - dramatic moment

								move					#BANK2F!BANK1F!BANK0F!PF2OF2F|BRDRBLNKF,d5
								move					#%011011,d6
								move					#%1011011,d6

								move					#ECSENAF|CONCOLF|BPU3F,d7
	;move #ECSENAF|CONCOLF|BPU0F|BPU1F|BPU2F,d7
								moveq					#10,d4
								bsr						.prepConRegs
								bra						creditsJumpin

.prepGlobals
.wait1secs


;	IFNE INITWITH
								WAITSECS
;	ENDIF

								lea						copGameWelcome,a0
								move					#NOOP,(a0)
								lea						CUSTOM,a6
								move.w					#DMAF_BPLEN!DMAF_COPPER!DMAF_SPRITE,DMACON(a6)																																																; black screen, switch off copper

	; load speech samples only if chipmem is sufficient
								move.l					#_fxSpeechHero,a0
								move.l					#.sampleHero,d1
								lea						audioFXHero(pc),a3
								bsr						loadSample
								move.l					#_fxSpeechBaddie,a0
								move.l					#.sampleBaddie,d1
								lea						audioFXBaddie(pc),a3
								bsr						loadSample

creditsJumpin
								bsr						initGameGlobal																																																								; reset general vars



; #MARK: set/reset playfield and sprite colors

								lea						CUSTOM,a6																																																									; set irq and dma
								move.w					#BRDRBLNKF,BPLCON3(a6)
								clr.w					COLOR00(a6)

								IFEQ					WRITECOLORFILE


	; fetch colortable from disk

								lea						levDefFileVar(pc),a0																																																						; generate filename
								move.l					#"colR",(a0)+
								move.w					#"eg",(a0)+
								move.w					gameStatusLevel(pc),d0
								add						#"A",d0
								move.b					d0,(a0)+
								move.b					#0,(a0)+

								move.l					#levDefFilename,d1																																																							; load color file
								move.l					mainPlanes(pc),d2
								move.l					#512*2,d3
								jsr						loadFile
								tst.l					d0
								beq						errorDisk

								lea						CUSTOM,a6
								move.l					mainPlanes(pc),a5
								move					#7,d5
								move.w					#BRDRBLNKF,d7
.switchColBank
								move					d7,d6
								or						#LOCTF,d6
								clr.w					d0
								move					#31,d4
.wrtColRegs
								move.w					(a5)+,d1
								move					d7,BPLCON3(a6)
								move.w					d1,COLOR00(a6,d0)
								move					d6,BPLCON3(a6)
								move.w					256*2-2(a5),d1
								move.w					d1,COLOR00(a6,d0)
								add						#2,d0
								dbra					d4,.wrtColRegs
								add						#%0010000000000000,d7
								dbra					d5,.switchColBank
								move.w					#BRDRBLNKF,BPLCON3(a6)
								clr.w					COLOR00(a6)																																																									;needed for flickerless transition
								ELSE

								bsr						colorManager
								lea						CUSTOM,a6
								move.w					#BRDRBLNKF,BPLCON3(a6)
								clr.w					COLOR00(a6)																																																									;needed for flickerless transition



	;lea 0,a1
.colorIt
								lea						playerVesselPalette(pc),a0																																																					;set sprite ship colors -> colRegs
								bsr						colorPlayer
								moveq					#0,d0
								bsr						dynamicPlayerColors																																																							; reset player extra colors

								lea						CUSTOM,a6
								move.w					#RDRAMF,BPLCON2(a6)																																																							; read color registers
								move.l					mainPlanes(pc),a5
								move					#7,d5
								move.w					#%0000000000000000,d7
.getColBank
								move					d7,d6
								or						#LOCTF,d6
								clr.w					d0
								move					#31,d4
;	move.w #RDRAMF,BPLCON2(a6)	; read color registers
.getColRegs
								move					d7,BPLCON3(a6)
	;move.w #RDRAMF,BPLCON2(a6)	; read color registers
								move.w					COLOR00(a6,d0),d1
	;move #-10,d1
								move.w					d1,(a5)
								move					d6,BPLCON3(a6)
;	move.w #RDRAMF,BPLCON2(a6)	; read color registers
								move.w					COLOR00(a6,d0),d1
	;move #-1,d1
								move.w					d1,256*2(a5)																																																								;
								add						#2,d0
								adda					#2,a5
								dbra					d4,.getColRegs
								add						#%0010000000000000,d7
								dbra					d5,.getColBank

								move.l					mainPlanes(pc),a5
								lea						levDefFileVar(pc),a0																																																						; write launchTable to disk
								move.l					#"colR",(a0)+
								move.w					#"eg",(a0)+
								move.w					gameStatusLevel(pc),d0
								add						#"A",d0
								move.b					d0,(a0)+
								move.b					#0,(a0)+
								move.l					mainPlanes(pc),d2
								move.l					#1024,d3
								bsr						writeMemToDisk
								ENDIF


								IFNE					INITWITH
								WAITSECS				1																																																											; wait a bit, to enhance drama
								ENDIF

								move.l					copperGame(pc),d0																																																							; init game coplist
								lea						copMainInit,a1
								move.w					d0,6(a1)
								swap					d0
								move.w					d0,2(a1)

								WAITVBLANK
								WAITVBLANK
								lea						CUSTOM,a6																																																									; set irq and dma
								move.w					COPJMP1(a6),d0
								move.w					#DMAF_SETCLR|DMAF_COPPER,DMACON(a6)																																																			; enable copper  dma
								WAITVBLANK																																																															; let copper setup screen
								WAITVBLANK

								lea						copBPLPT,a5																																																									; init Bitplane Pointers
								move.l					mainPlanesPointer+0(pc),d0
								moveq					#mainPlaneWidth,d1
								moveq					#3,d7
.setBPLPT
								move					d0,6(a5)
								swap					d0
								move					d0,2(a5)
								swap					d0
								lea						16(a5),a5
								add.l					d1,d0
								dbra					d7,.setBPLPT

								lea						gameInActionF(pc),a0
								move.b					#1,(a0)																																																										; enable gamecode in interrupt

								WAITVBLANK																																																															; let code setup screen display
								WAITVBLANK

	; init some nice and smooth transition
								lea						transitionFlag(pc),a1
								IFEQ					SHOWTRANSITION
								move					#transitionDone,(a1)																																																						; skip transition
								ELSE
								move					#transitionIn,(a1)																																																							; init transition
								ENDIF

								WAITVBLANK
								WAITVBLANK
								move.w					#DMAF_SETCLR|DMAF_BLITTER|DMAF_BLITHOG|DMAF_BPLEN|DMAF_SPRITE,DMACON(a6)																																									; enable full dma, blitter has priority
								bra						mainGameLoop

initPrepDataLoad
								IFNE					RELEASECANDIDATE
								cmp.b					loadedLevelStatus(pc),d7
								beq						.skipLoad																																																									; level already in mem? Skip load and decode
								ENDIF																																																																; in develop-mode load&decode always -> fast map editing

								move.b					d7,loadedLevelStatus

								lea						mapDefsFile(pc),a0       level data
								IFEQ					DEMOBUILD
								SEARCHXML4VALUE			(a0),"Foes"
								ELSE
								SEARCHXML4VALUE			(a0),"Foes"
								ENDIF
								move.b					d7,(a0)

								lea						animDefsFile(pc),a0
								SEARCHXML4VALUE			(a0),"nims"
								move.b					d7,(a0)
								lea						objectDefsFile(pc),a0
								SEARCHXML4VALUE			(a0),"ects"
								move.b					d7,(a0)

								lea						tilePixelData(pc),a0
								SEARCHXML4VALUE			(a0),"iles"
								move.b					d7,(a0)
								lea						colorDefsFile(pc),a0
								SEARCHXML4VALUE			(a0),"lors"
								move.b					d7,(a0)
								lea						parallaxSpriteA(pc),a0
								SEARCHXML4VALUE			(a0),"rite"																																																									; find chars
								move.b					d7,(a0)																																																										; alter number of entry
								lea						parallaxSpriteB(pc),a0
								SEARCHXML4VALUE			(a0),"rite"																																																									; find chars
								move.b					d7,(a0)																																																										; alter number of entry

								jsr						xmlDecode
								bra.b					.avoidMusicRestart
.skipLoad
								bsr						initGameSoundtrack																																																							;
    ;!!!: Welcome delete!!!
.avoidMusicRestart
								lea						CUSTOM,a6
								move.w					#DMAF_BPLEN!DMAF_SPRITE,DMACON(a6)																																																			; switch of bpl dma
								rts


; #MARK: INIT LEVEL ENDS
