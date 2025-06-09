
; #MARK: - MAIN PREPS CODE BEGINS



_Precalc
			clr				errorFlag																														; main wont run if flag is set

			lea				gameInActionF(pc),a0
			sf				(a0)																															; disable gamecode in interrupt
			bsr				setgameStatus
			clr.b			AudioIsInitiated
       
			lea				memoryPointers(pc),a6
			move.l			#memoryPointersEnd-memoryPointers,d7
			bsr.l			CLEARMEMORY

	; how much memory for three screen buffers

			moveq			#8,d0																															; move tilemapHeight
			muls			#tileHeight,d0
			add.w			#4,d0																															; safety net
			muls			#mainPlaneWidth,d0
			muls			#mainPlaneDepth,d0
			lsl.l			#1,d0
	;#FIXME: lsl is temp til scrolling works to avoid mem corruption
			move.l			d0,mainPlaneOneSize																												;   1 x framebuffer
			move.l			d0,d1
			lsl.l			#1,d0
			add.l			d1,d0																															;   3 x framebuffer
			move.l			#fxPlaneWidth*fxPlaneHeightBig*fxPlaneDepth+16,d1																				; buffer for second plane
			add.l			d1,d0
			add.l			d1,d0																															; 2 x bckbuffer

         ; parallax layer
			move.l			d0,diskBufferSize
			move.l			#MEMF_CHIP|MEMF_CLEAR,d1																										; triplebuffer bitplane A
			ALLOCMEMORY

			lea				mainPlanes(pc),a0
							
			lea				mainPlanes(pc),a0
			lea				mainPlanesPointer(pc),a1
			lea				diskBuffer(pc),a2
			move.l			mainPlaneOneSize(pc),d1
			move.l			d0,12(a0)
			move.l			d0,d2

			moveq			#8,d7
			add.l			d7,d2
			moveq			#-8,d7
			and.l			d7,d2																															; align to 8 byte adress
			move.l			d2,(a2)																															; use bitplane buffer as diskBuffer
			move.l			d2,4(a2)																														; first one gets modified, second one stays original
			move.l			d2,(a0)																															; content will be swapped (triple buffer)
			move.l			d2,(a1)																															; content will be added
			add.l			d1,d2
			move.l			d2,4(a0)																														;   ""
			move.l			d2,4(a1)																														;   ""
			add.l			d1,d2
			move.l			d2,8(a0)																														;   ""
			move.l			d2,8(a1)																														;   ""
			add.l			d1,d2
			move.l			d2,d0
			move.l			#fxPlaneWidth*fxPlaneHeightBig*fxPlaneDepth+16,d1

			add.l			d1,d0



			lea				fxPlanePointer(pc),a0																											; prep. 2nd parallax layer
			move.l			d2,(a0)
			move.l			d0,8(a0)
			moveq			#16,d7
			add.l			d7,d2
			add.l			d7,d0
			moveq			#-8,d7
			and.l			d7,d2
			and.l			d7,d0
			move.l			d2,4(a0)																														; needed for correct AGA-adressing, used in screenmanager and load bitmap code
			move.l			d0,12(a0)

			lea				bobCodeCases,a0																													; reset pointers to dynamic animation code entrys
			move.w			#bobCodeCasesEnd-bobCodeCases,d2
			lsr				#4,d2
			bra				.clrBobCodePointersLoop
.clrBobCodePointers
			clr.l			12(a0)
			lea				16(a0),a0
.clrBobCodePointersLoop
			dbra			d2,.clrBobCodePointers

;#MARK: build basic memory structures

bobSourceMem

.allocMem	SET				copperGameMaxSize+musicMemSize+bobSourceSize+spritePlayerDMASize+spritePosMemSize+spriteDMAMemSize+spriteParallaxBufferSize

			move.l			#.allocMem,d0																													; copperlist max. size
			move.l			#MEMF_CHIP|MEMF_CLEAR,d1
			ALLOCMEMORY
								
			lea				vars(pc),a5																														; store
			move.l			d0,copperGame-vars(a5)

			add.l			#copperGameMaxSize+8,d0
			move.l			d0,musicMemory-vars(a5)																											; total music memory

			add.l			#musicMemSize,d0
			moveq			#$fffffff8,d1
			and.l			d1,d0
			move.l			d0,bobSource-vars(a5)																											; keep static value
			move.l			d0,bobSource-vars+4(a5)																											; dynamic value

			add.l			#bobSourceSize,d0
			move.l			d0,16+spritePlayerDMA-vars(a5)																									; must not altered
			move.l			d0,d2
			addq.l			#8,d2
			and.l			d1,d2
			move.l			d2,spritePlayerDMA-vars(a5)																										; pointer to sprite 0, may be altered

			clr.l			d2
			move.w			#spritePlayerDMASize/4,d2
			move.l			d2,d3
			move.l			d3,d4
			add.l			d0,d2
			and.l			d1,d2
			move.l			d2,spritePlayerDMA-vars+8(a5)																									; double buffer pointer to sprite 0, may be altered

			add.l					d3,d3
			add.l					d3,d4
			add.l					d0,d3
			and.l					d1,d3
			move.l					d3,spritePlayerDMA-vars+4(a5)																									; pointer to sprite 1

			add.l					d0,d4
			and.l					d1,d4
			move.l					d4,spritePlayerDMA-vars+12(a5)																									; double buffer pointer to sprite 1

			add.l					#spritePlayerDMASize,d0
			move.l					d0,spritePosMem-vars(a5)

			add.l					#spritePosMemSize,d0																											;    sprite sorting and
			move.l					d0,spriteDMAMem-vars+8(a5)																										; must not be changed
			move.l					d0,d2
			addq.l					#8,d2
			andi.b					#$f8,d2																															; align to quadword adress
			move.l					d2,spriteDMAMem-vars(a5)																										; first buffer

			clr.l					d2
			move.w					#spriteDMAMemSize/2,d2
			add.l					d0,d2
			and.l					d1,d2
			move.l					d2,spriteDMAMem-vars+4(a5)																										; second buffer

			add.l					#spriteDMAMemSize,d0
			move.l					d0,spriteParallaxBuffer-vars(a5)
			moveq					#8,d1
			add.l					d1,d0
			andi.b					#$f8,d0
			move.l					d0,spriteParallaxBuffer-vars+4(a5)

			add.l					#spriteParallaxBufferSize/2+16,d0																								; Second parallax sprite buffer
			add.l					d1,d0
			andi.b					#$f8,d0
			move.l					d0,spriteParallaxBuffer-vars+8(a5)

			lea						launchTableEntryLength(pc),a0
			moveq					#(launchTableNotUsed+2)&$3e,d0
			move.l					d0,(a0)																															; create buffer for launchTable
			lsl.w					#8,d0																															; good for 256 launch entrys
			move.l					d0,8(a0)																														; write to launchTableSize
			add.l					d0,d0
			add.l					#tileSourceMemSize,d0																											; tiles source
			move.l					#MEMF_ANY|MEMF_CLEAR,d1
			ALLOCMEMORY

			move.l					d0,launchTable-vars(a5)																											; ; build permanent launchTable buffer

			add.l					launchTableSize(pc),d0
			move.l					d0,tileSource-vars(a5)

			move.l					launchTableSize(pc),d0
			move.l					#MEMF_ANY|MEMF_CLEAR,d1
			ALLOCMEMORY

			move.l					d0,launchTableBuffer-vars(a5)																									; build secondary launchTable buffer, altered while game plays
			move.l					d0,launchTableBuffer-vars+4(a5)


; #MARK: - Load and prepare Audio SFX Data -


	; setup secondary pointers, used for XML decoding
			move.l					bobSource(pc),a2																												; use bob mem as temp mem for storing wav-files
			lea						tempBuffer(pc),a0
			move.l					a2,(a0)+																														; tempBuffer
			move.l					spriteDMAMem(pc),a2
			move.l					a2,(a0)+																														;	tempBufferAnimPointers
			lea						$800(a2),a2
			move.l					a2,(a0)+																														; tempMemoryPointersXML
			move.l					a2,(a0)+
			lea						$3000(a2),a2
			move.l					a2,(a0)																															;tempStoreXML

			lea						AudioNoOfSamples(pc),a2
			clr.b					(a2)
			sub.l					a2,a2																															; added size of samples
			move.l					tempBuffer(pc),a3
			lea						fxLoadTable,a4
			move.l					copperGame(pc),a5																												; abuse for temp storage of sampleadress.l (relative) and samplelength.w
.loadNextFX
			tst.w					(a4)
			beq						.lastAudioFile
			move.l					a4,d1
			add.b					#1,AudioNoOfSamples
			move.l					a3,a0
			sub.l					tempBuffer(pc),a0
			move.l					a0,(a5)																															; store offset of sample
			move.l					diskBuffer+4(pc),d2																												; load and prepare sample data
			move.l					diskBufferSize(pc),d3
			lea						.soundFileBase(pc),a0
			bsr						createFilePath
			jsr						loadFile
			tst.l					d0
			beq						errorDisk

			move.l					diskBuffer+4(pc),a0
			SEARCHXML4VALUE			(a0),"data"																														; find data-structure
    ;addq.l #6,a0

			move.l					(a0)+,d7
			swap					d7
			rol.w					#8,d7
			adda.w					d7,a2
			lsr						#1,d7
			move.w					d7,4(a5)																														; store length of sample, words-length for use in trackerplayer
			lsr						#1,d7
			subq					#2,d7
			clr.l					d3
			tst.l					d7
			bmi						.originalWav																													; original .iff/8svx do not need conversion
			eor.l					#$80808080,d3																													; .wav need
.originalWav
			lea						4(a0),a0
    ;SEARCHXML4VALUE (a0),"SSND"     ; find data-structure
			clr.w					(a3)+																															; first sample-longword needs to 0 for soundtracker-use
.copySample
			move.l					(a0)+,d0
			eor.l					d3,d0																															; convert unsigned to signed audio format
			move.l					d0,(a3)+																														; copy to tempMem
			dbra					d7,.copySample
			addq.l					#8,a5																															; next entry in fxTable

			SEARCHXML4VALUE			(a4),".wav"																														; find eof
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
			move.l					#MEMF_CHIP|MEMF_CLEAR,d1																										; get memory for fx-samples
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
			move.l					copperGame(pc),a1																												; abused as temp storage
			move.l					audioWavTable(pc),d7																											; memory base

.getFX
			move.l					(a0),d0																															; get first longword of fx-entry / index to sample
			beq						.lastFXfound
			move.l					(a1,d0*8),d1																													; fetch relative adress
			add.l					d7,d1																															; add offset of samplememory
			move.l					d1,(a0)+																														; overwrite with actual address of sample in memory
			move.w					4(a1,d0*8),d0																													; get sample length
			move.w					d0,(a0)
			lea						8(a0),a0
			bra						.getFX
.lastFXfound
			IFEQ					HISCORETABLEDEFAULT
			bsr						loadHighscores																													; load highscore table from NV oder HD
			ENDIF
    ; continue with preparations

;.allocMem						SET						copSplitListSize+copLinePrecalcSize+collListSize+bobDrawListSize+bobRestoreListSize+objectListSize+shotColFadeTableSize
.allocMem	SET						copSplitListSize+copLinePrecalcSize+collListSize+bobDrawListSize+bobRestoreListSize+objectListSize+shotColFadeTableSize
			move.l					#.allocMem,d0
			moveq					#MEMF_CLEAR>>16,d1																												; MEMF_ANY
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
.add		SET						bobDrawListEntrySize*10
			move.w					#bobDrawListSize/2,d1
			add.l					d1,d0
			move.l					d0,4(a0)
			lea						-.add(d0.l),a1
			move.l					a1,12(a0)																														; store end of bobdrawlist A
			add.l					d1,d0
			lea						-.add(d0.l),a1
			move.l					a1,16(a0)																														; store end of bobdrawlist B

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
			move.l					d0,(a0)																															; object table shot sprites
			moveq					#AnimPtrNoShotOffset,d1
			add.l					d1,d2
			move.l					d2,4(a0)																														; object table all other objects
			move.l					d2,a1																															; +8 contains dynamic pointer to best available object slot
			lea						objectListEntrySize-8(a1),a1
			move.l					a1,12(a0)																														; object list endOfTable

			add.l					#objectListSize,d0
shotColIterations		=	16
shotNoOfPals			=	3
shotNoOfUpgrades		=	3
shotColFadeTableSize	=	shotColIterations*shotNoOfUpgrades*shotNoOfPals*3
			lea						colorFadeTable(pc),a0
			move.l					d0,(a0)

; precalc fade colors for 3 colored-shot sprites between 4 palettes

			move.l					colorFadeTable,a0																												; color1
			lea						playerShotColors+4+16,a1
			lea						playerShotColors+4,a2
			jsr						precalcColorFade

			move.l					colorFadeTable,a0
			lea						64(a0),a0
			lea						playerShotColors+4+32,a1
			lea						playerShotColors+4+16,a2
			jsr						precalcColorFade

			move.l					colorFadeTable,a0																												;color2
			lea						128(a0),a0
			lea						playerShotColors+8+16,a1
			lea						playerShotColors+8,a2
			jsr						precalcColorFade

			move.l					colorFadeTable,a0
			lea						192(a0),a0
			lea						playerShotColors+8+32,a1
			lea						playerShotColors+8+16,a2
			jsr						precalcColorFade

			move.l					colorFadeTable,a0																												;color3
			lea						256(a0),a0
			lea						playerShotColors+12+16,a1
			lea						playerShotColors+12,a2
			jsr						precalcColorFade

			move.l					colorFadeTable,a0
			lea						320(a0),a0
			lea						playerShotColors+12+32,a1
			lea						playerShotColors+12+16,a2
			jsr						precalcColorFade

			lea						scoreHigh,a0																													; clr score and hiscore
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

			move.l					#copSpriteDMA,d0																												; prepare Sprite-pointers sublists
			move.l					d0,a2
			move					d0,copInitSprPtLW
			swap					d0
			move					d0,copInitSprPtHW

			lea						copSpriteLists(pc),a0																											; write base pointers to 8 preconf´d copper sprite init list. Mix for buffering
			move					#copSpriteDMAOffset,d2
			move.l					a2,a3

			lea						copSpriteDMAOffset*4(a3),a3

			moveq					#3,d7																															; prepare Sprite-pointers sublists
.copSprListPointers
			move.l					a2,(a0)
			move.l					a3,4(a0)
			adda.w					d2,a2
			adda.w					d2,a3
			addq					#8,a0
			dbra					d7,.copSprListPointers

.copSprListReturn
			move.l					#copInitSprPtReturn,d0																											; add return pointers to 8 sprite DMA inits
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

			move.l					#copGameReturn,d0																												; prepare default copper sublist
			lea						copGamePlyBodyReturn+2,a0
			move					d0,copGameReturnL
			move					d0,(a0)																															; gets modified in runtime, this is just a safety net
			swap					d0
			move					d0,copGameReturnH
			move					d0,4(a0)																														; ""

			lea						copGameDefault,a0																												; copy return code to each sub copper list
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

			move.l					#objectDefsFile,d1																												; load and prepare object data
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
			movem.l					d0-d1,(a2)																														; temporary memory pointers


searchXMLObjects
			SEARCHXML4VALUE			(a0),"obj:"																														; find object
			tst						d4
			bmi						getObjectBitmapMemory																											; last entry found, continue
			move.l					a0,a2
			move.l					(a0)+,(a1)+
			move.l					(a0)+,(a1)+


			clr.l					d7																																; clear flag
			clr.l					tempVar+28																														; reset pointer to obj mem adress
       
			SEARCHXML4VALUE			(a0),"name"																														; filename of object data?
			tst						d4
			bmi						keepCurrentPixels																												; no? use current pixels in memory (is sprite, or obj with shared pixel content)
    ; found tag "name", therefore load new moving object pixels into buffer

			SEARCHXML4VALUEShort	(a0),"ing>"

			move.l					tempVar+24(pc),d0
			sub.l					tempVar+20(pc),d0
			move.l					d0,objectDefSourcePointer(a1)																									; offset mem adress of pixeldata
			move.l					d0,tempVar+16


			lea						tempVar+12(pc),a5
			movem.l					a0/a1/a6,-(a5)																													; DOS-Code destroys these registers

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
			jsr						GetFileInfo(pc)																													; file exists? Get basic data
			tst.l					d0
			beq						errorDisk

	;    SAVEREGISTERS
    ;move.l fxPlanePointer(pc),d0
	;lea tempVar+28(pc),a0
	;move.l d0,(a0); get memory for current object bitmap
	;   RESTOREREGISTERS

			lea						tempFilename(pc),a4
			move.l					a4,d1
			move.l					fxPlanePointer(pc),d2																											; use parallax memory as temp object data storage
			move.l					#fxPlaneWidth*fxPlaneHeightBig*fxPlaneDepth,d3																					; do  load only upto size of available memory
			jsr						loadFile
			tst.l					d0
			beq						errorDisk


			movem.l					(a5)+,a0/a1/a6
			SEARCHXML4VALUE			(a0),"widt"																														; store width
			asciiToNumber			(a0),d3
			asr						#1,d3
			move.b					d3,objectDefWidth(a1)

			clr						d4
			SEARCHXML4VALUE			(a0),"heig"																														; store heigth
			asciiToNumber			(a0),d4
			move.b					d4,objectDefHeight(a1)
			clr						d3
			move.b					objectDefWidth(a1),d3
			lsr						#2,d3																															; width of one bob.b

			move.l					(fib_Size.w,pc),d2
			lsr.l					#2,d2																															; size one bitplane
			divu					d4,d2																															; sizeof all anims one bitplane complete line.b
			move					d2,d5
			move.w					d5,objectDefMask(a1)
			lsl						#1,d5
			sub.w					d3,d5																															; modulus.b
			subq					#2,d5
    ;lsl #1,d5
;    	move.w objectDefModulus(a1),d0
			move.w					d5,objectDefModulus(a1)

			bra						findAttribs
keepCurrentPixels
			move.l					tempVar+16,d7
			move.l					d7,objectDefSourcePointer(a1)																									; mem adress of pixeldata

			move.l					a2,a0
			SEARCHXML4VALUE			(a0),"widt"																														; store width
			asciiToNumber			(a0),d3
			asr						#1,d3
			move.b					d3,objectDefWidth(a1)

			clr.w					d4
			SEARCHXML4VALUE			(a0),"heig"																														; store heigth
			asciiToNumber			(a0),d4
			move.b					d4,objectDefHeight(a1)

			tst.w					d4
			beq						findAttribs

			lsr						#2,d3
			move.l					(fib_Size.w,pc),d2
			asr						#2,d2																															; size one bitplane
			divu					d4,d2																															; sizeof all anims one bitplane complete line.b
			move					d2,d5
			move.w					d5,objectDefMask(a1)
			lsl						#1,d5
			sub.w					d3,d5																															; modulus.b
			subq					#2,d5
			move.w					d5,objectDefModulus(a1)
findAttribs
			move.l					d7,a3
			moveq					#0,d7
			SEARCHXML4VALUE			(a0),"ribs"																														; find attributes
			asciiToNumber			(a0),d7
			SEARCHXML4VALUE			(a0),"rite"																														; find sprite yes or no
			asciiToNumber			(a0),d3

    ;tst d7
    ;bmi .skipBitmapPreps ; control by bob code, but has no bitmap (e.g. event hub, empty obj)
			tst						d3
			bne						.isSprite

			move.b					d7,objectDefAttribs(a1)
			tst.l					a3																																;keep current pixels?
			bne						.skipBitmapPreps

			btst					#6,d7
			bne						.noMask
	; bob with attrib-bit 6 clear -> create mask
			bsr						.createMask

			move.l					(fib_Size.w,pc),d7
			lsl.l					#1,d7

			add.l					d7,tempVar+24																													; pointer to next object entry
			bra						.skipBitmapPreps

.noMask		; bob with attrib-bit 6 set -> no mask

			lsr						objectDefModulus(a1)
			clr.w					d0
			move.b					objectDefWidth(a1),d0
			lsr						#3,d0
			addq					#1,d0
			sub						d0,objectDefModulus(a1)																											; no mask -> modify modulus

			movem.l					a0/a1/a6,-(sp)
			move.l					fxPlanePointer(pc),a0																											; source
			move.w					objectDefMask(a1),d0
			neg						d0
			lea						(a0,d0),a0																														; sub mask adress from source
			move.l					tempVar+24(pc),a1																												; destination  addr
			move.l					(fib_Size.w,pc),d0
			moveq					#8,d3
			add.l					d3,d0
			moveq					#-8,d3
			and.l					d3,d0																															; load objects only align to 8 byte adress

			moveq					#16,d4
			add.l					d4,d0


			add.l					d0,tempVar+24
			CALLEXEC				CopyMem																															; copy object w/o mask to permanent storage
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
			SEARCHXML4VALUE			(a4),"core"																														; store score
			tst						d4
			bmi						.noScore
			asciiToNumber			(a4),d3
			move.l					a4,a0
.noScore
			move					d3,objectDefScore(a1)
			lea						objectDefSize(a1),a1
			lea						objectDefSize(a6),a6
			bra						searchXMLObjects																												; jump to start of loop

.isSprite
			subq					#1,d3
			andi					#$3f,d3
			asl						#8,d7
			andi					#$7f<<8,d7
			or						d7,d3
			bset					#15,d3
			move					d3,objectDefAttribs(a1)																											; write attribs and spritenumber
			move					#0,objectDefScore(a1)																											;cant hit sprites, therefore score = 0
			lea						objectDefSize(a1),a1
			lea						objectDefSize(a6),a6
			bra						searchXMLObjects

.createMask


			clr.w					d4
			move.b					objectDefHeight(a1),d4
			move.l					(fib_Size.w,pc),d2
			lsr.l					#2,d2																															; size one bitplane
			divu					d4,d2																															; sizeof all anims one bitplane complete line.b
			move.l					tempVar+24(pc),d5																												; d5 = destination bob source addr
			clr.l					d6
			move					d2,d6
			add.l					d5,d6
    ;move.l d5,d6                    ; d6 = destination bob mask addr

			movem.l					a0-a2,-(sp)
			move.l					fxPlanePointer(pc),a0																											; pointer to current object bitmap
			bra						bobCutMaskPrepExit
bobCutMaskPrep
			move.l					a0,a1																															; loaded bitmap source
			move.l					d5,a3																															; bob source
			move.l					d6,a4																															; bob mask
			move					d2,d1
			lsr						#1,d1
			subq					#1,d1																															; no of bytes per line
bobCutMaskPrepLine
			moveq					#0,d7
			lea						(a1),a2
			lea						(a3),a5
			REPT					mainPlaneDepth
			move					(a2),d3
			move					d3,(a5)																															; store source pixeldata
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
			lsl.l					#2,d7																															; one line, four bitplanes
			adda.w					d7,a0
			add.l					d7,d5																															; add one line to source pointer
			add.l					d7,d6																															; mask pointer
			add.l					d7,d5																															; add one line to source pointer
			add.l					d7,d6																															; mask pointer
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
			move.l					d0,(a0)																															; memory for object definitions
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


			move.l					#animDefsFile,d1																												; load and prepare animation data
			move.l					diskBuffer+4(pc),d2
			move.l					diskBufferSize(pc),d3
			bsr						createFilePathOnStage
			bsr						loadFile
			tst.l					d0
			beq						errorDisk

;	#MARK: decode animDefinitions



			move.l					tempMemoryPointersXML+4(pc),a5
			clr.l					d6																																; how much memory we need? counter!
			move.l					tempBufferAnimPointers(pc),a3																									; used for temp storing anim names and pointers
			move.l					tempStoreXML(pc),a1

			move.l					diskBuffer+4(pc),a0
			lea						$b0(a0),a0
			clr						animDefsAmount																													; clear counter for number of animdefs

			lea						tempVar(pc),a6
searchXMLAnimations

			SEARCHXML4VALUE			(a0),"nim:"																														; find animation

			tst						d4
			bmi						writeAnimationList
			addq					#1,animDefsAmount
			move.l					a1,(a5)+
			movem.l					(a0)+,d0/d1
;    cmpi.l #"lnds",d0
;   bne .ssss
;   DEBUGBREAK
;.ssss
			movem.l					d0/d1/d6,(a1)																													; save name, needed later for binding anims with launchTable.
			movem.l					d0/d1/d6,(a3)																													; save name, needed later for calling anims from individual bobcode
			lea						12(a1),a1
			lea						12(a3),a3
			lea						12(a0),a0
			SEARCHXML4VALUE			(a0),"dict"																														; start of anim data
			clr.l					(a6)																															; reset counter formerly known as "loopGap"
			sf.b					4(a6)																															; clear first-entry-flag
			lea						objName(pc),a2
			clr.l					(a2)+
			clr.l					(a2)																															; clear temp name space


searchXMLAnimationStep

			searchXML4Anim			(a0),"ect<"																														; start of object
			tst						d4
			bmi						reachedLastAnimStep
			searchXML4Anim			(a0),"ing>"																														; find object name

			cmp.b					#"<",(a0)																														; if objectname=empty, use old name (no need to write objName in consecutive animDef-cells)
			bne.b					.readObjName
			tst.l					objName(pc)																														; forgot to insert objectname into first animList entry? Use emptyObj then
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

			move.l					tempBuffer(pc),a2																												; find object number in obj definitions list
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
			dbra					d4,searchObjList																												; cant find object defined within anim-list. Throw error, quit!
			suba.w					#8,a0
			bra						errorXMLAnim

foundObject
			sub.b					d4,d7
			lsl						#1,d7
			move.b					d7,animDefType(a1)

			searchXML4Anim			(a0),"xAcc"																														; get xAcc
			searchXML4Anim			(a0),"ger>"

			move.l					a0,a4
			asciiToNumber			(a0),d5
			cmpi.b					#"-",(a4)
			bne.b					.negXAcc
			neg						d5
.negXAcc
			move					d5,animDefXAcc(a1)

			searchXML4Anim			(a0),"yAcc"																														; get yAcc
			searchXML4Anim			(a0),"ger>"

			move.l					a0,a4
			asciiToNumber			(a0),d5
			cmpi.b					#"-",(a4)
			bne.b					.negYAcc
			neg						d5
.negYAcc
			move					d5,animDefYAcc(a1)

			searchXML4Anim			(a0),"dura"																														; get duration
			searchXML4Anim			(a0),"ger>"
			asciiToNumber			(a0),d5
			tst.b					4(a6)
			beq						.firstEntry
.retFirstEntry
			move.b					d5,animDefCnt(a1)
;	#MARK: manage code-mnemonics

			move.l					a0,a4
			searchXML4Anim			(a4),"code"																														; get code?
			tst						d4
			bmi						noCodeInit
                                ; take care of code mnemonic
			lea						30(a0),a0
			searchXML4Anim			(a4),"ing>"

			move.l					(a4)+,d0
			cmpi.l					#"loop",d0																														; marks end of loop
			bne.b					.rept
			move					#$00f1,animDefEndWaveAttrib(a1)
			move.l					a1,d4
			sub.l					(a6),d4
			move					d4,animDefNextWave(a1)																											; gap between entry and endOfloop
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
			cmpi.l					#"rept",d0																														; beginning of loop
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
			move					d3,animDefNextWave(a1)																											; write pointer to executable
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
			cmpi.l					#"trig",d0																														; set trigger to value (hibyte=trigger, lobyte=value)
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
			move					d3,animDefNextWave(a1)																											; write pointer to executable
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
			suba.l					d4,a0																															; pointer probably stopped at "anim" (marks begin of animsequence), so push a little back
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
			move.l					#MEMF_CHIP|MEMF_CLEAR,d1																										; memory for animation definitions
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
			add						d1,d0																															; *12
    ;muls #12,d0
			move.l					#MEMF_CHIP|MEMF_CLEAR,d1
			ALLOCMEMORY

			lea						animTable(pc),a0
			move.l					d0,(a0)																															; memory for storing anim names and jumpoffsets

			move.l					d0,a1
			move.l					tempBufferAnimPointers(pc),a0
			move					animDefsAmount(pc),d0
			moveq					#12,d5
			moveq					#16,d6
			bra.b					saveAnimPointersLoop
saveAnimPointers
			movem.l					(a0)+,d2-d4
			movem.l					d2-d4,(a1)
			lea						bobCodeCases(pc),a2																												; find and preload animadr (no need for GETANIMADRESS in runtime any more)
			move.w					#((bobCodeCasesEnd-bobCodeCases)/16)-1,d7
.2
			add.l					d6,a2
			cmp.l					(a2),d2
			bne.b					.3
			cmp.l					4(a2),d3
			beq.b					.4
.3			dbra					d7,.2
			IF						0=1
			IFNE					SHELLHANDLING
			SAVEREGISTERS
			bsr						shellAnimMissing
			RESTOREREGISTERS
			ENDIF
			ENDIF
			bra.b					.5
.4
			move.l					a1,12(a2)																														; write to table bobcustomcode.s
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
			bsr						initGameSoundtrack																												; start audiotrack halfway through loading

			IFNE					USEXMLFILE

		; fetch map data from xml-file & decode
			move.l					#mapDefsFile,d1																													; Load tilemap data
			move.l					diskBuffer+4(pc),d2
			move.l					diskBufferSize(pc),d3
			bsr						createFilePathOnStage
			bsr						loadFile
			tst.l					d0
			beq						errorDisk

			move.l					diskBuffer+4(pc),a0																												; width of tilemap
			SEARCHXML4VALUE			(a0),"orth"

			SEARCHXML4VALUE			(a0),"dth="
			tst						d4
			bmi						errorXML
			asciiToNumber			(a0),d5
			move					d5,tileMapWidth


			SEARCHXML4VALUE			(a0),"ght="																														; height of tilemap
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
			move.l					tilemapConverted(pc),a1																											; find tiles
			moveq					#$70,d7
			move					#tileSourceMaxTile,d3
			lea						$e0(a0),a0
			SEARCHXML4VALUE			(a0),"data"																														; find start of data
.getTile
			lea						11(a0),a0
			SEARCHXML4VALUE			(a0),"gid="
			tst						d4
			bmi						xmlAttackWaves																													;   no error check because built-in failsafe-routine in this case marks end of map data
			asciiToNumber			(a0),d5
			subq					#1,d5
			move.b					d5,d6
			andi.b					#$7,d6
			tst.b					d5																																; modify tilecode to match ingame fetch
			bmi						.flipXaxis
			lsr.b					#1,d5
			btst					#2,d5
			bne						.flipYAxis
			andi.b					#%111000,d5																														; keep tile unmodified
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

			lea						levDefFileVar(pc),a0																											; generate filename
			move.w					#"ma",(a0)+
			move.b					#"p",(a0)+
			move.w					gameStatusLevel(pc),d0
			add						#"A",d0
			move.b					d0,(a0)+
			move.b					#0,(a0)+

			move.l					#levDefFilename,d1
			move.l					diskBuffer+4(pc),d2
			move.l					diskBufferSize(pc),d3

			bsr						GetFileInfo																														; get filesize
			tst.l					d0
			beq						errorDisk

			tst.l					tilemapConverted(pc)
			beq.b					.freeMemory																														; memory alloc´d? Free it!
			move.l					tilemapConverted(pc),a1
			CALLEXEC				FreeVec
.freeMemory
			move.l					(fib_Size.w,pc),d0																												; get new memory
			move.l					#MEMF_CHIP|MEMF_CLEAR,d1
			ALLOCMEMORY

			lea						tilemapConverted(pc),a0
			move.l					d0,(a0)

	

			move.l					#levDefFilename,d1																												; load map file bitmap
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
			movem.l					d4-d7,(a1)																														; fetch tilemapsize, height etc. from very end of data file, store in resident vars

			ENDIF


    ; #MARK:  begin object mapping/get start position

xmlAttackWaves

			IFNE					USEXMLFILE

		; fetch launchTable from xml-file & decode
			SEARCHXML4VALUE			(a0),"star"																														; read startposition
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
			SEARCHXML4VALUE			(a0),"id="""																													; find anim in XML-List
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
			bra						errorXMLMapObject																												; could not find anim in map. Error and stop

foundObjectAnim

			SEARCHXML4VALUE			(a0),""" x="																													; x-launchposition
			asciiToNumber			(a0),d3

			sub.w					#96,d3
			SEARCHXML4VALUE			(a0),""" y="																													; y-launchposition
			move.l					a0,a5
			asciiToNumber			(a0),d7
			sub						#8,d7
			move					10(a4),d2
			movem.w					d2/d3/d7,(a1)

			clr.l					d3																																; preload with single object
			lea						24(a0),a0
			clr.l					d7
			move.l					a0,a4
			SEARCHXML4VALUEShort	(a4),"copy"
			tst						d4
			bpl						.copyObject																														; found copy command? Yes!
    ;move.l a4,a0
.single	; No -> single object. Also re-entry for copied object code

			SEARCHXML4VALUEShort	(a0),"hit"""																													; hitPoints value
.s22
			SEARCHXML4VALUEShort	(a0),"ue="""


			move.l					a0,a2
			asciiToNumber			(a0),d6

			cmpi.b					#"-",(a2)																														; if hitvalue<0 -> object not hitable
			bne.b					.basicHitBehave
			lea						1(a0),a0
			move.w					#attrIsNotHitableF<<8,d6
.basicHitBehave

			move.l					a0,a4
			SEARCHXML4VALUEShort	(a4),"link"																														; link-flag set? is group, share hitcount, destroy all members of group
			tst						d4
			bmi.b					.noChainAttrib
			SEARCHXML4VALUEShort	(a4),"ue="""
			bset					#attrIsLink+8,d6
			move.l					a4,a0
.noChainAttrib

			move.l					a0,a4
			SEARCHXML4VALUEShort	(a4),"opaq"																														; opaque-flag set? skip merging bob with background
			tst						d4
			bmi.b					.noOpaqueAttrib
			SEARCHXML4VALUEShort	(a4),"ue="""
			bset					#attrIsOpaq+8,d6
			move.l					a4,a0
.noOpaqueAttrib

			move.l					a0,a4
			SEARCHXML4VALUEShort	(a4),"refr"																														; refresh-flag set? skip merging bob with background
			tst						d4
			bmi.b					.noRefreshAttrib
			SEARCHXML4VALUEShort	(a4),"ue="""
			bset					#attrIsNoRefresh+8,d6
			move.l					a4,a0
.noRefreshAttrib


			move.l					a0,a4
			SEARCHXML4VALUEShort	(a4),"xadd"																														; xadd value
			bmi						.noXAdd
			SEARCHXML4VALUEShort	(a4),"ue="""
			move.l					a4,a0
			asciiToNumber			(a4),d4
			cmpi.b					#"-",(a0)
			seq						d7																																; sub from initial x-pos? Modify polarity!
			eor.b					d7,d4
			or.b					d4,d3
			move.l					a4,a0
.noXAdd

			move.l					a0,a4
			clr						d7
			SEARCHXML4VALUEShort	(a4),"yadd"																														; yadd value
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
			SEARCHXML4VALUEShort	(a4),"ue="""																													; find copy value
			asciiToNumber			(a4),d3
			tst						d3
			beq						.copyZero
							; decoding object attributes

	;move d5,d3
			addq					#2,d3
			bset					#7,d3																															; d3 = no of copied objects
			asl						#8,d3
			swap					d3
			SEARCHXML4VALUEShort	(a4),"gap"""																													; gap value
			SEARCHXML4VALUEShort	(a4),"ue="""
			asciiToNumber			(a4),d7
			swap					d7
			or.l					d7,d3
			move.l					a4,a0
			bra						.single
.copyZero
			move.l					#$82000000,d3
			SEARCHXML4VALUE			(a0),"hit"""																													;hit value
			bra						.s22

			SEARCHXML4VALUEShort	(a4),"gap"""																													; gap value
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
			move.l					4(a0),(a0)																														; restore original diskBuffer pointer

; #MARK:  sort objects sequence

			move.l					launchTable(pc),a0																												; address of array
			move.l					launchTableNoOfEntrys(pc),d0																									;number of items
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
			move.l					tempBufferAnimPointers(pc),a6																									; use as buffer for sorting
			move.l					launchTableEntryLength(pc),d6
			subq					#1,d6
.saveEntry
			move.b					(a3)+,(a6)+																														; write to buffer
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


			lea						levDefFileVar(pc),a0																											; generate filename
			move.l					#"laun",(a0)+
			move.w					#"ch",(a0)+
			move.w					gameStatusLevel(pc),d0
			add						#"A",d0
			move.b					d0,(a0)+
			move.b					#0,(a0)+

			move.l					#levDefFilename,d1																												; load launch file
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
			move.w					d4,(a1)																															; fetch startposition from very end of data file, store in resident var
			ENDIF

    ; #MARK:  write launchTable to disk

			IFNE					WRITElaunchTable
			lea						levDefFileVar(pc),a0																											; write launchTable to disk
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
			move.w					scr2StartPos(pc),-(a1)																											; store startposition at very end of file
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
			movem.l					d4-d7,-(a1)																														; store tilemapsize, height etc. at very end of data file
			bsr						writeMemToDisk
			ENDIF


; #MARK:  load and prepare Tiles
			move.l					tempBuffer(pc),a0																												; temp multiplication table for tile arrangement
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

			move.l					#tilePixelData,d1																												; load  pixel data
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
			moveq					#tilesWidth,d2																													; modulus source
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

			IFNE					0																																; old code, delete after 1.10.22
			move.l					Execbase,a6
			move.l					tempBuffer(pc),a1																												; mem buffer only needed for decoding TMX and Plist XML-data, can be freed
			CALLEXEC				FreeVec
			move.l					tempMemoryPointersXML+4(pc),a1																									; same here
			CALLEXEC				FreeVec
			move.l					tempStoreXML(pc),a1																												; and here
			CALLEXEC				FreeVec
			move.l					tempBufferAnimPointers(pc),a1																									; and here
			CALLEXEC				FreeVec
			ENDIF

                                    ;   ************************
                                    ;    ***** XML-decoding ends
                                    ;   ************************

; #MARK: XML DECODING ENDS
