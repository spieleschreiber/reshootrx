

;PX  25. 5. 2025
; Copyright (c) 2025 spieleschreiber UG | Richard Löwenstein



;{ <- this lines only purpose is to keep indents and formatting in Xcode right
								PRINTT
								PRINTT					"*** Compiling RRX.S"

								SECTION					INCLUDES,CODE																																																								; attn: code in chipmem might execute very slowly on fast cpus > 030



								INCDIR					source/system/																																																								; search these folders for includes
								INCDIR					source/copperCode/
								INCDIR					source/animCode/
								INCDIR					source/customCode/
								INCDIR					source/
								INCDIR					include/
								INCDIR					include/system/
								INCLUDE					targetControl.s																																																								; define important target vars
								INCLUDE					cia.i
								INCLUDE					custom.i
								INCLUDE					exec_lib.i
								INCLUDE					dos_lib.i
								INCLUDE					intuition_lib.i
								INCLUDE					graphics_lib.i
								INCLUDE					constants.i
								INCLUDE					source/macro.s

								SECTION					CODE,CODE
								rts
								bra						start

								INCLUDE					source/loadFile.s
								INCLUDE					errorMessengers.s
								INCLUDE					inputHandler.s
								INCLUDE					stingraysStartup.s
								INCLUDE					saveState.s

								IFNE					SANITYCHECK
								INCLUDE					sanityCheck.s
								ENDIF

; #MARK: - FILENAME DEFINITIONS

filenamePrefix					MACRO
								dc.b					"PROGDIR:data/"
								ENDM


tempFilename
								filenamePrefix
tempFilenameVar
								blk.b					64,0
tempFilenameVarEOF
								even
levDefFilename
								filenamePrefix
								dc.b					"levDefs/"
levDefFileVar
								blk.b					10,0
								even

;Modify TEst
mapDefsFile
								dc.b					"mapFoes0.tmx",0
animDefsFile
								dc.b					"anims0.plist",0
objectDefsFile
								dc.b					"objects0.plist",0
vfxDefsFile
								dc.b					"vfx.raw",0
tilePixelData
								dc.b					"mainTiles0.int",0																																																							; approx. 131 KB
colorDefsFile
    ;FILENAMEPREFIX
								dc.b					"mainColors0.pal",0
introPicture
								dc.b					"intropic.raw",0
introLogo	; 8 sprites 64 x 39 pixels, saved with ctrl words
								dc.b					"intro_spieleschreiber.raw",0


parallaxSpriteA
	;#FIXME: Map filename def´d the hard way temporaily
								dc.b					"parSprite0.raw",0
    ;FILENAMEPREFIX
    ;dc.b    "parSprite0.raw",0     ; ca. 4 KB (*32)
parallaxSpriteB
	;#FIXME: Map filename def´d the hard way temporaily
								dc.b					"parSpritB0.raw",0
    ;FILENAMEPREFIX
    ;dc.b    "parSprite0.raw",0     ; ca. 4 KB (*32)
								even


; #MARK: - GAME VARIABLES

gfxTileGridOffset				blk.l					$100


scr2mod							Macro																																																																;3 Bitplanes
								dc.l					mainPlaneWidth*mainPlaneDepth*tileHeight*\1
								Endm
scr2Offset
								scr2mod					0
								scr2mod					1
								scr2mod					2
								scr2mod					3
								scr2mod					4
								scr2mod					5
								scr2mod					6
								scr2mod					7
								scr2mod					8


scr2LastOffset
								dc.l					0
scr2Flag
								dc.w					0
scr2StartPos
								dc.w					0
								even


; #MARK: - TEXT DEFINITIONS
titleHighInitials
								dc.b					"AAA"
titleCursor
								dc.b					0
titleCursorFlash
								dc.b					0
titleCursorOld
								dc.b					0
titleHighFlag
								dc.b					0
titleViewIndx
								dc.b					0


; #MARK: - MAIN PREPS CODE BEGINS



_Precalc
								clr						errorFlag																																																									; main wont run if flag is set

								lea						gameInActionF(pc),a0
								sf						(a0)																																																										; disable gamecode in interrupt
								bsr						setgameStatus
								clr.b					AudioIsInitiated
       
								lea						memoryPointers(pc),a6
    							move.l #memoryPointersEnd-memoryPointers,d7
    							bsr.l CLEARMEMORY

	; how much memory for three screen buffers

								moveq					#8,d0																																																										; move tilemapHeight
								muls					#tileHeight,d0
								add.w					#4,d0																																																										; safety net
								muls					#mainPlaneWidth,d0
								muls					#mainPlaneDepth,d0
								lsl.l					#1,d0
	;#FIXME: lsl is temp til scrolling works to avoid mem corruption
								move.l					d0,mainPlaneOneSize																																																							;   1 x framebuffer
								move.l					d0,d1
								lsl.l					#1,d0
								add.l					d1,d0																																																										;   3 x framebuffer
								move.l					#fxPlaneWidth*fxPlaneHeightBig*fxPlaneDepth+16,d1																																															; buffer for second plane
								add.l					d1,d0
								add.l					d1,d0																																																										; 2 x bckbuffer

         ; parallax layer
								move.l					d0,diskBufferSize
								move.l					#MEMF_CHIP|MEMF_CLEAR,d1																																																					; triplebuffer bitplane A
								ALLOCMEMORY

								lea						mainPlanes(pc),a0
							
								lea						mainPlanes(pc),a0
								lea						mainPlanesPointer(pc),a1
								lea						diskBuffer(pc),a2
								move.l					mainPlaneOneSize(pc),d1
								move.l					d0,12(a0)
								move.l					d0,d2

								moveq					#8,d7
								add.l					d7,d2
								moveq					#-8,d7
								and.l					d7,d2																																																										; align to 8 byte adress
								move.l					d2,(a2)																																																										; use bitplane buffer as diskBuffer
								move.l					d2,4(a2)																																																									; first one gets modified, second one stays original
								move.l					d2,(a0)																																																										; content will be swapped (triple buffer)
								move.l					d2,(a1)																																																										; content will be added
								add.l					d1,d2
								move.l					d2,4(a0)																																																									;   ""
								move.l					d2,4(a1)																																																									;   ""
								add.l					d1,d2
								move.l					d2,8(a0)																																																									;   ""
								move.l					d2,8(a1)																																																									;   ""
								add.l					d1,d2
								move.l					d2,d0
								move.l					#fxPlaneWidth*fxPlaneHeightBig*fxPlaneDepth+16,d1

								add.l					d1,d0



								lea						fxPlanePointer(pc),a0																																																						; prep. 2nd parallax layer
								move.l					d2,(a0)
								move.l					d0,8(a0)
								moveq					#16,d7
								add.l					d7,d2
								add.l					d7,d0
								moveq					#-8,d7
								and.l					d7,d2
								and.l					d7,d0
								move.l					d2,4(a0)																																																									; needed for correct AGA-adressing, used in screenmanager and load bitmap code
								move.l					d0,12(a0)

								lea						bobCodeCases,a0																																																								; reset pointers to dynamic animation code entrys
								move.w					#bobCodeCasesEnd-bobCodeCases,d2
								lsr						#4,d2
								bra						.clrBobCodePointersLoop
.clrBobCodePointers
								clr.l					12(a0)
								lea						16(a0),a0
.clrBobCodePointersLoop
								dbra					d2,.clrBobCodePointers

;#MARK: build basic memory structures

bobSourceMem

.allocMem						SET						copperGameMaxSize+musicMemSize+bobSourceSize+spritePlayerDMASize+spritePosMemSize+spriteDMAMemSize+spriteParallaxBufferSize

								move.l					#.allocMem,d0																																																								; copperlist max. size
								move.l					#MEMF_CHIP|MEMF_CLEAR,d1
								ALLOCMEMORY
								
								lea						vars(pc),a5																																																									; store
								move.l					d0,copperGame-vars(a5)

								add.l					#copperGameMaxSize+8,d0
								move.l					d0,musicMemory-vars(a5)																																																						; total music memory

								add.l					#musicMemSize,d0
								moveq					#$fffffff8,d1
								and.l					d1,d0
								move.l					d0,bobSource-vars(a5)																																																						; keep static value
								move.l					d0,bobSource-vars+4(a5)																																																						; dynamic value

								add.l					#bobSourceSize,d0
								move.l					d0,16+spritePlayerDMA-vars(a5)																																																				; must not altered
								move.l					d0,d2
								addq.l					#8,d2
								and.l					d1,d2
								move.l					d2,spritePlayerDMA-vars(a5)																																																					; pointer to sprite 0, may be altered

								clr.l					d2
								move.w					#spritePlayerDMASize/4,d2
								move.l					d2,d3
								move.l					d3,d4
								add.l					d0,d2
								and.l					d1,d2
								move.l					d2,spritePlayerDMA-vars+8(a5)																																																				; double buffer pointer to sprite 0, may be altered

								add.l					d3,d3
								add.l					d3,d4
								add.l					d0,d3
								and.l					d1,d3
								move.l					d3,spritePlayerDMA-vars+4(a5)																																																				; pointer to sprite 1

								add.l					d0,d4
								and.l					d1,d4
								move.l					d4,spritePlayerDMA-vars+12(a5)																																																				; double buffer pointer to sprite 1

								add.l					#spritePlayerDMASize,d0
								move.l					d0,spritePosMem-vars(a5)

								add.l					#spritePosMemSize,d0																																																						;    sprite sorting and
								move.l					d0,spriteDMAMem-vars+8(a5)																																																					; must not be changed
								move.l					d0,d2
								addq.l					#8,d2
								andi.b					#$f8,d2																																																										; align to quadword adress
								move.l					d2,spriteDMAMem-vars(a5)																																																					; first buffer

								clr.l					d2
								move.w					#spriteDMAMemSize/2,d2
								add.l					d0,d2
								and.l					d1,d2
								move.l					d2,spriteDMAMem-vars+4(a5)																																																					; second buffer

								add.l					#spriteDMAMemSize,d0
								move.l					d0,spriteParallaxBuffer-vars(a5)
								moveq					#8,d1
								add.l					d1,d0
								andi.b					#$f8,d0
								move.l					d0,spriteParallaxBuffer-vars+4(a5)

								add.l					#spriteParallaxBufferSize/2+16,d0																																																			; Second parallax sprite buffer
								add.l					d1,d0
								andi.b					#$f8,d0
								move.l					d0,spriteParallaxBuffer-vars+8(a5)

								lea						launchTableEntryLength(pc),a0
								moveq					#(launchTableNotUsed+2)&$3e,d0
								move.l					d0,(a0)																																																										; create buffer for launchTable
								lsl.w					#8,d0																																																										; good for 256 launch entrys
								move.l					d0,8(a0)																																																									; write to launchTableSize
								add.l					d0,d0
								add.l					#tileSourceMemSize,d0																																																						; tiles source
								move.l					#MEMF_ANY|MEMF_CLEAR,d1
								ALLOCMEMORY

								move.l					d0,launchTable-vars(a5)																																																						; ; build permanent launchTable buffer

								add.l					launchTableSize(pc),d0
								move.l					d0,tileSource-vars(a5)

								move.l					launchTableSize(pc),d0
								move.l					#MEMF_ANY|MEMF_CLEAR,d1
								ALLOCMEMORY

								move.l					d0,launchTableBuffer-vars(a5)																																																				; build secondary launchTable buffer, altered while game plays
								move.l					d0,launchTableBuffer-vars+4(a5)


; #MARK: - Load and prepare Audio SFX Data -


	; setup secondary pointers, used for XML decoding
								move.l					bobSource(pc),a2																																																							; use bob mem as temp mem for storing wav-files
								lea						tempBuffer(pc),a0
								move.l					a2,(a0)+																																																									; tempBuffer
								move.l					spriteDMAMem(pc),a2
								move.l					a2,(a0)+																																																									;	tempBufferAnimPointers
								lea						$800(a2),a2
								move.l					a2,(a0)+																																																									; tempMemoryPointersXML
								move.l					a2,(a0)+
								lea						$3000(a2),a2
								move.l					a2,(a0)																																																										;tempStoreXML

								lea						AudioNoOfSamples(pc),a2
								clr.b					(a2)
								sub.l					a2,a2																																																										; added size of samples
								move.l					tempBuffer(pc),a3
								lea						fxLoadTable,a4
								move.l					copperGame(pc),a5																																																							; abuse for temp storage of sampleadress.l (relative) and samplelength.w
.loadNextFX
								tst.w					(a4)
								beq						.lastAudioFile
								move.l					a4,d1
								add.b					#1,AudioNoOfSamples
								move.l					a3,a0
								sub.l					tempBuffer(pc),a0
								move.l					a0,(a5)																																																										; store offset of sample
								move.l					diskBuffer+4(pc),d2																																																							; load and prepare sample data
								move.l					diskBufferSize(pc),d3
								lea						.soundFileBase(pc),a0
								bsr						createFilePath
								jsr						loadFile
								tst.l					d0
								beq						errorDisk

								move.l					diskBuffer+4(pc),a0
								SEARCHXML4VALUE			(a0),"data"																																																									; find data-structure
    ;addq.l #6,a0

								move.l					(a0)+,d7
								swap					d7
								rol.w					#8,d7
								adda.w					d7,a2
								lsr						#1,d7
								move.w					d7,4(a5)																																																									; store length of sample, words-length for use in trackerplayer
								lsr						#1,d7
								subq					#2,d7
								clr.l					d3
								tst.l					d7
								bmi						.originalWav																																																								; original .iff/8svx do not need conversion
								eor.l					#$80808080,d3																																																								; .wav need
.originalWav
								lea						4(a0),a0
    ;SEARCHXML4VALUE (a0),"SSND"     ; find data-structure
								clr.w					(a3)+																																																										; first sample-longword needs to 0 for soundtracker-use
.copySample
								move.l					(a0)+,d0
								eor.l					d3,d0																																																										; convert unsigned to signed audio format
								move.l					d0,(a3)+																																																									; copy to tempMem
								dbra					d7,.copySample
								addq.l					#8,a5																																																										; next entry in fxTable

								SEARCHXML4VALUE			(a4),".wav"																																																									; find eof
								lea						1(a4),a4
								bra						.loadNextFX
.soundFileBase
								dc.b					"PROGDIR:data/sound/",0
.lastAudioFile

								IFNE					DEBUG
								cmp.l					diskBufferSize(pc),a2
								bhi						errorMemoryOverrun
								ENDIF

								move.l					a2,d0
								move.l					#MEMF_CHIP|MEMF_CLEAR,d1																																																					; get memory for fx-samples
								ALLOCMEMORY

								move.l					d0,audioWavTable
								move.l					Execbase,a6
								move.l					tempBuffer(pc),a0
								move.l					d0,a1
								move.l					a2,d0
								subq.l					#4,d0
								CALLEXEC				CopyMem

    ; write all samples adress and length to fxTable

								lea						fxTable(pc),a0
								move.l					copperGame(pc),a1																																																							; abused as temp storage
								move.l					audioWavTable(pc),d7																																																						; memory base

.getFX
								move.l					(a0),d0																																																										; get first longword of fx-entry / index to sample
								beq						.lastFXfound
								move.l					(a1,d0*8),d1																																																								; fetch relative adress
								add.l					d7,d1																																																										; add offset of samplememory
								move.l					d1,(a0)+																																																									; overwrite with actual address of sample in memory
								move.w					4(a1,d0*8),d0																																																								; get sample length
								move.w					d0,(a0)
								lea						8(a0),a0
								bra						.getFX
.lastFXfound
								IFEQ					HISCORETABLEDEFAULT
								bsr					loadHighscores																																																								; load highscore table from NV oder HD
								ENDIF
    ; continue with preparations

;.allocMem						SET						copSplitListSize+copLinePrecalcSize+collListSize+bobDrawListSize+bobRestoreListSize+objectListSize+shotColFadeTableSize
.allocMem						SET						copSplitListSize+copLinePrecalcSize+collListSize+bobDrawListSize+bobRestoreListSize+objectListSize+shotColFadeTableSize
								move.l					#.allocMem,d0
								moveq					#MEMF_CLEAR>>16,d1																																																							; MEMF_ANY
								swap					d1
								ALLOCMEMORY

								lea						copSplitList(pc),a0
								move.l					d0,(a0)

								add.l					#copSplitListSize,d0
								lea						copLinePrecalc(pc),a0
								move.l					d0,(a0)
								move.l					d0,a1
								lea						coplineAnimPointers,a0
								move					#noOfCoplines,d6
								move					#noOfCoplineAnims,d7
								lsl						#2,d6
								bra						.quitLoop
.loop
								move.l					a1,(a0)+
								add.l					d6,a1
.quitLoop
								dbra					d7,.loop
								add.l					#copLinePrecalcSize,d0

								lea						collidingList(pc),a0
								move.l					d0,8(a0)
								move.l					d0,a0
								moveq					#-1,d1
								move.l					d1,(a0)
								add.l					#collListSize,d0

								lea						bobDrawList(pc),a0
								move.l					d0,(a0)
								move.l					d0,8(a0)
								move.l					d0,a1
								clr.l					(a1)
								clr.l					d1
.add							SET						bobDrawListEntrySize*10
								move.w					#bobDrawListSize/2,d1
								add.l					d1,d0
								move.l					d0,4(a0)
								lea						-.add(d0.l),a1
								move.l					a1,12(a0)																																																									; store end of bobdrawlist A
								add.l					d1,d0
								lea						-.add(d0.l),a1
								move.l					a1,16(a0)																																																									; store end of bobdrawlist B

								lea						bobRestoreList(pc),a0
								move.l					d0,d2
								move.l					d0,(a0)
								move.l					d0,8(a0)
								move.l					d0,a2
								add.l					#bobRestoreListSize/2,d2
								move.l					d2,4(a0)
								move.l					d2,a1

								lea						objCount(pc),a0
								clr.w					(a0)

								add.l					#bobRestoreListSize,d0
								move.l					d0,d2
								lea						objectList(pc),a0
								move.l					d0,(a0)																																																										; object table shot sprites
								moveq					#AnimPtrNoShotOffset,d1
								add.l					d1,d2
								move.l					d2,4(a0)																																																									; object table all other objects
								move.l					d2,a1																																																										; +8 contains dynamic pointer to best available object slot
								lea						objectListEntrySize-8(a1),a1
								move.l					a1,12(a0)																																																									; object list endOfTable

								add.l					#objectListSize,d0
shotColIterations			=	16
shotNoOfPals				=	3
shotNoOfUpgrades			=	3
shotColFadeTableSize		=	shotColIterations*shotNoOfUpgrades*shotNoOfPals*3
								lea						colorFadeTable(pc),a0
								move.l					d0,(a0)

; precalc fade colors for 3 colored-shot sprites between 4 palettes

								move.l					colorFadeTable,a0																																																							; color1
								lea						playerShotColors+4+16,a1
								lea						playerShotColors+4,a2
								jsr						precalcColorFade(pc)

								move.l					colorFadeTable,a0
								lea						64(a0),a0
								lea						playerShotColors+4+32,a1
								lea						playerShotColors+4+16,a2
								jsr						precalcColorFade(pc)

								move.l					colorFadeTable,a0																																																							;color2
								lea						128(a0),a0
								lea						playerShotColors+8+16,a1
								lea						playerShotColors+8,a2
								jsr						precalcColorFade(pc)

								move.l					colorFadeTable,a0
								lea						192(a0),a0
								lea						playerShotColors+8+32,a1
								lea						playerShotColors+8+16,a2
								jsr						precalcColorFade(pc)

								move.l					colorFadeTable,a0																																																							;color3
								lea						256(a0),a0
								lea						playerShotColors+12+16,a1
								lea						playerShotColors+12,a2
								jsr						precalcColorFade(pc)

								move.l					colorFadeTable,a0
								lea						320(a0),a0
								lea						playerShotColors+12+32,a1
								lea						playerShotColors+12+16,a2
								jsr						precalcColorFade(pc)

								lea						scoreHigh,a0																																																								; clr score and hiscore
								clr.l					(a0)
								lea						score,a1
								clr.l					(a1)

;!!!: Prepare Copperlist-Jumps

    ;WAITVBLANK
    ;WAITVBLANK

								lea						copGameDone,a2
								move.l					#coplist,d0
								move					d0,6(a2)
								swap					d0
								move					d0,2(a2)

								move.l					#copSpriteDMA,d0																																																							; prepare Sprite-pointers sublists
								move.l					d0,a2
								move					d0,copInitSprPtLW
								swap					d0
								move					d0,copInitSprPtHW

								lea						copSpriteLists(pc),a0																																																						; write base pointers to 8 preconf´d copper sprite init list. Mix for buffering
								move					#copSpriteDMAOffset,d2
								move.l					a2,a3

								lea						copSpriteDMAOffset*4(a3),a3

								moveq					#3,d7																																																										; prepare Sprite-pointers sublists
.copSprListPointers
								move.l					a2,(a0)
								move.l					a3,4(a0)
								adda.w					d2,a2
								adda.w					d2,a3
								addq					#8,a0
								dbra					d7,.copSprListPointers

.copSprListReturn
								move.l					#copInitSprPtReturn,d0																																																						; add return pointers to 8 sprite DMA inits
								move.w					#copSpriteDMAOffset,d1
								lea						copSpriteDMA,a0
								move.l					a0,a1
								moveq					#7,d7
.wrtLoWord
								move					d0,copSpriteDMAReturnLW(a0)
								adda.w					d1,a0
								dbra					d7,.wrtLoWord
								swap					d0
								moveq					#7,d7
.wrtHiWord
								move					d0,copSpriteDMAReturnHW(a1)
								adda.w					d1,a1
								dbra					d7,.wrtHiWord

								move.l					#copGameReturn,d0																																																							; prepare default copper sublist
								lea						copGamePlyBodyReturn+2,a0
								move					d0,copGameReturnL
								move					d0,(a0)																																																										; gets modified in runtime, this is just a safety net
								swap					d0
								move					d0,copGameReturnH
								move					d0,4(a0)																																																									; ""

								lea						copGameDefault,a0																																																							; copy return code to each sub copper list
								movem.l					(a0),d0-d3
								lea						copGameWelcomeEnd,a0
								movem.l					d0-d3,(a0)
								lea						copGameFinQuit,a0
								movem.l					d0-d3,(a0)

								WAITVBLANK
								move.l					copperGame(pc),a0
								move.l					a0,d0
								lea						copMainInit,a1
								move.w					d0,6(a1)
								swap					d0
								move.w					d0,2(a1)
								lea						CUSTOM,a6
								move.l					#coplist,COP1LC(a6)
								move.w					COPJMP1(a6),d0
								rts

    ; #MARK: MAIN PREPS CODE ENDS


                                   ;   ************************
                                   ;    ***** XML-decoding start
                                   ;   ************************

; #MARK: - XML DECODING BEGINS
xmlDecode

; MARK:  decode objectdefinitions

								move.l					#objectDefsFile,d1																																																							; load and prepare object data
								move.l					diskBuffer+4(pc),d2
								move.l					diskBufferSize(pc),d3
								bsr						createFilePathOnStage
								bsr						loadFile
								tst.l					d0
								beq						errorDisk

								move.l					tempBuffer(pc),a1
								move.l					diskBuffer+4(pc),a0
								lea						$a8(a0),a0
;    adda.w #$a8,a0
								sub.l					a6,a6


; #MARK:  object load, unpack, cookie cut
; memory map: plane0: object xml data, plane1: object bitmap data, plane2: object  mask
								lea						tempVar+20(pc),a2
	;move.l diskBuffer+4(pc),d0
								move.l					bobSource(pc),d0
								move.l					d0,d1
								add.l					mainPlaneOneSize(pc),d1
								movem.l					d0-d1,(a2)																																																									; temporary memory pointers


searchXMLObjects
								SEARCHXML4VALUE			(a0),"obj:"																																																									; find object
								tst						d4
								bmi						getObjectBitmapMemory																																																						; last entry found, continue
								move.l					a0,a2
								move.l					(a0)+,(a1)+
								move.l					(a0)+,(a1)+


								clr.l					d7																																																											; clear flag
								clr.l					tempVar+28																																																									; reset pointer to obj mem adress
       
								SEARCHXML4VALUE			(a0),"name"																																																									; filename of object data?
								tst						d4
								bmi						keepCurrentPixels																																																							; no? use current pixels in memory (is sprite, or obj with shared pixel content)
    ; found tag "name", therefore load new moving object pixels into buffer

								SEARCHXML4VALUEShort	(a0),"ing>"

								move.l					tempVar+24(pc),d0
								sub.l					tempVar+20(pc),d0
								move.l					d0,objectDefSourcePointer(a1)																																																				; offset mem adress of pixeldata
								move.l					d0,tempVar+16


								lea						tempVar+12(pc),a5
								movem.l					a0/a1/a6,-(a5)																																																								; DOS-Code destroys these registers

								lea						tempFilename(pc),a4
								move.l					a4,d1
								lea						tempFilenameVar(pc),a4
createFilename
								move.b					(a0)+,d0
								cmpi.b					#"<",d0
								beq						endOfFilename
								move.b					d0,(a4)+
								bra.b					createFilename
endOfFilename
								clr.b					(a4)
								move.l					#70,d3
								jsr						GetFileInfo(pc)																																																								; file exists? Get basic data
								tst.l					d0
								beq						errorDisk

	;    SAVEREGISTERS
    ;move.l fxPlanePointer(pc),d0
	;lea tempVar+28(pc),a0
	;move.l d0,(a0); get memory for current object bitmap
	;   RESTOREREGISTERS

								lea						tempFilename(pc),a4
								move.l					a4,d1
								move.l					fxPlanePointer(pc),d2																																																						; use parallax memory as temp object data storage
								move.l					#fxPlaneWidth*fxPlaneHeightBig*fxPlaneDepth,d3																																																; do  load only upto size of available memory
								jsr						loadFile
								tst.l					d0
								beq						errorDisk


								movem.l					(a5)+,a0/a1/a6
								SEARCHXML4VALUE			(a0),"widt"																																																									; store width
								asciiToNumber			(a0),d3
								asr						#1,d3
								move.b					d3,objectDefWidth(a1)

								clr						d4
								SEARCHXML4VALUE			(a0),"heig"																																																									; store heigth
								asciiToNumber			(a0),d4
								move.b					d4,objectDefHeight(a1)
								clr						d3
								move.b					objectDefWidth(a1),d3
								lsr						#2,d3																																																										; width of one bob.b

								move.l					(fib_Size.w,pc),d2
								lsr.l					#2,d2																																																										; size one bitplane
								divu					d4,d2																																																										; sizeof all anims one bitplane complete line.b
								move					d2,d5
								move.w					d5,objectDefMask(a1)
								lsl						#1,d5
								sub.w					d3,d5																																																										; modulus.b
								subq					#2,d5
    ;lsl #1,d5
;    	move.w objectDefModulus(a1),d0
								move.w					d5,objectDefModulus(a1)

								bra						findAttribs
keepCurrentPixels
								move.l					tempVar+16,d7
								move.l					d7,objectDefSourcePointer(a1)																																																				; mem adress of pixeldata

								move.l					a2,a0
								SEARCHXML4VALUE			(a0),"widt"																																																									; store width
								asciiToNumber			(a0),d3
								asr						#1,d3
								move.b					d3,objectDefWidth(a1)

								clr.w					d4
								SEARCHXML4VALUE			(a0),"heig"																																																									; store heigth
								asciiToNumber			(a0),d4
								move.b					d4,objectDefHeight(a1)

								tst.w					d4
								beq						findAttribs

								lsr						#2,d3
								move.l					(fib_Size.w,pc),d2
								asr						#2,d2																																																										; size one bitplane
								divu					d4,d2																																																										; sizeof all anims one bitplane complete line.b
								move					d2,d5
								move.w					d5,objectDefMask(a1)
								lsl						#1,d5
								sub.w					d3,d5																																																										; modulus.b
								subq					#2,d5
								move.w					d5,objectDefModulus(a1)
findAttribs
								move.l					d7,a3
								moveq					#0,d7
								SEARCHXML4VALUE			(a0),"ribs"																																																									; find attributes
								asciiToNumber			(a0),d7
								SEARCHXML4VALUE			(a0),"rite"																																																									; find sprite yes or no
								asciiToNumber			(a0),d3

    ;tst d7
    ;bmi .skipBitmapPreps ; control by bob code, but has no bitmap (e.g. event hub, empty obj)
								tst						d3
								bne						.isSprite

								move.b					d7,objectDefAttribs(a1)
								tst.l					a3																																																											;keep current pixels?
								bne						.skipBitmapPreps

								btst					#6,d7
								bne						.noMask
	; bob with attrib-bit 6 clear -> create mask
								bsr						.createMask

								move.l					(fib_Size.w,pc),d7
								lsl.l					#1,d7

								add.l					d7,tempVar+24																																																								; pointer to next object entry
								bra						.skipBitmapPreps

.noMask		; bob with attrib-bit 6 set -> no mask

								lsr						objectDefModulus(a1)
								clr.w					d0
								move.b					objectDefWidth(a1),d0
								lsr						#3,d0
								addq					#1,d0
								sub						d0,objectDefModulus(a1)																																																						; no mask -> modify modulus

								movem.l					a0/a1/a6,-(sp)
								move.l					fxPlanePointer(pc),a0																																																						; source
								move.w					objectDefMask(a1),d0
								neg						d0
								lea						(a0,d0),a0																																																									; sub mask adress from source
								move.l					tempVar+24(pc),a1																																																							; destination  addr
								move.l					(fib_Size.w,pc),d0
								moveq					#8,d3
								add.l					d3,d0
								moveq					#-8,d3
								and.l					d3,d0																																																										; load objects only align to 8 byte adress

								moveq					#16,d4
								add.l					d4,d0


								add.l					d0,tempVar+24
								CALLEXEC				CopyMem																																																										; copy object w/o mask to permanent storage
								movem.l					(sp)+,a0/a1/a6
.skipBitmapPreps

								lea						animCases,a3
								lea						animCasesEnd-animCases,a4
								moveq					#0,d3
								movem.l					(a2),d4/d5
.findAnim
								add						#16,d3
								cmp						a4,d3
								bge						.noAnim
								movem.l					(a3,d3),a2/a5
								cmp.l					d4,a2
								bne						.findAnim
								cmp.l					d5,a5
								bne						.findAnim
								addq					#8,d3
								bra						.writeAnim
.noAnim
								moveq					#8,d3
.writeAnim
								asr						#3,d3
								move.b					d3,objectDefAnimPointer(a1)

								move.l					a0,a4
								clr.l					d3
								SEARCHXML4VALUE			(a4),"core"																																																									; store score
								tst						d4
								bmi						.noScore
								asciiToNumber			(a4),d3
								move.l					a4,a0
.noScore
								move					d3,objectDefScore(a1)
								lea						objectDefSize(a1),a1
								lea						objectDefSize(a6),a6
								bra						searchXMLObjects																																																							; jump to start of loop

.isSprite
								subq					#1,d3
								andi					#$3f,d3
								asl						#8,d7
								andi					#$7f<<8,d7
								or						d7,d3
								bset					#15,d3
								move					d3,objectDefAttribs(a1)																																																						; write attribs and spritenumber
								move					#0,objectDefScore(a1)																																																						;cant hit sprites, therefore score = 0
								lea						objectDefSize(a1),a1
								lea						objectDefSize(a6),a6
								bra						searchXMLObjects

.createMask


								clr.w					d4
								move.b					objectDefHeight(a1),d4
								move.l					(fib_Size.w,pc),d2
								lsr.l					#2,d2																																																										; size one bitplane
								divu					d4,d2																																																										; sizeof all anims one bitplane complete line.b
								move.l					tempVar+24(pc),d5																																																							; d5 = destination bob source addr
								clr.l					d6
								move					d2,d6
								add.l					d5,d6
    ;move.l d5,d6                    ; d6 = destination bob mask addr

								movem.l					a0-a2,-(sp)
								move.l					fxPlanePointer(pc),a0																																																						; pointer to current object bitmap
								bra						bobCutMaskPrepExit
bobCutMaskPrep
								move.l					a0,a1																																																										; loaded bitmap source
								move.l					d5,a3																																																										; bob source
								move.l					d6,a4																																																										; bob mask
								move					d2,d1
								lsr						#1,d1
								subq					#1,d1																																																										; no of bytes per line
bobCutMaskPrepLine
								moveq					#0,d7
								lea						(a1),a2
								lea						(a3),a5
								REPT					mainPlaneDepth
								move					(a2),d3
								move					d3,(a5)																																																										; store source pixeldata
								or						d3,d7
								adda.w					d2,a2
								adda.w					d2,a5
								adda.w					d2,a5
								ENDR

								lea						(a4),a5
								REPT					mainPlaneDepth
								move.w					d7,(a5)
								adda.w					d2,a5
								adda.w					d2,a5
								ENDR
								lea						2(a1),a1
								lea						2(a3),a3
								lea						2(a4),a4
								dbra					d1,bobCutMaskPrepLine

								clr.l					d7
								move					d2,d7
								lsl.l					#2,d7																																																										; one line, four bitplanes
								adda.w					d7,a0
								add.l					d7,d5																																																										; add one line to source pointer
								add.l					d7,d6																																																										; mask pointer
								add.l					d7,d5																																																										; add one line to source pointer
								add.l					d7,d6																																																										; mask pointer
bobCutMaskPrepExit
								dbra					d4,bobCutMaskPrep
								movem.l					(sp)+,a0-a2
								rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

getObjectBitmapMemory

								move.l					a6,objectDefsSize

								IFNE					SHELLHANDLING
								lea						tempVar+20(pc),a2
								move.l					4(a2),d0
								sub.l					(a2),d0
								lea						.msg(pc),a6
								bsr						shellNum
								bra						.skip
.msg
								dc.b					"$$$$$$$$$ KB used for objectbitmaps",0
								ALIGNLONG
.skip
								lea						tempVar+20(pc),a2
								move.l					4(a2),d0
								sub.l					(a2),d0
								cmp.l					#bobSourceSize,d0
								bhi						errorMemoryOverrun
								ENDIF

    ; MARK: point object defs to object bitmap definitions
								tst.l					objectDefs(pc)
								beq.b					.freeObjDefs
								move.l					objectDefs(pc),a1
								CALLEXEC				FreeVec
.freeObjDefs
								move.l					objectDefsSize(pc),d0
								move.l					#MEMF_CHIP|MEMF_CLEAR,d1
								move.l					Execbase,a6
								ALLOCMEMORY

								lea						objectDefs(pc),a0
								move.l					d0,(a0)																																																										; memory for object definitions
								move.l					d0,a1
								move.l					tempBuffer(pc),a0
								move.l					objectDefsSize(pc),d1
								divu					#objectDefSize,d1
								move					d1,objectDefsAmount
								bra						writeObjListLoop
writeObjList
								addq					#8,a0
								move					#objectDefSize/2-1,d2
.writeObj
								move					(a0)+,(a1)+
								dbra					d2,.writeObj
writeObjListLoop
								dbra					d1,writeObjList


								move.l					#animDefsFile,d1																																																							; load and prepare animation data
								move.l					diskBuffer+4(pc),d2
								move.l					diskBufferSize(pc),d3
								bsr						createFilePathOnStage
								bsr						loadFile
								tst.l					d0
								beq						errorDisk

;	#MARK: decode animDefinitions



								move.l					tempMemoryPointersXML+4(pc),a5
								clr.l					d6																																																											; how much memory we need? counter!
								move.l					tempBufferAnimPointers(pc),a3																																																				; used for temp storing anim names and pointers
								move.l					tempStoreXML(pc),a1

								move.l					diskBuffer+4(pc),a0
								lea						$b0(a0),a0
								clr						animDefsAmount																																																								; clear counter for number of animdefs

								lea						tempVar(pc),a6
searchXMLAnimations

								SEARCHXML4VALUE			(a0),"nim:"																																																									; find animation

								tst						d4
								bmi						writeAnimationList
								addq					#1,animDefsAmount
								move.l					a1,(a5)+
								movem.l					(a0)+,d0/d1
;    cmpi.l #"lnds",d0
;   bne .ssss
;   DEBUGBREAK
;.ssss
								movem.l					d0/d1/d6,(a1)																																																								; save name, needed later for binding anims with launchTable.
								movem.l					d0/d1/d6,(a3)																																																								; save name, needed later for calling anims from individual bobcode
								lea						12(a1),a1
								lea						12(a3),a3
								lea						12(a0),a0
								SEARCHXML4VALUE			(a0),"dict"																																																									; start of anim data
								clr.l					(a6)																																																										; reset counter formerly known as "loopGap"
								sf.b					4(a6)																																																										; clear first-entry-flag
								lea						objName(pc),a2
								clr.l					(a2)+
								clr.l					(a2)																																																										; clear temp name space


searchXMLAnimationStep

								searchXML4Anim			(a0),"ect<"																																																									; start of object
								tst						d4
								bmi						reachedLastAnimStep
								searchXML4Anim			(a0),"ing>"																																																									; find object name

								cmp.b					#"<",(a0)																																																									; if objectname=empty, use old name (no need to write objName in consecutive animDef-cells)
								bne.b					.readObjName
								tst.l					objName(pc)																																																									; forgot to insert objectname into first animList entry? Use emptyObj then
								beq						.getEmptyObj
								lea						objName(pc),a2
								bra						.gotIt
.getEmptyObj
								lea						.baseObject(pc),a2
.gotIt
								movem.l					(a2),d0/d1
    ;move.l objName(pc),d0
    ;move.l objName+4(pc),d1
								bra.b					.gotObjName
.baseObject
								dc.l					"empt","yObj"
.readObjName

								movem.l					(a0)+,d0/d1
								movem.l					d0/d1,objName
.gotObjName

								move.l					tempBuffer(pc),a2																																																							; find object number in obj definitions list
								clr.l					d4
								move					objectDefsAmount(pc),d4
								move.b					d4,d7
								subq.b					#1,d7
								bra.b					searchObjListLoop
searchObjList
								movem.l					(a2),d2/d3
								lea						objectDefSize+8(a2),a2
								cmp.l					d2,d0
								bne.b					searchObjListLoop
								cmp.l					d3,d1
								bne.b					searchObjListLoop
								bra.b					foundObject
searchObjListLoop
								dbra					d4,searchObjList																																																							; cant find object defined within anim-list. Throw error, quit!
								suba.w					#8,a0
								bra						errorXMLAnim

foundObject
								sub.b					d4,d7
								lsl						#1,d7
								move.b					d7,animDefType(a1)

								searchXML4Anim			(a0),"xAcc"																																																									; get xAcc
								searchXML4Anim			(a0),"ger>"

								move.l					a0,a4
								asciiToNumber			(a0),d5
								cmpi.b					#"-",(a4)
								bne.b					.negXAcc
								neg						d5
.negXAcc
								move					d5,animDefXAcc(a1)

								searchXML4Anim			(a0),"yAcc"																																																									; get yAcc
								searchXML4Anim			(a0),"ger>"

								move.l					a0,a4
								asciiToNumber			(a0),d5
								cmpi.b					#"-",(a4)
								bne.b					.negYAcc
								neg						d5
.negYAcc
								move					d5,animDefYAcc(a1)

								searchXML4Anim			(a0),"dura"																																																									; get duration
								searchXML4Anim			(a0),"ger>"
								asciiToNumber			(a0),d5
								tst.b					4(a6)
								beq						.firstEntry
.retFirstEntry
								move.b					d5,animDefCnt(a1)
;	#MARK: manage code-mnemonics

								move.l					a0,a4
								searchXML4Anim			(a4),"code"																																																									; get code?
								tst						d4
								bmi						noCodeInit
                                ; take care of code mnemonic
								lea						30(a0),a0
								searchXML4Anim			(a4),"ing>"

								move.l					(a4)+,d0
								cmpi.l					#"loop",d0																																																									; marks end of loop
								bne.b					.rept
								move					#$00f1,animDefEndWaveAttrib(a1)
								move.l					a1,d4
								sub.l					(a6),d4
								move					d4,animDefNextWave(a1)																																																						; gap between entry and endOfloop
								moveq					#animDefSize*2,d4
								add.l					d4,a1
								add.l					d4,d6
								move.l					a4,a0
								bra						searchXMLAnimationStep
.firstEntry
								st.b					4(a6)
								tst.b					d5
								bne						.retFirstEntry
								move.b					#1,d5
								bne						.retFirstEntry

.rept
								cmpi.l					#"rept",d0																																																									; beginning of loop
								bne						.xacc
								move					#$00f7,animDefEndWaveAttrib(a1)
								move.l					a1,(a6)
								add.l					#animDefSize*2,(a6)
								bra.b					.writeVals
.xacc
								cmpi.l					#"xacc",d0
								bne.b					.yacc
								move					#$00f2,animDefEndWaveAttrib(a1)

.writeVals
								move.b					(a4),d4
								asciiToNumber			(a4),d3
								cmpi.b					#"-",d4
								bne.b					.neg
								neg						d3
.neg
								move					d3,animDefNextWave(a1)																																																						; write pointer to executable
								moveq					#animDefSize*2,d4
								adda.l					d4,a1
								add.l					d4,d6
								move.l					a4,a0
								bra						searchXMLAnimationStep
.yacc
								cmpi.l					#"yacc",d0
								bne.b					.xpos
								move					#$00f3,animDefEndWaveAttrib(a1)
								bra.b					.writeVals
.xpos
								cmpi.l					#"xpos",d0
								bne.b					.ypos
								move					#$00f4,animDefEndWaveAttrib(a1)
								bra.b					.writeVals
.ypos
								cmpi.l					#"ypos",d0
								bne.b					.trig
								move					#$00f5,animDefEndWaveAttrib(a1)
								bra.w					.writeVals
.trig
								cmpi.l					#"trig",d0																																																									; set trigger to value (hibyte=trigger, lobyte=value)
								bne.b					.customCode
								move					#$00f6,animDefEndWaveAttrib(a1)
								bra.w					.writeVals
.customCode
								move.l					(a4)+,d1
								lea						(bobCodeCases,pc),a0
								move.l					#bobCodeCasesEnd-bobCodeCases,d2
								moveq					#0,d3
.findCode
								add						#16,d3
								cmp						d2,d3
								bge						.noCodeFound
								movem.l					(a0,d3),d4/d5
								cmp.l					d0,d4
								bne.b					.findCode
								cmp.l					d1,d5
								bne.b					.findCode
								addq					#8,d3
								move					#$00f0,animDefEndWaveAttrib(a1)
;    bra .writeVals
								move					d3,animDefNextWave(a1)																																																						; write pointer to executable
								moveq					#animDefSize*2,d4
								add.l					d4,a1
								add.l					d4,d6
								move.l					a4,a0
								bra						searchXMLAnimationStep
.noCodeFound
  ;  move.l a4,a0
								sub.l					#animDefSize,a0
								bra						errorXMLName
noCodeInit
								moveq					#animDefSize,d4
								adda.l					d4,a1
								add.l					d4,d6
								bra						searchXMLAnimationStep
reachedLastAnimStep
								move.l					#$00f000f0,(a1)
								moveq					#animDefSize,d4
								adda.l					d4,a1
								add.l					d4,d6
								suba.l					d4,a0																																																										; pointer probably stopped at "anim" (marks begin of animsequence), so push a little back
								bra						searchXMLAnimations

objName
								dc.l					0,0
writeAnimationList
								move.l					a5,tempMemoryPointersXML
								move.l					a1,(a5)
								tst.l					animDefs(pc)
								beq.b					.freeMemory
								move.l					animDefs(pc),a1
								CALLEXEC				FreeVec
.freeMemory
								move.l					d6,d0
								move.l					d0,animDefsSize
								move.l					#MEMF_CHIP|MEMF_CLEAR,d1																																																					; memory for animation definitions
								ALLOCMEMORY

								lea						animDefs(pc),a0
								move.l					d0,(a0)

								tst.l					animTable(pc)
								beq.b					.freeAnimTable
								move.l					animTable(pc),a1
								CALLEXEC				FreeVec
.freeAnimTable
								move					animDefsAmount(pc),d1
								clr.l					d0
								move					d1,d0
								lsl						#3,d0
								lsl						#2,d1
								add						d1,d0																																																										; *12
    ;muls #12,d0
								move.l					#MEMF_CHIP|MEMF_CLEAR,d1
								ALLOCMEMORY

								lea						animTable(pc),a0
								move.l					d0,(a0)																																																										; memory for storing anim names and jumpoffsets

								move.l					d0,a1
								move.l					tempBufferAnimPointers(pc),a0
								move					animDefsAmount(pc),d0
								moveq					#12,d5
								moveq					#16,d6
								bra.b					saveAnimPointersLoop
saveAnimPointers
								movem.l					(a0)+,d2-d4
								movem.l					d2-d4,(a1)
								lea						bobCodeCases(pc),a2																																																							; find and preload animadr (no need for GETANIMADRESS in runtime any more)
								move.w					#((bobCodeCasesEnd-bobCodeCases)/16)-1,d7
.2
								add.l					d6,a2
								cmp.l					(a2),d2
								bne.b					.3
								cmp.l					4(a2),d3
								beq.b					.4
.3								dbra					d7,.2
								IF						0=1
								IFNE					SHELLHANDLING
								SAVEREGISTERS
								bsr						shellAnimMissing
								RESTOREREGISTERS
								ENDIF
								ENDIF
								bra.b					.5
.4
								move.l					a1,12(a2)																																																									; write to table bobcustomcode.s
.5
								add.l					d5,a1
saveAnimPointersLoop
								dbra					d0,saveAnimPointers


								move.l					animDefs(pc),a0
								move					animDefsAmount(pc),d1
								move.l					tempMemoryPointersXML+4,a3
								moveq					#animDefSize,d7
								lsr						#1,d7
								bra.b					writeAnimListLoop
writeAnimList
								move.l					4(a3),d6
								move.l					(a3)+,a4
								lea						12(a4),a4
writeAnimListInnerLoop
								move					d7,d5
								bra.b					.wrtAnimListWordLoop
.wrtAnimListWord
								move.w					(a4)+,(a0)+
.wrtAnimListWordLoop
								dbra					d5,.wrtAnimListWord

								cmp.l					d6,a4
								blt						writeAnimListInnerLoop
writeAnimListLoop
								dbra					d1,writeAnimList


; #MARK:  main map objects decoding

xmlMainMap
								bsr						initGameSoundtrack																																																							; start audiotrack halfway through loading

								IFNE					USEXMLFILE

		; fetch map data from xml-file & decode
								move.l					#mapDefsFile,d1																																																								; Load tilemap data
								move.l					diskBuffer+4(pc),d2
								move.l					diskBufferSize(pc),d3
								bsr						createFilePathOnStage
								bsr						loadFile
								tst.l					d0
								beq						errorDisk

								move.l					diskBuffer+4(pc),a0																																																							; width of tilemap
								SEARCHXML4VALUE			(a0),"orth"

								SEARCHXML4VALUE			(a0),"dth="
								tst						d4
								bmi						errorXML
								asciiToNumber			(a0),d5
								move					d5,tileMapWidth


								SEARCHXML4VALUE			(a0),"ght="																																																									; height of tilemap
								tst						d4
								bmi						errorXML
								asciiToNumber			(a0),d5
								move					d5,tilemapHeight
								mulu					tileMapWidth,d5
    ;asl #1,d5
								lea						tilemapConvertedSize(pc),a1
								move					d5,(a1)
								move.l					a0,diskBuffer

								tst.l					tilemapConverted(pc)
								beq.b					.freeMemory
								move.l					tilemapConverted(pc),a1
								CALLEXEC				FreeVec
.freeMemory


								clr.l					d0
								move					tilemapConvertedSize(pc),d0
								move.l					#MEMF_CHIP|MEMF_CLEAR,d1
								ALLOCMEMORY

								lea						tilemapConverted(pc),a0
								move.l					d0,(a0)

    ; #MARK:  build tile map

								move.l					diskBuffer(pc),a0
								move.l					tilemapConverted(pc),a1																																																						; find tiles
								moveq					#$70,d7
								move					#tileSourceMaxTile,d3
								lea						$e0(a0),a0
								SEARCHXML4VALUE			(a0),"data"																																																									; find start of data
.getTile
								lea						11(a0),a0
								SEARCHXML4VALUE			(a0),"gid="
								tst						d4
								bmi						xmlAttackWaves																																																								;   no error check because built-in failsafe-routine in this case marks end of map data
								asciiToNumber			(a0),d5
								subq					#1,d5
								move.b					d5,d6
								andi.b					#$7,d6
								tst.b					d5																																																											; modify tilecode to match ingame fetch
								bmi						.flipXaxis
								lsr.b					#1,d5
								btst					#2,d5
								bne						.flipYAxis
								andi.b					#%111000,d5																																																									; keep tile unmodified
								or.b					d5,d6
								move.b					d6,(a1)+
								bra.w					.getTile
.flipYAxis		; tile mirror left-right, keep up<->down
								andi.b					#%111000,d5
								or.b					#$80,d5
								eor.b					#$7,d6
								or.b					d6,d5
								move.b					d5,(a1)+
								bra.w					.getTile
.flipXaxis	; mirror up-down, keep left-right
								lsr.b					#1,d5
								btst					#2,d5
								bne						.flipXYaxis
								andi					#%111000,d5
								eor.b					#$f0>>1,d5
	;or.b #$40,d5
								or.b					d6,d5
								move.b					d5,(a1)+
								bra.w					.getTile
.flipXYaxis	; mirror up-down, mirror left-right
								andi					#%111000,d5
								eor.b					#$f8,d5
;	or.b #$c0,d5
								eor.b					#$7,d6
								or.b					d6,d5
								move.b					d5,(a1)+
								bra.w					.getTile

								ELSE


		; fetch map data from disk

								lea						levDefFileVar(pc),a0																																																						; generate filename
								move.w					#"ma",(a0)+
								move.b					#"p",(a0)+
								move.w					gameStatusLevel(pc),d0
								add						#"A",d0
								move.b					d0,(a0)+
								move.b					#0,(a0)+

								move.l					#levDefFilename,d1
								move.l					diskBuffer+4(pc),d2
								move.l					diskBufferSize(pc),d3

								bsr						GetFileInfo																																																									; get filesize
								tst.l					d0
								beq						errorDisk

								tst.l					tilemapConverted(pc)
								beq.b					.freeMemory																																																									; memory alloc´d? Free it!
								move.l					tilemapConverted(pc),a1
								CALLEXEC				FreeVec
.freeMemory
								move.l					(fib_Size.w,pc),d0																																																							; get new memory
								move.l					#MEMF_CHIP|MEMF_CLEAR,d1
								ALLOCMEMORY

								lea						tilemapConverted(pc),a0
								move.l					d0,(a0)

	

								move.l					#levDefFilename,d1																																																							; load map file bitmap
								move.l					d0,d2
								move.l					(fib_Size.w,pc),d3
								jsr						loadFile
								tst.l					d0
								beq						errorDisk

								move.l					tilemapConverted(pc),a0
								move.l					(fib_Size.w,pc),d3
								lea						-16(a0,d3),a0
								lea						tileDefs(pc),a1
								movem.l					(a0),d4-d7
								movem.l					d4-d7,(a1)																																																									; fetch tilemapsize, height etc. from very end of data file, store in resident vars

								ENDIF


    ; #MARK:  begin object mapping/get start position

xmlAttackWaves

								IFNE					USEXMLFILE

		; fetch launchTable from xml-file & decode
								SEARCHXML4VALUE			(a0),"star"																																																									; read startposition
								tst						d4
								bmi						errorXML
								SEARCHXML4VALUE			(a0),""" y="
								tst						d4
								bmi						errorXML
								asciiToNumber			(a0),d7
								lea						scr2StartPos(pc),a3
								move					d7,(a3)

    ; #MARK:  build launch table


    ;MARK: XML-Decoder – Tiled-launchTable
    ; attribs:
    ;   x, y, copy, hitpoints, gap, impact, link, opaque

								move.l					launchTable(pc),a1
findObject
    ;SEARCHXML4VALUE (a0),"t id"                 ; find anim in XML-List
								SEARCHXML4VALUE			(a0),"id="""																																																								; find anim in XML-List
								tst						d4
								bmi						foundAllObjects
								SEARCHXML4VALUE			(a0),"me="""
								movem.l					(a0)+,d4/d5
								move.l					tempMemoryPointersXML+4,a3
								move					animDefsAmount(pc),d1
								bra.b					findObjectAnimLoop
findObjectAnim
								move.l					(a3)+,a4
								movem.l					(a4),d2/d3
								cmp.l					d2,d4
								bne.b					findObjectAnimLoop
								cmp.l					d3,d5
								bne.b					findObjectAnimLoop
								bra.b					foundObjectAnim
findObjectAnimLoop
								dbra					d1,findObjectAnim
								bra						errorXMLMapObject																																																							; could not find anim in map. Error and stop

foundObjectAnim

								SEARCHXML4VALUE			(a0),""" x="																																																								; x-launchposition
								asciiToNumber			(a0),d3

								sub.w					#96,d3
								SEARCHXML4VALUE			(a0),""" y="																																																								; y-launchposition
								move.l					a0,a5
								asciiToNumber			(a0),d7
								sub						#8,d7
								move					10(a4),d2
								movem.w					d2/d3/d7,(a1)

								clr.l					d3																																																											; preload with single object
								lea						24(a0),a0
								clr.l					d7
								move.l					a0,a4
								SEARCHXML4VALUEShort	(a4),"copy"
								tst						d4
								bpl						.copyObject																																																									; found copy command? Yes!
    ;move.l a4,a0
.single	; No -> single object. Also re-entry for copied object code

								SEARCHXML4VALUEShort	(a0),"hit"""																																																								; hitPoints value
.s22
								SEARCHXML4VALUEShort	(a0),"ue="""


								move.l					a0,a2
								asciiToNumber			(a0),d6

								cmpi.b					#"-",(a2)																																																									; if hitvalue<0 -> object not hitable
								bne.b					.basicHitBehave
								lea						1(a0),a0
								move.w					#attrIsNotHitableF<<8,d6
.basicHitBehave

								move.l					a0,a4
								SEARCHXML4VALUEShort	(a4),"link"																																																									; link-flag set? is group, share hitcount, destroy all members of group
								tst						d4
								bmi.b					.noChainAttrib
								SEARCHXML4VALUEShort	(a4),"ue="""
								bset					#attrIsLink+8,d6
								move.l					a4,a0
.noChainAttrib

								move.l					a0,a4
								SEARCHXML4VALUEShort	(a4),"opaq"																																																									; opaque-flag set? skip merging bob with background
								tst						d4
								bmi.b					.noOpaqueAttrib
								SEARCHXML4VALUEShort	(a4),"ue="""
								bset					#attrIsOpaq+8,d6
								move.l					a4,a0
.noOpaqueAttrib

								move.l					a0,a4
								SEARCHXML4VALUEShort	(a4),"refr"																																																									; refresh-flag set? skip merging bob with background
								tst						d4
								bmi.b					.noRefreshAttrib
								SEARCHXML4VALUEShort	(a4),"ue="""
								bset					#attrIsNoRefresh+8,d6
								move.l					a4,a0
.noRefreshAttrib


								move.l					a0,a4
								SEARCHXML4VALUEShort	(a4),"xadd"																																																									; xadd value
								bmi						.noXAdd
								SEARCHXML4VALUEShort	(a4),"ue="""
								move.l					a4,a0
								asciiToNumber			(a4),d4
								cmpi.b					#"-",(a0)
								seq						d7																																																											; sub from initial x-pos? Modify polarity!
								eor.b					d7,d4
								or.b					d4,d3
								move.l					a4,a0
.noXAdd

								move.l					a0,a4
								clr						d7
								SEARCHXML4VALUEShort	(a4),"yadd"																																																									; yadd value
								tst						d4
								bmi						.noYAdd
								SEARCHXML4VALUEShort	(a4),"ue="""
								asciiToNumber			(a4),d7
.noYAdd
								move.l					a4,a0
								tst						d7
								seq						d7
								lsr.b					#7,d7
								ext.w					d7
								ext.l					d7
								ror.w					#1,d7

								or						d6,d7
								swap					d7
								bra						.writeLaunchEntry
.copyObject
								SEARCHXML4VALUEShort	(a4),"ue="""																																																								; find copy value
								asciiToNumber			(a4),d3
								tst						d3
								beq						.copyZero
							; decoding object attributes

	;move d5,d3
								addq					#2,d3
								bset					#7,d3																																																										; d3 = no of copied objects
								asl						#8,d3
								swap					d3
								SEARCHXML4VALUEShort	(a4),"gap"""																																																								; gap value
								SEARCHXML4VALUEShort	(a4),"ue="""
								asciiToNumber			(a4),d7
								swap					d7
								or.l					d7,d3
								move.l					a4,a0
								bra						.single
.copyZero
								move.l					#$82000000,d3
								SEARCHXML4VALUE			(a0),"hit"""																																																								;hit value
								bra						.s22

								SEARCHXML4VALUEShort	(a4),"gap"""																																																								; gap value
								SEARCHXML4VALUEShort	(a4),"ue="""
    ;asciiToNumber (a4),d7
								move.l					a4,a0
								bra						.single


.writeLaunchEntry

								movem.l					d3/d7,6(a1)
								add.l					launchTableEntryLength(pc),a1
								bra						findObject
foundAllObjects
								moveq					#-1,d0
								move.l					d0,(a1)

								sub.l					launchTable(pc),a1
								move.l					launchTableEntryLength(pc),d2
								move.l					a1,d1
								divu					d2,d1
								move.l					d1,launchTableNoOfEntrys

								lea						diskBuffer(pc),a0
								move.l					4(a0),(a0)																																																									; restore original diskBuffer pointer

; #MARK:  sort objects sequence

								move.l					launchTable(pc),a0																																																							; address of array
								move.l					launchTableNoOfEntrys(pc),d0																																																				;number of items
								subq.l					#1,d0
								move.l					launchTableEntryLength(pc),d7
.sortLoop2
								move.l					a0,a2
								move.l					a0,a1
								add.l					d7,a2
								move.w					d0,d1
								subi.w					#1,d1
.sortLoop1
								move					launchTableY(a1),d2
								add.l					d7,a1
								move					launchTableY(a2),d3
								add.l					d7,a2
								cmp						d2,d3
								ble.b					.skip
								move.l					a1,a3
								move.l					a1,a4
								sub.l					d7,a4
								move.l					a1,a5
								move.l					tempBufferAnimPointers(pc),a6																																																				; use as buffer for sorting
								move.l					launchTableEntryLength(pc),d6
								subq					#1,d6
.saveEntry
								move.b					(a3)+,(a6)+																																																									; write to buffer
								dbra					d6,.saveEntry
								move.l					a4,a3
								move.l					launchTableEntryLength,d6
								subq					#1,d6
.swapEntry
								move.b					(a3)+,(a5)+
								dbra					d6,.swapEntry
								move.l					tempBufferAnimPointers,a6
								move.l					launchTableEntryLength,d6
								subq					#1,d6
.writeEntry
								move.b					(a6)+,(a4)+
								dbra					d6,.writeEntry
.skip
								dbra					d1,.sortLoop1
								subi.w					#1,d0
								bgt.b					.sortLoop2
 		;moveq #-1,d0
    ;move.l d0,(a5)


								ELSE

	; fetch launchTable from disk


								lea						levDefFileVar(pc),a0																																																						; generate filename
								move.l					#"laun",(a0)+
								move.w					#"ch",(a0)+
								move.w					gameStatusLevel(pc),d0
								add						#"A",d0
								move.b					d0,(a0)+
								move.b					#0,(a0)+

								move.l					#levDefFilename,d1																																																							; load launch file
								move.l					launchTable(pc),d2
								move.l					launchTableSize(pc),d3
								jsr						loadFile
								tst.l					d0
								beq						errorDisk

								move.l					launchTable(pc),a0
								move.l					launchTableSize(pc),d3
								lea						-2(a0,d3),a0
								lea						scr2StartPos(pc),a1
								move.w					(a0),d4
								move.w					d4,(a1)																																																										; fetch startposition from very end of data file, store in resident var
								ENDIF

    ; #MARK:  write launchTable to disk

								IFNE					WRITElaunchTable
								lea						levDefFileVar(pc),a0																																																						; write launchTable to disk
								move.l					#"laun",(a0)+
								move.w					#"ch",(a0)+
								move.w					gameStatusLevel(pc),d0
								add						#"A",d0
								move.b					d0,(a0)+
								move.b					#0,(a0)+
								move.l					launchTable(pc),a1
								move.l					a1,d2
								move.l					launchTableSize(pc),d3
								lea						(a1,d3),a1
								move.w					scr2StartPos(pc),-(a1)																																																						; store startposition at very end of file
								bsr						writeMemToDisk
								ENDIF

    ; #MARK:  write map to disk
								IFNE					WRITEMAPFILE
								lea						levDefFileVar(pc),a0
								move.w					#"ma",(a0)+
								move.b					#"p",(a0)+
								move.w					gameStatusLevel(pc),d0
								add						#"A",d0
								move.b					d0,(a0)+
								move.b					#0,(a0)+
								move.l					tilemapConverted(pc),a1
								move.l					a1,d2
								clr.l					d3
								move.w					tilemapConvertedSize(pc),d3
								lea						(a1,d3),a1
								lea						tileDefs(pc),a0
								movem.l					(a0),d4-d7
								movem.l					d4-d7,-(a1)																																																									; store tilemapsize, height etc. at very end of data file
								bsr						writeMemToDisk
								ENDIF


; #MARK:  load and prepare Tiles
								move.l					tempBuffer(pc),a0																																																							; temp multiplication table for tile arrangement
								move.l					diskBuffer(pc),d0
								moveq					#tilesHeight/tileHeight,d7
								bra.b					.gfxTileGridOffsetLoop
.gfxTileGridOffset
								moveq					#(tilesWidth/4)-1,d6
								move.l					d0,d1
.gfxTileGridOffset1
								move.l					d1,(a0)+
								add.l					#tileWidth/8,d1
								dbra					d6,.gfxTileGridOffset1
								add.l					#tileHeight*tilesWidth*mainPlaneDepth,d0
.gfxTileGridOffsetLoop
								dbra					d7,.gfxTileGridOffset

.justLoad

								move.l					#tilePixelData,d1																																																							; load  pixel data
								move.l					diskBuffer(pc),d2
								move.l					diskBufferSize(pc),d3
								bsr						createFilePathOnStage
								bsr						loadFile
								tst.l					d0
								beq						errorDisk
 ;   move.l fib_timestamp+8,fib_tilePixelFingerprint

                                    ; rearrange tiles for fast copy code in screenmanager

								move					#(tilesWidth/(tileWidth/8))*(tilesHeight/tileHeight),d7
								clr.l					d2
								clr.l					d3
								moveq					#tilesWidth,d2																																																								; modulus source
								move.l					tempBuffer(pc),a0
								move.l					tileSource(pc),a3
								bra.b					.converTilesLoop
.convertTiles
								move.l					(a0)+,a2
								moveq					#tileHeight-1,d6
.writeTileLine
								move.l					(a2),(a3)+
								add.l					d2,a2
								move.l					(a2),(a3)+
								add.l					d2,a2
								move.l					(a2),(a3)+
								add.l					d2,a2
								move.l					(a2),(a3)+
								add.l					d2,a2
								dbra					d6,.writeTileLine
.converTilesLoop
								dbra					d7,.convertTiles
.keepTilePixels

								IFNE					0																																																											; old code, delete after 1.10.22
								move.l					Execbase,a6
								move.l					tempBuffer(pc),a1																																																							; mem buffer only needed for decoding TMX and Plist XML-data, can be freed
								CALLEXEC				FreeVec
								move.l					tempMemoryPointersXML+4(pc),a1																																																				; same here
								CALLEXEC				FreeVec
								move.l					tempStoreXML(pc),a1																																																							; and here
								CALLEXEC				FreeVec
								move.l					tempBufferAnimPointers(pc),a1																																																				; and here
								CALLEXEC				FreeVec
								ENDIF

                                    ;   ************************
                                    ;    ***** XML-decoding ends
                                    ;   ************************

; #MARK: XML DECODING ENDS

								rts

; #MARK: - EXIT CODE BEGINS

_Exit:
								move.l					Execbase,a6
								move.l					mainPlanes+12(pc),a1
								tst.l					a1
								beq.b					.skipThis1
								jsr						_LVOFreeVec(a6)
.skipThis1
								move.l					tilemapBckConverted(pc),a1
								tst.l					a1
								beq.b					.skipThis8
								jsr						_LVOFreeVec(a6)
.skipThis8
								move.l					tilemapConverted(pc),a1
								tst.l					a1
								beq.b					.skipThis26
								jsr						_LVOFreeVec(a6)
.skipThis26
								move.l					copperGame(pc),a1
								tst.l					a1
								beq.b					.skipThis35
								jsr						_LVOFreeVec(a6)
.skipThis35
								move.l					copSplitList(pc),a1
								tst.l					a1
								beq.b					.skipThis36
								jsr						_LVOFreeVec(a6)
.skipThis36
								move.l					launchTable(pc),a1
								tst.l					a1
								beq.b					.skipThis37
								jsr						_LVOFreeVec(a6)
.skipThis37
								move.l					launchTableBuffer+4(pc),a1
								tst.l					a1
								beq.b					.skipThis43
								jsr						_LVOFreeVec(a6)
.skipThis43
								move.l					objectDefs(pc),a1
								tst.l					a1
								beq.b					.skipThis47
								jsr						_LVOFreeVec(a6)
.skipThis47
								move.l					animDefs(pc),a1
								tst.l					a1
								beq.b					.skipThis49
								jsr						_LVOFreeVec(a6)
.skipThis49
								move.l					animTable(pc),a1
								tst.l					a1
								beq.b					.skipThis50
								jsr						_LVOFreeVec(a6)
.skipThis50
								move.l					audioWavTable(pc),a1
								tst.l					a1
								beq.b					.skipThis62
								jsr						_LVOFreeVec(a6)
.skipThis62
								move.l					audioFXHero(pc),a1
								tst.l					a1
								beq.b					.skipThis63
								jsr						_LVOFreeVec(a6)
.skipThis63
								move.l					audioFXBaddie(pc),a1
								tst.l					a1
								beq.b					.skipThis64
								jsr						_LVOFreeVec(a6)
.skipThis64
	;move.l musicMemory(pc),a1
	;tst.l a1
    ;beq.b .skipThis66
	;jsr	_LVOFreeVec(a6)
.skipThis66
								tst.b					AudioIsInitiated(pc)
								beq						.noAudioEver
								lea						CUSTOM,a6
								lea						mt_chan1,a4
								move.b					#0,mt_Enable-mt_chan1(a4)																																																					;disable music playing
								jsr						_mt_end																																																										; stop player
								lea						CUSTOM,a6
								jsr						_mt_remove_cia																																																								; stop CIA-Interrupt
								clr.b					AudioIsInitiated
.noAudioEver
								lea						forceQuitFlag(pc),a0
								sf.b					(a0)


								moveq					#-1,d0																																																										; instr cache bit
								moveq					#-1,d1																																																										; affect all bits
								CALLEXEC				CacheControl																																																								; disable all cache but instr cache

								clr.l					d0
								rts
	; #MARK: EXIT CODE ENDS


    ; #MARK: - SUBROUTINES BEGINS
convertHexToBCD
  	;	d0	->	num in hex format
  	;	->	d1 converted bcd number
  	; destroys d0,d1,d2,d3,d4,d5,d7
								moveq					#0,d1																																																										; convert score to add from binary -> bcd number. att: four bcd digits max!
								move.l					d1,d3
								move.l					d1,d7
								moveq					#3,d2
								move					#-1,d3
								moveq					#10,d4
								moveq					#4,d5
.convertLoop
								cmp.w					d4,d0
								blt						.foundRemainder
								sub						d4,d0
								addq					#1,d7
								bra						.convertLoop
.foundRemainder
								swap					d7
								or.l					d7,d0
								add.w					d0,d1
								ror.w					d5,d1
								swap					d0
								and.l					d3,d0
								moveq					#0,d7
								dbra					d2,.convertLoop
								rts



loadSample	    ; import and init voice sample
				; d1 = pointer to sample binary filename
				; a0	= 	pointer to sample init struc
				; a3	pointer to sample memory pointer


								lea						tempVar(pc),a4
								move.l					a0,8(a4)
								move.l					d1,a5

								move.l					(a3),a1
								tst.l					a1
								beq						.freeMemFirst
								clr.l					(a3)																																																										; clear sample pointer within sfx structure in any case
								SAVEREGISTERS
								move.l					Execbase,a6
								jsr						_LVOFreeVec(a6)
								RESTOREREGISTERS
.freeMemFirst

								bsr						createFilePathOnStage
								bsr						GetFileInfo																																																									; check for sufficient memory
								tst.l					d0
								beq						errorDisk

								move.l					(fib_Size,pc),d0																																																							; filesize
								move.l					#MEMF_CHIP|MEMF_CLEAR,d1
								move.l					Execbase,a6
								jsr						_LVOAllocVec(a6)
								tst.l					d0
								beq						.noMemory																																																									; not enough chipmem, do not play voice sample
								move.l					(fib_Size,pc),d1
								movem.l					d0-d1,(a4)																																																									; store sample pointer, size of sample
								move.l					d0,(a3)

								move.l					a5,d1																																																										; filename
								move.l					d0,d2																																																										; memory pointer
								move.l					(fib_Size,pc),d3																																																							; sample size
								bsr						createFilePathOnStage
								jsr						loadFile
								tst.l					d0
								beq						errorDisk
								movem.l					(a4),d0/d1/a0																																																								; pointer to sample, sample size, sample struc
								add.w					#$70,d0																																																										; skip sample definition entry
								sub.w					#$70,d1																																																										; modify sample length accordingly
								move.l					d0,(a0)
								move.l					d0,a1
								clr.l					(a1)																																																										; clear first word for clean audio playback
								lsr						#1,d1
								move.w					d1,4(a0)
.noMemory
								rts
loadMainCopList
								lea						copperGame(pc),a3
								move.l					(a3),d2
								clr.l					4(a3)																																																										; reset pointer to end of main coplist
								bsr						loadCopList
								lea						-16(a1),a1																																																									; prepare for copying cop1lc-reset to end of list
								lea						irqCopJmp(pc),a0
								move.l					a3,(a0)																																																										; make available in irq
								rts

loadCopList	; a0=pointer to filename, d2=pointer to memory address. Returns end of file adress in a1
								move.l					a0,d1																																																										; pointer to filename
								move.l					d1,d5																																																										;	""
								move.l					d2,d6																																																										; pointer to memory address
								bsr						createFilePathOnStage
								bsr						GetFileInfo
								move.l					(fib_Size.w,pc),d1
								tst.l					d0
								beq						errorDisk

								move.l					d5,d1
								move.l					d6,d2
								move.l					(fib_Size.w,pc),d3
								bsr						createFilePathOnStage
								bsr						loadFile
								tst.l					d0
								beq						errorDisk
								add.l					(fib_Size.w,pc),d2
								move.l					d2,a1
								lea						copperGame(pc),a3
								move.l					d2,4(a3)																																																									; 	store pointer to end of coplist
								rts



resetScores
								lea						score(pc),a0
								move.w					#1,scoreAdder-score(a0)																																																						; some score preps
								move.l					#$99999999,(a0)
								IFNE					SCORE_OVERRIDE
								move.l					#SCORE_OVERRIDE,(a0)
								ENDIF
								clr.w					scoreHighDelta-score(a0)
								clr.b					scoreHighSuccessFlag-score(a0)
								rts

;!!!: Do also clr ply sprite, use this code in intro
blankSprite


								moveq					#7,d0
.wrtSprt
								clr.w					SPR0POS(a6)																																																									; reset sprite positions to disable dma draw bug
								add.w					#8,a6
								dbra					d0,.wrtSprt
								rts

; MARK: SET gameStatus GAME / TITLE
setgameStatus
								lea						gameStatus(pc),a0
	;move.b #1<<optionDiffBit|1<<optionMusicBit|1<<optionSFXBit,1(a0)	; set basic options
								clr.b					1(a0)																																																										; set basic options
								IFNE					RELEASECANDIDATE																																																							; go to title only if releaseversion

								move.b					#statusIntro,(a0)																																																							;  $8000 indicates first call to mainFade-routine
;FIXME: Reset to statusIntro
								ELSE
								IF						INITWITH<20
								move.b					#statusLevel0+INITWITH,(a0)

								move.l					#.levelGetter,d1																																																							; load level specified in file
								move.l					a0,d2
								moveq					#1,d3
								jsr						loadFile
								tst.l					d0
								beq						errorDisk
								lea						gameStatus(pc),a0
								sub.b					#"0"-2,(a0)
								bra.b					.1
.levelGetter
								filenamePrefix
								dc.b					"levDefs/levelGetter.s",0
								even
.1
								ELSE
								IF						INITWITH=20
								move.b					#statusIntro,(a0)
								ENDIF
								IF						INITWITH=30
								move.b					#statusTitle,(a0)
								ENDIF
								ENDIF
								ENDIF
								rts

installAudioDriver	; init CIA interrupt, running music driver
								SAVEREGISTERS
								tst.b					AudioIsInitiated
								bne.b					.ciaIntRunning

								lea						CUSTOM,a6
								bsr						_mt_remove_cia

								move.l					VBRptr(pc),a0
								lea						CUSTOM,a6
	;st.b d0	; st.b != 0 for PAL
								bsr						_mt_install_cia

								lea						AudioIsInitiated(pc),a0
								st.b					(a0)

.ciaIntRunning
								RESTOREREGISTERS
								rts

initAudioTrack	; init music track. Loads File "mus" from current stage folder; loads file "bos" as needed
	; ATTN: outro music is too big for music memory. Partially overwrittes object memory. Dont bother as it is not needed in stage 5.

								lea						vars(pc),a6
								clr.l					musicTrackB-vars(a6)
								lea						mainMusicFile(pc),a0

								move.l					musicMemory(pc),d2
								bsr						loadCopList
								lea						vars(pc),a6
								move.l					d2,musicTrackB-vars(a6)

								move.b					gameStatus,d0
								andi.w					#$f,d0
								move.w					oneOrTwoTracksFlag(pc),d1
								move.l					d6,a0
								btst					d0,d1
								beq						startAudioTrack																																																								; load boss-track only ingame
								move.l					a0,-(sp)
								lea						bossMusicFile(pc),a0
								bsr						loadCopList
								move.l					(sp)+,a0
startAudioTrack
								tst.l					a0
								beq						.q
								lea						CUSTOM,a6
								sub.l					a1,a1																																																										; get samples from mod-file
								clr.l					d0
								sf.b					d0																																																											; 0=start at beginning
								bsr						_mt_init																																																									;(a6=CUSTOM, a0=TrackerModule, a1=Samples, d0=StartPos.b)	; init audiotrack
								lea						CUSTOM,a6
								move					#musicFullVolume,d0
								bsr						_mt_mastervol																																																								; set music volume

								clr.l					d0
								btst					#optionMusicBit,optionStatus(pc)
								bne						.noMusic
								lea						mt_chan1+_mt_Enable(pc),a4
								st.b					(a4)
								move.b					#%0011,d0
.noMusic
								bsr						_mt_musicmask																																																								; set music mask to 0 incase of noMusic flag set
.q
	;RESTOREREGISTERS
								rts
oneOrTwoTracksFlag
								dc.w					%01111100<<1																																																								;added one bit, due to architecture of maingame controller
mainMusicFile
								dc.b					"mus",0
bossMusicFile
								dc.b					"bos",0



    ; subroutine for precalc of 16 color fades and converting to Amiga AGA-Table. Result: 2 x .w lo/hi-palette per color
shotColorFader:
precalcColorFade
								moveq					#shotColIterations-1,d6

.1
								move.l					a1,a3
								move.l					a2,a4
    ;lea \1,a1
    ;lea \2,a2
								move.w					#3,d7
								moveq					#0,d3
								move.l					d6,d4
								asl.w					#4,d4
								divu					#shotColIterations,d4

    ;integer( A1+ i/A * (A2-A1) )
.2
								moveq					#0,d0
								moveq					#0,d1
								move.b					(a3)+,d0																																																									; d0 = color0
								move.b					(a4)+,d1																																																									; d1 = color1

								move.w					d1,d2
								sub.w					d0,d2																																																										; d2 = c1-c0
								muls.w					d4,d2																																																										; d2 = (c1-c0)*alpha
								asr.w					#4,d2																																																										; d2 = ((c1-c0)*alpha)>>8

								addx.w					d3,d2
								add.w					d2,d0																																																										; d0 = c0 + ((c1-c0)*alpha))>>8
								move.b					d0,(a0)+
								dbf						d7,.2
								dbf						d6,.1

								moveq					#shotColIterations-1,d7
.3
								move.l					-(a0),d0
								move.l					d0,d1
								swap					d1
								move					d1,d2
								lsl.w					#8,d1
								lsl.w					#4,d2
								andi					#$f00,d1																																																									; lobyte    r
								andi					#$f00,d2																																																									; hibyte    r

								move.w					d0,d3
								asr						#4,d3
								move					d3,d4
								lsr						#4,d4
								andi					#$f0,d3																																																										; lobyte    g
								andi					#$f0,d4																																																										; hibyte    g

								move.w					d0,d5
								move					d5,d6
								lsr						#4,d6
								andi					#$f,d5																																																										; lobyte    b
								andi					#$f,d6																																																										; hibyte    b
								or						d1,d5
								or						d3,d5																																																										; lobyte rgb
								or						d2,d6
								or						d4,d6																																																										; hibyte rgb
								move.w					d5,(a0)
								move.w					d6,2(a0)
								dbra					d7,.3
								rts

    ; MARK: SUBROUTINES ENDS

; #MARK: - MAIN MANAGER
_Main
	;QUITNOW
								tst						errorFlag
								bne						.quitMain
.mainLoop

	;jsr initGame

								move.b					gameStatus(pc),d0
								andi.w					#$f,d0
								addq.b					#1,gameStatus
								move.w					(.jmpTable,pc,d0.w*2),d0
.off
								jsr						.off(pc,d0.w)
								tst.b					forceQuitFlag(pc)
								beq.b					.mainLoop
.quitMain
								rts
.jmpTable
								IFEQ					DEMOBUILD
								dc.w					mainIntro-.off-2,mainTitle-.off-2
								dc.w					initGame-.off-2
								dc.w					initGame-.off-2
								dc.w					initGame-.off-2
								dc.w					initGame-.off-2
								dc.w					initGame-.off-2
								dc.w					initGame-.off-2
								dc.w					mainReset-.off-2
								ELSE
								dc.w					mainIntro-.off-2,mainTitle-.off-2
								dc.w					initGame-.off-2
								dc.w					mainReset-.off-2
								dc.w					mainTitle-.off-2
								ENDIF
statusIntro					=	0
statusTitle					=	1
statusLevel0				=	2
statusLevel1				=	3
statusLevel2				=	4
statusLevel3				=	5
statusLevel4				=	6
statusLevel5				=	7
statusLevel6				=	8
statusFinished				=	10

mainGameOver
								rts
mainInit
								rts
mainReset
    ;move.b #statusLevel0,gameStatus
								move.b					#statusTitle,gameStatus
								rts


; #MARK: - INTRO

mainIntro
    ; display artwork picture, then free memory and add some preparations

								IFNE					FASTINTRO
								WAITSECSSET				1
								ELSE
								WAITSECSSET				6																																																											; show spieleschreiber logo for 6 secs
								ENDIF


								lea						gameStatusLevel(pc),a0
								move.w					#-1,(a0)																																																									; reset level status pointer

								WAITVBLANK
								lea						CUSTOM,a6
								move.w					#DMAF_COPPER!DMAF_BPLEN!DMAF_SPRITE,DMACON(a6)																																																; copper,sprites and bpl dma off

								move					#BRDRBLNKF,BPLCON3(a6)																																																						; 	black screen
								clr.w					COLOR00(a6)
								bsr						blankSprite
								jsr					prepareDisplay


; intro picture preps
								lea						introLogo(pc),a0
								move.l					a0,d1																																																										; load spieleschreiber logo
								move.l					spriteDMAMem(pc),d2
								move.l					#artworkPictureSize,d3
								bsr						createFilePathOnStage
								jsr						loadFile


								tst.l					d0
								beq						errorDisk

	;move.b #statusLevel0,gameStatus
	;bra _Main

	; load and prepare artwork. 512 x 256 pixels, jpeg converted with ADPro, bitmap data and palette saved to raw with PicCon

								lea						introPicture(pc),a0
								move.l					a0,d1
								move.l					artworkBitplane(pc),d2
								move.l					#artworkPictureSize,d3
								bsr						createFilePathOnStage
								bsr						loadFile
								tst.l					d0
								beq						errorDisk



								lea						scrMngOffset(pc),a0
								move.w					#screenManagerLv0-jmpSrcMngOffset,(a0)

								lea						CUSTOM,a6																																																									; setup copperlist for intro
								move					#0,BPL1MOD(a6)
								move					#0,BPL2MOD(a6)
	;clr.w copBPL2ModOffset+2
								move.w					#$2656,COPDIWSTRT+2																																																							; window
								move.w					#$2100,COPDIWHIGH+2
								move.w					#$26a1,DIWSTOP(a6)
								move					#HAMF!ECSENAF!BPU3F!HIRESF!CONCOLF,copBPLCON0+2																																																; HAMF
								clr.w					copBPLCON1+2


								lea						(.introCopFilename,pc),a0
								bsr						loadMainCopList
								lea						copGameDefault,a0																																																							; copy return address to coplist
								movem.l					(a0),d0-d3
								movem.l					d0-d3,(a1)																																																									; copy return cmd chain to eof coplist

								lea						copBPLPT,a5
								move.l					artworkBitplane(pc),d1
								clr.l					d2
								move.w					#(artworkPictureSize/8),d2
								moveq					#7,d6
.prepBitplaneAdress
								move					d1,6(a5)
								swap					d1
								move					d1,2(a5)
								swap					d1
								add.l					d2,d1
								lea						8(a5),a5
								dbra					d6,.prepBitplaneAdress

								move.l					#coplist,COP1LC(a6)
								move.w					COPJMP1(a6),d0
								lea						CUSTOM,a6																																																									; setup copperlist
								move					#DMAF_SETCLR!DMAF_COPPER,DMACON(a6)																																																			;enable copper for wait-cmd. Disabled as it caused crash on CD32

								WAITVBLANK
								clr.l					d7
								move.l					spriteDMAMem(pc),a5																																																							; init sprite-DMA / spieleschreiber logo
								move.l					#$9454ba00,d5
								move.w					#titleSpritesOffset-32,d7
								bsr						titleShowSprites

								lea						CUSTOM,a6
								move.w					#DMAF_SETCLR!DMAF_SPRITE,DMACON(a6)																																																			; sprite dma -> on

								;WAITSECS																																																															; wait for spieleschreiber logo

								IFNE					FASTINTRO
								WAITSECSSET				1
								ELSE
								WAITSECSSET				8
								ENDIF

								move.w					#DMAF_SPRITE,DMACON(a6)																																																						; kill logo

								lea						titleSprites,a5																																																								; init sprite-DMA / title logo
								move.l					#$445e6d00,d5
								move.w					#titleSpritesOffset,d7
								jsr						titleShowSprites
								suba					d7,a0
								sub.b					#14,1(a0)
								suba					d7,a0
								sub.b					#14,1(a0)
								move.w					#DMAF_SETCLR!DMAF_BPLEN,DMACON(a6)																																																			; show picture

								WAITSECS

	; init music
								sf.b					d0
								bsr						installAudioDriver
								bsr						initAudioTrack

								move					#musicFullVolume,d0
								lea						CUSTOM,a6
								jsr						_mt_mastervol
								move.w					#DMAF_SETCLR!DMAF_SPRITE,DMACON(a6)																																																			; add sprite game logo to bitplane display

								IFNE					FASTINTRO
								WAITSECSSET				1
								ELSE
								WAITSECSSET				8																																																											; black frame; should be
								ENDIF

								WAITSECS

; turn bitplane dma off and display title logo only

								move.w					#DMAF_BPLEN,DMACON(a6)

								WAITSECSSET				2
								WAITSECS

								lea						transitionFlag(pc),a1
								move					#transitionIn,(a1)																																																							; init fadein

								lea						introLaunched(pc),a0
								st.b					(a0)																																																										; keep music playing in title
								rts
.introCopFilename
								dc.b					"intro.cop",0
								even
titleShowSprites
								move					#$00ff,copBPLCON4+2																																																							;Get SprColors from colorRegs 240ff
								move.l					a5,d0
								lea						copSprite01,a0
								move					d0,6(a0)
								swap					d0
								move					d0,2(a0)
								swap					d0
								add.l					d7,d0
								move					d0,14(a0)
								swap					d0
								move					d0,10(a0)
								swap					d0
								add.l					d7,d0

								lea						copSpriteDMA,a1
								clr.w					d3
								move.w					#copSpriteDMAOffset,d3
								moveq					#7,d1
.wrtFourLists
								move.l					d0,d4
								moveq					#3,d2
								move.l					a1,a0
.spriteDMAInit
								move					d4,6(a0)
								swap					d4
								move					d4,2(a0)
								swap					d4
								lea						8(a0),a0
								add.l					d7,d4
								dbra					d2,.spriteDMAInit
								adda.w					d3,a1
								dbra					d1,.wrtFourLists

								lea						copSprite67,a1
								move					d4,14(a1)
								swap					d4
								move					d4,10(a1)
								swap					d4
								add.l					d7,d4
								move					d4,6(a1)
								swap					d4
								move					d4,2(a1)
titlePosSprites
								move.l					a5,a0
    ;lea titleSprites,a0     ; show title sprites
								moveq					#7,d0
								move.w					d5,d6
								swap					d5
.wrtSprites
								move					d5,(a0)
								move					d6,8(a0)
								add						#$10,d5
								adda					d7,a0
								dbra					d0,.wrtSprites
								rts
titleHideSprites
								lea						SPR0PTH,a1
								moveq					#7,d7
.wrtPt
								move.l					d0,(a1)+
								dbra					d7,.wrtPt
								rts
.sprZero
								dc.l					$3000,0
								dc.l					0,0
								dc.l					$3200,0
								dc.l					0,0
prepareDisplay:
								lea						CUSTOM,a6
								move					#$38,DDFSTRT(a6)
								move					#$a0,DDFSTOP(a6)
								move					#displayWindowStart<<8+$08,DIWSTRT(a6)
								move					#displayWindowStop<<8+$9c,DIWSTOP(a6)																																																		;Displaywindow, Datafetch
;	move #(mainPlaneWidth*(mainPlaneDepth-1)),BPL1MOD(a6)  ; basic modulus
;	move #0,BPL2MOD(a6)

								clr.w					CLXCON2(a6)																																																									;Bitplanes 7 & 8-> no sprites collision
quitPrepareDisplay
								rts

								IFNE					WRITECOLORFILE

;	#MARK: - COLOR MANAGER

;	#MARK: - color player
colorPlayer

; #MARK: Set ship, shot, bullet colors (a0 = player pal, a1 = shot pal). Also parallax sprites
	;rts
	;set sprite ship colors -> colRegs 224ff
								move.l					#$e*16,d4																																																									;224 > 240
								moveq					#15,d7
.colShipSprRead
								lea						1(a0),a0
								move.w					d4,d3
								move.b					(a0)+,d0
								move.b					(a0)+,d1
								move.b					(a0)+,d2
								WRITECOLOR
								addq					#1,d4
								dbra					d7,.colShipSprRead

;	#MARK: - enemy bullet colors
								cmpi.w					#3,gameStatusLevel(pc)
								seq						d0
								andi					#enemShotColors_stage3-enemShotColors,d0
								lea						enemShotColors(pc,d0),a1																																																					;enem shot colors
								moveq					#$c,d4
								lsl.b					#4,d4																																																										; $c0 -> color regs 192
								moveq					#0,d3
								moveq					#2,d7
.colSprRead
								clr.l					d0
								lea						1(a1),a1
								move.b					(a1)+,d0
								move.b					(a1)+,d1
								move.b					(a1)+,d2

								move					d4,d3
								add						#32+5,d3																																																									; 224+5 = bank 7, +$a
								WRITECOLOR																																																															; set sprite 3	; bullet colors basic version
								move					d4,d3
								add						#32+9,d3																																																									; 224+9 = bank 7, +$12
								WRITECOLOR																																																															; set sprite 5
								move					d4,d3
								add						#48+5,d3																																																									; 240+5 = bank 7, +$2a
								WRITECOLOR																																																															; set sprite 2
								move					d4,d3
								add						#48+9,d3																																																									; 240+9 = bank 7, +$32
								WRITECOLOR																																																															; set sprite 4
								addq					#1,d4
								dbra					d7,.colSprRead

	; set xtra weapon colors
								lea						CUSTOM,a6
								move					#%1110000000000000,BPLCON3(a6)
								move					#$b80,COLOR17(a6)																																																							; from dark to bright
								move					#$ec0,COLOR19(a6)
								move					#$ff0,COLOR18(a6)
								rts

colorManager
;MARK: Game MainPlane Colors
	;	#MARK: - load main palette
 	;move.l mainPlanePalette(pc),a0
								move.l					#colorDefsFile,d1																																																							; Load main color data
								move.l					diskBuffer+4(pc),d2
								moveq					#16*4+8*4,d3																																																								; 16+8 colors
								bsr						createFilePathOnStage
								bsr						loadFile
								tst.l					d0
								beq						errorDisk

								IFEQ					(RELEASECANDIDATE||DEMOBUILD)
								IF						1=1																																																											; set all colors to bright blue. Just for checking if all colors are set correctly
								move					#256,d7
								clr.b					d0
								clr.b					d1
								st.b					d2
								bra						.qqqqq
.loopq1
								move					d7,d3
								WRITECOLOR
.qqqqq
								dbra					d7,.loopq1
								ENDIF
								ENDIF

								IF						0=1																																																											; set some colors to blue
								move					#2,d7
.loopq2
								move					#0,d0
								move					#0,d1
								move					#-1,d2
								move					d7,d3
								add						#241,d3
								WRITECOLOR
.qq
								dbra					d7,.loopq2
								ENDIF


	; escalation colors. font colors set within escl coplist
								move					#7,d7
								move.w					gameStatusLevel(pc),d0
								lea						.reds(pc,d0*8),a0
								lea						copEscalateReds+2,a6
.loop
								move.b					(a0)+,(a6)																																																									; set 7 red shaded main visual  layer colors
								lea						4(a6),a6
								dbra					d7,.loop

								lea						gameStatusLevel(pc),a0
								move.w					(a0),d0
								move.w					(.jmpTable,pc,d0.w*2),d0

								move.l					diskBuffer+4(pc),a0																																																							; color rgbs in 24 bit format
								lea						colorAlphaTable,a1
								clr.l					d3
								clr.l					d4
								clr.l					d5
.jmp								jmp						.jmp(pc,d0.w)
.jmpTable		; color jumper
								dc.w					.stage0-.jmpTable+2
								dc.w					.stage1-.jmpTable+2
								dc.w					.stage2-.jmpTable+2
								dc.w					.stage3-.jmpTable+2
								dc.w					.stage4-.jmpTable+2
								dc.w					.stage5-.jmpTable+2
.reds
								dc.b					$2,$6,$3,$6,$4,$3,$4,$c																																																						; bone valley
								dc.b					$2,$6,$4,$6,$4,$2,$6,$6																																																						; ??
								dc.b					$2,$6,$2,$8,$5,$4,$3,$3
								dc.b					$0,$6,$4,$6,$4,$2,$6,$6																																																						; ??
								dc.b					$0,$6,$4,$6,$4,$2,$6,$6																																																						; ??
								dc.b					$0,$6,$4,$6,$4,$2,$6,$6																																																						; ??


;	#MARK: colors stage 0

.stage0
								clr.w					d3
								clr.w					d4
								clr.w					d5

								move					#(1<<fxPlaneDepth)-5,d7
.colRead0
								move					#11,d0
								sub						d7,d0

								move.l					a1,a2
								move.l					a0,a3
								move					#(1<<mainPlaneDepth)-1,d6																																																					; loop through all 16 colors
.colWriteFade0               ; inner loop, write 16 colors with progressing hue
	;clr.w d3
								move					(a2)+,a4																																																									; which color register?
								lea						1(a3),a3
								move.b					(a3)+,d0
								move.b					(a3)+,d1
								move.b					(a3)+,d2
								IF						0=1																																																											; 1=1 to test greyscale alpha
								move					#1,d0
								move					#1,d1
								move					#1,d2
								ENDIF

								clr.l					d3
								clr.l					d4
								clr.l					d5
								move					#11,d5
								sub						d7,d5
	;move #0,d0
								move.b					.vfxColors0+1(pc,d5*4),d3
								move.b					.vfxColors0+2(pc,d5*4),d4
								move.b					.vfxColors0+3(pc,d5*4),d5
								cmpi					#(1<<mainPlaneDepth)-1,d6																																																					; check if bitplan is 0
								bne						.doColor0
.base							SET						4
.range							SET						12*32

								move					d7,a5

								move					d3,d0
								move					d4,d1
								move					d5,d2
    ;lsr #1,d0
    ;lsr #1,d1
    ;lsr #1,d2
								move					a5,d7
								bra.b					.writeColor0
.s0AlphaScaler
								dc.b					$00,$04,$08,$10
								dc.b					$18,$1c,$20,$24
								dc.b					$28,$30,$38,$44
								dc.b					$60,$00

    ; do fx colors for nontransparent playfield pixels
.doColor0

								add						d3,d5
								add						d4,d5
								lsl						#4,d5
								move					a5,d4
	;lsr #1,d4
								move					#12,d3
								sub						d4,d3
								seq						d4
								move					d3,d5
								move.b					(.s0alphaScaler,pc,d5.w),d5

	;lsl #4,d5

	;andi #1,d4
								or						d4,d3																																																										; avoid div by zero exception
	;divu d3,d5
	;sub #100,d5
	;bpl .ss4
	;sf.b d5
.ss0
	;sf.b d5
	;move.b #15,d5

								add.b					d5,d0
								bcc.b					.keepRR0
								st.b					d0
.keepRR0
								add.b					d5,d1
								bcc.b					.keepGG0
								st.b					d1
.keepGG0
								add.b					d5,d2
								bcc.b					.keepBB0
								st.b					d2
.keepBB0

.writeColor0
	; write colors
								exg.l					a4,d3
    ;moveq #-1,d0
    ;moveq #-1,d1
    ;moveq #-1,d2
  ;clr.w d0
  ;clr.w d1	; set color to blue
								WRITECOLOR																																																															; 8 shades of colors at 0000
								exg.l					a4,d3
								dbra					d6,.colWriteFade0

								lea						32(a1),a1
								dbra					d7,.colRead0
								rts
.vfxColors0
								INCBIN					stage4/vfxColors.pal																																																						; used to be stage4, now its stage0

								move					#(1<<fxPlaneDepth)-5,d7

.colRead3
								move.l					a1,a2
								move.l					a0,a3
								move					#(1<<mainPlaneDepth)-1,d6																																																					; loop through all 16 colors
.colWriteFade3               ; inner loop, write 16 colors with progressing hue
	;clr.w d3
								move					(a2)+,a4																																																									; which color register?
								lea						1(a3),a3
								move.b					(a3)+,d0
								move.b					(a3)+,d1
								move.b					(a3)+,d2
    ;bra .doColor3
								cmpi					#(1<<mainPlaneDepth)-1,d6																																																					; check if bitplan is 0
								bne						.doColor3

    ; set vfx colors for transparent background

    ;cmpi #(1<<fxPlaneDepth)-5,d7
    ;bne .s1


    ;lea 0,a6
    ;movem.w (a6),d3-d5 ; shading-values to begin with (rgb)
.s1
    ; do fx colors for transparent playfield pixels
.base							SET						10
.range							SET						12*32
								move					d7,a5
								move					#.base+$b,d7																																																								;254
								sub						a5,d7
								mulu					#.range,d7																																																									; range, 74*18 means maximum from 0 to $f0 (approx.)
								lsr.w					#5,d7
								add.b					d7,d0
								bcc.b					.keepR3
								st.b					d0
.keepR3
								move					#.base,d7
								sub						a5,d7
								mulu					#.range,d7
								lsr.w					#5,d7
								add.b					d7,d1
								bcc.b					.keepG3
								st.b					d1
.keepG3
								move					#.base,d7
								sub						a5,d7
								mulu					#.range,d7
								lsr.w					#5,d7
								add.b					d7,d2
								bcc.b					.keepB3
								st.b					d2
.keepB3
								move					a5,d7
								bra.b					.writeColor

    ; do fx colors for nontransparent playfield pixels
.doColor3
								add.b					d3,d0
								bcc.b					.keepRR3
								st.b					d0
.keepRR3
								add.b					d4,d1
								bcc.b					.keepGG3
								st.b					d1
.keepGG3
								add.b					d5,d2
								bcc.b					.keepBB3
								st.b					d2
.keepBB3
.writeColor
	; write colors
								exg.l					a4,d3
    ;moveq #-1,d0
    ;moveq #-1,d1
    ;moveq #-1,d2
  ;clr.w d0
  ;clr.w d1	; set color to blue
								WRITECOLOR																																																															; 8 shades of colors at 0000
								exg.l					a4,d3
								dbra					d6,.colWriteFade3

								lea						32(a1),a1
								add.b					#$12,d3																																																										; add red to main pal
								bcc						.keepRRR3
								st.b					d3
.keepRRR3
								add.b					#$12,d4																																																										; add green to main palette
								bcc.b					.keepGGG3
								st.b					d4
.keepGGG3
								add.b					#$12,d5																																																										;add blue to main pal
								bcc.b					.keepBBB3
								st.b					d5
.keepBBB3
								dbra					d7,.colRead3
								rts
;.vfxColors0
;	INCBIN	stage0/vfx.pal	; used to be stage4, now its stage0


;	#MARK: colors stage 1


.stage1
.storeColors

; #MARK: install main palette

								WAITVBLANK
								lea						5(a0),a0
								lea						64(a0),a2
								moveq					#1,d3
								move.w					#14,d7
.wrtFrntCol
								move.b					(a0)+,d0
								move.b					(a0)+,d1
								move.b					(a0)+,d2
	;moveq #$cf,d0
	;moveq #3,d1
	;moveq #9,d2
								WRITECOLOR
								addq					#1,a0
								addq					#1,d3
								dbra					d7,.wrtFrntCol

								moveq					#17,d3
								move.w					#7,d7
.wrtBckCol
								move.b					(a2)+,d0
								move.b					(a2)+,d1
								move.b					(a2)+,d2
	;moveq #-1,d0
	;moveq #-1,d1
	;moveq #-1,d2
								WRITECOLOR
								addq					#1,a2
								addq					#1,d3
								dbra					d7,.wrtBckCol
								rts



;	#MARK: colors stage 2
.stage2

;    lea lv0boneShades,a2
 ;   movem.w (a2),d3-d5 ; shading-values to begin with (rgb)
								clr.w					d3
								clr.w					d4
								clr.w					d5


								move					#(1<<fxPlaneDepth)-5,d7

.2colRead3B
								move					#11,d0
								sub						d7,d0
	;move #0,d0
								move.b					.vfxColors2+1(pc,d0*4),d3
								move.b					.vfxColors2+2(pc,d0*4),d4
								move.b					.vfxColors2+3(pc,d0*4),d5
	;move.w #-1,d3
	;move.w #-1,d4
	;move.w #-1,d5
	;clr.w d4
	;clr.w d5
								move.l					a1,a2
								move.l					a0,a3
								move					#(1<<mainPlaneDepth)-1,d6																																																					; loop through all 16 colors

.2colWriteFade3B               ; inner loop, write 16 colors with progressing hue
	;clr.w d3
								move					(a2)+,a4																																																									; which color register?
								lea						1(a3),a3

								move.b					(a3)+,d0
								move.b					(a3)+,d1
								move.b					(a3)+,d2

								clr.l					d3
								clr.l					d4
								clr.l					d5
								move					#11,d5
								sub						d7,d5
								move.b					.vfxColors2+1(pc,d5*4),d3
								move.b					.vfxColors2+2(pc,d5*4),d4
								move.b					.vfxColors2+3(pc,d5*4),d5

    ;bra .2doColor3
								cmpi					#(1<<mainPlaneDepth)-1,d6																																																					; check if bitplan is 0
								bne						.2doColor3B
;    bra.b .2writeColorB

    ; do fx colors for transparent playfield pixels
.base							SET						4
.range							SET						12*32
								move					d7,a5

								move					d3,d0
								move					d4,d1
								move					d5,d2
   ; lsr #1,d0
    ;lsr #1,d1
    ;lsr #1,d2
								move					a5,d7
								bra.b					.2writeColorB

    ; do fx colors for nontransparent playfield pixels
.2doColor3B
.muls							SET						16
.lsr							SET						5
								cmpi					#(1<<fxPlaneDepth)-5,d7																																																						; darkest vfx layer color? Skip color modification
								beq						.2writeColorB

								move					#((1<<fxPlaneDepth)-5)*2,d5
								sub						d7,d5
								sub						d7,d5
								muls					#10,d5
	;add #50,d5
								bpl						.2ss1
								move					#35,d5																																																										; set value for lowest storm density areas
.2ss1
								add.b					d5,d0
								bcc.b					.2keepRR3B
								st.b					d0
.2keepRR3B
								add.b					d5,d1
								bcc.b					.2keepGG3B
								st.b					d1
.2keepGG3B
								lsr.b					#1,d5
								add.b					d5,d2
								bcc.b					.2keepBB3B
								st.b					d2
.2keepBB3B
.2writeColorB
	; write colors
								exg.l					a4,d3

								WRITECOLOR																																																															; 8 shades of colors at 0000
								exg.l					a4,d3
								dbra					d6,.2colWriteFade3B
								lea						32(a1),a1
								dbra					d7,.2colRead3B
								rts
.vfxColors2
								INCBIN					stage2/vfx.pal

;	#MARK: colors stage 3

.stage3
;    lea lv0boneShades,a2
 ;   movem.w (a2),d3-d5 ; shading-values to begin with (rgb)
								clr.w					d3
								clr.w					d4
								clr.w					d5


								move					#(1<<fxPlaneDepth)-5,d7

.colRead3B
								move					#11,d0
								sub						d7,d0
	;move #0,d0
								move.b					.vfxColors3+1(pc,d0*4),d3
								move.b					.vfxColors3+2(pc,d0*4),d4
								move.b					.vfxColors3+3(pc,d0*4),d5
	;move.w #-1,d3
	;move.w #-1,d4
	;move.w #-1,d5
	;clr.w d4
	;clr.w d5
								move.l					a1,a2
								move.l					a0,a3
								move					#(1<<mainPlaneDepth)-1,d6																																																					; loop through all 16 colors

.colWriteFade3B               ; inner loop, write 16 colors with progressing hue
	;clr.w d3
								move					(a2)+,a4																																																									; which color register?
								lea						1(a3),a3



								move.b					(a3)+,d0
								move.b					(a3)+,d1
								move.b					(a3)+,d2
								IF						1=0
								move.b					d0,d3
								move.b					d1,d4
								move.b					d2,d5
								lsr						#4,d3
								lsr						#4,d4
								lsr						#4,d5
								muls					#299,d3
								muls					#587,d4
								muls					#114,d5
								add.w					d3,d4
								add.w					d5,d4
								divu					#1000,d4																																																									; brightness of main color
								move.w					d4,a5
								ENDIF
								clr.l					d3
								clr.l					d4
								clr.l					d5
								move					#11,d5
								sub						d7,d5
	;move #0,d0
								move.b					.vfxColors3+1(pc,d5*4),d3
								move.b					.vfxColors3+2(pc,d5*4),d4
								move.b					.vfxColors3+3(pc,d5*4),d5

    ;bra .doColor3
								cmpi					#(1<<mainPlaneDepth)-1,d6																																																					; check if bitplan is 0
								bne						.doColor3B
    ; do fx colors for transparent playfield pixels
.base							SET						4
.range							SET						12*32
								move					d7,a5

								move					d3,d0
								move					d4,d1
								move					d5,d2
    ;lsr #1,d0
    ;lsr #1,d1
    ;lsr #1,d2
								move					a5,d7
								bra.b					.writeColorB

    ; do fx colors for nontransparent playfield pixels
.doColor3B
.muls							SET						16
.lsr							SET						5
								cmpi					#(1<<fxPlaneDepth)-5,d7																																																						; darkest vfx layer color? Skip color modification
								beq						.writeColorB

								add						d3,d5
								add						d4,d5
								lsl						#4,d5
								move					a5,d4
								lsr						#1,d4
								move					#22,d3
								sub						d4,d3
								seq						d4
	;andi #1,d4
								or						d4,d3																																																										; avoid div by zero exception
								divu					d3,d5
								sub						#60,d5
								bpl						.ss1
								sf.b					d5
.ss1
								add.b					d5,d0
								bcc.b					.keepRR3B
								st.b					d0
.keepRR3B
								add.b					d5,d1
								bcc.b					.keepGG3B
								st.b					d1
.keepGG3B
								lsr.b					#1,d5
								add.b					d5,d2
								bcc.b					.keepBB3B
								st.b					d2
.keepBB3B
	;lsr #1,d2

.writeColorB
	; write colors
								exg.l					a4,d3
								WRITECOLOR																																																															; 8 shades of colors at 0000
								exg.l					a4,d3
								dbra					d6,.colWriteFade3B
								lea						32(a1),a1
								dbra					d7,.colRead3B
								rts
.vfxColors3
								INCBIN					stage3/vfxColors3.pal


;	#MARK: colors stage 4

.stage4
								clr.w					d3
								clr.w					d4
								clr.w					d5

								move					#(1<<fxPlaneDepth)-5,d7
.colRead4
								move					#11,d0
								sub						d7,d0

								move.l					a1,a2
								move.l					a0,a3
								move					#(1<<mainPlaneDepth)-1,d6																																																					; loop through all 16 colors
.colWriteFade4               ; inner loop, write 16 colors with progressing hue
	;clr.w d3
								move					(a2)+,a4																																																									; which color register?
								lea						1(a3),a3
								move.b					(a3)+,d0
								move.b					(a3)+,d1
								move.b					(a3)+,d2
								IF						0=1																																																											; 1=1 to test greyscale alpha
								move					#1,d0
								move					#1,d1
								move					#1,d2
								ENDIF

								clr.l					d3
								clr.l					d4
								clr.l					d5
								move					#11,d5
								sub						d7,d5
	;move #0,d0
								move.b					.vfxColors4+1(pc,d5*4),d3
								move.b					.vfxColors4+2(pc,d5*4),d4
								move.b					.vfxColors4+3(pc,d5*4),d5
								cmpi					#(1<<mainPlaneDepth)-1,d6																																																					; check if bitplan is 0
								bne						.doColor4
.base							SET						4
.range							SET						12*32

								move					d7,a5

								move					d3,d0
								move					d4,d1
								move					d5,d2
    ;lsr #1,d0
    ;lsr #1,d1
    ;lsr #1,d2
								move					a5,d7
								bra.b					.writeColor4
.skyAlphaScaler
								dc.b					$00,$00,$00,$10
								dc.b					$20,$40,$50,$60
								dc.b					$70,$80,$90,$a0
								dc.b					$b0,$c0,$d0,$f0

    ; do fx colors for nontransparent playfield pixels
.doColor4

								add						d3,d5
								add						d4,d5
								lsl						#4,d5
								move					a5,d4
	;lsr #1,d4
								move					#12,d3
								sub						d4,d3
								seq						d4
								move					d3,d5
								move.b					(.skyAlphaScaler,pc,d5.w),d5

	;lsl #4,d5

	;andi #1,d4
								or						d4,d3																																																										; avoid div by zero exception
	;divu d3,d5
	;sub #100,d5
	;bpl .ss4
	;sf.b d5
.ss4
	;sf.b d5
	;move.b #15,d5

								add.b					d5,d0
								bcc.b					.keepRR4
								st.b					d0
.keepRR4
								add.b					d5,d1
								bcc.b					.keepGG4
								st.b					d1
.keepGG4
								add.b					d5,d2
								bcc.b					.keepBB4
								st.b					d2
.keepBB4

.writeColor4
	; write colors
								exg.l					a4,d3
    ;moveq #-1,d0
    ;moveq #-1,d1
    ;moveq #-1,d2
  ;clr.w d0
  ;clr.w d1	; set color to blue
								WRITECOLOR																																																															; 8 shades of colors at 0000
								exg.l					a4,d3
								dbra					d6,.colWriteFade4

								lea						32(a1),a1
								dbra					d7,.colRead4
								rts
.vfxColors4
								INCBIN					stage4/vfx.pal

;	#MARK: colors stage 05 outro

.stage5
								clr.w					d3
								clr.w					d4
								clr.w					d5

								move					#(1<<fxPlaneDepth)-5,d7
.colRead5
								move					#11,d0
								sub						d7,d0

								move.l					a1,a2
								move.l					a0,a3
								move					#(1<<mainPlaneDepth)-1,d6																																																					; loop through all 16 colors
.colWriteFade5               ; inner loop, write 16 colors with progressing hue
								move					(a2)+,a4																																																									; which color register?
								lea						1(a3),a3
								move.b					(a3)+,d0
								move.b					(a3)+,d1
								move.b					(a3)+,d2

								cmpi					#(1<<mainPlaneDepth)-1,d6																																																					; check if bitplan is 0
								bne						.doColor5

    ; set vfx colors for transparent background

.base							SET						4
.range							SET						12*32

								move					d7,a5
    ;moveq #-1,d1
    ;moveq #-1,d2
    ;moveq #-1,d3
								bra						.doColor5
								bra.b					.writeColor5
    ; do fx colors for nontransparent playfield pixels
.doColor5

								add						d3,d5
								add						d4,d5
								lsl						#4,d5
								move					a5,d4
								move					#12,d3
								sub						d4,d3
								seq						d4
								move					d3,d5
								move.b					(.outroAlphaScaler,pc,d5.w),d5
	;or d4,d3	; avoid div by zero exception

.ss5

								add.b					d5,d0
								bcc.b					.keepRR5
								st.b					d0
.keepRR5
								add.b					d5,d1
								bcc.b					.keepGG5
								st.b					d1
.keepGG5
								add.b					d5,d2
								bcc.b					.keepBB5
								st.b					d2
.keepBB5
;	clr.w d0
;	clr.w d1
;	clr.w d2

.writeColor5
								exg.l					a4,d3
;	clr.w d0
;	clr.w d1
;	clr.w d2
								WRITECOLOR																																																															; 8 shades of colors at 0000
								exg.l					a4,d3
								dbra					d6,.colWriteFade5

								lea						32(a1),a1
								dbra					d7,.colRead5
								rts
.outroAlphaScaler
								dc.b					$00,$04,$06,$08
								dc.b					$0a,$0c,$10,$14
								dc.b					$16,$18,$1a,$1c
								dc.b					$20,$20

enemShotColors
								dc.b					0,$6c,$20,0																																																									; outline of bullets
								dc.b					-1,$d0,$d0,0
								dc.b					0,$ff,-1,-1																																																									; centre of bullets, centre of vessel exhaust -> pulsating color
enemShotColors_stage3
								dc.b					0,$99,$99,$99																																																								;	darkest color
								dc.b					0,$cc,$fe,$c9																																																								; 	max brightness
								dc.b					0,155,210,5																																																									;	medium color


playerVesselPalette
								Incbin					incbin/palettes/ship.pal
								even

								ENDIF

wrtTextOneShortPlane
								move.w					#mainPlaneWidth,d7
								bra.b					wrtTextOP
wrtTextOnePlane
								move.w					#mainPlaneWidth*mainPlaneDepth,d7
	;move.w #mainPlaneWidth,d7
wrtTextOP
								move.l					a3,-(sp)
								lea						wrt1plane(pc),a3																																																							; jump vector
								bra						wrtTextSkip
wrtTextBitmap
	;  	a0.l	-> 	textaddress
	; 	d0		->	x-coord
	;	d1		->	y-coord
	;	a5/a6	->	targetscreens (doublebuffer, base) optimised for write to 3 bitplanes
    ;	destroys a1,a2,a4,a5,a6,d0,d1,d2,d3,d4,d6

								move.l					a3,-(sp)
								lea						wrt3planes(pc),a3
wrtTextSkip
								cmp.l					#0,a5
								beq						.quitText
								moveq					#0,d3
								clr.l					d4
								st.b					d4																																																											;=$000000ff
								and.l					d4,d0
								asl						#1,d4
								and.l					d4,d1
								divu					#8,d0
								muls					#mainPlaneWidth*mainPlaneDepth,d1
								andi.l					#$3f,d0
								add.l					d0,d1
								move.l					d1,a1
								add.l					a5,a1
								clr.l					d4
    ;sf.b d4
								lea						font,a4

.readChar
								move.l					a1,a2
								moveq					#0,d6
								move.b					(a0)+,d6
								beq						.quitText
								cmpi.b					#"@",d6
								bgt						.gotLetter
								sub						#" ",d6
								move.b					charConvTable(pc,d6),d6
								jsr						(a3)
								addq.l					#1,d4
								bra						.readChar
.gotLetter
								sub						#49,d6
								jsr						(a3)
								addq.l					#1,d4
								bra						.readChar
.quitText
								move.l					(sp)+,a3
								rts
charConvTable
								dc.b					15,11,0,10,128,129,13,0																																																						; 32 - 39 " ","!","$"(Color Switch),"%"(NOOP), #"(Delta),"&"(%)
								dc.b					0,0,0,0,0,14,12,0																																																							; 40-47, "-","."
								dc.b					0,1,2,3,4,5,6,7,8,9																																																							; 48-57
wrt3planes
								move					#8,d5
								move					d4,d3
								move					#3,d2
.wrtLine
								move.b					4(a4,d6*8),d1
								move.b					d1,(mainPlaneWidth*4)*4(a2,d3)
								move.l					(a4,d6*8),d1
								move.b					d1,(mainPlaneWidth*4)*3(a2,d3)
								lsr.l					d5,d1
								move.b					d1,(mainPlaneWidth*4)*2(a2,d3)
								lsr.l					d5,d1
								move.b					d1,(mainPlaneWidth*4)*1(a2,d3)
								lsr.w					d5,d1
								move.b					d1,(mainPlaneWidth*4)*0(a2,d3)
								clr.b					(mainPlaneWidth*4)*5(a2,d3)
								clr.b					(mainPlaneWidth*4)*6(a2,d3)
								add.w					#mainPlaneWidth,d3
								dbra					d2,.wrtLine
								rts
wrt1plane
								move					d4,d3
								moveq					#fontHeight-2,d2
.wrtLine
								move					#8,d5
								move					d4,d3
								move.b					4(a4,d6*8),d1
								move.b					d1,(mainPlaneWidth*4)*4(a2,d3)
								move.l					(a4,d6*8),d1
								move.b					d1,(mainPlaneWidth*4)*3(a2,d3)
								lsr.l					d5,d1
								move.b					d1,(mainPlaneWidth*4)*2(a2,d3)
								lsr.l					d5,d1
								move.b					d1,(mainPlaneWidth*4)*1(a2,d3)
								lsr.w					d5,d1
								move.b					d1,(mainPlaneWidth*4)*0(a2,d3)
								clr.b					(mainPlaneWidth*4)*5(a2,d3)
								clr.b					(mainPlaneWidth*4)*6(a2,d3)
								rts


; #MARK: - TITLE MANAGER BEGINS


        ; MARK: - TITLESCREEN INIT
mainTitle

								IF						INITWITH=30
								lea						gameStatusLevel(pc),a0
								move.w					#-1,(a0)																																																									; reset level status pointer
								ENDIF
								lea						vars(pc),a5
								sf.b					gameInActionF-vars(a5)																																																						; disable gamecode in interrupt
								sf.b					blitterManagerFinished-vars(a5)																																																				; no buffer swapping
								clr.w					escalateIsActive-vars(a5)																																																					; reset escalateIsActive, dialogueIsActive,
								sf.b					killShakeIsActive-vars(a5)																																																					; reset killShakeIsActive
								sf.b					plyCheatEnabled+plyBase-vars(a5)																																																			; reset cheatflag

								IF						INITWITH=30
								sf.b					introLaunched-vars(a5)																																																						; temp to always start music
								ENDIF
								tst.b					introLaunched-vars(a5)
								bne						.keepIntroMusicPlayin																																																						; keep start music playing if first init of titlescreen
								IF						INITWITH=30
								sf.b					d0
								bsr						installAudioDriver																																																							; for testing only. Launch if titlescreen is init'ed first
								ENDIF
								move.w					#-1,gameStatusLevel-vars(a5)
								bsr						initAudioTrack
.keepIntroMusicPlayin
								sf.b					introLaunched-vars(a5)																																																						; temp to always start music
								clr.b					fxInit-vars(a5)

;    tst.b gameStatus
 ;   bpl .skipFirstStart             ; init fade-coplist and copFadeCnt to copy with first fade
  ;  bclr.b #7,gameStatus      ; killbit, indicating that first launch of titlescreen has happened
;.skipFirstStart

								sf.b					titleHighFlag-vars(a5)
								move.w					#-1,gameStatusLevel-vars(a5)

								lea						CUSTOM,a6
	;move.w #DMAF_BPLEN,DMACON(a6); sprites and bpl dma off
	;	move.w #DMAF_SETCLR|DMAF_SPRITE,DMACON(a6); enable sprites
	;move #BRDRBLNKF,BPLCON3(a6); 	black screen
								clr.w					COLOR00(a6)

								bsr						blankSprite
								jsr					prepareDisplay

	; prepare artwork (64 colors, 6 bitplanes)

								lea						titlePicFilename(pc),a0
								move.l					a0,d1
								bsr						createFilePathOnStage
								jsr						GetFileInfo
								tst.l					d0
								beq						errorDisk
								move.l					(fib_Size.w,pc),d7																																																							; fetch size of raw picture
								move.l					d7,tempVar+28
								move.l					d7,d3
								divu					#6,d7


	; prep bitplane pointers
								lea						copBPLPT,a5
								move.l					artworkBitplane(pc),d1
								move.l					d1,d2
								moveq					#7,d6
.prepBitplaneAdress
								move					d1,6(a5)
								swap					d1
								move					d1,2(a5)
								swap					d1
								add.l					d7,d1
								lea						8(a5),a5
								dbra					d6,.prepBitplaneAdress


	; load title artwork


								lea						titlePicFilename(pc),a0
								move.l					a0,d1
								bsr						createFilePathOnStage
								bsr						loadFile
								tst.l					d0
								beq						errorDisk


	;WAITSECSSET 6
	;WAITSECS

								lea						scrMngOffset(pc),a0
								move.w					#screenManagerLv0-jmpSrcMngOffset,(a0)


								lea						CUSTOM,a6																																																									; setup copperlist
	;clr.w copBPL2ModOffset+2

								move.w					#$38,DDFSTRT(a6)
								move.w					#$a0,DDFSTOP(a6)
								move.w					#$2ca6,COPDIWSTRT+2																																																							; window
								move.w					#$b100,COPDIWHIGH+2
								move.w					#$289c,DIWSTOP(a6)
								move					#ECSENAF!BPU1F!BPU2F!CONCOLF,copBPLCON0+2

								move.w					#$8800,copBPLCON1+2
								move.w					#KILLEHBF!%111111,copBPLCON2+2
								move.w					#BRDSPRTF|BRDRBLNKF,copBPLCON3+2
								move.w					#%0000000000001111,FMODE(a6)																																																				;64 pixel sprites
	;move.w #BRDSPRTF|SPRES1F,CUSTOM+BPLCON3
	;clr.w CUSTOM+Color00
	;move.w #$32b4,COPDIWSTRT+2
	;move.w #$3920,COPDIWHIGH+2	; set transition

	;WAITSECSSET 6
	;WAITSECS

								WAITVBLANK
								lea						(titleCopFilename,pc),a0
								bsr						loadMainCopList
								lea						copGameDefault,a0																																																							; copy return address to coplist
								movem.l					(a0),d0-d3
								movem.l					d0-d3,(a1)																																																									; copy return cmd chain to eof coplist




	; dynamic store in tempvar:  0.l -> SPR0PTH, +4.l -> SPR0POS, +8.l COLOR17, +12.l SPR0PTH+SPR0POS II (spieleschreiber), +16.l COLORS29-31 engine colors, +20.l pointer to BPLCON1-list
	; predef´d store in tempvar: +24.l Base of coord conv table, +28.l -> size of artwork, +32.w fadeCounter,+34.w pointer to high ranking display name,+36.w pointer to high ranking data table
	; fetch dynamic pointers from coplist

								move.l					copperGame(pc),a0
								lea						(tempVar,pc),a2
.findPointers
								cmpa.l					a1,a0
								bhi						.foundPointers
								lea						4(a0),a0
								cmpi.w					#NOOP,(a0)
								bne						.findPointers
								move.w					2(a0),d0
								lea						4(a0),a0
								move.l					a0,(a2,d0*4)
								bra						.findPointers
.foundPointers

								clr.l					d7
								lea						titleSprites,a5																																																								; init sprite-DMA / title logo
								move.l					#$445e6d00,d5
								move.w					#titleSpritesOffset,d7
								bsr						titleShowSprites
								suba					d7,a0
								sub.b					#14,1(a0)
								suba					d7,a0
								sub.b					#14,1(a0)

	; prepare text sprites

								move.l					(tempVar,pc),a0
								move.l					mainPlanes+4(pc),a1
								bsr						installSpritePointers

	; prepare spieleschreiber sprites

								move.l					(12+tempVar,pc),a0
								move.l					#titleSpieleschreiber,d0
								move.l					#titleSpieleschreiber+(titleSpieleschreiberEnd-titleSpieleschreiber)/2,d1
								move.w					d0,6(a0)
								move.w					d1,8+6(a0)
								swap					d0
								swap					d1
								move.w					d0,2(a0)
								move.w					d1,8+2(a0)

								move.l					tempVar+28(pc),d7																																																							; fetch size of raw picture
								move.l					artworkBitplane(pc),a6																																																						; create conversion table x/y coords to sprite address
								lea						(a6,d7),a6																																																									; pointer to position conversion table
								bsr						createTableTextSpritesCoord

	;#MARK: Check and enter new highscore entry

								lea						newHighText(pc),a6
								move.b					#14,(a6)																																																									; reset "new"-text
								lea						tempVar+36(pc),a5
								clr.l					(a5)																																																										; reset marker to ranking table
				; attn: (a5) accessed again incase of highscore

								lea						score(pc),a3
								cmpi.l					#$99999999,(a3)
								bne						.ScoreBugfix																																																								; ugly fix for some bug that lead to having a score of 99999999 when entering highscore view. Cause  remains mysterious
								clr.l					(a3)
.ScoreBugfix
								IFNE					HIGHSCORE_OVERRIDE
								move.l					#HIGHSCORE_OVERRIDE,(a3)																																																					; MODIFY SCORE IF NEEDED FOR TESTING
								ENDIF

								lea						highData(pc),a4																																																								; new hiscore?
								move.l					(a3),d1
								moveq					#9,d7																																																										; no of high entrys
.compareHigh
								move.l					(a4),d0
								cmp.l					d0,d1
								bhi.b					.gotHigh																																																									; found new highscore – prepare setup
								lea						8(a4),a4
								dbra					d7,.compareHigh
								bra.w					.buildHighDisplay																																																							; no new highscore - further preps

	; copy score to highscore table
.gotHigh
								moveq					#10,d6
								sub.b					d7,d6
								move.b					d6,titleHighFlag

								move					d6,d4
								muls					#(titleHighHeroesEnd-titleHighHeroes)/10,d4
								sub						#4,d4
								move.w					d4,(a5)+																																																									; store pointer to displayed name

								move					d6,d4
								lsl						#3,d4
								sub						#4,d4
								move.w					d4,(a5)																																																										; ; store pointer to database name

								add.b					#2,d6
								move.b					d6,1(a6)																																																									; display "new" at y-coord

								lea						highDataEnd(pc),a1
								lea						-8(a1),a0
								tst.b					d7
								beq						.skipMove
								subq					#1,d7
.moveHigh
								move.l					-(a0),-(a1)
								move.l					-(a0),-(a1)
								dbra					d7,.moveHigh
.skipMove
								move.l					d1,(a0)																																																										; copy score to hero table

	; generate alphanumerical code for upload score to website. BCD-score in d0.l converted to string with numbase 23 (vs. bin, dec, hex etc.) plus checksum

.numBase						=						23
.encodeHighscore
								lea						scoreHighEncoded+9(pc),a0
								move.l					#"XXXX",d1
								move.l					d1,d2
								movem.l					d1-d2,-9(a0)																																																								; reset encoding space. Two rightmost numbers do not need reset, as they are always written
								clr.l					d1
								clr.l					d2
								clr.l					d7

								move.l					score(pc),d0																																																								; fetch last score
								move.l					#.numBase,d3																																																								; load code numbase
.loopDigit
								divul.l					d3,d1:d0																																																									; d1 = remainder, d0 = result
								beq						.lastDigit
								add.l					d1,d2
								add.b					#"A",d1
								move.b					d1,-(a0)																																																									; store -> encoding space
								bra						.loopDigit
.lastDigit
								add.l					d1,d2
								add.b					#"A",d1
								move.b					d1,-(a0)																																																									; store leftmost digit
								divul.l					d3,d1:d2																																																									; calc checksum. ; d1 = remainder, d2 = result

								move.b					#.numBase-1,d0
								sub.b					d1,d0
								add.b					#"A",d0
								move.b					d0,-(a0)																																																									; store remainder of checksum


								IF						0=1
; decoding needed only for testing ...

    ; Highscore Decoder
    ; Decode 8 char alphanumerical string into number in Motorola bcd (binary coded decimal)-format: $11 means 11 dec, $20 means 20 dec)

    ;	-> field of 8 bytes / chars. Can contain letters a to x, where a to w stand for numerical value, x stands for end of field

		; ATTN: Read doc "how to decode rp3 highscore" for detailed instruction on how the code is built
    ;	Examples
    ;
    ; 	RF 		decodes to 		5
    ;	DT			->	 		13
    ;	OWJ			->			203
    ;	DBAS		->			223
    ;	WBAW		->			227
    ;	UBBA		->			228
    ;	TBBB		->			229
    ;	DBJAJ		->			4229
    ;	SBQCFD		->			74229
    ;	QQPSWE		->			474229
    ;	KQIJJDN		->			6474722
    ;	MRAQNPEO	->			946474795
    ;
    ;	You would start decoding at the rightmost character.

    ;	num value is based on a number system with number base 23 (as opposed to the usual 2,10 or 16)

    ;	Read rightmost byte / digit. Scale it down to a number of 0 to 22 by subtracting 65 (representing ASCII-value of the letter "A") of byte
    ;	Multiply result with 1, copy to output result
    ;	Read digit second to the right. Scale it down to a number of 0 to 22
    ;	Multiply the result with 23, add to output result
    ;	Read digit third to the right. Scale it down to a number of 0 to 22
    ;	Multiply the result with 23*23, add to output result
    ;	Read digit fourth to the right. Scale it down to a number of 0 to 22
    ;	Multiply the result with 23*23*23, add to output result
    ; 	and so on, until digit second to the left is reached
    ;
	;	The leftmost digit contains checksum is NOT to be added to output result

    ;	d4 -> 4 bytes output result in bcd-format (score)


								lea						scoreHighEncoded+9(pc),a0																																																					; pointer to end of string
    ;move.b #"F",-3(a0)
								clr.l					d2
								clr.l					d4

								move.l					#.numBase,d3																																																								; number base = 23 (as opposed to the usual 2,10 or 16)
								move.l					#1,d7																																																										; reset digitshifter
.fetchDigit		; loop through string
								clr.l					d0
								move.b					-(a0),d0																																																									; read rightmost char
								cmpi.b					#"X",d0																																																										; char is X, Y or Z? Quit!
								bge						.reachedLastDigit
								sub.b					#"A",d0																																																										; sub 65. A -> 0, B -> 1, C -> 2 ... W = 22
								add.l					d0,d2																																																										; add result to checksum
								move.l					d0,d1																																																										; save for later use
								mulu.l					d7,d0																																																										; Multiply result with digitshifter
								add.l					d0,d4
								mulu.l					d3,d7																																																										; modify digitshifter by multiplying it with numBase 23. 1. loop -> 1, 2. loop = 1*23, 3. loop = 23*23 = 529, 4. loop = 23*23*23 = 12167 ...
								bra						.fetchDigit

.reachedLastDigit
								sub.l					d0,d4																																																										; adjust outputvalue
								sub.l					d1,d2																																																										; adjust checksum adder
								divul.l					d3,d0:d2																																																									; divide checksum by 23. ; d0 = remainder, d2 = result
								move.b					#.numBase-1,d3																																																								; what is 22 minus ...
								sub.b					d2,d3																																																										; ... result of division?
								cmp.b					d3,d1																																																										; d1 = encoded checksum, d3 = calculated checksum. Identical?
								beq						.outputThis																																																									; yes!
								illegal																																																																; no
.outputThis
								ENDIF

	;#MARK: Create displayable Highscore table

.buildHighDisplay

								bsr						resetScores

								moveq					#9,d7
								lea						highData(pc),a3
								lea						titleHighHeroes(pc),a4
.drawHeroesLoop
								lea						(a3),a0																																																										; pointer to fetch number
								lea						9(a4),a1																																																									; pointer to draw number
								bsr.w					writeScoreToCharSprites
		; a0 now contains pointer to highData origin
		; a1 now contains pointer to number text+1
								lea						4(a1),a1
								move.b					#"$",(a1)+																																																									; red colors
								move.w					(a0)+,(a1)+
								move.b					(a0)+,(a1)+																																																									; copy name

								lea						8(a3),a3
								lea						(titleHighHeroesEnd-titleHighHeroes)/10(a4),a4
								dbra					d7,.drawHeroesLoop

								lea						scoreHighEncoded+1(pc),a0																																																					; copy encoded chars to displayable text
								lea						titleHighWeb+10(pc),a1

								move.l					#"    ",d0
								move.l					d0,d1
								movem.l					d0-d1,(a1)																																																									; clear display area

								clr.w					d7
.fetchEntry
								move.b					(a0)+,d0
								add						#1,d7
								cmpi.b					#"X",d0
								bge						.fetchEntry
								lsr						#1,d7
.fetchCode
								move.b					d0,(a1,d7)
								add						#1,d7
								move.b					(a0)+,d0
								cmpi.b					#"X",d0
								blt						.fetchCode																																																									; write centered code into display area

	;movem.l (a0),d0-d1


								bsr						titleClrTextArea


								WAITVBLANK
								lea						CUSTOM,a6																																																									; setup copperlist
								move.l					#coplist,COP1LC(a6)
								move.w					COPJMP1(a6),d0	: re-init copper
								move.w					#DMAF_SETCLR!DMAF_COPPER,DMACON(a6)																																																			; enable copper, bitplanes, sprites
;	WAITSECS 2	; just for drama ...
								move.w					#DMAF_SETCLR!DMAF_BPLEN|DMAF_SPRITE,DMACON(a6)																																																; enable copper, bitplanes, sprites
	;#MARK: Title Mainloop
								RSRESET
titStatEnterHigh				rs.b					1
titStatShowHigh					rs.b					1
titStatShowCreds				rs.b					1
titStatShowMsg					rs.b					1
titStatShowOptions				rs.b					1
titStatInitGame					rs.b					1
								bsr						titleClrTextArea
								lea						tempVar(pc),a0
								lea						fastRandomSeed(pc),a4
								lea						font(pc),a5																																																									; pointer font
								move.l					24(a0),a6																																																									; pointer to sprite->text coord conv table

								tst.b					titleHighFlag(pc)
								sne						d7
								add.b					#1,d7
								move.b					d7,titleViewIndx

								lea						titleCursor(pc),a3
								clr.w					(a3)																																																										; set cursor position to initial position

								move.w					#titleCounter,32(a0)																																																						; set transition counter
								lea						titleMessage(pc),a0
								st.b					(a0)																																																										; prepare reset of "titleMessage"
titleCounter					SET						$40*6+$40
titleFirstView					SET						titStatShowHigh																																																								; defines first and last screen within title basic loop
titleLastView					SET						titStatShowMsg
titleMainLoop
	;QUITNOW
								bsr						titleKickVessel
								bsr						titleJetEngines
								bsr						titleFlashFirebutton
								WAITVBLANK

								bsr						titleTestFirebutton

;	QUITNOW

								lea						tempVar(pc),a0
								sub						#1,32(a0)
								bmi						.switchView
								move					#$3f,d3
								move.w					32(a0),d0
								cmpi					#$3f,d0
								bgt						.tstFadeOut
								andi					#$3f,d0
								move					d0,d3
								bra						.noTransition
.tstFadeOut
								cmpi					#titleCounter-$3f,d0
								blt						.noTransition
								neg						d0
								andi					#$3f,d0
								move					d0,d3
.noTransition
								clr.w					d4
								clr.w					d7
								move.b					titleViewIndx(pc),d7
								move.w					titleJumpTable(pc,d7.w*2),d7
;	pea titleMainLoop(pc)	; return from sub to loop entry
								jsr						titleJumpTable(pc,d7.w)
								bra						titleMainLoop

.switchView
								move.w					#titleCounter,32(a0)
								lea						titleMessage(pc),a0
								st.b					(a0)																																																										; prepare reset of "titleMessage"
								lea						titleViewIndx(pc),a0
								add.b					#1,(a0)
								cmpi.b					#titleLastView,(a0)
								bls						titleMainLoop
								move.b					#titleFirstView,(a0)
								bra						titleMainLoop
		; titles view-specific code


	;#MARK: Title Init Game
titleInitGame
								lea						copperGame(pc),a3
								movem.l					(a3),a3/a4																																																									; start coplist, end of coplist
								sub.l					a3,a4
								move.w					a4,d7
								lsr						#2,d7
.findBPLCON3
								lea						4(a3),a3
								cmpi.w					#BPLCON3,(a3)
								beq						.modBPLCON3
.retMod
								dbra					d7,.findBPLCON3

								lea						transitionFlag(pc),a1
								move					#transitionOut,(a1)																																																							; init fadeout
.fadeOut
								WAITVBLANK
								bsr						titleKickVessel
								bsr						titleJetEngines
								lea						titleOptions(pc),a2
								move					#$3f,d3
								bsr						drawTextToSprites
								lea						transitionFlag(pc),a1
								tst.w					(a1)
								bne.b					.fadeOut

								lea						CUSTOM,a6
								move.w					#DMAF_COPPER!DMAF_BPLEN!DMAF_SPRITE,DMACON(a6)																																																; sprites and bpl dma off
								lea						4(sp),sp																																																									; pull return adress of stack
								rts																																																																	; return to main game controller
.modBPLCON3
								or.w					#BRDRBLNKF,2(a3)
								bra						.retMod

		;#MARK: Title Enter High

titleEnterHigh
								cmpi					#$40,32(a0)
								bhi						.fadeIn
								move.w					#$40,32(a0)																																																									; text only fade in, then keep solid state
.fadeIn
								bsr						titleEnterInitials
								lea						titleHighEnterA(pc),a2
								btst					#5,AudioRythmFlagAnim(pc)
								bne						.switch
								lea						titleHighEnterB(pc),a2
.switch
								bsr						drawTextToSprites
								lea						titleHighHeroes(pc),a2
								bsr						drawTextToSprites

								tst.b					optionStatus(pc)
								bmi						.highDiff
								lea						newHighText(pc),a2
								bra						drawTextToSprites
.highDiff
								lea						titleHighWeb(pc),a2																																																							; also displays "NEW"-msg
								bra						drawTextToSprites

	;#MARK: Title Show Highscore Table
titleShowHigh
								lea						titleHighTitle(pc),a2
								bsr						drawTextToSprites
								lea						titleHighHeroes(pc),a2
								bra						drawTextToSprites

	;#MARK: Title Show Message
titleShowMsg	; spawn single messages insync to music beat
								lea						titleMessage(pc),a0
								tst.b					(a0)
								bmi						.resetMsg																																																									; first call, text table needs some adjusting
								lea						1(a0),a2
								bsr						drawTextToSprites
								cmpi.b					#20,AudioRythmFlagAnim(pc)
								beq						.newText
								cmpi.b					#9,AudioRythmFlagAnim(pc)
								beq						.newText
								cmpi.b					#14,AudioRythmFlagAnim(pc)
								bne						titleReturn
.newText
								tst.b					(a2)
								bmi						titleReturn
								sf.b					-(a2)
								bra						titleReturn
.resetMsg
								sf.b					(a0)+
.resetMessage		; hide all messages
								tst.b					(a0)+
								bmi						.isNeg
								bne						.resetMessage
.isNeg
								st.b					-1(a0)																																																										; set end of line flag
								tst.b					(a0)																																																										; reached end of titleMessage?
								bmi						titleReturn
								bra						.resetMessage

		;#MARK: Title Show Credits
titleShowCreds
								lea						titleCredits(pc),a2
								bsr						drawTextToSprites
								rts

		;#MARK: Title Show Options
titleMaxOptions					SET						2																																																											; number of options
titleShowOptions
	;QUITNOW
								SAVEREGISTERS
								lea						tempVar(pc),a0
								cmpi					#$40,32(a0)
								bhi						.fadeInn
								move.w					#$40,32(a0)																																																									; text only fade in, then keep solid state
.fadeInn
								IFEQ					(RELEASECANDIDATE||DEMOBUILD)
	; choose stage, only in devbuild or prerelease build
								move.b					gameStatus(pc),d4
								add.b					#"1"-statusLevel0,d4
								move.b					d4,titleOptionsStagePointer+18

								moveq					#0,d4
								moveq					#5,d7																																																										; keys 1-6
.queryDirectionals
								tst.w					keyArray+Key1(pc,d7*4)
								bne						.action
								dbra					d7,.queryDirectionals
								bra						.noAction
.action
								add.w					#statusLevel0,d7
								move.b					d7,gameStatus
.noAction
								ENDIF

								move.l					plyBase+plyJoyCode(pc),d0
								lea						titleOptions(pc),a0
								lea						titleCursor(pc),a6
								lea						optionStatus(pc),a5

								move					d0,d1
								swap					d0
								cmp.w					d0,d1
								beq						titleNoAction

    ; process up and down
titleControlOptions

	; handle Konami cheat code query
								tst.b					d0
								beq						.retUnchanged																																																								; no button modified

								lea						.cheatCode(pc),a2																																																							; cheat combo check
								clr.w					d5
								move.b					(a2),d5
								move.b					1(a2,d5.w),d3
								add.b					#1,(a2)
								cmp.b					d3,d0																																																										;combo continued?
								bne.b					.resetCheatCombo
								cmpi.b					#7,d5
								blt.b					.retUnchanged
	; cheat enabled
								lea						plyBase(pc),a2
								st.b					plyCheatEnabled(a2)
								PLAYFX					fxSpawn
.resetCheatCombo
								clr.b					(a2)
.retUnchanged

								clr.w					d3
								move.b					(a6),d3
								move.b					d3,titleCursorOld-titleCursor(a6)
								move.w					titleOption(pc,d3*2),d3
								move.w					(a0,d3),d3
								btst					#JOY_DOWN,d0
								beq						.tstDown
								cmpi.b					#2,(a6)
								bge						.noOptionChange
								add.b					#1,(a6)
								bra						.optionProcessed
.cheatCode
								dc.b					0
								dc.b					08,08,04,04,01,02,02,01																																																						; Konami cheat sequence UUDDRLLR
								even

.tstDown
								btst					#JOY_UP,d0
								beq						.noOptionChange
								tst.b					(a6)
								beq						.noOptionChange
								sub.b					#1,(a6)
								bra						.optionProcessed
.noOptionChange
								move.b					#0,d3
.optionProcessed
								clr.w					d7
								move.b					(a6),d7

								moveq					#titleMaxOptions,d6
.resetOptions
								move.w					titleOption(pc,d6*2),d5
								andi.b					#$fe,2(a0,d5)
								dbra					d6,.resetOptions

								moveq					#5,d5
								add						d7,d5																																																										; prepare bitmarker for toggle code

								move.w					titleOption(pc,d7*2),d7
								or.b					#1,2(a0,d7)
								move.w					(a0,d7),d6
								move.w					d3,titleOptionsClearColW-titleOptions(a0)																																																	; clear recent white text
								move.w					d6,titleOptionsClearColR-titleOptions(a0)																																																	; clear old red text


	; toggle option
								btst					#JOY_LEFT,d0
								beq						.tstRight
								bclr					d5,(a5)
								bra						.toggleProcessed
.tstRight
								btst					#JOY_RIGHT,d0
								beq						.toggleProcessed
								bset					d5,(a5)


.toggleProcessed
								move					d5,d6
								btst					d5,(a5)
								sne						d5
								lsl.b					#7,d5																																																										; 0 or $80
								sub						#5,d6
								move.w					titleOptionToggle(pc,d6*2),d7
								andi.b					#$7f,1(a0,d7)
								or.b					d5,1(a0,d7)																																																									; copy bit into y-coord. If <$80 msg will not be displayed
								eor.b					#$80,d5
								andi.b					#$7f,8+1(a0,d7)
								or.b					d5,8+1(a0,d7)

								RESTOREREGISTERS
								lea						titleOptions(pc),a2
								bsr						drawTextToSprites
	;sub.b #-1,titleOptionsClearColW-titleOptions+1(a0)	; outcommented as purpose is unclear, and caused bad bug / crash
	;sub.b #-1,titleOptionsClearColW-titleOptions+1(a0)
								rts
titleNoAction
								RESTOREREGISTERS
								lea						titleOptions(pc),a2
								bra						drawTextToSprites
								IFNE					(RELEASECANDIDATE||DEMOBUILD)
titleOption
								dc.w					titleOptionsMsc-titleOptions, titleOptionsSFX-titleOptions, titleOptionsDiff-titleOptions
titleOptionToggle
								dc.w					titleToggleMsc-titleOptions, titleToggleSFX-titleOptions, titleToggleDiff-titleOptions
								ELSE
titleOption
								dc.w					titleOptionsMsc-titleOptions, titleOptionsSFX-titleOptions, titleOptionsDiff-titleOptions, titleOptionsStage-titleOptions
titleOptionToggle
								dc.w					titleToggleMsc-titleOptions, titleToggleSFX-titleOptions, titleToggleDiff-titleOptions
								ENDIF
	;#MARK: Several functions used within title display

titleFlashFirebutton
	; flash Firebutton-message insync to music
								clr.w					d7
								move.b					AudioRythmFlagAnim(pc),d7
								sne						d7
								andi					#2,d7																																																										; 0 or 2	; flash freq

								tst.b					titleViewIndx(pc)
								seq						d6
								andi.w					#1,d6																																																										; 1 = highscore entry view, 0 = basic view
								lsl						d6,d7																																																										; 0 or (2 / 4)	; indicator (0,2,4)
								move.w					.titleFBmessages(pc,d7),d7																																																					; pointer to message
								lea						(titleFirebutton,pc,d7),a2																																																					; fetch msg adress
								move					#$3f,d3
								bra						drawTextToSprites
.titleFBmessages
								dc.w					0,titleFirebuttonB-titleFirebutton,titleFirebuttonC-titleFirebutton

titleEnterInitials
								SAVEREGISTERS
								lea						tempVar+36(pc),a5
								move.l					(a5),d5
								lea						titleCursorFlash(pc),a3
								lea						titleHighInitials(pc),a4
								lea						titleCursor(pc),a6

								clr.w					d7
								move.b					(a6),d7																																																										; fetch cursor position

								lea						plyBase(pc),a0
								move.l					plyJoyCode(a0),d0
								move					d0,d1
								swap					d0
								cmp.w					d0,d1
								beq						.charProcessed
	; process char position index left and right

								btst					#JOY_LEFT,d0
								beq						.testRight
								tst.b					(a6)
								beq.b					.indexProcessed
								subq.b					#1,(a6)
								clr.b					(a3)
								bra						.indexProcessed
.testRight
								btst					#JOY_RIGHT,d0
								beq						.indexProcessed
								cmpi.b					#2,(a6)
								bge.b					.indexProcessed
								addq.b					#1,(a6)
								clr.b					(a3)
.indexProcessed


    ; process char up and down

								btst					#JOY_UP,d0
								beq						.testDown
								cmpi.b					#"Z",(a4,d7)
								bge.b					.charProcessed
								add.b					#1,(a4,d7)
								bra						.charProcessed
.testDown
								btst					#JOY_DOWN,d0
								beq						.charProcessed
								cmpi.b					#"A",(a4,d7)
								ble.b					.charProcessed
								sub.b					#1,(a4,d7)
.charProcessed
								move.w					(a4),d6
								move.b					2(a4),d4
								lea						highData(pc),a1
								move.w					d6,(a1,d5.w)																																																								; copy to database
								move.b					d4,2(a1,d5.w)
								swap					d5
								lea						titleHighHeroes(pc),a1
								lea						(a1,d5.w),a1
								move.b					#"%",-1(a1)																																																									; white color
								move.w					d6,(a1)																																																										; copy to display
								move.b					d4,2(a1)

								add.b					#1,(a3)
								btst.b					#4,(a3)
								bne						.keepChar
								move.b					#" ",(a1,d7)
.keepChar
.noHigh
								RESTOREREGISTERS
								rts

titleJetEngines
								move.l					(tempVar+16,pc),a0																																																							; fetch pointer to coplist colors regs
								tst.l					a0
								beq						.quit
								move.w					frameCount+4(pc),d7
								btst					#2,d7
								seq						d7
								andi					#6<<1,d7
								move.l					(.colVar,pc,d7),d1																																																							; read color values
								move.w					d1,6(a0)
								swap					d1
								move.w					d1,2(a0)
								move.l					(4+.colVar,pc,d7),d1																																																						; read color values
								move.w					d1,14(a0)
								swap					d1
								move.w					d1,10(a0)
								move.l					(8+.colVar,pc,d7),d1																																																						; read color values
								move.w					d1,22(a0)
								swap					d1
								move.w					d1,18(a0)
.quit
								rts
.colVar
	;dc.w $fd6,$ff4,$ff7,$ff9,$ffa,$ffd	; original colors
	;dc.w $fc4,$ff0,$ff4,$ff8,$ff8,$ffa	; variations
								dc.w					$cb4,$cc2,$cc5,$cc7,$cc8,$ccb																																																				; original colors
								dc.w					$cb2,$cc0,$cc2,$cc6,$cc6,$cc8																																																				; variations

titleKickVessel
								move.l					tempVar+16(pc),a0
								tst.l					a0
								beq						.quit
								lea						-$2a(a0),a0

								move.b					AudioRythmFlagAnim(pc),d0
								beq						.ss
								sub.b					#1,AudioRythmFlagAnim
.ss
								btst					#1,d0
								seq						d7
								andi					#$37,d7
								eor						d7,d0																																																										; count up to $1f, count down to $0

								clr.l					d4
								move					d0,d4
	;divs #16,d0
								lsr						#5,d0
								add						#$1,d0
								divs					#30,d4																																																										; prepare max. dynamic x-range
								add						#1,d4
	;sub d4,d0
								andi.w					#%01111,d4
								move.w					(a4),d1																																																										; get rnd number
								andi					#$07,d1																																																										; prepare max. dynamic y-range
								lsr						d0,d1																																																										; modify y-range insync to audio beat

								lsl						#5,d1																																																										; calc mod offset
								sub.w					#8,d1																																																										; adjust
								move					d1,(a0)																																																										; write bplmod
								move					d1,4(a0)


								move.l					tempVar+20(pc),a0																																																							; fetch pointer to coplist
								tst.l					a0
								beq						.quit
								lea						20+6(a0),a0																																																									; adjust
								moveq					#$4,d5
								moveq					#$1f,d6
								move					#displayWindowStop+$100-$c8,d7																																																				; no of scanlines
								lea						fastRandomSeed(pc),a4
.1
								movem.l					(a4),d1-d2																																																									; ABCD
								swap					d2																																																											; DC
								add.l					d2,(a4)																																																										; AB + DC
								add.l					d1,4(a4)																																																									; CD + AB
								and						d6,d1
								lsr						d4,d1
								move.w					224+scrollXbitsTable(pc,d1*2),d1
								move					d1,d2
								lsl						d5,d2
								or						d2,d1
								move.w					d1,(a0)
								lea						28(a0),a0
								dbra					d7,.1
.quit
								rts

titleTestFirebutton

								move.w					plyBase+plyJoyCode(pc),d7
								btst					#STICK_BUTTON_ONE,d7																																																						; check firebutton 1
								bne.b					.fireButton

								IFEQ					(RELEASECANDIDATE||DEMOBUILD)
								tst.w					keyArray+LShift(pc)
								bne.w					.quit
								tst.w					keyArray+RShift(pc)
								bne.w					.quit
								ENDC
								rts
								IFEQ					(RELEASECANDIDATE||DEMOBUILD)
.quit
								QUITNOW
								ENDIF

.fireButton

								lea						titleViewIndx(pc),a0
								tst.b					(a0)
								bne						titleInitOptions																																																							; status = highscore entry
								SAVEREGISTERS
								jsr					saveHighscores
								RESTOREREGISTERS
								add.b					#1,(a0)																																																										; yes

								lea						titleCursor(pc),a3
								move.b					#titleMaxOptions,(a3)																																																						; set cursor position to "Start Mission" in option screen
								bset.b					#4,1(a3)
								bsr						titleEnterInitials																																																							; make sure new initials get fully displayed

								lea						tempVar(pc),a0
								move.w					#$40*6,32(a0)

								lea						titleHighHeroes(pc),a2																																																						; set draw color of initials to all white
								moveq					#9,d7
.setWhite
								move.b					#"%",21(a2)																																																									; initials
								lea						(titleHighHeroesEnd-titleHighHeroes)/10(a2),a2
								dbra					d7,.setWhite

								clr.w					d4
								moveq					#$3f,d3
								lea						clearHighFrags(pc),a2
								lea						newHighText(pc),a0
								move.w					(a0),(a2)
								bsr						drawTextToSprites																																																							; clear undesired text fragments

.waitRelease

								WAITVBLANK
								bsr						titleKickVessel
								bsr						titleJetEngines
								clr.w					d4
								moveq					#$3f,d3
								lea						titleHighHeroes(pc),a2
								bsr						drawTextToSprites
								lea						titleHighTitle(pc),a2
								bsr						drawTextToSprites

								move.w					plyBase+plyJoyCode(pc),d7
								btst					#STICK_BUTTON_ONE,d7																																																						; check firebutton 1
								bne.b					.waitRelease
titleReturn
								rts
titleInitOptions
								lea						tempVar+32(pc),a2
								move					#$30,(a2)																																																									; init fade out

								cmpi.b					#titStatShowOptions,(a0)
								bne						.initOptionLoop
								move.b					#titStatInitGame,(a0)																																																						; switch to init game code
								rts

	; fadeout current title text
.initOptionLoop
								bsr						titleKickVessel
								bsr						titleJetEngines
								lea						titleFirebuttonD(pc),a2
								bsr						drawTextToSprites																																																							; clear firebutton message during fadeout
								WAITVBLANK
								lea						tempVar+32(pc),a0
								sub						#1,(a0)																																																										; text faded out?
								bmi						.waitReleaseOptions																																																							; yes

								move.w					(a0),d3
								clr.w					d7
								move.b					titleViewIndx(pc),d7
								move.w					titleJumpTable(pc,d7.w*2),d7
	;pea .initOptionLoop(pc)
								jsr						titleJumpTable(pc,d7.w)																																																						; keep displaying current view
								bra						.initOptionLoop

.waitReleaseOptions
	; fadeout current title text

								btst					#STICK_BUTTON_ONE,plyBase+plyJoyCode(pc)																																																	; check firebutton 1
								bne.b					.waitReleaseOptions

								move					#titleCounter,(a0)																																																							; reset fade
								lea						titleCursor(pc),a2
								move.b					#2,(a2)																																																										; set cursor to last position
								move.b					#titStatShowOptions,titleViewIndx-titleCursor(a2)
								SAVEREGISTERS
								move.l					plyBase+plyJoyCode(pc),d0
								lea						titleOptions(pc),a0
								move.l					a2,a6
								lea						optionStatus(pc),a5
								bra						titleControlOptions																																																							; run option display once to get text highlighted
titleClrTextArea
								SAVEREGISTERS
								move.l					tempVar+24(pc),a6																																																							; pointer to sprite->text coord conv table
								move.l					(a6),a6
								move.w					#2203,d7
.loopClr
								clr.l					(a6)+
								dbra					d7,.loopClr
								RESTOREREGISTERS
								rts
	;#MARK: Filenames and tables
titleJumpTable
								dc.w					titleEnterHigh-titleJumpTable
								dc.w					titleShowHigh-titleJumpTable
								dc.w					titleShowCreds-titleJumpTable
								dc.w					titleShowMsg-titleJumpTable
								dc.w					titleShowOptions-titleJumpTable
								dc.w					titleInitGame-titleJumpTable

titlePicFilename
								dc.b					"vessel.raw",0
								even
titleCopFilename
								dc.b					"title.cop",0
								even

drawTextToSprites ; text to sprite
	;	a2.l	->	pointer.l to text
	;	d3.l 	->	noisefilter index
	;	d4.w 	->	color indicator (0 or 8)
	;	attn: additional regs needed for  writeCharToSprites!
	;	-> a2.l		pointer to end of text
	;	destroys d0,d1,d2,d4,d5,d6,d7,a1
	;	y-coord = neg -> do not draw line
								movem.l					d3/a0,-(sp)
								lsr						#2,d3
								move.l					noiseFilter(pc,d3*2),d3
								clr.w					d7
.fetchCoords
								clr.w					d4																																																											; reset color indicator
								movem.w					(a2)+,d5
								clr.w					d6
								move.b					d5,d6
								bmi						.skipRow																																																									; y=-1 -> do not display text for the moment
								lsr						#8,d5
.fetchChar
								move.w					d5,d0
								move.w					d6,d1
								move.b					(a2)+,d7
								beq						.fetchCoords
								bmi						.lastChar
								cmpi.b					#"@",d7
								bgt						.gotLetter
								sub						#" ",d7
								move.b					charConvTable(pc,d7),d7
								bmi						.switchColor
								bsr						writeCharToSprites
								add						#1,d5
								bra						.fetchChar
.gotLetter
								sub						#49,d7
								bsr						writeCharToSprites
								add						#1,d5
								bra						.fetchChar
.lastChar
								movem.l					(sp)+,d3/a0
								rts
.skipRow
								tst.b					(a2)+
								bmi						.lastChar
								bne						.skipRow
								bra						.fetchCoords
.switchColor
								btst					#0,d7
								bne						.fetchChar
								eor						#8,d4
								bra						.fetchChar


writeCharToSprites
	;	a4.l	->	pointer.l to fastRandomSeed
	;	a5.l	->	pointer.l to font
	; 	a6.l	->	pointer.l to coord conv table
	;	d0.w 	->	x-coord
	;	d1.w 	->	y-coord
	;	d3.l 	->	noisefilter
	;	d4.w	->	color adder (0 or 8 for 64 px sprites)
	; 	d7.w 	->	char.w
	; 	-> char to coord within sprite. 1 bitplane
	;	destroys d0,d1,d2,d3,a0,a1
								lsl						#2,d0
								move					d1,d2
								lsl						#6,d1
								lsl						#5,d2																																																										; muls y-coord by 96
								add						d1,d0
								add						d2,d0																																																										; add to x-coord
								move.l					(a6,d0),a1																																																									; fetch sprite bitmap adress
								lea						(a1,d4),a1
								lea						(a5,d7*8),a0																																																								; fetch char address
								move.l					(a0)+,d0

								move.l					(a4),d1																																																										; AB
								move.l					4(a4),d2																																																									; CD
								swap					d2																																																											; DC
								add.l					d2,(a4)																																																										; AB + DC
								add.l					d1,4(a4)																																																									; CD + AB
								rol.l					d1,d3
								and.l					d3,d0
.spriteOffset					SET						16
								move.b					d0,.spriteOffset*3(a1)
								lsr						#8,d0
								move.b					d0,.spriteOffset*2(a1)
								swap					d0
								move.b					d0,.spriteOffset*1(a1)
								lsr						#8,d0
								move.b					d0,(a1)
								move.b					(a0),d0
								and.b					d3,d0
								move.b					d0,.spriteOffset*4(a1)
								rts


writeScoreToCharSprites
	;	a0.l	->	pointer.l to bcd number.l
	; 	a1.l	->	pointer.l to target text mem (8 bytes)
	;	destroys a1,d0,d1,d2
								moveq					#3,d2
.loop
								move.b					(a0)+,d0
								move					d0,d1
								andi					#$0f,d1
								andi					#$f0,d0
								asr						#4,d0
								add						#"0",d0
								move.b					d0,(a1)+
								add						#"0",d1
								move.b					d1,(a1)+
								dbra					d2,.loop
								rts

installSpritePointers
	;	a0.l	->	pointer.l to start of 6 x spr0pth+spr0ptl
	; 	a1.l	->	pointer.l to sprite bitmap memory
	;	destroys d0,a3

								lea						charToSpriteMaxRows*charHeight*spriteLineOffset(a1),a3
								lea						charToSpriteMaxRows*charHeight*spriteLineOffset*2(a1),a4
installSpriteJumpin

								move.l					a1,d0
								move.w					d0,6(a0)
								move.w					d0,6+24(a0)
								swap					d0
								move.w					d0,2(a0)
								move.w					d0,2+24(a0)
								move.l					a3,d0
								move.w					d0,8+6(a0)
								move.w					d0,8+6+24(a0)
								swap					d0
								move.w					d0,8+2(a0)
								move.w					d0,8+2+24(a0)
								move.l					a4,d0
								move.w					d0,16+6(a0)
								move.w					d0,16+6+24(a0)
								swap					d0
								move.w					d0,16+2(a0)
								move.w					d0,16+2+24(a0)
								rts

createTableTextSpritesCoord
	;	a1.l	->	pointer.l to sprite bitmap data space
	;	a6.l	-> 	pointer.l to coord table storage container
	;	-> char to sprite coord adress table @[artworkBitplane]
	;	destroys tempVar+24, ??

								move.l					a6,tempVar+24
								clr.w					d6
.createConvTable
								move					d6,d0
								muls					#spriteLineOffset*charHeight,d0																																																				;

								lea						(a1,d0),a3
								lea						charToSpriteMaxRows*charHeight*spriteLineOffset(a1,d0),a4
								lea						charToSpriteMaxRows*charHeight*spriteLineOffset*2(a1,d0),a5
								moveq					#7,d7
.wrtLine
								move.l					a4,8*4(a6)																																																									; sprite 1
								lea						1(a4),a4
								move.l					a5,16*4(a6)																																																									; sprite 2
								lea						1(a5),a5
								move.l					a3,(a6)+																																																									; sprite 0
								lea						1(a3),a3
								dbra					d7,.wrtLine
								lea						16*4(a6),a6
								add						#1,d6
								cmp						#charToSpriteMaxRows,d6																																																						; 20 lines?
								bcs						.createConvTable
								rts

noiseFilter
								dc.l					0
								dc.l					$00000401
								dc.l					$10402081
								dc.l					$5826c351
								dc.l					$95ac3ac5
								dc.l					$a7bca7bc
								dc.l					$7ef7dfcf
								dc.l					$f7fff3ff
								dc.l					-1
titleOptions
								dc.b					3,1,"CHOOSE YOUR OPTION",0
								IFEQ					(RELEASECANDIDATE||DEMOBUILD)
titleOptionsStage
								dc.b					5,12,"$TESTBUILD ONLY",0
								dc.b					4,13,"$TAP KEYS  1 TO 6",0
titleOptionsStagePointer
								dc.b					4,14,"$TO INIT  STAGE A",0
								ENDIF
titleOptionsDiff
								dc.b					3,10,"$DIFFICULTY",0
titleOptionsSFX
								dc.b					3,8,"$SOUND-FX",0
titleOptionsMsc
								dc.b					3,6,"$MUSIC",0
titleToggleDiff
								dc.b					17,10,"$EASY",0
								dc.b					17,$8a,"$HARD",0
titleToggleSFX
								dc.b					17,8," $ ON",0
								dc.b					17,$88," $OFF",0
titleToggleMsc
								dc.b					17,6," $ ON",0
								dc.b					17,$86," $OFF",0
titleOptionsClearColW
								dc.b					3,0
								blk.b					10," "
								dc.b					0
titleOptionsClearColR
								dc.b					3,0,"$"
								blk.b					10," "
								dc.b					-1
titleMessage
								dc.b					0																																																											; 0.b status (-1 = reset)
								dc.b					2,4,"ONLY ON $AMIGA$",0
								dc.b					7,12,"$ENJOY THE$ FLOW",0
								dc.b					5,16,"FUELED BY $AGA$",0
								dc.b					3,6,"$HIGHSCORE$ SAVE",0
								dc.b					1,14,"FULL $FRAMERATE$",0
								dc.b					5,8,"$DANCE$ THE BULLETS",0
								dc.b					2,10,"FIVE $STAGES$",0
								dc.b					7,2,"$BOSS$ GALORE",0
								dc.b					-1

titleCredits
								dc.b					1,1,"$PROJECT LEAD$",0
								dc.b					1,2,"RICHARD",0
								dc.b					1,3,"LOEWENSTEIN",0
								dc.b					14,6,"$PIXEL ART$",0
								dc.b					18,7,"KEVIN",0
								dc.b					15,8,"SAUNDERS",0
								dc.b					4,13,"$SONIC ART$",0
								dc.b					4,14,"ALTRAZ",0
								dc.b					4,15,"VIRGILL",-1
titleFirebutton
								dc.b					7,20," TAP FIRE  ",-1
titleFirebuttonB
								dc.b					7,20," TO START  ",-1
titleFirebuttonC
								dc.b					7,20,"TO CONTINUE",-1
titleFirebuttonD
								dc.b					7,20,"           ",-1
titleHighTitle
								dc.b					4,0,"HIGHSCORE HEROES",-1
titleHighEnterA
								dc.b					5,0,"YOU ARE A HERO!",-1
titleHighEnterB
								dc.b					5,0,"ENTER YOUR NAME",-1

titleHighHeroes
.column							SET						0																																																											; spalte
.row							SET						3																																																											; zeile
.rowC							SET						.row
.entry							SET						1
.entryOffset					SET						1
.namOffset						SET						20
.scoreOffset					SET						5
								REPT					9
								dc.b					.column+.entryOffset,.row,.entry+"0",". ",0
								dc.b					.column+.scoreOffset,.row, "$00000000$",0
								dc.b					.column+.namOffset,.row,"%TES",0
.row							SET						.row+1
.entry							SET						.entry+1
								ENDR
								dc.b					.column+.entryOffset,.row,"10.",0,.column+.scoreOffset,.row, "$00000000$",0,.column+.namOffset,.row,"$TES",-1
titleHighHeroesEnd

titleHighWeb
								dc.b					3,15,"$ENTER $XXXXXXXX$ AT",0
								dc.b					1,16,"$RP3.SPIELESCHREIBER.DE",0
newHighText
								dc.b					0,0,"YES!",-1
clearHighFrags	; clear NEW-Text after high entry
								dc.b					0,0,"    ",0																																																								; clr NEW-msg
								dc.b					7,20
								blk.b					11," "																																																										; clr FB-msg
								dc.b					0,3,15,"$"
								blk.b					5," "																																																										; clr ENTER-msg
								dc.b					0,9,15
								blk.b					8," "																																																										; clr XXXXXXXX
								dc.b					0,18,15,"$"
								blk.b					2," "																																																										; clr AT-msg
								dc.b					0,1,16,"$"
								blk.b					22," "																																																										; clr RP3...-msg
								dc.b					0
.rowC							SET						3
.column							SET						0
.namOffset						SET						20
								REPT					9
								dc.b					.column+.namOffset,.rowC,"$   ",0
.rowC							SET						.rowC+1
								ENDR
								dc.b					.column+.namOffset,.rowC,"$   ",-1
								even
highData		; actual highscore data saved to NVRAM
								IFEQ					DEMOBUILD
								dc.l					$3000000
								dc.b					"RIC",0
								dc.l					$2750000
								dc.b					"KEV",0
								dc.l					$2500000
								dc.b					"ALT",0
								dc.l					$2250000
								dc.b					"CLA",0
								dc.l					$2000000
								dc.b					"DOR",0
								dc.l					$1250000
								dc.b					"ING",0
								dc.l					$1000000
								dc.b					"FRA",0
								dc.l					$750000
								dc.b					"AND",0
								dc.l					$500000
								dc.b					"GRA",0
highDataLast
								dc.l					$250000
								dc.b					"BOR",0
								ELSE
								dc.l					$3000000
								dc.b					"RIC",0
								dc.l					$2750000
								dc.b					"KEV",0
								dc.l					$2500000
								dc.b					"ALT",0
								dc.l					$2250000
								dc.b					"CLA",0
								dc.l					$2000000
								dc.b					"DOR",0
								dc.l					$100000
								dc.b					"ING",0
								dc.l					$750000
								dc.b					"FRA",0
								dc.l					$500000
								dc.b					"AND",0
								dc.l					$250000
								dc.b					"GRA",0
highDataLast
								dc.l					$100000
								dc.b					"BOR",0
								ENDIF
highDataEnd
								blk.b					10,0																																																										; fill up to meet NVRAM saving format
								even

; #MARK: TITLE MANAGER ENDS



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

; #MARK: - INIT GAME GLOBAL BEGINS
prepareInitGame
								WAITVBLANK

;	move.w #$41fa,chkBckCol;	enable col detection

								lea						titleSprites,a0																																																								; hide sprites
								moveq					#6,d0
								move					#$3000,d1
								move					#$f000,d2
.hideSprites
								move					d1,(a0)
								move					d2,8(a0)
								add.l					#titleSpritesOffset,a0
								dbra					d0,.hideSprites
								rts

initGameGlobal
	;bra.b .waitWelcome

   ; move.w #1,copBPLCON0+2    ; disable display
    ;move #%111111,copBPLCON2+2   ;video priority (sprites behind pf1)


	;move #0,copBPL2ModOffset+2		; adjust copperlist
    ;move #fxPlaneWidth-mainPlaneWidth,copBPL2MOD+2        ;bitplane modulos
	;move #mainPlaneWidth*(mainPlaneDepth-1),copBPL1MOD+2  ; basic modulus

								move.l					copPriority(pc),a0
								tst.l					a0
								beq						.skip
								move					#%011011,(a0)																																																								; sprites to front
.skip

								IF						ALERTHANDLING=1																																																								; reset alertvars
								clr.w					alertNumber
								clr.l					alertLine
								ENDIF


								jsr					prepareDisplay



								lea						CUSTOM,a6
								move					#$0,CLXCON2(a6)																																																								; control sprite<->bck collissions
.clxcon							SET						$1<<14+$1<<13+$1<<12+$1<<6+1<<0
								move					#.clxcon,CLXCON(a6)																																																							; control sprite<->bck collissions. Enable sprite 1 for player, 3 and 5 for ORing with sprite 2 and 4

	; #MARK: reset and rebuild preconfigured sprite dma list

								move.l					#(spritePosMemSize/4)-1,d0																																																					;    reset sorting memory
								move.l					spritePosMem(pc),a0
.del2
								clr.l					(a0)+
								dbra					d0,.del2

    move.l spritePlayerDMA(pc),a6
    move.l #spritePlayerDMASize-4,d7
    jsr CLEARMEMORY
	move.l spriteDMAMem+8(pc),a6
    move.l #spriteDMAMemSize,d7
    jsr CLEARMEMORY

	;QUITNOW

;,fxPlaneWidth*fxPlaneHeightBig*fxPlaneDepth+16,d3	; clear all bitplanes - not needed anymore, as tileRenderer is doing the clearance



								lea						spriteBullet4pixels,a0
								moveq					#3,d4																																																										; precalc 4 lists
.writeAllDMALists
								move.l					spriteDMAMem(pc),d0
								move.l					spriteDMAMem+4(pc),d2
								move.l					#spriteDMAListOffset,d7																																																						; offset between each single sprite dma list
								lsl						#2,d7
								mulu					d4,d7
								add.l					d7,d0
								add.l					d7,d2
								moveq					#spriteDMAHeight-1,d1
.writeSingleDMAList
								move.l					d0,a1
								move.l					d2,a2
								move.w					#(bulletsMax-1)/4,d6
								move.w					#$1c18,(a1)+																																																								; first sprite, not used ingame, used as restore source
								clr.l					(a1)+
								clr.w					(a1)+
								move.w					#$2000,(a1)+
								clr.l					(a1)+
								clr.w					(a1)+
								move.w					#$1c58,(a2)+																																																								; first sprite, not used ingame, used as restore source
								clr.l					(a2)+
								clr.w					(a2)+
								move.w					#$2000,(a2)+
								clr.l					(a2)+
								clr.w					(a2)+
								bra.b					.firstSprite
.writeSingleSprite
								IF						1=1
								clr.l					(a1)																																																										; reset position data all other dma sprites
								clr.l					4(a1)
								clr.l					8(a1)
								clr.l					12(a1)
								clr.l					(a2)
								clr.l					4(a2)
								clr.l					8(a2)
								clr.l					12(a2)
								ENDIF
.firstSprite
								IF						0=1																																																											; 0=0 use predef´d numbers instead of bitplane data
								lea						.spriteTempNumbers,a3
								move					d4,d7
			;add.w d6,d7
			;andi #3,d7
								lsl						#4,d7
								lea						(a3,d7),a3
								bra						.skipTemp
.spriteTempNumbers
								dc.b					%00001100,0
								dc.w					0
								dc.b					%00010100,0
								dc.w					0
								dc.b					%00111100,0
								dc.w					0
								dc.b					%00000100,0
								dc.w					0

								dc.b					%00111000,0
								dc.w					0
								dc.b					%00000100,0
								dc.w					0
								dc.b					%00000100,0
								dc.w					0
								dc.b					%00111000,0
								dc.w					0

								dc.b					%00011000,0
								dc.w					0
								dc.b					%00000100,0
								dc.w					0
								dc.b					%00011000,0
								dc.w					0
								dc.b					%00111100,0
								dc.w					0

								dc.b					%00000100,0
								dc.w					0
								dc.b					%00001100,0
								dc.w					0
								dc.b					%00000100,0
								dc.w					0
								dc.b					%00000100,0
								dc.w					0
.skipTemp

								ELSE
								move.l					a0,a3
								ENDIF



								moveq					#spriteDMAHeight-1,d7
.writePixelRows
								movem.w					(a3),a4-a5																																																									; read 1 line
;				move.w #$ffff,a4
;				move.w a4,a5
								move.w					a4,(a1)
								clr.w					2(a1)
								clr.l					4(a1)
								move.w					a5,8(a1)																																																									; write 1 line
								clr.w					10(a1)
								clr.l					12(a1)

								movem.w					64(a3),a4-a5																																																								; read 1 line
;				move.w #$ffff,a4
								move.w					a4,(a2)
								clr.w					2(a2)
								clr.l					4(a2)
								move.w					a5,8(a2)																																																									; write 1 line
								clr.w					10(a2)
								clr.l					12(a2)
								addq					#4,a3
								adda					#spriteLineOffset,a1
								adda					#spriteLineOffset,a2
								dbra					d7,.writePixelRows
								lea						spriteLineOffset(a1),a1
								lea						spriteLineOffset(a2),a2
								dbra					d6,.writeSingleSprite
								clr.l					d6
								move.w					#spriteDMAListOffset,d6
								add.l					d6,d0
								add.l					d6,d2
								dbra					d1,.writeSingleDMAList
								lea						16(a0),a0
								dbra					d4,.writeAllDMALists


								lea						copSpriteDMA,a0																																																								; write sprite DMA pointers to 8 sub copper lists. Have 4 lists for four sprite anim frames.

								move.l					spriteDMAMem(pc),d4
								move.l					#spriteDMAListOffset*4,d3
								move.l					#spriteDMAListOffset,d2
								moveq					#8,d1
								moveq					#3,d7
.wrtCopSpriteDMA			; write four lists
								move.l					a0,a1
								move.l					d4,d0
								moveq					#3,d6
.wrtSingleEntry				; write four entrys
								move					d0,6(a1)
								swap					d0
								move					d0,2(a1)
								swap					d0
								add.l					d1,a1
								add.l					d2,d0
								dbra					d6,.wrtSingleEntry
								add.l					d3,d4
								lea						copSpriteDMAOffset(a0),a0
								dbra					d7,.wrtCopSpriteDMA


								move.l					spriteDMAMem+4,d4																																																							; prepare second set of copper sub lists, used for buffering / fast switching
								moveq					#3,d7
.wrtCopSpriteDMAB
								move.l					a0,a1
								move.l					d4,d0
								moveq					#3,d6
.wrtSingleEntryB
								move					d0,6(a1)
								swap					d0
								move					d0,2(a1)
								swap					d0
								add.l					d1,a1
								add.l					d2,d0
								dbra					d6,.wrtSingleEntryB
								add.l					d3,d4
								lea						copSpriteDMAOffset(a0),a0
								dbra					d7,.wrtCopSpriteDMAB

								lea						spriteCount(pc),a0
								clr.l					(a0)																																																										; reset sprite dma lists
								bsr						spriteManager
								bsr						spriteManager

								move.w					scr2StartPos,d0																																																								;write startposition all relevant pointers, reset player-flag
								add.w					#DisplayWindowHeight,d0
								swap					d0
								clr.w					d0
								lea						viewPosition,a3
								move.l					d0,viewPositionPointer(a3)
								move.l					viewPositionAdd(a3),d6
								moveq					#-1,d7
								clr.w					d7
								move.l					d7,viewPositionAdd(a3)


								move					#DisplayWindowHeight-1,d7
.drawLoop
								movem.l					d6/d7,-(sp)
								lea						viewPosition,a3
								move.l					viewPositionAdd(a3),d7
								add.l					d7,viewPositionPointer(a3)
								bsr						tileRenderer
								movem.l					(sp)+,d7/d6
								dbra					d7,.drawLoop

								lea						viewPosition,a3
								move.l					d6,viewPositionAdd(a3)
								move.w					scr2StartPos,d0																																																								;write startposition all relevant pointers, reset player-flag
								swap					d0
								clr.w					d0
								move.l					d0,viewPositionPointer(a3)

								lea						plyBase(pc),a6																																																								; setup player position, reset flags
								move					#254,d1
								swap					d1
								add.l					d1,d0
								move.l					d0,plyPosY(a6)
    ;clr.l plyPosAcclX(a6)
								move.w					#-640,d0
								move.w					d0,plyPosAcclY(a6)
								move.w					#122,d0																																																										; centre x-position
								swap					d0
								move.l					d0,plyPosX(a6)
								clr.w					plyPosAcclX(a6)																																																								; initial y-accl defined in playerController

								moveq					#90,d0
								move.w					d0,plyInitiated(a6)																																																							; duration of init auto anim
								clr						plyCollided(a6)
								sf.b					plyExitReached(a6)
								st.b					plyFire1Auto(a6)
								st.b					plyFire1AutoB(a6)
    ;subq.b #1,plyFire1Auto(a6)
								sf.b					plyFire1Flag(a6)
								sf.b					plyFire1Hold(a6)
								sf.b					plyWeapUpgrade(a6)
								sf.b					plyWeapSwitchFlag(a6)
								sf.b					plyDistortionMode(a6)
								sf.b					plyShotCnt(a6)
								clr.l					plyShotsFired(a6)																																																							;	 plyShotsFired+plyHitObjects
								clr.w					plyWaveBonus(a6)

								lea						plySprSaveCop(pc),a0
								clr.l					(a0)+
								clr.l					(a0)+
								clr.l					(a0)+
								clr.l					(a0)+


								moveq					#plyAcclXMin,d0
								move.w					d0,plyAcclXCap(a6)
								moveq					#plyAcclYMin+10,d0																																																							; will be caped after auto init anim
								move.w					d0,plyAcclYCap(a6)

								lea						objectList+4(pc),a0
								move.l					(a0)+,(a0)																																																									; reset dynamic objectList Pointer


								move.l					launchTable(pc),a0
								sub.l					launchTableEntryLength(pc),a0
								move.l					launchTableBuffer+4(pc),a1
								move.l					a1,launchTableBuffer


								move					viewPosition+viewPositionPointer(pc),d0
.animtabsrch
								add.l					launchTableEntryLength(pc),a0
								tst						(a0)
								bmi						.foundLastEntry
								move					launchTableY(a0),d1
								cmp						d1,d0
								bcs.b					.animtabsrch
								move.l					a0,a3
.animTabWrite
								move.l					launchTableEntryLength(pc),d7
								subq					#1,d7
.animtabwriteLoop
								move.b					(a3)+,(a1)+
								dbra					d7,.animtabwriteLoop
								bra						.animtabsrch
.foundLastEntry
								moveq					#-1,d7
								move.l					d7,(a1)

;	rts

; #MARK: Reset basic memory structures
    move.l objectList(pc),a6
    move.l #objectListSize,d7
    jsr CLEARMEMORY
								lea						objCopyTable(pc),a6
    move.l #objCopyEnd-objCopyTable,d7
    jsr CLEARMEMORY
								movem.l					bobRestoreList(pc),a0/a1																																																					; clear list of bobs to clear from background
								clr.l					(a0)
								clr.l					(a1)
								movem.l					bobDrawList(pc),a0/a1																																																						; clear list of bobs to draw
								clr.l					(a0)
								clr.l					(a1)

								lea						vars(pc),a5
								clr						objCount-vars(a5)
								clr.l					spriteCount-vars(a5)
								clr						bulletLaunchSkipper-vars(a5)

								lea						bossVars-vars(a5),a1
								moveq					#(bossVarsSize/2)-1,d0
.resetBossVars					clr.w					(a1)+
								dbra					d0,.resetBossVars

								sf.b					forceExit-vars(a5)
								clr.l					frameCount-vars(a5)
								clr.l					frameCompare-vars(a5)																																																						; set target framerate
	;move.l #$00010001,frameCompare
								move.w					#1,blitterManagerFinished-vars(a5)																																																			; reset "" & blitterManagerLaunch

								tst						$dff00e																																																										;   reset clxcon & collisionmarker

								lea						polyVars(pc),a1
								clr.l					xA1(a1)																																																										; reset fillManagers xA1
								clr.l					polyBlitAddr(a1)
								clr.w					polyBlitAddr+4(a1)

								move.l					launchTableBuffer+4(pc),a1
								adda.l					launchTableSize(pc),a1
								sub.l					launchTableEntryLength(pc),a1
								moveq					#-1,d0
								move.l					d0,(a1)

								lea						particleBase(pc),a0
								moveq					#4,d0
.resetPartBase
								clr.l					(a0)+																																																										; reset particle vars
								dbra					d0,.resetPartBase

								lea						particleTable,a6
								moveq					#partEntrySize,d6
								moveq					#particlesMaxNo,d7
								bra						.loop
.resetParticles
								clr.w					(a6)
								add.l					d6,a6
.loop
								dbra					d7,.resetParticles

; #MARK: Reset score variables

								lea						score(pc),a0
								IFEQ					INITWITH																																																									; releaseversion:score reset in title code
								bsr						resetScores
								ENDIF
								move.l					#-1,scoreOld(a0)
								clr.l					scoreAdd(a0)
								clr.l					scoreMultiplier-score(a0)
								clr.b					scoreHighSuccessFlag-score(a0)


; #MARK: SCORE / HIGHSCORE SETTINGS -

								lea						scoreHigh(pc),a1
								move.l					(highDataLast.w,pc),d0
								addq.l					#1,d0
    ;move.l #$100003,d0; temp highscore setting
								move.l					d0,(a1)																																																										; copy last hi table entry to highscore save var

	
								lea						copSprite67,a0																																																								; write dma pointer sprite 0+1 -> coplist
								move.l					#infoPanelScore,d0
								subq					#8,d0
								subq					#8,d0
								move.l					d0,a1
								move.w					#spriteScoreCtlrWordLo,d1
								move.w					#spriteScoreCtlrWordHi,d2
								move.w					d1,(a1)
								move.w					d2,8(a1)
								move					d0,6(a0)
								swap					d0
								move					d0,2(a0)
								move.l					#infoPanelStatus,d0
								subq					#8,d0
								subq					#8,d0
								move.l					d0,a1
								move.b					#spriteStatusXPosition,d1

								move.w					d1,(a1)
								move.w					d2,8(a1)
								move					d0,6+8(a0)
								swap					d0
								move					d0,2+8(a0)

								clr.l					d0
								bsr						drawScore
								bsr						drawInfoPanel
								lea						score(pc),a0
								clr.l					scoreMultiplier-score(a0)																																																					; do this here to avoid audio glitch
								rts


initGameSoundtrack
								lea						fxInit(pc),a0
								sf.b					(a0)																																																										; fxInit
								st.b					d0

								bsr						installAudioDriver
								bra						initAudioTrack

; #MARK: INIT GAME GLOBAL ENDS

    ; #MARK: - MAIN GAME LOOP
mainGameLoop        	;***Hauptprogramm/Schleife***




								IF						1=0																																																											; display objectlist pointers: shot, objects, dynamic pointer to objects
								movem.l					objectList(pc),d0-d3
								ALERT01					m1,d0
								ALERT02					m1,d1
								ALERT03					m1,d2
								ALERT04					m1,d3
								ENDIF
;	move.w objCount(pc),d0
;	MSG01 m2,d0
;	move.w shotCount(pc),d1

;	MSG02 m2,d1
;	sub.w d1,d0
;	MSG03 m2,d0

								tst.b					blitterManagerLaunch(pc)
								beq						.blitterListNotReady

								tst.b					gameInActionF(pc)
								beq.b					.blitPause
								bsr						fillManager
								bsr						blitterManager
								move.l					CUSTOM+VPOSR,d0
								lsr.l					#7,d0
								move.w					d0,rasterBarNow																																																								; store rasterPosition after blitter draw process

.blitPause
								lea						frameCount(pc),a0																																																							; update frameCount
								move.w					frameCount+6(pc),d0

.noFullFrame
								move					(a0),d1
								beq						.noFullFrame
								add.w					d1,2(a0)
								move					d1,6(a0)																																																									; store actual framerate
								clr.w					(a0)

								move.w					2(a0),d7																																																									; alternate sound-fx (shot and wall-hit pitch) for additional audio dynamics
								move.w					d7,d0
								andi.w					#%111,d0
								beq						.keepPitch
								btst					#5,d7
								seq						d0
								andi.b					#%111<<2,d0
								andi					#%111<<2,d7
								eor.b					d0,d7
								add						#$100,d7
								lea						fxTable+((fxShot-1)*fxSizeOf)+6(pc),a0
								move.w					d7,(a0)
								lea						(fxImpactWall-fxShot)*fxSizeOf(a0),a0
								andi.b					#%1<<4,d7
								lsl.b					#2,d7

								sub.w					#$b0,d7
								move.w					d7,(a0)
.keepPitch
								IFNE					SHOWGLOBALFLAGS
								lea						(animTriggers,pc),a5
								move.l					(a5),d0
								MSG04					msgGlobFlags,d0
								ENDIF

								IF						SHOWFRAMERATE=1
								lea						frameCount+6(pc),a5
								move					(a5),d1
								move.b					.frameNum-1(pc,d1),d0
								lea						.frameRate(pc),a0
								move					d0,d1
								and						#$0f,d1
								add						#"0",d1
								move.b					d1,2(a0)
								move					d0,d1
								lsr						#4,d1
								and						#$0f,d1
								add						#"0",d1
								move.b					d1,1(a0)
.sk1
								move.w					#40,d0
								move.w					#247,d1
								move.l					mainPlanesPointer+0(pc),a5
								lea						40(a5),a5
								bsr						wrtTextOnePlane

								bra.b					.cont
.frameNum
								dc.b					80,37,23,18
.frameRate
								dc.b					" AA",0
								even
.cont
								ENDIF

								bsr						scoreManager
.blitterListNotReady


								IF						SHOWframeCount=1
								lea						frameCount+2(pc),a5
								move.w					(a5),d0
								ALERT01					msgFC,d0
								ENDIF

								IFNE					SHOWOBJECTNO
								lea						.objCount(pc),a0
								move.w					#"00",2(a0)
								move.w					#"00",8(a0)
								move.w					#"00",13(a0)

								clr.l					d7
								move.w					bobCount(pc),d7
								beq						.zeroBob
.retLoopB
								divs					#10,d7
								add						#"0",d7
								move.b					d7,8(a0)
								swap					d7
								add						#"0",d7
								move.b					d7,9(a0)
.zeroBob

								clr.l					d7
								move.w					objCount(pc),d7
								beq						.zeroObj
								divs					#10,d7
								add						#"0",d7
								move.b					d7,13(a0)
								swap					d7
								add						#"0",d7
								move.b					d7,14(a0)
.zeroObj

								clr.l					d7
								move.w					spriteCount(pc),d7
								bne						.buildSprNum
.retLoopA
								clr.l					d7
								bra						.skip
.buildSprNum
								divs					#10,d7
.skip
								add						#"0",d7
								move.b					d7,2(a0)
								swap					d7
								add						#"0",d7
								move.b					d7,3(a0)

.print
								move.w					#120,d0																																																										; x-pos at the very right
								move.w					#247,d1																																																										; y-pos at the very bottom
								move.l					mainPlanesPointer+8(pc),a5
								lea						40(a5),a5
								bsr						wrtTextOnePlane
								bra.b					.contB
.objCount
								dc.b					"SPAA BOBAA OBAA",0
								even
.contB
								ENDIF


								IFNE					SANITYCHECK

								bsr						objectSanityCheck
								ENDIF

								WAITRASTER				30


.noEscape
								move.w					plyPos+plyJoyCode(pc),d0																																																					; read only upper two bytes of controller
								andi					#1<<(STICK_BUTTON_TWO),d0																																																					; only start button bit
								lea						.storeController(pc),a1
								tst.w					(a1)
								bne.b					.sameKey																																																									; only process pause if start was released
								move.w					d0,(a1)
								btst					#STICK_BUTTON_TWO,d0
								bne						.pauseGame
.sameKey
								tst.w					d0
								bne.b					.stillPressed																																																								; was button released?
								clr.w					(a1)																																																										; yes
.stillPressed

								tst.w					transitionFlag(pc)
								bne.w					mainGameLoop

								IFEQ					(RELEASECANDIDATE||DEMOBUILD)
								tst.w					keyArray+LShift(pc)
								bne						forceQuit
								tst.w					keyArray+RShift(pc)
								bne						.fastRestart
								ENDIF

								tst.b					forceExit(pc)
								beq						mainGameLoop
.exit
								lea						transitionFlag(pc),a1
								move					#transitionOut,(a1)																																																							; init fadeout
.fadeOut
								WAITVBLANK
								bsr						blitterManager
								lea						transitionFlag(pc),a1
								tst.w					(a1)
								bne.b					.fadeOut
.fastExit
								lea						CUSTOM,a6
								move.w					#DMAF_BPLEN!DMAF_SPRITE,DMACON(a6)																																																			; switch of bpl dma
								lea						gameInActionF(pc),a0
								sf.b					(a0)																																																										;	avoid
								WAITVBLANK
								WAITVBLANK
								rts

								IFEQ					(RELEASECANDIDATE||DEMOBUILD)
.fastRestart
		; right shift key, restart at level defined on levelGetter.s
								lea						gameInActionF(pc),a0
								sf.b					(a0)																																																										; disable gamecode in interrupt
								WAITVBLANK																																																															; wait a bit -> irq blits may finish
								WAITVBLANK
								WAITVBLANK
								bsr						setgameStatus
	;move.b #statusLevel1,gameStatus			;	should be statusTitle
								bra.b					.fastExit
								ENDIF
.pauseGame
;    bra mainGameLoop
								lea						transitionFlag(pc),a0
								tst.w					(a0)																																																										; no pause if fading
								bne						mainGameLoop
								tst.b					plyBase+plyExitReached(pc)
								bne						mainGameLoop																																																								; no pause if exit reached

								lea						CUSTOM,a6
								tst.b					plyBase+plyWeapUpgrade(pc)
								bmi						.initPause																																																									; skip pause code if not triggered by player but fatal ship hit

								lea						gameInActionF(pc),a0
								btst					#0,(a0)
								beq						.unpauseGame
								bclr					#0,(a0)

								move.w					frameCount+2(pc),tempVar+36																																																					; save frameCounter to keep synced animations in flow afte unpause

								lea						CUSTOM,a6
.vol							SET						0
								move.w					#musicPauseVolume,d0
								bsr						_mt_mastervol

	; init pause icon display

								move.l					pauseMsgAnimPointer(pc),a4
								move.w					animTablePointer+2(a4),d4																																																					;add  object to control quick resume mode
								move					#259+16,d5
								sub.w					plyBase+plyPosXDyn(pc),d5
								moveq					#24,d6
								add.w					viewPosition+viewPositionPointer(pc),d6
								st.b					d3
								jsr					objectInit																																																									; spawn Instant Respawn sprite
								bsr						objectListManager																																																							; update display by hand, as interrupt driven updates are off in pause mode
								bsr						spriteManager
								move.w					#$00<<1,d5																																																									; modify bullet colors to make pause icon look clear

.waitKeyRelease
								pea						.quitPause
								SAVEREGISTERS

								bra						irqJumpIn

.unpauseGame
								move.w					tempVar+36(pc),frameCount+2

								move.w					#5,d7
.loop
								lea						CUSTOM,a6
								move.w					#musicFullVolume,d0
								bsr						_mt_mastervol																																																								; need to call this a couple of time to ensure correct volume. Some kind of bug, I suppose. Prevents exploit of pause to slow down pacing too
								WAITVBLANK
								dbra					d7,.loop
.initPause

								lea						gameInActionF(pc),a0
								bset					#0,(a0)
.quitPause
								bra						mainGameLoop
.storeController
								dc.w					0
    ;bra.b keyQuitGame
;noJoyAction
 ;   clr.l plyPos+plyJoyCode
.quitGame
								btst					#0,(gameInActionF,pc)
								bne						.noEscape																																																									; in action mode? Cant escape to title
								lea						gameStatus(pc),a0
								move.b					#statusTitle,(a0)
	;move.b #statusLevel0,(a0)
								bra.b					mainLoopQuit
forceQuit
								lea						forceQuitFlag(pc),a0
								st.b					(a0)
mainLoopQuit
								lea						gameInActionF(pc),a0
								sf.b					(a0)																																																										; disable gamecode in interrupt

								WAITVBLANK																																																															; wait a bit -> irq blits may finish
								WAITVBLANK
								WAITVBLANK
								rts

; #MARK: - BLITTERMANAGER
								Include					fillManager.s


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

; #MARK: - COPPER IRQ
copperInt
								SAVEREGISTERS
								lea						SoftIntServer(pc),a1
								CALLEXEC				Cause																																																										; init software interrupt, delegate further 50 hz code handling without blocking vbi and coper interrupt chain
.skipIntCall

;	moveq #0,d0
								RESTOREREGISTERS
								rts
								IFEQ					(RELEASECANDIDATE||DEMOBUILD)
.skipFrame
								bra						.skipIntCall
								ENDIF
; #MARK: SOFT IRQ

softInt		; interrupt with lowest prio, but higher than mainloop
								SAVEREGISTERS


								bra						inputHandler																																																								; reads keyboard and stick, builds one action
retInputHandler

								tst.b					gameInActionF(pc)
								beq						quitSoftInt

	;#FIXME: code moved from interrupt to blittermanager, to kill display glitches in busy moments. Delete after 31.12.2022
								IFNE					1
								tst.b					blitterManagerFinished(pc)
								beq.b					irqScrMng																																																									; if blitter has not yet finished drawing,  keep old blitter draw list

;	if blitter has finished drawing: buffer -> active
								lea						bobDrawList(pc),a5
								movem.l					(a5),d0-d1
								exg.l					d0,d1
								movem.l					d0-d1,(a5)																																																									; swap drawing queue lists
								lea						12(a5),a5
								movem.l					(a5),d0-d1
								exg.l					d0,d1
								movem.l					d0-d1,(a5)																																																									; swap end of list comparators
								lea						blitterManagerLaunch(pc),a0
								st.b					(a0)																																																										; active list now ready for drawing
								ENDIF

irqScrMng
								lea						viewPosition(pc),a3
								move.w					((scrMngOffset).w,pc),d0
jmpSrcMngOffset
								jsr						jmpSrcMngOffset(pc,d0.w)
irqRetScreenManager
								bsr						rasterListMove
								bsr						plyManager
								bra						spriteManagerPlayer
sprManPlyReturn
								lea						frameCompare(pc),a1
								tst.w					2(a1)
								bne.b					irqSlowMotion
								bra						objectMoveManager
irqSlowMotion
								sub.w					#1,(a1)																																																										; handle framerate
								bpl						irqDidObjMoveManager
								move					2(a1),(a1)
								bra						objectMoveManager
irqDidObjMoveManager
								lea						viewPosition(pc),a3
								move.l					viewPositionAdd(a3),d7
								move.l					viewPositionPointer(a3),d6
								swap					d6
								sub						#$60,d6
								move.w					d6,viewPositionPointerLaunchBuf(a3)
								add.l					d7,viewPositionPointer(a3)																																																					; update viewPosition pointers here -> flickerfree sync of objects and background
								bsr						objectListManager
.blitListUpdate
								bra						collisionManager
irqDidColManager
								bra						particleManager
irqDidParticleManager

								move.w					((sprMngOffset).w,pc),d0
jmpSprMngOffset
								jsr						jmpSprMngOffset(pc,d0.w)																																																									;spritemanager

								tst.w					plyPos+plyCollided(pc)
								bne.b					irqNoMoreLaunches
								bra						launchManager




irqNoMoreLaunches
.noMovement
.skipGamecode


	; apply dynamic colors to enemy bullets

								move					frameCount+2(pc),d5

irqJumpIn	; used by pause function to set bullet colors
								moveq					#3,d7
								moveq					#$7<<1,d6
.paintBullets
								move.l					colorBullet(pc,d7*4),a0
								tst.l					a0
								beq						.colorBullets
								move.w					d5,d0
								btst					#4,d5
								seq						d1
								and.w					d6,d0
								and.b					d6,d1
								eor.b					d1,d0

								move.w					fetchBulletColors(pc,d0),d1
.offset							SET						12
								move.w					d1,.offset+2(a0)
								move.w					d1,.offset+6(a0)
								move.w					d1,.offset+10(a0)
								move.w					d1,.offset+14(a0)

								move.w					16+fetchBulletColors(pc,d0),d1
								move.w					d1,.offset+16+2(a0)
								move.w					d1,16+.offset+6(a0)
								move.w					d1,16+.offset+10(a0)
								move.w					d1,16+.offset+14(a0)

								move.w					32+fetchBulletColors(pc,d0),d1
								move.w					d1,32+.offset+2(a0)
								move.w					d1,32+.offset+6(a0)
								move.w					d1,32+.offset+10(a0)
								move.w					d1,32+.offset+14(a0)

								add						#6,d5
.colorBullets
								dbra					d7,.paintBullets

quitSoftInt
								moveq					#0,d0																																																										; set z-flag -> OS handles further interrupt reqs
								RESTOREREGISTERS																																																													; does not affect flags
								rts

fetchBulletColors
.red							SET						$1<<4
.green							SET						$2<<4
.blue							SET						$2<<4

	; darkest bullet color
								dc.w					-1
								REPT					7
.rgb							SET						(.red&$f0)<<4!(.green&$f0)!(.blue&$f0)>>4
								dc.w					.rgb

.red							SET						.red+24
.green							SET						.green+27
.blue							SET						.blue+38

								IF						(.red>255)
.red							SET						255
								ENDIF
								IF						(.green>255)
.green							SET						255
								ENDIF
								IF						(.blue>255)
.blue							SET						255
								ENDIF
								ENDR


	;	brightest bullet color

.red							SET						$f<<4
.green							SET						$f<<4
.blue							SET						$4<<4
								dc.w					-1
								REPT					7
.rgb							SET						(.red&$f0)<<4!(.green&$f0)!(.blue&$f0)>>4
								dc.w					.rgb

.red							SET						.red+13
.green							SET						.green+13
.blue							SET						.blue+16

								IF						(.red>255)
.red							SET						255
								ENDIF
								IF						(.green>255)
.green							SET						255
								ENDIF
								IF						(.blue>255)
.blue							SET						255
								ENDIF
								ENDR

	; medium bullet color

.red							SET						$a<<4
.green							SET						$a<<4
.blue							SET						$1<<4
								dc.w					-1
								REPT					7
.rgb							SET						(.red&$f0)<<4!(.green&$f0)!(.blue&$f0)>>4
								dc.w					.rgb

.red							SET						.red+21
.green							SET						.green+21
.blue							SET						.blue+6

								IF						(.red>255)
.red							SET						255
								ENDIF
								IF						(.green>255)
.green							SET						255
								ENDIF
								IF						(.blue>255)
.blue							SET						255
								ENDIF
								ENDR
; #MARK: levelspecific jmps
scrMngOffset				=	*+2
								dc.w					0,0
sprMngOffset
								dc.w					0

; #MARK: VERTICAL BLANK IRQ
vertBlancInt
								SAVEREGISTERS



								IFNE					0																																																											; not using ingame sync of audio and video anymore; commented out

								lea						AudioRythmFlagAnim(pc),a0
								tst.b					(a0)
								beq.b					.2
								btst					#4,(a0)
								seq						d0
								andi					#$3f,d0
								sub.b					#1,(a0)																																																										; flag reset in audio.s
								move.b					(a0),d7
								eor						d0,d7
								clr.b					d7
								move.b					d7,1(a0)

.2
								ENDIF
	;bsr keyboardHandler

								tst.l					copInitColorswitch(pc)																																																						; poke .l into this with pointer to colorlist or other alternative coplist in copperformat to safely switch colors; take care of init´ copjmp1@end of colorlist
								bne						.initModifiedCoplist
								move.l					#copGamePlyBody,CUSTOM+COP2LC																																																				; user-init needed every vbi to overwrite OS-init
.cop2started
								lea						frameCount(pc),a0
								addq					#1,(a0)
								addq					#1,4(a0)
;    tst.w plyPos+plyCollided(pc)
 ;   bne .playerDies    ; if player dies, handle framerate(copperIRQ)
.playerLives                  ; do some score stuff
								lea						scoreMultiplier(pc),a1
								tst.w					(a1)																																																										; countdown scoremultiplier?
								beq.b					.1
								subq.w					#1,(a1)																																																										;  yes
								beq						.pitchreset																																																									; no valuable hit for some time?
.1
								tst.w					transitionFlag(pc)
								bne.w					.transition
.vbiQuit
								moveq					#0,d0																																																										; z-flag needs to be clear on vbi / OS convention
								RESTOREREGISTERS
								rts

.initModifiedCoplist
								lea						copInitColorswitch(pc),a0
								move.l					(a0),CUSTOM+COP2LC
								clr.l					(a0)
								clr.w					CUSTOM+COPJMP2
								bra						.cop2started

.pitchreset
								lea						plyPos(pc),a0
								tst.w					plyCollided(a0)
								bne.b					.skipFX
								tst.b					plyExitReached(a0)
								bne.b					.skipFX																																																										; play FX only if player in action
								tst.b					3(a1)																																																										; multiplier < 2?
								beq						.skipFX																																																										; yes!
								PLAYFX					fxKillChain
.skipFX
								clr.w					2(a1)
								bra						.1
.transition
								lea						transitionFlag(pc),a0
								clr.l					d1
								tst.w					(a0)
								bpl						.fadeIn
								move.w					#transitionOut-$18,d0																																																						; fade out
								sub.w					(a0),d0
								SAVEREGISTERS
								tst.w					d0
								spl						d1
								ext.w					d1
								and.l					d1,d0
								not.b					d0
								muls					#36,d0
								lsr.w					#7,d0
								sub.b					#$9,d0
	;sub.b #2,d0
								lea						CUSTOM,a6

								bsr						_mt_mastervol																																																								; set music volume
								RESTOREREGISTERS
								bra.b					.cntDwnFade
.fadeIn
								move.w					(a0),d0
								sub						#30,d0																																																										; set left frame border
.cntDwnFade						sub.w					#4,(a0)
								bvc.b					.gamePaused
								clr.w					(a0)																																																										; fade finished
.gamePaused
	;lea $dff000,a6
								add.w					#$c0,d0
								move.l					d0,d1
								andi					#$ff,d0
								or.w					#(displayWindowStart+1)<<8,d0
								lsr.l					#3,d1
								andi					#$20,d1
								or						#$3100,d1
								move.w					d0,COPDIWSTRT+2
								move.w					d1,COPDIWHIGH+2
.quit
								bra						.vbiQuit

irqCopJmp
								dc.l					0
transitionFlag
								dc.w					0
transitionIn				=	$f0																																																																	; $f8
transitionDone				=	$30																																																																	; $34
transitionOut				=	$8000!transitionIn
irqColorFlag
								dc.b					0
								even


; #MARK: - RASTERLIST MANAGER BEGINS
rasterListTitle:

								move.l					copSplitList(pc),a1
								move.l					(a1)+,a2																																																									; get adress of current subcoplist -> pointer to BPLCON1
								lea						-8(a2),a4																																																									; pointer to BPLMOD
								lea						coplineAnimPointers,a6
								andi					#$7f,d6
								move.l					(a6,d6*4),a5																																																								; get adress of anim table list

								move.l					4(a5),d5																																																									;; get first modulus
								move.w					(a1)+,d0
								move					d5,(a4,d0)
								lea						8(a5),a5
								move					copBPLCON1+2,d2																																																								; get value calc´d by basic scroll code
								andi					#$0f0f,d2
								swap					d5
								or						d2,d5

								move					d5,(a2,d0)
								move.w					#$7a,d7																																																										; no of scanlines/2
								lsr						#1,d7
								addq					#2,d7
.writeCopLine
								movem.l					(a5)+,d3-d4
								movem.w					(a1)+,d0-d1
								move					d3,(a4,d0)																																																									; write to BPLxMOD
								swap					d3
								or						d2,d3
								move					d3,(a2,d0)																																																									; write to BPL1CON
								move					d4,(a4,d1)
								swap					d4
								or						d2,d4
								move					d4,(a2,d1)
								dbra					d7,.writeCopLine
nilManager	; label needed in case of skipping subcode from irq code. Could use any rts
								rts


rasterListMove:
								lea						copSplitList(pc),a2

								move.l					(a2)+,a1																																																									; pointer to offset table
	;lea $6814BE04,a1
								move.w					(a2),d7																																																										; no of lines
								beq.b					nilManager

								move.l					(a1)+,a2																																																									; get adress of current subcoplist -> pointer to BPLCON1
								lea						coplineAnimPointers,a6

								lsr.w					d5,d6																																																										;modify anim speed

								move.w					plyBase+plyPosX(pc),d5
								lsr						#2,d5
								cmpi.w					#$39,d5
								bls						.sk
								move.w					#$39,d5
.sk
								move.l					(a6,d5*4),a5																																																								; get adress of anim table list. Full list contains an order of 12 (?) x-offsets -> x-scrolling


								move.w					frameCount+2(pc),d5
								asr						#2,d5
								andi					#$ff,d5
								lea						(a5,d5*2),a5																																																								; apply animation wave


								move					copBPLCON1+2,d2																																																								; get value calc´d by basic scroll code
								andi					#$0f0f,d2

								tst.b					escalateIsActive(pc)
								bne						.escalateMode

								tst.b					dialogueIsActive(pc)
								bne						.dialogueMode

	;move.b plyBase+plyDistortionMode(pc),d0

								tst.b					plyBase+plyDistortionMode(pc)
								bne.b					.distortionMode
;;	move.w copSplitList+4(pc),d7 ; how many lines in current copsublist?
								lsr						#2,d7
								sub						#1,d7
.writeCopLine
								movem.l					(a1)+,d0-d1
								movem.l					(a5)+,d3-d4
								eor						d2,d3
								move					d3,(a2,d0)																																																									; write to BPL1CON

								swap					d0
								swap					d3
								or						d2,d3
								move					d3,(a2,d0)

								or						d2,d4
								move					d4,(a2,d1)
								swap					d1
								swap					d4
								or						d2,d4
								move					d4,(a2,d1)

								dbra					d7,.writeCopLine
;	bra .quit
								movem.l					(a1)+,d0
								movem.l					(a5)+,d3

								or						d2,d3
								move					d3,(a2,d0)
								swap					d0
								swap					d3
								or						d2,d3
								move					d3,(a2,d0)
								rts
.distortionMode         ; shake screen a bit

								move.w					copSplitList+4(pc),d7
								subq					#1,d7
								clr.w					d3
								move.b					plyPos+plyDistortionMode(pc),d3
								lsr						#3,d3
								move					d3,d6
								lsl						#4,d6
								or						d6,d3
								moveq					#4,d6
.writeCopDistortion
								move.w					(a5)+,d4
    ;move d4,d5
								move.w					(a1)+,d0
								swap					d4
								or						d2,d4
								move.l					(a3),d1																																																										; AB
								move.l					4(a3),d5																																																									; CD
								swap					d5																																																											; DC
								add.l					d5,(a3)																																																										; AB + DC
								add.l					d1,4(a3)
								eor.b					d6,d1
								lsl						#1,d1
								move					d1,d5
								andi					#$0f,d5
								lsr						#1,d5
								ror						d6,d1
								move.b					d1,d5
								lsl						d6,d5
								or						d5,d1
								and						d3,d1
								eor.b					d1,d2
								tst.b					-2(a2,d0)																																																									; is $80?
	;beq.b .skip	; yes->skip shot/player split
								move.w					d4,(a2,d0)																																																									; write to BPL1CON
.skip
								dbra					d7,.writeCopDistortion
.quit
								rts
														; split view
.escalateMode
								moveq					#((escalateStart-displayWindowStart)/4),d6
.writeEscCopLow
								move.l					(a1)+,d0
								move.l					(a5)+,d3
								or						d2,d3
								move					d3,(a2,d0)																																																									; write to BPL1CON
								swap					d0
								swap					d3
								or						d2,d3
								move					d3,(a2,d0)
								dbra					d6,.writeEscCopLow

								move					#3,d4
								clr.w					d5
								move					d2,d3
								lea						$bfe601,a3
								move.b					escalateIsActive(pc),d1
								cmpi.b					#1,d1
								beq						.escalMore																																																									; first phase? Yes!
								move					d1,d4																																																										; text zoomed -> distort
								lsr.b					#5,d4
								cmpi.b					#4,d4
								bcs						.cap
								move.b					#3,d4
.cap
								move.b					$dff007,d1
.escalMore
								moveq					#(escalateHeight-4)/2,d6
								andi.w					#$fff,d3
								or.w					#%10<<14,d3

								lea						copGameEscalateSplits,a4
.writeEscCopCentre
	;move.l (a5)+,d3
								add.b					(a3),d1
								move.b					d1,d5
								lsr.b					d4,d5																																																										; modify strength of split line effect
								andi					#$f0,d5
								eor.b					d5,d3
								move					d3,6(a4)																																																									; write to BPL1CON
								lea						8(a4),a4
								dbra					d6,.writeEscCopCentre


								lea						26*2(a1),a1
								lea						26*2(a5),a5
	; modify two scanlines out of loop and write result to dialogue coplist too
								bsr						.modifySubViewBPL1CON
								move					d3,copGameEscExitBPLCON2+6																																																					; take care of last rastline escal view

								moveq					#($100+displayWindowStop-escalateStart+escalateHeight-195)/2,d7
	;lea -(escalateHeight-10)*2(a5),a5
	;lea escalateHeight-34(a1),a1
.writeEscCopHigh
								move.l					(a1)+,d0
								move.l					(a5)+,d3
	;moveq #-1,d3
								or						d2,d3
								move					d3,(a2,d0)																																																									; write to BPL1CON
								swap					d0
								swap					d3
								or						d2,d3
								move					d3,(a2,d0)
								dbra					d7,.writeEscCopHigh
								rts
.modifySubViewBPL1CON
								move.l					(a1)+,d0
								move.l					(a5)+,d3
								or						d2,d3
								move					d3,(a2,d0)																																																									; write to BPL1CON
								swap					d0
								swap					d3
								or						d2,d3
								move					d3,(a2,d0)
								rts

.dialogueMode
								lsr						#1,d7
								moveq					#((dialogueStart-displayWindowStart)/4),d6
								sub						d6,d7
.writeDialgCopLow
								move.l					(a1)+,d0
								move.l					(a5)+,d3
								or						d2,d3
								move					d3,(a2,d0)																																																									; write to BPL1CON
								swap					d0
								swap					d3
								or						d2,d3
								move					d3,(a2,d0)
								dbra					d6,.writeDialgCopLow

								move					#3,d4
								clr.w					d5
								move					d2,d3
								moveq					#(dialogueHeight-8)/4,d6
								sub						d6,d7
								andi.w					#$c0f,d3
								or.w					#%1000<<12!%101<<4,d3
.writeDialgCopCentre
								move.l					(a1)+,d0
								move					d3,(a2,d0)																																																									; write to BPL1CON
								swap					d0
								move					d3,(a2,d0)
								dbra					d6,.writeDialgCopCentre
								sub						#4,d7

	; modify two scanlines out of loop and write result to dialogue coplist too
								lea						40(a5),a5
								bsr						.modifySubViewBPL1CON
								move					d3,copGameDialgExitBPLCON0+6																																																				; take care of last rastline dialogue view

.writeDialgCopHigh
								move.l					(a1)+,d0
								move.l					(a5)+,d3
								or						d2,d3
								move					d3,(a2,d0)																																																									; write to BPL1CON
								swap					d0
								swap					d3
								or						d2,d3
								move					d3,(a2,d0)
								dbra					d7,.writeDialgCopHigh
								rts



; #MARK: build raster list

rasterListBuild:          ; generate pointers to BPLCON1 in current copsublist. Called by macro COPPERSUBLIST
								lea						escalateEntry(pc),a0
								moveq					#(memoryPointersEnd-escalateEntry)/4-1,d7
.resetPointers
								clr.l					(a0)+
								dbra					d7,.resetPointers

								move.l					#tempVar+20,copColSprite																																																					; preload with harmless dummy value, in case no working entry is found

								move.l					copperGame(pc),a0
								move.l					copSplitList(pc),a1
								move.l					a0,(a1)+																																																									; store address of current coplist, pointers to all BPLCON1-regs behind
								clr.l					d0
								clr.l					d1
								clr.w					d3																																																											; used as counter for bulletColor. Do not modify!
								clr.w					d5																																																											; used as counter for spr7posEntry. Do not modify!
								lea						vars(pc),a5
.iterate
								addq.w					#4,d0
								move.l					(a0,d0),d6
								move.l					d6,d7
								swap					d6
								cmpi.w					#BPLCON1,d6																																																									; find entrys with scrolling regs
								beq						.scrolReg
								cmpi.w					#COPJMP1,d6																																																									; reached end of subcoplist
								beq.w					.finish
								cmpi.w					#NOOP,d6
								bne						.iterate
								move.w					.jT(pc,d7.w*2),d6																																																							; check for NOOP-cmd as initsignal for special copper fx
.jmp							jmp					.jmp(pc,d6.w)
.jT
								dc.w					.iterate-.jT+2,.escalateEntry-.jT+2,.escalateExit-.jT+2,.gameFinEntry-.jT+2																																									; 0-3
								dc.w					.gameFinReturn-.jT+2,.iterate-.jT+2,.spr7pthEntry-.jT+2,.lowerScoreEntry-.jT+2																																								; 4-7
								dc.w					.iterate-.jT+2,.dialogueEntry-.jT+2,.dialogueExit-.jT+2,.achievementsEntry-.jT+2																																							;8-11
								dc.w					.achievementsQuit-.jT+2,.bpl2modReversal-.jT+2, .spr7posEntry-.jT+2, .colorBullet-.jT+2																																						;12-15
								dc.w					.availSlot-.jT+2
.scrolReg
								move					d0,d2
								addq					#2,d2
								move.w					d2,(a1)+																																																									; write pointer
								addq					#1,d1
								bra						.iterate
.spr7pthEntry
								lea						4(a0,d0.w),a2
								move.l					a2,copSPR6PTH-vars(a5)
								bra						.iterate
.spr7posEntry
								lea						4(a0,d0.w),a2
								IFEQ					(RELEASECANDIDATE||DEMOBUILD)																																																				; overflow-errorcheck in pre-releasecode only
								cmpi					#(copSpr6posChk-copSpr6pos)/4-1,d5
								bls						.noError
.noError
								ENDIF
								move.l					a2,copSpr6pos-vars(a5,d5*4)
								addq					#1,d5
								bra						.iterate
.availSlot
								ILLEGAL
								bra						.iterate
.colorBullet
								lea						(a0,d0.w),a2
								move.l					a2,colorBullet-vars(a5,d3*4)
								addq					#1,d3
								bra						.iterate
.lowerScoreEntry
								lea						(a0,d0.w),a2
								move.l					a2,lowerScoreEntry-vars(a5)
								bra						.iterate
.gameFinEntry
								lea						(a0,d0.w),a2
								move.l					a2,gameFinEntry-vars(a5)
								move.l					#copGameFin,d2
								move					d2,10(a0,d0)
								swap					d2
								move					d2,6(a0,d0)
								move					#NOOP,12(a0,d0)																																																								; overwrite copJmp trigger
								bra						.iterate
.gameFinReturn
								lea						(a0,d0.w),a2
								move.l					a2,d2
								lea						copGameFinQuit,a2
								move.w					d2,6(a2)
								swap					d2
								move.w					d2,2(a2)																																																									; set return adress to main coplist in gamefin subcoplist
								bra						.iterate
.bpl2modReversal
								lea						6(a0,d0.w),a2
								move.l					a2,bpl2modReversal-vars(a5)
								bra						.iterate
.escalateEntry
								lea						(a0,d0.w),a2
								move.l					a2,escalateEntry-vars(a5)
								move.l					#copGameEscalate,d2
								move					d2,10(a0,d0)
								swap					d2
								move					d2,6(a0,d0)
								move					#NOOP,12(a0,d0)																																																								; overwrite copJmp trigger
								lea						escalateIsActive(pc),a2
								sf.b					(a2)
								add.w					#16,d0
								bra.w					.iterate

.escalateExit
								lea						(a0,d0.w),a2
								move.l					a2,escalateExit-vars(a5)
								add.w					#4,d0
								bra.w					.iterate

.modifyCopEnd
								lea						16(a0,d0.w),a6
								move.l					a6,d2
								move.w					d2,6(a2)
								swap					d2
								move.w					d2,2(a2)
								add.w					#16,d0
								bra.w					.iterate
.achievementsEntry
								lea						(a0,d0.w),a2
								move.l					a2,achievementsEntry-vars(a5)
								move.l					#copGameAchievements,d2
								move					d2,10(a0,d0)
								swap					d2
								move					d2,6(a0,d0)
								move					#NOOP,12(a0,d0)																																																								; overwrite copJmp trigger
								lea						copGameAchievementsEnd,a2
								bra						.modifyCopEnd
.achievementsQuit
								lea						(a0,d0.w),a2
								move.l					a2,achievementsQuit-vars(a5)
								move.l					#copGameAchievementsQuit,d2
								move					d2,10(a0,d0)
								swap					d2
								move					d2,6(a0,d0)
								move					#NOOP,12(a0,d0)																																																								; overwrite copJmp trigger
								lea						copGameAchievementsQuitEnd,a2
								bra						.modifyCopEnd

.dialogueEntry
								lea						(a0,d0.w),a2
								move.l					a2,dialogueEntry-vars(a5)
								move.l					#copGameDialogue,d2
								move					d2,10(a0,d0)
								swap					d2
								move					d2,6(a0,d0)
								move					#NOOP,12(a0,d0)																																																								; overwrite copJmp trigger
								lea						dialogueIsActive(pc),a2
								sf.b					(a2)
								add.w					#16,d0
								bra.w					.iterate

.dialogueExit
								lea						(a0,d0.w),a2
								move.l					a2,dialogueExit-vars(a5)
								add.w					#4,d0
								bra.w					.iterate

.colorMarker
								lea						10(a0,d0.w),a2
								move.l					a2,copColSprite-vars(a5)
								lea						4(a2),a2
								move.l					a2,copPriority-vars(a5)
								bra.w					.iterate
.finish
								clr.l					(a1)+

								move.w					#$18,d5
								move					d1,copSplitList+4																																																							; number of BPLCON1-regs in subcoplist
								lea						gameStatusLevel(pc),a0																																																						; preps - which kind of parallax anim?
								move.w					(a0),d0
								bpl.b					.titleCheck
								clr.w					d0
.titleCheck
								lea						rasListPrepJmpTbl(pc),a0
								move.w					(a0,d0*2),d6																																																								; fetch anim precalc jump offset

								move.l					copperGame(pc),a1
								move.l					(a1)+,a2																																																									; get adress of current subcoplist -> pointer to BPLCON1
    ;lea 4(a2),a4    ; pointer to BPLMOD
								suba.l					a4,a4
								lea						coplineAnimPointers,a6

								moveq					#8,d2																																																										; start value for 2nd scanline mod modifier
D7RASYCOUNT						EQUR					d7
D1frameCount					EQUR					d1
								move.l					(a6),a0																																																										; get adress of anim buffer
								moveq					#noOfCoplineAnims-1,D1frameCount																																																			; build data for x anim / x-scroll frames
buildRasListFrame
								move					#(noOfCoplines*2)-1,D7RASYCOUNT																																																				; build data for x coplines
	;move.w #$7f,d7
								move.l					(a6)+,a0																																																									; get adress of anim buffer
								move.w					#2,a5
buildRasList
								jmp						buildRasList(pc,d6.w)																																																									; precalc PF2Hx and modulus for one frame
buildRasListMod
								adda					#2,a0
								dbra					d7,buildRasList
								adda					#noOfCoplines,a0
								dbra					d1,buildRasListFrame
								rts

rasListPrepJmpTbl	; precalc list offsets
								dc.w					.preStoreStage0-buildRasList-2
								dc.w					.preStoreStage1-buildRasList-2
								dc.w					.preStoreStage2-buildRasList-2
								dc.w					.preStoreStage3-buildRasList-2
								dc.w					.preStoreStage4-buildRasList-2
								dc.w					.preStoreStage5-buildRasList-2

.preStoreStage0
;	d1 = frames $3a - 0
;	d7 = coplines 0 - 127
								move					d7,d4
								asr						#1,d4
								clr.w					d2
								move.b					0+sineTable(pc,d4.w),d2																																																						; add sinus form
								asr						#1,d2
								muls					#30*3,d2
								divu					#27*3,d2
								move.w					d1,d4
								cmpi.b					#$10,d4
								blo						.skip
								move.b					#10,d4
.skip
								add.w					d1,d2
								move.w					scrollXbitsTable(pc,d2*2),d5
								bra						.pSS1
.preStoreStage1
;	d1 = frames 0-127
;	d7 = coplines 0 - 127
								move					d7,d4
								lsl						#2,d4
								andi.w					#$7f,d4
								clr.w					d2
								move.b					sineTable(pc,d4.w),d2																																																						; add sinus form
								move					#410,d3
								sub						d7,d3
								muls					d3,d2
								divu					#232<<4,d2
								add						d1,d2
								andi.w					#$7f,d2
								move.w					scrollXbitsTable+110(pc,d2*2),d5
.pSS1
								lsl						#4,d5
								move					d5,(a0)																																																										; prestore BPL1CON
								move					d5,noOfCoplines*2(a0)																																																						; prestore BPL1CON
								bra						buildRasListMod

.preStoreStage2
;	d1 = frames 0-127
;	d7 = coplines 0 - 127
								move.w					d1,d2
								muls					#9,d2
								lsr						#3,d2

								clr.w					d3
								move.w					d7,d3
								asr						#1,d3
								move.b					sineTable(pc,d3.w),d3																																																						; add sinus form
								asr						#1,d3
								add.b					d3,d2

								andi.w					#$7f,d2
								move.w					scrollXbitsTable+20(pc,d2*2),d5
								bra						.pSS1
.preStoreStage3

								move					d7,d4
								asr						#2,d4
								clr.w					d2
								move.b					0+sineTable(pc,d4.w),d2																																																						; add sinus form
								asr						#1,d2
								muls					#30*3,d2
								divu					#27*3,d2
								move.w					d1,d4
								cmpi.b					#$10,d4
								blo						.reachedBorder
								move.b					#10,d4
.reachedBorder
								add.w					d1,d2																																																										; background x-scrolling
								move					d7,d4
								add						d1,d4
								lsr						#2,d4
	;move d7,d4
	;lsr #2,d4

								andi					#$7,d4																																																										; d4 contains water ripple
								move.w					100+sineTable(pc,d4*2),d4																																																					; contains sidescrolling
								andi.w					#$f,d4

								move.w					scrollXbitsTable(pc,d2*2),d5																																																				; contains sidescrolling
								lsl						#4,d4
								andi.w					#(%11<<8)|(%11<<4),d4
								add.w					d4,d5																																																										; add water ripple

								bra						.pSS1
.preStoreStage4
.preStoreStage5
;	d1 = frames 0-127
;	d7 = coplines 0 - 127
								move					d7,d4
								andi.w					#$7f,d4
								clr.w					d2
								move.b					sineTable(pc,d4.w),d2																																																						; add sinus form
								move.b					d2,d3
								lsr.b					#1,d2
								lsr.b					#4,d3
								add.b					d3,d2
								add						d1,d2
								andi.w					#$7f,d2
								move.w					scrollXbitsTable+50(pc,d2*2),d5
								bra						.pSS1
;.preStoreStage5
								move					d1,d4
								not						d4
								move					d7,d5
								lsr						#2,d5
								add						d5,d4
								andi					#$7f,d4
								move.b					80+sineTable(pc,d4.w),d3																																																					; add sinus form
								muls					#25,d3
								divu					#10,d3
								not.b					d3
								andi					#$7f,d3

								move.w					scrollXbitsTable(pc,d3*2),d5
								not.b					d5
								lsl						#4,d5
								andi					#$0f0,d5
								move					d5,(a0)																																																										; prestore BPL1CON
								bra						buildRasListMod
.preStoreNil
								bra						buildRasListMod


sineTable   ; 128 values, maxAmp=128, 1 oscillation, generated http://www.daycounter.com/Calculators/Sine-Generator-Calculator.phtml
								dc.b					64,67,70,73,76,79,82,85,88,91,93,96,99,101,104,106,108,111,113,115,116,118,120,121,122,123,124,125,126,126,127,127,127,127,127,126,126,125,124,123,122,121,120,118,116,115,113,111,108,106,104,101,99,96,93,91,88,85,82,79,76,73,70,67
								dc.b					64,60,57,54,51,48,45,42,39,36,34,31,28,26,23,21,19,16,14,12,11,9,7,6,5,4,3,2,1,1,0,0,0,0,0,1,1,2,3,4,5,6,7,9,11,12,14,16,19,21,23,26,28,31,34,36,39,42,45,48,51,54,57,60


tanTable	; transform angle/anim offset table in relation to x- and y-vector/acc. resolution 32 x 32 positions. Generated using createObjAngleVectorTable.cpp
								dc.b					24,24,24,24,26,26,26,26,28,28,30,30,30,30,32,32,32,32,32,34,34,36,36,36,36,38,38,38,38,40,40,40																																				; row 0
								dc.b					24,24,24,24,26,26,26,26,28,28,28,28,30,30,32,32,32,34,34,34,34,36,36,38,38,38,38,40,40,40,40,40
								dc.b					24,24,24,24,26,26,26,26,28,28,28,28,30,30,32,32,32,34,34,34,34,36,36,38,38,38,38,40,40,40,40,40
								dc.b					22,22,24,24,24,24,26,26,26,26,28,28,30,30,32,32,32,34,34,34,34,36,36,38,38,38,38,40,40,40,40,42
								dc.b					22,22,24,24,24,24,26,26,26,26,28,28,30,30,32,32,32,34,34,34,34,36,36,38,38,38,38,40,40,40,40,42
								dc.b					22,22,22,22,24,24,24,24,26,26,28,28,30,30,32,32,32,34,34,36,36,38,38,38,38,40,40,40,40,42,42,42																																				; row 5
								dc.b					22,22,22,22,24,24,24,24,26,26,28,28,30,30,32,32,32,34,34,36,36,38,38,38,38,40,40,40,40,42,42,42
								dc.b					20,20,22,22,22,22,24,24,24,24,26,26,30,30,32,32,32,34,34,36,36,38,38,40,40,42,42,42,42,42,42,44
								dc.b					20,20,22,22,22,22,24,24,24,24,26,26,30,30,32,32,32,34,34,36,36,38,38,40,40,42,42,42,42,42,42,44
								dc.b					20,20,20,20,20,20,22,22,24,24,26,26,28,28,32,32,32,34,34,38,38,40,40,42,42,42,42,44,44,44,44,44
								dc.b					20,20,20,20,20,20,22,22,24,24,26,26,28,28,32,32,32,34,34,38,38,40,40,42,42,42,42,44,44,44,44,44																																				; row 10
								dc.b					18,18,18,18,20,20,20,20,22,22,24,24,26,26,32,32,32,36,36,40,40,42,42,44,44,44,44,44,44,46,46,46
								dc.b					18,18,18,18,20,20,20,20,22,22,24,24,26,26,32,32,32,36,36,40,40,42,42,44,44,44,44,44,44,46,46,46
								dc.b					16,16,16,18,18,18,18,18,18,18,20,20,24,24,32,32,32,40,40,44,44,44,44,46,46,46,46,46,46,46,46,46
								dc.b					16,16,16,18,18,18,18,18,18,18,20,20,24,24,32,32,32,40,40,44,44,44,44,46,46,46,46,46,46,46,46,46
								dc.b					18,18,18,18,18,18,18,18,18,18,18,18,18,18,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48																																				; row 15
								dc.b					18,18,18,18,18,18,18,18,18,18,18,18,18,18,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
								dc.b					18,18,18,18,18,18,18,18,18,18,18,18,18,18,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48,48
								dc.b					16,16,16,16,16,16,14,14,14,14,12,12,10,10,0,0,0,56,56,54,54,52,52,50,50,50,50,50,50,50,50,50
								dc.b					16,16,16,16,16,16,14,14,14,14,12,12,10,10,0,0,0,56,56,54,54,52,52,50,50,50,50,50,50,50,50,50
								dc.b					14,14,14,14,14,14,12,12,12,12,10,10,6,6,0,0,0,60,60,56,56,54,54,54,54,52,52,52,52,52,52,50																																					; row 20
								dc.b					14,14,14,14,14,14,12,12,12,12,10,10,6,6,0,0,0,60,60,56,56,54,54,54,54,52,52,52,52,52,52,50
								dc.b					14,14,12,12,12,12,10,10,10,10,6,6,4,4,0,0,0,62,62,58,58,56,56,54,54,54,54,54,54,52,52,52
								dc.b					14,14,12,12,12,12,10,10,10,10,6,6,4,4,0,0,0,62,62,58,58,56,56,54,54,54,54,54,54,52,52,52
								dc.b					12,12,12,12,10,10,10,10,8,8,6,6,4,4,0,0,0,62,62,60,60,58,58,56,56,56,56,54,54,54,54,54
								dc.b					12,12,12,12,10,10,10,10,8,8,6,6,4,4,0,0,0,62,62,60,60,58,58,56,56,56,56,54,54,54,54,54																																						; row 25
								dc.b					10,10,10,10,10,10,8,8,6,6,4,4,2,2,0,0,0,62,62,60,60,60,60,58,58,56,56,56,56,54,54,54
								dc.b					10,10,10,10,10,10,8,8,6,6,4,4,2,2,0,0,0,62,62,60,60,60,60,58,58,56,56,56,56,54,54,54
								dc.b					10,10,10,10,8,8,6,6,6,6,4,4,2,2,0,0,0,0,0,62,62,60,60,58,58,58,58,56,56,56,56,54
								dc.b					10,10,10,10,8,8,6,6,6,6,4,4,2,2,0,0,0,0,0,62,62,60,60,58,58,58,58,56,56,56,56,54
								dc.b					10,10,8,8,8,8,6,6,6,6,4,4,2,2,0,0,0,0,0,62,62,60,60,60,60,58,58,58,58,56,56,56
								dc.b					10,10,8,8,8,8,6,6,6,6,4,4,2,2,0,0,0,0,0,62,62,60,60,60,60,58,58,58,58,56,56,56
tanTableEnd
								if						(tanTableEnd-tanTable)!=1024
								PRINTT					"WARNING Tantable MUST contain 1024 bytes!"
								ENDIF
; #MARK: RASTERLIST MANAGER ENDS




; #MARK: - PARTICLE MANAGER BEGINS
particleManager
								lea						particleClear(pc),a6
								movem.l					particleDrawBase(pc),a4-a5
								lea						mainPlaneWidth*mainPlaneDepth(a4),a1
								lea						mainPlaneWidth*mainPlaneDepth(a5),a2
								clr.l					d4
.clrLoop
								move.w					(a6)+,d4
								beq.b					.allCleared
								move.b					(a4,d4.l),(a5,d4.l)
								move.b					(a1,d4.l),(a2,d4.l)
								bra.b					.clrLoop
.allCleared
;	clr.w (a3)
.draw

								lea						AddressOfYPosTable(pc),a0
								lea						particleBits(pc),a1
								lea						particleBitmapOffset(pc),a2
								lea						particleDrawBase(pc),a3
								movem.l					mainPlanesPointer+4(pc),a4/a5

								move.l					a5,(a3)
								move.l					a4,4(a3)
								lea						mainPlaneWidth*mainPlaneDepth(a4),a5
								lea						particleClear(pc),a3
								lea						particleTable-partEntrySize(pc),a6

								moveq					#7,d0
								clr.l					d1
								clr.l					d2
								clr.w					d3
								move					#240,d4																																																										; y-bounds
								move					#280<<4,d2																																																									; x-bounds
								clr.l					d5
								move.w					#partEntrySize,d6
								move					#particlesMaxNo-1,d7
								bra.w					.loop
.nextParticle
								lea						(a6,d6),a6
    ;lea partEntrySize(a6),a6
								move.w					(a6),d1																																																										; load x-Position
								bne						.drawParticle
.loop
								dbra					d7,.nextParticle
								clr.w					(a3)																																																										; mark end of particle clear list
								bra						irqDidParticleManager

.drawParticle
								move.b					partLifeCntdwn(a6),d3
								sub.b					d3,partLifetime(a6)																																																							; lifetime
								bcs.b					.killPart

								cmp						d2,d1
								bhi						.killPart																																																									; out of bounds left or right?

								move.b					partYPos(a6),d3																																																								; y-position
    ;move #200,d3
								cmp						d4,d3
								bhi.b					.killPart																																																									; out of bounds up or down?
								move					d1,d5
								lsr						#4,d5
								lsr						d0,d1																																																										; x-byte-offset
								and.w					d0,d5
								move.b					(a1,d5),d5																																																									; read particle definition
								add.w					(a0,d3*2),d1																																																								; add y bitmap offset

								move.b					partLifetime(a6),d3
								lsr.b					#6,d3
								add.w					(a2,d3.w*2),d1																																																								; add bitplane offset
								move.w					d1,(a3)+																																																									; bitmap byte restore pointer
								eor.b					d5,(a5,d1.l)																																																								; plot top line
								eor.b					d5,(a4,d1.l)																																																								; plot second line

								move.l					partXAccl(a6),d5																																																							; move particle
								add.l					d5,partXPos(a6)

								dbra					d7,.nextParticle
								clr.w					(a3)																																																										; mark end of particle clear list
								bra						irqDidParticleManager

.killPart
								clr.w					(a6)																																																										; delete
								dbra					d7,.nextParticle
								clr.w					(a3)																																																										; mark end of particle clear list
								bra						irqDidParticleManager

    ; particleTable a0, x-pos D3, y-pos D4, xacc D5, yacc d6
    ; 	x d3 (0-255) << 4
	;	y d4 (0-255) << 8
particleSpawn

								clr.l					d0

								lea						particleTable-partEntrySize(pc),a6

								lea						ptEnd-4(pc),a3

								move.w					d5,a1
								move.w					d3,a2
								moveq					#-1,d1
								lea						partEntrySize,a5
.readParticle
								move.l					(a0)+,d0
								beq.b					.noMoreParticles
								move.b					d0,d7

								ext.w					d7																																																											; y-acc
								asl						#3,d7
    ;move #-400,d7
								asr.l					#8,d0
								move.b					d0,d2
								ext.w					d2																																																											; x-acc

								move.w					d0,d3
								clr.b					d3																																																											; y-add
								swap					d0
								ext.w					d0
								lsl.l					#4,d0																																																										; x-add

								add.w					d0,a2
								add.w					d3,d4

								add.w					d2,a1
								add.w					d7,d6
.findSlot
								adda.w					a5,a6
								tst.w					(a6)																																																										; particle available?
								bne.b					.findSlot

								cmp.l					a3,a6
								bhi						.noMoreParticles

								move.w					a1,d5
								move.w					a2,d3
								swap					d3
								move					d4,d3
								swap					d5
								move					d6,d5
								movem.l					d3/d5,(a6)

								move.b					(a0)+,d1
								move.w					d1,partLifetime(a6)
								add						#1,a0
								bra.b					.readParticle
.noMoreParticles
								rts
emitterBulletHitsBck
								dc.b					0,0,-1,-12,21,0
								dc.b					-1,1,0,17,24,0
								dc.b					0,-2,-3,2,17,0
								dc.b					-1,-1,-5,-7,23,0
								dc.b					-1,3,5,-40,25,0
								dc.b					-1,-4,-10,90,20,0
								dc.l					0
emitterExtraLoss
								dc.b					0,0,-1,-127,8,0
								dc.b					-1,1,0,-127,12,0
								dc.b					0,-2,-3,80,9,0
								dc.b					-1,-1,-5,-40,5,0
								dc.b					-1,-4,-10,90,7,0
								dc.b					0,4,5,-90,9,0
								dc.b					2,4,-5,90,8,0
								dc.b					3,5,10,-70,10,0
								dc.b					-3,-5,-20,-70,8,0
								dc.b					2,3,10,-90,6,0
								dc.b					-2,-3,10,90,6,0
								dc.b					-4,7,10,90,6,0
								dc.b					4,-7,10,90,6,0
								dc.b					-1,0,-10,120,6,0
								dc.b					1,0,-10,120,6,0
								dc.b					0,-2,10,127,12,0
								dc.b					0,-2,10,-127,9,0
								dc.b					0,-2,-10,-127,3,0
								dc.l					0
emitterKillA
								dc.b					0,0,-1,-70,3,0
								dc.b					-1,1,0,-75,7,0
								dc.b					0,-2,-3,64,5,0
								dc.b					-1,-1,-5,-20,2,0
								dc.b					-1,-4,-10,70,3,0
								dc.b					0,4,5,-50,3,0
								dc.b					2,4,-5,38,4,0
								dc.b					3,5,10,-40,5,0
								dc.b					-3,-5,-20,-50,4,0
								dc.b					2,3,10,-50,3,0
								dc.b					-2,-3,10,50,3,0
								dc.b					-4,7,10,40,3,0
								dc.b					4,-7,10,60,3,0
								dc.b					-1,0,-10,73,3,0
								dc.b					1,0,-10,66,3,0
								dc.b					0,-2,10,78,5,0
								dc.b					0,-2,10,-63,4,0
								dc.b					0,-2,-10,-75,1,0
								dc.l					0
emitterKillB
								dc.b					-3,-4,-1,-60,1,0
								dc.b					0,-2,10,60,4,0
								dc.b					0,-2,10,-87,3,0
								dc.l					0
								dc.b					0,-2,-10,-77,1,0
								dc.b					-1,1,0,-60,3,0
								dc.b					0,-2,-3,50,2,0
								dc.b					-2,-3,10,40,2,0
								dc.b					-4,7,0,45,2,0
								dc.b					4,-7,-10,33,2,0
								dc.b					-1,-1,-5,-20,1,0
								dc.b					2,4,-5,30,3,0
								dc.b					3,5,10,-30,4,0
								dc.b					-3,-5,-20,-20,3,0
								dc.b					-1,-4,-10,30,2,0
								dc.b					0,4,5,-35,2,0
								dc.b					2,3,10,-31,2,0
								dc.b					-1,0,-10,30,4,0
								dc.b					1,0,-10,50,5,0
								dc.l					0
emitterKillC
								dc.b					3,4,15,-70,1,0
								dc.b					-3,-5,-20,30,3,0
								dc.b					-1,-4,-10,40,2,0
								dc.b					0,4,5,-40,2,0
								dc.b					2,4,-5,40,3,0
								dc.b					3,5,10,-50,4,0
								dc.b					-1,1,0,-66,3,0
								dc.b					0,-2,-3,56,2,0
								dc.b					-2,-3,10,45,2,0
								dc.b					-4,7,0,39,2,0
								dc.b					4,-7,-10,53,2,0
								dc.b					-1,-1,-5,-25,1,0
								dc.b					2,3,10,-40,2,0
								dc.b					-1,0,-10,50,4,0
								dc.b					1,0,-10,55,5,0
								dc.b					0,-2,10,65,4,0
								dc.b					0,-2,10,-85,3,0
								dc.b					0,-2,-10,-67,1,0
								dc.l					0
emitterHitA
								dc.b					-2,-2,1,-70,4,0
								dc.b					-3,-2,-4,-20,7,0
								dc.b					-3,-2,10,-10,8,0
								dc.b					1,2,-20,4,6,0
								dc.b					0,3,14,32,4,0
								dc.l					0
emitterHitB
								dc.b					-4,-4,-4,-85,4,0
								dc.b					-5,-2,9,-20,7,0
								dc.b					-2,-1,10,-21,9,0
								dc.b					1,3,-30,-17,8,0
								dc.b					0,4,2,19,5,0
								dc.l					0
emitterMetShower
								dc.b					-10,-10,-10,50,5,0
								dc.b					2,4,10,30,3,0
								dc.b					3,7,-2,14,4,0
								dc.b					5,3,-10,12,7,0
								dc.b					6,5,20,50,2,0
								dc.b					3,5,10,-40,4,0
								dc.b					-1,1,0,-70,3,0
								dc.b					0,-2,-3,35,4,0
								dc.b					-2,-3,10,50,6,0
								dc.b					-4,7,0,20,4,0
								dc.b					4,-7,-10,33,7,0
								dc.b					-1,-1,-5,-30,3,0
								dc.b					2,3,10,-50,2,0
								dc.b					-1,0,-10,60,1,0
								dc.b					1,0,-10,70,5,0
								dc.b					0,-2,10,65,7,0
								dc.b					0,-2,10,-77,4,0
								dc.b					0,-2,-10,-57,3,0
								dc.l					0

								RSRESET
partXPos						rs.w					1
partYPos						rs.w					1
partXAccl						rs.w					1
partYAccl						rs.w					1
partLifetime					rs.b					1
partLifeCntdwn					rs.b					1
partEntrySize					rs.w					1


particlesMaxNo				=	32
particleBits
								dc.b					%11000000,%00100000, %00110000,%00010000, %00001100,%00000110,%00000011, %00000001
particleBitmapOffset
								dc.w					mainPlaneWidth*3, mainPlaneWidth*2, mainPlaneWidth*1, mainPlaneWidth*1
particleBase
particleDrawBase
								dc.l					0,0,0
particleClear
								blk.w					particlesMaxNo+1,0
	; particleTable at end of code
particleTable
								blk.b					(particlesMaxNo+1)*partEntrySize,0

ptEnd
; #MARK: PARTICLE MANAGER ENDS


			; MARK: - Score Vars

scoreNew					=	0
scoreAdd					=	4
scoreOld					=	8


score
								dc.l					0																																																											; 4 bytes in bcd-format for 8 digits
								dc.l					0																																																											; 4 add-bytes in bcd-format
								dc.l					0																																																											; old score, needed for comparison
scoreHigh
								dc.l					0
scoreHighStatus
								dc.b					0,0
scoreHighEncoded
								dc.b					"X"
								blk.b					8,0
								dc.b					"X"
scoreHighDelta
								dc.l					0
scoreAdder
								dc.w					0
scoreMultiplier ; 0.w = countdown, 2.b = score multiplier 3.b = old multiplier, 4.l pointer to last successful bullet
								dc.l					0,0
scoreHighSuccessFlag
								dc.b					0
								even



;                                SPRxCTL
 ;                              ---------
  ;        Bits 15-8       The low eight bits of VSTOP
   ;       Bit 7           (Used in attachment)
    ;      Bits 6-3        Unused (make zero)
     ;     Bit 2           The VSTART high bit
      ;    Bit 1           The VSTOP high bit
       ;   Bit 0           The HSTART low bit

; #MARK: - SPRITE MANAGER

spriteManagerPlayer
;	#MARK: sprite player code
								clr.l					d6

								lea						spritePlayerDMA(pc),a0
								movem.l					(a0),d0-d1/a5-a6
								exg.l					d0,a5
								exg.l					d1,a6
								movem.l					d0-d1/a5-a6,(a0)																																																							; switch double buffered dma lists

								lea						copSprite01,a0																																																								; write dma pointers to coplist
								move.l					a5,d0
								move.l					a6,d1
								move					d0,6(a0)
								swap					d0
								move					d0,2(a0)
								move					d1,14(a0)
								swap					d1
								move					d1,10(a0)


								lea						plyBase(pc),a1
								lea						copGamePlyBody,a5

								move.w					plyPosX(a1),d4																																																								; player x-position
	;sub.w plyPosXDyn(a1),d4
								move.w					plyPosYABS(a1),d2																																																							;	y-position
								add						#50,d2
								moveq					#playerBodyHeight,d5
								add.w					d2,d5
								clr.b					d3
								lsl.w					#8,d2																																																										; move vertical start bit 8 in place
								addx.b					d3,d3

								lsl.w					#8,d5																																																										; vertical stop bit 8
								addx.b					d3,d3

								lsr.w					#1,d4																																																										; horizontal start bit 0
								addx.b					d3,d3
								add.b					#$44,d4
								move.b					d4,d2																																																										; make first control word
								move.b					d3,d5																																																										; second control word
								rol						#5,d6																																																										; add 35 & 70 ns pixelcoord
								andi					#%11000,d6
								bset					#7,d6																																																										; attach bit
								or						d6,d5

								move.w					d2,0+2(a5)																																																									; SPRxPOS
								move.w					d5,4+2(a5)																																																									; SPRxCTL
								move.w					d2,8+2(a5)																																																									; SPRxPOS
								move.w					d5,12+2(a5)																																																									; SPRxCTL
								moveq					#1,d6
								sub.b					plyBase+plyFire1AutoB(pc),d6
								seq.b					d6
								ext.w					d6
								move.w					d6,d4
								andi					#(spritePlayerBasicEnd-spritePlayerBasic)/2,d6																																																; add shoot illumination

								lea						spritePlayerBasic(d6),a0																																																					; set pointer to anim frame

								move.w					plyBase+plyPosAcclX(pc),d6
								tst.w					plyBase+plyPosAcclX(pc)
								beq.b					.idle																																																										; moves left or right? No!
								spl.b					d6																																																											; yes - tilt anim
								ext.w					d6
.sprSize						SET						(spritePlayerBasicEnd-spritePlayerBasic)
								andi					#.sprSize,d6
								lea						.sprSize(a0,d6),a0
.idle
								move					frameCount+4(pc),d7
								lsr						#1,d7
								andi					#$07<<1,d7
								move.w					.frameOffsetTable(pc,d7),d1
	;lsl #8,d0
								lea						(a0,d1.w),a0
								move.l					a0,d6

								btst					#1,d7
								bne						.skipEvenFrames
.exhaustOffset					SET						(20*8*2)+4																																																									; ship acceleration  -> exhaust size
								lea						.exhaustOffset(a0),a2
								clr.w					d7
								move.b					plyBase+plyAcclXCap+1(pc),d7
								sub.b					#6,d7
								beq						.skip
								move.w					frameCount+2(pc),d1
								andi.w					#1,d1
								add.b					d7,d1
								move.b					.fireFrame-2(pc,d1.w),d7
.skip
								lsl						#4,d7
								lea						spritePlayerExhaust(pc,d7.w),a1
								movem.l					(a1)+,d1/d2/d3/d4																																																							; 8 lines of pixeldata
								move					#8,d5
								move.b					d1,48(a2)
								lsr.l					d5,d1
								move.b					d1,32(a2)
								lsr.l					d5,d1
								move.b					d1,16(a2)
								lsr						d5,d1
								move.b					d1,(a2)

								move.b					d3,56(a2)
								lsr.l					d5,d3
								move.b					d3,40(a2)
								lsr.l					d5,d3
								move.b					d3,24(a2)
								lsr						d5,d3
								move.b					d3,8(a2)

	;lea (28*16)+0(a2),a2
								move.b					d2,112(a2)
								lsr.l					d5,d2
								move.b					d2,96(a2)
								lsr.l					d5,d2
								move.b					d2,80(a2)
								lsr						d5,d2
								move.b					d2,64(a2)

								move.b					d4,120(a2)
								lsr.l					d5,d4
								move.b					d4,104(a2)
								lsr.l					d5,d4
								move.b					d4,88(a2)
								lsr						d5,d4
								move.b					d4,72(a2)

.skipEvenFrames


								move.w					d6,16+2(a5)
								swap					d6
								move.w					d6,16+6(a5)


.frameMod						SET						.sprSize/16
.xOffsetLeft					SET						1
.xOffsetRight					SET						5
.bitplaneOffset					SET						8
.lineOffset						SET						16
.testCase						SET						2*.lineOffset+.xOffsetLeft
.yOffset						SET						7
	;btst #0,frameCount+3(pc)
	;beq .keepPos
								move.w					frameCount+2(pc),d2
								btst					#4,d2
								seq						d4
								andi.w					#$9c,d4																																																										; animframe offset

	;clr.l d0
								andi					#$f,d2
								lea						plyBase+plyRemXPos(pc),a2
								movem.w					plyBase+plyPosX(pc),d0
								move.w					d0,(a2,d2.w*2)
								sub						#4,d2																																																										; add visual intertia by fetching xpos with three frames delay
								andi					#$f,d2
								move.w					(a2,d2*2),d1
	;andi #3,d2
								sub.w					d1,d0																																																										; valuerange.w -8 to 8

								asr						#1,d0																																																										; control x-inertia
								add						#4,d0
								move					d0,d2
								smi.b					d1
								cmpi.b					#8,d0
								sge.b					d3																																																											; >8?
								andi.b					#1,d3
								or.b					d3,d1																																																										; create eor modify byte
								ext.w					d1
								and.w					d1,d2
								eor.w					d2,d0																																																										; avoid values <0 and >8

								lea						((.lineOffset*(3+.yOffset))+playerBodyHeight*16,a0),a3
.idleXClr
								lea						spritePlayerContainer,a2

								lea						.restore+.yOffset*4(pc),a4
								clr.w					d7
								tst.w					plyBase+plyPosAcclX(pc)
								beq						.idleXY
								spl						d7
								and.w					#32+16,d7
								add.w					#32+16,d7
.idleXY
								lea						(a4,d7),a4

								move.b					plyBase+plyWeapUpgrade(pc),d7
								spl						d6
								and.b					d6,d7																																																										; player fatal hit? Keep d7 >= 0
								move.b					.offsetTable(pc,d7),d7
								lea						(a2,d7*2),a2																																																								; add upgrade offset
								lea						(a2,d4.w*2),a2																																																								; add animframe offset
								moveq					#11-.yOffset,d7
.clrContrns
								move.w					(a4)+,d6																																																									; fetch ship outlines
								movem.l					(a2)+,d2/d5
								lsl.l					d0,d2
								lsl.l					d0,d5
								or.b					d6,d2
								move.w					d2,.xOffsetLeft+.bitplaneOffset(a3)																																																			; bitplane 0 right, 1.row
								swap					d2
								lsr.w					#8,d6
								or.w					d6,d5
	;move #-1,d5
								move.w					d5,.xOffsetLeft(a3)																																																							; bitplane 1 right, 1.row

								move.w					(a4)+,d6
								move.b					d6,d3
								sf.b					d6
								or.w					d6,d2
								move.w					d2,.xOffsetRight+.bitplaneOffset(a3)																																																		; bitplane 0 right, 1.row
								swap					d5
								lsl						#8,d3
	;lsl #3,d5
								or.w					d3,d5
	;move #-1,d5
								move.w					d5,.xOffsetRight(a3)																																																						; bitplane 1 right, 1.row
								lea						16(a3),a3
								dbra					d7,.clrContrns

								moveq					#.yOffset,d7
.clrContrns1
								movem.l					(a2)+,d4/d5
								lsl.l					d0,d4
								lsl.l					d0,d5
	;move.w d4,.xOffsetLeft+.bitplaneOffset-(2*8*0)(a3)	; bitplane 0 right, 1.row
								move.w					d5,.xOffsetLeft+.bitplaneOffset-(2*8*28)(a3)																																																; bitplane 0 right, 1.row
								move.w					d5,.xOffsetLeft-(2*8*28)(a3)																																																				; bitplane 1 right, 1.row
								move.w					d4,.xOffsetLeft-(2*8*28)(a3)																																																				; bitplane 1 right, 1.row
								swap					d4
								swap					d5

								move.w					d4,.xOffsetRight+.bitplaneOffset-(2*8*28)(a3)																																																; bitplane 0 right, 1.row
								move.w					d5,.xOffsetRight-(2*8*28)(a3)																																																				; bitplane 1 right, 1.row
								move.w					d5,.xOffsetRight-(2*8*28)(a3)																																																				; bitplane 1 right, 1.row
								lea						16(a3),a3
								dbra					d7,.clrContrns1
.keepPos
								bra						.fuk
.fireFrame
								dc.b					3,5,6,7
.offsetTable
								dc.b					0,13*4,26*4,39*4
	;SAVEREGISTERS
.restore	; bitmap data taken from ship_0a.raw, row/byte 496 to 672
								dc.b					1,1,$80,$80
								dc.b					0,1,0,$80
								dc.b					1,1,$80,$80
								dc.b					0,1,0,$80
								dc.b					1,1,$80,$80
								dc.b					3,2,$c0,$40
								dc.b					3,2,$c0,$40
								dc.b					3,2,$c0,$40
								dc.b					3,3,$c0,$c0
								dc.b					3,3,$c0,$c0
								dc.b					3,3,$c0,$c0
								dc.b					1,1,$80,$80
	; bitmap data taken from ship_0b.raw, row/byte 496 to 672
								dc.b					0,0,$80,$40
								dc.b					0,0,$e0,$e0
								dc.b					0,0,$e0,$e0
								dc.b					0,0,$e0,$e0
								dc.b					0,0,$b0,$70
								dc.b					0,0,$d0,$30
								dc.b					0,0,$f8,$18
								dc.b					0,0,$f8,$78
								dc.b					0,0,$d8,$f8
								dc.b					0,0,$e0,$e0
								dc.b					0,0,$c0,$c0
								dc.b					0,0,$c0,$40
	; bitmap data taken from ship_0c.raw, row/byte 496 to 672
								dc.b					1,2,0,0
								dc.b					7,7,0,0
								dc.b					7,7,0,0
								dc.b					7,7,0,0
								dc.b					$d,$e,0,0
								dc.b					$b,$c,0,0
								dc.b					$1f,$18,0,0
								dc.b					$1f,$1e,0,0
								dc.b					$1b,$1f,0,0
								dc.b					7,7,0,0
								dc.b					3,3,0,0
								dc.b					3,2,0,0

.fuk


								lea						(playerBodyHeight*16,a0),a0
								move.l					a0,d0
								move.w					d0,16+10(a5)
								swap					d0
								move.w					d0,16+14(a5)
								lea						copSplitList(pc),a0
								move.l					(a0)+,a1																																																									; get pointer to offset table

								move.w					(a0),d6																																																										; no of lines
								sub						#1,d6
								beq						sprManPlyReturn

								move.l					(a1)+,a2																																																									; get adress of current subcoplist -> pointer to BPLCON1
								lea						-16(a2),a2
								lea						plySprSaveCop(pc),a5
								lea						copGamePlyBodyRestore,a4
								lea						copGamePlyBodyReturn+2,a6
								movem.l					(a5),a0/d0-d2
								tst.l					a0
								beq						.firstRun
								movem.l					d0-d2,(a0)
.firstRun
								moveq					#3,d7																																																										; y-offset playerpos / rastersplit
								add.w					plyBase+plyPosYABS(pc),d7																																																					; get scanline
								lsr						#1,d7
								cmp						d6,d7
								blo						.yPosOK
								move					d6,d7
.yPosOK
								move.w					(a1,d7*2),d7																																																								; pointer to entry in coplist
								lea						2(a2,d7),a2
								tst.b					dialogueIsActive(pc)
								bne						.dialogueMod
								tst.b					escalateIsActive(pc)
								bne						.escalateMod
.cont
								movem.l					(a2),d0-d2																																																									; get original entrys
								move.l					a2,12(a5)																																																									; save coplist adress
								movem.l					d0-d2,(a5)																																																									; save entrys
								movem.l					d0-d2,(a4)																																																									; write copied commands to temp coplist

								lea						12(a2),a4
								move.l					a4,d0
								move.w					d0,(a6)
								swap					d0
								move.w					d0,4(a6)																																																									; copjmp bck to original coplist

								move.w					#COPJMP2,(a2)																																																								; write copjmp code -> coplist. Inits copjmp to copGamePlyBody
								bra						sprManPlyReturn
.escalateMod
								cmpi.w					#escalateStart+escalateHeight-50,plyBase+plyPosYABS(pc)																																														; get player y-pos
								bhi						.cont
								cmpi.w					#escalateStart-48,plyBase+plyPosYABS(pc)																																																	; get player y-pos
								bls						.cont
								lea						copGameEscalateSplits,a2
								move.w					plyBase+plyPosYABS(pc),d7
	;lsr #2,d7
								sub.w					#50,d7
								lea						(a2,d7*4),a2
								bra						.cont
.dialogueMod
								cmpi.w					#$42,plyBase+plyPosYABS(pc)																																																					; get player y-pos
								bhi						.cont

								lea						copGameDialogueExit,a2
								moveq					#45,d7
								add.b					plyBase+plyPosYABS+1(pc),d7
								move.b					d7,-4(a2)																																																									; modify copper wait within dialogue view
								bra						.cont
.add							SET						.sprSize/16
.muls							SET						0
.frameOffsetTable
								REPT					8
								dc.w					.muls
.muls							SET						.muls+.add																																																									;player vessel height * 8
								ENDR
plySprSaveCop
								blk.l					4,0

spritePlayerExhaust
								INCBIN					incbin/player/exhaust0
								INCBIN					incbin/player/exhaust1
								INCBIN					incbin/player/exhaust2
								INCBIN					incbin/player/exhaust3
								INCBIN					incbin/player/exhaust4
								INCBIN					incbin/player/exhaust5
								INCBIN					incbin/player/exhaust6
								INCBIN					incbin/player/exhaust7


;	#MARK: general sprite code
spriteManager
								clr.l					d0
								clr.l					d1
								clr.l					d2
								clr.l					d3

								lea						CUSTOM,a6
								lea						spriteWriteLastYPos(pc),a0																																																					; clear for sprites 2-5 -> not 6,7 -> not part of multiplexing code
								movem.l					d0-d3,(a0)

								lea						copSpriteLists(pc),a0
								add.w					#1,32(a0)
								move.w					32(a0),d7
	;lsl #1,d7
								andi					#%11000,d7
								move.l					(a0,d7.w*1),d0
								move.l					d0,36(a0)

								move					d0,copInitSprPtLW
								swap					d0
								move					d0,copInitSprPtHW
								swap					d0
		;move.l d0,36(a0)
								move.l					d0,a1
								move.w					2(a1),d2																																																									; get address of sprite dma memory
								swap					d2
								move.w					6(a1),d2

								lea						spriteDMAListDynOffsets(pc),a0																																																				; reset list of dynamic pointers.w
								move.l					d2,(a0)+
								movem.l					8(a0),d4-d5
								movem.l					d4-d5,(a0)
.sprModifiedFlag=2

								move.l					d2,a6																																																										; get base pointer.l
	;ALERT01 m2,a6
								movem.l					spritePlayerDMA+8(pc),a3/a4																																																					; fetch pointers to sprite 0 / 1 dma (basic shot, xtra shot)
								move					spriteCount(pc),d7
								subq					#1,d7
								bmi.w					.closeDMA

								move.l					spritePosFirst(pc),a1

								IFNE					DEBUGSPRITEPOSMEM
								move.l					spritePosMem(pc),a5
								ALERT01					m2,a5
								lea						spritePosMemSize(a5),a5
								ALERT02					m2,a5
								ALERT03					m2,a1
								move.l					spritePosLast(pc),d6
								ALERT04					m2,d6
								ENDIF

								lea						spriteWriteLastYPos(pc),a5
    ;sub.l a6,a6			; reset dynamic spritedmamem-offset
    ;move frameCount+4(pc),d0
    ;lsr #1,d0
   ; andi #3,d0
								moveq					#0,d0																																																										; reset pointer to sprite-no

		;#MARK: sprite bullets loop
		;
		; a1	pointer sprite chain list
		; a3	pointer player shot dma sprite
		; a5	remember last y stop position+1
		; a6 = target base address
		; d5 	dynamic offset to target
								moveq					#4,d6
								bra.b					.firstEntry
.nextSprite
								adda.w					d6,a1
								tst.w					(a1)
								bne.b					.firstEntry
								adda.w					d6,a1
								tst.w					(a1)
								bne.b					.firstEntry
								adda.w					d6,a1
								tst.w					(a1)
								bne.b					.firstEntry
								adda.w					d6,a1
								tst.w					(a1)
								beq.b					.nextSprite
.firstEntry
								move.l					(a1),d2
								clr.l					(a1)																																																										; clear up sprite list
								move					d2,d4																																																										; x-position in lower word
								move					d2,d1																																																										; prep animjump
								swap					d2																																																											; y-position
								rol						#7,d1																																																										; jump to different animation routines
								andi.w					#$3f<<1,d1
	;move #35<<1,d1

	;jmp .sprBullet8C
								move.w					(.spriteAnimCases.w,pc,d1),d1
.jmp								jmp						.jmp(pc,d1)
.spriteAnimCases
.sc								=						*-2
								dc.w					0,.sprPlyShotA-.sc,.sprPlyShotB-.sc,.sprPlyShotC-.sc,.sprPlyShotD-.sc,.sprPlyShotE-.sc,.sprPlyShotF-.sc
		; sprite 0-6

								dc.w					.sprPlyShotA1-.sc,.sprPlyShotB1-.sc,.sprPlyShotC1-.sc,.sprPlyShotD1-.sc,.sprPlyShotE1-.sc,.sprPlyShotF1-.sc
		; sprite 7-12

								dc.w					.sprPlyShotA2-.sc,.sprPlyShotB2-.sc,.sprPlyShotC2-.sc,.sprPlyShotD2-.sc,.sprPlyShotE2-.sc,.sprPlyShotF2-.sc
		; sprite 13-18

								dc.w					.sprPlyShotA3-.sc,.sprPlyShotB3-.sc,.sprPlyShotC3-.sc,.sprPlyShotD3-.sc,.sprPlyShotE3-.sc,.sprPlyShotF3-.sc
		; sprite 19-24

								dc.w					.sprBonus8A-.sc,.sprBonus8B-.sc,.sprChain8A-.sc,.sprChain8B-.sc																																												;25-28
								dc.w					.bulletBasicX1-.sc,.bulletBasicX2-.sc,.bulletBasic-.sc,.sprBullet8C-.sc																																										;29-32
								dc.w					.sprBullet8B-.sc,.sprBullet8A-.sc,.sprTutSpeedA-.sc,.sprTutSpeedB-.sc																																										;33-36
								dc.w					.sprTutPowerUpA-.sc,.sprTutPowerUpB-.sc,.sprInstSpwn-.sc,.sprAlertA-.sc																																										;37-40
								dc.w					.sprAlertB-.sc,.sprAlertC-.sc																																																				;41,42
								dc.w					.sprAlertD-.sc,.sprAlertE-.sc																																																				;43,44
								dc.w					.sprPause-.sc																																																								;45

	; control player shots


.spritelineMod					SET						spriteLineOffset/2*playerShotHeight
.sprPlyShotF3	; basic shot totally fractured
								lea						spritePlayerShot+.spritelineMod*23(pc),a2
								bra						.sprDrawXtraSht
.sprPlyShotE3
								lea						spritePlayerShot+.spritelineMod*22(pc),a2
								bra						.sprDrawXtraSht
.sprPlyShotD3
								lea						spritePlayerShot+.spritelineMod*21(pc),a2
								bra						.sprDrawXtraSht
.sprPlyShotC3
								lea						spritePlayerShot+.spritelineMod*20(pc),a2
								bra						.sprDrawXtraSht
.sprPlyShotB3
								lea						spritePlayerShot+.spritelineMod*19(pc),a2
								bra						.sprDrawShot
.sprPlyShotA3	; a3 = pointer to sprite 0, a4 = pointer to sprite 1
								lea						spritePlayerShot+.spritelineMod*18(pc),a2
								bra						.sprDrawShot

.sprPlyShotF2	; first fractures
								lea						spritePlayerShot+.spritelineMod*17(pc),a2
								bra						.sprDrawXtraSht
.sprPlyShotE2
								lea						spritePlayerShot+.spritelineMod*16(pc),a2
								bra						.sprDrawXtraSht
.sprPlyShotD2
								lea						spritePlayerShot+.spritelineMod*15(pc),a2
								bra						.sprDrawXtraSht
.sprPlyShotC2
								lea						spritePlayerShot+.spritelineMod*14(pc),a2
								bra						.sprDrawXtraSht
.sprPlyShotB2
								lea						spritePlayerShot+.spritelineMod*13(pc),a2
								bra						.sprDrawShot
.sprPlyShotA2	; a3 = pointer to sprite 0, a4 = pointer to sprite 1
								lea						spritePlayerShot+.spritelineMod*12(pc),a2
								bra						.sprDrawShot


.sprPlyShotF1	; first fractures
								lea						spritePlayerShot+.spritelineMod*11(pc),a2
								bra						.sprDrawXtraSht
.sprPlyShotE1
								lea						spritePlayerShot+.spritelineMod*10(pc),a2
								bra						.sprDrawXtraSht
.sprPlyShotD1
								lea						spritePlayerShot+.spritelineMod*9(pc),a2
								bra						.sprDrawXtraSht
.sprPlyShotC1
								lea						spritePlayerShot+.spritelineMod*8(pc),a2
								bra						.sprDrawXtraSht
.sprPlyShotB1
								lea						spritePlayerShot+.spritelineMod*7(pc),a2
								bra						.sprDrawShot
.sprPlyShotA1	; a3 = pointer to sprite 0, a4 = pointer to sprite 1
								lea						spritePlayerShot+.spritelineMod*6(pc),a2
								bra						.sprDrawShot


.sprPlyShotF	; basic shots
								lea						spritePlayerShot+.spritelineMod*5(pc),a2
								bra						.sprDrawXtraSht
.sprPlyShotE
								lea						spritePlayerShot+.spritelineMod*4(pc),a2
								bra						.sprDrawXtraSht
.sprPlyShotD
								lea						spritePlayerShot+.spritelineMod*3(pc),a2
								bra						.sprDrawXtraSht
.sprPlyShotC	; spread shot right
								lea						spritePlayerShot+.spritelineMod*2(pc),a2
								bra						.sprDrawXtraSht
.sprPlyShotB	; spread shot left
								lea						spritePlayerShot+.spritelineMod(pc),a2
								bra						.sprDrawShot
.sprPlyShotA	; basic shot north. a3 = pointer to sprite 0, a4 = pointer to sprite 1
								lea						spritePlayerShot(pc),a2

.sprDrawShot

    ;    d6= height, d2=y-position, d4 = x-position
;	#MARK: sprite make control words

								move					#-playerShotHeight-1,d3																																																						; check if sprites overlap
								sub.b					-(playerShotHeight+1)*spriteLineOffset(a4),d3
								add						d2,d3																																																										; <0 if overlap
								smi						d3
								sub.w					d3,d2																																																										; +1 to ypos if overlap

.firstSprite

	; optimised sprite write, cope with non-PAL area only
								clr.b					d3
								moveq					#playerShotHeight,d1
								add.w					d2,d1																																																										; y stop position
								lsl.w					#8,d2																																																										; move vertical start bit 8 in place
								addx.b					d3,d3
								lsl.w					#8,d1																																																										; vertical stop bit 8
								addx.b					d3,d3
								lsr.w					#1,d4																																																										; horizontal start bit 0
								addx.b					d3,d3
								add.b					#$30,d4
								move.b					d4,d2																																																										; make first control word
								move.b					d3,d1
								move.w					d2,(a4)																																																										; SPRxPOS
								move.w					d1,8(a4)																																																									; SPRxCTL

.offset							SET						spriteLineOffset

.wrtLine

								movem.l					(a2)+,d1-d4																																																									; get one scanline
								cmp.l					.offset+24(a4),d4
								bne						.drawPixels
								cmp.l					.offset+16(a4),d3
								beq						.keepPixels
.drawPixels
				; write 4 scanlines * 4 times
								IF						1=0
								moveq					#-1,d1
								move.l					d1,d2
								move.l					d2,d3
								move.l					d3,d4
								ENDIF
								move.l					d1,.offset(a4)
								move.l					d2,.offset+8(a4)
								move.l					d3,.offset+16(a4)
								move.l					d4,.offset+24(a4)

								REPT					11
								movem.l					(a2)+,d1-d4
								IF						0=1
								move.l					#$fffff000,d1
								move.l					d1,d2
								move.l					d2,d3
								move.l					d3,d4
								ENDIF
.offset							SET						.offset+spriteLineOffset*2
								move.l					d1,.offset(a4)
								move.l					d2,.offset+8(a4)
								move.l					d3,.offset+16(a4)
								move.l					d4,.offset+24(a4)
								ENDR
								adda.w					#(playerShotHeight+1)*spriteLineOffset,a4
								dbra					d7,.nextSprite
								bra						.closeDMA
.keepPixels
								adda.w					#(playerShotHeight+1)*spriteLineOffset,a4
.endLoopPlyShot
								dbra					d7,.nextSprite
								bra						.closeDMA

.sprDrawXtraSht
    ;  d2=y-position, d4 = x-position
;	#MARK: sprite control words xtra shot


								move					#-playerShotHeight-1,d3																																																						; check if sprites overlap
								sub.b					-(playerShotHeight+1)*spriteLineOffset(a3),d3
								add						d2,d3																																																										; <0 if overlap

								smi						d3
								sub.w					d3,d2																																																										; +1 to ypos if overlap

	; optimised sprite write, cope with non-PAL area only
								clr.b					d3
								moveq					#playerShotHeight,d1
								add.w					d2,d1																																																										; y stop position

								lsl.w					#8,d2																																																										; move vertical start bit 8 in place
								addx.b					d3,d3
								lsl.w					#8,d1																																																										; vertical stop bit 8
								addx.b					d3,d3
								lsr.w					#1,d4																																																										; horizontal start bit 0
								addx.b					d3,d3
								add.b					#$30,d4
								move.b					d4,d2																																																										; make first control word
								move.b					d3,d1
								move.w					d2,(a3)																																																										; SPRxPOS
								move.w					d1,8(a3)																																																									; SPRxCTL

.offset							SET						spriteLineOffset


								movem.l					(a2)+,d1-d4																																																									; get one scanline
								cmp.l					.offset(a3),d1
								beq						.keepPixelsXtra
			;bra .keepPixelsXtra
				; write 4 scanlines * 4 times

								move.l					d1,.offset(a3)
								move.l					d2,.offset+8(a3)
								move.l					d3,.offset+16(a3)
								move.l					d4,.offset+24(a3)

								REPT					11
								movem.l					(a2)+,d1-d4
.offset							SET						.offset+spriteLineOffset*2
								move.l					d1,.offset(a3)
								move.l					d2,.offset+8(a3)
								move.l					d3,.offset+16(a3)
								move.l					d4,.offset+24(a3)
								ENDR
.keepPixelsXtra
								adda.w					#(playerShotHeight+1)*spriteLineOffset,a3
								dbra					d7,.nextSprite
								bra						.closeDMA

	;	#MARK: sprites 8 px height
.coll8Overlap
								btst.b					#0,frameCount+5(pc)
								beq						.endLoop
								move					#spriteLineOffset*(spriteDMAHeight+1),d3
								move					d5,d1																																																										; restore current offset to dma table
								sub.w					d3,d1																																																										; sub one line
								sub.w					d3,d1
								tst.b					.sprModifiedFlag(a6,d1)
								beq						.overwrite4pxSpriteB
								sf.b					.sprModifiedFlag(a6,d5)																																																						; old sprite = 8px, modify pointers
								sub.w					d3,d5
								sub.w					d3,d5
								bra						.skipAddBigg
.overwrite4pxSpriteB
	; 4px sprite has already been stored, replace it with 8px sprite
								sub.w					d3,d5
								add.w					d3,(a0,d0*2)
								bra						.skipAddBigg

.sprPause		; pause message
								lea						spritePause(pc),a2
								bra						.bullet8Draw
.sprInstSpwn		; post kill quick resume sprite
								lea						spriteInstaSpawn(pc),a2
								clr.w					d1
								move.b					plyBase+plyFire1Flag(pc),d1
								tst.w					d1
								beq						.idleAnim
								move.w					d1,d3
								lsr						#3,d1
								lsr						#5,d3
								sub.w					d3,d1
								lsl						#6,d1

								tst.w					transitionFlag(pc)																																																							; cap anim frame number as it would too high with wipe transition
								beq						.instSpwnAnim
								move.w					#19<<6,d1
.instSpwnAnim
								lea						(a2,d1.w),a2
								bra						.bullet8Draw
.idleAnim
								move.w					frameCount+2(pc),d1
								lsl						#4,d1
								andi.w					#%10000000,d1
								bra						.instSpwnAnim
.sprTutSpeedA		; speedup tutorial icon
								lea						spriteTutorial8pixels(pc),a2
								add.w					plyBase+plyPosXDyn(pc),d4																																																					; add x-scroll-offset
								bra.b					.bullet8Draw
.sprTutSpeedB
								lea						spriteTutorial8pixels+64(pc),a2
								add.w					plyBase+plyPosXDyn(pc),d4
								bra.b					.bullet8Draw
.sprTutPowerUpA		; powerup tutorial icon
								lea						spriteTutorial8pixels(pc),a2
								add.w					plyBase+plyPosXDyn(pc),d4
								bra.b					.bullet8Draw
.sprTutPowerUpB
								lea						spriteTutorial8pixels+128(pc),a2
								add.w					plyBase+plyPosXDyn(pc),d4
								bra.b					.bullet8Draw
.sprBullet8A
								lea						spriteBullet8(pc),a2
								bra.b					.bullet8Draw
.sprBullet8B
								lea						spriteBullet8+8*8(pc),a2
								bra.b					.bullet8Draw
.sprBullet8C
	;move frameCount+2(pc),d1
	;add d7,d1	; add some dynamix to animation
								move					d2,d1
								lsr						#2,d1

								andi					#7,d1
								move.l					(spriteAnimTableBullet8,pc,d1*4),a2
								bra.b					.bullet8Draw
.sprBonus8A		; wave bonus
								lea						spriteBonus8pixels(pc),a2
								bra.b					.bullet8Draw
.sprBonus8B
								lea						spriteBonus8pixels+64(pc),a2
								bra.b					.bullet8Draw
.sprAlertA		; alert text sprite
								lea						spriteAlert(pc),a2
								bra.b					.bullet8Draw
.sprAlertB		; alert dart southwards
								lea						spriteAlert+128(pc),a2
								bra.b					.bullet8Draw
.sprAlertC		; alert dart westwards
								lea						spriteAlert+256(pc),a2
								bra.b					.bullet8Draw
.sprAlertD		; alert dart northwards
								lea						spriteAlert+64(pc),a2
								bra.b					.bullet8Draw
.sprAlertE		; alert dart eastwards
								lea						spriteAlert+192(pc),a2
								bra.b					.bullet8Draw

.sprChain8A		; chain bonus
								lea						spriteChain8pixels(pc),a2
								bra.b					.bullet8Draw
.sprChain8B		; chain number, adressed indirectly
								move.l					((spriteAnimTableChain).W,pc),a2
.bullet8Draw
								sub						#2,d2
								addq					#1,d0
								andi					#3,d0																																																										; which sprite slot
								move.w					(a0,d0*2),d5																																																								; get current offset

								cmp.w					(a5,d0*2),d2
								ble						.coll8Overlap
								add.w					#2*(spriteLineOffset*(spriteDMAHeight+1)),(a0,d0*2)
.skipAddBigg
.m								MACRO
.fullFilled						SET						0
								IF						.fullFilled=1																																																								; init for test with full filled sprite
								moveq					#-1,d1
								move.l					d1,d3
								ENDIF
								ENDM
	; draw pixels to dma memory
								movem.l					(a2)+,d1/d3
								.m
								move.l					d1,spriteLineOffset(a6,d5)
								move.l					d3,8+spriteLineOffset(a6,d5)
								movem.l					(a2)+,d1/d3
								.m
								move.l					d1,2*spriteLineOffset(a6,d5)
								move.l					d3,8+(2*spriteLineOffset)(a6,d5)
								movem.l					(a2)+,d1/d3
								.m
								move.l					d1,3*spriteLineOffset(a6,d5)
								move.l					d3,8+(3*spriteLineOffset)(a6,d5)
								movem.l					(a2)+,d1/d3
								.m
								move.l					d1,4*spriteLineOffset(a6,d5)
								move.l					d3,8+(4*spriteLineOffset)(a6,d5)
								movem.l					(a2)+,d1/d3
								.m
								move.l					d1,5*spriteLineOffset(a6,d5)
								move.l					d3,5*spriteLineOffset+8(a6,d5)
								movem.l					(a2)+,d1/d3
								.m
								move.l					d1,6*spriteLineOffset(a6,d5)
								move.l					d3,6*spriteLineOffset+8(a6,d5)
								movem.l					(a2)+,d1/d3
								.m
								move.l					d1,7*spriteLineOffset(a6,d5)
								move.l					d3,7*spriteLineOffset+8(a6,d5)
								movem.l					(a2)+,d1/d3
								.m
								move.l					d1,8*spriteLineOffset(a6,d5)
								move.l					d3,8*spriteLineOffset+8(a6,d5)
								IFEQ					.fullFilled
								clr.l					9*spriteLineOffset(a6,d5)
								clr.l					8+(9*spriteLineOffset)(a6,d5)
								ELSE
								.m
								move.l					d1,9*spriteLineOffset(a6,d5)
								move.l					d3,9*spriteLineOffset+8(a6,d5)
								ENDIF
								st.b					.sprModifiedFlag(a6,d5)																																																						; set modified flag in 2nd spriteslot
								moveq					#9,d1																																																										; modify height
								bra						.makeControlWordsAlt																																																						;bra.b .makeControlWords


;	#MARK: sprites 4 px height
.bulletBasicX1
								st.b					.sprModifiedFlag(a6,d5)
								lea						spriteBullet4Xpixels(pc),a2
								bra						.bulletDraw
.bulletBasicX2
								st.b					.sprModifiedFlag(a6,d5)
								lea						spriteBullet4Xpixels+(spriteBullet4XpixelsSize/2)(pc),a2
								bra						.bulletDraw

.bulletOverlap
								btst.b					#0,frameCount+5(pc)
								beq						.endLoop																																																									; draw new sprite only every 2nd frame, else keep old sprite
								move					#spriteLineOffset*(spriteDMAHeight+1),d3
								move					d5,d1
								sub.w					d3,d1
								sub.w					d3,d1
								tst.b					.sprModifiedFlag(a6,d1)
								bne						.overwriteBigSprite
								sub.w					d3,d5
								bra						.skipAdd
.overwriteBigSprite	; old sprite = 8px, modify pointers
								sf.b					.sprModifiedFlag(a6,d5)
								sub.w					d3,(a0,d0*2)																																																								; modify pointer to next sprite dma init
								sub.w					d3,d5
								sub.w					d3,d5
								bra						.skipAdd

								sub.w					#1*(spriteLineOffset*(spriteDMAHeight+1)),d5
								tst.b					.sprModifiedFlag(a6,d5)
								bpl						.skipAdd
								sub.w					#1*(spriteLineOffset*(spriteDMAHeight+1)),d5
								bra						.skipAdd
.bulletBasic
    ;lea spriteBullet4pixels(pc),a2
								lea						spriteLineOffset(a6),a2
.bulletDraw
								addq					#1,d0
								andi					#3,d0																																																										; which sprite slot
								move.w					(a0,d0*2),d5																																																								; get current offset

								cmp.w					(a5,d0*2),d2
								ble						.bulletOverlap
.shotDraw
								add.w					#spriteLineOffset*(spriteDMAHeight+1),(a0,d0*2)
.skipAdd
								move.l					(a2),d1
								move.l					8(a2),d3																																																									; get one line
	;move.l ,d3
								cmp.l					spriteLineOffset(a6,d5),d1
								bne						.draw
								cmp.l					spriteLineOffset+8(a6,d5),d3
								bne						.draw

								tst.b					.sprModifiedFlag(a6,d5)																																																						; tst modified flag
								beq.b					.makeControlWords
.draw
								move.l					d1,spriteLineOffset(a6,d5)
								move.l					d3,spriteLineOffset+8(a6,d5)

								lea						16(a2),a2
								move.l					(a2),d1
								move.l					8(a2),d3																																																									; get next line
								move.l					d1,2*spriteLineOffset(a6,d5)
								move.l					d3,2*spriteLineOffset+8(a6,d5)
								lea						16(a2),a2

								move.l					(a2),d1
								move.l					8(a2),d3																																																									; get next line
								move.l					d1,3*spriteLineOffset(a6,d5)
								move.l					d3,3*spriteLineOffset+8(a6,d5)
								lea						16(a2),a2

								move.l					(a2),d1
								move.l					8(a2),d3																																																									; get next line
								move.l					d1,4*spriteLineOffset(a6,d5)
								move.l					d3,4*spriteLineOffset+8(a6,d5)
.makeControlWords
    ;    d6 = height, d2=y-position, d4 = x-position
;	#MARK: sprite make control words
								sf						.sprModifiedFlag(a6,d5)
								move					d6,d1
.makeControlWordsAlt
								add.w					d2,d1																																																										; y stop position

								move					d1,(a5,d0*2)																																																								; save y stop for later compare

								clr.b					d3

								lsl.w					#8,d2																																																										; move vertical start bit 8 in place
								addx.b					d3,d3

								lsl.w					#8,d1																																																										; vertical stop bit 8
								addx.b					d3,d3

								lsr.w					#1,d4																																																										; horizontal start bit 0
								addx.b					d3,d3
								add.b					#$30,d4
								move.b					d4,d2																																																										; make first control word
								move.b					d3,d1																																																										; second control word

								move.w					d2,(a6,d5)																																																									; SPRxPOS
								move.w					d1,8(a6,d5)																																																									; SPRxCTL

								IFNE					DEBUG
								move.l					spriteDMAMem+8(pc),d1
								lea						(a6,d5),a2
								cmp.l					d1,a2
								bls						spriteManagerError
								lea						9*spriteLineOffset+8(a6,d5),a2
								cmp.l					d1,a2
								bls						spriteManagerError

								add.l					#spriteDMAMemSize,d1
								lea						(a6,d5),a2
								cmp.l					d1,a2
								bhi						spriteManagerError
								lea						9*spriteLineOffset+8(a6,d5),a2
								cmp.l					d1,a2
								bhi						spriteManagerError
								ENDIF
.endLoop
								dbra					d7,.nextSprite

.closeDMA	; attn: this marks entry point after ply shot draw

								clr.l					(a3)																																																										; close dma channel sprite 0
								clr.l					8(a3)
								clr.l					(a4)																																																										; close dma channel sprite 1
								clr.l					8(a4)

								move.w					#spriteDMAListOffset,d0
								movem.l					(a0),d0-d1
								clr.l					(a6,d0)																																																										; close dma channel sprites 2-5
								clr.l					8(a6,d0)																																																									; close dma channel sprites 2-5
								swap					d0
								clr.l					(a6,d0)
								clr.l					8(a6,d0)																																																									; close dma channel sprites 2-5
								clr.l					(a6,d1)
								clr.l					8(a6,d1)
								swap					d1
								clr.l					(a6,d1)
								clr.l					8(a6,d1)

.quit
								IFNE					DEBUG
								move.l					spritePlayerDMA+16(pc),a5																																																					; check for memory under / overflow in player shots
								cmpa.l					a3,a5																																																										; underflow
								bhi						.overFlow
								cmpa.l					a4,a5
								bhi						.overFlow

								lea						spritePlayerDMASize(a5),a5
								tst.l					a3
								beq						.overflow
								cmpa.l					a3,a5																																																										; overflow
								bls						.overFlow
								tst.l					a4
								beq						.overflow
								cmpa.l					a4,a5
								bls						.overFlow

								move.l					spriteDMAMem+8(pc),a4																																																						; check for memory under / overflow in enemy bullets
								lea						spriteDMAMemSize(a4),a5
								move.w					(a0)+,d6
								cmpi.w					#spriteDMAListOffset*4,d6
								bhi						.overflow
								lea						(a6,d6),a3
								cmpa.l					a3,a4
								bhi						.underflow
								cmpa.l					a3,a5
								bls						.overFlow

								move.w					(a0)+,d6
								cmpi.w					#spriteDMAListOffset*4,d6
								bhi						.overflow
								lea						(a6,d6),a3
								cmpa.l					a3,a4
								bhi						.underflow
								cmpa.l					a3,a5
								bls						.overFlow

								move.w					(a0)+,d6
								cmpi.w					#spriteDMAListOffset*4,d6
								bhi						.overflow
								lea						(a6,d6),a3
								cmpa.l					a3,a4
								bhi						.underflow
								cmpa.l					a3,a5
								bls						.overFlow

								move.w					(a0),d6
								cmpi.w					#spriteDMAListOffset*4,d6
								bhi						.overflow
								lea						(a6,d6),a3
								cmpa.l					a3,a4
								bhi						.underflow
								cmpa.l					a3,a5
								bls						.overFlow
								ENDIF
								rts
								IFNE					DEBUG
.underflow
.overflow
spriteManagerError
								IFNE					SHELLHANDLING
								jsr						shellSpriteDMAMemError
								ENDIF
								QUITNOW
								ENDIF

spriteAnimTableChain
								dc.l					spriteChain8pixels+64

spriteAnimTableBullet8
.tempVal						SET						2*8*8
								REPT					8
								dc.l					spriteBullet8+.tempVal
.tempVal						SET						.tempVal+(8*8)
								Endr

spriteWriteLastYPos
								blk.w					4,0
spriteDMAListDynOffsets	; 4 x store.w for sprite dma pointers. Reset values stored in upper two longwords
								dc.l					0
								dc.w					0,0,0,0
.tempA							SET						(spriteLineOffset*(spriteDMAHeight+1))*1
.tempB							SET						spriteDMAListOffset
								dc.w					.tempA
								REPT					3
.tempA							SET						.tempA+.tempB
								dc.w					.tempA																																																										; setup static source table
								ENDR

								cnop					0,4
spriteBullet8	; export as 32px wide sprites, not attached, no control words. 2 spawn frames, 8 rotate frames
								Incbin					incbin/bullet8
								cnop					0,4

spriteBonus8pixels	; export as 32px wide sprites, 16 px high, not attached, no control words
								Incbin					incbin/collect_wave.raw
								cnop					0,4
spriteChain8pixels	; text "chain" + 4 numbers as sprites, 32 px wide, 40 px high, not attached, no control words
								Incbin					incbin/collect_chain.raw
								cnop					0,4
spriteTutorial8pixels	; save as sprite, 32 px wide, 24 px high, not attached, no control words
								Incbin					incbin/collect_tutorial.raw
spriteInstaSpawn	; save as sprite, 32 px wide, not attached, no control words
								Incbin					incbin/instSpwn.raw
spritePause	; save as sprite, 32 px wide, not attached, no control words
								Incbin					incbin/pause.raw
spriteAlert	; save as sprite, 32 px wide, 16 px high, not attached, no control words. ? Anim frames
								Incbin					incbin/alert.raw

spriteBullet4pixels ; export as 16px wide sprites, not attached, no control words
								INCBIN					incbin/bullet

								cnop					0,4
spriteBullet4Xpixels ; export as 32px wide sprites, not attached, no control words
								Incbin					incbin/bulletSpawn
spriteBullet4XpixelsSize	=	*-spriteBullet4Xpixels

spritePlayerShot	; export as 32px sprites, not attached, no control
								Incbin					incbin/player/weapon.raw
;    Incbin incbin/player/weapons_0a.raw
spritePlayerShotEnd
;	#MARK: SPRITE MANAGER ENDS

font	;  save font using PICCON, Imageformat "SNES modes",2-bit characters, no redundancy. This packs each char into a set of 8 consecutive bytes
								INCBIN					incbin/font.raw
fontEnd


			; MARK:  - PLAYER DEFINITIONS
								RSRESET
plyPosX							rs.l					1
plyPosY							rs.l					1
plyPosAcclX						rs.w					1
plyPosAcclY						rs.w					1
plyAcclXABS						rs.w					1
plyAcclYABS						rs.w					1
plyInitiated					rs.w					1
plyCollided						rs.w					1
plyShotCnt						rs.b					1
plyFire1Auto					rs.b					1
plyFire1Flag					rs.b					1
plyFire1Hold					rs.b					1
plyDistortionMode				rs.b					1
plyExitReached					rs.b					1
plyWeapUpgrade					rs.b					1
plyWeapSwitchFlag				rs.b					1
plyAVAIL						rs.b					1
plyAVAILB						rs.b					1
plyAcclXCap						rs.w					1
plyAcclYCap						rs.w					1
plyPosXDyn						rs.w					1
plyviewLeftClip					rs.w					1
plyviewRightClip				rs.w					1
plyJoyCode						rs.w					4
plyDiffBulletDelta				rs.w					1
plyPosYABS						rs.w					1
plyShotsFired					rs.w					1
plyShotsHitObject				rs.w					1
plyWaveBonus					rs.w					1
plyHitShotRatio					rs.w					1
plyBossBonus					rs.w					1
plyRemXPos						rs.w					16
plyCheatEnabled					rs.b					1
plyFire1AutoB					rs.b					1
plyAcclXMin					=	$6
plyAcclYMin					=	$6
plyWeapUpgrMax					SET						2

plyBase
plyPos
								blk.l					(plyFire1AutoB/4)+1,0



; #MARK: - SCREENMANAGER BEGINS

	; #MARK: screenmanagerlv0

screenManagerLv0
								move.l					spriteParallaxBuffer+8(pc),a1
								move.l					copSPR6PTH(pc),a5
								tst.l					a5
								beq						setVFXPointers
								move.w					viewPosition+viewPositionPointer(pc),d0

								move					d0,d1
								lsr						#1,d1
								sub						d1,d0
	;lsr #1,d0
								andi					#$ff,d0
								lsl						#4,d0

								lea						(a1,d0),a1
								move.l					a1,d1
								move.w					d1,2(a5)
								swap					d1
								move.w					d1,6(a5)																																																									; write sprite scroller source adress
	;clr.l d0

								bra						setVFX


	; #MARK: screenmanagerlv4

screenManagerLv4
								move.l					spriteParallaxBuffer+8(pc),a1
								move.l					copSPR6PTH(pc),a5
								tst.l					a5
								beq						setVFX
;Mmove.w viewPositionPointer(a3),d0
								move.w					vfxPosition(a3),d0
	;move d0,d1
								lsr						#5,d0
	;sub d1,d0
	;lsl #1,d0
								andi					#$ff,d0
								lsl						#4,d0
								lea						(a1,d0),a1
								move.l					a1,d1
								move.w					d1,2(a5)
								swap					d1
								move.w					d1,6(a5)																																																									; write sprite scroller source adress

								move.l					spriteParallaxBuffer+4(pc),a1
	;move.w viewPositionPointer(a3),d0
	;lsr #2,d0
	;move d0,d1
	;lsr #2,d1
	;sub d1,d0
	;andi #$ff,d0
	;lsl #4,d0
								lea						(a1,d0),a1
								move.l					a1,d1
								move.w					d1,2+8(a5)
								swap					d1
								move.w					d1,6+8(a5)																																																									; write sprite scroller source adress

setVFX
								move.l					fxPlanePointer+4(pc),d0
								clr.l					d7
								move.w					vfxPosition(a3),d7
								sub.w					vfxPositionAdd(a3),d7
								move.w					d7,vfxPosition(a3)
								andi.w					#$ff<<3,d7
								move.w					d7,d5
								lsl.w					#2,d7
								add.w					d5,d7																																																										; muls #40
								add.l					d7,d0																																																										; set vfx bitplane
								bra						screenManager

	; #MARK: screenmanagerlv5
screenManagerLv5
								bra						setVFX

	; #MARK: screenmanagerlv1
screenManagerLv1

								move.l					copSPR6PTH(pc),a5
								tst.l					a5
								beq						setVFXPointers
								move.l					spriteParallaxBuffer+8(pc),a1
								move.w					viewPosition+vfxPosition(pc),d0
	;lsr #3,d5
	;move.w viewPosition+viewPositionPointer(pc),d0
								lsr						#4,d0
								move					d0,d1
	;lsr #1,d0
								lsr						#1,d1
								sub						d1,d0
								andi					#$7f,d0
								lsl						#4,d0
								lea						(a1,d0),a1
								move.l					a1,d0
								move.w					d0,2(a5)
								move.w					d0,2+8(a5)
								swap					d0
								move.w					d0,6(a5)																																																									; write sprite scroller source adress
								move.w					d0,6+8(a5)																																																									; write sprite scroller source adress

								bra						setVFX


	; #MARK: screenmanagerlv2

screenManagerLv2
								move.l					spriteParallaxBuffer+8(pc),a1
								move.l					copSPR6PTH(pc),a5
								tst.l					a5
								beq						setVFXPointers

								move.w					vfxPosition(a3),d0
								move					d0,d1
								lsr						#3,d0
								andi					#$ff,d0
								lsl						#4,d0
								lea						(a1,d0),a1
								move.l					a1,d1
								move.w					d1,2(a5)
								swap					d1
								move.w					d1,6(a5)																																																									; write sprite scroller source adress
								bra						screenManagerVerticalSplit

; #MARK: screenmanagerlv3
screenManagerLv3


								move.l					spriteParallaxBuffer+8(pc),a1
								move.l					copSPR6PTH(pc),a5
								tst.l					a5
								beq						setVFXPointers
								move.w					viewPosition+viewPositionPointer(pc),d0

								move.w					vfxPosition(a3),d0
	;move.w viewPositionPointer(a3),d0
	;MSG02 m2,d0
	;move d0,d2
	;lsr #2,d2
	;and.w #$ff<<1,d2	; (s)lowest sprite layer

								move.w					d0,d1
								lsr						#3,d0
								lsr						#4,d1
								add.w					d1,d0																																																										; sync sprite-based floor scrolling to vfx scroller
	;add d1,d0	; middle sprite layer
								and.w					#$ff<<1,d0
								lea						(a1,d0*8),a1
								move.l					a1,d1
								move.w					d1,2(a5)
								swap					d1
								move.w					d1,6(a5)																																																									; write sprite scroller source adress

								move.w					vfxPosition(a3),d7
								sub.w					vfxPositionAdd(a3),d7
								move.w					d7,vfxPosition(a3)

								clr.w					d5

								move.w					frameCount+2(pc),d4
								asr						#3,d4
								andi					#$ff,d4

								andi					#$7f,d4
								move.b					sineTable(pc,d4.w),d5
								clr.w					d3
								move.w					#$100,d6
								sub.w					plyBase+plyPosX(pc),d6
								add.w					d6,d5
								lsr						#4,d5
								addx.b					d3,d3																																																										; 70ns x-pos (1/2 pixel)
								lsl						#3,d3
								lsr						#1,d5
								addx.b					d3,d3																																																										; 140ns x-pos (1 pixel)
								add.b					#$85,d5
								move.b					d5,19(a5)																																																									; write SPR6POS x-coord
								move.b					d3,4+19(a5)																																																									; write SPR6POS x-coord
								lea						copSpr6pos(pc),a4
								moveq					#2,d7
.loop
								move.l					(a4)+,a5
	;move #2,d6
								add.b					#6,d4
								andi.b					#$7f,d4
								move.b					sineTable(pc,d4.w),d5
								add.w					d6,d5
								lsr						#4,d5
								addx.b					d3,d3
								lsl						#3,d3
								lsr						#1,d5
								addx.b					d3,d3
								add.b					#$85,d5
								move.b					d5,3(a5)
								move.b					d3,7(a5)
								dbra					d7,.loop

screenManagerVerticalSplit

	; take care of lower view

								move.l					fxPlanePointer+4(pc),d0
								move.l					d0,d3
								clr.l					d7
								move.w					#127*40,d7
								add.l					d7,d0

								move.w					vfxPosition(a3),d7
								move.l					d7,d4
								clr.l					d6
								ror.l					#5,d7																																																										; set speed of anim
								smi						d6
								andi.w					#$01,d6
								move.w					mulsThis(pc,d6.w*2),d6
								sub.l					d6,d0																																																										; add scrolling to smoothen animation
								andi.w					#7,d7
								move.w					mulsThisXtr(pc,d7*2),d7
								add.l					d7,d0
screenManagerMirrorView
								move.l					bpl2modReversal(pc),a5
								clr.l					d7
								move.w					#fxPlaneWidth*1024,d7
								move					#fxPlaneDepth-3,d6
.setVFXPointers
								move					d0,4(a5)
								swap					d0
								move					d0,(a5)																																																										; update startadress of secondary plane
								lea						8(a5),a5
								swap					d0
								add.l					d7,d0
								dbra					d6,.setVFXPointers
								move					d0,4(a5)
								swap					d0
								move					d0,(a5)

	; take care of upper view

								move.l					d3,d0
								move.l					d4,d7
								ror.l					#5,d7																																																										; set speed of anim (needs to be 1 for desert, 3 for nautica stage)
								smi						d6
								andi.w					#$01,d6
								moveq					#0,d1

								add.w					mulsThis(pc,d6*2),d1

								add.l					d1,d0																																																										; add scrolling to smoothen animation
								neg						d7
								andi.l					#7,d7
								move.w					mod2(pc,d7*2),d7
								lsl.l					#2,d7																																																										; *4
								lsl.l					#5,d7																																																										;*128
								add.l					d7,d0

								clr.l					d7
								move.w					#fxPlaneWidth*1024,d7
								lea						copBPLPT+10,a5
								move					#fxPlaneDepth-3,d6
.setVFXPointersB
								move					d0,4(a5)
								swap					d0
								move					d0,(a5)																																																										; update startadress of secondary plane
								lea						16(a5),a5
								swap					d0
								add.l					d7,d0
								dbra					d6,.setVFXPointersB
								move					d0,4(a5)
								swap					d0
								move					d0,(a5)

								clr.l					d7
								move.w					vfxPosition(a3),d7
								sub.w					vfxPositionAdd(a3),d7
								move.w					d7,vfxPosition(a3)

								bra						smSkipVfxWrite
		;#FIXME: optimize code please. setVFX doubled a few times?
mulsThis
								dc.w					0,120
mulsThisXtr
								dc.w					0,40*128,40*128*2,40*128*3
								dc.w					40*128*4,40*128*5,40*128*6,40*128*7
mod2
								dc.w					240,280,0,40,80,120,160,200

_smEscalUpdateBPLPT
								pea						smEscalRet(pc)
smEscalUpdateBPLPT
								lea						copBPLPT+(8*6),a1
								move.w					2(a1),d1
								swap					d1
								move.w					6(a1),d1
.add							SET						(mainPlaneWidth*4*(escalateStart+escalateHeight-displayWindowStart-0))
								add.l					#.add,d1

								lea						copGameEscExitBPLPT+34,a1
								move					d1,4(a1)
								swap					d1
								move					d1,(a1)
								rts

setVFXPointers
								move.l					fxPlanePointer+4(pc),d0
								clr.l					d7
								move.w					frameCount+2(pc),d7
								add.w					frameCount(pc),d7
								add						#1,d7
								neg.b					d7
								rol.l					#2,d7
								sub.b					d5,d7																																																										; vfx playfield - speed of scrolling
								andi.w					#$ff,d7

								move.w					d7,d5
								lsl.w					#5,d7
								lsl.w					#3,d5
								add.w					d5,d7
								add.l					d7,d0																																																										; set vfx bitplane
; #MARK: screenmanager main

screenManager

;FIXME: Do two subcoplists with bplpt make sense? Probably not!

; write bplpt pointer visual plane to copsublist. Mainplane is written in blittermanager

								lea						copBPLPT+10,a5
								clr.l					d7
								move.w					#fxPlaneWidth*fxplaneHeight,d7
								move					#fxPlaneDepth-2,d6
.setVFXPointers
								move					d0,4(a5)
								swap					d0
								move					d0,(a5)																																																										; update startadress of secondary plane
								lea						16(a5),a5
								swap					d0
								add.l					d7,d0
								dbra					d6,.setVFXPointers
								move					d0,4(a5)
								swap					d0
								move					d0,(a5)

smSkipVfxWrite
tileRenderer
	; incase of escalation -> update bplpt7 @escal coplist
								tst.b					escalateIsActive(pc)
								bne						_smEscalUpdateBPLPT
smEscalRet

								lea						copBPLPT+(8*6),a1
								move.w					2(a1),d1
								swap					d1
								move.w					6(a1),d1
.add							SET						(mainPlaneWidth*4*(escalateStart+escalateHeight-displayWindowStart-0))
								add.l					#.add,d1

								lea						copGameEscExitBPLPT+34,a1
								move					d1,4(a1)
								swap					d1
								move					d1,(a1)


								clr.l					d1
								clr.l					d2
								clr.l					d3
								clr.l					d5

								IF						1=0
								move.l					viewPositionPointer(a3),d1
								swap					d1
								andi					#$ff,d1
								ALERT03					m2,d1
								ENDIF

    ;clr d1
    ;swap d1             ; d1 = add to mainPlane-pointer
	;move d1,d4		; save for later compare


;tileRenderer
								move.l					tilemapConverted(pc),a0
								move.w					viewPositionPointer(a3),d7																																																					; calc pointer to tilemapConverted

								clr.w					d0																																																											; scroll offset modifier
								tst.l					viewPositionAdd(a3)
								beq						tilePointerModified																																																							; scroll northwards?
								bpl						modifyTilePointer
tilePointerModified
								move					tileMapWidth(pc),d2
								lsr						#5,d7
								move					d7,d2
								lsl						#3,d7
								add						d2,d7																																																										; muls 9
								adda.w					d7,a0																																																										; source tile         ;

								lea						mainPlanes(pc),a1
								lea						mainPlanesPointer(pc),a6

								movem.l					(a1),d5-d7
								tst.b					blitterManagerFinished(pc)
								beq						.swapGfxBuffers
								exg.l					d5,d7
								exg.l					d6,d7
								movem.l					d5-d7,(a1)
.swapGfxBuffers
								move.b					viewPositionPointer+1(a3),d3
								move.w					AddressOfYPosTable(pc,d3*2),d1
								move.l					d5,a1
								move.l					d6,a2
								move.l					d7,a4
								add.l					d1,d6																																																										; d6 = mainplanePointer+4
								add.l					d1,d5
								add.l					d1,d7
								movem.l					d5-d7,(a6)

								bclr					#0,d3																																																										; modify mainPlanePointer for use in tile drawing code
								add.w					d0,d3
	;sub #4,d3
								andi.w					#$fe,d3
								move.w					AddressOfYPosTable(pc,d3*2),d1
								lea						(a1,d1.l),a1
								lea						(a2,d1.l),a2
								lea						(a4,d1.l),a4
								clr.l					d1



	;cmpi.w #1,frameCount+6(pc)
	;bgt screenManagerSmoothScroll	; if framerate >50 fps, scale y-scroll value
smoothScrollRet
								lea						plyBase(pc),a5

								tst						plyCollided(a5)																																																								; ply death seq running? Do not modify x-scrolling
								bne						.noHorzScrolling
								move					#240,d7																																																										; x-scrolling based on ply x-position
								sub						plyPosX(a5),d7
								clr.w					d5
								move.b					killShakeIsActive(pc),d5
								bne						.addKillShakeX
.retKillShakeX
								move					d7,d5
								lsl						#2,d7
								add						d5,d7
								asr						#3,d7

								move.w					scrollXbitsTable(pc,d7*2),d1
								move					d1,copBPLCON1+2

								asr						#2,d7
								move					d7,plyPosXDyn(a5)
								not						d7
								move					d7,d1
								add						#viewRightClip,d7
								add						#viewLeftClip,d1
								movem.w					d1/d7,plyviewLeftClip(a5)																																																					; dynamically modify left / right clipping
.noHorzScrolling

	;tst.l viewPositionAdd(a3)
	;beq screenManagerNil	; skip tile update if screen don´t scroll
	;bra irqRetScreenManager

; #MARK: screenmanager tiledrawing

								clr.l					d7
								moveq					#9,d1
.drawTileOffset=(mainPlaneWidth-tileWidth/8)+4
								lea						.drawTileOffset,a3
								moveq					#(tileHeight/2)-1,d6
								clr.l					d5																																																											; read tile

	; a1/a2/a4 contain mainPlanes pointer

								move					viewPosition+viewPositionPointer(pc),d6
								andi					#$1e,d6
								lsl						#4,d6																																																										; line offset within tile
.tileMemSize					=						(tileHeight-1)*tileWidth/2

								move.w					#.tileMemSize,d4
								sub						d6,d4
								move					d6,d4
		;eor.w #$1f0,d4
								move.l					tileSource(pc),a6
	;lea $130280,a6
								moveq					#$5,d5
								ror.w					#3,d5																																																										; (mainPlaneWidth*mainPlaneDepth)*256 = $a000
								move.l					#$0f0f0f0f,d6
								moveq					#8,d7
.getTile
								move.b					(a0)+,d0
								bmi						.mirrorVertical																																																								; mirror on y-axis
								move.w					d4,d2

								btst					#6,d0																																																										; flip on x-axis
								sne						d1
								ext.w					d1
								andi					#$1f0,d1
								eor.w					d1,d2																																																										; set source adress
								andi.b					#-$20,d1
								add.b					#$10,d1
								extb.l					d1																																																											; extend .b to .l
								move.l					d1,-(sp)																																																									; set offset
								andi					#$3f,d0

								moveq					#9,d3
								lsl.w					d3,d0																																																										; modulus between each tile: 512.b
								lea						(a6,d0.w),a5																																																								; tile source base
								lea						(a5,d2.w),a5																																																								; add yoffset to source base

								REPT					2
								movem.l					(a5),d0-d3																																																									; load one line of one tile
								add.l					(sp),a5

								move.l					d0,(a1)																																																										; draw first bitmap to three framebuffers, main view
								move.l					d0,(a1,d5.l)																																																								; secondary view
								add.l					a3,a1
								move.l					d0,(a2)
								move.l					d0,(a2,d5.l)
								add.l					a3,a2
								move.l					d0,(a4)
								move.l					d0,(a4,d5.l)
								add.l					a3,a4

								move.l					d1,(a1)																																																										; draw scnd bitmap to three framebuffers
								move.l					d1,(a1,d5.l)
								add.l					a3,a1
								move.l					d1,(a2)
								move.l					d1,(a2,d5.l)
								add.l					a3,a2
								move.l					d1,(a4)
								move.l					d1,(a4,d5.l)
								add.l					a3,a4

								move.l					d2,(a1)																																																										; ....
								move.l					d2,(a1,d5.l)
								add.l					a3,a1
								move.l					d2,(a2)
								move.l					d2,(a2,d5.l)
								add.l					a3,a2
								move.l					d2,(a4)
								move.l					d2,(a4,d5.l)
								add.l					a3,a4

								move.l					d3,(a1)
								move.l					d3,(a1,d5.l)
								add.l					a3,a1
								move.l					d3,(a2)
								move.l					d3,(a2,d5.l)
								add.l					a3,a2
								move.l					d3,(a4)
								move.l					d3,(a4,d5.l)
								add.l					a3,a4
								ENDR


.offset							SET						-(.drawTileOffset*8)+4																																																						; even appearance of tiles
;.offset	SET 4	; uneven appearance
								lea						.offset(a1),a1
								lea						.offset(a2),a2
								lea						.offset(a4),a4
								move.l					(sp)+,d0
								dbra					d7,.getTile
								rts
.mirrorVertical
								move					d4,d2
								clr.l					d5

								btst					#6,d0
								sne						d5
								ext.w					d5
								andi.w					#$1f0,d5																																																									; set source address
								eor.w					d5,d2																																																										; reverse read order
								andi.w					#$20,d5
								move.l					d5,-(sp)																																																									; set offset

								andi					#$3f,d0
								moveq					#9,d1
								lsl.w					d1,d0																																																										; modulus between each tile: 512.b
								lea						(a6,d0.w),a5																																																								; tile source base
								lea						(a5,d2),a5																																																									; add yoffset to source base

								move.w					#(mainPlaneWidth*mainPlaneDepth)*256,d5
.draw
								move.l					#$55555555,d3
								move.l					#$33333333,d2
								swap					d7
								move					#1,d7
.drawTwoLinesMirrored
								REPT					4
								move.l					(a5)+,d0
								move.l					d3,d1
								and.l					d0,d1
								eor.l					d1,d0
								add.l					d1,d1
								lsr.l					#1,d0
								or.l					d1,d0

								move.l					d2,d1
								and.l					d0,d1
								eor.l					d1,d0
								lsl.l					#2,d1
								lsr.l					#2,d0
								or.l					d1,d0

								move.l					d6,d1
								and.l					d0,d1
								eor.l					d1,d0
								lsl.l					#4,d1
								lsr.l					#4,d0
								or.l					d1,d0

								rol.w					#8,d0
								swap					d0
								rol.w					#8,d0

								move.l					d0,(a1)
								move.l					d0,(a1,d5.l)
								add.l					a3,a1
								move.l					d0,(a2)
								move.l					d0,(a2,d5.l)
								add.l					a3,a2
								move.l					d0,(a4)
								move.l					d0,(a4,d5.l)
								add.l					a3,a4
								ENDR
								sub.l					(sp),a5
								dbra					d7,.drawTwoLinesMirrored
								swap					d7

.offset							SET						-(.drawTileOffset*8)+4																																																						; even appearance
;.offset	SET 4	; uneven appearance
								lea						.offset(a1),a1
								lea						.offset(a2),a2
								lea						.offset(a4),a4

								move.l					(sp)+,d0
								dbra					d7,.getTile
								rts
.addKillShakeX
								lea						killShakeIsActive(pc),a3
								sub.b					#1,(a3)
								move.b					.killShakeX(pc,d5.w),d5
	;lsr #2,d5
								ext.w					d5
								add.w					d5,d7
								bra						.retKillShakeX
.killShakeX
								dc.b					0,1,-1,1,-2,3,-4,5
modifyTilePointer
								move.w					#-1,d0
								add.w					#256,d7
								bra						tilePointerModified
screenManagerNil
								rts
	; scrolling bits predefined
scrollXbitsTable
.scrollCode						SET						0
.temp							SET						0
								REPT					256
;.scrollCode	SET	((.temp&$3c)>>2)|((.temp&$00)<<8)|((.temp&$c0)<<4)	; temp solution not using 1/4 pixel scrolling

.scrollCode						SET						((.temp&$3c)>>2)|((.temp&$03)<<8)|((.temp&$c0)<<4)																																															; this works on real hardware

;.scrollCode	SET	((.temp&$00)>>2)|(((.temp+0)&%00)<<8)|((.temp&$c)<<8)	; this works on emulation
								dc.w					.scrollCode
.temp							SET						.temp+1
								ENDR


; #MARK: SCREENMANAGER ENDS -


;	#MARK: - SPRITE PARALLAX MANAGER
ParallaxManager        ; handles building of background layer. d0 = no. of map mixed into basic layer. Max. 15 maps
    ; set parallax sprite colors
   ; SAFECOPPER	; take care that copper doesnt change colorreg offset

								move.l					#parallaxSpriteA,d1																																																							; load and prepare parallax sprite data (saved as 64 pixel sprite no ctrl bytes, A = 512 pixels height, B=384 pixels height). filename: parSpritex
								move.l					spriteParallaxBuffer+4(pc),d2
								move.l					#spriteParallaxBufferSize/2,d3
								bsr						createFilePathOnStage
								jsr						loadFile
								tst.l					d0
								beq						errorDisk																																																									;

								move.l					#parallaxSpriteB,d1																																																							; load and prepare parallax sprite data (saved as 64 pixel sprite with ctrl bytes, spriteParallaxHeight-1 = 241). filename: parSpritex
								move.l					spriteParallaxBuffer+8(pc),d2
								move.l					#spriteParallaxBufferSize/2,d3
   	;move.l #100,fd3
								bsr						createFilePathOnStage
								bsr						loadFile
								tst.l					d0
								beq						errorDisk
								rts


	; #MARK:  - Key game vars


    ; #MARK: - viewPosition AND FRAMECOMPARE VARS


								RSRESET
viewPositionScrollspeed			rs.l					1
viewPositionAdd					rs.l					1
viewPositionPointer				rs.l					1
vPyAccConvertWorldToView		rs.w					1
viewPositionPointerLaunchBuf	rs.w					1
vfxPosition						rs.w					1
vfxPositionAdd					rs.w					1
vfxAnimSpeed					rs.w					1
viewPosition
								blk.l					6,0																																																											;2.longword = scrolldirection 3.word = y-pointer, 3.w store
	; #MARK:  - TILE STORAGE
tileDefs
tilemapConvertedSize			dc.w					0
tilemapBckConvertedSize			dc.w					0
tilemapHeight					dc.w					0
tileMapWidth					dc.w					0
tilemapBckHeight				dc.w					0
tilemapBckWidth					dc.w					0
tilemapBckNoMaps				dc.w					0,-1



	; #MARK:  - OBJECT COUNTERS
								cnop					0,4																																																											; align on quad adress
vars
	; #MARK:  - Key Game Vars



gameStatus
								dc.b					0
optionStatus
								dc.b					0
loadedLevelStatus
								dc.b					0
gameInActionF	; bit0=runIntcodeFlag; bit1=pauseModeFlag
								dc.b					0
gameStatusLevel
								dc.w					0

	; #MARK:  - Blitter control vars - reset each game
blitterManagerFinished
								dc.b					0
blitterManagerLaunch
								dc.b					0
								even

	; #MARK:  - MIXED VARS

fastRandomSeed
								dc.l					$3E50B28C,$D461A7F9
forceQuitFlag
								dc.b					0
forceExit
								dc.b					0

escalateIsActive
								dc.b					0
dialogueIsActive
								dc.b					0
killShakeIsActive
								dc.b					0
introLaunched
								dc.b					0
								even

homeShotHead
								dc.l					0

objCount
								dc.w					0

spriteCount	; 1.w = static counter,2.w temp counter
								dc.w					0,0
shotCount
								dc.w					0
bobCount
								dc.w					0,0																																																											; 1.w = static counter,2.w temp counter
bobCountHitable
								dc.w					0,0																																																											;	1.w = countup, 2.w store number
objectWarning
								dc.w					0																																																											; , 0.b = true -> too many bobs, 1.b = true -> too many sprites
	; #MARK:  - Temp vars - use only locally

rasterBarNow
								dc.w					0
								IFNE					SHOWRASTERBARS
rasterBarMax
								dc.w					0
								ENDIF

tempVar							blk.l					10,0

	; #MARK:  - Object and anim vars

objectDefsSize					dc.l					0
animDefsSize					dc.l					0
animDefsAmount					dc.w					0
objectDefsAmount				dc.w					0


	; #MARK: - MEMORY POINTERS BEGINS


memoryPointers
								cnop					0,4																																																											; align on quad adress
								IFEQ					(RELEASECANDIDATE||DEMOBUILD)
memorySum						dc.l					0
memoryCount						dc.l					0
								ENDIF

artworkBitplane                 ; share memory
mainPlanes						dc.l					0,0,0,0																																																										; offset needed for memory restore in _exit
mainPlanesPointer				blk.l					3,0																																																											; pointer to mainPlanes plus current y-offset, three buffers
mainPlanesPointerAsync			dc.l					0,0
mainPlaneOneSize				dc.l					0
mainPlaneAllSize				dc.l					0
fxPlanePointer					dc.l					0,0,0,0
copperGame						dc.l					0
copperGameNext					dc.l					0
copperDialogueColors			dc.l					0
copInitColorswitch				dc.l					0																																																											; filled in runtime -> points to end of game copperlist
diskBuffer						dc.l					0,0
diskBufferSize					dc.l					0
tileSource						dc.l					0
tilemapConverted				dc.l					0
tilemapBckConverted				dc.l					0
artworkPalette                  ; share memory
bobSource						dc.l					0,0
objectList						dc.l					0,0,0,0
bobDrawList						blk.l					5,0
bobRestoreList					blk.l					3,0
collidingList					dc.l					0,0,0
copSpriteLists					blk.l					10,0
copBplLists						dc.l					0,0
copSplitList					dc.l					0,0
copLinePrecalc					dc.l					0
colorFadeTable					dc.l					0
spriteDMAMem					dc.l					0,0,0
spritePosMem					dc.l					0
spritePosFirst					dc.l					0
spritePlayerDMA					dc.l					0,0,0,0,0
spriteParallaxBuffer			dc.l					0,0,0
launchTable						dc.l					0
launchTableBuffer				dc.l					0,0
objectDefs						dc.l					0
animTable						dc.l					0
animDefs						dc.l					0
audioWavTable					dc.l					0
audioFXHero						dc.l					0
audioFXBaddie					dc.l					0
musicMemory						dc.l					0																																																											; total music memory
musicTrackB						dc.l					0																																																											; pointer to Track B

;fib_tilePixelFingerprint	dc.l 	0

								IFNE					DEBUG
spritePosLast					dc.l					0
								ENDIF

tempBuffer
								dc.l					0																																																											; secondary pointer to bobsource mem
tempBufferAnimPointers	; secondary pointer to spriteDMAMem
								dc.l					0
tempMemoryPointersXML	; ""
								dc.l					0,0
tempStoreXML			; ""
								dc.l					0
    ; Coplist pointers
escalateEntry					dc.l					0
escalateExit					dc.l					0
dialogueEntry					dc.l					0
dialogueExit					dc.l					0
achievementsEntry				dc.l					0
achievementsQuit				dc.l					0
bpl2modReversal					dc.l					0
gameFinEntry					dc.l					0
lowerScoreEntry					dc.l					0
colorBullet						dc.l					0,0,0,0
copColSprite					dc.l					0
copPriority						dc.l					0
copSPR6PTH						dc.l					0
copSpr6pos						dc.l					0,0,0
copSpr6posChk
; coplist pointers cleared in rasterlist code, dependent on memorypointersEnd
memoryPointersEnd
animTriggers					dc.l					0
launchTableEntryLength			dc.l					0
launchTableNoOfEntrys			dc.l					0
launchTableSize
								dc.l					0

    ; #MARK: MEMORY POINTERS END


    ; #MARK: - frameCountERS

frameCount
								dc.w					0																																																											; refresh rate counter
								dc.w					0																																																											; total no of frames (Main Game)
								dc.w					0																																																											;	 total no of frames (IRQ)
								dc.w					0																																																											; store refresh rate

frameCompare    ; 0.w = target framerate, 1.w = actual framerate
								dc.w					0,0


; #MARK: - PLAYER MANAGER BEGINS

plyManager

								lea						plyBase(pc),a6
								lea						viewPosition(pc),a0
								move.l					viewPositionAdd(a0),d2
								add.l					d2,plyPosY(a6)

								move.l					plyPosY(a6),d0
								move.l					viewPositionPointer(a0),d1
								sub.l					d1,d0
								swap					d0
								move.w					d0,plyPosYABS(a6)
								asl.l					#8,d2
								swap					d2
								move.w					d2,vPyAccConvertWorldToView(a0)

								tst.w					plyCollided(a6)
								bne.w					plyHitAnim
								tst.b					plyExitReached(a6)
								bne						plyFinal
								move.w					plyJoyCode(a6),d7
								clr.l					d6

;!!!: handle scrolling- and player-x-acceleration
plyJumpIn 		; needed for debugging to avoid scrolling



;#MARK: player movement


handlePlayerMovement
								move.w					plyAcclXCap(a6),d4
								move					d4,d6
								asr						#1,d6
								add						d6,d4

								tst						plyInitiated(a6)
								bne.b					.plyInit
.plyUpDown
								IFNE					PLAYERSPRITEDITHERED																																																						; for player collission tests, player is snail-paced
								btst					#STICK_BUTTON_ONE,d7																																																						; check firebutton 1
								bne						.nofb

								move.w					#plyAcclYMin-5,plyAcclYCap(a6)																																																				; already got highest speed?
								move.w					#plyAcclYMin-5,plyAcclXCap(a6)																																																				; already got highest speed?
								bra						.cont
.nofb							move.w					#plyAcclYMin*2,plyAcclYCap(a6)																																																				; already got highest speed?
								move.w					#plyAcclYMin*2,plyAcclXCap(a6)																																																				; already got highest speed?
.cont
								ENDIF

								btst					#JOY_DOWN,d7
								beq						.plyQueryUp
.plyGoDown
								tst.w					plyPosAcclY(a6)
								bmi						.plyInitPosY
								add.w					d4,plyPosAcclY(a6)
								bra						.plyTstBoundDwn
.plyInit
								subq					#1,plyInitiated(a6)
								bne.b					.initRuns

								move.w					#plyAcclYMin,plyAcclYCap(a6)
.initRuns
								move.w					plyInitiated(a6),d6																																																							; initial inertia
								move.b					(sineTable+49,pc,d6),d6
								ror.l					#4,d6
								swap					d6
								add.l					d6,plyPosY(a6)
								bra						.plyQueryLeftRight
.plyInitPosY
								move.w					d4,plyPosAcclY(a6)
								bra.b					.plyTstBoundDwn

.plyQueryUp
								btst					#JOY_UP,d7
								beq.b					.plyZeroYAccl
.plyGoUp
								tst.w					plyPosAcclY(a6)
								bgt						.plyInitNegY
								sub.w					d4,plyPosAcclY(a6)
								bra						.plyTstBoundUp
.plyInitNegY
								neg.w					d4
								move.w					d4,plyPosAcclY(a6)
.plyTstBoundUp
								cmpi					#$15,d0
								bgt.b					.plyQueryLeftRight
								moveq					#$15,d6
								bra.b					.wrtYPos
.plyTstBoundDwn
								cmpi					#$dc,d0
								blt.b					.plyQueryLeftRight
								clr.l					d6
								move					#$dc,d6
.wrtYPos
								swap					d6
								add.l					viewPosition+viewPositionPointer(pc),d6
								move.l					d6,plyPosY(a6)
.plyZeroYAccl
								clr.w					plyPosAcclY(a6)

.plyQueryLeftRight
								btst					#JOY_RIGHT,d7
								beq.b					.plyQueryLeft
.plyGoRight
								tst.w					plyPosAcclX(a6)
								bmi.b					.plyInitPosX
								add.w					d4,plyPosAcclX(a6)
								bra.b					.plyTstBoundRgt
.plyInitPosX
								move.w					d4,plyPosAcclX(a6)
								bra.b					.plyTstBoundRgt

.plyQueryLeft
								btst					#JOY_LEFT,d7
								beq						.plyZeroXAccl
.plyGoLeft
								tst						plyPosAcclX(a6)
								bgt.b					.plyInitNegX
								sub.w					d4,plyPosAcclX(a6)
								bra.b					.plyTstBoundLft
.plyInitNegX
								neg.w					d4
								move.w					d4,plyPosAcclX(a6)
.plyTstBoundLft
								cmpi					#8,plyPosX(a6)
								bgt.b					.plyXfinish
								move					#8,d5
								bra.b					.wrtXPos
.plyTstBoundRgt
								cmpi					#232,plyPosX(a6)
								blt.b					.plyXfinish
								move					#232,d5
.wrtXPos
								swap					d5
								clr.w					d5
								move.l					d5,(a6)																																																										;plyPosX
.plyZeroXAccl
								clr.w					plyPosAcclX(a6)


.plyXfinish
	;clr.w plyPosAcclX(a6)
								moveq					#-7,d6
								add.w					plyPosX(a6),d6
    ;lsr #4,d6
    ;move.w d6,plyPosXDyn(a6); dynamic offset, used for horizontal scrolling    ;
	;subq #3,d6
	;move.w d6,plyPosXDynAlt(a6)
		;#FIXME: temp. disabled plyPosXDynAlt. Still needed?
								add.w					#viewDownClip-30,d6

;#MARK: Player shot control
.plyShotControl
	;move.b #3,plyWeapUpgrade(a6)
	;move #plyAcclXMin+2*3,plyAcclXCap(a6)
	;move #plyAcclXMin+2*3,plyAcclYCap(a6)

								IFEQ					(RELEASECANDIDATE||DEMOBUILD)
;   keypress 1 -> weap down, 2-> weap up
								tst.w					keyArray+Key2(pc)
								beq						.smooth1
								cmpi.b					#plyWeapUpgrMax,plyWeapUpgrade(a6)
								bge						.smooth2
								add.b					#1,plyWeapUpgrade(a6)
								add.w					#2,plyAcclXCap(a6)
								add.w					#2,plyAcclYCap(a6)
								move.b					plyWeapUpgrade(a6),d0
	;add.w #1,objCount
								subq.b					#1,d0
								lsl						#5,d0
								addq					#1,d0
								move.b					d0,plyWeapSwitchFlag(a6)
	;ADDSCORE 10
								PLAYFX					21
.smooth1
								tst.w					keyArray+Key1(pc)
								beq						.smooth2
								tst.b					plyWeapUpgrade(a6)
								beq						.smooth2
								sub.b					#1,plyWeapUpgrade(a6)
								sub.w					#2,plyAcclXCap(a6)
								sub.w					#2,plyAcclYCap(a6)
								move.b					plyWeapUpgrade(a6),d0
								add.b					#1,d0
								lsl						#5,d0
								bset					#7,d0
								subq.b					#1,d0
								PLAYFX					22

								move.b					d0,plyWeapSwitchFlag(a6)
	;ADDSCORE 10
.smooth2
								ENDIF


; keypress code ends

								clr.l					d6
								move.b					plyFire1Auto(a6),d6
								bpl						.autoShoot
								clr.w					d0
								IFNE					PLAYERAUTOFIRE
								bra						.fbPressed
								ENDIF
								btst					#STICK_BUTTON_ONE,d7																																																						; is primary firebutton tapped?
								beq						.released
.fbPressed
								addq					#1,d0																																																										; yes!
								add.b					d0,plyFire1Flag(a6)
								bra.b					.shotManager
.released
								clr.b					plyFire1Flag(a6)
	;andi.b #$1,plyShotCnt(a6)
.shotManager


								move.b					plyFire1Auto(a6),d6
								tst.b					d0
								beq						plyNoFire

								move.b					#1,plyFire1Flag(a6)
.plyShoot	; init player shot

								clr.w					d5
								move.b					plyWeapUpgrade(a6),d1
								andi					#3,d1																																																										; index to weapon upgrade
	;move.b (.addShots,pc,d1.w),d5
	;add.w d5,plyShotsFired(a6)	; queried in achievements screen

								cmpi.w					#FBHOLD,plyJoyCode+6(a6)
								shi						d4
								andi.w					#4,d4
								add.w					d4,d1

								move.b					(.freq.W,pc,d1.w),plyFire1AutoB(a6) shot frequency
								move.b					#20,plyFire1Auto(a6)																																																						; 32	; length of one fire burst
								bra						plyNoFire
;.addShots
;	dc.b 5,10,16,0

.autoShoot	; fire row of shots automatically after first init

								move.b					plyFire1Auto(a6),d0
								subq.b					#1,plyFire1Auto(a6)
								bmi.w					plyNoFire

								clr.w					d5
								clr.w					d1
								move.b					plyWeapUpgrade(a6),d1
								bne						.initXtraShot
.initMainShot
	;bra plyNoFire
								sub.b					#1,plyFire1AutoB(a6)																																																						; shot frequency
								bne						plyNoFire
								clr.w					d1
								move.b					plyWeapUpgrade(a6),d1

								cmpi.w					#FBHOLD,plyJoyCode+6(a6)
								shi						d4
								andi.w					#2,d4


								move.b					(.freq.W,pc,d1.w),d6
								add.b					d4,d6																																																										; double firerate if fb tapped

								move.b					d6,plyFire1AutoB(a6)
								bra						.initShot
.freq
								dc.b					4,4,4,0
.freqHold
								dc.b					7,7,6,0

.xtraFreq
								IFNE					0
								dc.b					-1,-1,-1,-1,-1,-1,-1,-1
								dc.b					-1,-1,-1,-1,-1,-1,-1,-1
								dc.b					-1,-1,-1,-1,-1,-1,-1,-1
								dc.b					-1,-1,-1,-1,-1,-1,-1,-1
								ENDIF

								dc.b					0,-1,-1,-1,-1,-1,-1,0
								dc.b					-1,-1,-1,-1,-1,-1,-1,-1
								dc.b					0,-1,-1,-1,-1,-1,-1,0
								dc.b					-1,-1,-1,-1,-1,-1,-1,-1

								dc.b					0,-1,-1,-1,-1,-1,-1,1
								dc.b					-1,-1,-1,-1,-1,-1,-1,-1
								dc.b					0,-1,-1,-1,-1,-1,-1,1
								dc.b					-1,-1,-1,-1,-1,-1,-1,-1

	;blk.b 256,-1
								dc.b					0,-1,-1,-1,-1,1,-1,-1
								dc.b					-1,-1,0,-1,-1,-1,-1,1
								dc.b					-1,-1,-1,-1,0,-1,-1,-1
								dc.b					-1,1,-1,-1,-1,-1,-1,-1
								even

.weapEmit
								dc.l					.initShot, .initShot,.initShot
.shotPointers
								dc.l					cPlyShtAAnimPointer,cPlyShtAAnimPointer,cPlyShtBAnimPointer, cPlyShtBAnimPointer
.xtraPointer
								dc.l					cPlyShtCAnimPointer, cPlyShtDAnimPointer
.xtraXMod
								dc.b					30,4,36,-10
.xtraXAcc
								dc.b					40,-40,95,-90
.initXtraShot
								lsl						#5,d1
								lea						(.xtraFreq,pc,d1),a1
								move					d0,d3
								andi					#$1f,d3
								move.b					(a1,d3),d1
								bmi						.initMainShot
								move.l					([.xtraPointer,pc,d1*4]),a5
								move.w					animTablePointer+2(a5),d4

								move.w					#147,d5
								add.b					(.xtraXMod,pc,d1),d5
								add						(a6),d5																																																										;plyPosX
								sub.w					plyPos+plyPosXDyn(pc),d5																																																					;Convert absolute to relative
								clr.l					d6

								move					plyPosY(a6),d6
								sub						#8,d6
								sf.b					d3
								bsr						objectInitShot
								tst.l					d6
								bmi.w					.initMainShot

								add.w					#1,plyShotsFired(a6)

								clr.b					objectListAttr(a4)																																																							; code read attribs from object defs


								move.b					(.xtraXAcc,pc,d1),d1
								ext.w					d1
								lsl						#4,d1
    ;move #-32<<6,d1
    ;clr.w d1
								move.w					d1,objectListAccX(a4)																																																						; no x-accl
    ;move.w #-30<<6,d1

								move.l					viewPosition+viewPositionAdd(pc),d1
								asr.l					#8,d1																																																										; get scroll speed -> tare y-velociy no matter how fast background moves
								sub.w					#30<<6,d1																																																									;32

								add						d1,objectListAccY(a4)																																																						; add y-accl
								bra						.initMainShot

.initShot

								move.l					([.shotPointers.W,pc,d1*4]),a5
								move.w					animTablePointer+2(a5),d4

								move.w					(.xMod,pc,d1*2),d5
								add						(a6),d5																																																										;plyPosX
								sub.w					plyPos+plyPosXDyn(pc),d5																																																					;Convert absolute to relative
								move					plyPosY(a6),d6
								sub						#1,d6
								sf.b					d3
								bsr						objectInitShot

								tst.l					d6
								bmi						plyNoFire

								lea						plyBase,a6
								add.w					#1,plyShotsFired(a6)

    ;move #,objectListHit(a4); hitpoints
								clr.b					objectListAttr(a4)																																																							; code read attribs from object defs


								move.l					viewPosition+viewPositionAdd(pc),d1
								asr.l					#8,d1																																																										; get scroll speed -> tare y-velociy no matter how fast background moves
								sub.w					#36<<6,d1																																																									;32
								move.w					d1,objectListAccY(a4)																																																						; add y-accl
								clr.w					objectListAccX(a4)																																																							; no x-accl
								PLAYFX					fxShot
								bra.b					plyNoFire
.xMod
								dc.w					165,165,163
plyShotYOffset      ; + = upper position
.y=39
;    dc.w .y,.y+4,.y-4,.y+2
;    dc.w .y-4,.y+6,.y-8,.y+8
								dc.w					.y,.y+2,.y,.y-2
								dc.w					.y-4,.y+3,.y+4,.y-3
plyNoFire

   ; fade colors of player shots when switching weaponry


								tst.b					plyWeapSwitchFlag(a6)
								beq.b					playerMovement																																																								; no colorfade going on
								bpl.b					.switchup																																																									; msb -> fade up or down

								sub.b					#1,plyWeapSwitchFlag(a6)
								bra.b					.switched
.switchup
								add.b					#1,plyWeapSwitchFlag(a6)
.switched
								clr.w					d0
								move.b					plyWeapSwitchFlag(a6),d0
								bclr					#7,d0
								lsr						#1,d0
								move.b					d0,d1
								andi.b					#%1111,d1
								bne.b					.playerColors
								clr.b					plyWeapSwitchFlag(a6)
								bra.w					playerMovement
.playerColors
								bsr						dynamicPlayerColors

playerMovement


								clr.w					d3
								clr.l					plyAcclXABS(a6)
								move.l					plyAcclXCap(a6),d5
								move.l					d5,d7
								move.l					plyPosAcclX(a6),d0																																																							; load x and y-accl
								move.l					d0,d4
								move					d0,d1
								beq.b					.chkXAccl
								smi						d6																																																											; moves up?
								ext.w					d6
								eor						d6,d5																																																										; yes - neg Y-acc
								eor						d6,d1
								cmp.w					d5,d1
								blt						.wrtYAccl
								move					d5,d0
								lsr						#1,d6
								addx					d3,d0																																																										; modify y-acc incase of moving up
.wrtYAccl
								move.w					d0,plyAcclYABS(a6)
								swap					d0
								clr.w					d0
								asr.l					#2,d0
								add.l					d0,plyPosY(a6)																																																								;plyPosY

.chkXAccl                       ; same for ply x-accl
								swap					d4
								swap					d7
								move					d4,d1
								beq.b					plyCollision
								smi						d6
								ext.w					d6
								eor						d6,d7
								eor						d6,d1
								cmp.w					d7,d1
								blt						.wrtXAccl
								move					d7,d4
								lsr						#1,d6
								addx					d3,d4																																																										; needed to
.wrtXAccl
								move.w					d4,plyAcclXABS(a6)
								swap					d4
								clr.w					d4
								asr.l					#2,d4
								add.l					d4,plyPosX(a6)																																																								;plyPosX

; #MARK: player collission
plyCollision

								move					$dff00e,d0

								IFEQ					PLAYERCOLL
								bra						plyColQuit
								ENDIF

								btst					#1,d0																																																										; hit background?
								bne						plyChkColBck
	;bra plyChkColBck
plyBulletCheck
								andi.w					#1<<10+1<<9,d0																																																								; registered sprite (2 or 4) collission?
								tst.w					d0
								bne						plyBulletHit
								rts
plyBulletHit
	; hardware registered player<->bullet hit. Recheck with bounding box!

								move.l					objectList(pc),a3
								moveq					#4,d4
								sub.l					d4,a3
								clr.w					d6
								clr.w					d1
								clr.w					d3
								move					(a6),a4																																																										;plyPosX
								sub.w					plyPos+plyPosXDyn(pc),a4																																																					;Convert
.hitboxXWidth					SET						16
.hitboxYWidth					SET						14
								clr.w					d2
								tst.w					plyBase+plyPosAcclX(pc)
								beq						.playerShipCentred
								smi.b					d2																																																											; adjust x-position if sprite tilts left or right
								andi					#2,d2																																																										; either 0 or 2
								sub.b					#1,d2																																																										; either -1 or 1
								ext.w					d2
.playerShipCentred
								lea						$aa+(.hitboxXWidth/4)(a4,d2),a4																																																				; higher preval -> move colbox to the right end of playership
    ; centre basic x val / tested = $ac

								move					plyPosY(a6),a5
								lea						$23(a5),a5																																																									; higher preval -> move colbox to the lower end of playership
								move.l					animDefs(pc),a6
								move					#-.hitboxXWidth,d2																																																							; hitbox x-width - need to adjust x-pos too; see code above
								move					#-.hitboxYWidth,d6																																																							; hitbox y-width
								move					objCount(pc),d7
								bra						.nextObject
;chkPlyCol
.checkEntry
								adda.w					d4,a3
								tst						(a3)																																																										;objectListAnimPtr
								beq.b					.checkEntry
								move					(a3),d1																																																										;objectListAnimPtr
								lea						(a6,d1),a2																																																									; Accelerate x and y - read from animDefAcc
								clr.w					d3
								move.b					animDefType(a2),d3
								lea						([(objectDefs).w,pc],d3*8),a2																																																				; Pointer to animDefinitions
								move.b					objectDefAttribs(a2),d0
								bpl.b					.nextObject																																																									; no sprite? Check right now
    ;#FIXME: Player shot chk needed?
								btst					#6,d0
								bne.b					.nextObject																																																									; bonus sprite icon? Skip too
.calcDist
								move.w					objectListY(a3),d0
								sub.w					a5,d0
								cmp.w					d6,d0																																																										; height of colbox
								blo						.nextObject
	;bra kick

								move.w					objectListX(a3),d1
								sub.w					a4,d1
								cmp.w					d2,d1
								bhi						playerHit
.nextObject
								dbra					d7,.checkEntry
fuckIt
								rts


    			; adjust colors in player aprite
dynamicPlayerColors
								lea						CUSTOM,a4

								move.l					colorFadeTable(pc),a0
								lea						128(a0),a1
								lea						2+(128*2)(a0),a2
						; write shot colors to color regs
								move.l					(a0,d0*4),d1
								move.w					(a2,d0*4),d2
								move.l					(a1,d0*4),d3
								move					#%1110000000000000,BPLCON3(a4)
    ; player shots

								movem.w					d1-d3,COLOR01(a4)																																																							; main weapon
								swap					d1
								swap					d2
								swap					d3
								move					#%1110001000100000,BPLCON3(a4)
								movem.w					d1-d3,COLOR01(a4)
								rts
plyChkColBck	; basic coldetection for playership -> check hit with bitplane0

								lea						AddressOfYPosTable(pc),a2
								move.l					mainPlanesPointer+8(pc),a1
								moveq					#11,d4																																																										;y-offset
								clr.l					d5
.HitBoxXWidth					SET						12																																																											; set bit 0 to 0
								move					#$168-((.HitBoxXWidth+1)/2),d5																																																				;x-offset
								sub.w					plyBase+plyPosXDyn(pc),d5
								move.w					#2*mainPlaneDepth*mainPlaneWidth,d3
.hitBckChk
								add.w					plyPosYABS(a6),d4																																																							; load player y-coords
								move.w					(a2,d4.w*2),d4																																																								; y bitmap offset
								lea						-40(a1,d4.l),a1


								add.w					plyPosX(a6),d5
								ror.l					#3,d5
								lea						(a1,d5.w),a1																																																								; add x-byte-offset
								clr.w					d5
								swap					d5
								rol						#3,d5																																																										; put bit pointer in place
								IFNE					0
								bfset					(a1){d5:.HitBoxXWidth}																																																						; set 8 bits
								bfset					2*mainPlaneDepth*mainPlaneWidth(a1,d3.w*2){d5:.HitBoxXWidth}																																												; set 8 bits
								bfset					4*mainPlaneDepth*mainPlaneWidth(a1,d3.w*4){d5:.HitBoxXWidth}																																												; set 8 bits
	;bra plyColQuit
								ENDIF
								bftst					(a1){d5:.HitBoxXWidth}
								bne						playerHit
								bftst					2*mainPlaneDepth*mainPlaneWidth(a1,d3.w*2){d5:.HitBoxXWidth}
								bne						playerHit
								bftst					4*mainPlaneDepth*mainPlaneWidth(a1,d3.w*4){d5:.HitBoxXWidth}
								bne						playerHit
.quit
								bra						plyBulletHit																																																								; no background hit. Now check bullet hit
; #MARK: player hit animation
playerHit
								move.b					plyDistortionMode(a6),d5
								lea						plyBase(pc),a6
								tst						plyInitiated(a6)
								bne						plyColQuit
								tst						plyCollided(a6)																																																								; is already dying
								bne						plyColQuit
								cmpi.b					#8,plyDistortionMode(a6)																																																					; hack to trigger deathseq incase of heat screen distortion (boss0)
								beq						.hitPlayer
								tst.b					plyDistortionMode(a6)																																																						; weapon downgrading?
								bne						plyColQuit
.hitPlayer

								IFNE					PLAYERSPRITEDITHERED																																																						; ATTN: Set PLAYERCOLL=1, SHOWRASTERBARS=1 Too!
								clr.w					CUSTOM+BPLCON3
								move					#-1,CUSTOM+COLOR00
								rts
								ENDIF
	;#!!!:Temp code to pause game when player is hit
	;lea gameInActionF(pc),a4
    ;bchg #0,(a4)

								move.l					weapDstrAnimPointer(pc),a4
								move.w					animTablePointer+2(a4),d4																																																					;add  object to control distortion mode
								move					objectListX(a0),d5
								add.w					#$15,d5
								moveq					#-40,d6
								add						collTableYCoords(a3),d6																																																						; get y-coord from shot
								st.b					d3
								bsr.w					objectInit
								tst.l					d6
								bmi.w					.quit

								subq.b					#1,plyWeapUpgrade(a6)																																																						; destroy current weapon
;    addq.b #1,plyWeapUpgrade(a6)         ; destroy current weapon
								bmi						.initDeath
.cheatRetPoint
								move.b					plyWeapUpgrade(a6),d1

								move					d1,d0
								addq.b					#1,d1
								lsl						#5,d1
								bset					#7,d1
								subq.b					#1,d1
								move.b					d1,plyWeapSwitchFlag(a6)
								PLAYFX					13

								cmpi.w					#plyAcclXMin,plyAcclXCap(a6)
								bls.b					.minReached
								sub.w					#2,plyAcclXCap(a6)
								sub.w					#2,plyAcclYCap(a6)
.minReached
	;move.l a6,a1
	;st plyDistortionMode
    ;lea plyPos(pc),a0           ; init particle rain
								move					#$66,d3
								sub.w					plyPosXDyn(a6),d3
								add.w					plyPosX(a6),d3																																																								;plyPosX
	    	;#FIXME: Check use  plyPosXABS
	;sub.w viewPosition+viewPositionPointer(pc),d3
								sub						#60,d3
								lsl						#4,d3
								move.w					plyPosY(a6),d4
								sub.w					viewPosition+viewPositionPointer(pc),d4
								add.w					#16,d4
								lsl						#8,d4
								clr.w					d5																																																											;x-acc
								clr.w					d6																																																											;y-acc
								lea						emitterExtraLoss(pc),a0

								jmp						particleSpawn																																																								; apawn particle rain after hit equipped ship

; #MARK: player death  animation
.cheater
								addq.b					#1,plyWeapUpgrade(a6)																																																						; destroy current weapon
								bra						.cheatRetPoint

.initDeath		; init death sequence
	;tst.b plyCheatEnabled(a6)
	;bne.b .cheater
								btst					#optionSFXBit,optionStatus(pc)
								bne.b					.keepMusic																																																									; fx switched off?

								SAVEREGISTERS
								lea						CUSTOM,a6
								move.b					#%0000,d0
								bsr						_mt_musicmask																																																								; enable all channels for sfx

								lea						CUSTOM,a6
								move					#musicPauseVolume,d0
								bsr						_mt_mastervol																																																								; lower music volume

								RESTOREREGISTERS
.keepMusic
								DEBUGBREAK
								cmpi.b					#statusLevel1+1,gameStatus(pc)																																																				; is stage 0 or stage 1? Do not spawn continue-sprite
								bls						.noContinueSprite

								move.l					instSpwnAnimPointer(pc),a4
								move.w					animTablePointer+2(a4),d4																																																					;add  object to control quick resume mode
								move					#258+16,d5
								sub.w					plyBase+plyPosXDyn(pc),d5
								moveq					#24,d6
								add.w					viewPosition+viewPositionPointer(pc),d6
								st.b					d3
								bsr.w					objectInit																																																									; spawn Instant Respawn sprite
.noContinueSprite
								move					#30,frameCompare+2
								move					#30,frameCompare
								move					#1,plyCollided(a6)																																																							; init playerhit animation

								clr.l					viewPosition+viewPositionAdd																																																				; stop scrolling
.quit
								rts
storePlayerPos
								dc.w					0,0
plyHitAnim                  ; animation fatal player was hit

								move					#1,frameCompare+2																																																							; slow down frame update
.noInitDebris

	; handle quick resume / respawn


								move.b					#statusLevel0,d7																																																							; quick respawn at stage0
								DEBUGBREAK
								move.b					gameStatus(pc),d7
								cmpi.b					#statusLevel1+1,d7																																																							; is stage 0 or stage 1? No continue
								bls						.retFBreleased
								sub.b					#1,d7																																																										; prepare for quick respawn at current stage

								add.b					#1,plyFire1Flag(a6)																																																							;Firebutton triggered -> respawn at stage0
								cmpi.b					#192,plyFire1Flag(a6)
								bhi						.quickRespawn																																																								; write d7 to gameStatus, leave
								btst					#STICK_BUTTON_ONE,plyJoyCode(a6)																																																			; check firebutton 1 from stick
								beq						.FBreleased
.retFBreleased
								move.b					#statusTitle,d7																																																								; return to title incase of NO quick respawn
								addq					#1,plyCollided(a6)
								lea						transitionFlag(pc),a1
								cmpi					#370,plyCollided(a6)
								beq						.initFade																																																									; write d7 to gameStatus, leave
								moveq					#5,d7																																																										; slow down frame
								cmpi					#200,plyCollided(a6)
								bhi						.frameRate
								moveq					#3,d7
								cmpi					#180,plyCollided(a6)
								bhi						.frameRate
								moveq					#2,d7
								cmpi					#160,plyCollided(a6)
								bhi						.frameRate
								cmpi					#70,plyCollided(a6)
								bhi						.spawnDebris																																																								; debris
								cmpi					#61,plyCollided(a6)
								beq						.hidePlayer																																																									; playership hide
								cmpi					#60,plyCollided(a6)
								beq						.bigExplosion																																																								; playership explodes

								movem.w					plyPosAcclX(a6),d4/d5																																																						; drift player vessel / modify x- and y-position while particles rain
								lsl.l					#4,d4
								add.l					d4,plyPosX(a6)
								lsl.l					#4,d5
								add.l					d5,plyPosY(a6)
								move.l					plyPosY(a6),d4
								move.l					viewPosition+viewPositionPointer(pc),d5
								sub.l					d5,d4
								swap					d4
								move.w					d4,plyPosYABS(a6)


								lea						emitterKillA(pc),a0
								cmpi					#20,plyCollided(a6)
								beq						.spawnParticles																																																								; init particle rain
								cmpi					#15,plyCollided(a6)																																																							; init particle rain
								beq						.spawnParticles

								lea						emitterKillB(pc),a0
								cmpi					#10,plyCollided(a6)
								beq						.spawnParticles

								lea						emitterKillC(pc),a0
								cmpi					#2,plyCollided(a6)
								beq						.spawnParticlesFX
	;move #30,frameCompare
.quit
								rts
.FBreleased

								sf.b					plyFire1Flag(a6)																																																							; set to zero
								bra						.retFBreleased
.frameRate
								lea						frameCompare+2(pc),a0
								move					d7,(a0)
								rts
.hidePlayer
								move.w					#0,plyPosY(a6)
								rts
.bigExplosion
								lea						storePlayerPos(pc),a5
								moveq					#$24,d5
								sub.w					plyPosXDyn(a6),d5
								add.w					plyPosX(a6),d5
								move.w					d5,(a5)
								move.w					plyPosY(a6),2(a5)																																																							; save players position

								PLAYFX					fxExplBig
								PLAYFX					fxExplMed
								PLAYFX					fxExplSmall
								move.l					cExplLrgAnimPointer(pc),a4
								move.w					animTablePointer+2(a4),d4
								lea						storePlayerPos(pc),a1
								move.w					(a1),d5																																																										;plyPosX
								add						#165,d5
								move.w					2(a1),d6
								sub.w					#10,d6
								st.b					d3
								bsr						objectInit																																																									; big explosion to cover loss of player sprite
								tst.l					d6
								bmi						.quit
								move.b					#attrIsNotHitableF,objectListAttr(a4)																																																		; attribs
								rts
.quickRespawn	; re-init after fatal death bypassing title screen
								bsr						resetScores
.initFade
								lea						forceExit(pc),a0
								tst.b					(a0)
								bne						.fadeActive
								st.b					(a0)																																																										; init fade and quit
								lea						gameStatus(pc),a0
								move.b					d7,(a0)
.fadeActive
								rts

.spawnParticlesFX
.spawnParticles
								PLAYFX					fxLoseVessel

								moveq					#$2c,d3
								sub.w					plyBase+plyPosXDyn(pc),d3
								add.w					plyBase+plyPosX(pc),d3

								move.w					plyBase+plyPosY(pc),d4
								lsl						#4,d3
								sub.w					viewPosition+viewPositionPointer(pc),d4
								move.w					plyBase+plyPosYABS(pc),d4
								add.w					#16,d4
								lsl						#8,d4
								clr.w					d5																																																											; x-acc
								clr.w					d6																																																											; y-acc
								jmp						particleSpawn(pc)

.spawnDebris

								lea						storePlayerPos(pc),a1
								move					plyCollided(a6),d1
								move					d1,d7
								lsr						#3,d1
								andi					#7,d1
								clr.l					d5
								movem.w					(a1),d5/d6																																																									;plyPosX/Y
								add						#165,d5
debrisEntry
								clr.w					d3
								jmp						([(.debrisCases).W,pc,d1.w*4])
.debrisCases
								dc.l					.debrisA,.debrisH,.debrisC,.debrisF
								dc.l					.debrisD,.debrisD,.debrisD,.debrisH
.debrisH
								move.b					#fxExplSmall-1,d3
								move.l					cExplSmlAnimPointer(pc),a4
								bra.b					.initObject
.debrisF
								move.b					#fxExplBig-1,d3
								move.l					cExplMedAnimPointer(pc),a4
	;sub #20,d5
								bra.b					.initObject
.debrisD
								move.w					#fxExplMed-1,d3
								move.l					cExplLrgAnimPointer(pc),a4
								bra.b					.initObject
.debrisC
								move.l					debrisA3AnimPointer(pc),a4
								bra.b					.initObject
.debrisA
								move.l					debrisA4AnimPointer(pc),a4
.initObject
	;move.l cExplLrgAnimPointer(pc),a4
								andi					#$3,d7
								bne						.noFX
								tst.w					d3
								beq						.noFX
								movem.l					d0-d1/a0/a6,-(sp)
								lea						CUSTOM,a6
								move					d3,d4
								lsl						#3,d3
								lsl						#2,d4
								add						d4,d3

								lea						fxTable(pc,d3),a0
								bsr						_mt_playfx
								movem.l					(sp)+,d0-d1/a0/a6
.noFX
								move.w					animTablePointer+2(a4),d4
								st.b					d3
								bsr						objectInit

								tst.l					d6
								bmi.b					.quit /was: .noInitDebris
								move.b					#attrIsNotHitableF|attrIsOpaqF,objectListAttr(a4)																																															; attribs
								lea						vars(pc),a0
								clr.w					d7
								move.b					$bfe601,d7
								move.b					$dff006,d6
								andi					#3,d6
								rol.b					d6,d7
								move					d7,d6
								lsr						#4,d6
								add.w					d6,objectListY(a4)
								move					d7,d6
								lsl						#2,d6
								lsl						#3,d7
								add						d6,d7
								sub						#1620,d7
								move					d7,objectListAccY(a4)
								move.b					#31,objectListCnt(a4)

								movem.l					fastRandomSeed-vars(a0),d6/d7
								swap					d7
								add.l					d6,fastRandomSeed-vars+4(a0)
								add.l					d7,fastRandomSeed-vars(a0)

	;move.w $dff006,d7
	;move.b $bfe601,d6
	;eor.b d6,d7
								andi					#$1f,d7
								moveq					#$f,d6
								sub						d7,d6
	;add #200,d6
								add.w					d6,objectListX(a4)
								lsl						#5,d6
								move					d6,objectListAccX(a4)
.quit
								rts
plyColQuit
plyColQuitFromScore
plyFinal
								rts
    ;bra irqRetPlyManager

; #MARK: PLAYER MANAGER ENDS


; #MARK: - OBJECT MOVE MANAGER

objectMoveManager

								move.l					animDefs(pc),a5																																																								; loaded at animlooper
								move.l					objectList(pc),a6
								moveq					#4,d2
								sub.l					d2,a6
								clr.l					d0
								moveq					#2,d2
								move.w					objCount(pc),d7

								bra						animLooper
animLoop
								moveq					#8,d4
.checkEntry
								lea						4(a6),a6
								move.w					(a6),d1																																																										;objectListAnimPtr
								beq.b					.checkEntry
.2
								movem.w					(a5,d1.w),d5/d6																																																								; Accelerate x and y - read from animDefAcc
								add.w					d5,objectListAccX(a6)
								add.w					d6,objectListAccY(a6)

								movem.w					objectListAccX(a6),d5/d6																																																					; movem.w sign extendeds automatically
								lsl.l					d4,d5
								add.l					d5,objectListX(a6)
								lsl.l					d4,d6
								add.l					d6,objectListY(a6)

.3
								subq.b					#1,objectListCnt(a6)
								beq.b					.stepEnds
								dbra					d7,.checkEntry

								bra						irqDidObjMoveManager																																																						; back to irq
.stepEnds
								lea						(a5,d1),a0
								move					animDefEndWaveAttrib(a0),d0
								cmpi.w					#$f0,d0
								bge.b					.initcode
.bobInitNextStep
								addq					#animDefSize,(a6)																																																							;objectListAnimPtr. No. init next animation step
.1
								move					(a6),d0																																																										;objectListAnimPtr
								move.l					animDefs(pc),a5
								move.b					animDefCnt(a5,d0),d0
								beq						.zeroCnt																																																									; cnt of 0 -> execute next step immediately

								move.b					d0,objectListCnt(a6)
								dbra					d7,animLoop

								bra						irqDidObjMoveManager																																																						; back to irq
.zeroCnt
								move.b					#1,objectListCnt(a6)
								move.w					(a6),d1																																																										;objectListAnimPtr
								moveq					#8,d4
								movem.w					(a5,d1.w),d5/d6																																																								; update x and y acceleration, but do not apply to object in case of immediate nextstepping to avoid undesired acceleration
								add.w					d5,objectListAccX(a6)
								add.w					d6,objectListAccY(a6)
								bra						.3
.initcode
								sub.w					#$f0,d0
								moveq					#animDefSize*2,d1
								jmp						((.codeCases).w,pc,d0*4)

.codeCases
								bra.w					.attrNext
								bra.w					.attrLoop
								bra.w					.attrXacc
								bra.w					.attrYacc
								bra.w					.attrXpos
								bra.w					.attrYpos
								bra.w					.attrTrig
								bra.w					.attrRept
.attrXacc
								add						d1,(a6)
								move					animDefNextWave(a0),objectListAccX(a6)
								bra.w					.1
.attrYacc
    ;add d1,(a6)
    ;move animDefNextWave(a0),objectListAccY(a6)
    ;bra.w .1

								add						d1,(a6)
								move					animDefNextWave(a0),d5
								tst.b					objectListAttr(a6)																																																							; incase of static onscreen y-launch position of copied objects, adjust y-acc to keep patterns similar to dynamic onscreen (scrolling) y-launch position
								bmi.b					.modifyYacc
								move.w					viewPosition+viewPositionAdd(pc),d6
								lsl						#7,d6
								neg.w					d6
								sub.w					d6,d5
.modifyYacc
								move					d5,objectListAccY(a6)
								bra.w					.1
.attrXpos
								add						d1,(a6)
								move.w					animDefNextWave(a0),objectListX(a6)
								clr.w					objectListAccX(a6)
								bra						.1
.attrYpos
								add						d1,(a6)
								clr.l					d5
								tst.l					objectListMyParent(a6)
								bne.b					.noChildX
								move					viewPosition+viewPositionPointer(pc),d5
.noChildX
								add						animDefNextWave(a0),d5
								move					d5,objectListY(a6)
								clr.w					objectListAccY(a6)
								bra.w					.1
.attrTrig           ; four triggers available
                    ; bits 8&9 determine triggerslot (256/512)
                    ; bit 10 determines global(0) or objectrelated(1) trigger (1024)
                    ; if trigger>128    -> pause animList until trigger<>0
                    ; if trigger<128    -> write value to trigger

								move.w					animDefNextWave(a0),d4
								move					d4,d5
								lsr						#8,d5
								btst					#2,d5
								bne.b					.objectTrigger
								lea						(animTriggers,pc),a5																																																						;globalTrigger
								bra.b					.triggerType
.objectTrigger
								lea						objectListTriggers(a6),a5
.triggerType
								andi					#3,d5
								tst.b					d4
								bpl.b					.noWait
								tst.b					(a5,d5)																																																										; pause animList
								beq						.1
	;clr.b d4
	;move.b d4,(a5,d5) ; unpause animList
								add						d1,(a6)																																																										; next anim step
								bra.w					.1
.noWait
								add						d1,(a6)																																																										; next anim step
								move.b					d4,(a5,d5)																																																									; write value to trigger
.wait
								bra.w					.1

.getNext
								add						d1,(a6)
								bra.w					.1

.attrRept
    ;clr objectListAccX(a6)
								move.w					animDefNextWave(a0),d4
								move.b					d4,objectListLoopCnt(a6)
								bra.w					.getNext
.attrLoop        ; loop endlessly if rept0
								tst.b					objectListLoopCnt(a6)
								beq.b					.endless
								sub.b					#1,objectListLoopCnt(a6)																																																					; else countdown
								beq.b					.getNext
.endless
								move.w					animDefNextWave(a0),d4
								sub						d4,(a6)
								bra.w					.1


								move.w					animDefNextWave(a0),d4
								sub						d4,(a6)
								move					(a6),d0																																																										;objectListAnimPtr
								move.l					animDefs(pc),a5
								move.b					animDefCnt(a5,d0),d0
;    beq .zeroCnt	; cnt of 0 -> execute next step immediately

								move.b					d0,objectListCnt(a6)
								dbra					d7,animLoop
								bra						irqDidObjMoveManager																																																						; back to irq




;    bra.w .1
.attrNext
								move.w					animDefNextWave(a0),d4
								cmpi.b					#$f0,d4
								beq.b					.animClrBob
										; execute individual code
								add						#animDefSize*2,(a6)																																																							;objectListAnimPtr
								cmpi.l					#$00f000f0,animDefSize(a0)																																																					; code was last entry? yes, then delete bob
								beq						.toLiveAndDie

								lea						.1(pc),a5
								jmp						([bobCodeCases,pc,d4])																																																						; continues at .1
.toLiveAndDie

;	btst.b #attrIsAvail,objectListAttr(a6)
;	bne .rrr

	;ALERTSETLINE 10
.lea								lea						.lea+6(pc),a5
								jmp						(a5)
.animClrBob							; clear main parent object

								lea						objectList+4(pc),a0
								cmp.l					(a0)+,a6																																																									; is new free slot shot or crumbling shot?
								blo						.isLower

								cmp.l					(a0),a6																																																										; is new free slot lower than current pointer?
								bhs						.isHigherOrEqual
								move.l					a6,(a0)																																																										; update dynamic object pointer
.isLower
.isHigherOrEqual
								move.l					objectListMyChild(a6),a0
								clr						(a6)																																																										;objectListAnimPtr
								clr.l					objectListMyChild(a6)
								clr.l					objectListMyParent(a6)
								subq					#1,objCount
								tst.l					a0
								beq						animLooper																																																									; main object has child object? No!

								cmp.l					objectListMyParent(a0),a6																																																					; check valid relationship
								bne						animLooper																																																									; if parent!=child->leave

								move.l					objectList+4(pc),a3																																																							;  fetch object data table adress
								lea						-4(a3),a3
								move.w					objCount(pc),d0
								bra						.findAllChildren
.getChildOfMain     ; find all child-objects of main object

								moveq					#4,d4
								move					#((tarsMax+bulletsMax)/8)-1,d5																																																				; loop
.loop
								REPT					4
								adda.w					d4,a3
								tst						objectListAnimPtr(a3)																																																						;objectListAnimPtr
								bne.b					.getChildOfChild
								ENDR
								dbra					d5,.loop																																																									; if
								bra						animLooper

.getChildOfChild
								move.l					a3,a0																																																										; current object->a0
								cmp.l					objectListMyParent(a0),a6
								beq						.delChildOfChild																																																							; is child of main object? Yes!
								dbra					d0,.getChildOfMain																																																							; No. Continue search
								bra						animLooper

.delChildOfChild
								move.l					a0,a4																																																										; loop through parent-child-chain until last member
								movea.l					objectListMyChild(a4),a0
								clr						objectListAnimPtr(a4)
								clr.l					objectListMyChild(a4)
								clr.l					objectListMyParent(a4)
								clr.l					objectListMainParent(a6)
								subq					#1,objCount
								subq					#1,d0
								bmi						irqDidObjMoveManager																																																						; deleted all objects? Quit!
								cmp.l					a6,a4
								bls.b					.modifyLoopCount
								subq					#1,d7
.modifyLoopCount
								tst.l					a0
								bne						.delChildOfChild																																																							; last child deleted? No!
.findAllChildren
								dbra					d0,.getChildOfMain																																																							; deleted one main-child-chain. 							; Continue search of all of main-objects childs
animLooper
								dbra					d7,animLoop
								bra						irqDidObjMoveManager


; #MARK:  - OBJECT LIST MANAGER

objectListManager
; Eingangswerte:
    ;A2 =   objectList
    ;A3 =   bobpostab
    ;A4 =   objectDefinitionTable
    ;A5 =   pointer to vars
    ;A6 =   bobDrawList


								lea						animBasicOffsets(pc),a0																																																						; predefine basic anim offsets
								move.b					AudioRythmAnimOffset(pc),d6
								andi					#$f,d6
								move					d6,(a0)

								lea						vars(pc),a5
								clr.w					spriteCount+2-vars(a5)																																																						; 2.w = temp counter, static 1.w = static
								clr						shotCount-vars(a5)


								move.w					bobCountHitable-vars(a5),d0
								move.w					d0,bobCountHitable-vars+2(a5)
								clr						bobCountHitable-vars(a5)

								lea						memoryPointers(pc),a0
								move.l					collidingList+8-memoryPointers(a0),a6
								move.l					a6,collidingList-memoryPointers(a0)
								move.w					#collListBobOffset,d6
								adda.w					d6,a6
								move.l					a6,collidingList+4-memoryPointers(a0)

								move.l					bobDrawList+4(pc),a6

								move.l					objectList-memoryPointers(a0),a2
								subq.l					#4,a2

								move.w					viewPosition+viewPositionPointer(pc),d2

								move.l					spritePosMem-vars(a5),a0
								lea						spritePosMemSize-4(a0),a0
								move.l					a0,spritePosFirst																																																							; reset mem pointer to sprite with lowest y-coord

								IFNE					DEBUG
								clr.l					spritePosLast
								ENDIF

								clr.w					bobCount+2-vars(a5)

								move					objCount(pc),d3
								bra						objectListNextEntry
bobBlitLoop
								moveq					#4,d0
.findObject
								lea						4(a2),a2
								move					(a2),d0																																																										;objectListAnimPtr
								beq.b					.findObject

								lea						([animDefs-vars,a5],d0.w),a0
								clr.l					d4
								move.b					animDefType(a0),d4
								lea						([objectDefs,pc],d4.w*8),a4																																																					; Pointer to animDefinitions


								move					objectDefAttribs(a4),d0																																																						; fetch attribs and anim pointer

								tst.w					d0
								bpl						bobPrepareDraw																																																								; draw sprite or bob?
;   ****
;   add object to sprite dma list
;   ****
	;ALERT01 m2,d0
; #MARK:  prepare sprite lists

hybridSpriteJumpin
								moveq					#-100,d6
								add						objectListX(a2),d6

								move.w					#30,d5
								add						objectListY(a2),d5

								tst.l					objectListMyParent(a2)
								bne						.isChild - add parents coords
.retChild

								IFEQ					1																																																											; testing code which takes care of playershots y-pos / moving up / increased density on y-axis
								tst.w					plyBase+plyPosAcclY(pc)
								bpl						.22
								btst					#12,d0																																																										; is shot?
								beq.b					.22
								clr.l					d7
								move					plyBase+plyPosAcclY(pc),d7
								ext.l					d7
;	ALERT01 m2,d7
								lsl.l					#8,d7
								lsl.l					#4,d7
								add.l					d7,objectListY(a2)
.22
								ENDIF

   ;add.w plyPos+plyPosXDyn(pc),d6;;Convert absolute to relative Screenposition
								move.l					.xbounds(pc),d1																																																								; sprite within view?
								cmp						d1,d6
								bhi						.deleteSprite
								swap					d1
								cmp						d1,d6
								bls						.deleteSprite																																																								; exited to left border


	;sprite
								sub.w					viewPosition+viewPositionPointer(pc),d5																																																		; convert to absolute screenposition
								move.l					.ybounds(pc),d1
								cmp						d1,d5
								bge						.deleteSprite																																																								; exited border down
								swap					d1
								cmp						d1,d5
								ble						.deleteSprite																																																								; exited border up

								move					d5,d4																																																										; scale to possible slot in y-order, factor 24
								lsl						#3,d4																																																										;
								move.l					spritePosMem-vars(a5),a0
.spriteSort

								tst						(a0,d4.w)
								bne						.forceSlot																																																									; no empty slot? Force one!
.spriteSorted
								lea						(a0,d4.w),a0
								btst					#12,d0																																																										; is shot?
								bne						.addShotToColList																																																							; yes - add to shot collission list
	; check bullet background collission

								tst.b					objectListTriggers+3(a2)
								beq						.addedShotToColList
								move.w					d6,d4
								sub.w					#$1c,d4
	;sub.w plyPos+plyPosXDyn(pc),d4;Convert absolute to relative
								lsr						#3,d4																																																										; get x-pos-byte

								add.w					AddressOfYPosTable-($2a*2)(pc,d5.w*2),d4																																																	; add bitmap y-adress

								move.l					mainPlanesPointerAsync(pc),a3
	;move.l	mainPlanesPointer+8(pc),a3

	; use mainPlanesPointerAysnc instead for detection background detection, no objects
	; use mainPlanesPointer+8 instead for detection background detection and objects
								tst.b					(a3,d4.l)
								bne						.bckColKillBullet

.addedShotToColList
								add.w					plyPos+plyPosXDyn(pc),d6																																																					;Convert absolute to relative

								andi					#$3f,d0																																																										; sprite type
								ror						#6,d0
								or						d0,d6
								movem.w					d5/d6,(a0)
								addq					#1,spriteCount+2-vars(a5)
	;add #1,spriteCount+2
								cmpa.l					spritePosFirst-vars(a5),a0
								bhi.b					.refreshFirstYpos
								move.l					a0,spritePosFirst-vars(a5)																																																					; only store if new address is lower than old
.refreshFirstYpos

								IFNE					DEBUG
								cmpa.l					spritePosLast-vars(a5),a0
								bls.b					.refreshLastYpos
								move.l					a0,spritePosLast-vars(a5)																																																					; pointer to highest sprite adress
.refreshLastYpos




	; check for memory overflow
								move.l					spritePosMem-vars(a5),a1
								cmpa.l					a1,a0
								bls						.spriteError
								lea						spritePosMemSize-12(a1),a1
								cmpa.l					a1,a0
								bhi						.spriteError
								ENDIF
.eofSpriteLoop
								dbra					d3,bobBlitLoop
.eofSpriteList
								bra						objectListQuit
.forceSlot
; sprite sorter looks for free slot. if not available, find next free slot with. Upto 4 sprites with same y-coord
;    bra.w objectListNextEntry
 ;   moveq #3,d7
.findNiceSlot
								addq					#4,d4
								move					(a0,d4),d1
								beq						.spriteSorted
								cmp						d5,d1
								bls						.findNiceSlot
								bra.w					objectListNextEntry
.addShotToColList
								move.l					collidingList-vars(a5),a1																																																					;yes -> write to collission list
								move.l					a2,(a1)
								andi					#$1f,d0
								move					d0,d7
								movem.w					d5/d6/d7,collTableYCoords(a1)																																																				; write pure y-coord and x-coord to coll list (handling a little bit different for shots for optimized memory access). Write sprite number too
								moveq					#collListEntrySize,d7
    ;lea collidingList(pc),a1
								add.l					d7,collidingList-vars(a5)
								addq					#1,shotCount-vars(a5)
								bra						.addedShotToColList

.bckColKillBullet	; Bullet hit background - trigger particles, init bullet death

								sf.b					objectListTriggers+3(a2)																																																					; kill collission detection
								SAVEREGISTERS

								move.l					bascShtXAnimPointer(pc),a3
								move.w					animTablePointer+2(a3),(a2)																																																					; switch to bullet death anim

								move.b					#1,objectListCnt(a2)																																																						; set anim count manually for first frame

	; add particle system
								moveq					#-27,d3
								add.w					d6,d3
	;sub.w plyPos+plyPosXDyn(pc),d3;Convert absolute to relative
								lsl						#4,d3																																																										; set x-pos

								moveq					#-40,d4
								add.w					d5,d4
								lsl						#8,d4																																																										; set y-pos
								clr.w					d6																																																											; no x- and y-inertia
								clr.w					d5

								lea						emitterBulletHitsBck(pc),a0
								bsr						particleSpawn																																																								; call particleEmitter

								RESTOREREGISTERS
								bra						.addedShotToColList

								IFNE					DEBUG
.spriteError
								IFNE					SHELLHANDLING
								jsr						shellSpriteMemError
								ENDIF
								QUITNOW
.memCorrupt
								ENDIF
.xbounds
								dc.w					20,320
.ybounds
								dc.w					32,295

.isChild
								move.l					a2,a1																																																										; is children object -> add all parent coords
.readParent
								move.l					objectListMyParent(a1),a1
								tst.l					a1
								beq						.retChild
								add.w					objectListX(a1),d6
								add.w					objectListY(a1),d5
								bra.b					.readParent

.deleteSprite
								tst.l					objectListMyParent(a2)
								bne						objectListNextEntry																																																							; sprite is attached to parent object, let parent object do killjob
								move.l					emtyAnimAnimPointer(pc),a3
								move.w					animTablePointer+2(a3),(a2)
								move.b					#1,objectListCnt(a2)
								bra.w					objectListNextEntry

    ;!!!: Objectcode: code called each frame update. Usually used for bitmap animation, but can do other things too


;   ****
;   draw blitter object
;   ****
; #MARK:  prepare blitter objects



								moveq					#$1f,d0
								ror						#5,d0

bobPrepareDraw
								move.l					(a4),a0																																																										;objectDefSourcePointer
								adda.l					bobSource-vars(a5),a0																																																						; Adress of sourcebitmap
								andi					#$ff,d0
								jmp						([(animCases).w,pc,d0.w*8])																																																					; jump to specific anim code

;FIXME: Execute code only after draw-check
animReturn
								clr.l					d4
								clr.l					d7
								move.b					objectDefWidth(a4),d4																																																						; bob-Width in pixels
								move					d4,d5
								move					d4,d7
								addq					#7,d4
								lsr						#3,d4
								addq					#1,d4																																																										; bob-width for blitter

								clr.l					d6
								move					objectListX(a2),d6
								sub						d5,d6																																																										; center x-position


								move					objectListY(a2),a3
								tst.l					objectListMyParent(a2)
								bne						bobBlitIsChild
bobBlitChildReturn

								move					objectDefModulus(a4),d1
;	move d6,d0	; d6 = center coord
;	sub d5,d0	; d0 = leftmost x-coord
								add						d6,d5																																																										; d5 = rightmost x-coord

								move.l					collidingList+4(pc),a1
								move.l					a2,(a1)
								add.w					d5,d7
								movem.w					d6/d7,collTableXCoords(a1)																																																					; left / right border

	; check left clipping
								move					plyBase+plyviewLeftClip(pc),d0
								cmp.w					d0,d6																																																										;   bob outside left handside of view?
								ble						bobBlitCutLeft																																																								; yes - cut!

    ; check right clipping
								move					plyBase+plyviewRightClip(pc),d5
								cmp						d5,d7																																																										;leaves screen to the right?
								bgt						bobBlitCutRight

bobBlitDidHorizontalClip

								move					d1,(a6)																																																										;bobDrawBLTMOD
								clr.l					d0
								clr.l					d1
								clr.l					d5
								move.b					objectDefHeight(a4),d5
								move.b					d5,d0
								lsr						#1,d0

								move					a3,d1																																																										; y-pos relative
								sub						d2,d1																																																										; sub viewPositionPointer, get abs(y-pos)
								move					d1,d7
								add						d5,d7
								move.w					d1,collTableYCoords(a1)																																																						; write y-coord left corner to collission table
								moveq					#spriteDMAHeight-2,d0
								add						d7,d0
								move.w					d0,collTableYCoords+2(a1)																																																					; write y-coord right corner
				; d5 = bobhoee
				; d1 = bobypos

	;check clip view upper border
								move					#viewUpClip,d0
								cmp						d0,d1
								blt						bobBlitCutUp

	;check clip view lower border
								move.w					#viewDownClip,d0																																																							; attn.! value modified in player manager
								cmp						d0,d7
								bhi						bobBlitCutDown

addToColTable
								btst.b					#attrIsNotHitable,objectListAttr(a2)
								bne.b					.notHitable
								moveq					#collListEntrySize,d7
								add.l					d7,collidingList+4-vars(a5)
								addq					#1,bobCountHitable-vars(a5)
.notHitable

								move.w					AddressOfYPosTable(pc,d1*2),d1																																																	; get y-positions memory offset

								sub						#viewXOffset,d6
								move					d6,d0
								lsr						#3,d6

								subq.l					#4,d1
								add.l					d6,d1																																																								; add x-position to mainplane pointer
								bclr					#0,d1

								move					d0,d7
								moveq					#$f,d6
								and.l					d6,d7
								beq						blitZeroX																																																									; word-aligned blit, no pixelshift? Reduce blit size!

retBlitZeroX
								ror						#4,d7
								btst					#1,objectListHit+1(a2)																																																						; stamp
								bne						hitDisplay
								or						#$0fca,d7
drawBob
								move.l					a0,bobDrawSource(a6)																																																						; store source adress
								move.w					objectDefMask(a4),a0																																																						; get source mask offset
								movem.w					d1/d7/a0,bobDrawTargetOffset(a6)																																																		; store pointer to target adress, bltcon0, source mask offset,

								lsl						#8,d5																																																										; x 4 for 4 bitplanes, add bob height to blit control word
								or						d5,d4

								IFNE					DISABLEOPAQUEATTRIB
								btst.b					#attrIsOpaq,objectDefAttribs(a4)
								bne						blitEnableOpaque
retblitEnableOpaque
								ENDIF

								IFNE					BLITNORESTOREENABLED
								btst					#attrIsOpaq,objectDefAttribs(a4)
								bne						bobIsOpaque
bobRetIsOpaque
								ENDIF
								move					d4,bobDrawBLTSIZE(a6)
								add						#1,bobCount+2-vars(a5)
								cmp.l					bobDrawList+16(pc),a6
								bcc						objectListQuit
								lea						bobDrawListEntrySize(a6),a6

objectListNextEntry
								dbra					d3,bobBlitLoop

objectListQuit
								clr.l					(a6)																																																										;mark eof bobdrawlist

	; check amount of objects. If too many: forbid new objects spawning

								clr.w					objectWarning-vars(a5)
								move.w					spriteCount+2-vars(a5),d0
								move.w					d0,spriteCount-vars(a5)
								cmpi					#bulletsMax-1,d0
								bhi						issueWarningSprites

								move.w					bobCount+2-vars(a5),d0
								move.w					d0,bobCount-vars(a5)
								cmpi					#tarsMax,d0
								bhi						issueWarningBobs
								rts
blitZeroX
								sub						#1,d4																																																										; modify blitsize
								add						#2,(a6)																																																										; modify modulus
								bset					#15,(a6)																																																									; flag for use in blittermanager
								bra						retBlitZeroX
hitDisplay
								bchg					#0,objectListHit+1(a2)
								btst					#0,objectListHit+1(a2)
								beq.b					.keepHitMarker2
								andi.b					#$fc,objectListHit+1(a2)
.keepHitMarker2
								or						#$0ffa,d7
								bra						drawBob

bobBlitIsChild
								move.l					a2,a1																																																										; is children object -> add all parent coords
.readParent
								move.l					objectListMyParent(a1),a1
								tst.l					a1
								beq						bobBlitChildReturn
								add.w					objectListX(a1),d6
								add.w					objectListY(a1),a3
								bra.b					.readParent


bobBlitCutLeft
								move					d0,d7
								sub						d6,d7																																																										; left hangover

								add.w					plyBase+plyPosXDyn(pc),d6
								andi					#$f,d6
								add						d0,d6
								add						#1,d6																																																										; new x-coord

								lsr						#4,d7
								add						#1,d7
								sub						d7,d4																																																										; new blit x-size
								cmpi					#2,d4																																																										; x-blitsize < 2?
								blt						objectListNextEntry																																																							; yes - out of view
								lsl						#1,d7																																																										; only 2,4,6 ...
								add						d7,a0																																																										; modify bitplane fetch adress
								add						d7,d1																																																										; ... and modulo
								bra						bobBlitDidHorizontalClip
bobBlitCutRight
								sub						d5,d7
								lsr						#4,d7
								add						#1,d7
								sub						d7,d4
								cmpi					#2,d4																																																										; x-blitsize < 2?
								blt						objectListNextEntry																																																							; yes - out of view
								lsl						#1,d7
								add						d7,d1
								bra						bobBlitDidHorizontalClip

bobBlitCutUp
								sub						d0,d1
	;sub #3,d1
								neg						d1
								sub						d1,d5
								ble.w					objectListNextEntry
    ;add.l (a1,d1*4),a0
								clr.w					d0
								move.w					objectDefModulus(a4),d0
								addq					#2,d0
								clr.w					d7
								move.b					objectDefWidth(a4),d7
								lsr.w					#2,d7
								add.w					d7,d0
								lsl.w					#2,d0
								muls					d0,d1
								adda.w					d1,a0																																																										; modify source adress

								clr.l					d1
								move					#viewUpClip,d1																																																								; topmost y-coord
								bra						addToColTable
bobBlitCutDown
								sub						d0,d7
								sub						d7,d5
								bmi.w					objectListNextEntry
								addq					#1,d5
								bra						addToColTable

								IFNE					DISABLEOPAQUEATTRIB
blitEnableOpaque
								bset					#15,bobDrawMaskOffset(a6)
	;sub.b #1,d4		; modify blitsize
	;add #2,(a6)		; modify modulus
	;cmpi.b #$ca,d7
	;beq retblitEnableOpaque
								move.l					a0,d0
								add.l					d0,bobDrawSource(a6)																																																						; store source adress
								bra						retblitEnableOpaque
								ENDIF

								IFNE					BLITNORESTOREENABLED
bobIsOpaque
								bset					#15,d7
								bra						bobRetIsOpaque
								ENDIF

issueWarningSprites
								ALERT01					msgTooManySprites,spriteCount(pc)
								st.b					objectWarning+1-vars(a5)
								rts
issueWarningBobs
								ALERT01					msgTooManyObjects,bobCount(pc)
								st.b					objectWarning-vars(a5)
								rts



AddressOfYPosTable 		; Convert y-coord to bitplane y-addr-offset
.temp							SET						0
								REPT					257
								dc.w					.temp
.temp							SET						.temp+mainPlaneDepth*mainPlaneWidth
								ENDR
AddYSmoothScroll
.clip							SET						(mainPlaneWidth*mainPlaneDepth)*(viewUpClip)
								REPT					4
								dc.w					.clip
.clip							SET						.clip+mainPlaneDepth*mainPlaneWidth
								ENDR

; #MARK:  - COLLISSION MANAGER

collisionManager

								move					shotCount(pc),d7
								beq						irqDidColManager																																																							; back to IRQ

								move.l					collidingList+8(pc),a3
								move.l					a3,a2
								lea						collListBobOffset(a2),a2
								move.l					a3,a5																																																										; load adress of collision table
								moveq					#collListEntrySize,d4
								move.l					d4,a4																																																										; preload some registers...

								clr.l					d0
								clr.l					d1
								clr.l					d2
								subq					#1,d7
								move					d7,d6

								move					bobCountHitable(pc),a1
								tst.w					a1
								beq						.chkBckCol
								moveq					#-34,d1																																																										; y-offset
								sub.w					#1,a1

								lea						collTableYCoords(a2),a0

								move					#$81,a2																																																										; x-offset (increase value -> move hitbox left
	;move plyBase+plyPosXDyn(pc),d4
	;sub d4,a2

.loadShot
								move					d1,d0
								add.w					collTableYCoords(a5),d0																																																						; load shot y-coords

								move					a1,d6																																																										; no of hitable objects
								move.l					a0,a6

								move.w					a2,d2
								add.w					collTableXCoords-2(a5),d2																																																					; load shot x-coords; memory optimized for shots
	;MSG03 m2,d2
	;sub.w #10,d2	; optimal for 32 px objects
	;sub.w #32,d2	; optimal for 32 px objects
								move.w					8(a5),d4																																																									; get sprite number
.chkBob

								move.l					(a6),d5
								cmp2.w					(a6),d0																																																										;chk y-collissionbox collTableYCoords
								bcs.b					.noYCol																																																										; is higher or lower? Skip!

								move.l					4(a6),d5
								cmp						d5,d2
								bgt.b					.noYCol
								swap					d5
								sub.w					(.colXWidth,pc,d4*2),d5
								cmp						d5,d2
								bge						.hitObjectBox
    ;cmp2.w 4(a6),a2; modified pointer to collTableXCoords
    ;bcc.w hitObject
.noYCol
								add.l					a4,a6
								dbra					d6,.chkBob
								add.l					a4,a5
								dbra					d7,.loadShot

	; #MARK:  check hit static
.chkBckCol

								lea						AddressOfYPosTable(pc),a0
								move.l					mainPlanesPointerAsync(pc),a1
								lea						24(a1),a1																																																									; add x offset
								lea						80(a1),a1
	;move.l mainPlanesPointer(pc),a1
	;move.l mainPlanesPointer+4(pc),a2
	;move.l mainPlanesPointer+8(pc),a4


								moveq					#20,d5
								clr.l					d1
								clr.l					d2
								moveq					#collListEntrySize,d4
								moveq					#4,d7
								moveq					#-48,d0																																																										;y-offset
								move					#$1a3,d5																																																									;x-offset (159 if bitexact collission check)
	;sub.w plyPos+plyPosXDyn(pc),d5
								move.l					a3,a6
								lea						28,a5
								lea						$10,a4																																																										; upper border check
								lea						$2d8,a3																																																										; right border check
								move					shotCount(pc),d3
								bra						.firstLoop

	; #MARK:  check hit object
.hitObjectBox
								lea						AddressOfYPosTable(pc),a2
								move.l					mainPlanesPointer+4(pc),a1
								moveq					#-36,d4																																																										;y-offset
    ;moveq #0,d4
								clr.l					d5
								move					#$120,d5																																																									;x-offset
	;sub.w plyBase+plyPosXDyn(pc),d5
								move.w					#-4*mainPlaneDepth*mainPlaneWidth,d3
								add.w					collTableYCoords(a5),d4																																																						; load player y-coords

								move.w					(a2,d4.w*2),d4																																																								; y bitmap offset
								lea						(a1,d4.w),a1

								add.w					collTableXCoords-2(a5),d5
								ror.l					#3,d5
								lea						(a1,d5.w),a1																																																								; add x-byte-offset
								clr.w					d5
								swap					d5
								rol						#3,d5																																																										; put bit pointer in place
	; hitbox check triggered. Now check if actual pixels have been hit
	;bfset (a1,d3.w*2){d5:20}
	;bfset (a1){d5:20}
 	;bra .chkBckCol
								bftst					(a1){d5:20}
								bne						hitObject
								bftst					(a1,d3.w){d5:20}
								bne						hitObject
								bra						.chkBckCol

.chkBckLoop
								move					d0,d1
								add.w					collTableYCoords(a6),d1																																																						; load shot y-coords
								cmp.w					a4,d1
								ble						.skipTest																																																									; close to upper border? Skip!
								clr.l					d2
								move.w					(a0,d1.w*2),d2																																																								; y bitmap offset
								move.w					collTableXCoords-2(a6),d1																																																					; load shot x-coords
								cmp.w					a5,d1
								bls						.skipTest																																																									; offscreen to the left
								add.w					d5,d1
								cmp.w					a3,d1
								bhi						.skipTest																																																									; bullet offscreen to the right?
								move					d1,d6
								lsr						d7,d1
								lsl						#1,d1
								add.w					d1,d2																																																										; add x-byte-offset

								move.w					d6,d1
								andi.w					#%1111,d1																																																									; define left bit border
								move					collTableXCoords(a6),d6																																																						; get sprite number
								add.w					((.bitModifier).W,pc,d6.w*2),d6																																																				; define width of bitfield test
	;bfset (a1,d2.l){d1:d6}

								bftst					(a1,d2.l){d1:d6}
								bne.b					.hitBackground
.skipTest
								adda					d4,a6
.firstLoop
								dbra					d3,.chkBckLoop
.colQuit
								bra						irqDidColManager
.bitModifier
								dc.w					8,14,14,14
.colXWidth
								dc.w					11,18,18,18
.hitBckCoords
								dc.l					$00e0ffec,$00e0ffec																																																							; main shot 0 and 1, 0.w = y-offset 1.w = x-offset
								dc.l					$00e8fff8,$00e8fff0																																																							; right xtra shot, left xtra shot

	; #MARK:  hit static background

.hitBackground		; hit static background, draw damage

								tst.b					dialogueIsActive(pc)
								bne						irqDidColManager																																																							; dialoge running->no shot<->bckgnd check

	;bra .skipBckMod
								moveq					#mainPlaneWidth+16,d7
								sub.l					d7,d2

								lea						fastRandomSeed(pc),a2
								movem.l					(a2),d0/d7																																																									; AB
								swap					d7																																																											; DC
								add.l					d7,(a2)																																																										; AB + DC
								add.l					d0,4(a2)																																																									; CD + AB
								andi.w					#$7,d0
								add.w					AddressOfYPosTable(pc,d0*2),d2																																																				; add randomness to y-position
	;move.w AddressOfYPosTable(pc,d0*2),d0; add randomness to y-position
								andi					#$7,d7
								add.b					d7,d1																																																										; add some randomness to x-position
								move.l					d1,d0
								lsr						#2,d7
								add						d7,d1																																																										; modify x-position of upper line
								moveq					#2,d6
								lea						mainPlanesPointer(pc),a2
								move.l					fxPlanePointer(pc),a4
								lea						-mainPlaneWidth*7(a4),a4
.outerLoop
								move.l					(a2)+,a1																																																									; loop 3 times -> three viewport buffers
								lea						(a1,d2.l),a1																																																								; add x- and y-offset
								lea						mainPlaneWidth*4*256(a1),a3																																																					; load pointer to 2nd screenbuffer
								cmp.l					a4,a3																																																										; memory bound check - overrun?
								ble						.loop
								lea						-mainPlaneWidth*4*256(a1),a3																																																				; yes. Modify pointer
.loop
	   ; bfclr (a1){d1:1}	; clear bits in main view - upper line
								bfclr					mainPlaneWidth(a1){d1:1}
								bfclr					mainPlaneWidth*2(a1){d1:1}																																																					; two added bits -> shading
								bfclr					mainPlaneWidth*3(a1){d1:1}
								lea						mainPlaneWidth*4(a1),a1
	    ;bfclr (a1){d0:2}	; lower line
								bfclr					mainPlaneWidth(a1){d0:2}
								bfclr					mainPlaneWidth*2(a1){d0:2}
								bfclr					mainPlaneWidth*3(a1){d0:2}

	    ;bfclr (a3){d1:2}	; clear bits in secondary view
								bfclr					mainPlaneWidth(a3){d1:2}
								bfclr					mainPlaneWidth*2(a3){d1:2}
								bfclr					mainPlaneWidth*3(a3){d1:2}
								lea						mainPlaneWidth*4(a3),a3
	    ;bfclr (a3){d0:2}
								bfclr					mainPlaneWidth(a3){d0:4}
								bfclr					mainPlaneWidth*2(a3){d0:4}
								bfclr					mainPlaneWidth*3(a3){d0:4}
								dbra					d6,.outerLoop
.skipBckMod
								move.l					(a6),a0																																																										; collTableAnimActionAdr -switch to exit anim
								move					collTableXCoords(a6),d0																																																						; get sprite number
								andi					#$1f,d0

								move.l					([hitObjAnim.W,pc,d0.w*4]),a1																																																				; get exit anim adress
								move.w					animTablePointer+2(a1),(a0)																																																					;
								move.b					#6,objectListCnt(a0)																																																						;

								PLAYFX					9
								move.l					((.hitBckCoords).W,pc,d0.w*4),d4																																																			; modify coords for perfekt particle spawn
								move					d4,d3
								swap					d4
spawn
								add.w					collTableYCoords(a6),d4																																																						; load shot y-coords
								clr.w					d5
    ;move.w plyBase+plyPosXDyn(pc),d6
    ;sub d6,d3
								clr.w					d6
								add.w					collTableXCoords-2(a6),d3																																																					; load shot x-coords
								lsl						#4,d3
								lsl						#8,d4
								lea						emitterHitA(pc),a0
								pea						irqDidColManager(pc)																																																						; push fake rts adress
								bra						particleSpawn																																																								; call particles subroutine

hitObjAnim
								dc.l					cPlyShAXAnimPointer,	cPlyShBXAnimPointer																																																	; pointers to basic exit anims
								dc.l					cPlyShCXAnimPointer, cPlyShDXAnimPointer


	; #MARK:  hit moving object

hitObject                   ; hit moving object. A5 = pointer to bullet adress, A6=pointer to target adress

								lea						plyBase(pc),a1
								add.w					#1,plyShotsHitObject(a1)																																																					; reward accuracy in stage exit view
								move					collTableXCoords(a5),d0																																																						; get sprite number
								andi					#$1f,d0
								move.l					([hitObjAnim.W,pc,d0.w*4]),a1																																																				; get new anim adress
								suba.w					#4,a6
								move.l					(a5),a0																																																										; collTableAnimActionAdr- handle player shot

								lea						scoreMultiplier+4(pc),a4
								move.l					a0,(a4)																																																										; make available to chain score sprite spawn

								move.w					animTablePointer+2(a1),(a0)																																																					; objectListAnimPtr. object hit, change to exit-animation

								move.b					#6,objectListCnt(a0)
								move.l					(a6),a0																																																										; collTableAnimActionAdr - handle attacker object

								clr.l					d7
								clr.l					d5
								move.b					objectListAttr(a0),d6
								btst					#2,d6
								beq						singleObject

								tst.l					objectListMainParent(a0)																																																					; is child object?
								bne						.hitRelatedObject
								tst.l					objectListMyChild(a0)																																																						; is main parent?
								bne						.hitRelatedObject


;    move bobCountHitable(pc),d0                 ; hit group of objects
								move					objCount(pc),d6
								move.l					objectList(pc),a1

								suba.w					#4,a1
								move.w					objectListGroupCnt(a0),d3
								tst.w					objectListHit(a0)
								beq						hitObjectIsInvulnerable
								andi					#$fffc,objectListHit(a0)

								subq.w					#4,objectListHit(a0)
								IFEQ					MENTALKILLER
    ;bcs colHitKill
								beq						colHitKill
								bmi						colHitKill
								tst.b					plyBase+plyCheatEnabled(pc)
								bne						colHitKill
								ELSE
								move.w					#-1,objectListHit(a0)
								bra						colHitKill
								ENDIF
								move.w					objectListHit(a0),d0
								or.b					#$3,d0

; hit group / no destruction

								IFEQ					OBJECTSCORETEST
								ADDSCORE				1
								ENDIF
								move.w					#4,a4
.animsrchlist
								adda.w					a4,a1
								tst						(a1)
								beq.b					.animsrchlist
								btst.b					#2,objectListAttr(a1)
								beq.b					.noGroupedObject
								move.w					objectListGroupCnt(a1),d4
								cmp.w					d3,d4
								bne.b					.noGroupedObject
								move.l					a1,a6
								move.w					d0,objectListHit(a1)
.noGroupedObject
								dbra					d6,.animsrchlist
								move.l					a1,a6
								bra						colHit

; hit related object / no destruction

.hitRelatedObject
								IFEQ					OBJECTSCORETEST
								ADDSCORE				1
								ENDIF

								move.l					objectListMainParent(a0),a6																																																					; fetch main parent
								tst.l					a6
								bne						.hitChild
								move.l					a0,a6																																																										; use parent adress
.hitChild

								tst.w					objectListHit(a6)
								beq						hitObjectIsInvulnerable


								andi					#$fffc,objectListHit(a6)
								subq.w					#4,objectListHit(a6)

								IFEQ					MENTALKILLER
								bmi						colHitKill
								beq						colHitKill
								tst.b					plyBase+plyCheatEnabled(pc)
								bne						colHitKill
								ELSE
								move.w					#-1,objectListHit(a0)
								bra						colHitKill
								ENDIF
	;btst #2,objectListAttr(a2)
	;beq colHit
								move.w					objectListHit(a6),d0
								or.b					#$3,d0
.loopRelationship
								move.w					d0,objectListHit(a6)																																																						; mark every child as hitframe

								move.l					objectListMyChild(a6),a6
								tst.l					a6
								bne						.loopRelationship
								bra						colHit


singleObject

								clr.l					d0
								tst.w					objectListHit(a0)
								beq						hitObjectIsInvulnerable																																																						; object hitable, not destroyable

								andi					#$fffc,objectListHit(a0)
								subq.w					#4,objectListHit(a0)																																																						; hit single object
    ;bcs colHitKill                                 ; hit but hitpoints left
								IFEQ					MENTALKILLER
								beq						colHitKill
								bmi						colHitKill
								tst.b					plyBase+plyCheatEnabled(pc)
								bne						colHitKill
								ELSE
								move.w					#-1,objectListHit(a0)
								bra						colHitKill
								ENDIF
								or.b					#$3,objectListHit+1(a0)																																																						; init blitz
								move.l					a0,a6
          ; hit objects / not destroyed
								clr.w					d0
								add.w					objectListHit(a6),d0
colHit
								lsr						#2,d0
								add						#periodBase,d0
								lea						(fxImpactEnem*fxSizeOf)+fxTable+6-12(pc),a0
								move.w					d0,(a0)																																																										; store modified hitpoints -> fx pitch
								IFEQ					OBJECTSCORETEST
								ADDSCORE				1
								ENDIF
								PLAYFX					fxImpactEnem
; particles after hit moving object
spawnHitParticles
;	bra irqDidColManager

	;move #$a0,a3	; calc x-position of particle emitter

		;move.l #$30,d4
		;move.l #$
		;	bra spawn
;	clr.l d3
    ;sub.w plyBase+plyPosXDyn(pc),d3
;	sub #18,d3
								moveq					#-18,d3
								add.w					collTableXCoords-2(a5),d3
								move					d3,d5
								lsr						#4,d5
								sub						#8,d5																																																										; start particles with some "drall"
								lsl						#4,d3
								moveq					#-27,d4
								add.w					collTableYCoords(a5),d4
								clr.w					d6
								lsl						#8,d4

								lea						emitterHitA(pc),a0																																																							; switch two emitters randomly
								btst					#1,frameCount+5(pc)
								beq						.keepA
								lea						emitterHitB-emitterHitA(a0),a0
.keepA
								pea						irqDidColManager(pc)																																																						; push fake rts adress
								bra						particleSpawn																																																								; call subroutine

hitObjectIsInvulnerable
								PLAYFX					9
								bra						spawnHitParticles

		; #MARK:  killed moving object

colHitKill
								tst.l					objectListMyChild(a0)
								bne						.singleOrFamilyObject
								tst.l					objectListMyParent(a0)
								bne						.singleOrFamilyObject																																																						; prioritize related objects to grouped objects

								btst.b					#2,objectListAttr(a0)
								bne						.killGroupedObject																																																							; hit object of grouped origin

.singleOrFamilyObject
								move.l					objectListMainParent(a0),d0
								beq						.singleObject
								move.l					d0,a0																																																										; get main parent
.singleObject
								clr.l					d5																																																											; hit and killed
								move					(a0),d5																																																										;objectListAnimPtr
								move.l					(animDefs,pc),a6
								lea						(a6,d5),a6
								clr.l					d4
								move.b					animDefType(a6),d4
								move.l					(objectDefs,pc),a4
								lea						(a4,d4*8),a4
								move					objectDefScore(a4),d0
								add.w					d0,scoreAdder

								bclr.b					#1,objectListHit+1(a0)

								tst.b					objectListDestroy(a0)
								bne						.destroySpecial
.retDestrSpecNotGrouped

								clr.w					d0
								move.b					objectDefHeight(a4),d0
								cmpi.b					#48,d0
								bhi						.explLrg
								cmpi.b					#16,d0
								bhi						.explMed

		; #MARK:  init small explosion
.explSml
								move.l					cExplSmlAnimPointer(pc),a4
								move.w					animTablePointer+2(a4),(a0)																																																					; objectListAnimPtr. object hit, change to explosion animation

								andi.b					#%10111010,objectListAttr(a0)																																																				; clr opaque, group, refresh  bit
								bset					#attrIsNotHitable,objectListAttr(a0)																																																		; set not hitable bit

								move.b					#31,objectListCnt(a0)

								move.w					viewPosition+viewPositionAdd(pc),d6
								lsl						#8,d6
								add						#-80,d6
								move.w					d6,objectListAccY(a0)
								move					frameCount+4(pc),d0
								andi					#%1110,d0
								sub						#%1110>>1,d0
								lsl						#4,d0
								move					d0,objectListAccX(a0)																																																						; vary x-acceleration a little bit


;    clr.w objectListAccX(a0)
.addSoundFX
								PLAYFX					3
								bra						.parentalCheck

	; #MARK:  init medium explosion

.explMed

								move.l					cExplMedAnimPointer(pc),a1
								move.w					animTablePointer+2(a1),(a0)																																																					; objectListAnimPtr. object hit, change to explosion animation

								andi.b					#%10111010,objectListAttr(a0)																																																				; clr opaque, group, refresh   bit
								bset					#attrIsNotHitable,objectListAttr(a0)																																																		; set not hitable bit
								move.b					#$3f,objectListCnt(a0)

								move.w					viewPosition+viewPositionAdd(pc),d6
								lsl						#8,d6
								move.w					d6,objectListAccY(a0)
								move					frameCount+4(pc),d0
								andi					#%1110,d0
								sub						#%1110>>1,d0
								lsl						#4,d0
								move					d0,objectListAccX(a0)																																																						; vary x-acceleration a little bit

								move.l					a0,a6
								move.l					cExplSmlAnimPointer(pc),a4
								move.w					animTablePointer+2(a4),d4																																																					;add small explosion just for the looks...
								move					#144,d5
	;add.w plyBase+plyPosXDyn(pc),d5
								add.w					collTableYCoords+2(a5),d5																																																					; get x-coord from shot
								move.w					#-10,d6
								add						objectListY(a0),d6																																																							; get y-coord
								st.b					d3
								bsr.w					objectInit
								tst.l					d6
								bmi						irqDidColManager
;    move #0,objectListHit(a4); hitpoints
								move.b					#attrIsNotHitableF,objectListAttr(a4)																																																		; attribs

								move.b					#$7f,objectListCnt(a4)
								add						#-$380,objectListAccY(a4)
	;clr.w objectListAccY(a4)
								andi					#%11100000,d6
								sub						#%11100000>>1,d6
								move					d6,objectListAccX(a4)																																																						; vary y-acceleration a little bit
								PLAYFX					4

.parentalCheck
								tst.l					objectListMyChild(a0)
								bne.b					.isParent																																																									; hit object is parent?
								tst.l					objectListMyParent(a0)
								bne.b					.isParent																																																									; hit object is child?

								move.b					objectListWaveIndx(a0),d7
								tst.b					objectListWaveIndx(a0)
								bpl						.isWave
								bra						irqDidColManager

.isParent		; find child objects
								move.l					objectListMainParent(a0),a6																																																					; get main parent of hit object.
								tst.l					a6																																																											; is hit object main parent itself?
								bne						.hitChild																																																									; no
								move.l					a0,a6																																																										; yes. copy main parent adress at relevant registers
.hitChild
								move.l					objectListMyChild(a6),a5																																																					; get first child of main parent
								move.l					objectListX(a6),d6																																																							; get world coords main parent
								move.l					objectListY(a6),d7

.loopRelatives
								move.w					(a5),d5																																																										;objectListAnimPtr
								lea						([animDefs,pc],d5.w),a1
								clr.w					d5
								move.b					animDefType(a1),d5
								lea						([objectDefs,pc],d5.w*8),a1																																																					; Pointer to ObjectDefinitions
								move.b					objectDefHeight(a1),d5																																																						; fetch size of object

								cmpi.b					#35,d5
								shi						d4
								cmpi.b					#16,d5
								shi						d5
								andi.b					#16,d5
								andi.b					#16,d4
								add.b					d4,d5																																																										; and determine size of explosion
								move.l					cExplSmlAnimPointer(pc,d5.w),a1
								move.w					animTablePointer+2(a1),(a5)																																																					; objectListAnimPtr. object hit, change to explosion animation

								andi.b					#%10111010,objectListAttr(a5)																																																				; clr opaque, group, link   bit
								bset					#attrIsNotHitable,objectListAttr(a5)																																																		; set not hitable bit

								lsl						objectListAccY(a5)																																																							; improve dynamics
								lsl						objectListAccY(a5)

								lsl						objectListAccX(a5)																																																							; improve dynamics
								lsl						objectListAccX(a5)

								move.b					#31,objectListCnt(a5)																																																						; duration of child explosion
								move.b					#1,objectListLoopCnt(a5)																																																					;

								move.w					objectListX(a5),d4
								lsl						#4,d4
								move.w					d4,objectListAccX(a5)

								add.l					objectListX(a5),d6
								move.l					d6,objectListX(a5)																																																							; modify object position to make it work without parent relationship


								add.l					objectListY(a5),d7
								move.l					d7,objectListY(a5)																																																							; ""

								clr.l					objectListMyParent(a5)																																																						; cancel relationship to enhance explosion dynamics, and enhance object management reliability
								clr.l					objectListMainParent(a5)
.isMainParent
								move.l					objectListMyChild(a5),d5
								clr.l					objectListMyChild(a5)
								move.l					d5,a5
								tst.l					a5
								bne						.loopRelatives
								bra						irqDidColManager


	; #MARK:  init large explosion

.explLrg
								move.l					cExplLrgAnimPointer(pc),a1
								move.w					animTablePointer+2(a1),(a0)																																																					; objectListAnimPtr. object hit, change to explosion animation
								andi.b					#%10111010,objectListAttr(a0)																																																				; clr opaque, group   bit
								bset					#attrIsNotHitable,objectListAttr(a0)																																																		; set not hitable bit
								move.b					#$31,objectListCnt(a0)

								move.w					viewPosition+viewPositionAdd(pc),d6
								lsl						#8,d6
								move.w					d6,objectListAccY(a0)
								move					frameCount+4(pc),d0
								andi					#%1110,d0
								sub						#%1110>>1,d0
								lsl						#4,d0
								move					d0,objectListAccX(a0)																																																						; vary x-acceleration a little bit

	;bra .parentalCheck

								move.l					cExplSmlAnimPointer(pc),a1
								move.w					animTablePointer+2(a1),d4																																																					;add med explosion replacing shot
								move					#134,d5
	;sub.w plyBase+plyPosXDyn(pc),d5
								add.w					collTableYCoords+2(a5),d5																																																					; get x-coord from shot
								moveq					#40,d6
								add						objectListY(a0),d6																																																							; get y-coord
								st.b					d3
								bsr.w					objectInit
								tst.l					d6
								bmi						irqDidColManager																																																							; back to IRQ
        ;move #0,objectListHit(a4); hitpoints
								move.b					#attrIsNotHitableF,objectListAttr(a4)																																																		; attribs
								move.w					viewPosition+viewPositionAdd(pc),d6
								add.w					#-$480,d6
								move.w					d6,objectListAccY(a4)
								move.b					#$2c,objectListCnt(a4)

								move.l					cExplMedAnimPointer(pc),a1
								move.w					animTablePointer+2(a1),d4																																																					;add med explosion just

								moveq					#-22,d5
								add.w					objectListX(a0),d5																																																							; get x-coord from shot
								moveq					#20,d6
								add						objectListY(a0),d6																																																							; get y-coord

								st.b					d3
								bsr.w					objectInit
								tst.l					d6
								bmi						irqDidColManager																																																							; back to irq
    ;move #0,objectListHit(a4); hitpoints
								move.b					#attrIsNotHitableF,objectListAttr(a4)																																																		; attribs
								sub						#$400,objectListAccY(a4)
								move					#-565,objectListAccX(a4)
								move.b					#$1f,objectListCnt(a4)

								move.l					cExplMedAnimPointer(pc),a1
								move.w					animTablePointer+2(a1),d4
    ;add explosion just for the looks...
								moveq					#20,d5
								add.w					objectListX(a0),d5																																																							; get x-coord from shot
								moveq					#-10,d6
								add						objectListY(a0),d6																																																							; get y-coord
								st.b					d3
								bsr.w					objectInit
								tst.l					d6
								bmi						irqDidColManager																																																							; back to IRQ
								sub						#$450,objectListAccY(a4)
								move					#625,objectListAccX(a4)
								move.b					#$17,objectListCnt(a4)																																																						; hitpoints
								move.b					#attrIsNotHitableF,objectListAttr(a4)																																																		; attribs

								PLAYFX					5
								bra						.parentalCheck
.addSmlExplosion


	; kill tentactle and other grouped objects

.killGroupedObject

								move					(a0),d5																																																										;objectListAnimPtr	; get score
								move.l					(animDefs,pc),a5
								lea						(a5,d5),a5
								clr.l					d4
								move.b					animDefType(a5),d4
								move.l					(objectDefs,pc),a4
								lea						(a4,d4*8),a4
								move					objectDefScore(a4),d1
								clr.w					d5																																																											; hit and killed
								move.b					objectDefHeight(a4),d5
								move.w					d5,d4
								lsr						#1,d4
								add.w					d4,objectListY(a0)
	;move.w d5,d4
								lea						scoreAdder(pc),a3

								move.w					#4,a4

								cmpi.b					#160/2,d5
								shi						d7
								cmpi.b					#35/2,d5
								shi						d5
								andi.b					#16,d5
								andi.b					#16,d7
								add.b					d7,d5
								move.l					cExplSmlAnimPointer(pc,d5.w),a5
								move.w					animTablePointer+2(a5),d7
								moveq					#31,d6
								sub.w					a6,a6

								move.w					viewPosition+viewPositionAdd(pc),d2
								lsl						#8,d2
								add						#-30,d2

								move.l					objectList+4(pc),a1
								lea						-4(a1),a1
								move.w					objectListGroupCnt(a0),d3

								move.w					objCount(pc),d0
								sub.w					shotCount(pc),d0
								sub						#1,d0
.animsrchlistX
								adda.w					a4,a1
								tst.w					(a1)
								beq.b					.animsrchlistX
								btst.b					#attrIsLink,objectListAttr(a1)
								beq.b					.noGroupedObjectX
								move.w					objectListGroupCnt(a1),d4
								cmp.w					d3,d4
								bne.b					.noGroupedObjectX
								tst.w					a6
								beq.b					.cancelGroup
.return
	;MSG01 m2,d4
	;add.w d4,objectListY(a1)


								move.w					d7,(a1)																																																										; objectListAnimPtr. object hit, change to explosion animation
								andi.b					#%10111011,objectListAttr(a1)																																																				; clr opaque, group   bit
								bset					#5,objectListAttr(a1)																																																						; set not hitable bit

	;add.w d2,objectListAccY(a1)

	;lsl objectListAccY(a1)       ; vary y-acceleration a little bit

	;lsl objectListAccX(a1)       ; vary y-acceleration a little bit
								move					d0,d5
								lsl						#1,d5
								andi					#$f,d5
								add.w					d6,d5
								move.b					d5,objectListCnt(a1)
								add						d1,(a3)

	;pea .noGroupedObjectX(pc)
	;tst.b objectListDestroy(a0)
	;bne .destroySpecial
	;addq #4,sp
.noGroupedObjectX
	;bra irqDidColManager
								dbra					d0,.animsrchlistX


								PLAYFX					5
								bra						irqDidColManager
.cancelGroup	; modify counter in case linked group has not yet fully spawned before hitpoints=0
								add						#1,a6
								move.l					objectListLaunchPointer(a1),a5
								tst.l					a5																																																											; some object waves are not listlaunched, but manually linked. Do not need nor store repeat pointer. Quit.
								beq						.return
								clr.w					(a5)
								clr.b					launchTableRptCountdown(a5)
								bra						.return

.isWave				; is in of obj wave?
								clr.w					d0
								move.b					objectListWaveIndx(a0),d0
								lea						objCopyTable(pc),a1
								sub.b					#1,(a1,d0)
								bne						irqDidColManager																																																							; back to IRQ
								IFEQ					OBJECTSCORETEST
								ADDSCORE				5000
								ENDIF
								move.l					waveBnusAnimPointer(pc),a4
								move.w					animTablePointer+2(a4),d4																																																					;add bonus display
								move					objectListX(a0),d5
								sub						#$15,d5
								move					objectListY(a0),d6
								st.b					d3
								bsr						objectInit
								tst.l					d6
								bmi						.quitWave
								move.l					viewPosition+viewPositionAdd(pc),d2
								asr.l					#8,d2
								sub						#100,d2
								move.w					d2,objectListAccY(a4)																																																						; float up, regardless of scrollspeed

								lea						plyBase(pc),a4
								add.w					#1,plyWaveBonus(a4)																																																							; add one with each chain spawn. Query in achievements screen

    ; is sprite therefore attribs are assigned by objects-list. $40=bonus icon
.quitWave
								bra						irqDidColManager

	; #MARK:  object destroy special events (debris etc.)

	; insert "code destroyX" into anims-list to add post-death-event
	; 	destroyA	->	init debris 8 pcs
	;	destroyB	->	init debris 16 pcs
	;	destroyC	->	launch autotarget projectile
	;	destroyD	->	force small explosion
	;	destroyE	->	force medium explosion
	;	destroyF	->	force large explosion
	;	destroyG	->	draw relicts to bitplane
	;	destroyH	->	launch weap or speed upgrades
	;	destroyI	->	set global trigger2 | ATTN: Reset trigger2 in object waiting for trigger2-event, using animlist. Use animlist command "code setTrigs" to reset all global triggers.
	;	destroyJ	->	special for boss 3 (snake) - kill attached bullet emitter object
	;	destroyK	->	quit current animlist loop and init alt. animlist entry. Used with mid boss stage 4
	;	destroyL	->	test for facturo boss stage 0 / sky

.rasterCritical					SET						200
.destroySpecial

								clr.w					d4
								move.b					objectListDestroy(a0),d4
								clr.b					objectListDestroy(a0)																																																						; avoid re-init
								move.w					(.destroyJmpTable-2,pc,d4*2),d4
								lea						debrisA3AnimPointer(pc),a2
								moveq					#5,d2
.dstrOffset
								jmp						.dstrOffset(pc,d4)
.dstrEventB
								lea						killShakeIsActive(pc),a1
								move.b					#7,(a1)

								lea						16(a2),a2																																																									; modify pointer to debrisA4AnimPointer
								addq					#6,d2																																																										; add more debris objects
.dstrEventA
	;bra .retDestrSpecNotGrouped
								SAVEREGISTERS
								clr.l					d4
								move.l					debrsObjAnimPointer(pc),a4
								move.w					animTablePointer+2(a4),d4
								clr.l					d5
								clr.l					d6
								move.w					objectListX(a0),d5
								move.w					objectListY(a0),d6

								st.b					d3
								bsr						objectInit																																																									; spawn post-explosion debris controller Object
								tst.l					d6
								bmi.b					.dstrQuit																																																									; no more object slots available
								move.w					objectListX(a0),d5
								swap					d5
								move.w					#8,d5
								add.w					objectListY(a0),d5
								move.l					(a2),a2
								move.w					animTablePointer+2(a2),d0
								swap					d0
								move.l					viewPosition+viewPositionAdd(pc),d1
								lsr.l					#7,d1
								swap					d1
								move					#$600,d0
								sub.w					d1,d0
	;move.w #-$180,d0
	;move.w d1,d0
								move.l					d0,objectListTriggers(a4)																																																					; store animPointer, y-acceleration
								move.l					d5,objectListTriggersB(a4)																																																					; store x- and y-position

								move.w					rasterBarNow(pc),d5																																																							; fetch total system load, value 0-255
								lsr						#6,d5
								lsr.b					d5,d2																																																										; more onscreen action -> less debris
								add.b					#2,d2

								move.b					d2,objectListCnt(a4)																																																						; object lifetime determines number of debris
.dstrQuit
								RESTOREREGISTERS
								bra						.retDestrSpecNotGrouped
.dstrEventC
								SAVEREGISTERS
								lea						.ret(pc),a5
								move.l					a0,a6
								bra						homeShot
.ret
								bra						.dstrQuit

.dstrEventD			; force small explosion
								move.l					a0,a6
								bra						.explSml
.dstrEventE			; force medium explosion
								lea						killShakeIsActive(pc),a1
								move.b					#3,(a1)
								move.l					a0,a6
								bra						.explMed
.dstrEventF			; force large explosion
								lea						killShakeIsActive(pc),a1
								move.b					#7,(a1)
								move.l					a0,a6
								bra						.explLrg
.dstrEventG		; copy boss bob bitmap data to playfield
								SAVEREGISTERS
								lea						plyBase+plyDistortionMode(pc),a1
								sf.b					(a1)																																																										; stop screenshake (beam heat)

								clr.l					d5
								move.w					objectListY(a0),d5
								sub.w					viewPosition+viewPositionPointer(pc),d5
								move.w					AddressOfYPosTable(pc,d5*2),d5																																																				; get y-adress

								move					objectListX(a0),d7
								moveq					#-64,d4
								add.w					d7,d4
;	sub.w plyPos+plyPosXDyn(pc),d5;Convert absolute to relative
								lsr						#4,d4																																																										; set x-pos
								bclr					#0,d4
								add.w					d4,d5
								ext.l					d5
								move.l					d5,a5
	;add.l #3*40,a5
								move					(a0),d5																																																										;objectListAnimPtr	; get score
								move.l					(animDefs,pc),a1
								lea						(a1,d5),a1
								clr.l					d4
								move.b					animDefType(a1),d4
								move.l					(objectDefs,pc),a4
								lea						(a4,d4*8),a4
								move.l					(a4),a0																																																										;objectDefSourcePointer
								adda.l					bobSource(pc),a0																																																							; Adress of sourcebitmap
								move.l					a0,a6
								move.l					mainPlanesPointer+0(pc),a1
								bsr						.copy

								move.l					a6,a0																																																										;objectDefSourcePointer
								move.l					mainPlanesPointer+4(pc),a1
								bsr						.copy

								move.l					a6,a0																																																										;objectDefSourcePointer
								move.l					mainPlanesPointer+8(pc),a1
								bsr						.copy
								bra						.dstrQuit
.copy
								lea						(a1,a5.l),a1
								move					#46,d1																																																										; object heigth
								lea						7*8(a0),a2																																																									; pointer to cookie
								lea						(56+56),a3
								bra						mergeObjectToBitmap
.dstrEventH
	;tst.b optionStatus(pc)
	;bmi .dstrEventF	; diff is high? No extra icon
								SAVEREGISTERS
								lea						dstrEventHToggle(pc),a4
								move.b					(a4),d0
								andi.w					#1,d0
								lsl.b					#4,d0
								add.b					#1,(a4)
								move.l					weapUpgrAnimPointer(pc,d0),a4																																																				; fetch weapUpgr or spedUpgr Animpointer
								clr.w					d0
								bsr						initObject
								move.l					a0,a6
								bsr						getCoordsBlitter
	;clr.l objectListAccX(a4)
								move.b					#1,objectListCnt(a4)
								move.w					d5,objectListX(a4)
								move.w					d6,objectListY(a4)
								move.w					#100,objectListAccY(a4)																																																						; spiral downwards
								move.b					#attrIsNotHitableF,objectListAttr(a4)																																																		; cannot be hit
								RESTOREREGISTERS
								bra						.dstrEventF
.dstrEventI
								lea						animTriggers+2(pc),a4
								st.b					(a4)
								bra						.dstrEventF
.dstrEventJ			; kill boss 3 snake bullet emitter object

								lea						bossVars+bossChildPointers+(13*4)(pc),a6
								move.l					(a6),a6
								move.l					emtyAnimAnimPointer(pc),a0
								move.w					animTablePointer+2(a0),d4
								move.w					d4,(a6)
								move.b					#1,objectListCnt(a6)
								bra						.retDestrSpecNotGrouped

.dstrEventK			; quit current animlist loop and init alt. animlist entry. Used with mid boss stage 4

	;	move.w objectListHit(a6),d0
	;or.b #$3,d0
;.loopRelationship
	;move.w d0,objectListHit(a6)	; mark every child as hitframe

	;move.l objectListMyChild(a6),a6
	;tst.l a6
	;bne .loopRelationship
	;bra colHit
	; a0 contains pointer to main parent
								move.l					mechMedMAnimPointer(pc),a1
								move.w					animTablePointer+2(a1),(a0)																																																					; switch to exit animation
								move.b					#1,objectListCnt(a0)
								move.b					#1,objectListLoopCnt(a0)																																																					; quit current wait loop
								asr.w					objectListAccX(a0)
								asr.w					objectListAccX(a0)
								asr.w					objectListAccX(a0)
								asr.w					objectListAccY(a0)
	;move.w #200,objectListAccY(a0)

								move.w					#0<<2,objectListHit(a0)																																																						; set to indestructible
								move.b					#attrIsNotHitableF,objectListAttr(a0)

								move.l					objectListMyChild(a0),a0																																																					; get left wing
								move.w					#0<<2,objectListHit(a0)
								move.b					#attrIsNotHitableF,objectListAttr(a0)

								move.l					objectListMyChild(a0),a0																																																					; get central piece (exhaust)
								move.b					#1,objectListLoopCnt(a0)
								move.w					#0<<2,objectListHit(a0)																																																						; set to indestructible
								move.b					#attrIsNotHitableF,objectListAttr(a0)

								move.l					objectListMyChild(a0),a0																																																					; get right wing
								move.w					#0<<2,objectListHit(a0)																																																						; set to indestructible
	;move.b #1,objectListLoopCnt(a0)	; quit current wait loop
								move.b					#attrIsNotHitableF,objectListAttr(a0)
								bra						irqDidColManager

.dstrEventL; fix to kill crash with mid boss stage 2
								move.l					bossVars+bossChildPointers+36(pc),a1																																																		; get main parent
								move.w					objectListX(a0),d0
								add.w					objectListX(a1),d0
								move.w					d0,objectListX(a0)																																																							; modify x|y-position
								move.w					objectListY(a0),d0
								add.w					objectListY(a1),d0
								move.w					d0,objectListY(a0)
								clr.l					objectListMyParent(a0)
								clr.b					objectListAttr(a0)
								bra						.dstrEventH

.destroyJmpTable
								dc.w					.dstrEventA-.dstrOffset-2
								dc.w					.dstrEventB-.dstrOffset-2
								dc.w					.dstrEventC-.dstrOffset-2
								dc.w					.dstrEventD-.dstrOffset-2
								dc.w					.dstrEventE-.dstrOffset-2
								dc.w					.dstrEventF-.dstrOffset-2
								dc.w					.dstrEventG-.dstrOffset-2
								dc.w					.dstrEventH-.dstrOffset-2
								dc.w					.dstrEventI-.dstrOffset-2
								dc.w					.dstrEventJ-.dstrOffset-2
								dc.w					.dstrEventK-.dstrOffset-2
								dc.w					.dstrEventL-.dstrOffset-2
dstrEventHToggle
								dc.b					0
								even

								RSRESET
postDestroy						rs.b					1
postDestroyLowDebris			rs.b					1
postDestroyHighDebris			rs.b					1
postDestroyLaunchHomeshot		rs.b					1
postDestroyForceSmlExplosion	rs.b					1
postDestroyForceMedExplosion	rs.b					1
postDestroyForceLrgExplosion	rs.b					1
postDestroyCopyBobToBitmap		rs.b					1
postDestroyLaunchExtra			rs.b					1
; #MARK: - LAUNCH MANAGER
launchManager

	;#FIXME: check - use launchTable or launchTablebuffer. Is buffer still needed?
								move.l					launchTableBuffer(pc),a0
								move.l					launchTableEntryLength(pc),a6
								move					viewPosition+viewPositionPointerLaunchBuf(pc),d0
								move					d0,d5
								lea						launchTableAnim(a0),a5
								tst.w					launchTableAnim(a0)
								bmi						.enemQuit
								bne						.foundValidEntry																																																							;   is 0? past wave, unvalid!

.enemPreFetchWave               ;   preloop to determine first valid entry in launchTable. Table needs to be sorted
								REPT					4
								adda.l					a6,a0
								tst.w					(a0)																																																										;launchTableAnim
								bne						.foundValid																																																									;   is 0? past wave, unvalid!
								ENDR
								bra						.enemPreFetchWave
.foundValid
								bmi						.enemQuit																																																									;   is >$7fff? reached end of list

								lea						launchTableBuffer(pc),a4
								move.l					a0,(a4)
								bra						.foundValidEntry
.enemFetchWave

								REPT					4
								adda.l					a6,a0
								tst.w					(a0)																																																										; read launchTableAnim entry
								bne.s					.foundValidEntry																																																							;   is 0? already launched
								ENDR
								bra						.enemFetchWave
.foundValidEntry
								bmi						.enemQuit																																																									;   is >$7fff? reached end of list

								cmp						launchTableY(a0),d0
								bcc						.enemQuit

								tst.b					launchTableRptr(a0)
								bne.b					.copyObject

	; launch single object

								move.b					launchTableHitpoints(a0),d6
								clr.l					d6
								clr.l					d5
								move.w					launchTableX(a0),d5
								move					viewPosition+viewPositionPointerLaunchBuf(pc),d6
.singleDynX
								move.w					(a0),d4																																																										;launchTableAnim
								st.b					d3
								bsr						objectInitLaunchList
								tst.l					d6
								bmi						.enemFetchWave
								st.b					objectListWaveIndx(a4)
								clr.w					launchTableAnim(a0)																																																							; delete launch entry
								bra						.enemFetchWave																																																								; get next
.copyObject
								sub.b					#1,launchTableRptCountdown(a0)
								bcc.w					.enemNextWave
.enemChckRythm              ; launch delay until music permits

								move.b					launchTableRptrDist(a0),launchTableRptCountdown(a0)
								sub.b					#1,launchTableRptr(a0)
								beq.w					.enemEndWave																																																								; overflow? was single object
.launchCopied			; launch copied object
								bmi						.firstEntry																																																									; is first object? Yes!
.contLaunch
								clr.l					d5
								move.w					launchTableX(a0),d5

								tst.b					launchTableAttribs(a0)
								bpl.b					.copiedStaticY

								move					launchTableY(a0),d6
		;move #$13f0,d6
								bra.b					.copiedInit
.firstEntry
								lea						vars(pc),a1
								clr.l					homeShotHead-vars(a1)																																																						; reset pointer to first object
								move.w					a0,d7
								lsr						#3,d7
								andi					#$f,d7																																																										; create wave fingerprint
								lea						objCopyTable(pc,d7),a1

								bclr					#7,launchTableRptr(a0)
								clr.w					d0
								move.b					launchTableRptr(a0),d0
								move.b					d0,(a1)																																																										; store no of obj==mark as wave
								clr.b					objSpiralBulletTable-objCopyTable(a1)																																																		; reset shoot angle pointer
								bra.b					.contLaunch
.copiedStaticY
								move					viewPosition+viewPositionPointerLaunchBuf(pc),d6
.copiedInit
								move.w					(a0),d4																																																										;launchTableAnim
								st.b					d3
								bsr						objectInitLaunchList
								tst.l					d6
								bmi						.enemEndWave																																																								; too many objects? Kill wave!
		;		move.w objectListY(a4),d7
								move.w					a0,d7
								lsr						#3,d7
								andi					#$f,d7																																																										; generate wave fingerprint
								move.b					d7,objectListWaveIndx(a4)																																																					; store index in obj struc
;		bra.b .groupedChk
	;bra .enemFetchWave	; get next
.groupedChk
								btst					#2,d3
								beq.b					.noGroup
								move.l					a0,objectListLaunchPointer(a4)																																																				;store pointer to launch list entry / cancel wave if killed
								move.w					a0,objectListGroupCnt(a4)																																																					; needed for comparing
.noGroup
								move.b					launchTableRptXAdd(a0),d6
								ext.w					d6
								add.w					d6,launchTableX(a0)
								move					viewPosition+viewPositionPointerLaunchBuf(pc),d0																																															; restore d0
								bra.w					.enemFetchWave
.enemEndWave
								clr.w					launchTableAnim(a0)
.enemNextWave
								bra.w					.enemFetchWave
.enemQuit
								bra						irqNoMoreLaunches

objCopyTable	; store index and no of copied objects for wave bonus
								blk.b					16,0																																																										; entrys
objSpiralBulletTable
								blk.b					16,0
objSpiralplyPosTable
								blk.l					16,0
objCopyEnd
								even

attrIsNoRefresh				=	0
attrIsKillBorderExit		=	1
attrIsLink					=	2
attrIsAvailB				=	3
attrIsYadd					=	4
attrIsNotHitable			=	5
attrIsOpaq					=	6																																																																	; add "attribs 64" to object definition for object without no mask, to save memory and blitter dma cycles
attrIsBonus					=	6																																																																	; bit 6 has two tasks. IsBonus is used with sprites only, therefore IsOpaq is meaningless in such cases
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

    ; #MARK: - OBJECT INIT RUNTIME

		; -> d3 	false/0 = sprite, true/$ff=bob
		; -> d4 	AnimList-Address
		; -> d5/d6 	x/y-coordinates
            ; d6 returns errorcode -1 if too many objects

    ;objectListAttr attribs:
    ;bit 0 = $01 = no background refesh (useful for static anim objects). Set label refr in object@map
    ;bit 1 = $02 = object is killed if exits screen
    ;bit 2 = $04 = object belongs to one group of objects
    ;bit 3 = $08 = available
    ;bit 4 = $10 = available
    ;bit 5 = $20 = bob not hitable e.g. explosion. sprite is never hitable.
    ;bit 6 = $40 = opaque flag. Override potential cookieblit, force copyblit. If sprite->attach bonus icon
    ;bit 7 = $80 = sprite; 0 = bob








objectInitOnTopOfSelf	; alternative jumpin for object init. Does not alter pointer to earliest available object (objectList+8)
.browseObjList	; jump-in to spawn object ranked higher/displayed on top of current object
								lea						4(a4),a4
								tst.w					(a4)
								beq.s					.foundSlot
								lea						4(a4),a4
								tst.w					(a4)
								beq.s					.foundSlot
								lea						4(a4),a4
								tst.w					(a4)
								beq.s					.foundSlot
								bra						.browseObjList
.foundSlot
								cmp.l					objectList+8(pc),a4
								bls						.return
								move.l					a4,objectList+8																																																								; only update if current object is higher than old one
.return
								bra						writeObject
objectInitShot
								move.l					objectList(pc),a4
		;	load fixed pointer to object data table shot objects -> a4
								tst.w					(a4)
								beq						writeObject

.animsrchlistShotB
								lea						4(a4),a4
								tst.w					(a4)
								beq						writeObject
								lea						4(a4),a4
								tst.w					(a4)
								beq						writeObject
								lea						4(a4),a4
								tst.w					(a4)
								bne.s					.animsrchlistShotB
								bra						writeObject

objectInit	; launch in runtime, not from launch list
            ; handle ONLY attrib.b and hitpoint.w by code after init
	; destroys a1,a4,d3,d4,d5,d6
								IFNE					DEBUG
								ext.w					d3
								tst.b					objectWarning+1(pc,d3.w)
								bne						tooManyObjects
								ENDIF

								movem.l					objectList+4(pc),a1/a4

	;	load fixed pointer to object data table, non-shot objects -> a1
	;	dynamic pointer ->	a4

								IFNE					DEBUG																																																										; check if object pointer does not corrupt shot reserved space
								cmp.l					a1,a4
								bcc						.allOkay
								IFNE					SHELLHANDLING
								jsr						shellObjListRuntimeError
								ENDIF
								QUITNOW
.allOkay
								ENDIF


	;lea objectListEntrySize-(shotsMax*4)-4(a1),a1
;.animsrchlist
								tst.w					(a4)
								beq.s					obInitfoundSlot
obInitanimsrchlistB	; jump-in to spawn object ranked higher/displayed on top of current object
								lea						4(a4),a4
								tst.w					(a4)
								beq.s					obInitfoundSlot
								lea						4(a4),a4
								tst.w					(a4)
								beq.s					obInitfoundSlot
								lea						4(a4),a4
								tst.w					(a4)
								bne.s					obInitanimsrchlistB
obInitfoundSlot
								lea						4(a4),a1
								move.l					a1,objectList+8																																																								; store earliest object entry slot
writeObject
								cmpi.w					#tarsMax+bulletsMax+shotsMax,objCount(pc)
								bhs						tooManyObjects
								swap					d5
								clr						d5
								move.l					d5,objectListX(a4)
								swap					d6
								move.l					d6,objectListY(a4)
								clr.l					objectListAcc(a4)

								move					d4,(a4)																																																										; objectListAnimPtr - pointer to animDefinitions
								lea						objCount(pc),a1
								addq					#1,(a1)
								move.l					animDefs(pc),a1

								move.b					animDefCnt(a1,d4.w),d4
								lsl						#8,d4
								move.w					d4,objectListCnt(a4)																																																						; lifespan.b, clr.b destroy

								clr.l					objectListMainParent(a4)																																																					; clear parent pointer
								clr.l					objectListMyParent(a4)																																																						; clear parent pointer
								clr.l					objectListMyChild(a4)																																																						; clear child pointer
								moveq					#-1,d4
								sf.b					d4
								rol.l					#8,d4
								move.l					d4,objectListGroupCnt(a4)																																																					; -1.w =objectListGroupCnt, 0.b=objectListLoopCnt, -1.b=objectListWaveIndx
								clr.l					objectListLaunchPointer(a4)																																																					; clear launchListPointer
								clr.l					objectListTriggers(a4)																																																						; clear triggers
								clr.l					objectListTriggersB(a4)																																																						; clear triggers

								clr.l					d6																																																											; object implemented, set flag
								rts
tooManyObjects
								moveq					#-1,d6
								rts

    ; #MARK: - OBJECT INIT LAUNCHLIST


objectInitLaunchList:           ; launch by lauchlist, not manually. Attribs and hitpoints taken care off
								move.w					objectWarning,a1

								movem.l					objectList+4(pc),a1/a4
	;	load fixed pointer to object data table, non-shot objects -> a1
	;	->	d6		OK	=	0; Failed	<>	0
	;	->	a4		dynamic pointer
	;	->	d3		object attrib flag


								lea						objectListEntrySize-8(a1),a1																																																				; add offset for  overflow check
								ext.w					d3
								tst.b					objectWarning+1(pc,d3.w)
								bne						tooManyObjects
.animsrchlist
								moveq					#4,d3
								tst.w					(a4)
								beq.s					.foundSlot
.animsrchlistB
								lea						4(a4),a4
								tst.w					(a4)
								beq.s					.foundSlot
								lea						4(a4),a4
								tst.w					(a4)
								beq.s					.foundSlot
								lea						4(a4),a4
								tst.w					(a4)
								bne.s					.animsrchlistB
.foundSlot
								sub.l					a4,a1
								tst.l					a1
								bmi						tooManyObjects
								lea						4(a4),a1
								move.l					a1,objectList+8																																																								; pointer to next available objectslot

								swap					d5
								clr						d5
								move.l					d5,objectListX(a4)
								swap					d6
								clr						d6
								move.l					d6,objectListY(a4)																																																							; coords

								clr.l					objectListAcc(a4)
								move					d4,(a4)																																																										; objectListAnimPtr - pointer to animDefinitions
								clr.w					d3
								move.b					launchTableHitpoints(a0),d3
								tst.b					optionStatus(pc)
								bmi						.storeHitpoint
								move.b					.hitTableEasy(pc,d3.w),d3
.storeHitpoint
								lsl						#2,d3
								move					d3,objectListHit(a4)																																																						; bit 2-15=hitpoints. bits 0-1=hit-blink
								move.b					launchTableAttribs(a0),d3
								move.b					d3,objectListAttr(a4)																																																						;
;noGroup
								lea						objCount(pc),a1
								addq					#1,(a1)
								move.l					animDefs(pc),a1
								move.b					animDefCnt(a1,d4.w),d4
								seq						d6
								sub.b					d6,d4																																																										; add 1 incase of first entry duration=0 within animlist
								lsl.w					#8,d4
								move.b					#postDestroyLowDebris,d4																																																					; basic destroy setting = 1 only if spawn by launchlist
								move.w					d4,objectListCnt(a4)																																																						; set.b lifespan, clr.b destroy
								clr.l					objectListMainParent(a4)																																																					; clear parent pointer
								clr.l					objectListMyParent(a4)																																																						; clear parent pointer
								clr.l					objectListMyChild(a4)																																																						; clear child pointer
								clr.l					objectListLaunchPointer(a4)																																																					; clear launchListPointer
								clr.l					objectListTriggers(a4)																																																						; reset object triggers
								clr.l					objectListTriggersB(a4)																																																						; again
								clr.l					objectListGroupCnt(a4)
								st.b					objectListWaveIndx(a4)																																																						; clear wave index ($ff)
	;clr.b objectListLoopCnt(a4)   ; clear LoopCnt
								clr.l					d6
								rts
.hitTableEasy	; alternative hitvalues for easy mode 
								dc.b					$00,$01,$01,$02,$02,$03,$03,$06																																																				; $07
								dc.b					$05,$05,$05,$06,$06,$07,$08,$0a																																																				; $0f
								dc.b					$0a,$0a,$0b,$0c,$10,$0d,$0e,$10																																																				;	$17
								dc.b					$11,$12,$12,$13,$13,$14,$14,$15																																																				;	$1f
								dc.b					$16,$16,$17,$17,$18,$19,$1a,$1a																																																				;	$27
								dc.b					$1b,$1b,$1c,$1d,$1e,$1e,$1f,$1f																																																				;	$2f
								dc.b					$24,$21,$21,$22,$23,$24,$25,$26																																																				;	$37
								dc.b					$26,$27,$27,$28,$28,$29,$2a,$2b																																																				;	$3f
								dc.b					$30,$30,$31,$31,$33,$33,$46,$35																																																				;	$47
								dc.b					$36,$36,$37,$38,$39,$3a,$3a,$4f																																																				;	$4f
								dc.b					$3b,$3b,$3c,$3d,$3e,$3e,$3f,$3f																																																				;	$57
								dc.b					$40,$40,$41,$41,$42,$42,$43,$43																																																				;	$5f
								dc.b					$60,$44,$45,$45,$46,$46,$47,$47																																																				;	$67
								dc.b					$48,$48,$49,$49,$4a,$4a,$4b,$4c																																																				;	$6f
								dc.b					$4d,$4d,$4e,$4e,$4f,$4f,$50,$50																																																				;	$77
								dc.b					$51,$51,$52,$52,$53,$53,$54,$54																																																				;	$7f

								Include					animCodeMain.s
								Include					customMain.s

wrtScore               ; draw 2 numbers plus shadow to sprite
                            ; d7.b = bcd number, a1 = address

								move					d7,d5
								asr						#4,d7
								and.w					d3,d7
								and.w					d3,d5

								move.b					4(a0,d5*8),d0																																																								; read lowest line of right number
								move.b					4(a0,d7*8),d1																																																								; left number
								clr.w					d2
								move.b					d0,d2																																																										;
								lsl						d4,d1																																																										; push to position
								sf.b					d1																																																											; andi #$ff00,d1
								or						d1,d2																																																										; fetch two numbers
								move.w					d2,spriteLineOffset*4(a1)																																																					; write bitmap
								lsr						d2
								move.w					d2,8+spriteLineOffset*4(a1)																																																					; write shadow

								move.l					(a0,d7*8),d1																																																								; 4 lines from left digit
								move.l					(a0,d5*8),d0																																																								; read 4 lines from right digit
								clr.w					d2
								move.b					d0,d2
								move.b					d1,d7
								lsl						d4,d7
								sf.b					d7
								or.w					d7,d2
								move.w					d2,spriteLineOffset*3(a1)
								lsr						#1,d2
								move.w					d2,8+spriteLineOffset*3(a1)

								clr.l					d2
								lsr.l					d4,d0
								move.b					d0,d2
								sf.b					d1
								or.w					d1,d2
								move.w					d2,spriteLineOffset*2(a1)
								lsr						#1,d2
								move.w					d2,8+spriteLineOffset*2(a1)

								clr.w					d2
								lsr.l					d4,d0
								lsr.l					d4,d1
								move.b					d0,d2
								sf.b					d1
								or.w					d1,d2
								move.w					d2,spriteLineOffset(a1)
								lsr						#1,d2
								move.w					d2,8+spriteLineOffset(a1)

								lsr.w					d4,d0
								lsr.l					d4,d1
								sf.b					d1
								or.w					d1,d0
								move.w					d0,(a1)
								lsr						d0
								move.w					d0,8(a1)
								rts


;
; #MARK: - SCORE MANAGER

scoreManager
								clr.l					d0
								btst					#0,frameCount+3(pc)
								beq						drawInfoPanel

drawScore
								lea						scoreAdder(pc),a0
								move					(a0),d0
								beq						scoreQuit

								clr.w					(a0)
								tst.b					plyBase+plyCheatEnabled(pc)
								bne						scoreQuit																																																									; only add score if cheatFlag=false

	; handle multiplier
								lea						scoreMultiplier(pc),a3
								add.b					#1,2(a3)
								bcc.b					.maxMultiplier
								move.b					#250,2(a3)
.maxMultiplier
								clr.w					d1
								move.b					2(a3),d1
								lsr						#5,d1
								clr.w					d6
								move.b					((scoreMulti).w,pc,d1.w),d6
								move.w					#60*5,(a3)																																																									; keep chain for 3 seconds, then reset

								lea						(score,pc),a6

								move.l					(a3),d2
								tst.w					(a3)
								beq						scoreQuit																																																									; zero multiplier -> skip
								cmp.b					3(a3),d6																																																									; unchanged? Skip!
								beq.b					.skipDispUpdate
								bsr						initMultiply
.skipDispUpdate
								move.b					d6,3(a3)
.drawStats
								lea						scoreAdder(pc),a0
								clr.w					(a0)																																																										; reset scoreAdder
								bsr						convertHexToBCD
								move					d1,scoreAdd+2(a6)
								move.w					scoreAdd+2(a6),a4
.multiplyScore
								move.l					a6,a4
								addq.l					#4,a4
								lea						(score+scoreAdd+4,pc),a5

								moveq					#0,d0																																																										; calc new score
								add						#0,d0
								abcd					-(a5),-(a4)
								abcd					-(a5),-(a4)
								abcd					-(a5),-(a4)
								abcd					-(a5),-(a4)
								IFEQ					OBJECTSCORETEST
								dbra					d6,.multiplyScore																																																							; loop in case of score multiplier
								ENDIF

.scoreToSprite	;   write score
								lea						font(pc),a0
								clr.w					d5
								clr.w					d7
								moveq					#$f,d3
								moveq					#8,d4

								lea						infoPanelScore,a5
								move.b					scoreNew(a6),d7																																																								; check first two digits of score. Changed?
								move.b					scoreOld(a6),d5
								cmp.b					d5,d7
								beq.b					.chkNext2
								move.b					d7,scoreOld(a6)																																																								;   yes
								move.l					a5,a1
								bsr						wrtScore																																																									; write to sprite
.chkNext2
								addq.l					#1,a6																																																										; second two digits ...
								move.b					scoreNew(a6),d7
								move.b					scoreOld(a6),d5
								cmp.b					d5,d7
								beq.b					.chkNext3

								move.b					d7,scoreOld(a6)
    ;lea ([(spriteScoreBuffer).w,pc],(spriteLineOffset*spriteScoreHeight+16+2).w),a1
								lea						2(a5),a1
								bsr						wrtScore
.chkNext3
								addq.l					#1,a6																																																										; third two digits ...
								move.b					scoreNew(a6),d7
								move.b					scoreOld(a6),d5
								cmp.b					d5,d7
								beq.b					.chkNext4

								move.b					d7,scoreOld(a6)
    ;lea ([(spriteScoreBuffer).w,pc],(spriteLineOffset*spriteScoreHeight+16+4).w),a1
								lea						4(a5),a1
								bsr						wrtScore
.chkNext4
								addq.l					#1,a6																																																										; fourth two digits ...
								move.b					scoreNew(a6),d7
								move.b					scoreOld(a6),d5
								cmp.b					d5,d7
								beq.b					scoreQuit
								move.b					d7,scoreOld(a6)
								lea						6(a5),a1
								bra						wrtScore
scoreQuit
								rts

infoPanelDelta					SET						infoPanelStatus
infoPanelHighscore				SET						infoPanelDelta+10*spriteLineSize
infoPanelHuntem					SET						infoPanelDelta+5*spriteLineSize
infoPanelMultiply				SET						infoPanelDelta+15*spriteLineSize
infoPanelDidIt					SET						infoPanelDelta+20*spriteLineSize
scoreMulti
								dc.b					0,1,1,2,2,3,3,4
; #MARK: Draw Info Panel

drawInfoPanel
								lea						font(pc),a0

								clr.w					d1
;	move.b #4<<5,scoreMultiplier+2
								move.b					scoreMultiplier+2(pc),d1																																																					; got new multiplier?
								lsr						#5,d1
								tst.b					((scoreMulti).w,pc,d1.w)
								bne						.showMultiply																																																								; keep on displaying
	;MSG01 m2,d0

								move.b					scoreHighSuccessFlag(pc),d1																																																					; got new highscore
								bmi						.dispHigh
								bne						.drawHighBlink																																																								; keep on displaying
    ;bne .drawHighscore	; yes - init dsplay

								move.l					scoreHigh(pc),d6
								cmp.l					score(pc),d6
								bgt						.drawDelta																																																									; is highscore higher than score?
; #MARK: draw highscore

.drawHighscore
								PLAYFX					10																																																											; got new high!
								move.b					#1,scoreHighSuccessFlag
.dispHigh
								lea						infoPanelHighscore,a4
								lea						infoPanelDelta,a0
								move.l					a0,a1
								bra						.copyMsgToSprite
.drawHighBlink
								add.b					#1,scoreHighSuccessFlag
								andi.b					#%10000,d1
								bne.b					.showDelta
								lea						infoPanelDidIt,a0
								bra						.showInfoPanel
.showMultiply
								lea						infoPanelMultiDisplay,a0
	;lea infoPanelMultiply,a0
								bsr						.drawMultiplier
								bra						.showInfoPanel
.showDelta
								lea						infoPanelDelta,a0
.showInfoPanel
								move.l					a0,d0
								move.l					copperGame(pc),a1
								move.w					d0,2(a1)
								swap					d0
								move.w					d0,6(a1)
.quit
								rts

	; #MARK: draw delta
.drawDelta
								lea						scoreHighDelta(pc),a6
								move.l					scoreHigh(pc),d6
								move.l					d6,(a6)
								addq					#4,a6
								lea						score+4(pc),a5
    ;add #0,d0
								clr.w					d0
								sbcd					-(a5),-(a6)
								sbcd					-(a5),-(a6)
								sbcd					-(a5),-(a6)
								sbcd					-(a5),-(a6)

								lea						infoPanelDelta,a5
	;lea spritePlayerBasic,a5
								cmpi.l					#$100000-1,(a6)																																																								; check if high delta > 50000
								bgt						.copyHuntem

								clr.w					d5
								clr.w					d7
								moveq					#$f,d3
								moveq					#8,d4

								lea						scoreHighDelta(pc),a6
								move.b					1(a6),d7
								andi					#$f,d7
								or						#$a0,d7

								lea						2(a5),a1
								bsr						wrtScore
								move.b					2(a6),d7
								lea						4(a5),a1
								bsr						wrtScore
								move.b					3(a6),d7
								lea						6(a5),a1
								bsr						wrtScore
								bra						.showDelta

.copyHuntem
								lea						infoPanelHuntem,a4
								move.l					a5,a1
								move.l					4(a4),d1
								cmp.l					4(a5),d1																																																									; Huntem Msg already copied?
								beq						.showDelta																																																									; yes
.copyMsgToSprite
								moveq					#spriteDMAWidth/4,d4
								moveq					#spriteScoreHeight-1,d7																																																						; draw go 4 high
.copy
								movem.l					(a4)+,d0-d3
								move.w					d0,2(a1)
								move.l					d1,4(a1)
								move.w					d2,10(a1)
								move.l					d3,12(a1)
								lea						spriteLineSize(a1),a1
								dbra					d7,.copy
;.quit
								bra						.showDelta
	; #MARK: draw stats

.drawMultiplier	; draw extra stats
	;bra .klklk
								lea						scoreMultiplier(pc),a4
								move.w					(a4),d3
								cmpi					#$ff,d3
								shi						d0
								or.b					d0,d3																																																										; if >$ff -> $ff
								andi.w					#$ff,d3

								lea						infoPanelMultiply,a2


								lsr						#5,d3
								move.l					noiseFilter+1(pc,d3*4),d0
								lea						fastRandomSeed(pc),a4
								move.l					(a4),d1																																																										; AB
								move.l					4(a4),d2																																																									; CD
								swap					d2																																																											; DC
								add.l					d2,(a4)																																																										; AB + DC
								add.l					d1,4(a4)																																																									; CD + AB
								rol.l					d2,d0
								lea						(a0),a1
								moveq					#spriteScoreHeight-1,d5
.copyBitmap
								movem.l					(a2),d3/d4
								lea						16(a2),a2																																																									; get next line
								and.l					d0,d3
								and.l					d0,d4
								movem.l					d3/d4,(a1)																																																									; write bitmap data
								asr.l					d3
								roxr.l					d4
								movem.l					d3/d4,8(a1)																																																									; create shadow
								rol.l					d2,d0
								lea						16(a1),a1
								dbra					d5,.copyBitmap
								rts

	; #MARK: draw multiply

initMultiply
								SAVEREGISTERS
								move.l					4(a3),a0
								tst.l					a0
								beq						.skipSpriteSpawn
	;move.b d1,3(a3)
								move.w					d6,d1
								move.l					chainBnsAnimPointer(pc),a4
								move.w					animTablePointer+2(a4),d4																																																					;add chain display
								move					objectListX(a0),d5
								move					objectListY(a0),d6
    ;sub.w #$15,d5
								bsr						objectInit
								tst.l					d6
								bmi						.quit
								move.l					viewPosition+viewPositionAdd(pc),d2
								asr.l					#8,d2
								sub						#100,d2
								move.w					d2,objectListAccY(a4)																																																						; float up, regardless of scrollspeed
    ; is sprite therefore attribs are assigned by objects-list. $40=bonus icon

								lea						spriteAnimTableChain(pc),a2
								lsl						#6,d1
								lea						spriteChain8pixels(pc,d1),a1																																																				; muls 64
								move.l					a1,(a2)																																																										; modify sprite bitmap pointer

.skipSpriteSpawn
								lea						multiplyPixels(pc),a0
								clr.w					d1
								move.b					scoreMultiplier+2(pc),d1
								lsr						#5,d1
								move.b					((scoreMulti).w,pc,d1.w),d1
								lea						8+font(pc,d1*8),a1
								lea						infoPanelMultiply+7,a2

	; draw muls num

								move					#8,d5
								move.b					4(a1),d1
								move.b					d1,spriteLineOffset*4(a2)																																																					; lowest line
								lsr.b					#1,d1
								move.b					d1,8+spriteLineOffset*4(a2)																																																					; shadow

								move.l					(a1),d1
								move.b					d1,spriteLineOffset*3(a2)
								lsr.b					#1,d1
								move.b					d1,8+spriteLineOffset*3(a2)

								lsr.l					d5,d1
								move.b					d1,spriteLineOffset*2(a2)
								lsr.b					#1,d1
								move.b					d1,8+spriteLineOffset*2(a2)

								lsr.l					d5,d1
								move.b					d1,spriteLineOffset(a2)
								lsr.b					#1,d1
								move.b					d1,8+spriteLineOffset(a2)

								lsr.l					d5,d1
								move.b					d1,(a2)
								lsr.b					#1,d1
								move.b					d1,8(a2)
.quit
								RESTOREREGISTERS
								rts

newHighscorePixels; Highscore Pixeldata. First two words: sprite 7 DMA Highsuccess. 3rd word: sprite 7 manual Highsuccess, 4th word: sprite 7 manual High Delta
								INCBIN					incbin/scorefont_hi.raw
multiplyPixels; Multiply pixeldata
								INCBIN					incbin/scorefont_sc.raw
go4HighPixels
								INCBIN					incbin/scorefont_go.raw
statDisp
								dc.b					%00100000																																																									; 4 weap & speed stat displays
								dc.b					%00100000
								dc.b					%00010000																																																									; shadow
								dc.b					%00010000

								dc.b					%00101000
								dc.b					%00101000
								dc.b					%00010100
								dc.b					%00010100

								dc.b					%00101010
								dc.b					%00101010
								dc.b					%00010101
								dc.b					%00010101

;	dc.b %00101010
;	dc.b %00100100
;	dc.b %00010101
;	dc.b %00010010
; #MARK: SCORE MANAGER ENDS -




	;    Incbin reshoot:data/scoreExtras

colorAlphaTable ;pseudo colorRegs which define brightness of bplCol0, bplCol1 etc. 16 values per Col

								dc.w					$00,$01,$04,$05,$10,$11,$14,$15
								dc.w					$40,$41,$44,$45,$50,$51,$54,$55

								dc.w					$02,$03,$06,$07,$12,$13,$16,$17
								dc.w					$42,$43,$46,$47,$52,$53,$56,$57

								dc.w					$08,$09,$0c,$0d,$18,$19,$1c,$1d
								dc.w					$48,$49,$4c,$4d,$58,$59,$5c,$5d

								dc.w					$0a,$0b,$0e,$0f,$1a,$1b,$1e,$1f
								dc.w					$4a,$4b,$4e,$4f,$5a,$5b,$5e,$5f

								dc.w					$20,$21,$24,$25,$30,$31,$34,$35
								dc.w					$60,$61,$64,$65,$70,$71,$74,$75

								dc.w					$22,$23,$26,$27,$32,$33,$36,$37
								dc.w					$62,$63,$66,$67,$72,$73,$76,$77

								dc.w					$28,$29,$2c,$2d,$38,$39,$3c,$3d
								dc.w					$68,$69,$6c,$6d,$78,$79,$7c,$7d

								dc.w					$2a,$2b,$2e,$2f,$3a,$3b,$3e,$3f
								dc.w					$6a,$6b,$6e,$6f,$7a,$7b,$7e,$7f

								dc.w					$80,$81,$84,$85,$90,$91,$94,$95
								dc.w					$c0,$c1,$c4,$c5,$d0,$d1,$d4,$d5

								dc.w					$82,$83,$86,$87,$92,$93,$96,$97
								dc.w					$c2,$c3,$c6,$c7,$d2,$d3,$d6,$d7

								dc.w					$88,$89,$8c,$8d,$98,$99,$9c,$9d
								dc.w					$c8,$c9,$cc,$cd,$d8,$d9,$dc,$dd

								dc.w					$8a,$8b,$8e,$8f,$9a,$9b,$9e,$9f
								dc.w					$ca,$cb,$ce,$cf,$da,$db,$de,$df

;continueBitmap
;	Incbin incbin/misc/continue.raw
;continueBitmapE



playerShotColors
								Incbin					incbin/palettes/playerShots.pal
        ; obtained color data by using PicCon, creating palette and saving it as 8 bit copperlist; import into xcode and delete all BPLCON and COLOR entrys.


coplineAnimPointers
								blk.l					noOfCoplineAnims,0
								even

								Include					alert.s

								INCLUDE					audioManager.s

								SECTION					CHIPSTUFF, DATA_C


								Include					copperCode/coplist.s



; - Misc Data -
								cnop					0,8
								blk.l					spriteLineOffset/4
infoPanelScore
								blk.l					spriteScoreHeight*spriteLineOffset/4
								blk.l					spriteLineOffset/4
infoPanelStatus	; save as sprite, 64 pixel wide, 25 pixel high, no ctrl bytes
								INCBIN					incbin/infoPanel.raw
	;blk.l spriteScoreHeight*spriteLineOffset/4	; empty display

; MARK: - Level Data -

								cnop					0,8
titleSprites            ; 6 sprites 64 x 40 pixels. Save as 64 px wide sprites, 40 px high, ctrl words
								Incbin					incbin/title/logo_letters.raw
titleSpritesOffset			=	(*-titleSprites)/6
titleNumber
								Incbin					incbin/title/logo_number.raw
titleSpritesPalette
								Incbin					incbin/palettes/titleSprites.pal
titleSpieleschreiber
								Incbin					incbin/title/spieleschreiber.raw
titleSpieleschreiberEnd

								cnop					0,8
escalationBitmap
								INCBIN					incbin/escalation.raw

								cnop					0,8
spritePlayerContainer; pixel data 64 px wide, 52 px high, save as 32 pixel wide sprites, no attach, no ctrlword
	;REPT 16
	;dc.l 0,-1,-1,-1,-1,-1,-1,0
	;ENDR
	;blk.b 512,-1
								Incbin					incbin/player/weaponContainer.raw
								IFNE					PLAYERSPRITEDITHERED
spritePlayerBasic	; save as 32 px high, 64 px wide attached sprite, no ctrl words
								Incbin					incbin/player/shipDith_0a.raw
								Incbin					incbin/player/shipIll_0a.raw
spritePlayerBasicEnd
								Incbin					incbin/player/shipDith_0b.raw																																																				; move left
								Incbin					incbin/player/shipIll_0b.raw
								Incbin					incbin/player/shipDith_0c.raw																																																				; move right
								Incbin					incbin/player/shipIll_0c.raw
								ELSE
spritePlayerBasic	; save as 32 px high, 64 px wide attached sprite, no ctrl words
								Incbin					incbin/player/ship_0a.raw
								Incbin					incbin/player/shipIll_0a.raw
spritePlayerBasicEnd
								Incbin					incbin/player/ship_0b.raw																																																					; move left
								Incbin					incbin/player/shipIll_0b.raw
								Incbin					incbin/player/ship_0c.raw																																																					; move right
								Incbin					incbin/player/shipIll_0c.raw
								ENDIF
infoPanelMultiDisplay	; mirrored version of bitmap in infoPanelMultiply, fading out
								blk.b					infoPanelDidIt-infoPanelMultiply,0
								PRINTV					infoPanelDidIt-infoPanelMultiply

    ;}



