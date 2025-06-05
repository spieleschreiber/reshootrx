
; RESHOOT.repeat  27. 7. 2016
; Copyright (c) 2016 Richard Löwenstein




;{ <- this lines only purpose is to keep indents and formatting in Xcode right
    PRINTT "Lets get this started!"



;           *******************
;           *** assemble values
;           *******************

;Check values for RELEASE CANDIDATE: DEBUG=0, RELEASE=1, RASTERLINE=0, PLAYERCOLL=0, DIFF=0, COMPATIBILITY=2, USEASSIGN=0

RELEASECANDIDATE=	0
SHOWframeCount	=	0
SHOWFRAMERATE	=	0
SHOWOBJECTNO	=	0

    IFEQ RELEASECANDIDATE

DEBUG=0; -> kein Debug -> start copperlidmaconst
RELEASE=0; 0 -> dev-version, jump direkt to gameplay
INITWITH = 00	;  20=intro, 30=title. 00 -> Initlevel defined in levelGetter.s
RASTERLINE=0;     -> 1 = show bordercolor -> check runtime
PLAYERCOLL=0;       -> 1 = player can be hit
DIFF=0;         -> 1 = start with higher difficulty
    IF Rasterline=0
AUDIO=1;        -> 0 = assemble without musicplayer
    ELSE
AUDIO=1       ; no music with active rasterlines
    ENDIF
AROS	=	0	; 0 = compile for Amiga OS, 1 = compile for AROS
MEMORYUSAGE	=	0	; 1=get chip and fastmem usage (add code size!)
DEMO=0; -> 0 full game, 1 demo version
COPLISTREWRITE	= 0	; 0=load coplist dynamically, 1=compile coplist, need to save binary manually
XMLDATAPACKED	=	0	; 1=use "t=" instead of "tile gid=" in map file
PACK_PHYSICAL	=	1	; 1 for CD-ROM intro pic,0 for digital edit
USEASSIGN=1   ;   1  = run from ASM One, changes directorypath
COMPATIBILITY	=	2; ; 0: 68000 only, Kickstart 1.3 only, PAL only. 1: All CPUs, Kickstarts and display modes. ; 2: 68010+, Kickstart 2.04+, all display modes
ALERTHANDLING=1   ; 1->show alerts onscreen
SHELLHANDLING	=	1	; 1-> send msg to shell. ATTN: Emu only!

	IF (INITWITH>0) ! (INITWITH<20)
DEM 	rs.l 2
	ENDIF

	ELSE

DEBUG=0
RELEASE=1
INITWITH=20
RASTERLINE=0
PLAYERCOLL=1
DIFF=0
AUDIO=1
AROS=0
MEMORYUSAGE	=	0
DEMO=0; -> 0 full game, 1 demo version
COPLISTREWRITE	= 0
XMLDATAPACKED	=	1
PACK_PHYSICAL	=	1	; 1 for CD-ROM intro pic,0 for digital edit
USEASSIGN=0
COMPATIBILITY	=	2
ALERTHANDLING=0
SHELLHANDLING	=	0		; must not be 1, otherwise crashes on real hardware
    ENDIF


;           *******************
;           *** startup values for myStartup
;           *******************

FASTMEM	=	0
; Set to 1 to enable pause on right mouse button
; with single-step on left mouse button
    IF RELEASE=1
RMBPAUSE	=	1
    ELSE
RMBPAUSE	=	0
    ENDIF

LMBEXIT     =   1
; Set to 1 if you use FPU code in your interrupt
FPUINT	=	0
; Set to 1 if you use the copper, blitter or sprites, respectively
COPPER	=	1
BLITTER	=	1
SPRITE	=	1

; #MARK: - CODE BEGINS

    SECTION gameCode,CODE	; attn: code in chipmem might execute very slowly on fast cpus > 030

t:

	bra start

	INCDIR reshoot:		; needed for ASM One -> include binary files
	
	include dos_lib.i
    Include macro.s
    Include loadFile.s
    Include readjoypad.s
    Include stingraysStartup.s
	Include saveState.s

	even


; #MARK: - FILENAME DEFINITIONS

	IFEQ USEASSIGN
filenamePrefix MACRO
	dc.b "PROGDIR:data/"
	ENDM
	ELSE
filenamePrefix MACRO
	dc.b "reshoot:data/"
	ENDM
	ENDIF


tempFilename
    filenamePrefix
tempFilenameVar
    blk.b 20,0
    even

mapDefsFile
    FILENAMEPREFIX
    IFEQ DEMO
    dc.b "levDefs/map0.tmx",0
    ELSE
    dc.b "levDefs/dem0.tmx",0
    ENDIF
animDefsFile
    FILENAMEPREFIX
    dc.b "levDefs/anims0.plist",0
objectDefsFile
    FILENAMEPREFIX
    dc.b    "levDefs/objects0.plist",0 ; approx. 14 KB
tilePixelData
    FILENAMEPREFIX
    dc.b    "levDefs/mainTiles0.int",0      ; approx. 131 KB
colorDefsFile
    FILENAMEPREFIX
    dc.b "levDefs/mainColors0.pal",0
escalationFilename
    FILENAMEPREFIX
    dc.b "escalation.raw",0
parPlaneNebula
    FILENAMEPREFIX
    dc.b    "secondPlaneNebula.raw",0      ; ca. 50 KB
parPlaneSpace
    FILENAMEPREFIX
    dc.b    "secondPlaneSpace.raw",0
parPlaneSolar
    FILENAMEPREFIX
    dc.b    "secondPlaneSolar.raw",0
parPlaneSky
    FILENAMEPREFIX
    dc.b    "secondPlaneSky.raw",0
parPlaneSea
    FILENAMEPREFIX
    dc.b    "secondPlaneSea.raw",0
parPlaneCity
    FILENAMEPREFIX
    dc.b    "secondPlaneCity.raw",0
introPicture
    FILENAMEPREFIX
    IFNE PACK_PHYSICAL
    dc.b	"intropic_signature.raw",0
    ELSE
    dc.b	"intropic.raw",0
    ENDIF
ham8palette
    FILENAMEPREFIX
    IFNE PACK_PHYSICAL
    dc.b	"intropic_signature.pal",0
    ELSE
    dc.b	"intropic.pal",0
    ENDIF
introLogo	; 8 sprites 64 x 49 pixels, saved with ctrl words
    FILENAMEPREFIX
    dc.b    "introLogo",0


parallaxSprite
    FILENAMEPREFIX
    dc.b    "parSprite0.raw",0     ; ca. 4 KB (*32)
    even
; #MARK: - GAME CONSTANTS
;           *******************
;           *** static values
;           *******************

   		include	"custom.i"
		include	"cia.i"
        include constants.s
        include exec_lib.i

enemiesMax  =   64
bulletsMax  =   128
shotsMax    =   12
objectsMax  =   shotsMax+bulletsMax+enemiesMax

copperGameMaxSize	=	12700

mainPlaneDepth   =   4
bckplaneDepth  =   3

displayWindowStart   =   $32
displayWindowStop   =   $24

mainplaneView    =   40
mainplaneCache   =   8
mainPlaneWidth   =   mainplaneView+mainplaneCache

artworkPictureSize =   80*240*8
artworkPaletteSize  =   64*4        ; 64 color entrys 24bit

; MARK: - TILEMAP DEFINITIONS

tilemapConvertedSize     dc.w    0
tilemapBckConvertedSize     dc.w    0
tileWidth       =   32
tileHeight      =   32
tilesWidth      =   (tileWidth/8)*16          ; 16 tiles
tilesHeight     =   128
tilemapHeight   dc.w 0
tileMapWidth    dc.w 0
tilemapBckHeight   dc.w 0
tilemapBckWidth    dc.w 0
tilemapBckNoMaps    dc.w    0

tileSourceMemSize      =   tilesWidth*tilesHeight*mainPlaneDepth
tileSourceMaxTile = tilesWidth/4*(tilesHeight/32)

bobSourceWidth   =  128 ; size in rows

viewLeftClip=40
viewRightClip=360
viewUpClip=40
viewDownClip=256+40

bckplaneWidth 		=  	64
bckplaneWidthVisible	 	=   40
bckplaneHeight    	=   256


playerExtraHeight  =   9
playerBodyHeight  =   16
spritePlayerHeight  =   playerBodyHeight+(playerExtraHeight*2)+2 ;(total height plus ctrl words)
spritePlayerWidth  =   $24
spriteShotHeight =   4
spriteScoreHeight  =   6
spriteParallaxHeight = displayWindowStop+$100-displayWindowStart
spriteScoreColumns  =   8
spriteHiXPosition =   188
spriteHiYPosition =   51    ; always out of PAL-area
spriteScoreXPosition =   spriteHiXPosition
spriteScoreYPosition =   30 ; always in PAL-area
spriteHiCtlrWordLo = spriteHiYPosition<<8+(spriteHiXPosition)
spriteHiCtlrWordHi = (spriteHiYPosition+spriteScoreHeight-1)<<8!%00000000<<0
spriteScoreCtlrWordLo = spriteScoreYPosition<<8+(spriteScoreXPosition)<<0
spriteScoreCtlrWordHi = (spriteScoreYPosition+spriteScoreHeight-1)<<8!%00001110<<0
spriteParallaxCtlrWordLo = $32<<8+0<<0
spriteParallaxCtlrWordHi = displayWindowStop<<8!%00000010<<0
;spriteParallaxCtlrWordHi=spriteHiCtlrWordHi
spriteDMAHeight    =   4 ; just some typical value for calc memsize
spriteDMAWidth    =   64
spriteLineOffset    = spriteDMAWidth/8*2
;OLD: spriteDMAMemSize=(spriteDMAHeight*(spriteDMAWidth/8)*2)*256;adds up to #$?????
spriteDMAMemSize=((bulletsMax+shotsMax+2)*spriteLineOffset*(spriteDMAHeight+1))*4; calculated for four sprites; 4 px height plus control slot; 4 animation frames
spriteDMAListOffset=(spriteDMAMemSize/4)/4
spriteScoreBufferSize  =   (spriteDMAWidth/8)*((spriteScoreHeight+1)*2)*2
spriteParallaxBufferSize  =   ((spriteDMAWidth/8)*(spriteParallaxHeight+1)*2)*32
spriteParMultiSize  =   32*4

copLineListSize   =   256*2
noOfCoplines SET (displayWindowStop+$100-displayWindowStart)/2
noOfCoplineAnims SET $80
copLinePrecalcSize  =   noOfCoplines*4*noOfCoplineAnims ; no.lines*size of 1 entry*max width
;spritePosMemFaktorizer=4
spritePosMemSize=(294*24) ;space for 294 lines, first 48 not really needed (but kept to speed code up a little) 4 bytes per entry, calculated for max. 6 sprites per line.
collListEntrySize   =   12
collListBobOffset   =   shotsMax*collListEntrySize
collListShotsOffset =   0
collListSize =   (enemiesMax*collListEntrySize+shotsMax*collListEntrySize)+4
	RSRESET
collTableAnimActionAdr		rs.l	1
collTableYCoords			rs.l	1
collTableXCoords			rs.l	1

	RSRESET
bobRestoreListSource    rs.l 	1
bobRestoreListTarget    rs.l 	1
bobRestoreListBlitSize  rs.w 	1
bobRestoreListEntrySize rs.w	1
bobRestoreListSize  =   (enemiesMax+1)*bobRestoreListEntrySize*2

	RSRESET
bobDrawBLTMOD  			rs.w	1
bobDrawBLTSIZE 			rs.w	1
bobDrawBLTCON0  		rs.l	1
bobDrawBLTPT    		rs.l 	3
bobDrawListEntrySize	rs.w 	1
bobDrawListSize    = (enemiesMax+1)*bobDrawListEntrySize*2


animTableName   =   0
animTablePointer    =   8

;           launchTable offsets. Length of one full entry calculated automatically, so feel free to add more attribs. "NotUsed" needs to be last
	RSRESET
launchTableAnim				rs.w	1
launchTableX				rs.w	1
launchTableY				rs.w	1
launchTableRptr				rs.b	1
launchTableRptrDist			rs.b	1
launchTableRptCountdown		rs.b	1
launchTableRptYAdd			rs.b	1
launchTableAttribs			rs.b	1	;$80=Launch at static position; $40=non-opaque bob
launchTableHitpoints		rs.b	1
launchTableNotUsed			rs.b	1

;           object-list keeps track of each object. All values stored in lword-pairs with .b,.w & .l-size

objectListAnimPtr=0        ;.w
objectListX=objectsMax*4                 ;.l
objectListY=objectListX*2         ;.l
objectListAcc=objectListX*3      ;.l
objectListAccX=objectListAcc      ;.w
objectListAccY=objectListAcc+2   ;.w
objectListCnt=objectListX*5       ;.b
objectListAttr=objectListCnt+1    ;.b
objectListHit=objectListCnt+2 ;.w
    ;FIXME: Replace *7 with attr+1 to save memory
objectListMyParent=objectListX*6    ;.l
objectListMyChild=objectListX*7    ;.l
objectListGroupCnt=objectListX*8    ;.w
objectListLoopCnt=objectListGroupCnt+2  ;.b
objectListWaveIndx=objectListGroupCnt+3  ;.b
objectListTriggers=objectListX*9  ;.l
objectListTriggersB=objectListX*10  ;.l
objectListSize=objectListTriggersB+objectListX
AnimPtrNoShotOffset=4*12

	RSRESET
animDefXAcc			rs.w 	1
animDefYAcc			rs.w	1
animDefCnt			rs.b	1
animDefType			rs.b	1
animDefSize			rs.w	1
animDefEndWaveAttrib	= animDefSize
animDefNextWave		rs.w	0

    ; objectDefinitions Offsets. Beware: code implies manual multiplication of objectDefSize. Search whohle project! (e.g. macro.s)
	RSRESET
objectDefSourcePointer			rs.l 	1
objectDefWidth					rs.b 	1
objectDefHeight					rs.b	1
objectDefModulus				rs.w	1
objectDefMask					rs.w	1
objectDefEmptyB					rs.w	1
objectDefAttribs				rs.b	1
objectDefAnimPointer			rs.b	1
objectDefScore					rs.w	1
objectDefSize					rs.w	1

fontBitmapWidth=320/8
fontHeight=5

; #MARK: - GAME VARIABLES

gfxTileGridOffset     blk.l   $100


scr2mod		Macro ;3 Bitplanes
		dc.l  mainPlaneWidth*mainPlaneDepth*tileHeight*\1
		Endm
scr2Offset
    scr2mod 0
    scr2mod 1
    scr2mod 2
    scr2mod 3
    scr2mod 4
    scr2mod 5
    scr2mod 6
    scr2mod 7
    scr2mod 8


scr2LastOffset
    dc.l 0
scr2Flag
    dc.w 0
scr2StartPos
    dc.w 0





keyCode         ; stores keycode from keyboard. http://wiki.amigaos.net/w/images/thumb/6/68/LibFig34-1.png/800px-LibFig34-1.png
    dc.b 0
    even


; #MARK: - TEXT DEFINITIONS
titleHighBlink
    dc.b 0
titleHighFlag
	dc.b 0
titleHighText
    dc.b "NEW  HIGHSCORE",0
titleInitials
    dc.b "ENTER INITIALS",0
titleEncodedA
    dc.b "QUALIFIED FOR",0
titleEncodedAA
    dc.b "GLOBAL HERO TABLE",0
titleEncodedD
    dc.b "AT RESHOOTR=RICHARD?LOEWENSTEIN=DE",0
    dc.b "  AT RESHOOTR=SPIELESCHREIBER=DE  ",0
titleEncodedC
    dc.b "ENTER ",0

titleTextA
	IF DEMO=0
    dc.b "A MODERN AMIGA SHMUP",0
    ELSE
    dc.b "DEMO OF A MODERN AMIGA SHMUP",0
	ENDIF
titleTextA1
    dc.b "BY RICHARD LOEWENSTEIN",0
titleTextB
    dc.b "PIXELS BY KEVIN SAUNDERS",0
titleTextC
    dc.b "AURALS BY MARTIN AHMAN ",0
titleTextShopA
	dc.b "COPRODUCTION APC>TCP",0
titleTextShopB
	dc.b "VISIT WWW=AMIGASHOP=ORG",0

titleHighLocalHeroes
    dc.b "LOCAL HEROES",0
titleScoreText
    dc.b "0       ",0
    even

; #MARK: - SHELL TERMINAL MESSAGES

	IFNE SHELLHANDLING
shellNum		; send value.l in d0 to shell, msg-pointer a6
	SAVEREGISTERS
	lea 10(a6),a0
	bsr.w convertNumAscii
	move.l a6,a0
	bsr writeTerminal
	RESTOREREGISTERS
	rts
shellQuit
	lea .msg(pc),a0
	bra writeTerminal
.msg
	dc.b 13,10,"quit successfully",0
	even
shellBufferWarning
	SAVEREGISTERS
	lea .msg(pc),a0
	bsr writeTerminal
	RESTOREREGISTERS
	rts
.msg
	dc.b 13,10,"membuffer exceed warning",0
	even

shellLaunch
	lea .msg(pc),a0
	bra writeTerminal
.msg
	dc.b 13,10,"###",13,10,"launching RESHOOT R",0
	even
shellMemoryAvail
	AVAILMEMORY
	lea .msg+10(pc),a0
	bsr.w convertNumAscii
	lea .msg(pc),a0
	bra writeTerminal
.msg
	dc.b 13,10,"$         KB chipmem available ",0
	even

shellMemoryFree
	lea .msg+10(pc),a0
	bsr.w convertNumAscii
	lea .msg(pc),a0
	bra writeTerminal
.msg
	dc.b 13,10,"$         KB dealloc´d",0
	even

shellAnimMissing
	lea .msg(pc),a0
	movem.l d2/d3,(a0)
	bra writeTerminal
.msg
	dc.b 13,10,"          anim missing",0
	even


shellMemAllocd
	SAVEREGISTERS
	lea .msg+10(pc),a0
	bsr.w convertNumAscii
	lea .msg(pc),a0
	bsr writeTerminal
	RESTOREREGISTERS
	rts
.msg
	dc.b 13,10,"$          bytes alloc´d",0
	even


writeTerminal
	lea terminalMsg(pc),a1
	move.l #$20202020,d0
	move.l d0,(a1)
	move.l d0,4(a1)
	move.l d0,12(a1)
	move.l d0,16(a1)
	move.l d0,20(a1)
	move.l d0,24(a1)
	move.l d0,28(a1)

	moveq #30,d0
.copyChar
	move.b (a0)+,d1
	beq .quit
	move.b d1,(a1)+
	dbra d0,.copyChar
.quit
	move.b d1,(a1)+

	bra.w textToTerminal
convertNumAscii
	; number d0, memPointer+7 a0
    move #7,d7
.wrtNum
    move.l d0,d1
    andi.b #$f,d1
    cmpi.b #10,d1
    blt .isNum
    add.b #"A"-10,d1
    bra .wrtChar
.isNum
    add.b #"0",d1
.wrtChar
    move.b d1,-(a0)
    asr.l #4,d0
    dbra d7,.wrtNum
	rts
	ENDIF

; #MARK: - ERROR DEFINITIONS

errorBobMemory
    move #1,errorFlag
    moveq #_errorBobMem,d7
    jmp errorMessage
errorMemory
    move #1,errorFlag
    moveq #_errorLowMem,d7
    jmp errorMessage
errorDisk
    move #1,errorFlag
    moveq #_errorDiskRead,d7
    jmp errorMessage
errorXML
    move #1,errorFlag
    moveq #_errorXMLDecode,d7
    jmp errorMessage
errorConfig
    move #1,errorFlag
    moveq #_errorNoAGA,d7
    jmp errorMessage
errorXMLName
    move #1,errorFlag
    moveq #_errorXMLNamespace,d7
    moveq #7,d0
    lea errorXMLDecodeName,a2
.errorXMLcopyName
    move.b (a0)+,(a2)+
    dbra d0,.errorXMLcopyName
    jmp errorMessage
errorFlag
    dc.w 0
isAGA
    dc.b 0
    even


; #MARK: - MAIN PREPS CODE BEGINS

xA
	dc.l 0

xB
	dc.l 0
_Precalc
	clr errorFlag       ; main wont run if flag is set
	lea escalateIsActive(pc),a0
	sf.b (a0)
	lea gameInActionF(pc),a0
	sf (a0)      ; disable gamecode in interrupt
	lea plyBase(pc),a0
	sf.b plyPracticeAvail(a0)	; init only once

;	bset #0,$bfe001	; mute CD audio on CD32
;	move.w #3,$bfe201	; set potgo to direction in / read firebuttons

    move.w $dff004,d0
    and.w #$6F00,d0                      ; 0110111100000000
    cmp.w #$2200,d0                      ; 0010001000000000
    beq.b .aga
    cmp.w #$2300,d0                      ; 0010001100000000
.aga:
    seq.b isAGA
    tst.b isAGA
    beq errorConfig

	move.l	Execbase,a6
	btst	#0,296+1(a6)		; 68010+?
	beq.w errorConfig			; nope.

	moveq   #1,d0	; instr cache only
	moveq   #-1,d1	; affect all bits
	CALLDOS CacheControl	; disable all cache but instr cache

	bsr setgameStatus

    IFNE AUDIO
    clr.b AudioIsInitiated
    ENDC

	move.l	Execbase,a6
	sub.l	a1,a1
    CALLDOS FindTask

	move.l	d0,a1
	moveq #127,d0
    CALLDOS SetTaskPri

;    move #$200,$dff100                 ; clear screen while preparing data

    CLEARMEMORY #memoryPointers, #memoryPointersEnd-memoryPointers; clear memory pointers for flawless freeing in _exit-routine



    moveq #0,d0     ; how much memory for three screen buffers    (tilemapHeight*tileHeight*40*mainPlaneDepth)+1024
    moveq #8,d0      ; move tilemapHeight
    muls #tileHeight,d0
    muls #mainPlaneWidth,d0
    muls #mainPlaneDepth,d0
    moveq #0,d1
    move #$384,d1        ; move  tileMapWidth
    asl #2,d1
    add.l d1,d0           ; add buffer for scrolling modulo
	;lsl.l #1,d0

    move.l d0,mainPlaneOneSize          ;   =$ce10      (1 framebuffer)
    ;mulu#3,d0                                     ;   =$26a30   (3 framebuffers)
    move.l d0,d1
    lsl.l #1,d0
    add.l d1,d0
;   move.l d0,mainPlaneAllSize

	move.l #bckplaneWidth*bckplaneHeight*bckplaneDepth+16,d1; buffer for second plane
    add.l d1,d0
    add.l d1,d0

         ; parallax layer
    move.l d0,diskBufferSize
	;move.l diskBufferSize,d0
	;bsr memyAllocMsg
	;move.l diskBufferSize,d0
    move.l	#Chip!Mem_Clear,d1                          ; triplebuffer bitplane A
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF

    lea mainPlanes(pc),a0
    lea mainPlanesPointer(pc),a1
    lea diskBuffer(pc),a2
    move.l mainPlaneOneSize(pc),d1
    move.l d0,12(a0)
    move.l d0,d2

	moveq #16,d7
	add.l d7,d2
	moveq #-8,d7
	and.l d7,d2	; align to 8 byte adress
	move.l	d2,(a2)    ; use bitplane buffer as diskBuffer
	move.l	d2,4(a2) ; first one gets modified, second one stays original
    move.l d0,(a0)      ; content will be swapped (triple buffer)
    move.l d0,(a1)      ; content will be added
    add.l d1,d0
    move.l d0,4(a0)     ;   ""
    move.l d0,4(a1)     ;   ""
    add.l d1,d0
    move.l d0,8(a0)         ;   ""
    move.l d0,8(a1)         ;   ""
    add.l d1,d0
	move.l d0,d2
    move.l #bckplaneWidth*bckplaneHeight*bckplaneDepth+16,d1
	add.l d1,d2

    lea bckplanePointer(pc),a0      ; prep. 2nd parallax layer
	move.l	d0,(a0)
	move.l d2,8(a0)
    moveq #16,d7
    add.l d7,d0
    add.l d7,d2
    moveq #-8,d7
    and.l d7,d0
    and.l d7,d2
    move.l d0,4(a0) ; needed for correct AGA-adressing, used in screenmanager and load bitmap code
	move.l d2,12(a0)

	lea bobCodeCases,a0                ; reset pointers to dynamic animation code entrys
	move.w #bobCodeCasesEnd-bobCodeCases,d2
	lsr #4,d2
	bra .clrBobCodePointersLoop
.clrBobCodePointers
	clr.l 12(a0)
	lea 16(a0),a0
.clrBobCodePointersLoop
	dbra d2,.clrBobCodePointers

;#MARK: build basic memory structures

	move.l #copperGameMaxSize,d0		; copperlist max. size
    move.l	#Chip!Mem_Clear,d1
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	    lea copperGame(pc),a0
	move.l	d0,(a0)


bobSourceMem
bobSourceSize=$60000
	move.l #bobSourceSize,d0
    move.l	#Chip!Mem_Clear,d1
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	    lea bobSource(pc),a0
	move.l	d0,(a0)    ; remains unchanged
	move.l	d0,4(a0)        ; will be changed



    lea launchTableEntryLength(pc),a0
    moveq #(launchTableNotUsed+2)&$3e,d0
    move.l d0,(a0)           ; create buffer for launchTable
    lsl.w #8,d0                                 ; allows for 256 entrys
    move.l d0,launchTableBufferSize

	;move.l	#Any!Mem_Clear,d1
	moveq #Mem_Clear>>16,d1
	swap d1
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	    lea launchTable(pc),a0      ; build permanent launchTable buffer
	move.l	d0,(a0)

	move.l	launchTableBufferSize(pc),d0
	;move.l	#Any!Mem_Clear,d1
	moveq #Mem_Clear>>16,d1
	swap d1
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	    lea launchTableBuffer(pc),a2
	move.l	d0,(a2)         ; build secondary launchTable buffer, altered while game plays
	move.l	d0,4(a2)

	move.l	#tileSourceMemSize,d0       ; tiles source
	;move.l	#Any!Mem_Clear,d1
	moveq #Mem_Clear>>16,d1
	swap d1
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
		move.l	d0,tileSource

    ;#MARK: Load and prepare Audio-Data
	move.l bobSource(pc),d0	; use bob mem as temp mem for storing wav-files
    lea tempBuffer(pc),a0
	move.l	d0,(a0)

    IF AUDIO=1
    lea AudioNoOfSamples(pc),a2
    clr.b (a2)
    sub.l a2,a2         ; added size of samples
    move.l tempBuffer(pc),a3
    lea fxLoadTable,a4
    lea fxSamplePointers,a5
.loadNextFX
    tst.w (a4)
    beq .lastAudioFile
    move.l a4,d1
    add.b #1,AudioNoOfSamples
    move.l a3,a0
    sub.l tempBuffer(pc),a0
    move.l a0,(a5)              ; store offset of sample
    move.l diskBuffer+4(pc),d2; load and prepare sample data
   	move.l	diskBufferSize(pc),d3
    jsr loadFile
    beq errorDisk

    move.l diskBuffer+4(pc),a0
    SEARCHXML4VALUE (a0),"COMM"     ; find data-structure

    addq.l #6,a0
    move.l (a0),d7
    add.l d7,a2
    lsr #1,d7
    move.w d7,4(a5)                 ; store length of sample, words-length for use in trackerplayer
    lsr #1,d7
    subq #2,d7
    SEARCHXML4VALUE (a0),"SSND"     ; find data-structure
    clr.l (a3)+         ; first sample-longword needs to 0 for soundtracker-use
.copySample
    move.l (a0)+,(a3)+              ; copy to tempMem
    dbra d7,.copySample
    addq.l #8,a5             ; next entry in fxTable

    SEARCHXML4VALUE (a4),".iff"     ; find eof
    addq.l #1,a4
    bra .loadNextFX
.lastAudioFile
;	bra .memS

	IFNE SHELLHANDLING
	cmp.l diskBufferSize(pc),a2
	bls .noWarn
	bsr shellBufferWarning
.noWarn
	ENDIF

    move.l a2,d0
  	move.l	#Chip!Mem_Clear,d1   ; get memory for fx-samples
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
		move.l	d0,audioWavTable

    move.l Execbase,a6
    move.l tempBuffer(pc),a0
    move.l d0,a1
    move.l a2,d0
    subq.l #4,d0
    CALLDOS CopyMem

    clr.w d7
    move.b AudioNoOfSamples(pc),d7
    move.l audioWavTable(pc),d0
    lea fxSamplePointers,a0
    bra.b .audioPrepLoop
.addAudioOffset
    add.l d0,(a0)
    addq.l #8,a0
.audioPrepLoop
    dbra d7,.addAudioOffset
    ENDIF

	bsr.w loadHighscores
    ; continue with preparations

    move.l #escalationFilename,d1        ; check size of escalation bitmap
    move.l diskBuffer+4(pc),d2
   	move.l	diskBufferSize(pc),d3
    bsr GetFileInfo        ; check for sufficient memory
    beq errorDisk


    move.l (fib_Size.w,pc),d0	; filesize
  	move.l	#Chip,d1
    ALLOCMEMORY
    lea escalationBitmap(pc),a0
    move.l d0,(a0)

    move.l #escalationFilename,d1        ; load escalation bitmap
    move.l d0,d2
   	move.l	(fib_Size.w,pc),d3
    jsr loadFile
    beq errorDisk


   	move.l	#spritePosMemSize,d0    ;    sprite sorting and sprite dma-table
	;move.l	#Any!Mem_Clear,d1
	moveq #Mem_Clear>>16,d1
	swap d1
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	lea spritePosMem(pc),a0
	move.l	d0,(a0)
s:
	move.l	#spriteDMAMemSize,d0
	move.l	#Chip!Mem_Clear,d1
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	lea spriteDMAMem(pc),a0
	move.l	d0,8(a0)
	moveq #$10,d1
    add.l d1,d0
    andi.l #$fffffff8,d0
    move.l d0,(a0)

	move.l	#spriteDMAMemSize,d0        ; double buffering needed!
	move.l	#Chip!Mem_Clear,d1
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	lea spriteDMAMem(pc),a0
	move.l	d0,12(a0)
	moveq #$10,d1
	add.l d1,d0
    andi.l #$fffffff8,d0
    move.l d0,4(a0)

	move.l	#copLineListSize,d0
	;move.l	#Any!Mem_Clear,d1
	moveq #Mem_Clear>>16,d1
	swap d1
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	lea copLineList(pc),a0
	move.l	d0,(a0)

	move.l	#copLinePrecalcSize,d0
	move.l	#chip!Mem_Clear,d1
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	lea copLinePrecalc(pc),a0
	move.l	d0,(a0)

    move.l d0,a1
    lea coplineAnimPointers,a0
    move #noOfCoplines,d6
    move #noOfCoplineAnims,d7
    lsl #2,d6
    bra .quitLoop
.loop
    move.l a1,(a0)+
    add.l d6,a1
.quitLoop
    dbra d7,.loop

	move.l	#spriteScoreBufferSize,d0        ; Memory for score sprites
	move.l	#Chip!Mem_Clear,d1
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	lea spriteScoreBuffer(pc),a0
	move.l	d0,4(a0)
	moveq #8,d1
	add.l d1,d0
	andi.b #$f8,d0
	move.l	d0,(a0)

	move.l	#spriteParallaxBufferSize,d0        ; Memory for parallax sprites
	move.l	#Chip!Mem_Clear,d1
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	lea spriteParallaxBuffer(pc),a0
	move.l	d0,4(a0)
	moveq #8,d1
	add.l d1,d0
	andi.b #$f8,d0
	move.l	d0,(a0)

	move.l	#spriteParMultiSize,d0        ; Memory for parallax sprites
	move.l	#chip!Mem_Clear,d1
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	lea spriteParMultiTable(pc),a0
	move.l	d0,(a0)


	move.l	#collListSize,d0
	;move.l	#Any!Mem_Clear,d1
	moveq #Mem_Clear>>16,d1
	swap d1
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	lea collidingList(pc),a0
	move.l	d0,8(a0)
    move.l d0,a0
    moveq #-1,d1
    move.l d1,(a0)

   	move.l	#bobDrawListSize,d0
	;move.l	#Any!Mem_Clear,d1
	moveq #Mem_Clear>>16,d1
	swap d1
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF

	lea bobDrawList(pc),a0
	move.l	d0,(a0)
	move.l	d0,8(a0)
    move.l d0,a1
	clr.l (a1)
    clr.l d1
    move.w #bobDrawListSize/2,d1
    add.l d1,d0
	move.l	d0,4(a0)
    move.l d0,a1
	clr.l (a1)              ; reset entry pointers


   	move.l	#bobRestoreListSize,d0
	;move.l	#Any!Mem_Clear,d1
	moveq #Mem_Clear>>16,d1
	swap d1
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	lea bobRestoreList(pc),a0
	move.l	d0,(a0)
	move.l	d0,8(a0)
    move.l d0,a2
    add #bobRestoreListSize/2,d0
	move.l	d0,4(a0)
    move.l d0,a1
	clr.l (a2)
	clr.l (a1)

	lea objCount(pc),a0
	clr.w (a0)

  	move.l	#objectListSize,d0
	;move.l	#Any!Mem_Clear,d1
	moveq #Mem_Clear>>16,d1
	swap d1
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	lea objectList(pc),a0
	move.l	d0,(a0)    ; object table sprites
	moveq #AnimPtrNoShotOffset,d1
    add.l d1,d0
    move.l d0,4(a0)   ; object table bobs


shotColIterations=16
shotNoOfPals=3
shotColFadeTableSize=shotColIterations*4*shotNoOfPals*3
	move.l	#shotColFadeTableSize,d0
	move.l	#chip!Mem_Clear,d1
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	lea colorFadeTable(pc),a0
	move.l	d0,(a0)

; precalc fade colors for 3 colored-shot sprites between 4 palettes

    move.l colorFadeTable,a0    ; color1
    lea playerShotColors+4+16,a1
    lea playerShotColors+4,a2
    jsr precalcColorFade(pc)

    move.l colorFadeTable,a0
    lea 64(a0),a0
    lea playerShotColors+4+32,a1
    lea playerShotColors+4+16,a2
    jsr precalcColorFade(pc)

    move.l colorFadeTable,a0
    lea 128(a0),a0
    lea playerShotColors+4+48,a1
    lea playerShotColors+4+32,a2
    jsr precalcColorFade(pc)

    move.l colorFadeTable,a0    ;color2
    lea 192(a0),a0
    lea playerShotColors+8+16,a1
    lea playerShotColors+8,a2
    jsr precalcColorFade(pc)

    move.l colorFadeTable,a0
    lea 256(a0),a0
    lea playerShotColors+8+32,a1
    lea playerShotColors+8+16,a2
    jsr precalcColorFade(pc)

    move.l colorFadeTable,a0
    lea 320(a0),a0
    lea playerShotColors+8+48,a1
    lea playerShotColors+8+32,a2
    jsr precalcColorFade(pc)

    move.l colorFadeTable,a0    ;color3
    lea 384(a0),a0
    lea playerShotColors+12+16,a1
    lea playerShotColors+12,a2
    jsr precalcColorFade(pc)

    move.l colorFadeTable,a0
    lea 448(a0),a0
    lea playerShotColors+12+32,a1
    lea playerShotColors+12+16,a2
    jsr precalcColorFade(pc)

    move.l colorFadeTable,a0
    lea 512(a0),a0
    lea playerShotColors+12+48,a1
    lea playerShotColors+12+32,a2
    jsr precalcColorFade(pc)

	lea bobAdrTable,a0                  ; multiplication table for bob->target y-adressing
	move #255,d0
    moveq #2,d1
.setmulstab:
	move d1,(a0)+
	add #mainPlaneDepth*mainPlaneWidth,d1
	dbra d0,.setmulstab

    ; convert font numbers to fast font for scoredisplay
    lea font,a0
    moveq #fontBitmapWidth,d1
    lea fontNumbers,a1
    lea fontNumbersShdw(a1),a2
    moveq #9,d0
.1
    move.l a0,a3
    move.b (a3),d2
    add.l d1,a3
    move.b (a3),d3
    add.l d1,a3
    move.b (a3),d4
    add.l d1,a3
    move.b (a3),d5
    add.l d1,a3
    move.b (a3),d6

    move.b d2,3(a1)	; 5 x bitmaps
    move.b d3,2(a1)
    move.b d4,1(a1)
    move.b d5,(a1)
    move.b d6,4(a1)

	move.b d2,d7	; 5 x shadow
	lsr.b #1,d7
	and.b d7,d2
	eor.b d2,d7
    move.b d7,3(a2)

	move.b d3,d7
	lsr.b #1,d7
	and.b d7,d3
	eor.b d3,d7
    move.b d7,2(a2)

	move.b d4,d7
	lsr.b #1,d7
	and.b d7,d4
	eor.b d4,d7
    move.b d7,1(a2)

	move.b d5,d7
	lsr.b #1,d7
	and.b d7,d5
	eor.b d5,d7
    move.b d7,(a2)

	move.b d6,d7
	lsr.b #1,d7
	and.b d7,d6
	eor.b d6,d7
    move.b d7,4(a2)

    addq.l #1,a0
    adda.w #8,a1
    adda.w #8,a2
    dbra d0,.1

    lea highDeltaPixels,a3
    move.b (a3)+,d2; convert delta logo
    move.b (a3)+,d3
    move.b (a3)+,d4
    move.b (a3)+,d5

    move.b d2,3(a1)
    move.b d3,2(a1)
    move.b d4,1(a1)
    move.b d5,(a1)

	move.b d2,d7
	lsr.b #1,d7
	and.b d7,d2
	eor.b d2,d7
    move.b d7,3(a2)

	move.b d3,d7
	lsr.b #1,d7
	and.b d7,d3
	eor.b d3,d7
    move.b d7,2(a2)

	move.b d4,d7
	lsr.b #1,d7
	and.b d7,d4
	eor.b d4,d7
    move.b d7,1(a2)

	move.b d5,d7
	lsr.b #1,d7
	and.b d7,d5
	eor.b d5,d7
    move.b d7,(a2)

    lea scoreHigh,a0            ; clr score and hiscore
    clr.l (a0)
    lea score,a1
    clr.l (a1)
    ;move.l #$564568,(a1); temp highscore setting

	;IF INITWITH<>20
    move #DMAF_SETCLR!DMAF_ALL,$dff096 ;DMA on: blitterpriority, bitplanes, sprites, copper, all audiochannels
   ; move.w #$0400,$dff096 ; Blitternasty on is faster on lowend machines. Tested on 13th of january
	;ENDIF
;!!!: Prepare Copperlist-Jumps

    ;WAITVBLANK
    ;WAITVBLANK

    move.l #coplist,d0
    move d0,copIntroL
    move d0,copTitleL
    move d0,copGameL
    swap d0
    move d0,copIntroH
    move d0,copTitleH
    move d0,copGameH

    move.l #copSpriteDMA,d0   ; prepare Sprite-pointers sublists
	move.l d0,a2
    move d0,copInitSprPtLW
    swap d0
    move d0,copInitSprPtHW

	lea copSpriteLists(pc),a0		; write base pointers to 8 preconf´d copper sprite init list. Mix for buffering
	move #copSpriteDMAOffset,d2
	move.l a2,a3
popo:
    lea copSpriteDMAOffset*4(a3),a3
	moveq #3,d7; prepare Sprite-pointers sublists
.copSprListPointers
    move.l a2,(a0)
    move.l a3,4(a0)
	adda.w d2,a2
	adda.w d2,a3
	addq #8,a0
	dbra d7,.copSprListPointers

.copSprListReturn
	move.l #copInitSprPtReturn,d0   ; add return pointers to 8 sprite DMA inits
	move.w #copSpriteDMAOffset,d1
	lea copSpriteDMA,a0
	move.l a0,a1
	moveq #7,d7
.wrtLoWord
	move d0,copSpriteDMAReturnLW(a0)
	adda.w d1,a0
	dbra d7,.wrtLoWord
    swap d0
	moveq #7,d7
.wrtHiWord
	move d0,copSpriteDMAReturnHW(a1)
	adda.w d1,a1
	dbra d7,.wrtHiWord

    move.l #copGameReturn,d0     ; prepare default copper sublist
    move d0,copGameReturnL
    swap d0
    move d0,copGameReturnH

	lea copGameDefault,a0       ; copy return code to each sub copper list
    movem.l (a0),d0-d3
    ;lea copGameParallaxSpriteEnd-(a0)
    lea copGameWelcomeEnd,a0
    movem.l d0-d3,(a0)
    lea copInitEscalateEnd,a0
    movem.l d0-d3,(a0)
    lea copExitEscalateEnd,a0
    movem.l d0-d3,(a0)
	lea copGameFinQuit,a0
    movem.l d0-d3,(a0)
	lea copGameFinColorsQuit,a0
    movem.l d0-d3,(a0)

   ; COPPERSUBLIST copGameDefault ;prepare jump to sub empty copper list


    WAITVBLANK

    move.l #copIntro,d0
    move.w d0,copsprInitLW
    swap d0
    move.w d0,copsprInitHW
	move.l #copList,$dff084
	clr.l $dff088
    rts

yToPlanarTable
.tempY SET 0
	REPT (displayWindowStop+$100-displayWindowStart)/2
	dc.w (mainPlaneWidth*mainPlaneDepth*.tempY)&$ffff
.tempY	SET		.tempY+2
	ENDR
	blk.l 100,-1
    ;FIXME: Code above still needed?

    ; #MARK: MAIN PREPS CODE ENDS


                                   ;   ************************
                                   ;    ***** XML-decoding start
                                   ;   ************************

; #MARK: - XML DECODING BEGINS
xmlDecode
	moveq #$20,d0
	lsl #8,d0
  	move.l	#chip!Mem_Clear,d1   ; temp memory, used for building up sorting list
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	lea tempBuffer(pc),a0
	move.l	d0,(a0)

; MARK:  decode objectdefinitions

    move.l #objectDefsFile,d1        ; load and prepare object data
    move.l diskBuffer+4(pc),d2
   	move.l	diskBufferSize(pc),d3
    jsr loadFile
    beq errorDisk

    move.l tempBuffer(pc),a1
    move.l diskBuffer+4(pc),a0
    lea $a8(a0),a0
;    adda.w #$a8,a0
    sub.l a6,a6

; #MARK:  object load, unpack, cookie cut
; memory map: plane0: object xml data, plane1: object bitmap data, plane2: object  mask
    lea tempVar+20(pc),a2
	;move.l diskBuffer+4(pc),d0
	move.l bobSource(pc),d0
    move.l d0,d1
	add.l mainPlaneOneSize(pc),d1
    movem.l d0-d1,(a2)      ; temporary memory pointers


searchXMLObjects
    SEARCHXML4VALUE (a0),"obj:"     ; find object
    tst d4
    bmi getObjectBitmapMemory	; last entry found, continue
    move.l a0,a2
    move.l (a0)+,(a1)+
    move.l (a0)+,(a1)+

	clr.l d7; clear flag
	clr.l tempVar+28; reset pointer to obj mem adress

    SEARCHXML4VALUE (a0),"name"     ; filename of object data?
   	tst d4
    bmi keepCurrentPixels          ; no? use current pixels in memory (is sprite, or obj with shared pixel content)
    ; found tag "name", therefore load new moving object pixels into buffer

    SEARCHXML4VALUEShort (a0),"ing>"

    move.l tempVar+24(pc),d0
    sub.l tempVar+20(pc),d0
    move.l d0,objectDefSourcePointer(a1)                 ; offset mem adress of pixeldata
    move.l d0,tempVar+16


    lea tempVar+12(pc),a5
    movem.l a0/a1/a6,-(a5); DOS-Code destroys these registers

    lea tempFilename(pc),a4
    move.l a4,d1
    lea tempFilenameVar(pc),a4
createFilename
    move.b (a0)+,d0
    cmpi.b #"<",d0
    beq endOfFilename
    move.b d0,(a4)+
    bra.b createFilename
endOfFilename
    clr.b (a4)
    move.l #70,d3
    jsr GetFileInfo(pc)         ; file exists? Get basic data
    beq errorDisk

    SAVEREGISTERS
    move.l (fib_Size.w,pc),d0
  	move.l	#chip,d1
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	lea tempVar+28(pc),a0
	move.l d0,(a0); get memory for current object bitmap
    RESTOREREGISTERS

    lea tempFilename(pc),a4
    move.l a4,d1
    move.l tempVar+28(pc),d2   ; use parallax memory as temp object data storage
    move.l (fib_Size.w,pc),d3
    jsr loadFile
    beq errorDisk


    movem.l (a5)+,a0/a1/a6
    SEARCHXML4VALUE (a0),"widt"     ; store width
    asciiToNumber (a0),d3
    asr #1,d3
    move.b d3,objectDefWidth(a1)

    clr d4
    SEARCHXML4VALUE (a0),"heig"     ; store heigth
    asciiToNumber (a0),d4
    move.b d4,objectDefHeight(a1)
    clr d3
    move.b objectDefWidth(a1),d3
    lsr #2,d3                    ; width of one bob.b

    move.l (fib_Size.w,pc),d2
    lsr.l #2,d2        ; size one bitplane
    divu d4,d2      ; sizeof all anims one bitplane complete line.b
    move d2,d5
    move.w d5,objectDefMask(a1)
    lsl #1,d5
    sub.w d3,d5     ; modulus.b
    subq #2,d5
    ;lsl #1,d5
;    	move.w objectDefModulus(a1),d0

    move.w d5,objectDefModulus(a1)

    bra findAttribs
keepCurrentPixels
    move.l tempVar+16,d7
    move.l d7,objectDefSourcePointer(a1)                 ; mem adress of pixeldata

    move.l a2,a0
    SEARCHXML4VALUE (a0),"widt"     ; store width
    asciiToNumber (a0),d3
    asr #1,d3
    move.b d3,objectDefWidth(a1)

    clr.w d4
    SEARCHXML4VALUE (a0),"heig"     ; store heigth
    asciiToNumber (a0),d4
    move.b d4,objectDefHeight(a1)

    tst.w d4
    beq findAttribs

    lsr #2,d3
    move.l (fib_Size.w,pc),d2
    asr #2,d2        ; size one bitplane
    divu d4,d2      ; sizeof all anims one bitplane complete line.b
    move d2,d5
    move.w d5,objectDefMask(a1)
    lsl #1,d5
    sub.w d3,d5     ; modulus.b
    subq #2,d5
    move.w d5,objectDefModulus(a1)
findAttribs
	move.l d7,a3
    moveq #0,d7
    SEARCHXML4VALUE (a0),"ribs"     ; find attributes
    asciiToNumber (a0),d7
    SEARCHXML4VALUE (a0),"rite"     ; find sprite yes or no
    asciiToNumber (a0),d3

    ;tst d7
    ;bmi .skipBitmapPreps ; control by bob code, but has no bitmap (e.g. event hub, empty obj)
    tst d3
    bne .isSprite

    move.b d7,objectDefAttribs(a1)
	tst.l a3		;keep current pixels?
	bne .skipBitmapPreps

	btst #6,d7
	bne .noMask
	; bob with attrib-bit 6 clear -> create mask
	bsr .createMask


	move.l (fib_Size.w,pc),d7
    lsl.l #1,d7
    add.l d7,tempVar+24	 ; pointer to next entry
	bra .freeObjMemory
.noMask		; bob with attrib-bit 6 set -> no mask
	lsr objectDefModulus(a1)
	clr.w d0
	move.b objectDefWidth(a1),d0
	lsr #3,d0
	addq #1,d0
	sub d0,objectDefModulus(a1); no mask -> modify modulus

	movem.l a0/a1/a6,-(sp)
    move.l tempVar+28(pc),a0		; source
	move.l tempVar+24(pc),a1	; destination  addr
	move.l (fib_Size.w,pc),d0
    add.l d0,tempVar+24
    CALLDOS CopyMem         ; copy object w/o mask to permanent storage
    movem.l (sp)+,a0/a1/a6
.freeObjMemory
    SAVEREGISTERS

    move.l tempVar+28(pc),a1
    tst.l a1
    beq .skipMem
    CALLDOS FreeVec  ; release obj bitmap memory
.skipMem
    RESTOREREGISTERS


.skipBitmapPreps
    lea animCases,a3
    lea animCasesEnd-animCases,a4
    moveq #0,d3
    movem.l (a2),d4/d5
.findAnim
    add #16,d3
    cmp a4,d3
    bge .noAnim
    movem.l (a3,d3),a2/a5
    cmp.l d4,a2
    bne .findAnim
    cmp.l d5,a5
    bne .findAnim
    addq #8,d3
    bra .writeAnim
.noAnim
    moveq #8,d3
.writeAnim
    asr #3,d3
    move.b d3,objectDefAnimPointer(a1)

    move.l a0,a4
    clr.l d3
    SEARCHXML4VALUE (a4),"core"     ; store score
    tst d4
    bmi .noScore
    asciiToNumber (a4),d3
    move.l a4,a0
.noScore
    move d3,objectDefScore(a1)
    lea objectDefSize(a1),a1
    lea objectDefSize(a6),a6
    bra searchXMLObjects		; jump to start of loop

.isSprite
    subq #1,d3
    andi #$3f,d3
    asl #8,d7
    andi #$7f<<8,d7
    or d7,d3
    bset #15,d3
    move d3,objectDefAttribs(a1)               ; write attribs and spritenumber
    move #0,objectDefScore(a1)                   ;cant hit sprites, therefore score = 0
    lea objectDefSize(a1),a1
    lea objectDefSize(a6),a6
    bra searchXMLObjects

.createMask


    clr.w d4
    move.b objectDefHeight(a1),d4
    move.l (fib_Size.w,pc),d2
    lsr.l #2,d2        ; size one bitplane
    divu d4,d2      ; sizeof all anims one bitplane complete line.b
    move.l tempVar+24(pc),d5       ; d5 = destination bob source addr
    clr.l d6
    move d2,d6
    add.l d5,d6
    ;move.l d5,d6                    ; d6 = destination bob mask addr

    movem.l a0-a2,-(sp)
    ;move.l diskBuffer(pc),a0
    ;move.l bckplanePointer(pc),a0   ; use as temp memory
    move.l tempVar+28(pc),a0; pointer to current object bitmap
    bra bobCutMaskPrepExit
bobCutMaskPrep
    move.l a0,a1    ; loaded bitmap source
	move.l d5,a3	; bob source
	move.l d6,a4	; bob mask
    move d2,d1
    lsr #1,d1
    subq #1,d1		; no of bytes per line
bobCutMaskPrepLine
    moveq #0,d7
    lea (a1),a2
    lea (a3),a5
    REPT mainPlaneDepth
    move (a2),d3
    move d3,(a5); store source pixeldata
    or d3,d7
    adda.w d2,a2
    adda.w d2,a5
    adda.w d2,a5
    ENDR

    lea (a4),a5
    REPT mainPlaneDepth
    move.w d7,(a5)
    adda.w d2,a5
    adda.w d2,a5
    ENDR
    lea 2(a1),a1
    lea 2(a3),a3
    lea 2(a4),a4
    dbra d1,bobCutMaskPrepLine

    clr.l d7
    move d2,d7
    lsl.l #2,d7    ; one line, four bitplanes
    adda.w d7,a0
    add.l d7,d5 ; add one line to source pointer
    add.l d7,d6 ; mask pointer
    add.l d7,d5 ; add one line to source pointer
    add.l d7,d6 ; mask pointer
bobCutMaskPrepExit
	dbra d4,bobCutMaskPrep
    movem.l (sp)+,a0-a2
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

getObjectBitmapMemory

    move.l a6,objectDefsSize


	IFNE SHELLHANDLING

    lea tempVar+20(pc),a2
    move.l 4(a2),d0
    sub.l (a2),d0
	sub.l mainPlaneOneSize(pc),d0
    lea .msg(pc),a6
	bsr shellNum
	bra .skip
.msg
	dc.b 13,10,"$         KB needed for objects",0
	even
.skip
	ENDIF

	IFNE SHELLHANDLING
    move.l 4(a2),d0
    sub.l (a2),d0
	;sub.l mainPlaneOneSize(pc),d0
	cmp.l bobSourceMem+2(pc),d0
	bls .noWarn
	bsr shellBufferWarning
.noWarn
	ENDIF

    ; MARK: point object defs to object bitmap definitions
    tst.l objectDefs(pc)
    beq.b .freeObjDefs
    move.l objectDefs(pc),a1
    CALLDOS FreeVec
.freeObjDefs
    move.l objectDefsSize(pc),d0
  	move.l	#chip!Mem_Clear,d1
  	move.l	Execbase,a6
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	lea objectDefs(pc),a0
	move.l	d0,(a0)       ; memory for object definitions
    move.l d0,a1
    move.l tempBuffer(pc),a0
    move.l objectDefsSize(pc),d1
    divu #objectDefSize,d1
    move d1,objectDefsAmount
    bra writeObjListLoop
writeObjList
    addq #8,a0
    move #objectDefSize/2-1,d2
.writeObj
    move (a0)+,(a1)+
    dbra d2,.writeObj
writeObjListLoop
    dbra d1,writeObjList


    move.l #animDefsFile,d1      ; load and prepare animation data
    move.l diskBuffer+4(pc),d2
   	move.l	diskBufferSize(pc),d3
    jsr loadFile
    beq errorDisk

;	#MARK: decode animDefinitions

    bsr initGameSoundtrack ; start audiotrack halfway through loading

	moveq #1,d0
	ror.w #3,d0	; =$2000
  	move.l	#chip!Mem_Clear,d1   ; temp memory, used for  building anim pointers list
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	lea tempBufferAnimPointers(pc),a0
	move.l	d0,(a0)

	moveq #1,d0
	ror.w #5,d0	; =$800
  	move.l	#chip!Mem_Clear,d1   ; temp memory, used for storing memory pointers to start of each anim
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	lea tempMemoryPointersXML(pc),a0
	move.l	d0,(a0)
	move.l	d0,4(a0)


	moveq #1,d0
	ror.w #3,d0	; =$2000
  	move.l	#chip!Mem_Clear,d1   ; temp memory, used for building up final lists
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	lea tempStoreXML(pc),a0
	move.l	d0,(a0)

    move.l tempMemoryPointersXML+4(pc),a5
    clr.l d6                      ; how much memory we need? counter!
    move.l tempBufferAnimPointers(pc),a3         ; used for temp storing anim names and pointers
    move.l tempStoreXML(pc),a1

    move.l diskBuffer+4(pc),a0
    lea $b0(a0),a0
    clr animDefsAmount              ; clear counter for number of animdefs

searchXMLAnimations
;    add #1,it
    SEARCHXML4VALUE (a0),"nim:"     ; find animation

    tst d4
    bmi writeAnimationList
    addq #1,animDefsAmount
    move.l a1,(a5)+

    movem.l (a0)+,d0/d1
    movem.l d0/d1/d6,(a1)         ; save name, needed later for binding anims with launchTable.
    movem.l d0/d1/d6,(a3)         ; save name, needed later for calling anims from individual bobcode
    lea 12(a1),a1
    lea 12(a3),a3
    lea 12(a0),a0
    SEARCHXML4VALUE (a0),"dict"     ; start of anim data
    clr.l loopGap
searchXMLAnimationStep

    searchXML4Anim (a0),"ect<"     ; start of object
    tst d4
    bmi reachedLastAnimStep
    searchXML4Anim (a0),"ing>"     ; find object name

    cmp.b #"<",(a0)                ; if objectname=empty, use old name (no need to write objName in consecutive animDef-cells)
    bne.b .readObjName
    move.l objName(pc),d0
    move.l objName+4(pc),d1
    bra.b .gotObjName
.readObjName
    movem.l (a0)+,d0/d1
    movem.l d0/d1,objName
.gotObjName

    move.l tempBuffer(pc),a2         ; find object number in obj definitions list
    clr.l d4
    move objectDefsAmount(pc),d4
    move.b d4,d7
    subq.b #1,d7
    bra.b searchObjListLoop
searchObjList
    movem.l (a2),d2/d3
    lea objectDefSize+8(a2),a2
    cmp.l d2,d0
    bne.b searchObjListLoop
    cmp.l d3,d1
    bne.b searchObjListLoop
    bra.b foundObject
searchObjListLoop

    dbra d4,searchObjList
    suba.w #8,a0
    bra errorXMLName

foundObject
    sub.b d4,d7
    lsl #1,d7
    move.b d7,animDefType(a1)

    searchXML4Anim (a0),"xAcc"     ; get xAcc
    searchXML4Anim (a0),"ger>"

    move.l a0,a4
    asciiToNumber (a0),d5
    cmpi.b #"-",(a4)
    bne.b .negXAcc
    neg d5
.negXAcc
    move d5,animDefXAcc(a1)

    searchXML4Anim (a0),"yAcc"     ; get yAcc
    searchXML4Anim (a0),"ger>"

    move.l a0,a4
    asciiToNumber (a0),d5
    cmpi.b #"-",(a4)
    bne.b .negYAcc
    neg d5
.negYAcc
    move d5,animDefYAcc(a1)

    searchXML4Anim (a0),"dura"     ; get duration
    searchXML4Anim (a0),"ger>"
    asciiToNumber (a0),d5
    move.b d5,animDefCnt(a1)
;	#MARK: manage code-mnemonics

    move.l a0,a4
    searchXML4Anim (a4),"code"     ; get code?
    tst d4
    bmi noCodeInit
                                ; take care of code mnemonic
    lea 30(a0),a0
    searchXML4Anim (a4),"ing>"

    move.l (a4)+,d0
    cmpi.l #"loop",d0                    ; marks end of loop
    bne.b .rept
    move #$00f1,animDefEndWaveAttrib(a1)
    move.l a1,d4
    sub.l loopGap(pc),d4
    move d4,animDefNextWave(a1)  ; gap between entry and endOfloop
	moveq #animDefSize*2,d4
    add.l d4,a1
    add.l d4,d6
    move.l a4,a0
    bra searchXMLAnimationStep
.rept
    cmpi.l #"rept",d0                   ; beginning of loop
    bne .xacc
    move #$00f7,animDefEndWaveAttrib(a1)
    move.l a1,loopGap
    add.l #animDefSize*2,loopGap
    bra.b .writeVals
.xacc
    cmpi.l #"xacc",d0
    bne.b .yacc
    move #$00f2,animDefEndWaveAttrib(a1)

.writeVals
    move.b (a4),d4
    asciiToNumber (a4),d3
    cmpi.b #"-",d4
    bne.b .neg
    neg d3
.neg
    move d3,animDefNextWave(a1)  ; write pointer to executable
	moveq #animDefSize*2,d4
    adda.l d4,a1
    add.l d4,d6
    move.l a4,a0
    bra searchXMLAnimationStep
.yacc
    cmpi.l #"yacc",d0
    bne.b .xpos
    move #$00f3,animDefEndWaveAttrib(a1)
    bra.b .writeVals
.xpos
    cmpi.l #"xpos",d0
    bne.b .ypos
    move #$00f4,animDefEndWaveAttrib(a1)
    bra.b .writeVals
.ypos
    cmpi.l #"ypos",d0
    bne.b .trig
    move #$00f5,animDefEndWaveAttrib(a1)
    bra.w .writeVals
.trig
    cmpi.l #"trig",d0                    ; set trigger to value (hibyte=trigger, lobyte=value)
    bne.b .customCode
    move #$00f6,animDefEndWaveAttrib(a1)
    bra.w .writeVals
.customCode
    move.l (a4)+,d1
    lea (bobCodeCases,pc),a0
    move.l #bobCodeCasesEnd-bobCodeCases,d2
    moveq #0,d3
.findCode
    add #16,d3
    cmp d2,d3
    bge .noCodeFound
    movem.l (a0,d3),d4/d5
    cmp.l d0,d4
    bne.b .findCode
    cmp.l d1,d5
    bne.b .findCode
    addq #8,d3
    move #$00f0,animDefEndWaveAttrib(a1)
;    bra .writeVals
    move d3,animDefNextWave(a1)  ; write pointer to executable
	moveq #animDefSize*2,d4
    add.l d4,a1
    add.l d4,d6
    move.l a4,a0
    bra searchXMLAnimationStep
.noCodeFound
  ;  move.l a4,a0
    sub.l #animDefSize,a0
    bra errorXMLName
noCodeInit
	moveq #animDefSize,d4
    adda.l d4,a1
    add.l d4,d6
    bra searchXMLAnimationStep
reachedLastAnimStep
    move.l #$00f000f0,(a1)
    moveq #animDefSize,d4
    adda.l d4,a1
    add.l d4,d6
    suba.l d4,a0             ; pointer probably stopped at "anim" (marks begin of animsequence), so push a little back
    bra searchXMLAnimations
loopGap
    dc.l 0
objName
    dc.l 0,0
writeAnimationList
    move.l a5,tempMemoryPointersXML
    move.l a1,(a5)


    tst.l animDefs(pc)
    beq.b .freeMemory
    move.l animDefs(pc),a1
    CALLDOS FreeVec
.freeMemory
    move.l d6,d0
    move.l d0,animDefsSize
  	move.l	#chip!Mem_Clear,d1   ; memory for animation definitions
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	lea animDefs(pc),a0
	move.l	d0,(a0)

    tst.l animTable(pc)
    beq.b .freeAnimTable
    move.l animTable(pc),a1
    CALLDOS FreeVec
.freeAnimTable
    move animDefsAmount(pc),d1
    clr.l d0
    move d1,d0
    lsl #3,d0
	lsl #2,d1
	add d1,d0; *12
    ;muls #12,d0
	move.l	#chip!Mem_Clear,d1
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	lea animTable(pc),a0
	move.l	d0,(a0)                        ; memory for storing anim names and jumpoffsets

    move.l d0,a1
    move.l tempBufferAnimPointers(pc),a0
    move animDefsAmount(pc),d0
    moveq #12,d5
    moveq #16,d6
    bra.b saveAnimPointersLoop
saveAnimPointers
    movem.l (a0)+,d2-d4
    movem.l d2-d4,(a1)
		lea bobCodeCases(pc),a2	; find and preload animadr (no need for GETANIMADRESS in runtime any more)
		move.w #((bobCodeCasesEnd-bobCodeCases)/16)-1,d7
.2
		add.l d6,a2
		cmp.l (a2),d2
		bne.b .3
		cmp.l 4(a2),d3
		beq.b .4
.3		dbra d7,.2
	IFNE SHELLHANDLING
		SAVEREGISTERS
		bsr shellAnimMissing
		RESTOREREGISTERS
	ENDIF
		bra.b .5
.4
		move.l a1,12(a2)	; write to table bobcustomcode.s
.5
    add.l d5,a1
saveAnimPointersLoop
    dbra d0,saveAnimPointers

    move.l animDefs,a0
    move animDefsAmount,d1
    move.l tempMemoryPointersXML+4,a3
    moveq #animDefSize,d7
    lsr #1,d7
    bra.b writeAnimListLoop
writeAnimList
    move.l 4(a3),d6
    move.l (a3)+,a4
    lea 12(a4),a4
writeAnimListInnerLoop
    move d7,d5
    bra.b .wrtAnimListWordLoop
.wrtAnimListWord
    move.w (a4)+,(a0)+
.wrtAnimListWordLoop
    dbra d5,.wrtAnimListWord

    cmp.l d6,a4
    blt writeAnimListInnerLoop
writeAnimListLoop
    dbra d1,writeAnimList


xmlMainMap
    move.l #mapDefsFile,d1        ; Load tilemap data
    move.l diskBuffer+4(pc),d2
   	move.l	diskBufferSize(pc),d3
    jsr loadFile
    beq errorDisk


    move.l diskBuffer+4(pc),a0            ; width of tilemap
    lea $60(a0),a0
    SEARCHXML4VALUE (a0),"dth="
    tst d4
    bmi errorXML

    asciiToNumber (a0),d5
    move d5,tileMapWidth


    SEARCHXML4VALUE (a0),"ght="     ; height of tilemap
    tst d4
    bmi errorXML
    asciiToNumber (a0),d5

    move d5,tilemapHeight
    mulu tileMapWidth,d5
    ;asl #1,d5
    move d5,tilemapConvertedSize
    move.l a0,diskBuffer

    tst.l tilemapConverted(pc)
    beq.b .freeMemory
    move.l tilemapConverted(pc),a1
    CALLDOS FreeVec
.freeMemory
    clr.l d0
   	move   tilemapConvertedSize(pc),d0
	move.l	#chip!Mem_Clear,d1
	ALLOCMEMORY
	IFEQ AROS
	beq errorMemory
	ENDIF
	lea tilemapConverted(pc),a0
	move.l	d0,(a0)

    ;MARK: XML-Decoder – Tiled-Maps



    move.l diskBuffer(pc),a0
 	move.l tilemapConverted(pc),a1      ; find tiles
    moveq #0,d7
    move tileMapWidth,d6
    moveq #0,d3
    lea $100(a0),a0
searchXML
	IFNE XMLDataPacked
	lea 7(a0),a0
    SEARCHXML4VALUE (a0),"<t="""
    ELSE
	lea 11(a0),a0
    SEARCHXML4VALUE (a0),"gid="
    ENDIF
    tst d4
    bmi.b xmlAttackWaves          ;   no error check because built-in failsafe-routine in this case marks end of map data
    asciiToNumber (a0),d5
    subq #1,d5
;    tst.b d5
    cmpi #tileSourceMaxTile,d5
    blt.b .tileNotMirrored
    eori.b #$70,d5
    or.b #$80,d5
.tileNotMirrored
    move d7,d4
    move.b d5,(a1,d4.w*8)
    addq #1,d3
    addq #1,d7
    cmp d6,d7
    blt searchXML
    lea 1(a1),a1
    clr.l d7
    bra.w searchXML
xmlAttackWaves
    SEARCHXML4VALUE (a0),"star"     ; read startposition
    tst d4
    bmi errorXML
    SEARCHXML4VALUE (a0),""" x="
    tst d4
    bmi errorXML
    asciiToNumber (a0),d7
    lea scr2StartPos(pc),a3
    move d7,(a3)



    ;MARK: XML-Decoder – Tiled-launchTable
    ; attribs:
    ;   x, y, copy, hitpoints, gap, impact, link, opaque

    move.l launchTable(pc),a1
findObject
    SEARCHXML4VALUE (a0),"id="""                 ; find anim in XML-List
    tst d4
    bmi foundAllObjects
    SEARCHXML4VALUE (a0),"me="""
    movem.l (a0)+,d4/d5
    move.l tempMemoryPointersXML+4,a3
    move animDefsAmount,d1
    bra.b findObjectAnimLoop
findObjectAnim
    move.l (a3)+,a4
    movem.l (a4),d2/d3
    cmp.l d2,d4
    bne.b findObjectAnimLoop
    cmp.l d3,d5
    bne.b findObjectAnimLoop
    bra.b foundObjectAnim
findObjectAnimLoop
    dbra d1,findObjectAnim
	suba.w #40,a0	; find name of missing anim
    SEARCHXML4VALUE (a0),"id="""
	adda.w #11,a0
    bra errorXMLName
foundObjectAnim
    SEARCHXML4VALUE (a0),""" x="                ; x-launchposition
    asciiToNumber (a0),d3
    SEARCHXML4VALUE (a0),""" y="                ; y-launchposition
    move.l a0,a5
    asciiToNumber (a0),d7
    cmpi.b #"-",1(a5)
    bne.b .negYlaunch
    neg d7
.negYLaunch
    move 10(a4),d2
    movem.w d2/d3/d7,(a1)
    moveq #24,d3
    add.l d3,a0

   	moveq #$01,d3
   	ror.l #8,d3	;move.l #$01000000,d3
    clr.l d7
    SEARCHXML4VALUEShort (a0),"copy"


     tst d4
    bmi .noCopy
    SEARCHXML4VALUEShort (a0),"ue="""               ; find copy value
    asciiToNumber (a0),d3
    tst d3
    bne.b .alterObjectValue
    clr.l d3	; d3 contains no of object in highest 8 bits
    moveq #$28,d6
    add.l d6,a0
    bra .noCopy
                                        ; decoding copied objects only!
.alterObjectValue
	addq #1,d3
	bset #7,d3; d3 = no of copied objects
    asl #8,d3
    swap d3
    SEARCHXML4VALUEShort (a0),"gap"""               ; gap value
    SEARCHXML4VALUEShort (a0),"ue="""
    asciiToNumber (a0),d7
    swap d7
    or.l d7,d3
    SEARCHXML4VALUEShort (a0),"hit"""               ; hitPoints value
    SEARCHXML4VALUEShort (a0),"ue="""
    asciiToNumber (a0),d6
	tst.w d6
	bpl.b .basicHitBehave
    move.w #attrIsNotHitable<<8,d6
.basicHitBehave

    move.l a0,a4
    SEARCHXML4VALUEShort (a4),"impa"     ; impact-flag set? object will not move on impact of shot
    tst d4
    bmi.b .noImpactAttrib
    SEARCHXML4VALUEShort (a4),"ue="""
    bset #11,d6
    move.l a4,a0
.noImpactAttrib

    move.l a0,a4
    SEARCHXML4VALUEShort (a4),"link"     ; link-flag set? is group, share hitcount, destroy all members of group
    tst d4
    bmi.b .noChainAttrib
    SEARCHXML4VALUEShort (a4),"ue="""
    bset #10,d6
    move.l a4,a0
.noChainAttrib

	move.l a0,a4
	SEARCHXML4VALUEShort (a4),"opaq"     ; opaque-flag set? forgo merging bob with background
	tst d4
	bmi.b .noOpaqueAttrib
	SEARCHXML4VALUEShort (a4),"ue="""
	bset #14,d6
	move.l a4,a0
.noOpaqueAttrib

	move.l a0,a4
	SEARCHXML4VALUEShort (a4),"refr"     ; opaque-flag set? forgo merging bob with background
	tst d4
	bmi.b .noRefreshAttrib
	SEARCHXML4VALUEShort (a4),"ue="""
	bset #8,d6
	move.l a4,a0
.noRefreshAttrib


    SEARCHXML4VALUEShort (a0),"xAdd"              ; xAdd value
    SEARCHXML4VALUEShort (a0),"ue="""
    asciiToNumber (a0),d7
    tst d7
    ;beq.b .keepXPosition
	seq d7
	lsr.b #7,d7
	ext.w d7
	ext.l d7
	ror.w #1,d7

;    moveq #0,d7
 ;   bra.b .keepXPositionSkip
;.keepXPosition
;	moveq #1,d7
;	ror.w #1,d7	;$8000
;.keepXPositionSkip
    or d6,d7
    swap d7
    SEARCHXML4VALUEShort (a0),"yAdd"                 ; yAdd value
    SEARCHXML4VALUEShort (a0),"ue="""
    move.l a0,a4
    asciiToNumber (a0),d4
    cmpi.b #"-",(a4)
    bne.b .negYAcc
    neg.b d4
.negYAcc
    or.b d4,d3
    bra .writeLaunchEntry
.noCopy
	;addq #1,d3
    SEARCHXML4VALUEShort (a0),"hit"""               ; hitPoints value
    SEARCHXML4VALUEShort (a0),"ue="""
    asciiToNumber (a0),d6
	tst.w d6
	bpl.b .noCopyBasicHitBehave
    move.w #attrIsNotHitable<<8,d6
.noCopyBasicHitBehave

    move.l a0,a4
    SEARCHXML4VALUEShort (a4),"impa"     ; impact-flag set? object will not move on impact of shot
    tst d4
    bmi.b .noCopyImpactAttrib
    SEARCHXML4VALUEShort (a4),"ue="""
    bset #11,d6
    move.l a4,a0
.noCopyImpactAttrib

    move.l a0,a4
    SEARCHXML4VALUEShort (a4),"opaq"     ; opaque-flag set? forgo merging bob with background
    tst d4
    bmi.b .noCopyOpaqueAttrib
    SEARCHXML4VALUEShort (a4),"ue="""
    bset #14,d6
    move.l a4,a0
.noCopyOpaqueAttrib

	move.l a0,a4
	SEARCHXML4VALUEShort (a4),"refr"     ; opaque-flag set? forgo merging bob with background
	tst d4
	bmi.b .noCopyRefreshAttrib
	SEARCHXML4VALUEShort (a4),"ue="""
	bset #8,d6
	move.l a4,a0
.noCopyRefreshAttrib

	move.l a0,a4
	SEARCHXML4VALUEShort (a4),"rstr"     ; refresh-flag? no refresh of background
	tst d4
	bmi.b .noBckRefresh


	SEARCHXML4VALUEShort (a4),"ue="""
	;move #$ff00,d6
	move.l a4,a0
.noBckRefresh


;    add.l #$28,a0
    or d6,d7
    swap d7
.writeLaunchEntry

    movem.l d3/d7,6(a1)
    add.l launchTableEntryLength(pc),a1
    bra findObject
foundAllObjects

	moveq #-1,d0
    move.l d0,(a1)
;TODO: Mark EOF of launchTable with dynamic pointer <-> static FFFFFFF
    sub.l launchTable(pc),a1
    move.l launchTableEntryLength(pc),d2
    move.l a1,d1
    divu d2,d1
    move.l d1,launchTableNoOfEntrys

	lea diskBuffer(pc),a0
	move.l 4(a0),(a0)	; restore original diskBuffer pointer

    move.l launchTable(pc),a0	 ; address of array
 	move.l launchTableBufferSize(pc),d0 	; memsize of arrayitems in bytes
    move.l launchTableNoOfEntrys(pc),d0     ;number of items
    subq.l #1,d0
    move.l launchTableEntryLength(pc),d7
.sortLoop2
    move.l a0,a2
 	move.l a0,a1
 	add.l d7,a2
 	move.w d0,d1
 	subi.w #1,d1
.sortLoop1
    move launchTableX(a1),d2
    add.l d7,a1
    move launchTableX(a2),d3
    add.l d7,a2
    cmp d2,d3
 	bge.b .skip
    move.l a1,a3
    move.l a1,a4
    sub.l d7,a4
    move.l a1,a5
    move.l tempBufferAnimPointers(pc),a6 ; use as buffer for sorting
    move.l launchTableEntryLength(pc),d6
    subq #1,d6
.saveEntry
    move.b (a3)+,(a6)+  ; write to buffer
    dbra d6,.saveEntry
    move.l a4,a3
    move.l launchTableEntryLength,d6
    subq #1,d6
.swapEntry
    move.b (a3)+,(a5)+
    dbra d6,.swapEntry
    move.l tempBufferAnimPointers,a6
    move.l launchTableEntryLength,d6
    subq #1,d6
.writeEntry
    move.b (a6)+,(a4)+
    dbra d6,.writeEntry
.skip
    dbra d1,.sortLoop1
 	subi.w #1,d0
 	bgt.b .sortLoop2


    ;!!!: Load and prepare Tiles


    move.l tempBuffer(pc),a0            ; temp multiplication table for tile arrangement
    move.l diskBuffer(pc),d0
    moveq #tilesHeight/tileHeight,d7
    bra.b .gfxTileGridOffsetLoop
.gfxTileGridOffset
    moveq #(tilesWidth/4)-1,d6
    move.l d0,d1
.gfxTileGridOffset1
    move.l d1,(a0)+
    add.l #tileWidth/8,d1
    dbra d6,.gfxTileGridOffset1
    add.l #tileHeight*tilesWidth*mainPlaneDepth,d0
.gfxTileGridOffsetLoop
    dbra d7,.gfxTileGridOffset

	IF 0=1	; old code to save loading time
    move.l #tilePixelData,d1        ; load and prepare tile pixel data. Levels 0/1, 2/3 share pixel data
	move.l diskBuffer(pc),d2
	move.l	diskBufferSize(pc),d3
	bsr GetFileInfo

	move.l fib_tilePixelFingerprint(pc),d7
	move.l fib_timestamp+8(pc),d6
	beq.b .justLoad
	cmp.l d6,d7
	beq.b .keepTilePixels	; only load if new pixel data file
	ENDIF

.justLoad
    move.l #tilePixelData,d1        ; load  pixel data
    move.l diskBuffer(pc),d2
   	move.l	diskBufferSize(pc),d3
    jsr loadFile
    beq errorDisk
 ;   move.l fib_timestamp+8,fib_tilePixelFingerprint

                                    ; rearrange tiles for fast copy code in screenmanager

    move.w #(tilesWidth/(tileWidth/8))*(tilesHeight/tileHeight),d7
    clr.l d2
    clr.l d3
    moveq #tilesWidth,d2; modulus source
    move.l tempBuffer(pc),a0
    move.l tileSource(pc),a3
    bra.b .converTilesLoop
.convertTiles
    move.l (a0)+,a2
    moveq #tileHeight-1,d6
.writeTileLine
    move.l (a2),(a3)+
    add.l d2,a2
    move.l (a2),(a3)+
    add.l d2,a2
    move.l (a2),(a3)+
    add.l d2,a2
    move.l (a2),(a3)+
    add.l d2,a2
    dbra d6,.writeTileLine
.converTilesLoop
    dbra d7,.convertTiles


.keepTilePixels
	IFNE SHELLHANDLING
	bsr shellMemoryAvail
	ENDIF

	move.l	Execbase,a6
    move.l	tempBuffer(pc),a1                    ; mem buffer only needed for decoding TMX and Plist XML-data, can be freed
    CALLDOS FreeVec
    move.l	tempMemoryPointersXML+4(pc),a1          ; same here
    CALLDOS FreeVec
    move.l	tempStoreXML(pc),a1                     ; and here
    CALLDOS FreeVec
    move.l  tempBufferAnimPointers(pc),a1           ; and here
    CALLDOS FreeVec

                                    ;   ************************
                                    ;    ***** XML-decoding ends
                                    ;   ************************

; #MARK: XML DECODING ENDS
    rts

_Exit:

    move.l Execbase,a6
    move.l mainPlanes+12(pc),a1
    tst.l a1
    beq.b .skipThis1
	jsr	_LVOFreeVec(a6)
.skipThis1
    move.l	tileSource(pc),a1
    tst.l a1
    beq.b .skipThis7
	jsr	_LVOFreeVec(a6)
.skipThis7
    move.l	tilemapBckConverted(pc),a1
	tst.l a1
    beq.b .skipThis8
	jsr	_LVOFreeVec(a6)
.skipThis8
    move.l	bobSource(pc),a1
	tst.l a1
    beq.b .skipThis9
	jsr	_LVOFreeVec(a6)
.skipThis9
    move.l	escalationBitmap(pc),a1
	tst.l a1
    beq.b .skipThis12
	jsr	_LVOFreeVec(a6)
.skipThis12
    move.l	objectList(pc),a1
	tst.l a1
    beq.b .skipThis22
	jsr	_LVOFreeVec(a6)
.skipThis22
    move.l	tilemapConverted(pc),a1
	tst.l a1
    beq.b .skipThis26
	jsr	_LVOFreeVec(a6)
.skipThis26
   	move.l	bobDrawList+8(pc),a1
	tst.l a1
    beq.b .skipThis28
	jsr	_LVOFreeVec(a6)
.skipThis28
   	move.l	bobRestoreList+8(pc),a1
	tst.l a1
    beq.b .skipThis29
	jsr	_LVOFreeVec(a6)
.skipThis29
   	move.l	spriteDMAMem+8(pc),a1
	tst.l a1
    beq.b .skipThis30
	jsr	_LVOFreeVec(a6)
.skipThis30
   	move.l	spriteDMAMem+12(pc),a1
	tst.l a1
    beq.b .skipThis32
	jsr	_LVOFreeVec(a6)
.skipThis32
   	move.l	spritePosMem(pc),a1
	tst.l a1
    beq.b .skipThis34
	jsr	_LVOFreeVec(a6)
.skipThis34
   	move.l	copperGame(pc),a1
	tst.l a1
    beq.b .skipThis35
	jsr	_LVOFreeVec(a6)
.skipThis35
   	move.l	copLineList(pc),a1
	tst.l a1
    beq.b .skipThis36
	jsr	_LVOFreeVec(a6)
.skipThis36
   	move.l copLinePrecalc(pc),a1
	tst.l a1
    beq.b .skipThis37
	jsr	_LVOFreeVec(a6)
.skipThis37
   	move.l	launchTableBuffer+4(pc),a1
	tst.l a1
    beq.b .skipThis42
	jsr	_LVOFreeVec(a6)
.skipThis42
   	move.l	launchTable(pc),a1
	tst.l a1
    beq.b .skipThis43
	jsr	_LVOFreeVec(a6)
.skipThis43
   	move.l	objectDefs(pc),a1
	tst.l a1
    beq.b .skipThis47
	jsr	_LVOFreeVec(a6)
.skipThis47
   	move.l	animDefs(pc),a1
	tst.l a1
    beq.b .skipThis49
	jsr	_LVOFreeVec(a6)
.skipThis49
   	move.l	animTable(pc),a1
	tst.l a1
    beq.b .skipThis50
	jsr	_LVOFreeVec(a6)
.skipThis50
   	move.l	collidingList+8(pc),a1
	tst.l a1
    beq.b .skipThis51
	jsr	_LVOFreeVec(a6)
.skipThis51
   	move.l	spriteScoreBuffer+4,a1
	tst.l a1
    beq.b .skipThis52
	jsr	_LVOFreeVec(a6)
.skipThis52
   	move.l	spriteParallaxBuffer+4(pc),a1
	tst.l a1
    beq.b .skipThis53
	jsr	_LVOFreeVec(a6)
.skipThis53
   	move.l	spriteParMultiTable(pc),a1
	tst.l a1
    beq.b .skipThis54
	jsr	_LVOFreeVec(a6)
.skipThis54
   	move.l	colorFadeTable(pc),a1
	tst.l a1
    beq.b .skipThis60
	jsr	_LVOFreeVec(a6)
.skipThis60
   	move.l	audioWavTable(pc),a1
	tst.l a1
    beq.b .skipThis62
	jsr	_LVOFreeVec(a6)
.skipThis62


    tst.b AudioIsInitiated(pc)
    beq .noAudioEver
    lea CUSTOM,a6
    lea	mt_chan1,a4
	move.b	#0,mt_Enable-mt_chan1(a4)   ;disable music playing
    jsr  mt_end             ; stop player
    jsr mt_remove_cia       ; stop CIA-Interrupt
    clr.b AudioIsInitiated
.noAudioEver

	lea forceQuitFlag(pc),a0
    sf.b (a0)

    IFNE SHELLHANDLING
    jsr shellQuit
	ENDIF

	moveq   #-1,d0	; instr cache bit
	moveq   #-1,d1	; affect all bits
	CALLDOS CacheControl	; disable all cache but instr cache

	clr.l d0
	rts


    ; #MARK: - SUBROUTINES BEGINS

resetScores
	lea score(pc),a0
	move.w #1,scoreAdder-score(a0)	; some score preps
	move.l #$99999999,(a0)
    clr.w scoreHighDelta-score(a0)
    clr.w scoreHighSuccessFlag-score(a0)
	rts

spriteScroller		; d7 = scrolling value
	move d7,d5
	lsl #1,d7
	add d5,d7

    lea copSprite67,a4
    ;lsr #4,d7
    move.w d7,d6
    lsl.b #2,d6
    andi.b #%1100,d6
    lsr.b #3,d7
    addx.b d6,d6		; sprite parallax one pixel scroll

	eori.b #%00011011,d6	; ; sprite parallax  subpixel scroll
    andi.w #$1f,d7
	move.l ([(spriteParMultiTable).w,pc],d7*4),d0
	move.l d0,a1
	move d0,6+8(a4)
	swap d0
	move d0,2+8(a4)         ; write sprite pointer

	move.b d6,9(a1)         ; write sprite ctrl byte, pixelvalues
	lea	copSpriteScroll(pc),a6	; pointer to SPR6CTL in coplist

	movem.l (a6),a5/a6
	or.w #$35<<8+%110,d6
	andi #%11001,d6
	move.w d6,2(a6)
	;move.w d6,2(a5)
	rts

;!!!: Do also clr ply sprite, use this code in intro
blankSprite
	lea CUSTOM,a6
	move.w #DMAF_BPLEN!DMAF_SPRITE,DMACON(a6); sprites and bpl dma off
	WAITVBLANK

	moveq #7,d0
.wrtSprt
	clr.w SPR0POS(a6)	; reset sprite positions to disable dma draw bug
	add.w #8,a6
	dbra d0,.wrtSprt
	rts

; MARK: SET gameStatus GAME / TITLE
setgameStatus
	lea gameStatus(pc),a0
    IFNE Release        ; go to title only if releaseversion

    move.b #statusIntro,(a0)       ;  $8000 indicates first call to mainFade-routine
;FIXME: Reset to statusIntro
    ELSE
    	IF INITWITH<20
		move.b #statusLevel0+INITWITH,(a0)


	move.l #.levelGetter,d1        ; load level specified in file
	move.l a0,d2
	moveq #1,d3
	jsr loadFile
	lea gameStatus(pc),a0
	sub.b #"0"-2,(a0)
	bra.b .1
.levelGetter
    filenamePrefix
    dc.b "levDefs/levelGetter.s",0
    even
.1
		ELSE
			IF INITWITH=20
			move.b #statusIntro,(a0)
			ENDIF
			IF INITWITH=30
			move.b #statusTitle,(a0)
			ENDIF
		ENDIF
    ENDIF

	st.b 1(a0)	; loadedLevelStatus. which level in memory? None yet!
	rts

installAudioDriver
	tst.b AudioIsInitiated(pc)
	bne.b .isInited
    move.l VBRptr(pc),a0
    lea CUSTOM,a6
    move.b #1,d0
    jsr mt_install_cia
	lea AudioIsInitiated(pc),a0
	st.b (a0)
.isInited
	rts
initAudioTrack
    lea CUSTOM,a6
    sub.l a1,a1	; get samples from mod-file
    clr.l d0
    jsr mt_init;(a6=CUSTOM, a0=TrackerModule, a1=Samples, d0=StartPos.b)
	lea	mt_chan1,a4
	move.b	#1,mt_Enable-mt_chan1(a4)
	rts

    ; subroutine for precalc of 16 color fades and converting to Amiga AGA-Table. Result: 2 x .w lo/hi-palette per color
shotColorFader:
precalcColorFade
    moveq #shotColIterations-1,d6

.1
    move.l a1,a3
    move.l a2,a4
    ;lea \1,a1
    ;lea \2,a2
	move.w	#3,d7
	moveq	#0,d3
    move.l d6,d4
    asl.w #4,d4
    divu #shotColIterations,d4

    ;integer( A1+ i/A * (A2-A1) )
.2
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a3)+,d0	; d0 = color0
	move.b	(a4)+,d1	; d1 = color1

	move.w	d1,d2
	sub.w	d0,d2		; d2 = c1-c0
	muls.w	d4,d2		; d2 = (c1-c0)*alpha
	asr.w	#4,d2		; d2 = ((c1-c0)*alpha)>>8

	addx.w	d3,d2
	add.w	d2,d0		; d0 = c0 + ((c1-c0)*alpha))>>8
	move.b	d0,(a0)+
	dbf	d7,.2
    dbf d6,.1

    moveq #shotColIterations-1,d7
.3
    move.l -(a0),d0
    move.l d0,d1
    swap d1
    move d1,d2
    lsl.w #8,d1
    lsl.w #4,d2
    andi #$f00,d1  ; lobyte    r
    andi #$f00,d2 ; hibyte    r

    move.w d0,d3
    asr #4,d3
    move d3,d4
    lsr #4,d4
    andi #$f0,d3  ; lobyte    g
    andi #$f0,d4 ; hibyte    g

    move.w d0,d5
    move d5,d6
    lsr #4,d6
    andi #$f,d5  ; lobyte    b
    andi #$f,d6 ; hibyte    b
    or d1,d5
    or d3,d5    ; lobyte rgb
    or d2,d6
    or d4,d6    ; hibyte rgb
    move.w d5,(a0)
    move.w d6,2(a0)
    dbra d7,.3
    rts


keyboardHandler:

    clr.l d7            ; get keyboard char. keyCode will be updated only when keypress changes
   	move.b $bfec01,d7
    not.b d7
    ror.b #1,d7
    tst.b d7
    bmi.b .noKeyPress    ; no key pressed
    tst.b keycode(pc)
    bmi.b .keyProcessed    ; not.b keyCode after key has been processed whereever applicable
    cmp.b keycode(pc),d7
    beq.b .keyProcessed   ; key has not yet been processed
    move.b d7,keyCode
    bra.b .keyProcessed
.noKeyPress
    clr.b keyCode
.keyProcessed
    rts

    IF AUDIO=1
rythmSynchronizer:
	move.b AudioRythmFlagBullets,d7

    moveq #1,d7
    sub.b d7,AudioRythmFlagBullets
    bpl.b .1
    moveq #(8<<2)-1,d0
    move.b d0,AudioRythmFlagBullets
.1
rythmSyncAnim
    tst.b AudioRythmFlagAnim(pc)
    beq.b .2
    sub.b d7,AudioRythmFlagAnim ; flag reset in audio.s
.2  move.b AudioRythmFlagAnim,d7
    move.b AudioRythmTable(pc,d7),AudioRythmAnimOffset
    rts
AudioRythmTable
    dc.b 31,31,31,31,31,30,30,30
    dc.b 30,29,29,29,28,28,28,27
    dc.b 27,27,26,26,26,25,25,25
    dc.b 25,24,24,24,24,23,23,23
    dc.b 23,22,22,22,21,21,20,20
    dc.b 19,19,18,18,17,17,16,16
    dc.b 15,15,14,14,13,13,12,12
    dc.b 11,11,10,10,9,9,8,8
    dc.b 7,6,5,4,3,2,1,0
    blk.b 10,0
    ENDIF
    ; MARK: SUBROUTINES ENDS

; #MARK: - MAIN MANAGER
; change gameStatus at line 587 if needed
_Main

    tst errorFlag
    bne .quitMain
.mainLoop
    move.b gameStatus(pc),d0
    andi.w #$f,d0
    addq.b #1,gameStatus
	move.w (.jmpTable-*,pc,d0.w*2),d0
	jsr (pc,d0.w)
    tst.b forceQuitFlag(pc)
    beq.b .mainLoop
.quitMain
	rts
.jmpTable
    dc.w mainIntro-.jmpTable+4,mainTitle-.jmpTable+4
    blk.w 8,initGame-.jmpTable+4
    dc.w mainReset-.jmpTable+4
statusIntro=0
statusTitle=1
statusLevel0=2
statusLevel1=3
statusLevel2=4
statusLevel3=5
statusLevel4=6
statusLevel5=7
statusLevel6=8
statusLevel7=9
statusFinished=10

mainGameOver
	rts
mainInit
    rts
mainReset
    move.b #statusTitle,gameStatus
    rts



mainIntro:

    ; display artwork picture, then free memory and add some preparations
    bsr blankSprite
	bsr.w prepareDisplay

; intro picture preps
	lea introLogo(pc),a0
	move.l a0,d1	        ; load spieleschreiber logo
	move.l spriteDMAMem(pc),d2
	move.l	#artworkPictureSize,d3
	jsr loadFile
	beq errorDisk

	lea introPicture(pc),a0
	move.l a0,d1	; load and prepare artwork
	move.l artworkBitplane(pc),d2
	move.l	#artworkPictureSize,d3
	jsr loadFile
	beq errorDisk

	lea ham8palette(pc),a0
	move.l a0,d1	; load and prepare palette
	move.l artworkPalette(pc),d2
	move.w #63*4,d3
	lsl #2,d3;=artworkPaletteSize
	jsr loadFile
	beq errorDisk

    lea copBPLPT,a5             ; write artwork bitplaneadress to coplist
	move.l artworkBitplane(pc),d1
	move.l #(artworkPictureSize/8),d2
	moveq #7,d6
.prepBitplaneAdress
        move d1,6(a5)
        swap d1
        move d1,2(a5)
        swap d1
        add.l d2,d1
        lea 8(a5),a5
        dbra d6,.prepBitplaneAdress

	SAFECOPPER
	move.l artworkPalette(pc),a0   ;set artwork colors -> colRegs 0ff
	clr.l d3
	move.w #63,d7
.colArtwork
	addq #1,a0
	move.b (a0)+,d0
	move.b (a0)+,d1
	move.b (a0)+,d2
	WRITECOLOR
	addq #1,d3
	dbra d7,.colArtwork
	RESTORECOPPER

    WAITVBLANK

	lea scrMngOffset(pc),a0
	move.w #screenManagerLv0-jmpSrcMngOffset,(a0)

	lea $dff000,a6
    move #$38,DDFSTRT(a6)
    move #$d0,DDFSTOP(a6)
	move #0,BPL1MOD(a6)
	move #0,BPL2MOD(a6)
	;clr.w copBPL2ModOffset+2
	move.w #$2c56,COPDIWSTRT+2		; window
	move.w #$2100,COPDIWHIGH+2
	move.w #$18c0,DIWSTOP(a6)
	move #ECSENAF!HAMF!BPU3F!HIRESF,copBPLCON0+2
    clr.w copBPLCON1+2

	WAITVBLANK
	lea CUSTOM,a6
	;move.w #DMAF_SETCLR!DMAF_BPLEN,DMACON(a6); bpl dma -> on
	;move.w #DMAF_SPRITE,DMACON(a6); sprites off

	move.l spriteDMAMem(pc),a5	; init sprite-DMA / spieleschreiber logo
	move.l #$9454bb00,d5
	bsr titleShowSprites

	WAITSECS 1

	move.w #DMAF_SETCLR!DMAF_SPRITE,DMACON(a6); show spieleschreiber logo

	WAITSECS 5

	move.w #DMAF_SPRITE,DMACON(a6); kill logo

	lea titleSprites,a5	; init sprite-DMA / title logo
	move.l #$44546b00,d5
	bsr titleShowSprites

	WAITSECS 3

	move.w #DMAF_SETCLR!DMAF_BPLEN,DMACON(a6); show picture

	WAITSECS 3

	move.w #DMAF_SETCLR!DMAF_SPRITE,DMACON(a6); show game logo

	; init music
	lea AudioSoundStatus(pc),a0
	move.b #3,(a0)	; set music and fx on
	bsr installAudioDriver
	lea modTitle,a0
	bsr initAudioTrack

	move #musicFullVolume,d0
	jsr mt_ForceMastervol

	WAITSECS 11


	move.w #DMAF_BPLEN,DMACON(a6); bpl dma -> off
	;move.w #$32b4,COPDIWSTRT+2
	;move.w #$3920,COPDIWHIGH+2	; set transition

	;WAITVBLANK
	WAITSECS 3	; black frame; should be 3

	move.w #BANK0F!BANK1F!BANK2F!BRDSPRTF!SPRES1F,copTitleBlank+2

	lea transitionFlag(pc),a1
	move #transitionIn,(a1)	; init fadein

    lea introLaunched(pc),a0
	sf.b (a0)	; keep music playing in title
	rts

titleShowSprites
    move #$00ff,copBPLCON4+2 ;Get SprColors from colorRegs 240ff

    SAFECOPPER

	lea titleSpritesPalette,a0   ;set sprites colors -> colRegs 240ff
    addq #4,a0
    move #240,d4
	moveq #2,d7
.colSprRead
    addq #1,a0
    addq #1,d4
    move.b (a0)+,d0
    move.b (a0)+,d1
    move.b (a0)+,d2
    move d4,d3
    WRITECOLOR
    move d4,d3
    addq #4,d3
    WRITECOLOR
    move d4,d3
    addq #8,d3
    WRITECOLOR
    move d4,d3
    add #12,d3
    WRITECOLOR
    dbra d7,.colSprRead

    RESTORECOPPER

    move.l a5,d0
    clr.l d7
    moveq #$29,d7
    lsl #4,d7	: titleSpritesOffset
    lea copSprite01,a0
    move d0,6(a0)
    swap d0
    move d0,2(a0)
    swap d0
    add.l d7,d0
    move d0,14(a0)
    swap d0
    move d0,10(a0)
    swap d0
    add.l d7,d0
	IF 1=1
    lea copSpriteDMA,a1
    clr.w d3
    move.w #copSpriteDMAOffset,d3
    moveq #7,d1
.wrtFourLists
	move.l d0,d4
    moveq #3,d2
    move.l a1,a0
.spriteDMAInit
    move d4,6(a0)
    swap d4
    move d4,2(a0)
    swap d4
    lea 8(a0),a0
    add.l d7,d4
    dbra d2,.spriteDMAInit
    adda.w d3,a1
    dbra d1,.wrtFourLists
	ENDIF

    lea copSprite67,a1
    move d4,14(a1)
    swap d4
    move d4,10(a1)
    swap d4
    add.l d7,d4
    move d4,6(a1)
    swap d4
    move d4,2(a1)
titlePosSprites
	move.l d5,d3
	move.l a5,a0
    ;lea titleSprites,a0     ; show title sprites
    moveq #7,d0

	move.w d5,d6
	swap d5
    move.w #titleSpritesOffset,d7
.wrtSprites
    move d5,(a0)
    move d6,8(a0)
    add #$10,d5
    adda d7,a0
    dbra d0,.wrtSprites
    move.l d3,d5
    rts
titleHideSprites
	lea SPR0PTH,a1
	moveq #7,d7
.wrtPt
	move.l d0,(a1)+
	dbra d7,.wrtPt
	rts
    lea titleSprites,a0
    moveq #7,d0
    move #$3000,d1
    move #$3200,d2
.hideSprites
    move d1,(a0)
    move d2,8(a0)
    add.l #titleSpritesOffset,a0
    dbra d0,.hideSprites
    rts
.sprZero
	dc.l	$3000,0
	dc.l 	0,0
	dc.l	$3200,0
	dc.l 	0,0
prepareDisplay:
    lea CUSTOM,a6
    move #$34,DDFSTRT(a6)
    move #$b6,DDFSTOP(a6)
    move #displayWindowStart<<8+$98,DIWSTRT(a6)
    move #displayWindowStop<<8+$b8,DIWSTOP(a6)    ;Displaywindow, Datafetch
    move #mainPlaneWidth*(mainPlaneDepth-1)+mainplaneCache,copBPL1MOD+2  ; basic modulus


    move #bckplaneWidth-mainplaneView,copBPL2MOD+2        ;bitplane modulos
    clr.w CLXCON2(a6)              ;Bitplanes 7 & 8-> no sprites collision
quitPrepareDisplay
    rts

;	#MARK: - COLOR MANAGER
colorPlayer

; #MARK: Set ship and shot colors (a0 = player pal, a1 = shot pal)
	;set sprite ship colors -> colRegs 224ff
    move.l #$e*16,d4		;224 > 240
	moveq #15,d7
.colShipSprRead
    lea 1(a0),a0
	move.w d4,d3
    move.b (a0)+,d0
    move.b (a0)+,d1
    move.b (a0)+,d2
    WRITECOLOR
	lsr #1,d1
    lsr #1,d2
	add d1,d0
	add d2,d0
    lsr #1,d0
	clr d1
	clr d2
	sub #32,d3
	WRITECOLOR
    addq #1,d4
    dbra d7,.colShipSprRead


	lea 4(a1),a1
	moveq #$c,d4
	lsl.b #4,d4			; $c0 -> color regs 192
    moveq #0,d3
	moveq #2,d7
.colSprRead
	clr.l d0
	lea 1(a1),a1
    move.b (a1)+,d0
    move.b (a1)+,d1
    move.b (a1)+,d2
    move d4,d3
    add #32+5,d3	; 224+5 = bank 7, +$a
    WRITECOLOR ; set sprite 3	; plyship too!
    move d4,d3
    add #32+9,d3	; 224+9 = bank 7, +$12
    WRITECOLOR ; set sprite 5
    move d4,d3
    add #48+5,d3	; 240+5 = bank 7, +$2a
    WRITECOLOR ; set sprite 2
    move d4,d3
    add #48+9,d3		; 240+9 = bank 7, +$32
    WRITECOLOR ; set sprite 4

    lsr #1,d1	; set red tone / escalation
    lsr #2,d2
	add d1,d2
	add d2,d0
	clr d1
	clr d2
    move d4,d3
    add #5,d3
    WRITECOLOR ; set sprite 3
    move d4,d3
    add #9,d3
    WRITECOLOR ; set sprite 5
    move d4,d3
    add #16+5,d3
    WRITECOLOR ; set sprite 2
    move d4,d3
    add #16+9,d3
    WRITECOLOR ; set sprite 4
	addq #1,d4
    dbra d7,.colSprRead
	rts


colorManager
;MARK: Game MainPlane Colors
    ;SAFECOPPER

 	;move.l mainPlanePalette(pc),a0
    move.l #colorDefsFile,d1        ; Load main color data
    move.l diskBuffer+4(pc),d2
   	moveq #16*4,d3
    jsr loadFile
    beq errorDisk


    move.l diskBuffer+4(pc),a0
	moveq #15,d7		; 16 red toned game playfield colors for escalation window
	move.w #128,d3
    move.l a0,a3
.redTones
    addq.l #1,a3
	clr.l d0
    clr.l d1
    clr.l d2
    move.b (a3)+,d0
    move.b (a3)+,d1
    move.b (a3)+,d2
	divu #3,d0
	lsr #1,d1
	lsr #3,d2
	add.w d1,d2
	add.w d2,d0
	lsr #2,d1
	lsr #2,d2
	WRITECOLOR          ; red colors for main playfield
	addq #1,d3
	dbra d7,.redTones
    ;lea 0,a0
	moveq #15,d7		; 16 red toned font colors for escalation window
	move.w #128+16,d3
    move.l a0,a3
	clr.l d0
    clr.l d1
    clr.l d2
	clr.l d4
    clr.l d5
.redTonesB
    lea 1(a3),a3
	move d4,d0
	move d5,d1
	WRITECOLOR  ; red colors for escalate letter graphics
	add #16,d3
	lsr #2,d0
	lsr #2,d1
	WRITECOLOR     ; red colors for escalate letter graphics, darker version (blinking)
	sub #16,d3
	add #$21,d4
	add #$04,d5
	addq #1,d3
	dbra d7,.redTonesB

	lea gameStatusLevel(pc),a0
	move.w (a0),d0
	move.w (.jmpTable-*,pc,d0.w*2),d0

    move.l diskBuffer+4(pc),a0	; color rgbs in 24 bit format
	lea colorAlphaTable,a1
	clr.l d3
	clr.l d4
	clr.l d5
	jmp (pc,d0.w)
.jmpTable		; color jumper
	dc.w	.lv0nebula-.jmpTable+4
	dc.w	.lv1sun-.jmpTable+4
	dc.w	.lv2sky-.jmpTable+4
	dc.w	.lv3ocean-.jmpTable+4
	dc.w	.lv4city-.jmpTable+4

;	#MARK: - colors nebula
.lv0nebula
    lea lv0blueShadesInits(pc),a2
    movem.w (a2),d3-d5 ; shading-values to begin with (rgb)
	moveq #(2^bckplaneDepth)-1,d7
.colRead
    move.l a1,a2
    move.l a0,a3
	moveq #(2^mainPlaneDepth)-1,d6	; loop through all 16 colors
.colWriteFade               ; inner loop, write 16 colors with progressing hue
	;clr.w d3
    move (a2)+,a4		; which color register?

    lea 1(a3),a3
    move.b (a3)+,d0
    move.b (a3)+,d1
    move.b (a3)+,d2
    ;bra .keepB

    cmpi #(2^mainPlaneDepth)-1,d6
    bne .doColor

    cmpi #(2^bckplaneDepth)-1,d7
    beq .doColor
	;bra .keepB
    move d7,a5
    moveq #0,d7
    move.b d3,d7
    lsl.w #2,d7
    divu.w #5,d7
    add.b d7,d0
    bcc.b .keepR0
    st.b d0
.keepR0
    moveq #0,d7
    move.b d4,d7
    lsl.w #2,d7
    divu.w #5,d7
    add.b d7,d1
    bcc.b .keepG0
    st.b d1
.keepG0
    moveq #0,d7
    move.b d5,d7
    lsl.w #2,d7
	divu.w #5,d7
    add.b d7,d2
    bcc.b .keepB0
    st.b d2
.keepB0
    move a5,d7
    bra.b .keepB
.doColor
    add.b d3,d0
    bcc.b .keepR
    st.b d0
.keepR
    add.b d4,d1
    bcc.b .keepG
    st.b d1
.keepG
    add.b d5,d2
    bcc.b .keepB
    st.b d2
.keepB
    exg.l a4,d3
    ;move.l a4,d3
    WRITECOLOR
    exg.l a4,d3
;.fadeExit
    dbra d6,.colWriteFade
    lea 32(a1),a1


    add.b #$05,d3
    bcc .keepR1
    st.b d3
.keepR1
    add.b #$03,d4
    bcc.b .keepG1
    st.b d4
.keepG1
    add.b #$10,d5
    bcc.b .keepB1
    st.b d5
.keepB1
    dbra d7,.colRead
;quitColorManager
    ;RESTORECOPPER
        rts

;	#MARK: - colors space

.lv4sky
	lea lv0blueShadesInits,a2
	movem.w (a2),d0-d2 ; shading-values to begin with (rgb)
	moveq #7,d7
.wrtParCols
	move.w (a1),d3
	WRITECOLOR
	adda.w #32,a1
	add.w #12,d0
	dbra d7,.wrtParCols
.lv1skip
	lea colorAlphaTable,a6
	moveq #(2^bckplaneDepth)-1,d7
.colRead2
    ;move.l a1,a3
	move #(2^mainPlaneDepth)-2,d6	; loop through all 16 colors
	lea 4(a0),a1
	lea 2(a6),a2
.colWrite               ; inner loop, write 16 colors with progressing hue
	;clr.w d3
    move (a2)+,d3		; which color register?
    lea 1(a1),a1
    move.b (a1)+,d0
    move.b (a1)+,d1
    move.b (a1)+,d2
	WRITECOLOR
	dbra d6,.colWrite
    lea 32(a6),a6
	dbra d7,.colRead2
;quitColorManager
    ;RESTORECOPPER
        rts

;	#MARK: colors sun
.lv1sun
	lea lv1solarShades+5(pc),a2
	bra .storeColors

;	#MARK: colors sky
.lv2Sky
    lea lv2SkyShades,a2
    movem.w (a2),d3-d5 ; shading-values to begin with (rgb)
	moveq #(2^bckplaneDepth)-1,d7
.colRead3
    move.l a1,a2
    move.l a0,a3
	move #(2^mainPlaneDepth)-1,d6	; loop through all 16 colors
.colWriteFade3               ; inner loop, write 16 colors with progressing hue
	;clr.w d3
    move (a2)+,a4		; which color register?

    lea 1(a3),a3
    move.b (a3)+,d0
    move.b (a3)+,d1
    move.b (a3)+,d2
    cmpi #(2^mainPlaneDepth)-1,d6
    bne .doColor3

    cmpi #(2^bckplaneDepth)-1,d7
    beq .doColor3
	;bra .keepB
    move d7,a5
    moveq #0,d7
    move.b d3,d7
    muls #80,d7	; range, 80 means maximum from 0 to $f0 (approx.)
    lsr.w #5,d7
    sub #$70,d7
    ;clr.w d7
	add.b d7,d0
	bcc.b .keepR3
	st.b d0
.keepR3
    moveq #0,d7
    move.b d4,d7
	muls #27,d7
	lsr.w #5,d7
	add #$60,d7
    ;clr.w d7
    add.b d7,d1
	bcc.b .keepG3
    st.b d1
.keepG3
    moveq #0,d7
    move.b d5,d7
	muls #8,d7
	lsr.w #4,d7
    add #$b0,d7
    ;clr.w d7
    add.b d7,d2
    ;moveq #-1,d2
    bcc.b .keepB3
    st.b d2
.keepB3
    move a5,d7
    bra.b .keepBB3
.doColor3
    add.b d3,d0
    bcc.b .keepRR3
    st.b d0
.keepRR3
    add.b d4,d1
    bcc.b .keepGG3
    st.b d1
.keepGG3
    add.b d5,d2
    bcc.b .keepBB3
    st.b d2
.keepBB3
    exg.l a4,d3
    ;move.l a4,d3
    ;clr.w d3
    WRITECOLOR	; 8 shades of colors at 0000
    exg.l a4,d3
;.fadeExit
    dbra d6,.colWriteFade3
    lea 32(a1),a1

    add.b #$14,d3	; add red to main pal
    bcc .keepRRR3
    st.b d3
.keepRRR3
    add.b #$14,d4	; add green to main palette
    bcc.b .keepGGG3
    st.b d4
.keepGGG3
    add.b #$14,d5	;add blue to main pal
    bcc.b .keepBBB3
    st.b d5
.keepBBB3
	dbra d7,.colRead3
	rts

;	#MARK: colors ocean
.lv3ocean
	lea lv3oceanCols+5(pc),a2
	bra.b .storeColors
;	#MARK: colors city -
.lv4city
	lea lv4cityCols+5(pc),a2
.storeColors
	lea 5(a0),a0
	moveq #1,d3
	move.w #14,d7
.wrtFrntCol
	move.b (a0)+,d0
	move.b (a0)+,d1
	move.b (a0)+,d2
;	moveq #-1,d0
;	moveq #8,d1
;	moveq #0,d2
	WRITECOLOR
	addq #1,a0
	addq #1,d3
	dbra d7,.wrtFrntCol

	moveq #17,d3
	move.w #7,d7
.wrtBckCol
	move.b (a2)+,d0
	move.b (a2)+,d1
	move.b (a2)+,d2
	;moveq #-1,d0
	;moveq #-1,d1
	;moveq #-1,d2
	WRITECOLOR
	addq #1,a2
	addq #1,d3
	dbra d7,.wrtBckCol
	rts


lv0blueShadesInits
	dc.w $1<<4,$0<<4,$2<<4
lv1solarShades
	incbin incbin/secondPlaneSolar.pal
	even
lv2SkyShades
	dc.w $0<<4,$0<<4,$0<<4
lv3oceanCols
	incbin incbin/secondPlaneSea.pal
lv4CityCols
	incbin incbin/secondPlaneCity.pal

	;dbra d7,colRead
;00000000   ;180+1^2    = 0
;00000001   ;180+1^2    = 1

;00000000               =   0
;00000010               =   2
;00001000               =   8
;00001010               =   10
;00100000               =   32
;00100010               =   34
;00101000               =   40
;00101010               =   42


;00000000   ;180+3^2    =   $0
;00000001   ;180+3^2    =   $1
;00000100   ;180+3^2    =   $4
;00000101   ;180+5^2    =   $5

;00010000   ;180+5^2    =   $10
;00010001   ;180+5^2    =   $11
;00010100   ;180+5^2    =   $14
;00010101   ;180+5^2    =   $15

;01000000   ;180+5^2    =   $40
;01000001   ;180+5^2    =   $41
;01000100   ;180+5^2    =   $44
;01000101   ;180+5^2    =   $45

;01010000   ;180+5^2    =   $50
;01010001   ;180+5^2    =   $51
;01010100   ;180+5^2    =   $54
;01010101   ;180+5^2    =   $55

wrtTextOneShortPlane
	move.w #mainPlaneWidth-8,d7
	bra.b wrtTextOP
wrtTextOnePlane
	move.w #mainPlaneWidth*mainPlaneDepth,d7
	;move.w #mainPlaneWidth,d7
wrtTextOP
	move.l a3,-(sp)
	lea wrt1plane(pc),a3; jump vector
	bra wrtTextSkip
wrtTextBitmap: ;= = ., > = !, ? = - @ = empty, ; a0=textaddress, d0=x-coord, d1=y-coord, a5/a6=targetscreens (doublebuffer, base) optimised for write to 3 bitplanes
    ;uses a1,a2,a4,a5,a6,d0,d1,d2,d3,d4,d6
	move.l a3,-(sp)
	lea wrt3planes(pc),a3
wrtTextSkip
    cmp.l #0,a5
    beq .quitText
    moveq #0,d3
    moveq #0,d4
    st.b d4;=$000000ff
    and.l d4,d0
    and.l d4,d1
    divu #8,d0
    muls #mainPlaneWidth*mainPlaneDepth,d1
    andi.l #$3f,d0
    add.l d0,d1
    move.l d1,a1
    add.l a5,a1
    sf.b d4
    lea font,a4

.readChar
    move.l a1,a2
    moveq #0,d6
    move.b (a0)+,d6
    beq .quitText

    cmpi.b #" ",d6
    bne .noSpace
    move.b #"@",d6
    bra .gotChar
.noSpace
    cmpi.b #"9",d6
    bgt .noNum
    add.b #3,d6
    bra .gotChar
.noNum
    cmpi.b #".",d6
    bne .noDot
    move.b #"=",d6
.noDot
    cmpi.b #"!",d6
    bne .noExcl
    move.b #">",d6
.noExcl
.gotChar
    sub.b #51,d6
    jsr (a3)
    addq.l #1,d4
    bra .readChar
.quitText
    move.l (sp)+,a3
    rts
wrt3planes
    move d4,d3
    moveq #fontHeight-1,d2
.wrtLine
    move.b (a4,d6),d0
    ;move.b #$ff,d0
    REPT mainPlaneDepth
    move.b d0,(a2,d3)
    add.w #mainPlaneWidth,d3
    ENDR
    add #fontBitmapWidth,d6
    dbra d2,.wrtLine
	rts
wrt1plane
    move d4,d3
    moveq #fontHeight-1,d2
.wrtLine
    move.b (a4,d6),d0
    move.b d0,(a2,d3)
    add.w d7,d3
    add #fontBitmapWidth,d6
    dbra d2,.wrtLine
	rts

; #MARK: - TITLE MANAGER BEGINS


        ; MARK: - TITLESCREEN INIT
mainTitle

	lea gameInActionF(pc),a0
	sf.b (a0)      ; disable gamecode in interrupt
    move.w #ECSENAF,copBPLCON0+2
    move #%0,copBPLCON2+2   ;video priority (sprites in front)



    sf.b blitterManagerFinishedF   ; no buffer swapping
    lea plyPos(pc),a0
    sf.b plyDistortionMode(a0)      ; ensure rasterListManager runs fine
	sf.b escalateIsActive          ;   ""


	lea introLaunched(pc),a0
	tst.b (a0)
	st.b (a0)
    beq.b .introMusicPlayin      ; keep start music playing if first init of titlescreen
	bsr installAudioDriver

.AudioIRQOn
    lea modTitle,a0
    bsr initAudioTrack
	move #musicFullVolume,d0
	jsr mt_ForceMastervol
.introMusicPlayin

    clr.b fxInit

    tst.b gameStatus
    bpl .skipFirstStart             ; init fade-coplist and copFadeCnt to copy with first fade
    bclr.b #7,gameStatus      ; killbit, indicating that first launch of titlescreen has happened
.skipFirstStart

    lea mainPlanes+12(pc),a0
	move.l (a0),d0
	moveq #8,d1
	add.l d1,d0
	andi.b #$fc,d0
    move.l mainPlaneOneSize(pc),d1
    lea mainPlanesPointer(pc),a1
	move.l d0,(a1)+
	add.l d1,d0
	move.l d0,(a1)+
	add.l d1,d0
	move.l d0,(a1)+

	move.l #titleCopyRight,d0	; init copyright sprites
	lea copTitleSpr2,a1
	moveq #3,d7
	moveq #112,d1; mem size of one sprite
.wrtSpr
	move d0,6(a1)
	swap d0
	move d0,2(a1)
	swap d0
	add.l d1,d0
	adda #16,a1
	dbra d7,.wrtSpr

    bsr.w prepareDisplay

;	bsr titleDrawSound

	lea titleSprites,a5	; init sprite-DMA, hide
	move.l #$44546b00,d5
	bsr titleShowSprites

	move.b #$ca,d0	; show engage & sound icons
	bsr titlePosIcons

    lea score(pc),a0             ; new hiscore?
   ; move.l #$310315,(a0)	; fake new high score for testing

    clr.b titleHighFlag
    bsr scoreToChar
;MARK: title highscore manager
    lea score(pc),a0
 ;   move.l #$0123457,(a0)
    lea highData(pc),a1             ; new hiscore?
    move.l (a0),d1
    moveq #9,d7; no of high entrys
.compareHigh
    move.l 4(a1),d0
    cmp.l d0,d1
    bhi.b .gotHigh		; found new highscore – prepare setup
    lea 8(a1),a1
    dbra d7,.compareHigh
    bra.w highTableReady	; no new highscore - further preps

	; copy score to highscore table
.gotHigh
    moveq #10,d6
    sub.b d7,d6
    move.b d6,titleHighFlag
    lea highDataEnd(pc),a1
    lea -8(a1),a0
    tst.b d7
    beq .skipMove
    subq #1,d7
.moveHigh
    move.l -(a0),-(a1)
    move.l -(a0),-(a1)
    dbra d7,.moveHigh
.skipMove
    move.l ((score).w,pc),-(a1); copy score to hero table

.lastEntry

encodeHighscore

    lea score(pc),a0
    ;move.l #$93844381,(a0)
    lea scoreHighEncoded+3,a1
    clr.l d7
    clr.l d1
    clr.l d2
    moveq #3,d0
.encodeHigh
    move.b (a0)+,d1
    moveq #4,d5
    sub d0,d5
    move d1,d2
    andi #$0f,d1
    andi #$f0,d2
    lsr #4,d2
    eor d5,d1
    eor d5,d2
    add #"A",d1
    add #"D",d2
    move.b d1,(a1)+
    move.b d2,(a1)+
    add.b d2,d7
    dbra d0,.encodeHigh
    move.b (a0)+,d1
    add.b d1,d7
    add.b #"H",d1
    lea scoreHighEncoded,a1
    move.b d1,(a1)+
    andi #$0f,d7
    add #"F",d7
    move.b d7,(a1)+
    eori #$7,d7
    move.b d7,(a1)+

; code not needed, but tested just in case ...
    IF 0=1
decodeHighscore
    lea scoreHigh,a0
    lea scoreHighEncoded+3,a1
    clr d7
    moveq #3,d0
.decodeHigh
    move.b (a1)+,d1
    sub.b #"A",d1
    move.b (a1)+,d2
    sub.b #"D",d2
    add.b d2,d7
    moveq #4,d5
    sub d0,d5
    eori d5,d1
    eori d5,d2
    andi #$0f,d1
    lsl #4,d2
    andi #$f0,d2
    or d1,d2
    move.b d2,(a0)+
    dbra d0,.decodeHigh

    lea scoreHighEncoded(pc),a1
    move.b (a1)+,d1
    sub.b #"H",d1
    add.b d1,d7
    move.b d1,(a0)+;highscore status
    andi #$0f,d7
    add.b #"F",d7
    move.b (a1)+,d6
    cmp.b d6,d7
    bne .wrongCode
    move.b (a1)+,d6
    eori #$7,d6
    cmp.b d6,d7
    bne .wrongCode
    ;....
.wrongCode
    ENDIF

highTableReady
    ; build screen

    CLEARMEMORY mainPlanes(pc),mainPlaneOneSize(pc)                ; clear all bitplanes
    CLEARMEMORY mainPlanes+4(pc),mainPlaneOneSize(pc)
    CLEARMEMORY mainPlanes+8(pc),mainPlaneOneSize(pc)

; generate color pointers

    lea copTitle,a0
    move.l bobDrawList+8(pc),a1; use as pointer table to font colreg
    move.l a1,a2
    clr.l d0
    clr.l d1
    add.w #2,a1
.iterate
    addq.w #4,d0
    cmpi.w #COPJMP1,(a0,d0)  ; reached end of subcoplist
    beq.w .finish
    cmpi.w #COLOR15,(a0,d0)  ; find entrys with scrolling regs
    bne.b .iterate
    move d0,d2
    addq #2,d2
    move.w d2,(a1)+     ; write pointer
    addq #1,d1
    bra.b .iterate
.finish

    move.w d1,(a2)
    tst.b titleHighFlag(pc)
    beq.w titleMain			; no new highscore - go to title

	; common code only til here;

    ; new highscore - enter initials

	move.b #$ff,d0	; show engage & sound icons
	bsr titlePosIcons

    lea titleHighText(pc),a0    ; new highscore
    move #118,d0
    move.l #80,d1
    move.l mainPlanesPointer+4(pc),a5
    bsr.w wrtTextBitmap

    lea titleInitials(pc),a0    ; enter inits
    move #118,d0
    move.l #110,d1
    move.l mainPlanesPointer+4(pc),a5
    bsr.w wrtTextBitmap

    lea titleScoreText(pc),a0
    move #106,d0
    move.l #118,d1
    move.l mainPlanesPointer+4(pc),a5
    bsr.w wrtTextBitmap

globalHeroMsgY=160
    lea titleEncodedA(pc),a0    ; Qualify
    move #120,d0
    move.l #globalHeroMsgY,d1
    move.l mainPlanesPointer+4(pc),a5
    bsr.w wrtTextBitmap

    lea titleEncodedAA(pc),a0        ; global hero
    move #110,d0
    move.l #globalHeroMsgY+8,d1
    move.l mainPlanesPointer+4(pc),a5
    bsr.w wrtTextBitmap

    lea titleEncodedC(pc),a0; enter
    move #88,d0
    move.l #globalHeroMsgY+32,d1
    move.l mainPlanesPointer+4(pc),a5
    bsr.w wrtTextBitmap

    lea titleEncodedD(pc),a0; url
    move #34,d0
    move.l #globalHeroMsgY+40,d1
    move.l mainPlanesPointer+4(pc),a5
    bsr.w wrtTextBitmap

    lea scoreHighEncoded(pc),a0
    move #150,d0
    move.l #globalHeroMsgY+32,d1
    move.l mainPlanesPointer+4(pc),a5
    bsr.w wrtTextBitmap

    move.l mainPlanesPointer+4,tempVar  ; set first view


    lea highInitialsIndex(pc),a6
    clr.w (a6)

   bsr titleEnableDisplay        ; enable display

;#MARK: Enter highscore

titleEnterHighLoop
	bsr.w titleAction
	move.l mainPlanesPointer+4(pc),d1
	lea tempVar(pc),a0
	move.l d1,(a0)
	bsr.w titleWriteBpl
    moveq #1,d7
    bsr.w rythmSyncAnim

    lea titleHighBlink(pc),a3
    lea highInitials(pc),a4
    lea highInitialsIndex(pc),a6

	lea plyBase(pc),a0
	move.l plyJoyCode(a0),d0
	move d0,d1
	swap d0
	cmp.w d0,d1
    beq .charProcessed
	; process char position index left and right

    btst #JOY_LEFT,d0
    beq .tstRight
    ;btst #JOY_LEFT,d1        ; left unchanged? Skip
    ;bne .tstRight
    tst.w (a6)
    beq.b .indexProcessed
    subq.w #1,(a6)
    clr.b (a3)
    bra .indexProcessed
.tstRight
    btst #JOY_RIGHT,d0
    beq .indexProcessed
    ;btst #JOY_RIGHT,d1
    ;bne .indexProcessed        ; right unchanged? Skip
    cmpi #2,(a6)
    bge.b .indexProcessed
    addq.w #1,(a6)
    clr.b (a3)
.indexProcessed

    move.w (a6),d7

    ; process char up and down

    btst #JOY_UP,d0
    beq .tstDown
   ; btst #JOY_UP,d1        ; up unchanged? Skip
   ; bne .tstDown
    cmpi.b #"Z",(a4,d7*2)
    bge.b .charProcessed
    add.b #1,(a4,d7*2)
    bra .charProcessed
.tstDown
    btst #JOY_DOWN,d0
    beq .charProcessed
    ;btst #JOY_DOWN,d1        ; left unchanged? Skip
    ;bne .charProcessed
    cmpi.b #"A",(a4,d7*2)
    ble.b .charProcessed
    sub.b #1,(a4,d7*2)
.charProcessed
    move.w (a6),d7
    move.l (a4),highInitialsCopy-highInitials(a4)
    move.w 4(a4),4+highInitialsCopy-highInitials(a4)
    add.b #1,(a3)
    move.b (a3),d0
    lsr #4,d0
    btst #0,d0
    bne .keepChar
    move.b #"@",highInitialsCopy-highInitials(a4,d7*2)
.keepChar
    lea highInitialsCopy(pc),a0
    move #188,d0
    move.l #118,d1
    move.l mainPlanesPointer+4,a5
    bsr.w wrtTextBitmap

    lea highInitialsCopy+2(pc),a0
    move #204,d0
    move.l #118,d1
    move.l mainPlanesPointer+4,a5
    bsr.w wrtTextBitmap

    lea highInitialsCopy+4(pc),a0
    move #220,d0
    move.l #118,d1
    move.l mainPlanesPointer+4,a5
    bsr.w wrtTextBitmap

	move.w plyBase+plyJoyCode(pc),d7
	btst #STICK_BUTTON_ONE,d7; check firebutton 1
	bne.b .readyForDisplay                        ;
;    btst.b  #7,$bfe001                      ; firebutton 1 pressed?


    IFEQ RELEASE
    bsr.w keyboardHandler
    cmpi.b #$60,keyCode(pc)       ; left shift - quit game
    beq.w forceQuit
	cmpi.b #$61,keyCode(pc) ; right shift - start game
    beq.w titleToGame
    ENDC
    bra.w titleEnterHighLoop
.readyForDisplay
    lea highData(pc),a0
    clr.w d0
    move.b titleHighFlag,d0
    subq #1,d0
    lea highInitials(pc),a6 ; copy temp initials to hero table
    move.b (a6),(a0,d0*8)
    move.b 2(a6),1(a0,d0*8)
    move.b 4(a6),2(a0,d0*8)

    bsr.w saveHighscores

;#MARK: Title Main – Show highscore table
titleMain

    lea frameCount(pc),a0
    clr.l (a0)
    clr.w tempVar+4; rhythm counter

	lea AudioSoundStatus(pc),a1
	tst.b (a1)
	bne.b .keepAudioSoundStatus
	move.b #3,(a1)
.keepAudioSoundStatus
	bsr titleDrawSound

    move.l mainPlanesPointer(pc),tempVar        ; start with highscore screen
    tst.b titleHighFlag(pc)
    bne.b .credits ; already initiated
    move.l mainPlanesPointer+4,tempVar        ; start with credits screen
.credits
	move.l mainPlanesPointer+4(pc),d1
	lea tempVar(pc),a0
	;move.l d1,(a0)
	bsr.w titleWriteBpl
    WAITVBLANK
    CLEARMEMORY mainPlanesPointer+4(pc),mainPlaneOneSize(pc)


        ;#MARK: Title Draw Credits & Hightable
.drawCredits
.firstLine=80
    lea titleTextA(pc),a0
    IF DEMO=0
    move #11*8,d0
    ELSE
    move #7*8,d0
	ENDIF
    move.l #.firstLine+3*8,d1
    move.l mainPlanesPointer+4(pc),a5
    bsr.w wrtTextBitmap


    lea titleTextA1(pc),a0
    move #10*8,d0
    move.l #.firstLine+4*8,d1
    move.l mainPlanesPointer+4(pc),a5
    bsr.w wrtTextBitmap

    lea titleTextB(pc),a0
    move #9*8,d0
    move.l #.firstLine+7*8,d1
    move.l mainPlanesPointer+4(pc),a5
    bsr.w wrtTextBitmap

	lea titleTextC(pc),a0
	move #10*8,d0
	move.l #.firstLine+8*8,d1
	move.l mainPlanesPointer+4(pc),a5
	bsr.w wrtTextBitmap

	lea titleTextShopA(pc),a0		; shop notice
	move #11*8,d0
	move.l #.firstLine+4*8,d1
	move.l mainPlanesPointer+8(pc),a5
	bsr.w wrtTextBitmap

	lea titleTextShopB(pc),a0
	move #10*8,d0
	move.l #.firstLine+5*8,d1
	move.l mainPlanesPointer+8(pc),a5
	bsr.w wrtTextBitmap

    lea tempVar+20(pc),a4
    move.b #" ",(a4)
    move.b #"=",2(a4)
    clr.b 3(a4)      ; prep high numbering

    lea titleHighLocalHeroes(pc),a0
    move #120,d0
    move.l #80,d1
    move.l mainPlanesPointer(pc),a5
    bsr.w wrtTextBitmap ; draw title

    moveq #9,d7
    lea highData(pc),a3
    moveq #95,d5
.drawHeroesLoop
    lea tempVar+20(pc),a4
    tst.w d7
    beq .numberTen
    moveq #10,d0
    sub d7,d0
    add.w #"0",d0
    move.b d0,1(a4)
    bra.b .drawnNums
.numberTen
    move.w #"10",(a4)
.drawnNums
    move.l a4,a0
    move #96,d0
    move d5,d1
    move.l mainPlanesPointer(pc),a5
    bsr.w wrtTextBitmap



    lea 4(a3),a0 ; draw number
    bsr.w scoreToChar


    lea titleScoreText(pc),a0
    move #118+8,d0
    move d5,d1
    move.l mainPlanesPointer(pc),a5
    bsr.w wrtTextBitmap

    lea (a3),a0 ; draw name
    move #198+8,d0
    move d5,d1
    move.l mainPlanesPointer(pc),a5
    bsr.w wrtTextBitmap


    moveq #10,d6
    sub.b d7,d6
    cmp.b titleHighFlag,d6
    bne .currentHi
    lea highMarker(pc),a0 ; new entry
    move #48,d0
    move d5,d1
    move.l mainPlanesPointer(pc),a5
    bsr.w wrtTextBitmap
.currentHi
    add.w #10,d5
    lea 8(a3),a3
    dbra d7,.drawHeroesLoop

    tst.b titleHighFlag(pc)
    bne.b .gotIt ; already initiated
    bsr.w titleEnableDisplay
.gotIt
    clr.b titleHighFlag

	lea plyBase(pc),a5
	sf.b plyCheatEnabled(a5)
	sf.b plyContinueAvail(a5)
	sf.b plyFire1Hold(a5)
	bclr #7,plyPracticeAvail(a5); remove active flag

	move.b #$ca,d0	; show engage & sound icons
	bsr titlePosIcons


.waitFbRelease
	bsr titleAction
	move.w plyBase+plyJoyCode(pc),d7
	btst #STICK_BUTTON_ONE,d7; check firebutton 1
	bne.b .waitFbRelease

        ;#MARK: Title Mainloop
        ;clr frameCount+2
titleMainLoop
	bsr.w titleAction

	; check for controller actions, music&fx toggle, cheat sequence
	lea plyBase(pc),a5
	move.l plyJoyCode(a5),d0
	move d0,d1
	swap d0
	cmp.b d0,d1
    beq .ret     ; remains unchanged? skip!
.retController
    tst.b d0
    beq .retUnchanged
	lea .cheatCode(pc),a0	; cheat combo check
	clr.w d1
	move.b (a0),d1
	move.b 1(a0,d1.w),d2
	add.b #1,(a0)
	cmp.b d2,d0	;combo continued?
	bne.b .resetCheatCombo
	cmpi.b #7,d1
	blt.b .retUnchanged
	; cheat enabled
	st.b plyCheatEnabled(a5)
	move.b #01,fxPrioPlaying
    move.b #02,fxInit
	bra.b .resetCheatCombo
.toggleSubKey
	not.b keyCode
.toggleSub
	bsr .toggleSound
	bra.b .retToggle
.cheatCode
	dc.b 0
	dc.b 08,08,04,04,01,02,01,02; Konami cheat sequence UUDDRLRL
	even
.resetCheatCombo
	clr.b (a0)
.retUnchanged
    clr.l d1		; toggle music with left dir
	btst #JOY_LEFT,d0
    bne .toggleSub
    moveq #1,d1		; toggle sound with right dir
	btst #JOY_RIGHT,d0
    bne .toggleSub
.ret
	move.b keyCode(pc),d2
	clr.l d1
    cmpi.b #$37,d2	; m key press, toggle music
    beq.b .toggleSubKey
	moveq #1,d1
    cmpi.b #$21,d2	; s key press, toggle sound
    beq.b .toggleSubKey
.retToggle

	move.l mainPlanesPointer+4(pc),d1
	lea tempVar(pc),a0
	move.l d1,(a0)

    moveq #1,d7
    bsr.w rythmSyncAnim

	bsr.w keyboardHandler	; query keyboard

	IFEQ RELEASE
	cmpi.b #$60,keyCode(pc)       ; left shift - quit game
    beq.w forceQuit
	cmpi.b #$61,keyCode(pc) ; right shift - start game
    beq titleToGame
    ENDC

	lea plyBase(pc),a5

	move.w plyJoyCode(a5),d7	; hold firebutton during anim->continue
	btst #STICK_BUTTON_ONE,d7
	beq.b .FBreleased
	add.b #1,plyFire1Hold(a5)
	cmpi.b #3*50,plyFire1Hold(a5); hold fb longer than 3 seconds?
	bhi .chkPractice	; yes->init level 3
	bra titleMainLoop
.FBreleased
	tst.b plyFire1Hold(a5)	; was not yet pressed
	beq titleMainLoop
	bra titleToGame
.chkPractice
	tst.b plyPracticeAvail(a5)	; no practice available -> launch campaign
	beq titleToGame
.initPractice
	bset #7,plyPracticeAvail(a5)	; mark as active
	bra titleToPractice

.toggleSound
	lea AudioSoundStatus(pc),a1
	bchg.b d1,(a1)
	tst.b (a1)
	bne.b .keepOn
	eor.b #1,d1
	bchg.b d1,(a1)
	rts
.keepOn
titleDrawSound
	;rts
	lea copTitleSoundIcon,a0   ; set sprite pointer for AudioSoundStatus
	clr.w d1
	move.b AudioSoundStatus(pc),d1
	;ALERT alert02,d0
	subq #1,d1
	lsl #6,d1
    lea titleSoundIcon,a1
    adda.w d1,a1
    move.l a1,d1
    ;move.l #titleSoundIcon,d0
    move.w d1,6(a0)
    swap d1
    move.w d1,2(a0)
	rts
titlePosIcons
	lea copTitleEngageIcon-5,a0
	move.b d0,(a0)
	lea copTitleSoundIcon-5,a0
	move.b d0,(a0)
	rts

titleDrawEngage

.engageEntry=32
.engageEntryOff=.engageEntry+4
.trainingEntry=24
.trainingEntryOff=.trainingEntry+4
	lea plyBase(pc),a5
	lea copTitleEngageIcon,a0   ; set sprite pointer for Engage / Training
	lea titleSoundIcon,a1
	tst.b plyPracticeAvail(a5)
	sne d0
	andi #%100,d0
	lea .blinkTableEngage(pc,d0),a4

	move.w frameCount+4(pc),d4
	lsr #6,d4
	andi #3,d4
	move.b (a4,d4),d4
	lsl #3,d4
	lea (a1,d4),a1
	move.l a1,d0
    move.w d0,6(a0)
    swap d0
    move.w d0,2(a0)
	rts
.blinkTableEngage
	dc.b .engageEntry, .engageEntryOff, .engageEntry, .engageEntryOff
.blinkTableTraining
	dc.b .engageEntry, .engageEntryOff, .trainingEntry, .trainingEntryOff

titleToPractice
	lea gameStatus(pc),a0
	move.b #statusLevel2,(a0)
titleToGame
    	move.w #BANK0F!BANK1F!BANK2F!BRDRBLNKF!BRDSPRTF!SPRES1F,copTitleBlank+2
	lea transitionFlag(pc),a1
	move #transitionOut,(a1)	; init fadein
.fadeOut
	bsr.w titleAction
    bsr.w titleWriteBpl
    moveq #1,d7
    bsr.w rythmSyncAnim
	lea transitionFlag(pc),a1
	tst.w (a1)
	bne.b .fadeOut

	IFEQ DEBUG
	move.w #DMAF_BPLEN!DMAF_SPRITE,DMACON(a6); switch of bpl dma
    WAITVBLANK
	ENDIF

	IFNE INITWITH
	bra resetScores
	;move.l #$111111,(pc)	; fake start score
    ELSE
    rts
	ENDIF

titleEnableDisplay
    move #ECSENAF,copBPLCON0+2 ; 0 bitplanes
    move #$3f,copBPLCON2+2   ; priority

	move.l #parPlaneNebula,d1        ; load bckplane data for title
	lea bckplanePointer(pc),a0
	move.l 4(a0),d0
	move.l d0,d2
	move.l	#bckplaneWidth*bckplaneHeight*bckplaneDepth+16,d3
	jsr loadFile

    move #0,copBPLCON1+2
    lea CUSTOM,a6

	lea gameStatusLevel(pc),a0
	st.b (a0)	; reset pointer within rasterlist precalc code

    WAITVBLANK
    move.l #copGameReturn,d0
    move d0,copTitleL
    swap d0
    move d0,copTitleH

;	rts


    SAFECOPPER
    bsr rasterListBuild
    RESTORECOPPER
	;WAITSECS 1
	;QUITPROGRAM


    WAITVBLANK
    move.l #copTitle,d0
    move d0,irqCopJmp+2
    swap d0
    move d0,irqCopJmp
    st.b irqColorFlag
    WAITVBLANK

;	COPPERSUBLIST copTitle
    move.l #copTitle,d0            ; init game coplist
    move.w d0,copsprInitLW
    swap d0
    move.w d0,copsprInitHW

    lea CUSTOM,a6
    move #$34,DDFSTRT(a6)
    move #$b6,DDFSTOP(a6)

;	WAITSECS 1
;	QUITPROGRAM


    WAITVBLANK

	lea scrMngOffset(pc),a0
	move.w #screenManagerNil-jmpSrcMngOffset,(a0)




    ;lea rasterListBraMod(pc),a1
    ;move.w #rasterListMove-rasterListManager-6,2(a1); modify bra vector for rasterlistManager entry
	lea transitionFlag(pc),a1
	move #transitionIn,(a1)	; init fadein
	WAITVBLANK
	WAITVBLANK
	lea CUSTOM,a6
	move.w #DMAF_SETCLR!DMAF_BPLEN!DMAF_SPRITE,DMACON(a6); bpl dma -> on


	move.w #ECSENAF!BPU0F!BPU1F!BPU2F!DPFF,copBPLCON0+2 ; 7 bitplanes
    move #$3f,copBPLCON2+2   ; priority
    rts

titleWriteBpl
    move.l tempVar(pc),d1
   ; ALERT alert01,d1
    moveq #$50,d7
	add.l bckplanePointer(pc),d7
    clr.l d5
    move.b frameCount+3(pc),d5
    andi.b #1,d5
    lsl #6,d5
    add.l d5,d7

    move.l #bckplaneWidth*bckplaneHeight,d5
    moveq #mainPlaneWidth,d6
    lea copBPLPT,a4
.tempVal SET 6              ; write bplpt pointer mainplane to copsublist (small interleaved bitmap cant be scrolled by modyfing modulus)
    REPT 3
	move d1,.tempVal(a4)
    swap d1
	move d1,.tempVal-4(a4)
	move d7,.tempVal+8(a4)
    swap d7
	move d7,.tempVal+4(a4)      ; update startadress of secondary plane
.tempVal SET .tempVal+16
    swap d1
    swap d7
    add.l d6,d1
    add.l d5,d7
    ENDR
	move d1,.tempVal(a4)
    swap d1
	move d1,.tempVal-4(a4)
	move d7,.tempVal+8(a4)
    swap d7
	move d7,.tempVal+4(a4)
    rts
        ; MARK: Title Action
titleAction     ; do all the moving and dancing stuff

	lea CUSTOM,a6	; set irq and dma

    ;lea	mt_chan1,a4
    ;bsr mt_music
    move.w frameCount+4(pc),d0
.waitVBL
	move frameCount+4(pc),d1
	cmp.w d0,d1
    beq.b .waitVBL
.noIRQ
    ;WAITVBLANK
    ;lea frameCount(pc),a0
    ;clr (a0)
    ;add #1,2(a0)
;    move frameCount+2,d0
;    ALERT alertfc,d0
    ;bsr rythmSynchronizer
    clr.w d0
    move #darkRed,d1
    move #medRed,d2
    move #liteRed,d3
    lea copTitleRed,a0
    cmpi.b #$3c,AudioRythmFlagAnim(pc)
    blo .halfRed
    ;clr.b AudioRythmFlagAnim
    lsl #1,d1
    lsl #1,d2
    lsl #1,d3
.halfRed    moveq #3,d7
.writeColRed
    move d1,2(a0,d0)
    move d2,18(a0,d0)
    move d3,34(a0,d0)
    addq #4,d0
    dbra d7,.writeColRed
;    lea CUSTOM,a6
;.waitPAL   cmpi.b #$fe,VHPOSR(a6)
;    bls.b .waitPAL
;.waitDis2
;    cmpi.b #24,VHPOSR(a6)
;    ble.b .waitDis2

	bsr.w titleDrawSound
	bsr titleDrawEngage

	lea rastListMover(pc),a0
	add.b #1,(a0)
	move.b #3,1(a0); speed of animation
	bsr rasterListTitle

    					; switch screens
    tst.b titleHighFlag(pc)
    bne.b .skip

	lea tempVar+4(pc),a0
    cmpi.b #$3f,AudioRythmFlagAnim(pc)
	bne.b .skipBeat
    add.w #1,(a0)
.skipBeat
    cmpi #90,(a0)
    bhi .showCredits
    cmpi #60,(a0)
    bhi .showShop
    cmpi #30,(a0)
    bhi .showHeroes
.skip

    lea CUSTOM,a6
					 ;manage rainbow colors
    move.l bobDrawList+8(pc),a0
    lea copTitle,a1
    lea rainbowColors(pc),a2
    clr.w d2
    move.b AudioRythmAnimOffset(pc),d2

    move frameCount+4(pc),d4
    lsr #1,d4
    lea sineTable(pc),a4
    moveq #$7f,d0
    moveq #$3f,d6
    moveq #1,d5
    and d0,d4
    and d6,d2
    move.w (a0)+,d7 ; number of scanlines to colorize
    addq.w #2,a0     ; skip first text line
    subq #4,d7
    clr.l d5
    bra .loopQuit
.rainLoop
    move.w (a0)+,d1
    move d2,d3
    lsr #1,d3
    and d6,d3
    move.w (a2,d3*2),d3
    move d3,(a1,d1)
    move.b (a4,d4),d5
    addq #2,d4
    and d0,d4
    lsr #5,d5
    ;andi #$07,d5
    ;add.w #2,d2
    add.w d5,d2
.loopQuit
    dbra d7,.rainLoop
.noColorAction

	move.w copTitleBlank+2,d0	; disable sprites in border when fade has finished
	cmpi.w #BANK0F!BANK1F!BANK2F!BRDRBLNKF!SPRES1F,d0
	beq.b .isFine

	lea transitionFlag(pc),a1
	tst.w (a1)
	bne.b .isFine
	move.w #BANK0F!BANK1F!BANK2F!BRDRBLNKF!SPRES1F,copTitleBlank+2
.isFine
    rts
.showCredits
    move.l mainPlanesPointer+4(pc),d1
    move.l d1,tempVar
    bsr titleWriteBpl
    clr.w tempVar+4		; reset screen switch
    bra .skip
.showHeroes
    move.l mainPlanesPointer(pc),d1
    move.l d1,tempVar
    bsr titleWriteBpl
	bra .skip
.showShop
    move.l mainPlanesPointer+8(pc),d1
    move.l d1,tempVar
    bsr titleWriteBpl
	bra .skip
rainbowColors
    dc.w $f00,$f20,$f50,$f70,$fa0,$fc0,$ff0,$df0
    dc.w $bf0,$8f0,$6f0,$3f0,$1f0,$0f4,$0f6,$0f9
    dc.w $0fb,$0fe,$0ef,$0cf,$09f,$07f,$04f,$02f
    dc.w $00f,$30f,$50f,$80f,$a0f,$d0f,$f0f,$f2f
    dc.w $f4f,$f2f,$d0f,$a0f,$80f,$50f,$30f,$00f
    dc.w $02f,$04f,$07f,$09f,$0cf,$0ef,$0fe,$0fb
    dc.w $0f9,$0f6,$0f4,$1f0,$3f0,$6f0,$8f0,$bf0
    dc.w $df0,$ff0,$fc0,$fa0,$f70,$f50,$e30,$e10


scoreToChar
    lea titleScoreText(pc),a1; convert score-number to printable chars
    moveq #3,d2
.scoreToPrint
    move.b (a0)+,d0
    move d0,d1
    andi #$0f,d1
    andi #$f0,d0
    asr #4,d0
    add #"0",d0
    move.b d0,(a1)+
    add #"0",d1
    move.b d1,(a1)+
    dbra d2,.scoreToPrint
.quitScore
    move.b #"@",-8(a1)
    move.b #0,(a1)
    rts
; #MARK: TITLE MANAGER ENDS

;#MARK: - HIGHSCORE TABLE

highInitials
    dc.b "A",0,"A",0,"A",0
highInitialsCopy
    dc.b "Z",0,"B",0,"A",0
highInitialsIndex
    dc.b 0
    even
highMarker
    dc.b "NEW",0
    even

highData
    dc.b "RIC",0
    dc.l $10000
    dc.b "KEV",0
    dc.l $5000
    dc.b "ALT",0
    dc.l $4000
    dc.b "CLA",0
    dc.l $3000
    dc.b "DOR",0
    dc.l $2000
    dc.b "ING",0
    dc.l $1000
    dc.b "WIN",0
    dc.l $500
    dc.b "DAX",0
    dc.l $300
    dc.b "STI",0
    dc.l $20
highDataLast
    dc.b "WON",0
    dc.l $1
highDataEnd
	blk.b 10,0  ; fill up to meet NVRAM saving format
	even



; #MARK: - INIT LEVEL BEGINS
; #MARK: welcome message
initLevelWelcome

	WAITVBLANK

	bsr blankSprite

    WAITVBLANK

    lea CUSTOM,a6
	move #ECSENAF,copGameWelcome+6
	move.w #$b0,d0
	move.l d0,d1
	andi #$ff,d0
	or.w #(displayWindowStart+50)<<8,d0
	lsr.l #3,d1
	andi #$20,d1
	or #$3800,d1
	move.w d0,COPDIWSTRT+2
	move.w d1,COPDIWHIGH+2
	add #$04f0,d0
	move.w d0,DIWSTOP(a6)
	move.l bckplanePointer(pc),d0
	lea bobSourceSize-(mainPlaneWidth*mainPlaneDepth*5),a5	; use spare bytes of bobsource mem for text message
	add.l bobSource(pc),a5
	move.l a5,d0
	lea copBPLPT,a2
	move.w d0,6(a2)
	swap d0
	move.w d0,2(a2)


	lea copGameWelcome,a0
	move #BPLCON3,(a0)
	move.l a0,d0
	move d0,copsprInitLW
	swap d0
	move d0,copsprInitHW

	clr.w d0
	move.b gameStatus(pc),d0
	sub.b #(statusLevel0+1),d0
	move d0,d1
	lsl #5,d0
	lsl #2,d1
	sub d1,d0	: text length = 28
	lea .txt(pc,d0),a0
	moveq #56,d0
	clr.w d1
	bra wrtTextOnePlane
.txt
	dc.b "   STAGE 1=  FIRST RESORT  ",0
	dc.b "   STAGE 2=    NOT NAMED   ",0
	dc.b "   STAGE 3=  APIDYAN SUN   ",0
	dc.b "   STAGE 4=    NOT NAMED   ",0
	dc.b " STAGE 5= SKIES OF HYBRIS  ",0
	dc.b "  STAGE 6=  OCEAN OF SILK  ",0
	dc.b "   STAGE 7=    NOT NAMED   ",0
	dc.b "STAGE 8= FACTORY OF THUNDER",0

	    ; #MARK: init level 0-5

initGame
	lea gameInActionF(pc),a0
	sf (a0)      ; disable gamecode in interrupt

	lea frameCount+4(pc),a0
	clr.w (a0)	; reset frameCounter

	IFEQ INITWITH
	lea AudioSoundStatus(pc),a1
	move.b #%11,(a1)		; if testing with direct level init, start sound and music
	ENDIF
	;lea AudioSoundStatus(pc),a1

	;A
	;QUITPROGRAM
	SAFECOPPER	; switch to safe default copperlist

	clr.w d7
	move.b gameStatus(pc),d7
	sub.b #statusLevel0+1,d7
	lea gameStatusLevel(pc),a0
	move.w d7,(a0)

	lea rastListMover+1(pc),a0
	move.b .animSpeedVfxLayer(pc,d7),(a0); anim speed vfx layer
	clr.l d0
	move.b .scrollSpeed(pc,d7),d0
	ror.l #4,d0
	swap d0
	lea viewPosition(pc),a0
	move.l d0,viewPositionScrollspeed(a0); basic scroll speed
	move.l d0,viewPositionAdd(a0)

	bsr prepareInitGame

	bsr initLevelWelcome

	WAITVBLANK

	move #BPU0F!ECSENAF,copGameWelcome+6

	move.w gameStatusLevel(pc),d7
	add.b #"0",d7
    bsr initPrepDataLoad ; modify filenames, load and decode
	;rts
	WAITVBLANK

	move.w gameStatusLevel(pc),d0
	move.w .parallaxInit(pc,d0*2),d6
	swap d6
	move.w .screenManagerRun(pc,d0*2),d6
	lea jmpParallax(pc),a0	; 0.w = offset to ParInit, 1.2 = offset to screenManagerRun
	move.l d6,(a0)
	;b1
	lea sprMngOffset(pc),a0
	move.w #spriteManager-jmpSprMngOffset,(a0)
	bra .1
.scrollSpeed
	dc.b 	$10,$18,$20,$10,$10,0
.animSpeedVfxLayer	; second playfield scrollspeed
	dc.b 	3,2,2,3,2,3

.parallaxInit
	dc.w 	parallaxInit0-jmpParOffset;lv0
	dc.w	parallaxInit1-jmpParOffset;lv1
	dc.w 	parallaxInit1-jmpParOffset
	dc.w	parallaxInit2-jmpParOffset;lv3
	dc.w 	parallaxInit4-jmpParOffset
.screenManagerRun
	dc.w	screenManagerLv0-jmpSrcMngOffset;lv0
	dc.w	screenManagerLv1-jmpSrcMngOffset;lv1
	dc.w	screenManagerLv2-jmpSrcMngOffset
	dc.w	screenManagerLv3-jmpSrcMngOffset;lv3
	dc.w	screenManagerLv4-jmpSrcMngOffset

.copFileLV0
	FILENAMEPREFIX
	dc.b 	"coplistSprite.bin",0
.copFileLV1
	FILENAMEPREFIX
	dc.b 	"coplistSun.bin",0
.copFileLV2
	FILENAMEPREFIX
	dc.b 	"coplistSky.bin",0
.copFileLV3
	FILENAMEPREFIX
	dc.b 	"coplistSea.bin",0
.copFileLV4
	FILENAMEPREFIX
	dc.b 	"coplistCity.bin",0
	even
.gameCopList
	dc.w	.copFileLV0-.getFile
	dc.w	.copFileLV1-.getFile
	dc.w	.copFileLV2-.getFile
	dc.w	.copFileLV3-.getFile
	dc.w	.copFileLV4-.getFile
.1

	move.w gameStatusLevel(pc),d0
	move.w .gameCopList(pc,d0*2),d0
.getFile
	lea (pc,d0.w),a0
	move.l a0,d1	; pointer to filename
	move.l d1,d7
	move.l copperGame(pc),d2
	clr.l d3
	move #copperGameMaxSize,d3
	bsr GetFileInfo
	beq errorDisk

	move.l d7,d1
	move.l copperGame(pc),d2
	bsr loadFile
	beq errorDisk
	add.l (fib_Size.w,pc),d2
	move.l d2,a1
	lea -16(a1),a1
	lea copperGameJmp(pc),a0
	move.l a1,(a0)

	lea copGameDefault,a0       ; copy return address to coplist
    movem.l (a0),d0-d3
	movem.l d0-d3,(a1)

	move.l copperGame(pc),d0
	lea irqCopJmp(pc),a0
	move.l d0,(a0)		; make available in irq

	bsr rasterListBuild	; prepare rasterbased scrolling

	WAITVBLANK
	lea bckplanePointer(pc),a0
	move.w gameStatusLevel(pc),d7
	move.w (.jmpTable-*,pc,d7.w*2),d7
	jmp (pc,d7.w)
.jmpTable
	dc.w	.lv0nebula-.jmpTable+4
	dc.w	.lv1sun-.jmpTable+4
	dc.w	.lv2sky-.jmpTable+4
	dc.w	.lv3ocean-.jmpTable+4
	dc.w	.lv4city-.jmpTable+4

	; level specific init code

.lv0nebula
	lea parPlaneNebula(pc),a2
	move.l a2,d1	; load bckplane data -> temp
	move.l 12(a0),d0
	move.l d0,d2
	move.l	#bckplaneWidth*bckplaneHeight*bckplaneDepth+16,d3
	bsr loadFile
	move.w #(bckplaneWidth*bckplaneHeight*bckplaneDepth+16)/4,d7
	lea bckplanePointer(pc),a0
	move.l 4(a0),a0
.clrBckPlane
	clr.l (a0)+		; clear plane, fill ingame
	dbra d7,.clrBckPlane

	bsr ParallaxManager	; prep sprite plane data

	move #$fc20,d5
	move #%011011,d6
	move #ECSENAF!CONCOLF!BPU0F!BPU1F!BPU2F,d7
	bsr.b .prepConRegs

	bra .prepGlobals
.prepConRegs
	lea coplist,a0
	move d7,copBPLCON0-coplist+2(a0)
	move d6,copBPLCON2-coplist+2(a0)
	move d5,copBPLCON3-coplist+2(a0)
	move #$fe,copBPLCON4-coplist+2(a0)
	rts
	    ; #MARK: init level 1
;.lv1space
;	move.l #parPlaneSpace,d1        ; load bckplane data
;	move.l 4(a0),d0
;	move.w #ECSENAF!CONCOLF!BPU0F!BPU1F!BPU2F,d7
.loadLevDat	; entry with d5=BPLCON3 d6=bplcon2 d7=bplcon0
	bsr.b .prepconRegs
	move.l d0,d2
	move.l	#bckplaneWidth*bckplaneHeight*bckplaneDepth,d3
	bsr loadFile

	RESTORECOPPER

	bsr ParallaxManager	; prep sprite plane data
	bra .prepGlobals

	    ; #MARK: init level 2
.lv1sun
	lea parPlaneSolar(pc),a2
	move.l a2,d1	; load bckplane data -> temp buffer
	move.l 4(a0),d0
	move.w #ECSENAF!CONCOLF!BPU0F!BPU1F!BPU2F!DPFF,d7
	move #%011011,d6
	move #BANK0F!BANK1F!BANK2F!PF2OF2F!BRDRBLNKF!SPRES0F,d5
	bra .loadLevDat

	    ; #MARK: init level 3
.lv2sky
    lea copGameEscalateWait,a2
    move.l a2,d2
    lea copInitEscalateEnd,a2
    move.w d2,6(a2)
    swap d2
    move.w d2,2(a2)	;

	lea parPlaneSky(pc),a2
	move.l a2,d1	; load bckplane data -> temp buffer
	move.l 4(a0),d0
	move.w #ECSENAF!CONCOLF!BPU0F!BPU1F!BPU2F,d7
	move #%001001,d6
	move #$fc20,d5
	bra .loadLevDat

	    ; #MARK: init level 3
.lv3ocean
	lea parPlaneSea(pc),a2
	move.l a2,d1	; load bckplane data -> temp buffer
	move.l 4(a0),d0
	move #$f000!BRDRBLNKF,d5
	move #%100011,d6
	move.w #ECSENAF!CONCOLF!BPU0F!BPU1F!BPU2F!DPFF,d7
	bra .loadLevDat
	    ; #MARK: init level 4
.lv4city
	lea parPlaneCity(pc),a2
	move.l a2,d1	; load bckplane data -> temp buffer
	move.l 4(a0),d0
	move #$f000!BRDRBLNKF,d5
	move #%000011!PF2PRIF,d6
	move.w #ECSENAF!CONCOLF!BPU0F!BPU1F!BPU2F!DPFF,d7
	bra .loadLevDat
.prepGlobals
    bsr initGameGlobal	; reset general vars
    moveq #0,d0
	bsr dynamicPlayerColors	; reset player colors

.wait3secs
	IFEQ RELEASE
	move.w frameCount+4(pc),d0
	cmpi #1*20,d0
	bls .wait3secs
	ELSE
	move.w frameCount+4(pc),d0
	cmpi #3*60+50,d0
	bls .wait3secs
	ENDIF

	lea copGameWelcome,a0
	move #NOOP,(a0)

	lea CUSTOM,a6
	move.w #DMAF_BPLEN!DMAF_COPPER!DMAF_SPRITE,DMACON(a6); black screen, switch off copper

; #MARK: set/reset playfield and sprite colors
	WAITVBLANK

	move.l #copGameDefault,d0
    move d0,copsprInitLW
    swap d0
    move d0,copsprInitHW	; switch to basic coplist prior to color inits
	;WAITVBLANK
	;WAITVBLANK

    bsr colorManager
	lea enemShotColors,a1   ;enem shot colors
.colorIt
	lea gfxSourcePaletteShip,a0   ;set sprite ship colors -> colRegs
	bsr colorPlayer

	WAITVBLANK

	move.l #copGame,d0	; init game coplist
	move.w d0,copsprInitLW
	swap d0
	move.w d0,copsprInitHW


	lea CUSTOM,a6
	move.w #DMAF_SETCLR!DMAF_COPPER,DMACON(a6); enable copper

	CLEARMEMORY mainPlanes(pc),mainPlaneOneSize(pc)
	CLEARMEMORY mainPlanes+4(pc),mainPlaneOneSize(pc)
	CLEARMEMORY mainPlanes+8(pc),mainPlaneOneSize(pc)	; clear all bitplanes

	lea gameInActionF(pc),a0
	move.b #1,(a0)      ; enable gamecode in interrupt
	WAITVBLANK

	lea transitionFlag(pc),a1
	IFEQ RELEASE
	move #transitionDone,(a1)	; skip transition
	ELSE
	move #transitionIn,(a1)	; init transition
	ENDIF

	WAITVBLANK
	WAITVBLANK
	lea CUSTOM,a6	; set irq and dma
	move.w #DMAF_SETCLR!DMAF_BPLEN!DMAF_BLITHOG!DMAF_SPRITE,DMACON(a6); enable bpl dma, blittee has priority
	RESTORECOPPER
	;H
	;QUITPROGRAM
	;modify some anims / difficulty level

	clr.w d0
	
    ;#FIXME: Gamediff temp set

	move.b #2,d0
	move.b d0,gameDiff
	move.b gameDiff(pc),d0
	lsl #2,d0
	move.l (.modTurretH,pc,d0),a0
	move.l (a0),a0
	move.w animTablePointer+2(a0),d1
	move.l (.modTurretH+4,pc),a0
	move.l (a0),a0
	move.w d1,animTablePointer+2(a0)

	move.l (.modTurretL,pc,d0),a0
	move.l (a0),a0
	move.w animTablePointer+2(a0),d1
	move.l (.modTurretL+4,pc),a0
	move.l (a0),a0
	move.w d1,animTablePointer+2(a0)

	bra mainGameLoop
.modTurretH
	dc.l tubTurHXAnimpointer,tubTurHYAnimpointer,tubTurHZAnimpointer
.modTurretL
	dc.l tubTurLXAnimpointer,tubTurLYAnimpointer,tubTurLZAnimpointer

initPrepDataLoad
	IFNE RELEASE
	cmp.b loadedLevelStatus(pc),d7
	beq .skipLoad	; level already in mem? Skip load and decode
	ENDIF	; in develop-mode load&decode always -> fast map editing
	move.b d7,loadedLevelStatus
    lea mapDefsFile(pc),a0       level data
    IF DEMO=0
    SEARCHXML4VALUE (a0),"/map"
    ELSE
    SEARCHXML4VALUE (a0),"/dem"
	ENDIF
    move.b d7,(a0)
    lea animDefsFile(pc),a0
    SEARCHXML4VALUE (a0),"nims"
    move.b d7,(a0)
    lea objectDefsFile(pc),a0
    SEARCHXML4VALUE (a0),"ects"
    move.b d7,(a0)

    lea tilePixelData(pc),a0
    SEARCHXML4VALUE (a0),"iles"
    move.b d7,(a0)
    lea colorDefsFile(pc),a0
    SEARCHXML4VALUE (a0),"lors"
    move.b d7,(a0)
    lea parallaxSprite(pc),a0
    SEARCHXML4VALUE (a0),"rite"     ; find chars
    move.b d7,(a0)                  ; alter number of entry
    jsr xmlDecode
	bra.b .avoidMusicRestart
.skipLoad
    bsr initGameSoundtrack ;
    ;!!!: Welcome delete!!!
.avoidMusicRestart
    lea CUSTOM,a6
	move.w #DMAF_BPLEN!DMAF_SPRITE,DMACON(a6); switch of bpl dma
	rts


; #MARK: INIT LEVEL ENDS

; #MARK: - INIT GAME GLOBAL BEGINS
prepareInitGame
    WAITVBLANK

;	move.w #$41fa,chkBckCol;	enable col detection
	lea plyColJmp(pc),a0
	lea plyChkBck(pc),a3
	move.l a3,(a0)	; chk background, not colbox

	lea dialogueActive(pc),a3
	sf.b (a3)


    lea titleSprites,a0     ; hide sprites
    moveq #6,d0
    move #$3000,d1
    move #$f000,d2
.hideSprites
    move d1,(a0)
    move d2,8(a0)
    add.l #titleSpritesOffset,a0
    dbra d0,.hideSprites
    rts

initGameGlobal

	;bra.b .waitWelcome

   ; move.w #1,copBPLCON0+2    ; disable display
    ;move #%011011,copBPLCON2+2   ;video priority (sprites behind pf1)


	;move #0,copBPL2ModOffset+2		; adjust copperlist
    ;move #bckplaneWidth-mainplaneView,copBPL2MOD+2        ;bitplane modulos
	;move #mainPlaneWidth*(mainPlaneDepth-1)+mainplaneCache,copBPL1MOD+2  ; basic modulus

	move.l copPriority(pc),a0
	tst.l a0
	beq .skip
	move #%011011,(a0)	; sprites to front
.skip

    IF ALERTHANDLING=1          ; reset alertvars
    clr.w alertNumber
    clr.l alertLine
    ENDIF

    bsr.w prepareDisplay

    lea CUSTOM,a6
    move #$0,CLXCON2(a6); control sprite<->bck collissions
    move #$2^14+$2^13+$2^12+$2^6+2^0,CLXCON(a6); control sprite<->bck collissions. Enable sprite 1 for player, 3 and 5 for ORing with sprite 2 and 4

	lea introLogo(pc),a0
	move.l a0,d1	        ; load spieleschreiber logo
	move.l spriteDMAMem(pc),d2
	move.l	#artworkPictureSize,d3
	jsr loadFile
	beq errorDisk


	; #MARK: reset and rebuild preconfigured sprite dma list

   	move.l	#(spritePosMemSize/4)-1,d0    ;    reset sorting memory
	move.l	spritePosMem(pc),a0
.del2
	clr.l (a0)+
	dbra d0,.del2

	CLEARMEMORY spriteDMAMem+8(pc),#spriteDMAMemSize	; clean up sprite dma mem
	CLEARMEMORY spriteDMAMem+12(pc),#spriteDMAMemSize

	lea spriteBullet4pixels,a0
	moveq #3,d4
.writeAllDMALists
	move.l spriteDMAMem(pc),d0
	move.l spriteDMAMem+4(pc),d2
	move.l #spriteDMAListOffset,d7	; offset between each single sprite dma list
	lsl #2,d7
	mulu d4,d7
	add.l d7,d0
	add.l d7,d2
    moveq #3,d1
.writeSingleDMAList
	move.l d0,a1
	move.l d2,a2
		move.w #(shotsMax+bulletsMax-1)/4,d6
		move.w #$2058,(a1)+		; first sprite, not used ingame, used as restore source
		clr.l (a1)+
		clr.w (a1)+
		move.w #$2400,(a1)+
		clr.l (a1)+
		clr.w (a1)+
		move.w #$2058,(a2)+		; first sprite, not used ingame, used as restore source
		clr.l (a2)+
		clr.w (a2)+
		move.w #$2400,(a2)+
		clr.l (a2)+
		clr.w (a2)+
		bra.b .firstSprite
.writeSingleSprite
			clr.l (a1)
			clr.l 4(a1)
			clr.l 8(a1)
			clr.l 12(a1)
			clr.l (a2)
			clr.l 4(a2)
			clr.l 8(a2)
			clr.l 12(a2)
.firstSprite
			IF 1=0				; 0=0 sprites are numbered
			lea spriteTempNumbers,a3
			move d1,d7
			lsl #4,d7
			adda.w d7,a3
			ELSE
			move.l a0,a3
			ENDIF
				moveq #spriteDMAHeight-1,d7

.writePixelRows
				movem.w (a3),a4-a5	; read 1 line
				move.w a4,(a1)
				clr.w 2(a1)
				clr.l 4(a1)
				move.w a5,8(a1)    ; write 1 line
				clr.w 10(a1)
				clr.l 12(a1)
				movem.w 64(a3),a4-a5	; read 1 line
				move.w a4,(a2)
				clr.w 2(a2)
				clr.l 4(a2)
				move.w a5,8(a2)    ; write 1 line
				clr.w 10(a2)
				clr.l 12(a2)

				addq #4,a3
				adda #spriteLineOffset,a1
				adda #spriteLineOffset,a2
				dbra d7,.writePixelRows
			lea spriteLineOffset(a1),a1
			lea spriteLineOffset(a2),a2
			dbra d6,.writeSingleSprite
		clr.l d6
		move.w #spriteDMAListOffset,d6
		add.l d6,d0
		add.l d6,d2
		dbra d1,.writeSingleDMAList
	lea 16(a0),a0
	dbra d4,.writeAllDMALists


    lea copSpriteDMA,a0         ; write sprite DMA pointers to 8 sub copper lists. Have 4 lists for four sprite anim frames.

    move.l spriteDMAMem,d4
    move.l #spriteDMAListOffset*4,d3
    move.l #spriteDMAListOffset,d2
    moveq #8,d1
	moveq #3,d7
.wrtCopSpriteDMA			; write four lists
    move.l a0,a1
    move.l d4,d0
	moveq #3,d6
.wrtSingleEntry				; write four entrys
	move d0,6(a1)
    swap d0
    move d0,2(a1)
    swap d0
    add.l d1,a1
    add.l d2,d0
    dbra d6,.wrtSingleEntry
    add.l d3,d4
    lea copSpriteDMAOffset(a0),a0
	dbra d7,.wrtCopSpriteDMA


    move.l spriteDMAMem+4,d4	; prepare second set of copper sub lists, used for buffering / fast switching
	moveq #3,d7
.wrtCopSpriteDMAB
    move.l a0,a1
    move.l d4,d0
	moveq #3,d6
.wrtSingleEntryB
	move d0,6(a1)
    swap d0
    move d0,2(a1)
    swap d0
    add.l d1,a1
    add.l d2,d0
    dbra d6,.wrtSingleEntryB
    add.l d3,d4
    lea copSpriteDMAOffset(a0),a0
	dbra d7,.wrtCopSpriteDMAB

	lea spriteCount(pc),a0
	clr.l (a0) ; reset sprite dma lists
	bsr spriteManager
	bsr spriteManager

    move.w scr2StartPos,d0          ;write startposition all relevant pointers, reset player-flag
    swap d0
    clr.w d0
    move.l d0,viewPosition+viewPositionPointer
    lea plyPos(pc),a6           ; setup player position, reset flags
    ;sub.l #$100200,d0
    move.l d0,(a6);plyPosX
    ;clr.l plyPosAcclX(a6)
    moveq #35,d0
    swap d0
    move.l d0,plyPosAcclX(a6)
    move.w #$a0,d0
    swap d0
    move.l d0,plyPosY(a6)
    clr.l plyPosAcclY(a6)
    moveq #98,d0
    move.w d0,plyInitiated(a6)
    clr plyCollided(a6)
    sf.b plyExitReached(a6)
    st.b plyFire1Auto(a6)
    ;subq.b #1,plyFire1Auto(a6)
    sf.b plyFire1Flag(a6)
    sf.b plyFire1Hold(a6)
    sf.b plyWeapUpgrade(a6)
    sf.b plyWeapSwitchFlag(a6)
    sf.b plyDistortionMode(a6)
    sf.b plyShotCnt(a6)
	bclr #7,plyContinueAvail(a6)	; kill init bit

	moveq #plyAcclXMin,d0
	move.w d0,plyAcclXCap(a6)
	moveq #plyAcclYMin,d0
	move.w d0,plyAcclYCap(a6)

    clr d0
    clr d1
    clr d2

    move.l launchTable(pc),a0
    sub.l launchTableEntryLength(pc),a0
	move.l launchTableBuffer+4(pc),a1
    move.l a1,launchTableBuffer

	move viewPosition+viewPositionPointer(pc),d0
.animtabsrch
	add.l launchTableEntryLength(pc),a0
    tst (a0)
    bmi .foundLastEntry
    move launchTableX(a0),d1
	cmp d1,d0
	bcc.b .animtabsrch
    move.l a0,a3
.animTabWrite
    move.l launchTableEntryLength(pc),d7
    subq #1,d7
.animtabwriteLoop
    move.b (a3)+,(a1)+
    dbra d7,.animtabwriteLoop
    bra .animtabsrch
.foundLastEntry
    moveq #-1,d7
    move.l d7,(a1)

; #MARK: Reset basic memory structures

    CLEARMEMORY objectList,#objectListSize            ; reset objectlist

    move.l spritePosMem(pc),a0
    add.l #spritePosMemSize-4,a0
    moveq #-1,d0
    move.l d0,(a0)
    movem.l bobRestoreList(pc),a0/a1                                ; clear list of bobs to clear from background
    clr.l (a0)
    clr.l (a1)
    movem.l bobDrawList(pc),a0/a1                                   ; clear list of bobs to draw
    clr.l (a0)
    clr.l (a1)

    clr objCount
    clr.l spriteCount
    clr bulletLaunchSkipper

    move.l launchTableBuffer+4(pc),a1
    adda.l launchTableBufferSize(pc),a1
    sub.l launchTableEntryLength(pc),a1
    moveq #-1,d0
    move.l d0,(a1)

    ; reset rastList Values
    lea rastListMover(pc),a0
    clr.b (a0)

	lea particleBase(pc),a0
	moveq #4,d0
.resetPartBase
	clr.l (a0)+	; reset particle vars
	dbra d0,.resetPartBase

    lea particleTable,a6
	moveq #partEntrySize,d6
    moveq #particlesMaxNo,d7
    bra .loop
.resetParticles
    clr.w (a6)
    add.l d6,a6
.loop
    dbra d7,.resetParticles

	lea animTriggers(pc),a0
	clr.l (a0) 	; reset animTriggers, used to sync mixed and joined anims

; #MARK: Reset score variables

	lea score(pc),a0
	IFEQ INITWITH	; releaseversion:score reset in title code
	bsr resetScores
	ENDIF
    move.l #-1,scoreOld(a0)
    clr.l scoreAdd(a0)
    ;clr.b updateStatDispExtra-score(pc)
	clr.l scoreMultiplier-score(a0)
	st.b updateStatDispExtra-score(a0)	; init redraw status pixels

	clr.w d0
	tst.w scoreHighSuccessFlag-score(a0)
	sne.b d0
	lsr.b #1,d0
	ror.w #7,d0	; $fe00 in case of <>0
	move.w d0,scoreHighSuccessFlag-score(a0)
.noHigh

	lea 8*8+fxTable,a4      ; reset pitch, also serves as multiplier count
	moveq #$7f,d0
	move.w d0,(a4)

    lea scoreHigh(pc),a1
    move.l ((highDataLast+4).w,pc),d0
    addq.l #1,d0
    move.l d0,(a1); copy last hi table entry to highscore save var

	CLEARMEMORY spriteScoreBuffer,#spriteScoreBufferSize

    lea copSprite67,a0 ; write dma pointer sprite 0+1 -> coplist
    move.l spriteScoreBuffer,a1
;    lea titleSprites,a1
    move.l a1,d0
    move.w #spriteHiCtlrWordLo,d1
    move.w #spriteHiCtlrWordHi,d2
    move.w d1,(a1)
    move.w d2,8(a1)
    move d0,6(a0)
    move d0,6+8(a0)
    swap d0
    move d0,2(a0)
    move d0,2+8(a0)
    move.w #spriteScoreCtlrWordLo,d1
    move.w #spriteScoreCtlrWordHi,d2
    move.w d1,spriteLineOffset*(spriteScoreHeight)(a1)
    move.w d2,spriteLineOffset*(spriteScoreHeight)+8(a1)

    move.l spriteParallaxBuffer(pc),a1
    lea titleSprites,a1
    move.w #spriteParallaxCtlrWordLo,d1
    move.w #spriteParallaxCtlrWordHi,d2
    move.w d1,(a1)
    move.w d2,8(a1)
    move.l a1,d0
    move d0,6+8(a0)
    swap d0
    move d0,2+8(a0)

	jsr scoreManager
	lea score(pc),a0
	clr.l scoreMultiplier-score(a0)	; do this twice for correct display and avoid audio glitch

	lea fxInit(pc),a0
	clr.b (a0)

    lea forceExit(pc),a0
    sf.b (a0)
	clr.b keyCode       ; reset keyboard key
	clr.l frameCount
	clr.l frameCompare; set target framerate
	;move.l #$00010001,frameCompare
	lea blitterManagerFinishedF(pc),a0
	move #1,(a0); reset "" & blitterManagerLaunchF
	sf.b 2(a0); reset blitterManagerBlankF
	st.b 3(a0);	reset softIntFinishedFlag
	tst $dff00e         ;   reset clxcon & collisionmarker
	rts

initGameSoundtrack
	IF AUDIO=1            ; init soundfx-driver parameters

	lea fxInit(pc),a0
	clr.b (a0)
    clr.b fxPrioPlaying
    clr.b fxCountdown
    tst.b AudioIsInitiated(pc)
    bne .AudioIRQOn
    move.l VBRptr,a0
    lea CUSTOM,a6
    move.b #1,d0
    jsr mt_install_cia
    move.b #1,AudioIsInitiated
.AudioIRQOn
	lea modMain,a0	; start main game music
	bsr initAudioTrack

	clr.b storeSongPos  ; reset music position used in escalation exit code
	clr.b storeSongSpeed
	move #musicFullVolume,d0
	jsr mt_mastervol

    moveq #1,d0
    jsr mt_filter; deactivate audio filter

    ENDC
    rts
; #MARK: INIT GAME GLOBAL ENDS


    ; #MARK: - MAIN GAME LOOP
mainGameLoop        	;***Hauptprogramm/Schleife***
	lea blitterManagerLaunchF(pc),a0
	tst.b (a0)
	beq.b .blitterListNotReady

	tst.b gameInActionF(pc)
	beq.b .blitPause
	bsr blitterManager
.blitPause
.blitterListNotReady

	lea frameCount(pc),a0	; update frameCount
	move (a0),d1
	add.w d1,2(a0)
	clr.w (a0)

	IF SHOWFRAMERATE=1
	lea frameCount(pc),a5
	moveq #$50,d0
	move (a5),d1
	tst.w d1
	bne.b .d1
	moveq #1,d1
.d1
	divu.w d1,d0
	lea .frameRate(pc),a0
	move d0,d1
	and#$0f,d1
	add #"0",d1
	move.b d1,2(a0)
	move d0,d1
	lsr #4,d1
	and#$0f,d1
	add #"0",d1
	move.b d1,1(a0)
.sk1
    move.w #80,d0
    move.w #18,d1
    move.l mainPlanesPointer+8(pc),a5
    bsr wrtTextBitmap

    bra.b .cont
.frameRate
	dc.b " AA",0
	even
.cont
	ENDIF

	IF SHOWframeCount=1
	ALERTSETLINE 20
	lea frameCount+2(pc),a5
	move.w (a5),d0
	ALERT alertframeCount,d0
	ENDIF

	IF SHOWOBJECTNO=1
	lea .objCount(pc),a0
	move.w objCount,d0
	sub.w spriteCount,d0
	;move spriteCount,d0
	move d0,d1
	and#$0f,d1
	add #"0",d1
	move.b d1,2(a0)
	move d0,d1
	lsr #4,d1
	and#$0f,d1
	add #"0",d1
	move.b d1,1(a0)
    move.w #80,d0
    move.w #28,d1
    move.l mainPlanesPointer+8(pc),a5
    lea mainPlaneWidth*2(a5),a5
    bsr wrtTextOnePlane
    bra.b .contB
.objCount
	dc.b " AA",0
	even
.contB
	ENDIF


	IF AUDIO=1
	bsr     rythmSynchronizer
	ENDC
	jsr scoreManager

	cmpi.b #$45,keyCode	: Escape for titlescreen, only
    beq.w .quitGame
.noEscape
	cmpi.b #$19,keyCode
    beq.w .pauseGame

	move.w plyPos+plyJoyCode(pc),d0	; read only upper two bytes of controller
	andi #2^(STICK_BUTTON_TWO),d0	; only start button bit
	lea .storeController(pc),a1
	tst.w (a1)
	bne.b .sameKey		; only process pause if start was released
	move.w d0,(a1)
    btst #STICK_BUTTON_TWO,d0
    bne .pauseGame
.sameKey
	tst.w d0
	bne.b .stillPressed	; was button released?
	clr.w (a1)			; yes
.stillPressed
    bsr keyboardHandler
	tst.w transitionFlag(pc)
    bne.w mainGameLoop

    IFEQ RELEASE
    cmpi.b #$60,keyCode(pc)       ; left shift - quit game
    beq forceQuit

	cmpi.b #$61,keyCode(pc) ; right shift - restart stage. Surf here for complete keyboard code overview: http://wiki.amigaos.net/w/images/thumb/6/68/LibFig34-1.png/800px-LibFig34-1.png
    beq .fastRestart
    ENDIF

    tst.b forceExit(pc)
    beq mainGameLoop
.exit
	lea transitionFlag(pc),a1
	move #transitionOut,(a1)	; init fadeout
.fadeOut
	WAITVBLANK
	bsr blitterManager
	lea transitionFlag(pc),a1
	tst.w (a1)
	bne.b .fadeOut
.fastExit
	lea CUSTOM,a6
	move.w #DMAF_BPLEN!DMAF_SPRITE,DMACON(a6); switch of bpl dma
	lea gameInActionF(pc),a0
	sf.b (a0)	;	avoid
    WAITVBLANK
    WAITVBLANK
    rts
    IFEQ RELEASE
.fastRestart
		; right shift key, restart at level defined on levelGetter.s

	bsr setgameStatus
	;move.b #statusLevel1,gameStatus			;	should be statusTitle
	bra.b .fastExit
	ENDIF
.pauseGame
;    bra mainGameLoop
	lea transitionFlag(pc),a0
	tst.w (a0)	; no pause if fading
	bne mainGameLoop

	lea gameInActionF(pc),a0
    bchg #0,(a0)
    clr.l d0
    move.b (a0),d0
  	lea	mt_chan1,a4
	move.b	d0,mt_Enable-mt_chan1(a4)
    not.b keyCode
    bra mainGameLoop
.storeController
	dc.w 0
    ;bra.b keyQuitGame
;noJoyAction
 ;   clr.l plyPos+plyJoyCode
.quitGame
	btst #0,(gameInActionF,pc)
	bne .noEscape	; in action mode? Cant escape to title
	lea gameStatus(pc),a0
	move.b #statusTitle,(a0)
	bra.b mainLoopQuit
forceQuit
	lea forceQuitFlag(pc),a0
	st.b (a0)
mainLoopQuit
	lea gameInActionF(pc),a0
	sf.b (a0)      ; disable gamecode in interrupt

	lea keyCode(pc),a0
	sf.b (a0)
    WAITVBLANK          ; wait a bit -> irq blits may finish
    WAITVBLANK
    WAITVBLANK
	rts

; #MARK: - BLITTERMANAGER -
*-°°°°°°°°°
blitterManager

	;CALLDOS CachePreDMA

	clr.w blitterManagerFinishedF	; reset finish & launch flags
    lea CUSTOM,a6

	clr.l d0
	move.w #%00001001<<8+%11110000,d0
	tst.b blitterManagerBlankF(pc)
	beq.b .drawZeroes
	move.b #%10000000,d0; dont redraw, clr background
.drawZeroes
    swap d0
    move.l d0,BLTCON0(a6)
    moveq #-1,d0         ; prepare blitter for restoring pixels
    move.l d0,BLTAFWM(a6)

	move.l bobRestoreList(pc),a5
    moveq #%11111,d5
    move #mainPlaneWidth/2,d6
.bobClear
    move.l (a5)+,d0
	beq.s .bobClearQuit
    move.l (a5)+,d2	; bobRestoreListTarget
	WAITBLIT
	movem.l d0/d2,BLTAPTH(a6)
	move.w (a5)+,d0; bobRestoreListBlitSize
	move d6,d1
	sub d0,d1
	and d5,d1
	add d1,d1
    move d1,d2
    swap d2
    move d1,d2
    move.l d2,BLTAMOD(a6)
	move d0,BLTSIZE(a6)
	bra.b .bobClear
.bobClearQuit

	lea bobRestoreList(pc),a5	; keep two lists, one as buffer while screenmanager displays current framebuffer
    movem.l (a5),d0-d1
	exg.l d0,d1
    movem.l d0-d1,(a5)      ; swap restore queue lists

    moveq #-1,d0
	move #$f000,d3
	moveq #mainPlaneWidth/2,d4
	move.l mainPlanesPointer+8(pc),a1

	lea CUSTOM,a6
	movem.l mainPlanesPointer(pc),a1-a3; a1=draw, a2=restore
	lea mainPlanesPointerAsync(pc),a5
	move.l a3,(a5); pointer to bare background
	move.l bobDrawList(pc),a5	; prime list -> draw
	move.l bobRestoreList+4(pc),a3; secondary list -> buffer

	WAITBLIT
	clr.w d0
	move.l d0,BLTAFWM(a6)   ; set blitter mask only once before drawing stuff

.blitDrawLoop
    move.l (a5),d7;bobDrawBLTMOD + bobDrawBLTSIZE
    beq.w .bobDrawQuit          ; last bob already drawn? Prepare for restore code
;    cmpi.w d3,d7
;    beq.b .sameSize
;    move.w d7,d3
    move.l d7,d0
  	move d4,d0        ; calc screen modulus
	sub.b d7,d0
	add d0,d0
    WAITBLIT

	move.l d0,BLTAMOD(a6)       ; write to A & D
	swap d0
	move.l d0,BLTCMOD(a6)       ; modulus C & B
;.sameSize
	move bobDrawBLTCON0(a5),d0
	move d0,BLTCON0(a6)
	and.w d3,d0
	move.w d0,BLTCON1(a6)

	movem.l bobDrawBLTPT(a5),d0-d2

	move.l d0,d6
	lea bobDrawListEntrySize(a5),a5
	add.l a2,d6
	move.l d6,(a3)+; bobRestoreListSource; save mainplane source address for clearing code
	add.l a1,d0
	move.l d0,(a3)+; bobRestoreListTarget - save mainplane target address for clearing code

    move d7,(a3)+	;bobRestoreListBlitSize
	bmi.b .noRestore
.skipRestore
	move.l d0,d6
	movem.l d0-d2/d6,BLTCPTH(a6)    ; feed blitter with memory pointers C=D=target,
	move d7,BLTSIZE(a6)
	bra .blitDrawLoop
.bobDrawQuit
	clr.l (a3)	; mark end of blitter restore list

	lea blitterManagerFinishedF(pc),a0; set blitter frame finished
	st.b (a0)
    rts
.noRestore
	bclr #15,d7
	suba #10,a3
	bra.b .skipRestore

;!!!: Flags need reset for new game!
;drawManagerIntActionF
;	dc.b	0
blitterManagerFinishedF
    dc.b	0
blitterManagerLaunchF
	dc.b 	0
blitterManagerBlankF
	dc.b	0
;blitterManagerUnused
;	dc.b	0
softIntFinishedF
	dc.b	0
	even


    ; #MARK: - viewPosition AND FRAMECOMPARE VARS

viewPosition
	blk.l 5,0	;2.longword = scrolldirection 3.word = y-pointer, 3.w store
	RSRESET
viewPositionScrollspeed	rs.l 	1
viewPositionAdd			rs.l	1
viewPositionPointer		rs.l	1
viewPositionPointerOld	rs.l	1
viewPositionAddObjAccX	rs.w	1



	; #MARK:  - Key Game Vars

gameStatus
    dc.b 0
loadedLevelStatus
	dc.b 0
gameStatusLevel
	dc.w 0
gameInActionF	; bit0=runIntcodeFlag; bit1=pauseModeFlag
    dc.b 0
gameDiff
	dc.b	0
    even



	; #MARK:  - MIXED VARS

forceQuitFlag
    dc.b    0
forceExit
    dc.b    0


escalateIsActive
	dc.b 	0
introLaunched
	dc.b	0
dialogueActive
	dc.b	0
    even



			; MARK:  - OBJECT COUNTERS
vars
objCount
	dc.w 0
spriteCount	; 1.w = static counter,2.w temp counter
    dc.w    0,0
shotCount
    dc.w    0
bobCountHitable
    dc.w    0


tempVar             blk.l 10,0          ; flexible use for temp value store

			; MARK:  - OBEJCT DEFS

objectDefsSize      dc.l    0
objectDefsAmount        dc.w    0
animDefsSize        dc.l    0
animDefsAmount          dc.w    0



	; #MARK: - MEMORY POINTERS BEGINS
	cnop 0,4	; align on quad adress
mP
memoryPointers
    IFEQ RELEASE
memorySum		dc.l 0
memoryCount     dc.l 0
memoryChunks
            blk.l 200,0
    ENDIF

artworkBitplane                 ; share memory
mainPlanes        dc.l    0,0,0,0  ; offset needed for memory restore in _exit
mainPlanesPointer    dc.l 0,0,0
mainPlanesPointerAsync    dc.l    0,0
mainPlaneOneSize    dc.l    0
mainPlaneAllSize    dc.l    0
bckplanePointer     dc.l    0,0,0,0
copperGame			dc.l	0
copperGameJmp		dc.l	0	; filled in runtime -> points to end of game copperlist
diskBuffer          dc.l 0,0
diskBufferSize      dc.l    0
tileSource          dc.l    0
tilemapConverted    dc.l    0
tilemapBckConverted dc.l    0
escalationBitmap    dc.l    0
artworkPalette                  ; share memory
bobSource           dc.l    0,0
objectList   dc.l    0,0
bobDrawList         blk.l    3,0
bobRestoreList      blk.l    3,0
collidingList       dc.l    0,0,0
spriteDMAMem        dc.l    0,0,0,0
copSpriteLists      blk.l 10,0
copBplLists         dc.l 0,0
copLineList         dc.l 0,0
copLinePrecalc    dc.l 0
colorFadeTable      dc.l 0
spritePosMem        dc.l    0
spritePosFirst      dc.l    0
spriteParallaxBuffer    dc.l 0,0
spriteParMultiTable dc.l 0
launchTable         dc.l    0
launchTableBuffer   dc.l    0,0
objectDefs          dc.l    0
animTable           dc.l    0
animDefs            dc.l    0
audioWavTable       dc.l    0
;fib_tilePixelFingerprint	dc.l 	0
tempBuffer
    dc.l    0

tempMemoryPointersXML
    dc.l    0,0
tempStoreXML
    dc.l    0
tempBufferAnimPointers
    dc.l    0
    ; Coplist pointers
escalateEntry		dc.l	0
escalateExit		dc.l	0
gameFinEntry		dc.l	0
lowerScoreEntry		dc.l 	0
l4videoPrio			dc.l 	0
copColSprite		dc.l	0
copPriority			dc.l	0
copSpriteScroll		blk.l 3,0
; coplist pointers cleared in rasterlist code, dependent on memorypointersEnd
memoryPointersEnd
animTriggers		dc.l 0
launchTableEntryLength  dc.l    0
launchTableNoOfEntrys  dc.l    0
launchTableBufferSize
    dc.l 0

    ; #MARK: MEMORY POINTERS END

    ; #MARK: - frameCountERS

frameCount
	dc.w 0	; refresh rate counter
	dc.w 0	; total no of frames
	dc.w 0	; store refresh rate
frameCompare    ; 0.w = target framerate, 1.w = actual framerate
    dc.w    0,0

; #MARK: COPPER IRQ
copperInt
	SAVEREGISTERS
	READJOYSTICK	; using this instead of readjoypad in softInt, since that was slow and caused strange behaviour - code stalls
	lea plyBase+plyJoyCode(pc),a0
	move.w (a0),2(a0); save old status
	move.w d0,(a0)

	;#!!!: Delete softintfinished everywhere?
	lea softIntFinishedF(pc),a0
	sf.b (a0)
	lea	SoftIntServer(pc),a1
	CALLDOS Cause	; init software interrupt, handle down further code handling without blocking vbi and coper interrupt chain
.skipIntCall
	moveq #0,d0
	RESTOREREGISTERS
	rts
	IFEQ RELEASE
.skipFrame
	ALERTSETLINE 10
	ALERT alertFrameSkip,d0
	bra .skipIntCall
	ENDIF
; #MARK: SOFT IRQ

softInt		; interrupt with lowest prio, but higher than mainloop
	SAVEREGISTERS

	tst.b gameInActionF(pc)
	beq quitSoftInt
irqScrMng
	lea viewPosition(pc),a3
	move.w ((scrMngOffset).w,pc),d0
jmpSrcMngOffset
	jmp (pc,d0.w)
irqRetScreenManager

	bsr plyManager

	bra spriteManagerPlayer
sprManPlyReturn

.s1
	bsr rasterListMove
;irqRetRasLisMove
	;RASTER $0

	cmpi.w #1,frameCompare(pc)
	bge.b slowedDown

	bra objectMoveManager
irqDidObjMoveManager
slowedDown
;.ras	cmpi.b #$55,$dff006
;	bne.b .ras
	bsr objectListManager

	tst.b blitterManagerFinishedF(pc)
	beq.b .blitListUpdate; if blitter has not yet finished drawing,  keep old blitter draw list
;	if blitter has finished drawing: buffer -> active
	lea bobDrawList(pc),a5
    movem.l (a5),d0-d1
	exg.l d0,d1
    movem.l d0-d1,(a5)      ; swap drawing queue lists

	lea blitterManagerLaunchF(pc),a0
	st.b (a0); active list now ready for drawing
.blitListUpdate

;	lea blitterManagerFinishedF(pc),a0
;	sf.b (a0)
	bra collisionManager
irqDidColManager
	bra particleManager
irqDidParticleManager

	move.w ((sprMngOffset).w,pc),d0
jmpSprMngOffset
	jsr (pc,d0.w)	;spritemanager

	tst.w plyPos+plyCollided(pc)
	bne.b irqNoMoreLaunches
  	bra launchManager
irqNoMoreLaunches


.noMovement
.skipGamecode
;	lea drawManagerIntActionF(pc),a0
;	sf.b (a0)	; clear int-in-progress-flag
quitSoftInt
	lea softIntFinishedF(pc),a0
	st.b (a0)
	moveq #0,d0			; set z-flag -> OS handles further interrupt reqs
	RESTOREREGISTERS	; does not affect flags
	rts


; #MARK: levelspecific jmps
jmpParallax	=	*
sprInitOffset
scrMngOffset	= *+2
	dc.w 	0,0
sprMngOffset
	dc.w 	0

; #MARK: VERTICAL BLANK IRQ
vertBlancInt
	SAVEREGISTERS


	lea frameCount(pc),a0
	addq #1,(a0)
	addq #1,4(a0)

    tst.w plyPos+plyCollided(pc)
    bne .playerDies    ; if player dies, handle framerate(copperIRQ)
.playerLives                  ; do some score stuff
    tst.w scoreMultiplier(pc)     ; countdown scoremultiplier?
    beq.b .1
    subq.w #1,scoreMultiplier      ;  yes
    beq .pitchreset                      ; not worthy hit for some time?
.1
	;addq #1,frameCount+2
    tst.b irqColorFlag(pc)      ; make sure copper doesnt change AGA color pointers, temp. switch to safe copperlist
    bne.b .saveColorRegs
    tst.w transitionFlag(pc)
    bne.w .transition
.vbiQuit
	moveq #0,d0		; z-flag needs to be clear on vbi / OS convention
	RESTOREREGISTERS
	rts
.playerDies
    sub.w #1,frameCompare    ; handle framerate
    bpl .playerLives
    move frameCompare+2,frameCompare
    bra .playerLives
.saveColorRegs
    bmi .restore
.kill	; init´ by macro safecopper
    ;move copGameJmpL,irqCopJmp+2
    ;move copGameJmpH,irqCopJmp
    move.l #copGameDefault,d0
    move d0,copGameJmpL
    swap d0
    move d0,copGameJmpH
    sf.b irqColorFlag
	;move.l (sp)+,d0
	;move.w #2^5,$dff09c
    bra .vbiQuit
.restore	; init´ by macro restorecopper
    move.l irqCopJmp(pc),d0
    move d0,copGameJmpL
    swap d0
    move d0,copGameJmpH
    sf.b irqColorFlag
    bra .vbiQuit

.pitchreset
	lea plyPos(pc),a0
	tst.w plyCollided(a0)
	bne.b .skipFX
    tst.b plyExitReached(a0)
    bne.b .skipFX	; play FX only if player in action
	lea scoreMultiplier+2(pc),a0
	tst.b (a0)
	beq.b .skipFX
	PLAYFX 19
.skipFX
    lea updateStatDispExtra(pc),a0
    st.b (a0)
    tst.w scoreHighSuccessFlag(pc)  ; had highscore?
    beq.b .restoreHighMsg
    tst 2+scoreMultiplier(pc) ; yes
    beq.b .newHigh      ; only blink high msg if multiplier was displayed, otherwise old msg will still be there
    moveq #16,d4
    lea newHighscorePixels,a0
	move.l spriteScoreBuffer(pc),a1
	lea 16(a1),a1
    moveq #spriteScoreHeight-2,d7
.drawHighMsg
    movem.l (a0)+,d1-d4
    movem.l d1-d4,(a1)                  ; draw New High msg to sprite
	lea 16(a1),a1
    dbra d7,.drawHighMsg
    bra.b .newHigh
.restoreHighMsg             ; restore go 4 or highdelta msg
    lea fontNumbers,a0
    lea fontNumbersShdw(a0),a2
	jsr drawHighscore
.newHigh
    move.b #$7f,8*8+1+fxTable    ; reset pitch hit fx
    clr scoreMultiplier+2    ; reset score multiplier
	bra .1
.transition
	lea transitionFlag(pc),a0
	clr.l d1
	tst.w (a0)
	bpl .fadeIn
	move.w #transitionOut-$1c,d0	; fade out
    sub.w (a0),d0
	bra.b .cntDwnFade
.fadeIn
    move.w (a0),d0
    sub #30,d0
.cntDwnFade	sub.w #4,(a0)
    bvc.b .gamePaused
    clr.w (a0)	; fade finished
.gamePaused
	;lea $dff000,a6
	add.w #$b2,d0
	move.l d0,d1
	andi #$ff,d0
	or.w #displayWindowStart<<8,d0
	lsr.l #3,d1
	andi #$20,d1
	or #$3900,d1

	move.w d0,COPDIWSTRT+2
	move.w d1,COPDIWHIGH+2
.quit
    bra .vbiQuit

irqCopJmp
    dc.l 0
transitionFlag
	dc.w 0
transitionIn=$120
transitionDone=$4
transitionOut=$8000!transitionIn
irqColorFlag
    dc.b 0
	even


; #MARK: - RASTERLIST MANAGER BEGINS
rastListMover ;0.b = index, 1.b = scaler
	dc.b 	0,0
rasterListTitle:
	lea rastListMover(pc),a6
	clr.w d6
	move.b (a6),d6
	lsr #1,d6
	move.l copLineList(pc),a1
	move.l (a1)+,a2 ; get adress of current subcoplist -> pointer to BPLCON1
	lea -8(a2),a4    ; pointer to BPLMOD
	lea coplineAnimPointers,a6
	andi #$7f,d6
    move.l (a6,d6*4),a5; get adress of anim table list

	move.l 4(a5),d5;; get first modulus
	move.w (a1)+,d0
	move d5,(a4,d0)
	lea 8(a5),a5
    move copBPLCON1+2,d2    ; get value calc´d by basic scroll code
	andi #$0f0f,d2
	swap d5
	or d2,d5

	move d5,(a2,d0)
	move.w #$7a,d7; no of scanlines/2
	lsr #1,d7
	subq #2,d7
.writeCopLine
	movem.l (a5)+,d3-d4
	movem.w (a1)+,d0-d1
	move d3,(a4,d0)     ; write to BPLxMOD
	swap d3
	or d2,d3
	move d3,(a2,d0)     ; write to BPL1CON
	move d4,(a4,d1)
	swap d4
	or d2,d4
	move d4,(a2,d1)
    dbra d7,.writeCopLine
nilManager	; label needed in case of skipping subcode from irq code. Could use any rts
	rts


rasterListMove:

	lea rastListMover(pc),a6
	move.w (a6),d6

	move.w d6,d5
	lsr #6,d6
rasterListSkip
	lea copLineList(pc),a2

	move.l (a2)+,a1		; pointer to offset table
	move.w (a2),d7		; no of lines
    beq.b nilManager

	move.l (a1)+,a2 ; get adress of current subcoplist -> pointer to BPLCON1
	lea -8(a2),a4    ; pointer to BPLMOD
	lea coplineAnimPointers,a6

	lsr.w d5,d6;modify anim speed
	andi #$7f,d6
    move.l (a6,d6*4),a5; get adress of anim table list
    move.l 4(a5),d5 ; get first modulus
	move.w (a1)+,d0
	move d5,(a4,d0)
	lea 8(a5),a5
    move copBPLCON1+2,d2    ; get value calc´d by basic scroll code

	andi #$0f0f,d2
	swap d5
	or d2,d5

	move d5,(a2,d0)
	tst.b escalateIsActive(pc)
	bne .escalateMode
	tst.b plyPos+plyDistortionMode(pc)
	bne.b .distortionMode
;    move.w copLineList+4(pc),d7 ; how many lines in current copsublist?
    ;#FIXME: switch to indirect adressing
;    beq irqRetRasLisMove
	;move d7,d6
	lsr #2,d7
	subq #1,d7
.writeCopLine
	movem.l (a1)+,d0/d1
	movem.l (a5)+,d3/d4/d5/d6
	move d4,(a4,d0)     ; write to BPLxMOD
	swap d4
	or d2,d4
	move d4,(a2,d0)     ; write to BPL1CON

	swap d0
	move d3,(a4,d0)
	swap d3
	or d2,d3
	move d3,(a2,d0)

	move d6,(a4,d1)
	swap d6
	or d2,d6
	move d6,(a2,d1)

	swap d1
	move d5,(a4,d1)
	swap d5
	or d2,d5
	move d5,(a2,d1)

    dbra d7,.writeCopLine
	bra .quit
.distortionMode         ; shake screen a bit
    move.w copLineList+4(pc),d7
    subq #2,d7
    clr.w d3
	move.b plyPos+plyDistortionMode(pc),d3
	lsr #3,d3
    move d3,d6
    lsl #4,d6
    or d6,d3
	moveq #4,d6
	;lea $dff007,a3
	;lea $bfd800,a3
	lea $bfe601,a3
.writeCopDistortion
    move.l (a5)+,d4
    move d4,d5
    move.w (a1)+,d0
    swap d4
    move d5,(a4,d0)     ; write to BPLxMOD
    or d2,d4
	move.b (a3),d1
	;move.b (a4),d1
    move d1,d5
    andi #$0f,d5
    lsr #1,d5
.wait
    ;dbra d5,.wait

	ror d6,d1
    move.b d1,d5
    lsl d6,d5
    or d5,d1
	and d3,d1
	eor.b d1,d2
    move.w d4,(a2,d0)     ; write to BPL1CON
    dbra d7,.writeCopDistortion
.quit
	rts
														; split view
.escalateMode

    moveq #((escalateStart-displayWindowStart)/2)-1,d1
	moveq #$18,d7
    move.l -4(a5),d3
	;moveq #$18,d1
.writeTop
    move.l (a5)+,d4
    move d4,d5
    move.w (a1)+,d0
    swap d4
    move d5,(a4,d0)     ; write to BPLxMOD
    move d5,d6
    sub.w d7,d6
    add.w d6,d3
    or d2,d4
    move d4,(a2,d0)     ; write to BPL1CON
    dbra d1,.writeTop

	;subq #3,d1
	moveq #(escalateHeight/2)-3,d1

    move #$ffd8,d6
    move d2,d4
    or #$e020,d4
.writeCenter
    move.l (a5)+,d5
    sub.w d7,d5
	add.w d5,d3

    move.w (a1)+,d0
    move d6,(a4,d0)     ; write to BPLxMOD
    move d4,(a2,d0)     ; write to BPL1CON
    dbra d1,.writeCenter

	;clr.w d5
    ;btst #0,frameCount+3     ; add some imterlace to soften hard pixels
    ;beq .lacer
    ;moveq #bckplaneWidth,d0
    ;add.w d0,d5
.lacer
	add.w #(bckPlaneWidth*1)-$0c,d3	; modify modulus for correct display
	;add.w d5,d3	; add interlace
    move.w (a1)+,d0

    move d3,(a4,d0)     ; write to BPLxMOD
    move.w (a5),d4
    or d2,d4
    move d4,(a2,d0)     ; write to BPL1CON
    ;rts
    move.w copLineList+4(pc),d1 ; how many lines in current copsublist?
	;sub.w #(escalateHeight/2),d1
	sub.w #(((escalateStart-displayWindowStart)/2)-1)+(escalateHeight/2)+2,d1
.writeBottom
    move.l (a5)+,d4
    move d4,d5
    move.w (a1)+,d0
    swap d4
    ;move.w #$18,d5
    move d5,(a4,d0)     ; write to BPLxMOD
    or d2,d4
    move d4,(a2,d0)     ; write to BPL1CON
    dbra d1,.writeBottom
	rts

; #MARK: build raster list

rasterListBuild:          ; generate pointers to BPLCON1 in current copsublist. Called by macro COPPERSUBLIST
    lea escalateEntry(pc),a0
    moveq #(memoryPointersEnd-escalateEntry)/4-1,d7
.resetPointers
	clr.l (a0)+
	dbra d7,.resetPointers

	lea tempVar(pc),a4
	lea sprParColPointers(pc),a5
	move.l a5,(a4)
	move.w #((sprParColPointersEnd-sprParColPointers)/2)-1,d7
.resetParCols
	clr.w (a5)+
	dbra d7,.resetParCols

	;cc1
	;QUITPROGRAM
	move.l #tempVar+20,copColSprite	; preload with harmless dummy value, in case no working entry is found

    move.l copperGame(pc),a0
	lea gameStatusLevel(pc),a1	; preps - which kind of parallax anim?
	tst.w (a1)
	bpl.b .titleCop
    lea copTitle,a0
.titleCop
    move.l copLineList(pc),a1
    move.l a0,(a1)+     ; store address of current coplist, pointers to all BPLCON1-regs behind
    clr.l d0
    clr.l d1
.iterate
    addq.w #4,d0
	move.l (a0,d0),d6
	move.l d6,d7
	swap d6
    cmpi.w #COPJMP1,d6  ; reached end of subcoplist
    beq.w .finish
    cmpi.w #BPL7DAT,d6  ; find entries to color marker
    beq.w .colorMarker
	cmpi.l #(BPLCON3<<16)+BRDRBLNKF,d7  ; find entries to sprite parallax color marker
    beq .sprParallaxCols
	cmpi.l #(BPLCON3<<16)!(PF2OF2F!BRDRBLNKF!SPRES0F),d7  ; same here for level 2
	beq .sprParallaxCols
	cmpi.l #(NOOP<<16)+1,d7  ; find entries to escalate view
	beq .escalateEntry
	cmpi.l #(NOOP<<16)+2,d7  ; find escalate exit
	beq .escalateExit
	cmpi.l #(NOOP<<16)+3,d7  ; find entries to gameFin view
	beq.b .gameFinEntry
	cmpi.l #(NOOP<<16)+4,d7  ; find reentry after gameFin view
	beq .gameFinReturn
	cmpi.l #(NOOP<<16)+5,d7  ; find videopriority switch (level 4)
	beq.b .videoPrioSwitch
	cmpi.l #(NOOP<<16)+7,d7  ; find lower Score entry
	beq.b .lowerScoreEntry
	cmpi.w #SPR6CTL,d6  ; find sprite scroll alt entry
	beq.b .spriteScroll
.findScrollReg
    cmpi.w #BPLCON1,d6  ; find entrys with scrolling regs
    bne.b .iterate
    
    move.w #$18,-6(a0,d0)	; reset playfield B modulus
    move d0,d2
    addq #2,d2
    move.w d2,(a1)+     ; write pointer
    addq #1,d1
    bra.b .iterate
.lowerScoreEntry
	lea (a0,d0.w),a2
	move.l a2,lowerScoreEntry
	bra .iterate
.spriteScroll
    lea (a0,d0.w),a2
	lea copSpriteScroll(pc),a6
.findSlot	tst.l (a6)+
	bne.b .findSlot
	move.l a2,-4(a6)
	bra .iterate
.videoPrioSwitch
	lea 6(a0,d0.w),a2
	move.l a2,l4videoPrio
	bra .iterate
.gameFinEntry
    lea (a0,d0.w),a2
    move.l a2,gameFinEntry
    move.l #copGameFin,d2
    move d2,10(a0,d0)
    swap d2
    move d2,6(a0,d0)
    move #NOOP,12(a0,d0); overwrite copJmp trigger
    bra	.iterate
.gameFinReturn
    lea (a0,d0.w),a2
    move.l a2,d2
    lea copGameFinQuit,a2
    move.w d2,6(a2)
    swap d2
    move.w d2,2(a2)	; set return adress to main coplist in gamefin subcoplist
    bra .iterate
.escalateEntry
    lea (a0,d0.w),a2
    move.l a2,escalateEntry
    move.l #copGameEscalate,d2
    move d2,10(a0,d0)
    swap d2
    move d2,6(a0,d0)
    move #NOOP,12(a0,d0); overwrite copJmp trigger

    lea 16(a0,d0.w),a2
    move.l a2,d2
    lea copInitEscalateEnd,a2
    move.w d2,6(a2)
    swap d2
    move.w d2,2(a2)

    sf.b escalateIsActive
    add.w #16,d0
    bra .iterate
.escalateExit
    lea (a0,d0.w),a2
    move.l a2,escalateExit
    move.l #copGameEscalateExit,d2
    move d2,10(a0,d0)
    swap d2
    move d2,6(a0,d0)
    move #NOOP,12(a0,d0); overwrite copJmp trigger

	swap d2
	lea copWaitEscalateEnd,a2
    move.w d2,6(a2)
    swap d2
    move.w d2,2(a2)

    lea 16(a0,d0.w),a2
    move.l a2,d2
    lea copExitEscalateEnd,a2
    move.w d2,6(a2)
    swap d2
    move.w d2,2(a2)

    add.w #16,d0
    bra.w .iterate
.colorMarker
    lea 10(a0,d0.w),a2
	move.l a2,copColSprite
	lea 4(a2),a2
	move.l a2,copPriority
    bra.w .iterate
.sprParallaxCols
	lea tempVar(pc),a5
	move.l (a5),a2
	move.w d0,(a2)+
	moveq #2,d2
	add.l d2,(a5)
    bra.w .iterate
.finish
    clr.l (a1)+
	;cc2
	;QUITPROGRAM

	move.w #$18,d5
    move d1,copLineList+4       ; number of BPLCON1-regs in subcoplist
	lea gameStatusLevel(pc),a0	; preps - which kind of parallax anim?
	move.w (a0),d0
	bpl.b .titleCheck
	clr.w d0
.titleCheck
	lea rasListPrepJmpTbl(pc),a0
	move.w (a0,d0*2),d6		; fetch anim precalc jump offset

	;cc3
;	QUITPROGRAM

	move.l copperGame(pc),a1
	;!!!: Line above inserted @ 68060check. Caused crashed
    move.l (a1)+,a2 ; get adress of current subcoplist -> pointer to BPLCON1
    ;lea 4(a2),a4    ; pointer to BPLMOD
    suba.l a4,a4
    lea coplineAnimPointers,a6

	moveq #8,d2		; start value for 2nd scanline mod modifier
D7RASYCOUNT		EQUR	d7
D1frameCount	EQUR	d1

    move.l (a6),a0 ; get adress of anim buffer
    moveq #noOfCoplineAnims-1,D1frameCount     ; build data for x anim frames
buildRasListFrame
	moveq #noOfCoplines-1,D7RASYCOUNT       ; build data for x coplines
    move.l (a6)+,a0 ; get adress of anim buffer
	move.w #2,a5
    moveq #$18,d0        ; preload basic modulus
buildRasList
	jmp (pc,d6.w)			; precalc PF2Hx and modulus for one frame
buildRasListMod
	move d5,2(a0)           ; prestore BPLxMOD
	adda #4,a0
	dbra d7,buildRasList
	dbra d1,buildRasListFrame
	rts

rasListPrepJmpTbl	; precalc list offsets
	dc.w	preStoreSinewave-buildRasList
	dc.w	preStoreSun-buildRasList
	dc.w	preStoreSky-buildRasList
	dc.w	preStoreOcean-buildRasList
	dc.w	preStoreCity-buildRasList
	dc.w	preStoreSpace-buildRasList

preStoreSky
	move.w #noOfCoplines*2-1,d3
	sub.w D7RASYCOUNT,d3
	move D1frameCount,d4
	lsl #1,d4
	muls d4,d3
	divu #noOfCoplines*2+4,d3
	andi #$7f,d3

	move d3,d4
	move d4,d5
    andi #$0010,d5
    ror.w #6,d5
    andi #$f,d4
	;clr.w d4
	lsl #4,d4
	or d4,d5
	;clr.w d5
    move d5,(a0)		; prestore BPL1CON

	move d3,d4
	add.w #8,d4
	lsr #3,d4		; kill lower 32 pixels
	andi #%111100,d4
	moveq #$18,d5
	add.w d4,d5
	cmp.w d5,d0
	beq.b .same
	bhi.b .isHigher
	move d5,d0
	moveq #$14,d5
	bra.b .write
.isHigher
	move d5,d0
	bra.b .write
.same
	moveq #$18,d5
.write
	tst.w a5
	beq buildRasListMod	; modify first scanline modulus for correct appearance
			; first scanline, modify modulus
	move.w (a0),4(a0)	; copy softscroll value
	lea 4(a0),a0
	moveq #$8,d5
	sub.l a5,a5	; first scanline done
	sub d4,d5
	bra buildRasListMod

preStoreCity
	move D1frameCount,d4
	;lsl #1,d4
	andi #$7f,d4
	lea .sinCity(pc),a3
	move.w D7RASYCOUNT,d3
	andi #$7f,d3
	move.b (a3,d3),d3
	muls d4,d3
	lsr #7,d3
	andi #$7f,d3
	sub #4,d3
	bra prestorePerp

; table created within ASMone from command line, IS<Return> 45 136 128 127 b1 yy
.sinCity
	;DC.B	$5A,$5B,$5D,$5E,$5F,
	;blk.b 5,$5f
	DC.B	 $5f,$5f,$5f,$5f,$5f,$60,$61,$62,$63,$64,$65,$66,$67,$68,$68,$69
	DC.B	$6A,$6B,$6C,$6D,$6E,$6E,$6F,$70,$71,$71,$72,$73,$73,$74,$75,$75
	DC.B	$76,$76,$77,$78,$78,$79,$79,$7A,$7A,$7A,$7B,$7B,$7C,$7C,$7C,$7D
	DC.B	$7D,$7D,$7D,$7E,$7E,$7E,$7E,$7E,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F
	DC.B	$7F,$7F,$7F,$7F,$7F,$7F,$7E,$7E,$7E,$7E,$7E,$7E,$7D,$7D,$7D,$7C
	DC.B	$7C,$7C,$7B,$7B,$7B,$7A,$7A,$79,$79,$78,$78,$77,$77,$76,$76,$75
	DC.B	$74,$74,$73,$72,$72,$71,$70,$70,$6F,$6E,$6D,$6C,$6C,$6B,$6A,$69
	DC.B	$68,$67,$66,$65,$64,$63,$62,$61,$60,$5F,$5E,$5D,$5C,$5B,$5A,$59

	even
preStoreOcean
	move D1frameCount,d4
	move.w #81,d3
	sub.w D7RASYCOUNT,d3
	bpl.b .sk1
	clr.w d3
.sk1
	muls d4,d3
	divu #86,d3
	andi #$7f,d3

	move d3,d4
	move d4,d5
    andi #$0008,d5
    ror.w #5,d5
    andi #$7,d4
	;clr.w d4
	lsl #5,d4
	or d4,d5

	; add watery effect
    move d5,(a0)		; prestore BPL1CON
	move d1,d5
	move d7,d4
	not d4
	andi #$1f,d4
	andi #$1f,d5
	cmp d5,d4
	bne.b preStorePerpB
	move d7,d4
	lsr #6,d4
	addq #1,d4
	or d4,(a0)
	bra.b preStorePerpB

preStoreSun
	move D1frameCount,d4
	move.w #143,d3
	sub.w D7RASYCOUNT,d3
	bpl.b .sk1
	clr.w d3
.sk1
	muls d4,d3
    lea sineTable(pc),a3
	move.b (a3,d3),d5
	lsr #1,d5
	add.w d5,d3		; add blur
	divu #155,d3
	andi #$7f,d3
	bra.b preStorePerp
preStoreSpace
	move D7RASYCOUNT,d3
	move D1frameCount,d4
	;lsl #1,d4
	muls d4,d3
	lsr #7,d3
	andi #$7f,d3
preStorePerp
	move d3,d4	;
	move d4,d5
    andi #$0008,d5
    ror.w #5,d5
    andi #$7,d4
	;clr.w d4
	lsl #5,d4
	or d4,d5
    move d5,(a0)		; prestore BPL1CON
preStorePerpB
	move d3,d4
	add.w #4,d4
	asr #4,d4		; kill lower 32 pixels
	andi #%111,d4
	lsl #2,d4
	move d4,d5
	add #$18,d5
	cmp d5,d0
	beq.b .same
	bge.b .isHigher
	move d5,d0
	move #$14,d5
	bra.b .write
.isHigher
	move d5,d0
	move #$1c,d5
	bra.b .write
.same
	move.w #$18,d5
.write
	tst.w a5
	beq buildRasListMod	; modify first scanline modulus for correct appearance
	move.w (a0),4(a0)	; copy softscroll value
	lea 4(a0),a0
	moveq #$8,d5
	sub.l a5,a5	; first scanline done
	sub d4,d5
	bra buildRasListMod

preStoreSinewave
	move d7,d4
	add d1,d4
	andi.w #$7f,d4

	;cc4
	;QUITPROGRAM

	;FIXME: Move LEA to init code to save cpu time?
	lea sineTable(pc),a3
    clr.w d3
	move.b (a3,d4.w),d3              ; add sinus form
    ;lsl #1,d3            ; multiplicator for amplitude
    move d3,d4
    move d3,d5
    ;move d3,d2
    addq #$8,d5
    andi #$0010,d3
    ror.w #6,d3
    andi #$f,d4

    lsl #4,d4
    or d4,d3
    move d3,(a0)		; prestore BPL1CON
    not d5
    andi #%11100000,d5
    lsr.w #3,d5

    move d0,d3
    cmp d5,d3
    beq .keepMod
    cmp d5,d3
    bge.b .ss1
    move d5,d0
    move #$1c,d5
    bra.b .safeMod
.ss1
    move d5,d0
	move.w #$14,d5
    bra.b .safeMod
.keepMod
	move.w #$18,d5
.safeMod
	tst.w a5
	bne .firstLines
	bra buildRasListMod

.firstLines	; keep first scanline, modify modulus on second
	sub #1,a5
	tst.w a5
	beq .secondRas
	bra buildRasListMod
.secondRas
	cmpi #$18,d5
	beq.s .l3
	tst.b (a4)
	bne.b .l5
	cmpi.w #$1c,d5
	bne.s .l4
	move d2,d5		; add to modulus
	addq #4,d5
    st.b (a4)
    bra.s .l6
.l4			; lower modulus
    move d2,d5
    sub #4,d5
    st.b (a4)
	;move.w #$14,d5
    bra.s .l6
.l3
	sf.b (a4)
.l5
	move d2,d5
.l6
	move d5,d2
.safeMod2
	bra buildRasListMod


sineTable   ; 128 values, maxAmp=128, 1 oscillation, generated http://www.daycounter.com/Calculators/Sine-Generator-Calculator.phtml
    dc.b 64,67,70,73,76,79,82,85,88,91,93,96,99,101,104,106,108,111,113,115,116,118,120,121,122,123,124,125,126,126,127,127,127,127,127,126,126,125,124,123,122,121,120,118,116,115,113,111,108,106,104,101,99,96,93,91,88,85,82,79,76,73,70,67
    dc.b 64,60,57,54,51,48,45,42,39,36,34,31,28,26,23,21,19,16,14,12,11,9,7,6,5,4,3,2,1,1,0,0,0,0,0,1,1,2,3,4,5,6,7,9,11,12,14,16,19,21,23,26,28,31,34,36,39,42,45,48,51,54,57,60

; #MARK: RASTERLIST MANAGER ENDS




; #MARK: - PARTICLE MANAGER BEGINS
particleManager
	;bra irqDidParticleManager
    move.w particleCount(pc),d7
    beq irqDidParticleManager
.clear

	lea particleClear(pc),a6
    movem.l particleDrawBase(pc),a4-a5
    lea mainPlaneWidth*mainPlaneDepth(a4),a1
    lea mainPlaneWidth*mainPlaneDepth(a5),a2
    clr.l d4
.clrLoop
	move (a6)+,d4
	beq.b .allCleared
	move.b (a4,d4.l),(a5,d4.l)
	move.b (a1,d4.l),(a2,d4.l)
	bra.b .clrLoop
.allCleared
;	clr.w (a3)
.draw
    lea bobAdrTable(pc),a0
    lea particleBits(pc),a1
    lea particleBitmapOffset(pc),a2
    lea particleDrawBase(pc),a3
    move.l mainPlanes+4(pc),a5
    move.l mainPlanes+8(pc),a4

    move.l a4,(a3)
    move.l a5,4(a3)
    lea mainPlaneWidth*mainPlaneDepth(a5),a4
	lea particleClear(pc),a3
    lea particleTable-partEntrySize(pc),a6

	clr.l d5
	clr.l d4
	clr.l d1
    clr.l d2
    clr.w d3
    moveq #7,d0
    moveq #partEntrySize,d6
    bra.w .loop
.next
    add.l d6,a6
    move.w (a6),d1      ; load x-Position
    beq.b .next
    ;move.w #100,d1
    ;cmpi.w #20,d1
    ;blo.b .killPart
    bmi.b .killPart       ; left screen?
    move.b partLifeCntdwn(a6),d3
    sub.b d3,partLifetime(a6)    ; lifetime
    bcs.b .killPart


    move.b partYPos(a6),d3     ; y-position
    ;move.b #100,d3
    cmpi.b #252,d3
    bhi.b .killPart ; out of screen?
    lsr #3,d4
    move d1,d5
    lsr #4,d5
    lsr d0,d1
    and.w d0,d5
    move.b (a1,d5),d5       ; read particle definition
    ;st.b d5
    move.w (a0,d3*2),d2     ; y bitmap offset


    add.w d1,d2             ; add x-byte-offset

    move.b partLifetime(a6),d3
    lsr #6,d3
    add.w (a2,d3*2),d2             ; add bitplane offset
    add.w partBase(a6),d2
    move.w d2,(a3)+           ; bitmap byte restore pointer
	eor.b d5,(a5,d2.l)     ; plot top line
	eor.b d5,(a4,d2.l)     ; plot second line

	move.w partXAccl(a6),d5     ; move particle
    add.w d5,partXPos(a6)
    beq.b .killPart
    move.w partYAccl(a6),d5
    add.w d5,partYPos(a6)
.loop
    dbra d7,.next
    clr.w (a3); mark end of particle clear list
	bra irqDidParticleManager
.killPart
    clr.w (a6)        ; delete
    sub.w #1,particleCount
	;subq #1,d7
	dbra d7,.next
	clr.w (a3); mark end of particle clear list
	bra irqDidParticleManager

    ; particleTable a0, x-pos D3, y-pos D4, xacc D5, yacc d6
particleSpawn

    clr.l d0

    ;lea particleDrawBase(pc),a3
    move.l mainPlanesPointer(pc),a3
    sub.l mainPlanes(pc),a3
    ;move.l a4,8(a3)

    lea particleTable-partEntrySize(pc),a6
    move.w particleCount(pc),a4

	move.w d5,a1
	move.w d3,a2
    suba.l a5,a5
    move.w #partEntrySize,a5
.readParticle
    cmpa.w #particlesMaxNo,a4
    bge.b .noMoreParticles
    move.l (a0)+,d0
    beq.b .noMoreParticles
    move.b d0,d7
    ext.w d7		; y-acc
    lsr.l #8,d0
    move.b d0,d2
    ext.w d2		; x-acc

    move.w d0,d1
    clr.b d1        ; y-add
    swap d0
    ext.w d0
    lsl.l #4,d0  ; x-add

    add.w d0,a2
    add.w d1,d4

    add.w d2,a1
    add.w d7,d6
.findSlot
    adda.w a5,a6
    tst.w (a6)      ; particle available?
    bne.b .findSlot
	move.w a1,d5
	move.w a2,d3
	swap d3
	move d4,d3
	swap d5
	move d6,d5
	movem.l d3/d5,(a6)
    add.w #1,a4

    move.w a3,partBase(a6)

    moveq #-1,d5
    move.b (a0)+,d5

    move.w d5,partLifetime(a6)
    adda #1,a0
    bra.b .readParticle
.noMoreParticles
    move.w a4,particleCount
    rts
emitterExtraLoss
	dc.b 0,0,-1,-127,8,0
    dc.b -1,1,0,-127,12,0
    dc.b 0,-2,-3,80,9,0
    dc.b -1,-1,-5,-40,5,0
    dc.b -1,-4,-10,90,7,0
    dc.b 0,4,5,-90,9,0
    dc.b 2,4,-5,90,8,0
    dc.b 3,5,10,-70,10,0
    dc.b -3,-5,-20,-70,8,0
    dc.b 2,3,10,-90,6,0
    dc.b -2,-3,10,90,6,0
    dc.b -4,7,10,90,6,0
    dc.b 4,-7,10,90,6,0
    dc.b -1,0,-10,120,6,0
    dc.b 1,0,-10,120,6,0
    dc.b 0,-2,10,127,12,0
    dc.b 0,-2,10,-127,9,0
    dc.b 0,-2,-10,-127,3,0
    dc.l 0
emitterKillA
	dc.b 0,0,-1,-123,3,0
    dc.b -1,1,0,-123,7,0
    dc.b 0,-2,-3,84,5,0
    dc.b -1,-1,-5,-20,2,0
    dc.b -1,-4,-10,110,3,0
    dc.b 0,4,5,-70,3,0
    dc.b 2,4,-5,70,4,0
    dc.b 3,5,10,-50,5,0
    dc.b -3,-5,-20,-50,4,0
    dc.b 2,3,10,-70,3,0
    dc.b -2,-3,10,70,3,0
    dc.b -4,7,10,50,3,0
    dc.b 4,-7,10,80,3,0
    dc.b -1,0,-10,90,3,0
    dc.b 1,0,-10,80,3,0
    dc.b 0,-2,10,100,5,0
    dc.b 0,-2,10,-100,4,0
    dc.b 0,-2,-10,-127,1,0
    dc.l 0
emitterKillB
	dc.b -3,-4,-1,-100,1,0
    dc.b 0,-2,10,90,4,0
    dc.b 0,-2,10,-127,3,0
    dc.b 0,-2,-10,-127,1,0
    dc.b -1,1,0,-90,3,0
    dc.b 0,-2,-3,70,2,0
    dc.b -2,-3,10,70,2,0
    dc.b -4,7,0,60,2,0
    dc.b 4,-7,-10,63,2,0
    dc.b -1,-1,-5,-30,1,0
    dc.b 2,4,-5,50,3,0
    dc.b 3,5,10,-40,4,0
    dc.b -3,-5,-20,-40,3,0
    dc.b -1,-4,-10,60,2,0
    dc.b 0,4,5,-50,2,0
    dc.b 2,3,10,-50,2,0
    dc.b -1,0,-10,70,4,0
    dc.b 1,0,-10,70,5,0
    dc.l 0
emitterKillC
	dc.b 3,4,-1,-100,1,0
    dc.b -3,-5,-20,40,3,0
    dc.b -1,-4,-10,60,2,0
    dc.b 0,4,5,-50,2,0
    dc.b 2,4,-5,50,3,0
    dc.b 3,5,10,-70,4,0
    dc.b -1,1,0,-90,3,0
    dc.b 0,-2,-3,70,2,0
    dc.b -2,-3,10,70,2,0
    dc.b -4,7,0,60,2,0
    dc.b 4,-7,-10,63,2,0
    dc.b -1,-1,-5,-30,1,0
    dc.b 2,3,10,-50,2,0
    dc.b -1,0,-10,70,4,0
    dc.b 1,0,-10,70,5,0
    dc.b 0,-2,10,90,4,0
    dc.b 0,-2,10,-127,3,0
    dc.b 0,-2,-10,-127,1,0
    dc.l 0
emitterHitA
	dc.b 3,0,-2,-10,12,0
    dc.b -3,-1,-20,-40,14,0
    dc.b -1,-1,-10,-20,17,0
    dc.b 0,3,20,100,20,0
    dc.l 0
emitterMetShower
	dc.b -10,-10,-20,80,5,0
	dc.b 2,4,10,40,3,0
	;dc.l 0
    dc.b 3,7,-2,14,4,0
    dc.b 5,3,-10,12,7,0
    dc.b 6,5,20,100,2,0
    dc.b 3,5,10,-70,4,0
    dc.b -1,1,0,-90,3,0
    dc.b 0,-2,-3,70,4,0
    dc.b -2,-3,10,70,6,0
    dc.b -4,7,0,60,4,0
    dc.b 4,-7,-10,63,7,0
    dc.b -1,-1,-5,-30,3,0
    dc.b 2,3,10,-50,2,0
    dc.b -1,0,-10,70,1,0
    dc.b 1,0,-10,70,5,0
    dc.b 0,-2,10,90,7,0
    dc.b 0,-2,10,-127,4,0
    dc.b 0,-2,-10,-127,3,0
    dc.l 0

	RSRESET
partXPos	rs.w	1
partYPos	rs.w	1
partXAccl 	rs.w	1
partYAccl	rs.w	1
partLifetime	rs.b	1
partLifeCntdwn	rs.b	1
partBase	rs.w	1
partEntrySize	rs.w 1


particlesMaxNo=64
particleBits
    dc.b %11000000,%00100000, %00110000,%00010000, %00001100,%00000110,%00000011, %00000001
particleBitmapOffset
    dc.w mainPlaneWidth*1, mainPlaneWidth*3, mainPlaneWidth*2, mainPlaneWidth*2
particleBase
particleCount
    dc.l    0
particleDrawBase
    dc.l 0,0,0
particleClear
	blk.w particlesMaxNo+1,0
	; particleTable at end of code
particleTable
    blk.b (particlesMaxNo+1)*partEntrySize,0


; #MARK: PARTICLE MANAGER ENDS


			; MARK: - Score Vars

scoreNew    =   0
scoreAdd    =   4
scoreOld    =   8


score
    dc.l 0          ; 4 bytes in bcd-format for 8 digits
    dc.l 0          ; 4 add-bytes in bcd-format
    dc.l 0          ; old score, needed for comparison
scoreHigh
    dc.l 0
scoreHighStatus
    dc.b    0,0
scoreHighEncoded
    blk.b 12,0
scoreHighDelta
    dc.l 0
scoreAdder
    dc.w 0
spriteScoreBuffer      dc.l    0,0
scoreMultiplier ; 0.w = countdown, 2.b = score multiplier 3.b = old multiplier, 4.l pointer to hit object
    dc.l 0,0
scoreHighSuccessFlag
    dc.w 0
updateStatDispExtra
    dc.b 0
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

	lea plyBase(pc),a1
	lea plyPosRem(pc),a3
	movem.l 4(a3),d4-d5
	movem.l d4-d5,(a3)

	move.w (a1),8(a3)
	move.w 4(a1),10(a3)	; save current ply position

   	tst.b plyDistortionMode(a1)
	bne .distortionMode
.distortReturn

	; write extra sprites

	moveq #playerExtraHeight-1,d5
	cmpi.b #2,plyWeapUpgrade(a1)
	bge.b .extraPodsYes
	moveq #28,d7
	clr.w d4
	bra.b .makeCtrlWords
.extraPodsYes
	moveq #-22,d7	; offset upper pod
	add d4,d7; load Player Y-Position. d4 contains old plyPos@ x.l & y.w
	sub.w plyPos+plyPosYDyn(pc),d7
	swap d4
	sub.w viewPosition+viewPositionPointer(pc),d4
	;moveq #14,d2
	;add.w d7,d2
.makeCtrlWords
    move d5,d1
    add.w   d7,d5
    clr.b   d3
    lsl.w   #8,d7	; move vertical start bit 8 in place
    addx.b  d3,d3

    lsl.w   #8,d5	; vertical stop bit 8
    addx.b  d3,d3

    lsr.w   #1,d4	; horizontal start bit 0
    addx.b  d3,d3
    add.b #$20,d4
    move.b  d4,d7	; make first control word
    move.b  d3,d5	; second control word
    rol #5,d6		; add 35 & 70 ns pixelcoord
    andi #%11000,d6
    bset #7,d6		; attach bit
    or d6,d5

    move.w frameCount+4(pc),d0
    lsr #1,d0
    move.b AudioRythmAnimOffset(pc),d4			; sync music and player anim
    lsl #3,d4
    add.w d0,d4
    andi.w #$1f,d4

    lea ([spriteAnimTablePlayerBasic.w,pc,d4*4]),a5
    lea (spritePlayerHeight*spriteDMAWidth/4,a5),a6
    move.w d7,(a5)      ; SPRxPOS
    move.w d5,8(a5)     ; SPRxCTL
    move.w d7,(a6)      ; SPRxPOS
    move.w d5,8(a6)     ; SPRxCTL

.offset=(1+playerExtraHeight+playerBodyHeight)*spriteLineOffset
	move.w #$3500,d0
	add d0,d7	; startpos
	addx.b d0,d0	; pal bit. Use of d0 lower bits saves one clr-cmd
	add d0,d5	; stoppos
	addx.b d0,d0	; pal bit
	add.b d0,d0
	or.b d0,d5
.writeCtrlWord
    move.w d7,.offset(a5)      ; SPRxPOS
    move.w d5,.offset+8(a5)     ; SPRxCTL
    move.w d7,.offset(a6)      ; SPRxPOS
    move.w d5,.offset+8(a6)     ; SPRxCTL

	lea copSprite01,a0 ; write dma pointers to coplist
    move.l a5,d0
    move.l a6,d1
    move d0,6(a0)
    swap d0
    move d0,2(a0)
    move d1,14(a0)
    swap d1
    move d1,10(a0)

	; write main sprite

	move plyPosY(a1),d2	; player old y-position
	sub.w plyPos+plyPosYDyn(pc),d2

	move.l (a1),d4;plyPosX
	sub.l viewPosition+viewPositionPointer(pc),d4       ; load Player X-Position
    move.w d4,d6
    swap d4

    moveq #playerBodyHeight,d5
    add.w   d2,d5
    clr.b   d3
    lsl.w   #8,d2	; move vertical start bit 8 in place
    addx.b  d3,d3

    lsl.w   #8,d5	; vertical stop bit 8
    addx.b  d3,d3

    lsr.w   #1,d4	; horizontal start bit 0
    addx.b  d3,d3
    add.b #$20,d4
    move.b  d4,d2	; make first control word
    move.b  d3,d5	; second control word
    rol #5,d6		; add 35 & 70 ns pixelcoord
    andi #%11000,d6
    bset #7,d6		; attach bit
    or d6,d5

    move.w d2,playerExtraHeight*spriteLineOffset(a5)      ; SPRxPOS
    move.w d5,(playerExtraHeight*spriteLineOffset)+8(a5)     ; SPRxCTL
    move.w d2,playerExtraHeight*spriteLineOffset(a6)      ; SPRxPOS
    move.w d5,(playerExtraHeight*spriteLineOffset)+8(a6)     ; SPRxCTL
	bra sprManPlyReturn

.distortionMode
    clr.w d5        ; add some shake to player sprite
    move.b plyDistortionMode(a1),d5
    lsr #3,d5
    clr.w d1
    move.b $bfe601,d1
   	;move.b $dff007,d1
    and d5,d1
    eor.b d1,d4
	bra .distortReturn

;	#MARK: general sprite code
spriteManager
    ;clr$dff000+BPLCON3
    ;move #$f00,$dff180

    clr.l d0
    clr.l d1
    clr.l d2
    clr.l d3

    lea CUSTOM,a6
    lea spriteWriteLastYPos(pc),a0; clear for sprites 2-5 -> not 0,1,6,7 -> not part of multiplexing code
    movem.l d0-d3,(a0)

	lea copSpriteLists(pc),a0
	add.w #1,32(a0)
	move.w 32(a0),d7
	lsr #2,d7
	andi #%110,d7
	;clr.w d7
	move frameCount+4(pc),d6
	lsr #1,d6
	addx d0,d7
	move.l (a0,d7.w*4),d0
	move.l d0,36(a0)

    move d0,copInitSprPtLW
    swap d0
    move d0,copInitSprPtHW
	swap d0
		;move.l d0,36(a0)
    move.l d0,a1
    move.w 2(a1),d2     ; get address of sprite dma memory
    swap d2
    move.w 6(a1),d2

    move.w #(spriteLineOffset*(spriteDMAHeight+1))*1,d3	; current sprite dma list, base and four offsets
	move.w #spriteDMAListOffset,d4
	move d4,d5
    lea spriteDMAListDynOffsets(pc),a0
    move.l d2,(a0)+
    move.w d3,(a0)+
	add d3,d4
    move.w d4,(a0)+
	add d5,d4
    move.w d4,(a0)+
	add d5,d4
    move.w d4,(a0)+


.sprModifiedFlag=2

	lea spriteDMAListDynOffsets+4(pc),a0	; dynamic pointers.w
	move.l d2,a6 ; get base pointer.l
    	;lea 4(a0),a0	; set pointer to offsets

    move spriteCount(pc),d7
    subq #1,d7
    bmi.w .closeDMA

    move.l spritePosFirst(pc),a1
    lea spriteWriteLastYPos(pc),a5
    ;sub.l a6,a6			; reset dynamic spritedmamem-offset
    ;move frameCount+4(pc),d0
    ;andi #3,d0
	;moveq #0,d0			; reset pointer to sprite-no

		;#MARK: sprite bullets loop
		;
		; a1	pointer sprite chain list
		;	a5	remember last y stop position+1
		; a6 = target base address
		; d5 	dynamic offset to target
	moveq #4,d6
	bra.b .firstEntry
.nextSprite
    adda.w d6,a1
    tst.w (a1)
    bne.b .firstEntry
    adda.w d6,a1
    tst.w (a1)
    bne.b .firstEntry
    adda.w d6,a1
    tst.w (a1)
    bne.b .firstEntry
    adda.w d6,a1
    tst.w (a1)
    beq.b .nextSprite
.firstEntry
	move d7,d0
	andi #3,d0	; which sprite slot

	move.w (a0,d0*2),d5	; get current offset
;	move.w #spriteLineOffset*(spriteDMAHeight+1),d3; preload offset-summand
;		add.w d3,(a0,d0*2)
	move.l (a1),d2
	clr.l (a1)		; clear up sprite list

	move d5,d3
	move d2,d4	; save x-position
	move d2,d1	; prep animjump
	swap d2		; compare y start with last y stop
	cmp.w (a5,d0*2),d2
	ble .overlap
.skipDynUpdate
	rol #7,d1; jump to different animation routines
	andi #$3f<<1,d1
	move.w ((.spriteAnimCases-*).w,pc,d1),d1
	jmp (pc,d1)
    ;jmp ([(.spriteAnimCases).W,pc,d1.w*4])
.spriteAnimCases

	; podA is 32 pixels width, 10 percent angle up
	; podB is 32 pixels width, 10 percent angle dwn
	; spreadA is 64 pixels width, 5 percent angle up
	; spreadB is 64 pixels width, 5 percent angle dwn
.sc = *-4
	dc.w .sprShotInit-.sc,.sprShot1-.sc,.sprShot2-.sc,.sprShot3-.sc;1-4
	dc.w .sprShotPodA-.sc,.sprShotPodB-.sc,.spriteBasic-.sc,.sprShotSpreadA-.sc;5-8
	dc.w .sprShotSpreadB-.sc,.sprShotExpl1-.sc,.sprShotExpl2-.sc,.sprShotExpl3-.sc;9-12
	dc.w .sprShotPodAX1-.sc,.sprShotPodAX2-.sc,.sprShotPodAX3-.sc;13-15
	dc.w .sprShotPodBX1-.sc,.sprShotPodBX2-.sc,.sprShotPodBX3-.sc;16-18
	dc.w	.spriteBasic-.sc,.spriteBasicX1-.sc;19-20
	dc.w .sprShotSpreadAX1-.sc,.sprShotSpreadAX2-.sc,.sprShotSpreadAX3-.sc,.spriteBasicX2-.sc;21-24
	dc.w .sprShotSpreadBX1-.sc,.sprShotSpreadBX2-.sc,.sprShotSpreadBX3-.sc,.sprBullet8-.sc;25-28
	dc.w .sprBullet8x1-.sc, .sprBullet8x2-.sc, .sprBonus8A-.sc, .sprBonus8B-.sc;29-32
	dc.w  .sprChain8A-.sc, .sprChain8B-.sc
.sprShot5Overlap
	sub.w #2*(spriteLineOffset*(spriteDMAHeight+1)),d3
	sub d5,d3
	sub d3,(a0,d0*2)	;add #spriteLineOffset*(spriteDMAHeight+1),(a0,d0*2); 8px low, 4px up
		bra.b .sprShot5SkipAdd

.sprShotPodBX1
	move.l ((spriteAnimTableShot8+20).W,pc),a2
    bra.b .sprSkip
.sprShotPodBX2
	move.l ((spriteAnimTableShot8+24).W,pc),a2
    bra.b .sprSkip
.sprShotPodBX3
	move.l ((spriteAnimTableShot8+28).W,pc),a2
    bra.b .sprSkip
.sprShotPodB
	move.l ((spriteAnimTableShot8+16).W,pc),a2
    bra.b .sprSkip
.sprShotPodAX1
	move.l ((spriteAnimTableShot8+4).W,pc),a2
    bra.b .sprSkip
.sprShotPodAX2
	move.l ((spriteAnimTableShot8+8).W,pc),a2
    bra.b .sprSkip
.sprShotPodAX3
	move.l ((spriteAnimTableShot8+12).W,pc),a2
    bra.b .sprSkip
.sprShotPodA
	move.l ((spriteAnimTableShot8).W,pc),a2
.sprSkip
	cmp d3,d5
	bne.b .sprShot5Overlap
	add.w #2*(spriteLineOffset*(spriteDMAHeight+1)),(a0,d0*2)
.sprShot5SkipAdd
	move.b d6,.sprModifiedFlag(a6,d5)		; set modified flag
    bra.w .bul8PlyShot
.sprShotExpl1
	move.l ((spriteAnimTableShotBasic+16).W,pc),a2
    bra.b .sprShot
.sprShotExpl2
	move.l ((spriteAnimTableShotBasic+20).W,pc),a2
    bra .sprShot
.sprShotExpl3
	move.l ((spriteAnimTableShotBasic+24).W,pc),a2
    bra .sprShot
	;#MARK: sprite shot general
.shotOverlap
	sub.w #spriteLineOffset*(spriteDMAHeight+1),d3
	sub d5,d3
	sub d3,(a0,d0*2)
	bra.b .shotSkipAdd
.sprShotSpreadA
	move.l ((spriteAnimTableShotSpread).W,pc),a2
    bra.b .sprShot
.sprShotSpreadAX1
	move.l ((spriteAnimTableShotSpread+4).W,pc),a2
    bra.b .sprShot
.sprShotSpreadAX2
    lea ([(spriteAnimTableShotSpread+8).W,pc]),a2
    bra.b .sprShot
.sprShotSpreadAX3
	move.l ((spriteAnimTableShotSpread+12).W,pc),a2
    bra.b .sprShot
.sprShotSpreadB
	move.l ((spriteAnimTableShotSpread+16).W,pc),a2
    bra.b .sprShot
.sprShotSpreadBX1
	move.l ((spriteAnimTableShotSpread+20).W,pc),a2
    bra.b .sprShot
.sprShotSpreadBX2
	move.l ((spriteAnimTableShotSpread+24).W,pc),a2
    bra.b .sprShot
.sprShotSpreadBX3
	move.l ((spriteAnimTableShotSpread+28).W,pc),a2
    bra.b .sprShot
.sprShotInit
	move.l ((spriteAnimTableShotBasic).W,pc),a2
    bra.b .sprShot
.sprShot1
	move.l ((spriteAnimTableShotBasic+4).W,pc),a2
    bra.b .sprShot
.sprShot2
	move.l ((spriteAnimTableShotBasic+8).W,pc),a2
    bra.b .sprShot
.sprShot3
	move.l ((spriteAnimTableShotBasic+12).W,pc),a2
.sprShot
	cmp d3,d5		; overlap?
	bne.b .shotOverlap
.shotNoOverlap
	moveq #spriteLineOffset*(spriteDMAHeight+1),d3
	add.w d3,(a0,d0*2)
.shotSkipAdd
	movem.l (a2)+,d1/d3/a3/a4	; get one line
	movem.l d1/d3/a3/a4,spriteLineOffset(a6,d5)
	movem.l (a2)+,d1/d3/a3/a4	; ""
	movem.l d1/d3/a3/a4,2*spriteLineOffset(a6,d5)
	movem.l (a2)+,d1/d3/a3/a4	; ""
	movem.l d1/d3/a3/a4,3*spriteLineOffset(a6,d5)
	movem.l (a2)+,d1/d3/a3/a4	; ""

	movem.l d1/d3/a3/a4,4*spriteLineOffset(a6,d5)

	move.b d6,.sprModifiedFlag(a6,d5)		; set modified flag
	bra.w .makeControlWords

	;#MARK: sprite bullet 8 px height
.bul8Overlap
	sub.w #2*(spriteLineOffset*(spriteDMAHeight+1)),d3
	sub d5,d3
	sub d3,(a0,d0*2)	;add #spriteLineOffset*(spriteDMAHeight+1),(a0,d0*2); 8px low, 4px up
		bra.b .bul8SkipAdd
.sprBullet8x1
	move.l ((spriteAnimTableBullet8+32).W,pc),a2
 	bra.b .skip8
.sprBullet8x2
	move.l ((spriteAnimTableBullet8+36).W,pc),a2
 	bra.b .skip8
.sprBonus8A
	move.l ((spriteAnimTableBonus).W,pc),a2
 	bra.b .skip8
.sprBonus8B
	move.l ((spriteAnimTableBonus+4).W,pc),a2
 	bra.b .skip8
.sprChain8A
	move.l ((spriteAnimTableChain).W,pc),a2
 	bra.b .skip8
.sprChain8B
	move.l ((spriteAnimTableChain+4).W,pc),a2
 	bra.b .skip8
.sprBullet8
	move.l ((spriteAnimTableBullet8).W,pc),a2
    lea frameCount+4(pc),a3
    move (a3),d1
    lsr #2,d1
    andi.w #$07,d1
    lsl #6,d1
    adda.w d1,a2
.skip8
	cmp d3,d5
	bne.b .bul8Overlap
	add.w #2*(spriteLineOffset*(spriteDMAHeight+1)),(a0,d0*2)
.bul8SkipAdd
	move.b d6,.sprModifiedFlag(a6,d5)		; set modified flag

	;lea 0,a2
    ;adda.w d3,a2
.bul8PlyShot
    clr.l d3
    suba.l a4,a4
	lea 4+(2*spriteLineOffset)(a6,d5),a3

	;adda.w #4+(2*spriteLineOffset),a3
    tst.l (a3)		; was full width shot before?
   	beq.b .upThin		; no
   			; yes. draw upper part, full size body
	movem.l (a2)+,d1/a3	; get one line
	movem.l d1/d3/a3/a4,spriteLineOffset(a6,d5)
	movem.l (a2)+,d1/a3	; ""
	movem.l d1/d3/a3/a4,2*spriteLineOffset(a6,d5)
	movem.l (a2)+,d1/a3	; ""
	movem.l d1/d3/a3/a4,3*spriteLineOffset(a6,d5)
	movem.l (a2)+,d1/a3	; ""
	movem.l d1/d3/a3/a4,4*spriteLineOffset(a6,d5)
	bra.b .lowerSprite
.upThin	; draw upper part, left body only
	movem.l (a2)+,d1/a3
	move.l d1,spriteLineOffset(a6,d5)
	move.l a3,8+spriteLineOffset(a6,d5)
	movem.l (a2)+,d1/a3
	move.l d1,2*spriteLineOffset(a6,d5)
	move.l a3,8+(2*spriteLineOffset)(a6,d5)
	movem.l (a2)+,d1/a3
	move.l d1,3*spriteLineOffset(a6,d5)
	move.l a3,8+(3*spriteLineOffset)(a6,d5)
	movem.l (a2)+,d1/a3
	move.l d1,4*spriteLineOffset(a6,d5)
	move.l a3,8+(4*spriteLineOffset)(a6,d5)
.lowerSprite
	lea 5*spriteLineOffset(a6),a6
	lea 4+(2*spriteLineOffset)(a6,d5),a3
    tst.l (a3)
    beq.b .lowThin
					; 	draw lower part, full width
	movem.l (a2)+,d1/a3	; ""
	movem.l d1/d3/a3/a4,(a6,d5)
	move.b #$80,.sprModifiedFlag(a6,d5)		; set modified flag in 2nd spriteslot
	movem.l (a2)+,d1/a3	; ""
	movem.l d1/d3/a3/a4,1*spriteLineOffset(a6,d5)
	movem.l (a2)+,d1/a3	; ""
	movem.l d1/d3/a3/a4,2*spriteLineOffset(a6,d5)
	movem.l (a2)+,d1/a3	; ""
	movem.l d1/d3/a3/a4,3*spriteLineOffset(a6,d5)
	clr.l d1
	suba.l a3,a3
	movem.l d1/d3/a3/a4,4*spriteLineOffset(a6,d5)
	suba.w #5*spriteLineOffset,a6
	moveq #9,d1
	bra .makeControlWordsAlt	;bra.b .makeControlWords
.lowThin		; draw lower, left body only
	movem.l (a2)+,d1/a3
	move.l d1,(a6,d5)
	move.l a3,8(a6,d5)
	move.b #$80,.sprModifiedFlag(a6,d5)		; set modified flag
	movem.l (a2)+,d1/a3
	move.l d1,1*spriteLineOffset(a6,d5)
	move.l a3,8+(1*spriteLineOffset)(a6,d5)
	movem.l (a2)+,d1/a3
	move.l d1,2*spriteLineOffset(a6,d5)
	move.l a3,8+(2*spriteLineOffset)(a6,d5)
	movem.l (a2)+,d1/a3
	move.l d1,3*spriteLineOffset(a6,d5)
	move.l a3,8+(3*spriteLineOffset)(a6,d5)
	clr.l d1
	move.l d1,4*spriteLineOffset(a6,d5)
	move.l d1,8+(4*spriteLineOffset)(a6,d5)
	suba.w #5*spriteLineOffset,a6
.modifySet
	moveq #9,d1		; modify height
	bra .makeControlWordsAlt	;bra.b .makeControlWords

;	#MARK: sprite basic 4 px height
.basicXOverlap
	sub.w #spriteLineOffset*(spriteDMAHeight+1),d3
	sub d5,d3
	sub d3,(a0,d0*2)	; modify next target adress
	bra.b .basicXSkipAdd
.spriteBasicX1
    lea spriteBullet4Xpixels,a2
	bra.b .spriteBasicX
.spriteBasicX2
    lea spriteBullet4Xpixels+(spriteBullet4XpixelsSize/2),a2
.spriteBasicX
	cmp d3,d5		; overlap?
	bne.b .basicXOverlap
	add.w #spriteLineOffset*(spriteDMAHeight+1),(a0,d0*2)
.basicXSkipAdd
	move.b d6,.sprModifiedFlag(a6,d5)		; set modified flag
	lea 4+(2*spriteLineOffset)(a6,d5),a3
    tst.l (a3)		; was full width shot before?
   	beq.b .thin		; no
   			; yes. draw full size body
    clr.l d3
    suba.l a4,a4
	movem.l (a2)+,d1/a3	; get one line
	movem.l d1/d3/a3/a4,spriteLineOffset(a6,d5)
	movem.l (a2)+,d1/a3	; ""
	movem.l d1/d3/a3/a4,2*spriteLineOffset(a6,d5)
	movem.l (a2)+,d1/a3	; ""
	movem.l d1/d3/a3/a4,3*spriteLineOffset(a6,d5)
	movem.l (a2)+,d1/a3	; ""
	movem.l d1/d3/a3/a4,4*spriteLineOffset(a6,d5)
	bra .makeControlWords
.thin	; draw left body only
	movem.l (a2)+,d1/a3
	move.l d1,spriteLineOffset(a6,d5)
	move.l a3,8+spriteLineOffset(a6,d5)
	movem.l (a2)+,d1/a3
	move.l d1,2*spriteLineOffset(a6,d5)
	move.l a3,8+(2*spriteLineOffset)(a6,d5)
	movem.l (a2)+,d1/a3
	move.l d1,3*spriteLineOffset(a6,d5)
	move.l a3,8+(3*spriteLineOffset)(a6,d5)
	movem.l (a2)+,d1/a3
	move.l d1,4*spriteLineOffset(a6,d5)
	move.l a3,8+(4*spriteLineOffset)(a6,d5)
	bra.b .makeControlWords

.basicOverlap
	sub.w #spriteLineOffset*(spriteDMAHeight+1),d3
	sub d5,d3
	sub d3,(a0,d0*2)	; modify next target adress
	tst.b .sprModifiedFlag(a6,d5)		; tst modified flag
	beq.b .basicNotModified
	bra.b .skipAdd
.spriteBasic
	cmp d3,d5		; overlap?
	bne.b .basicOverlap
	add.w #spriteLineOffset*(spriteDMAHeight+1),(a0,d0*2)
.skipAdd
	tst.b .sprModifiedFlag(a6,d5)		; tst modified flag
	beq.b .basicNotModified

	lea spriteLineOffset(a6),a2
	movem.l (a2)+,d1/d3/a3/a4	; get one line
	movem.l d1/d3/a3/a4,spriteLineOffset(a6,d5)
	movem.l (a2)+,d1/d3/a3/a4	; ""
	movem.l d1/d3/a3/a4,2*spriteLineOffset(a6,d5)
	movem.l (a2)+,d1/d3/a3/a4	; ""
	movem.l d1/d3/a3/a4,3*spriteLineOffset(a6,d5)
	movem.l (a2)+,d1/d3/a3/a4	; ""
	movem.l d1/d3/a3/a4,4*spriteLineOffset(a6,d5)
.basicNotModified
	clr.b .sprModifiedFlag(a6,d5)

.makeControlWords
    ;    d6 = height, d2=y-position, d4 = x-position
;	#MARK: sprite make control words
	move d6,d1
.makeControlWordsAlt
	    add.w d2,d1          ; y stop position
		move d1,(a5,d0*2)         ; save y stop for later compare

	    clr.b   d3

		lsl.w   #8,d2     ; move vertical start bit 8 in place
		addx.b  d3,d3

		lsl.w   #8,d1     ; vertical stop bit 8
		addx.b  d3,d3

		lsr.w   #1,d4     ; horizontal start bit 0
		addx.b  d3,d3
		add.b #$30,d4
		move.b  d4,d2     ; make first control word
		move.b  d3,d1     ; second control word

		move.w d2,(a6,d5)      ; SPRxPOS
		move.w d1,8(a6,d5)     ; SPRxCTL
.endLoop
	dbra d7,.nextSprite
.closeDMA
	moveq #3,d7
.closeDMALoop
	move.w (a0,d7*2),d5	; get offset
	clr.w (a6,d5)
	clr.w 8(a6,d5)
	dbra d7,.closeDMALoop
.quit
	rts
;	#MARK: sprite overlap code

.overlap	; sprite has overlapped; skip draw or use upper slot
	btst #0,frameCount+3
	beq.b .endLoop
.findSlot
	sub #spriteLineOffset*(spriteDMAHeight+1),d5	; reset temp dyn
	tst.b .sprModifiedFlag(a6,d5)
	bpl .skipDynUpdate
	sub #spriteLineOffset*(spriteDMAHeight+1),d5	; reset temp dyn
	bra.w .skipDynUpdate



spriteAnimTableShotBasic
.tempVal SET 0
    REPT 8
    dc.l spritePlayerShot+.tempVal
.tempVal SET .tempVal+(4*spriteDMAWidth/4)
    Endr
spriteAnimTableShot8
.tempVal SET 0
    REPT 8
    dc.l spriteShotPod+.tempVal
.tempVal SET .tempVal+(4*spriteDMAWidth/4)
    Endr
spriteAnimTableShotSpread
.tempVal SET 0
    REPT 8
    dc.l spriteShotSpread+.tempVal
.tempVal SET .tempVal+(4*spriteDMAWidth/4)
    Endr

spriteAnimTableBonus
	dc.l spriteBonus8pixels,spriteBonus8pixels+64
spriteAnimTableChain
	dc.l spriteChain8pixels,spriteChain8pixels+64

spriteAnimTableBullet8
.tempVal SET 0
    REPT 10
    dc.l spriteBullet8pixels+.tempVal
.tempVal SET .tempVal+(4*spriteDMAWidth/4)
    Endr
spriteAnimTableBullet4
.tempVal SET 0
    REPT 14
    dc.l spriteBullet4pixels+.tempVal
.tempVal SET .tempVal+(2*spriteDMAWidth/8)
    Endr

spriteAnimTablePlayerBasic
.tempVal SET 0
    REPT 32
    dc.l (spritePlayerBasic+.tempVal)
.tempVal SET .tempVal+(spritePlayerHeight*spriteDMAWidth/2)
    Endr

spriteWriteLastYPos
    blk.w 4,0
spriteDMAListDynOffsets
	dc.l 0
	dc.w 0,0,0,0
    IF RELEASECANDIDATE=0
spriteTempNumbers
    dc.b %00001100,0
    dc.w 0
    dc.b %00010100,0
    dc.w 0
    dc.b %00111100,0
    dc.w 0
    dc.b %00000100,0
    dc.w 0

    dc.b %00111000,0
    dc.w 0
    dc.b %00000100,0
    dc.w 0
    dc.b %00000100,0
    dc.w 0
    dc.b %00111000,0
    dc.w 0

    dc.b %00011000,0
    dc.w 0
    dc.b %00000100,0
    dc.w 0
    dc.b %00011000,0
    dc.w 0
    dc.b %00111100,0
    dc.w 0

    dc.b %00000100,0
    dc.w 0
    dc.b %00001100,0
    dc.w 0
    dc.b %00000100,0
    dc.w 0
    dc.b %00000100,0
    dc.w 0
    ENDIF
;	#MARK: SPRITE MANAGER ENDS


	; #MARK:  - SOUND DEFINITIONS

AudioIsInitiated
    dc.b 0
AudioNoOfSamples
    dc.b 0
AudioRythmFlag
    dc.b 0
AudioRythmFlagBullets
    dc.b 0
AudioRythmFlagAnim
    dc.b    0
AudioRythmAnimOffset
    dc.b    0
AudioSoundStatus
	dc.b 0		; bit 0 toggles music on/off, 1 soundfx on/off
fxInit
    dc.b    0
AudioTimerIntervall
	dc.w 0
fxPrioPlaying
    dc.b 0
fxCountdown
    dc.b 0
    ; #MARK: - FX initvalue table -
    even

;	#MARK: - SFX TABLE

fxTable
    dc.l 0,0
;   0.w     Offset Sampleperiod (bit15-> add random pitch)
;   2.b     minimal playtime
;   3.b     volume
;   4.w     Pointer to sample (load order)
;   6.b     not used
;   7.b     priority

first
;1  - preshot
    dc.w $80b0
    dc.b 1,$1f
    dc.w 0
    dc.w fxPrioLowest

;2  - mainshot
    dc.w $b0
    dc.b 5,$18
    dc.w 1
    dc.w fxPrioLow

;3  -   explosion small
    dc.w $8030
    dc.b 10,$38
    dc.w 2
    dc.w fxPrioHigh

;4  -   explosion med
    dc.w $8060
    dc.b 14,$3c
    dc.w 2
    dc.w fxPrioHigher

;5  -   explosion big
    dc.w $8090
    dc.b 35,$3f
    dc.w 2
    dc.w fxPrioHighest

;6  -   Enemy shot
    dc.w $81c0
    dc.b 3,$12
    dc.w 4
    dc.w fxPrioMed

;7  -   Alarm
    dc.w $30
    dc.b 50,$3f
    dc.w 5
    dc.w fxPrioTop

;8  - impact
    dc.w $0001
    dc.b 4,$20
    dc.w 3
    dc.w fxPrioMed

;9  - impact no hit
    dc.w $80f1
    dc.b 5,$20
    dc.w 7
    dc.w fxPrioMed

;10  - new high
    dc.w $0040
    dc.b 50,$34
    dc.w 6
    dc.w fxPrioTop

;11  - extraweapon
    dc.w $0040
    dc.b 30,$34
    dc.w 8
    dc.w fxPrioTop

;12  - maxed out weapon
    dc.w $0040
    dc.b 30,$34
    dc.w 10
    dc.w fxPrioTop

;13  - Lost Weapon
    dc.w $8080
    dc.b 20,$30
    dc.w 9
    dc.w fxPrioHighest
;14  - Lost last Weapon
    dc.w $8130
    dc.b 4,$34
    dc.w 9
    dc.w fxPrioHighest

;15  - Got extra speed
    dc.w $0040
    dc.b 50,$34
    dc.w 11
    dc.w fxPrioTop

;16  -   Enemy shot very big
    dc.w $8310
    dc.b 35,$12
    dc.w 4
    dc.w fxPrioHigher

;17  -   Enemy shot very quick staffete
    dc.w $8010
    dc.b 3,$12
    dc.w 0
    dc.w fxPrioHigher

;18  - alternative soft enemy bullet sound
    dc.w $80e0
    dc.b 6,$30
    dc.w 12
    dc.w fxPrioMed

;19  - impact pitch reset
    dc.w $8251
    dc.b 13,$3f
    dc.w 7
    dc.w fxPrioHighest

;20  - alternative hard enemy bullet sound
    dc.w $80c1
    dc.b 8,$20
    dc.w 4
    dc.w fxPrioMed

;21  - l1 boss audio
    dc.w $02f1
    dc.b 130,$3f
    dc.w 5
    dc.w fxPrioHighest

;22  - l1 boss leave screen
    dc.w $02e1
    dc.b 100,$3f
    dc.w 11
    dc.w fxPrioHighest

last
    dc.l 0,0; eof fxtable
	even

;	#MARK: SFX TABLE ENDS


			; MARK:  - PLAYER DEFINITIONS
		RSRESET
plyPosX			rs.l	1
plyPosY			rs.l	1
plyPosAcclX		rs.l	1
plyPosAcclY		rs.l	1
plyPosAdderX	rs.l	1
plyPosAdderY	rs.l	1
plyInitiated	rs.w	1
plyCollided		rs.w	1
plyShotCnt		rs.b	1
plyFire1Auto	rs.b	1
plyFire1Flag	rs.b	1
plyFire1Hold	rs.b	1
plyDistortionMode	rs.b	1
plyExitReached	rs.b	1
plyWeapUpgrade	rs.b	1
plyWeapSwitchFlag	rs.b	1
plyAnimPointer	rs.l	1
plyPracticeAvail		rs.b	1
plyContinueAvail	rs.b	1
plyAcclXCap		rs.w	1
plyAcclXMin=$4
plyAcclYCap		rs.w	1
plyAcclYMin=$4
plyPosYDyn		rs.w	1
plyPosYDynAlt	rs.w	1
plyJoyCode		rs.w	1
plyJoyOldCode	rs.w	1
plyPosXABS		rs.w	1
plyPosYABS		rs.w	1
plyCheatEnabled		rs.b	1
plyEmpty		rs.b	1

plyPosRem
	blk.l 5,0
plyBase
plyPos
	blk.l (plyEmpty/4)+1,0

        PRINTV *
plyAddAccl=$8000



; #MARK: - SCREENMANAGER BEGINS
screenManagerBossLv0
	bra screenManager

	; #MARK: screenmanagerlv0

screenManagerLv0
    move frameCount+2(pc),d7
    andi #1,d7
    lsl #6,d7
    move d7,copBPL2ModOffset+2 ; modify modulus for secondplane / add to screenadress -> interlace for smoother pixels

    ; handle sprite parallaxplane
    move.w viewPositionPointer(a3),d7
	move d7,d5
    lsl #1,d7                   ; multiplier for sprite parallax plane
	add d5,d7

	lea rastListMover(pc),a6
	move.w frameCount+2(pc),d5
	;lsr #1,d5
    move.b d5,(a6)	; second playfield

scrMngPointers
    move.w d7,d6
    lsl.b #2,d6
    andi.b #%1100,d6
    lsr.b #3,d7
    addx.b d6,d6		; sprite parallax one pixel scroll

	eori.b #%00011011,d6	; ; sprite parallax  subpixel scroll
	andi.w #$1f,d7
scrSprPointers

    move.l ([(spriteParMultiTable).w,pc],d7*4),d0
    move.l d0,a1
    ;move.l #titleSprites,d0
    lea copSprite67,a4
    move d0,6+8(a4)
    swap d0
    move d0,2+8(a4)         ; write sprite pointer

    move.b d6,9(a1)         ; write sprite ctrl byte, pixelvalues
	lea	copSpriteScroll(pc),a6	; pointer to SPR6CTL in coplist
	movem.l (a6),a0-a2

	or.w #$35<<8+%110,d6
	andi #%11001,d6
	move.w d6,2(a0)
	move.w d6,2(a2)
	move.w d6,2(a1)
	bra screenManager

	; #MARK: screenmanagerBoss
screenManagerBoss
	lea screenManagerBossScroll(pc),a0
	move.w 2(a0),d7
	lsr #4,d7
	add.w d7,(a0)

	clr.w d7
	sub.w (a0),d7
	;lsl #1,d7	; multiplier for sprite parallax plane
	lea rastListMover(pc),a6
	move d7,d5
	;move.w frameCount+2(pc),d5
	move d5,d6
	lsr #4,d6
	lsr #1,d5
	sub.b d6,d5
	move.b d5,(a6)	; second playfield

    move.w d7,d6
    lsl.b #2,d6
    andi.b #%1100,d6
    lsr.b #3,d7
    addx.b d6,d6		; sprite parallax one pixel scroll

	eori.b #%00011011,d6	; ; sprite parallax  subpixel scroll
	andi.w #$1f,d7
    move.l ([(spriteParMultiTable).w,pc],d7*4),d0
    move.l d0,a1
    lea copSprite67,a4
    move d0,6+8(a4)
    swap d0
    move d0,2+8(a4)         ; write sprite pointer

    move.b d6,9(a1)         ; write sprite ctrl byte, pixelvalues
	lea	copSpriteScroll(pc),a6	; pointer to SPR6CTL in coplist
	movem.l (a6),a0
	bra screenManager
screenManagerBossScroll
	dc.w 0,0

	; #MARK: screenmanagerBoss LV4
screenManagerBossL4
	lea screenManagerBossScroll(pc),a0
	moveq #5,d7
	add.w d7,2(a0)
	andi #$ff,2(a0)

;	move.w (a0),d7
	;clr.w d7
	move.w 2(a0),d7
	;lsr #1,d7	; multiplier for sprite parallax plane
	lea rastListMover(pc),a6
	move d7,d5
	;move.w frameCount+2(pc),d5
	move d5,d6
	;lsr #2,d6
	lsr #1,d5
	;sub.b d6,d5
	move.b d5,(a6)	; second playfield

    move.w d7,d6
    lsl.b #2,d6
    andi.b #%1100,d6
    lsr.b #3,d7
    addx.b d6,d6		; sprite parallax one pixel scroll

	eori.b #%00011011,d6	; ; sprite parallax  subpixel scroll
	andi.w #$1f,d7
    move.l ([(spriteParMultiTable).w,pc],d7*4),d0
    move.l d0,a1
    lea copSprite67,a4
    move d0,6+8(a4)
    swap d0
    move d0,2+8(a4)         ; write sprite pointer

    move.b d6,9(a1)         ; write sprite ctrl byte, pixelvalues
	lea	copSpriteScroll(pc),a6	; pointer to SPR6CTL in coplist
	movem.l (a6),a0
	bra sm2




	; #MARK: screenmanagerlv1

screenManagerLv1

    move.w viewPositionPointer(a3),d7
	;lsl #1,d7	; multiplier for sprite parallax plane
	lea rastListMover(pc),a6
	move d7,d5
	;move.w frameCount+2(pc),d5
	move d5,d6
	lsr #4,d6
	lsr #1,d5
	sub.b d6,d5
	move.b d5,(a6)	; second playfield

    move.w d7,d6
    lsl.b #2,d6
    andi.b #%1100,d6
    lsr.b #3,d7
    addx.b d6,d6		; sprite parallax one pixel scroll

	eori.b #%00011011,d6	; ; sprite parallax  subpixel scroll
	andi.w #$1f,d7
    move.l ([(spriteParMultiTable).w,pc],d7*4),d0
    move.l d0,a1
    lea copSprite67,a4
    move d0,6+8(a4)
    swap d0
    move d0,2+8(a4)         ; write sprite pointer

    ;move.b d6,9(a1)         ; write sprite ctrl byte, pixelvalues
	lea	copSpriteScroll(pc),a6	; pointer to SPR6CTL in coplist
	movem.l (a6),a0

	or.w #$35<<8+%110,d6
	andi #%11001,d6
	move.w d6,2(a0)
	bra screenManager


	; #MARK: screenmanagerlv2

screenManagerLv2
    move.w viewPositionPointer(a3),d7
	lea rastListMover(pc),a6
	;move frameCount+2(pc),d7
	;lsl #1,d7
    move.b d7,(a6)	; second playfield
    ;move d7,d6
    add d7,d7
    ;add d6,d7
    ;lsr #2,d7
	;lsl #2,d7                   ; multiplier for sprite parallax plane
    move.w d7,d6
    lsl.b #2,d6
    andi.b #%1100,d6
    lsr.b #3,d7
    addx.b d6,d6		; sprite parallax one pixel scroll

	eori.b #%00011011,d6	; ; sprite parallax  subpixel scroll
	andi.w #$1f,d7
	move.l ((spriteParMultiTable).w,pc),a1
	move.l (a1,d7*4),a1
	move.l a1,d0
    ;move.l ([(spriteParMultiTable).w,pc],d7*4),d0
    ;move.l d0,a1
    ;move.l #titleSprites,d0
    lea copSprite67,a4
    move d0,6+8(a4)
    swap d0
    move d0,2+8(a4)         ; write sprite pointer

;    move.b d6,9(a1)         ; write sprite ctrl byte,

    	lea	copSpriteScroll(pc),a6	; pointer to SPR6CTL in coplist
	move.l 4(a6),a0
	or.w #$35<<8+%110,d6
	andi #%11001,d6
	move.w d6,2(a0)
	bra screenManager

; #MARK: screenmanagerlv3
screenManagerLv3
    move.w viewPositionPointer(a3),d7
	lea rastListMover(pc),a6
	move frameCount+2(pc),d7
    move.b d7,(a6)	; second playfield
    move d7,d6
    add d7,d7
    add d6,d7
    ;lsr #2,d7
	;lsl #2,d7                   ; multiplier for sprite parallax plane
    move.w d7,d6
    lsl.b #2,d6
    andi.b #%1100,d6
    lsr.b #3,d7
    addx.b d6,d6		; sprite parallax one pixel scroll

	eori.b #%00011011,d6	; ; sprite parallax  subpixel scroll
	andi.w #$1f,d7
    move.l ([(spriteParMultiTable).w,pc],d7*4),d0
    move.l d0,a1
    ;move.l #titleSprites,d0
    lea copSprite67,a4
    move d0,6+8(a4)
    swap d0
    move d0,2+8(a4)         ; write sprite pointer

    move.b d6,9(a1)         ; write sprite ctrl byte,
	bra screenManager
	;bra.b scrMngPointers
;!!!: SCLV1 kicken?

; #MARK: screenmanagerlv4
screenManagerLv4
    ; handle sprite parallaxplane
    move.l viewPositionPointer(a3),d7
	lea rastListMover(pc),a6
	move.l d7,d6
	lsl.l #2,d7
	add.l d6,d7
	lsr.l #1,d7
	swap d7
    move.b d7,(a6)	; second playfield

	move d7,d5
    lsr #2,d7                   ; multiplier for sprite parallax plane
	add d5,d7
    move.w d7,d6
    lsl.b #2,d6
    andi.b #%1100,d6
    lsr.b #3,d7
    addx.b d6,d6		; sprite parallax one pixel scroll

	eori.b #%00011011,d6	; ; sprite parallax  subpixel scroll
	andi.w #$1f,d7
    move.l ([(spriteParMultiTable).w,pc],d7*4),d0
    move.l d0,a1
    ;move.l #titleSprites,d0
    lea copSprite67,a4
    move d0,6+8(a4)
    swap d0
    move d0,2+8(a4)         ; write sprite pointer


    move.b d6,9(a1)         ; write sprite ctrl byte, pixelvalues
	lea	copSpriteScroll(pc),a6	; pointer to SPR6CTL in coplist
	movem.l (a6),a0-a2

	or.w #$35<<8+%110,d6
	andi #%11001,d6
	move.w d6,2(a1)
	;move.w d6,2(a2)


; #MARK: screenmanager main

screenManager

;FIXME: Do two subcoplists with bplpt make sense? Probably not!
	move.l viewPositionAdd(a3),d0
	move.l viewPositionPointer(a3),viewPositionPointerOld(a3)
	add.l d0,viewPositionPointer(a3)
	move #$f,d1
	ror.w #4,d1
	and.w d1,2+viewPositionPointer(a3); avoid flicker
sm2
.skip
	clr.l d1
	clr.l d2
	clr.l d3
	clr.l d5

	move.l viewPositionPointer(a3),d1

    move.l #%1111111111110111<<16+%11100000<<8+0,d0
    sub.l d1,d0           ; d0 finescrolling mainPlane

    lsl.l #3,d0
    swap d0
    move d0,d3            ; d3 finescrolling bckplane
    ;moveq #0,d3
    ;lsl #2,d3                ; multiplier bckplane

    clr d1
    swap d1             ; d1 = add to mainPlane-pointer
	move d1,d4		; save for later compare
    move.l d1,d2          ; d2 = factor to tile-on-mainplane

	move.l tilemapConverted(pc),a0
    move.l d1,d7      ; calc pointer to tilemapConverted
    lsr #2,d7
    moveq #%111,d2
    and.l d2,d7
    move d7,d2
    ;lsr #1,d7
	add.l d7,a0         ;

    move.l d1,d7
    rol.l #2,d7
    moveq #-$80,d5
    and.l d5,d7
    lsr.l #4,d7
    add.l d7,a0     ; source tile

    asr.l #3,d1

    lea mainPlanes(pc),a1
    lea mainPlanesPointer(pc),a6
    movem.l (a1),d5-d7
	tst.b blitterManagerFinishedF(pc)
    beq .swapGfxBuffers
    exg.l d5,d7
    exg.l d6,d7
    movem.l d5-d7,(a1)

.swapGfxBuffers
    add.l d1,d5
    add.l d1,d6
    add.l d1,d7
    movem.l d5-d7,(a6)
    ;clr.l d7
	;move.l d5,d6
	clr.l d7;Write bitplaneRestoreadress to Coplist
    move.w plyPos+plyPosYDyn(pc),d7
	clr.l d5
    move d7,d5
    lea bobAdrTable(pc),a1
    move.w -6(a1,d7*2),d7
    subq #2,d7

    add.l d7,d6
    moveq #8,d1
    add.l d1,d6	: d6 = mainplanePointer+4
    andi.b #$fc,d6
    move.l bckplanePointer+4(pc),d7

    bclr #0,d5
    lsl #5,d5
    add.l d5,d7	; add vert scrolling to bckplane
	clr.l d5
	move.w #bckplaneWidth*bckplaneHeight,d5
    moveq #mainPlaneWidth,d1
    lea copBPLPT,a4
.tempVal SET 6              ; write bplpt pointer mainplane to copsublist (small interleaved bitmap cant be scrolled by modyfing modulus)
    REPT 3
	move d6,.tempVal(a4)
    swap d6
	move d6,.tempVal-4(a4)
	move d7,.tempVal+8(a4)
    swap d7
	move d7,.tempVal+4(a4)      ; update startadress of secondary plane
.tempVal SET .tempVal+16
    swap d6
    swap d7
    add.l d1,d6
    add.l d5,d7
    ENDR
	move d6,.tempVal(a4)
    swap d6
	move d6,.tempVal-4(a4)
	move d7,.tempVal+8(a4)
    swap d7
	move d7,.tempVal+4(a4)

	tst.l viewPositionAdd(a3)
	beq irqRetScreenManager	; skip tile update if screen don´t scroll

	move d0,d7
    andi #%00000000<<8+%01111000,d7 ; x-Soft-Scroll
    lsr #3,d7
    move d3,d5
    andi #%00000000<<8+%01111000,d5 ; same for mainplane
    lsl #1,d5
    or d5,d7

    move d0,d1
    andi #%00000000<<8+%10000000,d1
    moveq #3,d4
    lsl d4,d1
    or d1,d7            ; add horizontal scrollcode for wide bitplanes

    move d3,d1
    andi #%00000000<<8+%10000000,d1
    moveq #7,d4
    lsl d4,d1
    or d1,d7            ; same for bckplane

    move d0,d5
    andi #%00000000<<8+%00000110,d5
    moveq #5,d4
    ror d4,d5
    or d5,d7            ; add horizontal scrollcode for 35 ns pixel finescrolling

    move d3,d5
    andi #%00000000<<8+%00000110,d5
    moveq #7,d4
    lsl d4,d5
    or d5,d7            ; same for bckplane

	move d7,copBPLCON1+2
	;lsr #2,d2
	;andi #%111,d2
	lea scr2Offset(pc),a1

plotOffset=mainPlaneWidth+4

	move.w #(mainPlaneWidth-tileWidth/8)+4,d7
	moveq #(tileHeight/2)-1,d6
	moveq #9,d1
	lea plotOffset.w,a6
	move.b #$fc,d0

    clr.l d5			; read tile
	move.b (a0),d5
	;andi #$7f,d5
	bmi .tileFlipped

	move.l tileSource(pc),a2
	lsl.w d1,d5
	lea (a2,d5.l),a2	; source first tile

	move.l (a1,d2*4),d3
	move.l d3,d4
	move.l d4,d5
	add.l mainPlanesPointer+0(pc),d3
	add.l a6,d3
	and.b d0,d3
 	move.l d3,a1            ; first buffer (alternating)

	add.l mainPlanesPointer+4(pc),d4
	add.l a6,d4
	and.b d0,d4
 	move.l d4,a3		; second buffer

	add.l mainPlanesPointer+8(pc),d5
	add.l a6,d5
	and.b d0,d5
 	move.l d5,a4		; second buffer

.copy
	movem.l (a2)+,d0-d5/a5-a6
	move.l d0,(a1)
	adda.w d7,a1
	move.l d0,(a3)
	adda.w d7,a3
	move.l d0,(a4)
	adda.w d7,a4

	move.l d1,(a1)
	adda.w d7,a1
	move.l d1,(a3)
	adda.w d7,a3
	move.l d1,(a4)
	adda.w d7,a4

	move.l d2,(a1)
	adda.w d7,a1
	move.l d2,(a3)
	adda.w d7,a3
	move.l d2,(a4)
	adda.w d7,a4

	move.l d3,(a1)
	adda.w d7,a1
	move.l d3,(a3)
	adda.w d7,a3
	move.l d3,(a4)
	adda.w d7,a4

	move.l d4,(a1)
	adda.w d7,a1
	move.l d4,(a3)
	adda.w d7,a3
	move.l d4,(a4)
	adda.w d7,a4

	move.l d5,(a1)
	adda.w d7,a1
	move.l d5,(a3)
	adda.w d7,a3
	move.l d5,(a4)
	adda.w d7,a4

	move.l a5,(a1)
	adda.w d7,a1
	move.l a5,(a3)
	adda.w d7,a3
	move.l a5,(a4)
	adda.w d7,a4

	move.l a6,(a1)
	adda.w d7,a1
	move.l a6,(a3)
	adda.w d7,a3
	move.l a6,(a4)
	adda.w d7,a4
	dbra d6,.copy
	bra irqRetScreenManager
.tileFlipped
    bclr #7,d5
    addq #1,d2
	move.l tileSource(pc),a2
	lsl.w d1,d5
	lea (a2,d5.l),a2	; source first tile

	move.l (a1,d2*4),d3
	move.l d3,d4
	move.l d4,d5
	add.l mainPlanesPointer+0(pc),d3
	add.l a6,d3
	and.b d0,d3
 	move.l d3,a1            ; tile target

	add.l mainPlanesPointer+4(pc),d4
	add.l a6,d4
	and.b d0,d4
 	move.l d4,a3

	add.l mainPlanesPointer+8(pc),d5
	add.l a6,d5
	and.b d0,d5
 	move.l d5,a4
.copyFlipped
	movem.l (a2)+,d0-d5/a5-a6
	suba.w d7,a1
	move.l d3,(a1)
	suba.w d7,a3
	move.l d3,(a3)
	suba.w d7,a4
	move.l d3,(a4)

	suba.w d7,a1
	move.l d2,(a1)
	suba.w d7,a3
	move.l d2,(a3)
	suba.w d7,a4
	move.l d2,(a4)

	suba.w d7,a1
	move.l d1,(a1)
	suba.w d7,a3
	move.l d1,(a3)
	suba.w d7,a4
	move.l d1,(a4)

	suba.w d7,a1
	move.l d0,(a1)
	suba.w d7,a3
	move.l d0,(a3)
	suba.w d7,a4
	move.l d0,(a4)

	suba.w d7,a1
	move.l a6,(a1)
	suba.w d7,a3
	move.l a6,(a3)
	suba.w d7,a4
	move.l a6,(a4)

	suba.w d7,a1
	move.l a5,(a1)
	suba.w d7,a3
	move.l a5,(a3)
	suba.w d7,a4
	move.l a5,(a4)

	suba.w d7,a1
	move.l d5,(a1)
	suba.w d7,a3
	move.l d5,(a3)
	suba.w d7,a4
	move.l d5,(a4)

	suba.w d7,a1
	move.l d4,(a1)
	suba.w d7,a3
	move.l d4,(a3)
	suba.w d7,a4
	move.l d4,(a4)
	dbra d6,.copyFlipped
ScreenManagerNil
	bra irqRetScreenManager

; #MARK: SCREENMANAGER ENDS -


;	#MARK: - SPRITE PARALLAX MANAGER
ParallaxManager        ; handles building of background layer. d0 = no. of map mixed into basic layer. Max. 15 maps
    ;moveq #0,d0;     ; FIXME: temp d0 value
    move.l d0,-(sp)
    ; handle spriteplane

    ; set parallax sprite colors
    SAFECOPPER	; take care that copper doesnt change colorreg offset
;#FIXME: Color code only needed incase copperlist doesnt control these. Trash?
  	lea lv0blueShadesInits,a0
    movem.w (a0),d0-d2
    add #1<<2,d2

    move #224+13+16,d3 ; parallax sprite color1 main playfield
    WRITECOLOR
	add d1,d0
	add d2,d0
	clr d1
	clr d2
    move #192+13+16,d3 ; parallax sprite color1 escalate playfield
    WRITECOLOR

    movem.w (a0),d0-d2
    add #3<<3,d2
    move #224+14+16,d3 ; parallax sprite color2 main playfield
    WRITECOLOR
	add d1,d0
	add d2,d0
	clr d1
	clr d2
    move #192+14+16,d3; parallax sprite color2 escalate playfield
    WRITECOLOR

    movem.w (a0),d0-d2
    add #$7<<3,d2
    move #224+15+16,d3	; parallax sprite color3 main playfield
    WRITECOLOR
	add d1,d0
	add d2,d0
	clr d1
	clr d2
    move #192+15+16,d3 ; parallax sprite color3 escalate playfield
    WRITECOLOR
    ;rts
	;bra prepSprParBitmaps
	move.w gameStatusLevel(pc),d1
	move.w .sprParColors(pc,d1*2),d1
	lea .lv0(pc,d1.w),a1
    move.l copLineList(pc),a0
    move.l (a0),a0

	lea sprParColPointers(pc),a2
.loop
	move.w (a2)+,d6
	beq prepSprParBitmaps
	movem.w (a1)+,d0-d3
	move d0,6(a0,d6)	; 	color0
	move d1,14(a0,d6)	;	color2xx
	move d2,18(a0,d6)	;	""
	move d3,22(a0,d6)	;	""
	bra.b .loop
.sprParColors
	dc.w 0,.lv1-.lv0,.lv2-.lv0,.lv3-.lv0,.lv4-.lv0
.lv0
	dc.w 	$0001,$0003,$0004,$0005	; Level0
	dc.w 	$0,$2,$2,$3
	dc.w	$1,$3,$4,$5
	dc.w	$2,$3,$15,$16
	dc.w	$2,$3,$15,$16			; top color!
.lv1
	dc.w	$820,$510,$400,$800		; level2
	dc.w	$100,$500,$900,$800
	dc.w	$100,$400,$700,$800
	dc.w	$100,$400,$500,$800
	dc.w	$230,$720,$610,$430		; top color!
.lv2
	dc.w	0,$18f,$18e,0		; level3
	dc.w	0,$19f,$2af,$2bf
	dc.w	0,$1af,$2bf,$2cf
.lv3
	dc.w	$5dd,$5cb,$7ed,$6dc
.lv4
;	 inits color in city coplist

sprParColPointers
	blk.w 16,0	; pointers to copper sprite color switch.  0.w - 14.w = pointer to coplist, 15.w =0 mark end
sprParColPointersEnd


prepSprParBitmaps
    ;RESTORECOPPER

    move.l #parallaxSprite,d1        ; load and prepare parallax sprite data (saved as 64 pixel sprite with ctrl bytes, spriteParallaxHeight-1 = 241). filename: parSpritex

    move.l spriteParallaxBuffer(pc),d2
   	move.l	#spriteParallaxBufferSize-20,d3
   	;move.l #4000,d3
    jsr loadFile
    beq errorDisk		;

    moveq #16,d2
    move.l d2,a2
    move.l #spriteParallaxBufferSize,d7
    lsr.l #5,d7
    move.l d7,a6
    move.l spriteParallaxBuffer(pc),a3
	move.w ((sprInitOffset).w,pc),d0
jmpParOffset
	jmp (pc,d0.w)

parallaxInit0
lv0parSprSlowEntry=145
lv0parSprSlowExit=209
    moveq #30,d5                 ; copy loaded sprite 31-times and rol it by 2 pixels each time -> 64 pixel endless loop
.nextSprite
    move.l a3,a1
    lea 16(a1),a1

    move.l a1,a0
    add.l #((spriteDMAWidth/8)*(spriteParallaxHeight+1)*2),a0
    moveq #0,d4


    move.w #50,d6	; fast top view, 3 colors
.copySprite0
    movem.l (a1),d0-d3
	bsr.w rolPlane0
	bsr.w rolPlane1
    movem.l d0-d3,(a0)
    moveq #16,d0
    adda.l d0,a0
    adda.l d0,a1
    dbra d6,.copySprite0

    move.w #(spriteParallaxHeight-1)/3-36,d6	; fast top view, parallax
.copySpriteA
    movem.l (a1),d0-d3
    btst #0,d5
    beq.b .skB0
	bsr.b rolPlane0
.skB0
	bsr rolPlane1
    movem.l d0-d3,(a0)
    moveq #16,d0
    adda.l d0,a0
    adda.l d0,a1
    dbra d6,.copySpriteA


    move.w #lv0parSprSlowExit-lv0parSprSlowEntry-1,d6; slow cntral view
.copySpriteB
    movem.l (a1),d0-d3
    btst #0,d5
    beq.b .skA
	bsr.b rolPlane1
.skA
    movem.l d0-d3,(a0)
    moveq #16,d0
    adda.l d0,a0
    adda.l d0,a1
    dbra d6,.copySpriteB

    move.w #(spriteParallaxHeight-1)/3-36,d6	; fast down view
.copySpriteC
    movem.l (a1),d0-d3
	btst #0,d5
    beq.b .skC0
	bsr.b rolPlane0
.skC0
	bsr.b rolPlane1
    movem.l d0-d3,(a0)
    moveq #16,d0
    adda.l d0,a0
    adda.l d0,a1
    dbra d6,.copySpriteC

    move.w #36,d6	; fast bottom view, 3 colors
.copySpriteD
    movem.l (a1),d0-d3
	bsr.w rolPlane0
	bsr.w rolPlane1
    movem.l d0-d3,(a0)
    moveq #16,d0
    adda.l d0,a0
    adda.l d0,a1
    dbra d6,.copySpriteD

    add.l a6,a3
    dbra d5,.nextSprite
	bra parallaxCleanUp
rolPlane0
    add.l d1,d1
    addx.l d0,d0
    addx.b d4,d1
    add.l d1,d1
    addx.l d0,d0
    addx.b d4,d1
	rts
rolPlane1
    add.l d3,d3
    addx.l d2,d2
    addx.b d4,d3
    add.l d3,d3
    addx.l d2,d2
    addx.b d4,d3
	rts

parallaxInit1
	;adda.w #16*50,a3
    moveq #30,d5                 ; copy loaded sprite 31-times and rol it by 2 pixels each time -> 64 pixel endless loop
.nextSprite
    move.l a3,a1
    lea 16(a1),a1

    move.l a1,a0
    adda.w #((spriteDMAWidth/8)*(spriteParallaxHeight+1)*2),a0
    moveq #0,d4
    moveq #$f0/2,d6
    lsl #1,d6; = (spriteParallaxHeight-1)-1
    ; roll both planes, full view
.copySprite
    movem.l (a1),d0-d3
	cmpi #$e0,d6
	bls.b .rolOn
	btst #0,d5
	beq.b .slowCeiling
.rolOn
	bsr.b rolPlane0
	bsr.b rolPlane1
.slowCeiling
    movem.l d0-d3,(a0)
    moveq #16,d0
    adda.l d0,a0
    adda.l d0,a1
    dbra d6,.copySprite
	add.l a6,a3
	dbra d5,.nextSprite
parallaxCleanUp
    move.l #spriteParallaxBufferSize,d0
parallaxCleanUpSkip
    moveq #31,d7
    move.l spriteParMultiTable(pc),a0
    move.l spriteParallaxBuffer(pc),d1
    ;move.l d0,a0
    lsr.l #5,d0
    move.w #spriteParallaxCtlrWordLo,d2
    move.w #spriteParallaxCtlrWordHi,d3  ; preconfig list of parallax sprite starting adresses
.writeTable
    ;move.l #this,d1          ;!!!!!!!!!!!!!!!!!!!!
    move.l d1,(a0)+
    move.l d1,a1
    move.w d2,(a1)
    move.w d3,8(a1) ; preconfig sprite control words
    add.l d0,d1
    dbra d7,.writeTable
    move.l (sp)+,d0
    rts
parallaxInit2	; sprite parallax ocean
	IF 0=1	; only needed to calc anim scroll, then dump mem
	add.l #2976,a3
    moveq #30,d5                 ; copy loaded sprite 31-times and rol it by 2 pixels each time -> 64 pixel endless loop
    ;move.l a1,a0
.nextSprite
	;move.l a3,a1
    ;a.w #((spriteDMAWidth/8)*(186*2),a0
	lea 16(a3),a3
    moveq #0,d4
    move.w #183,d6	; roll both planes, different speed, full view
.copySprite
    movem.l (a3),d0-d3
    moveq #30,d7
    sub d5,d7
.1
    bsr rolPlane0
    bsr rolPlane1
    dbra d7,.1

    movem.l d0-d3,(a3)
    moveq #16,d0
    adda.l d0,a3
    dbra d6,.copySprite
	;add.l a6,a3
	dbra d5,.nextSprite
	ENDIF
    move.l #((spriteDMAWidth/8)*186*2)*32,d0
	bra parallaxCleanUpSkip
parallaxInit4
    moveq #30,d5                 ; copy loaded sprite 31-times and rol it by 2 pixels each time -> 64 pixel endless loop
.nextSprite
    move.l a3,a1
    lea 16(a1),a1

    move.l a1,a0
    add.l #((spriteDMAWidth/8)*(spriteParallaxHeight+1)*2),a0
    moveq #0,d4

    move.w #lv0parSprSlowExit-lv0parSprSlowEntry+94,d6; slow cntral view
.copySpriteB
    movem.l (a1),d0-d3
    btst #0,d5
    beq.b .skA
	bsr rolPlane1
.skA
    movem.l d0-d3,(a0)
    moveq #16,d0
    adda.l d0,a0
    adda.l d0,a1
    dbra d6,.copySpriteB

    move.w #(spriteParallaxHeight-1)/3-36,d6	; fast down view
.copySpriteC
    movem.l (a1),d0-d3
	btst #0,d5
    beq.b .skC0
	bsr rolPlane0
.skC0
	bsr rolPlane1
    movem.l d0-d3,(a0)
    moveq #16,d0
    adda.l d0,a0
    adda.l d0,a1
    dbra d6,.copySpriteC

    move.w #36,d6	; fast bottom view, 3 colors
.copySpriteD
    movem.l (a1),d0-d3
	bsr.w rolPlane0
	bsr.w rolPlane1
    movem.l d0-d3,(a0)
    moveq #16,d0
    adda.l d0,a0
    adda.l d0,a1
    dbra d6,.copySpriteD

    add.l a6,a3
    dbra d5,.nextSprite
	bra parallaxCleanUp

; #MARK: - PLAYER MANAGER BEGINS

plyManager

	lea plyBase(pc),a6
	tst.w plyCollided(a6)
	bne.w plyHitAnim
    tst.b plyExitReached(a6)
    bne plyFinal
	move.w plyJoyCode(a6),d7
	clr.l d5
	clr.l d6

;!!!: handle scrolling- and player-x-acceleration
    lea viewPosition(pc),a0
    move.l viewPositionAdd(a0),d2
	add.l d2,(a6);plyPosX
	;andi.w #$8000,2(a6)
plyJumpIn 		; needed for debugging to avoid scrolling
	move (a6),d0;plyPosX
	sub viewPositionPointer(a0),d0
	move.w d0,plyPosXABS(a6)
	asl.l #8,d2
	swap d2
	move.w d2,viewPositionAddObjAccX(a0)
;#MARK: player movement

handlePlayerMovement
	clr.l d4
	move.w plyAcclXCap(a6),d4
	move d4,d6
	lsr #1,d6
	add d6,d4
    swap d4
    ror.l #1,d4	; dynamic acceleration upto cap

    tst plyInitiated(a6)
    ;bmi.b .plyExit
    bne.b .plyInit

.plyGoRight
	btst #JOY_RIGHT,d7
	beq.b .plyGoLeft
    tst plyPosAcclX(a6)
    bmi.b .plyInitPosX
	add.l d4,plyPosAcclX(a6)
	bra.b .plyTstBoundRgt
.plyInit
	move.w #$10,plyAcclXCap(a6)
    subq #1,plyInitiated(a6)
    bne.b .initRuns
	move.w #plyAcclXMin,plyAcclXCap(a6)
.initRuns
	moveq #1,d6
	;swap d6
	ror.w #1,d6	;->$2000
    sub.l d6,plyPosAcclX(a6)
    bra.b .plyUpDown
.plyInitPosX
    move.l d4,plyPosAcclX(a6)
	bra.b .plyTstBoundRgt
.plyGoLeft
	btst #JOY_LEFT,d7
	beq.b .plyZeroXAccl
    tst plyPosAcclX(a6)
    bgt.b .plyInitNegX
	sub.l d4,plyPosAcclX(a6)
    bra.b .plyTstBoundLft
.plyInitNegX
    neg.l d4
    move.l d4,plyPosAcclX(a6)
.plyTstBoundLft
	cmpi #91,d0
	bgt.b .plyUpDown
	move.l viewPosition+viewPositionPointer(pc),d0
	moveq #91,d5
	swap d5
	add.l d5,d0
    move.l d0,(a6);plyPosX
    bra.b .plyZeroXAccl
.plyTstBoundRgt
	cmpi #330,d0
	blt.b .plyUpDown
	move.l viewPosition+viewPositionPointer(pc),d0
	move #330,d5
	ext.l d5
	swap d5
    add.l d5,d0
    move.l d0,(a6);plyPosX
.plyZeroXAccl
    clr.l plyPosAcclX(a6)

.plyUpDown
	;move d7,d6
	;asl #1,d6
	;eor d6,d7
	btst #JOY_DOWN,d7
  	beq.b .plyGoUp
    tst plyPosAcclY(a6)
    bmi .plyInitPosY
	add.l d4,plyPosAcclY(a6)
	bra.b .plyTstBoundDwn
.plyInitPosY
    move.l d4,plyPosAcclY(a6)
	bra.b .plyTstBoundDwn
.plyGoUp
	btst #JOY_UP,d7
	beq.b .plyZeroYAccl
    tst plyPosAcclY(a6)
    bgt .plyInitNegY
	sub.l d4,plyPosAcclY(a6)
    bra .plyTstBoundUp
.plyInitNegY
    neg.l d4
    move.l d4,plyPosAcclY(a6)
.plyTstBoundUp
	cmpi #57,plyPosY(a6)
	bgt.b .plyYfinish
    move #57,plyPosY(a6)
    bra.b .plyZeroYAccl
.plyTstBoundDwn
	cmpi #289,plyPosY(a6)
	blt.b .plyYfinish
    move #289,plyPosY(a6)
.plyZeroYAccl
    clr.l plyPosAcclY(a6)



.plyYfinish
    moveq #-7,d6
    add.w plyPosY(a6),d6
    lsr #4,d6
    move.w d6,plyPosYDyn(a6); dynamic offset, used for vertical scrolling    ;
	subq #3,d6
	move.w d6,plyPosYDynAlt(a6)
    add.w #displayWindowStop+$100-viewUpClip-11,d6
    lea bobBlitCutdown+2(pc),a0
    move d6,(a0)    ; modify y-cut
;#MARK: Player shot control
.plyShotControl
	;jtbra irqRetPlyManager
    IFEQ RELEASE
;   keypress code 1 -> weap down, 2-> weap up
    cmpi.b #$02,keycode
    bne .smooth1
    cmpi.b #3,plyWeapUpgrade(a6)
    bge .smooth2
    add.b #1,plyWeapUpgrade(a6)
    move.b plyWeapUpgrade(a6),d0
    subq.b #1,d0
    lsl #5,d0
    addq #1,d0
    move.b d0,plyWeapSwitchFlag(a6)
   	st updateStatDispExtra	; init redraw status pixels
	;ADDSCORE 10
	PLAYFX 19
    not.b keycode
.smooth1
    cmpi.b #$01,keycode
    bne .smooth2
	tst.b plyWeapUpgrade(a6)
    beq .smooth2
    sub.b #1,plyWeapUpgrade(a6)
    move.b plyWeapUpgrade(a6),d0
    add.b #1,d0
    lsl #5,d0
    bset #7,d0
    subq.b #1,d0
	PLAYFX 19
    move.b d0,plyWeapSwitchFlag(a6)
   	st updateStatDispExtra	; init redraw status pixels
	ADDSCORE 10

    not.b keycode
.smooth2
    ENDIF


; keypress code ends

    clr.l d6
	move.b plyFire1Auto(a6),d6
	bpl .autoShoot
	clr.w d0
	btst #STICK_BUTTON_ONE,d7; check firebutton 1 from stick read code
    beq .released
.fbPressed
    addq #1,d0                   ; yes!
    add.b d0,plyFire1Flag(a6)
    bra.b .shotManager
.released
    clr.b plyFire1Flag(a6)
    ;andi.b #$1,plyShotCnt(a6)
.shotManager


    move.b plyFire1Auto(a6),d6
    tst.b d0
    beq plyNoFire

    move.b #1,plyFire1Flag(a6)
.plyShoot                                              ; init player shot

    move.b plyWeapUpgrade(a6),d1
    andi #3,d1

    move.l ([.shotPointers.W,pc,d1*4]),d7
    move.l d7,plyAnimPointer(a6)   ; pointer to animlist
    move.b (.freq.W,pc,d1.w),plyFire1Auto(a6)               ; shot frequency
        jmp ([(.weapEmit).w,pc,d1.w*4])
.weapEmit
	dc.l .initShot, .initShot,.initShot,.extra2
.shotPointers
    dc.l cPlyShtAAnimPointer,cPlyShtBAnimPointer,cPlyShtCAnimPointer,cPlyShtDAnimPointer
.freq
    dc.b %111, %1111,%10111,%11011
.init
	move.l plyAnimPointer(a6),a5		; init shot
;	move.l cPlyShtEAnimPointer(pc),a1
	move.w animTablePointer+2(a1),d4
	;move.l ([cExplLrgAnimPointer,pc,,d4
	add (a6),d5;plyPosX
	add plyPosY(a6),d6
	moveq #1,d3
	bra objectInitSprite
.extra2
.extra1
	;bra .initSpread
		moveq #-10,d5
	moveq #-63,d6
	move.l cPlyShtGAnimPointer(pc),a1
	bsr .init								; upper mid spread
	tst.l d6
	bmi.w plyNoFire
	move.b #attrIsPlyShot!attrIsSprite,objectListAttr(a4); attribs
	move #42<<6,d1
	add.w d1,objectListAccX(a4)     ; add x-accl to standard x-
	move.w #-250,objectListAccY(a4)

	moveq #-10,d5
	moveq #-23,d6
	move.l cPlyShtHAnimPointer(pc),a1
	bsr .init								; lower mid spread
	tst.l d6
	bmi.w plyNoFire
	move.b #attrIsPlyShot!attrIsSprite,objectListAttr(a4); attribs
	move #42<<6,d1
	add.w d1,objectListAccX(a4)     ; add x-accl to standard x-
	move.w #250,objectListAccY(a4)
	bra.b .initShot


	;bra.w .initShot

.extra3
	bra.b .initShot

.autoShoot                                          ; fire row of shots automatically after first init
    subq.b #1,plyFire1Auto(a6)
    bmi.w .finalFX
    move.b plyFire1Auto(a6),d0
    move d6,d7
    moveq #%111,d5
    and d5,d7
    bne plyNoFire

	moveq #011,d5
	and d5,d6
	bne .initSpread
	move.l cPlyShtEAnimPointer(pc),a1
	moveq #-22,d5
	moveq #-73,d6
	bsr .init		; lower and upper end spread
	tst.l d6
	bmi.w plyNoFire
	move.b #attrIsPlyShot!attrIsSprite,objectListAttr(a4); attribs
	move #42<<6,d1
	add.w d1,objectListAccX(a4)     ; add x-accl to standard x-momentum / current scrollspeed
	move.w #-550,objectListAccY(a4)
	move.l cPlyShtFAnimPointer(pc),a1
	moveq #-22,d5
	moveq #-13,d6
	bsr .init
	tst.l d6
	bmi.w plyNoFire
	move.b #attrIsPlyShot!attrIsSprite,objectListAttr(a4); attribs
	move #42<<6,d1
	add.w d1,objectListAccX(a4)     ; add x-accl to standard x-
	move.w #550,objectListAccY(a4)
	;bra.b .initShot
		bra.w plyNoFire

.initSpread
    sub.b #4,plyFire1Auto(a6)
.initShot

	move.l plyAnimPointer(a6),a5
		;move.l cPlyShtDAnimPointer(pc),a5
	;move.l cPlyShtGAnimPointer(pc),a5
	move.w animTablePointer+2(a5),d4

    moveq #-53,d5
    add (a6),d5;plyPosX
    move plyPosY(a6),d6

    move.b plyShotCnt(a6),d7
    addq.b #1,plyShotCnt(a6)
    andi #$7,d7
    ;clr d7     ; uncomment for all shots on same y-position
    sub.w (plyShotYOffset.w,pc,d7*2),d6
    moveq #1,d3
    bsr objectInitSprite

    tst.l d6
    bmi plyNoFire
    ;move #,objectListHit(a4); hitpoints
    move.b #attrIsPlyShot!attrIsSprite,objectListAttr(a4); attribs
    move #42<<6,d1
	add d1,objectListAccX(a4)     ; add x-accl to standard x-momentum / current scrollspeed
	;move #0,objectListAccX(a4)     ; add x-
    move (plyShotYSpread.w,pc,d7*2),d7
    sub.w d7,objectListAccY(a4)
    PLAYFX 1
    bra.b plyNoFire
.finalFX
    PLAYFX 2
    bra.b plyNoFire
plyShotYOffset      ; + = upper position
.y=39
;    dc.w .y,.y+4,.y-4,.y+2
;    dc.w .y-4,.y+6,.y-8,.y+8
    dc.w .y,.y+2,.y,.y-2
    dc.w .y-4,.y+3,.y+4,.y-3
plyShotYSpread      ; + = goes up
    dc.w 0,0,0,0
    dc.w 0,0,0,0
plyNoFire

   ; fade colors of player shots when switching weaponry


    tst.b plyWeapSwitchFlag(a6)
    beq.b plyBoundaries   ; no colorfade going on
    bpl.b .switchup       ; msb -> fade up or down

    sub.b #1,plyWeapSwitchFlag(a6)
    bra.b .switched
.switchup
    add.b #1,plyWeapSwitchFlag(a6)
.switched
    clr.w d0
    move.b plyWeapSwitchFlag(a6),d0
    bclr #7,d0
    lsr #1,d0
    move.b d0,d1
    andi.b #%1111,d1
    bne.b .playerColors
    clr.b plyWeapSwitchFlag(a6)
    bra.w plyBoundaries
.playerColors
	bsr dynamicPlayerColors

plyBoundaries
    move.w plyAcclXCap(a6),d5
	ext.l d5
	swap d5
	move.l plyPosAcclX(a6),d0; check if ply x-accl
	;move.w plyPosAcclX(a6),d0; check if ply x-accl is too high -> clear accl
    beq.b .chkYAccl
    bmi.b .chkXNegAccl
    ;swap d0
 ;   move.w plyAcclXCap(a6),d5
    cmp.l d5,d0
    blt.b .wrtXAccl
.capXAccl
    move.l d5,d0
    bra.b .wrtXAccl
.chkXNegAccl
    ;swap d0
;    move.w plyAcclXCap(a6),d5
    neg.l d5
    cmp.l d5,d0
    bgt.b .wrtXAccl
    move.l d5,d0
.wrtXAccl
	asr.l #2,d0
	add.l d0,(a6);plyPosX

.chkYAccl                       ; same for ply y-accl
    move.w plyAcclYCap(a6),d5
    ext.l d5
    swap d5
	move.l plyPosAcclY(a6),d0
    beq.b plyCollision
    bmi.b .chkYNegAccl
;    move.w plyAcclYCap(a6),d5
    cmp.l d5,d0
    blt.b .wrtYAccl
.capYAccl
    move.l d5,d0
    bra.b .wrtYAccl
.chkYNegAccl
    neg.l d5
    cmp.l d5,d0
    bgt.b .wrtYAccl
    move.l d5,d0
.wrtYAccl
	asr.l #2,d0
	add.l d0,plyPosY(a6)

; #MARK: player collission
plyCollision
	move $dff00e,d0
    move d0,d1
	IFEQ PLAYERCOLL
	bra plyColQuit
	ENDIF

    tst plyCollided(a6)         ; is already dying
	bne plyColQuit
    tst.b plyDistortionMode(a6)     ; weapon downgrading?
    bne plyColQuit

    andi #2^10+2^9,d0		; registered sprite (2 or 4) collission?
    bne .boundingBox
    btst #1,d1               ; hit background?
    bne plyBackgroundCheck
	rts

;	bra plyColQuit
.boundingBox

						; in case of shot recheck with bounding box
;d0, d1, a5
	move.l objectList(pc),a3
    moveq #4,d4
    sub.l d4,a3
    clr.w d6
    clr.w d1
    clr.w d3
    move (a6),a4;plyPosX
    move plyPosY(a6),a5
    move.l animDefs(pc),a6
	move objCount(pc),d7
    bra chkPlyColLoop
chkPlyCol
.checkEntry
   	adda.w d4,a3
	tst (a3);objectListAnimPtr
	beq.b .checkEntry
	move (a3),d1;objectListAnimPtr
    lea (a6,d1),a2       ; Accelerate x and y - read from animDefAcc

  	move.b animDefType(a2),d3
    lea ([(objectDefs).w,pc],d3*8),a2   ; Pointer to animDefinitions
    move.b objectDefAttribs(a2),d0
    bpl.b chkPlyColLoop		; no sprite? Check right now
	btst #4,d0
	bne.b chkPlyColLoop     ; player shot? Skip coldect
    ;#FIXME: Player shot chk needed?
	btst #6,d0
	bne.b chkPlyColLoop     ; bonus sprite icon? Skip too
	move.l plyBoundBox(pc),d2
	move.l plyBoundBox+4(pc),d6
.calcDist
	;bra spriteHit
	;  bounding box for colcheck
	move.w objectListX(a3),d1
	sub.w a4,d1		; sub plyPosX

	;move.l plyBoundBox(pc),d5
	move.l d2,d5
	cmp d5,d1
	bgt.b chkPlyColLoop
	swap d5
	cmp d5,d1
	blt.b chkPlyColLoop

	;cmp2.w (plyBoundBox,pc),d1
	;bcs.b chkPlyColLoop
	move.w objectListY(a3),d0
	sub a5,d0

	;move.l plyBoundBox+4(pc),d5
	move.l d6,d5
	cmp d5,d0
	bgt.b chkPlyColLoop
	swap d5
	cmp d5,d0
	bge.b spriteHit

	;cmp2.w (plyBoundBox+4,pc),d0
;	bcc.b spriteHit
chkPlyColLoop
	dbra d7,chkPlyCol
fuckIt
    rts
plyBoundBox	; collission box
	dc.w -31,-19	; x-bound left / right bound
	dc.w -47,-36	; y-bound up / down

    			; adjust colors in player aprite
dynamicPlayerColors
    lea CUSTOM,a4

.palReg2 set $180+$a
.palReg4 set $180+$12
.palReg3 set $180+$2a
.palReg5 set $180+$32
	move.l colorFadeTable(pc),a0
	lea 192(a0),a1
	lea 2+(192*2)(a0),a2
						; write shot colors to color regs
    move.l (a0,d0*4),d1
    move.l (a1,d0*4),d3
	move.l copColSprite(pc),a3
	tst.l a3
	beq.b .noSpriteColor
    move.w (a2,d0*4),d2
	move.w d3,(a3)
.noSpriteColor
    move #%1110000000100000,BPLCON3(a4)
    move.w d1,.palReg2(a4)
    move.w d1,.palReg4(a4)
    move.w d1,.palReg3(a4)
    move.w d1,.palReg5(a4); hi color byte -> 4 color regs
    move.w d2,.palReg2-$8(a4)		; addtional shading in player sprite
    swap d1
    swap d2
    move #%1110001000100000,BPLCON3(a4)
    move.w d1,.palReg2(a4)
    move.w d1,.palReg4(a4)
    move.w d1,.palReg3(a4)
    move.w d1,.palReg5(a4)			; low color byte -> 4 color regs
    move.w d2,.palReg2-$8(a4)
	rts

spriteHit
    clr (a3);objectListAnimPtr   ; kill bullet object
	clr.l objectListX(a3)
	clr.l objectListY(a3)
	subq #1,objCount
    bra.w playerHit
plyBackgroundCheck

    ; hardware signals background hit; now recheck with colbox
	jmp ([(plyColJmp).w,pc])	;simply check bck most of the time; if dialogue, then do colbox chk
plyColJmp
	dc.l 0
plyChkBox

	move bobCountHitable(pc),d6
	beq.b .quit
	move.l collidingList+8(pc),a3
    move.l a3,a2
    lea collListBobOffset(a2),a2
	    move.l a3,a5    ; load adress of collision table
    moveq #collListEntrySize,d4
    lea collTableYCoords(a2),a6
    moveq #-$38,d0
	add.w plyPos+plyPosY(pc),d0
    add.w plyPos+plyPosYDynAlt(pc),d0
    moveq #-$20,d1
    add.w plyPos+plyPosXABS(pc),d1
	;add.w plyPos+plyPosX(pc),d1
	;sub.w viewPosition+viewPositionPointer(pc),d1
	bra.b .colLoop
.chkBob

	move.l (a6),d5
	cmp d5,d0
	bgt.b .noYCol
	swap d5
	cmp d5,d0
	blt.b .noYCol

	move.l 4(a6),d5
	cmp d5,d1
	bgt.b .noYCol
	swap d5
	cmp d5,d1
	bge.b playerHit

;	cmp2.w (a6),d0 ;chk y-collissionbox collTableYCoords
;	bcs.b .noYCol   ; is higher or lower? Skip!
;	cmp2.w 4(a6),d1; modified pointer to collTableXCoords
;	bcc.w playerHit
.noYCol
    adda.l d4,a6
.colLoop
    dbra d6,.chkBob
.quit
    rts

;recheck with bckchk
plyChkBck

    lea bobAdrTable(pc),a2
	move.l mainPlanesPointer+8(pc),a1
    moveq #-49,d4;y-offset
    moveq #-26,d5;x-offset
    move.w #4*mainPlaneDepth*mainPlaneWidth,d3
.hitBckChk
    clr.l d1
    move d4,d1
    add.w plyPosY(a6),d1         ; load player y-coords
    ;ALERT alert03,d1
    move.w (a2,d1.w*2),d1     ; y bitmap offset
    adda.l d1,a1
    move d5,d1
    add.w plyPosXABS(a6),d1
    ;add.w (a6),d1	; load player x-coords – plyPosX
    ;sub.w viewPosition+viewPositionPointer(pc),d1
    lsr #3,d1
    adda.l d1,a1	; add x-byte-offset

	tst.b (a1)	; more tolerance up and down
	bne playerHit
	tst.w (a1,d3.w)
	bne playerHit
	tst.b (a1,d3.w*2)
	bne playerHit
.quit
	rts
playerHit
	;#!!!:Temp code to pause game when player is hit
	;lea gameInActionF(pc),a4
    ;bchg#0,(a4)


	lea plyPos(pc),a6

		move.l weapDstrAnimPointer(pc),a4
		move.w animTablePointer+2(a4),d4 ;add  object to control distortion mode
    move objectListX(a0),d5
    add.w #$15,d5
    moveq #-40,d6
    add collTableYCoords(a3),d6                    ; get y-coord from shot
    clr d3
    bsr.w objectInit
	tst.l d6
	bmi.w .quit

    subq.b #1,plyWeapUpgrade(a6)         ; destroy current weapon
;    addq.b #1,plyWeapUpgrade(a6)         ; destroy current weapon
    bmi.b .initDeath
.cheatRetPoint
    move.b plyWeapUpgrade(a6),d1

    move d1,d0
    addq.b #1,d1
    lsl #5,d1
    bset #7,d1
    subq.b #1,d1
    move.b d1,plyWeapSwitchFlag(a6)
    PLAYFX 13

    cmpi.w #plyAcclXMin,plyAcclXCap(a6)
    bls.b .minReached
    sub.w #2,plyAcclXCap(a6)
	sub.w #2,plyAcclYCap(a6)
.minReached
	;move.l a6,a1
	;st plyDistortionMode
	st updateStatDispExtra; init redraw status pixels
    ;lea plyPos(pc),a0           ; init particle rain
	move.w plyPosXABS(a6),d3;plyPosX
	;sub.w viewPosition+viewPositionPointer(pc),d3
    sub #10,d3
	lsl #4,d3
	move.w plyPosY(a6),d4
    sub #45,d4
	lsl #8,d4
    clr.w d5		;x-acc
    clr.w d6		;y-acc
    lea emitterExtraLoss(pc),a0
    jmp particleSpawn			; apawn particle rain

    ; #MARK: player death
.cheater
    addq.b #1,plyWeapUpgrade(a6)         ; destroy current weapon
	bra .cheatRetPoint
.initDeath
	tst.b plyCheatEnabled(a6)
	bne.b .cheater
	lea AudioSoundStatus(pc),a5
	btst #1,(a5)		; fx switched off?
	beq.b .keepMusic
	clr.l d0
	bsr.w mt_mastervol
.keepMusic
    move #20,frameCompare+2
	move #1,plyCollided(a6)       ; init playerhit animation
    clr.l plyPosAcclX(a6)
    clr.l plyPosAcclY(a6)
    clr.l viewPosition+viewPositionAdd
	lea storePlayerPos(pc),a5
	move.w plyPosX(a6),(a5)
	move.w plyPosY(a6),2(a5)

	tst.b plyContinueAvail(a6)
	beq.b .quit	; no continues
	move.l showContAnimPointer(pc),a5	; add continue object
	move.w animTablePointer+2(a5),d4
	moveq #1,d3	; init as shot -> ensures object slot is available
	bsr objectInit
.quit
    rts
storePlayerPos
	dc.w 0,0
plyHitAnim                  ; animation fatal player was hit

    move #1,frameCompare+2         ; slow down frame update
;    lea emitterExtraLoss(pc),a0

.noInitDebris
;    lea emitterKillA(pc),a0
	addq #1,plyCollided(a6)

	lea transitionFlag(pc),a1

	cmpi #370,plyCollided(a6)
	beq .initFade

	moveq #7,d7				 ; slow down frame
	cmpi #200,plyCollided(a6)
    bhi .frameRate

	moveq #5,d7
	cmpi #180,plyCollided(a6)
    bhi .frameRate

	moveq #3,d7
    cmpi #160,plyCollided(a6)
    bhi .frameRate

	;cmpi.w #110,plyCollided(a6)
	;bhi.b .quit
    cmpi #70,plyCollided(a6)
    bhi .spawnDebris			; debris

    cmpi #61,plyCollided(a6)
    beq.b .hidePlayer			; playership hide

    cmpi #60,plyCollided(a6)
    beq.b .bigExplosion			; playership explodes

    lea emitterKillA(pc),a0
    cmpi #20,plyCollided(a6)
    beq .spawnParticles							; init particle rain

    cmpi #15,plyCollided(a6)				; init particle rain
    beq .spawnParticles

    lea emitterKillB(pc),a0
    cmpi #10,plyCollided(a6)
    beq.w .spawnParticles

    lea emitterKillC(pc),a0
    cmpi #2,plyCollided(a6)
    beq.b .spawnParticlesFX
.quit
	rts
.frameRate
	lea frameCompare+2(pc),a0
	move d7,(a0)
	rts
.hidePlayer
	move.w #330,plyPosY(a6)
	rts
.bigExplosion
    move.b #5,fxInit
   	move.l cExplLrgAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
    lea storePlayerPos(pc),a1
	move.w (a1),d5;plyPosX
	sub #90,d5
	move.w 2(a1),d6
    sub.w #50,d6
    clr d3
    ;rts
    bsr objectInit	; big explosion to cover loss of player sprite
    tst.l d6
    bmi.b .quit
    move.b #attrIsNotHitable,objectListAttr(a4); attribs
    rts
.initFade

	lea forceExit(pc),a0
	st.b (a0)	; init fade and quit
	lea gameStatus(pc),a0
	tst.b plyContinueAvail(a6)
	bmi.b .keepPushing	; continue flagged
	move.b #statusTitle,(a0)
	rts
.keepPushing
	sub.b #1,(a0)
	bra resetScores
.spawnParticlesFX
	PLAYFX 14
.spawnParticles

    lea storePlayerPos(pc),a1           ; init particle rain
	move.w (a1),d3;plyPosX
	sub.w viewPosition+viewPositionPointer(pc),d3
    sub #20,d3
	lsl #4,d3
	move.w 2(a1),d4

    sub.w #46,d4
	lsl #8,d4
    clr.w d5    ; x-acc
    clr.w d6    ; y-acc
    jmp particleSpawn(pc)

.spawnDebris
	  lea storePlayerPos(pc),a1
	move plyCollided(a6),d1
	lsr #2,d1
	andi #7,d1

	move.w (a1),d5;plyPosX
	moveq #40,d3
    sub d3,d5
	move.w 2(a1),d6
    sub.w d3,d6
debrisEntry
    clr d3
    jmp ([(.debrisCases).W,pc,d1.w*4])
.debrisCases
	dc.l .debrisA,.debrisA,.debrisC,.debrisD
	dc.l .debrisF,.debrisH,.debrisG,.debrisH
.debrisA
		    move.b #3,fxInit

	move.l cExplSmlAnimPointer(pc),a4
	bra.b .initObject
.debrisC
	move.l cExplMedAnimPointer(pc),a4
	sub #20,d5
	bra.b .initObject
.debrisD
	    move.b #4,fxInit
	sub #20,d5
	move.l cExplMedAnimPointer(pc),a4
	bra.b .initObject
.debrisF
	move.l debrisA2AnimPointer(pc),a4
	bra.b .initObject
.debrisG
	move.l debrisA3AnimPointer(pc),a4
	bra.b .initObject
.debrisH
	move.b #5,fxInit
	move.l debrisA4AnimPointer(pc),a4
.initObject
	move.w animTablePointer+2(a4),d4

	bsr objectInit
	;moveq #-1,d6
	tst.l d6
	bmi.b .quit /was: .noInitDebris
	move.b #attrIsNotHitable,objectListAttr(a4); attribs
	clr.w d7
    move.b $bfe601,d7
;	lea$bfe601,a3
    move.b $dff006,d6
    andi #3,d6
    rol.b d6,d7
	;move.w $dff006,d6
	;eori d7,d6
    lsl #3,d7
    sub #740,d7
    move d7,objectListAccY(a4)
	move.b #31,objectListCnt(a4)
	;clr.w d7
	move.w $dff006,d7
	move.b $bfe601,d6
	eor.b d6,d7
	andi #$1f,d7
	moveq #$c,d6
	sub d7,d6
    lsl #7,d6
    move d6,objectListAccX(a4)
.quit
	rts
plyColQuit
plyColQuitFromScore
plyFinal
	rts
    ;bra irqRetPlyManager

    IF Demo=1

exitTextCases
    dc.l	exitTextA,exitTextB,exitTextD
    dc.l 	exitTextL,exitTextE,exitTextF,exitTextG
	dc.l 	exitTextH,exitTextI,exitTextJ,exitTextK
exitTextA
	dc.b "      THIS WAS RESHOOT R DEMO   ",0,0
exitTextB
	dc.b "      THIS WAS RESHOOT R DEMO   ",0,1 ; fade in picture
exitTextD
	dc.b "        THANK YOU FOR PLAYING ",0,0
exitTextE
    dc.b "      RESHOOT R COPYRIGHT 2019",0,0
exitTextF
    dc.b "       BY RICHARD LOEWENSTEIN",0,0
exitTextG
    dc.b "      HUGS TO KEVIN AND MARTIN",0,0
exitTextH
    dc.b "  KUDOS TO MY SUPPORTERS ON PATREON",0,0
exitTextI
    dc.b "   PLEASE SUPPORT RETRO DEVELOPMENT",0,-1
exitTextJ
    dc.b "   RESHOOT=RICHARD?LOEWENSTEIN=DE",0,0
exitTextK
    dc.b " ",0,-1
exitTextL
    dc.b " ",0,0
    even
    ELSE
exitTextCases
    dc.l	exitTextA,exitTextB,exitTextD
    dc.l 	exitTextE,exitTextL,exitTextF,exitTextG
	dc.l 	exitTextH,exitTextI,exitTextJ,exitTextK
exitTextA
    dc.b "           CONGRATULATIONS",0,0
exitTextB
    dc.b "           CONGRATULATIONS",0,5 ; fade in picture
exitTextD
    dc.b "  YOU DESTROYED THE EVIL TARS FLEET",0,0 ; keep picture
exitTextE
    ;dc.b "ARYN IS SAFE TO TRAVEL THE STARS NOW",0,4
    dc.b " ARYN MAY TRAVEL A SAFE NIGHTSKY NOW",0,4
exitTextF
    dc.b "      RESHOOT R COPYRIGHT 2019",0,-1	; fade out picture
exitTextG
    dc.b "       BY RICHARD LOEWENSTEIN",0,0
exitTextH
    dc.b "      HUGS TO KEVIN AND MARTIN",0,1
exitTextI
    dc.b "  KUDOS TO MY SUPPORTERS ON PATREON",0,2
exitTextJ
    ;dc.b "   THANK YOU FOR PLAYING RESHOOT R",0,3
    dc.b "       RESHOOT WILL RETURN",0,3
exitTextK
    dc.b " ",0,-1
exitTextL
    dc.b " ",0,0
    even
    ENDIF
; #MARK: PLAYER MANAGER ENDS

; #MARK: - OBJECT MOVE MANAGER

objectMoveManager
	move.l animDefs(pc),a5	; loaded at animlooper
	move.l objectList(pc),a6
    moveq #4,d2
    sub.l d2,a6
	clr.l d0
    moveq #2,d2
	move objCount(pc),d7
	bra animLooper
animLoop
    moveq #4,d0
    moveq #8,d4
.checkEntry
   	adda.l d0,a6
	tst (a6);objectListAnimPtr
	beq.b .checkEntry
	
	move (a6),d1;objectListAnimPtr
.2
    movem.w (a5,d1.w),d5/d6       ; Accelerate x and y - read from animDefAcc

    add.w d5,objectListAccX(a6)
    add.w d6,objectListAccY(a6)

	movem.w objectListAccX(a6),d5/d6	; movem.w sign extendeds automatically
	lsl.l d4,d5
    add.l d5,objectListX(a6)
	lsl.l d4,d6
    add.l d6,objectListY(a6)

	subq.b #1,objectListCnt(a6)
	beq.b .stepEnds
		dbra d7,.checkEntry

	bra irqDidObjMoveManager	; back to irq
.stepEnds
    lea (a5,d1),a0
    move animDefEndWaveAttrib(a0),d0
    cmpi.w #$f0,d0
    bge.b .initcode
.bobInitNextStep
	addq #animDefSize,(a6)    ;objectListAnimPtr. No. init next animation step
.1	move (a6),d0;objectListAnimPtr
    move.l animDefs(pc),a5
    move.b animDefCnt(a5,d0),objectListCnt(a6)
	dbra d7,animLoop

	bra irqDidObjMoveManager	; back to irq
.initcode
    sub.w #$f0,d0
    moveq #animDefSize*2,d1
    jmp ((.codeCases).w,pc,d0*4)

.codeCases
    bra.w .attrNext
    bra.w .attrLoop
    bra.w .attrXacc
    bra.w .attrYacc
    bra.w .attrXpos
    bra.w .attrYpos
    bra.w .attrTrig
    bra.w .attrRept
.attrXacc
    add d1,(a6)

    move animDefNextWave(a0),d4

    move d4,objectListAccX(a6)
    bra.w .1
.attrYacc
    add d1,(a6)
    move animDefNextWave(a0),objectListAccY(a6)
    bra.w .1
.attrXpos
    add d1,(a6)
    clr.w d5

    tst.l objectListMyParent(a6)
    bne.b .noChildX
    move viewPosition+viewPositionPointer(pc),d5
.noChildX
    add.w animDefNextWave(a0),d5
    move d5,objectListX(a6)
    move.l viewPosition+viewPositionAdd(pc),d5
    lsl.l d4,d5
    move.w d5,objectListAccX(a6)
    bra .1
.attrYpos
    add d1,(a6)
    move animDefNextWave(a0),objectListY(a6)
    clr.w objectListAccY(a6)
    bra.w .1
.attrTrig           ; four triggers available
                    ; bits 8&9 determine triggerslot (256/512)
                    ; bit 10 determines global(0) or objectrelated(1) trigger (1024)
                    ; if trigger>128    -> pause animList until trigger<>0
                    ; if trigger<128    -> write value to trigger

    move.w animDefNextWave(a0),d4
    move d4,d5
    lsr #8,d5
    btst #2,d5
    bne.b .objectTrigger
	lea (animTriggers,pc),a5;globalTrigger
	bra.b .triggerType
.objectTrigger
	lea objectListTriggers(a6),a5
.triggerType
    andi #3,d5
    tst.b d4
    bpl.b .noWait

    tst.b (a5,d5)       ; pause animList
    beq .1

    clr.b d4
    move.b d4,(a5,d5) ; unpause animList
    add d1,(a6)	; next anim step
    bra.w .1
.noWait
    add d1,(a6)	; next anim step
    move.b d4,(a5,d5); write value to trigger
.wait
	bra.w .1

.getNext
    add d1,(a6)
    bra.w .1

.attrRept

    ;clr objectListAccX(a6)
    move.w animDefNextWave(a0),d4
    move.b d4,objectListLoopCnt(a6)
    bra.w .getNext
.attrLoop                               ; loop endlessly if rept0

        tst.b objectListLoopCnt(a6)
    beq.b .endless
    sub.b #1,objectListLoopCnt(a6)   ; else countdown
    beq.b .getNext
.endless
    clr.w d4
    move.w animDefNextWave(a0),d4
    sub d4,(a6)
    bra.w .1
    ;moveq #4,d4
    subq.b #1,d4
    moveq #animDefSize,d0
.add
    sub d0,(a6)
    dbra d4,.add
    bra.w .1
.attrNext
	move.w animDefNextWave(a0),d4
	cmpi.b #$f0,d4
	beq.b .animClrBob
.cont		; execute individual code
	;moveq #animDefSize*2,d0
	;add d0,(a6);objectListAnimPtr
		add #animDefSize*2,(a6);objectListAnimPtr
    cmpi.l #$00f000f0,animDefSize(a0)                          ; code was last entry? yes, then delete bob
    beq .toLiveAndDie                                ; bit strange jump but frees up a0-reg
	lea -(*-.1)(pc),a5
    jmp ([(bobCodeCases).W,pc,d4])  ; continues at .1
;FIXME: Replace objectListAnimPtr.w with objectListAnimPtr.l everywhere
.toLiveAndDie
	;ALERTSETLINE 10
    lea 6(pc),a5
    jmp (a5)
.animClrBob
    clr (a6);objectListAnimPtr
	;clr.l objectListX(a6)
	;clr.l objectListY(a6)
	clr.l objectListMyParent(a6)
	;bra animLooper
	subq #1,objCount
    btst.b #1,objectListAttr(a6)
    beq animLooper           ; is parent? No!
; is Parent, yes!

    lea objectList+4(pc),a5      ; yes
    move.l (a5),a5      ;  object data table with bob offset

    subq.l #4,a5
    move.w objCount(pc),d0

    ;sub.w spriteCount(pc),d0
    ;ALERT alert02,d0
	bra .findAllChildren
	;add.w #20,d0
.findObject     ; loop through object list
    moveq #4,d4
.loop

    REPT 10
   	adda.w d4,a5
	tst (a5);objectListAnimPtr
	bne.b .foundEntry
    ENDR
    bra.b .loop
.foundEntry
    move.l a5,a0	; current object->a0
    cmp.l objectListMyParent(a0),a6
	beq.b .foundChild	; is child of main object?
    dbra d0,.findObject
	bra animLooper
.foundChild
    btst.b #1,objectListAttr(a0)	; object is child. Is it parent too?
	beq.b .justChild		; no, just child
	clr (a0);objectListAnimPtr	; delete child
	clr.l objectListMyParent(a0)
	cmp.l a6,a0
	bls.b .lowerEntryA
    subq #1,d7
.lowerEntryA
	subq #1,objCount
	beq.b animLooper
    movea.l objectListMyChild(a0),a0	; get child of child
    bra.b .foundChild	; and delete
.justChild
	clr (a0);objectListAnimPtr
	clr.l objectListMyParent(a0)
	cmp.l a6,a0
	bls.b .lowerEntryB
    subq #1,d7
.lowerEntryB
	subq #1,objCount
	beq.b animlooper

    lea objectList+4(pc),a5      ; yes
    move.l (a5),a5
    move.w objCount(pc),d0
    sub.w spriteCount(pc),d0
    ;subq #1,d0
    tst.w d0
    bmi.b animLooper
.findAllChildren
    dbra d0,.findObject
animLooper
    move.l animDefs(pc),a5
    moveq #8,d4
	dbra d7,animLoop

    bra irqDidObjMoveManager

; called individually from animDefs.list. Init by animDefs
    include bobCustomCode.s

; #MARK:  - OBJECT LIST MANAGER

objectListManager
; Eingangswerte:
    ;A2 =   objectList
    ;A3 =   bobpostab
    ;A4 =   objectDefinitionTable
    ;A5 =   spritePosMem
    ;A6 =   bobDrawList

	;ALERTSETLINE 16
	;move.l spritePosMem(pc),d0
	;ALERT alert01,d0

    lea animBasicOffsets(pc),a0 ; predefine basic anim offsets
    move.b AudioRythmAnimOffset(pc),d6
    andi #$f,d6
    move d6,(a0)

    lea vars(pc),a0
    clr.w spriteCount+2-vars(a0); 2.w = temp counter, static 1.w = static
    clr shotCount-vars(a0)
    clr bobCountHitable-vars(a0)

    lea memoryPointers(pc),a0
    move.l collidingList+8-memoryPointers(a0),a6
    move.l a6,collidingList-memoryPointers(a0)
    move.w #collListBobOffset,d6
    adda.w d6,a6
    move.l a6,collidingList+4-memoryPointers(a0)

	move.l bobDrawList+4(pc),a6

   	move.l objectList-memoryPointers(a0),a2
    subq.l #4,a2

	move viewPosition+viewPositionPointer(pc),d2


    move.l spritePosMem(pc),a5
    lea spritePosMemSize-4(a5),a0
    move.l a0,spritePosFirst

  	move objCount(pc),d3
    bra objectListNextEntry
bobBlitLoop
    moveq #4,d0
.findObject
    adda d0,a2
	tst (a2);objectListAnimPtr
	beq.b .findObject
.foundObject
	move (a2),d0;objectListAnimPtr
	move.l animDefs(pc),a0
	adda.w d0,a0
    ;lea ([(animDefs).w,pc],d0.w),a0

	clr.l d4
	move.b animDefType(a0),d4
    lea ([(objectDefs).w,pc],d4*8),a4   ; Pointer to animDefinitions
	move objectDefAttribs(a4),d0
    bpl.w bobPrepareDraw                      ; draw sprite or bob?
;   ****
;   add object to sprite dma list
;   ****

; #MARK:  prepare sprite lists
	;a
	;bra .4

   	move objectListX(a2),d6
;	a1
	;bra .4

	sub d2,d6           ;Convert absolute to relative Screenposition

	move.l .xbounds(pc),d1	; sprite within view?
	cmp d1,d6
	bhi .deleteSprite
	swap d1
	cmp d1,d6
	bls .deleteSprite	; exited to left border

	moveq #48,d5
	add objectListY(a2),d5
    sub.w plyPos+plyPosYDyn(pc),d5
	move.l .ybounds(pc),d1
	cmp d1,d5
	bge .deleteSprite	; exited border down
	swap d1
	cmp d1,d5
	ble .deleteSprite	; exited border up
	; beware: cmp2 is emulated on 68060 and TERRIBLY SLOW!

    move d5,d4              ; scale to possible slot in y-order, factor 24
    lsl #3,d4
    move d4,d1
    lsl #1,d4
    add d1,d4

.spriteSort
    addq #4,d4
    tst (a5,d4)
    beq .spriteSorted       ; is empty -> go!
; sprite sorter looks for free slot. if not available, find next free slot with. Upto 8 sprites with same y-coord

    move #6,d7
.findNiceSlot
    addq #4,d4
    move (a5,d4),d1
    beq.b .spriteSorted
    cmp d1,d5
    bne.b .findNiceSlot
    dbra d7,.findNiceSlot
    bra.w objectListNextEntry
.spriteSorted
	;c
	;bra .4

    lea vars(pc),a0
    ;ror #5,d0
    btst #12,d0              ; is shot?
    beq.b .addSpriteToList

	;lea spritePosFirst(pc),a1
	;move.l (a1),d0
	;ALERT alert02,d0

.3
    move.l collidingList(pc),a1 ;yes -> write to collission list

    move.l a2,(a1)
    ;add.w plyPos+plyPosYDyn(pc),d5
    ;add.w #8,d5
    move d5,d1
    andi #$1f,d0
    add.w ((.hitModYColBox).W,pc,d0.w*2),d1
	;move.w ((.hitModYColBox).W,pc,d0.w*2),d7
    move d0,d7

    movem.w d1/d6/d7,collTableYCoords(a1); write pure y-coord and x-coord to coll list (handling a little bit different for shots for optimized memory access). Write sprite number too
	;sub.w #8,d5
    moveq #collListEntrySize,d7
    lea collidingList(pc),a1
    add.l d7,(a1)
    addq #1,shotCount-vars(a0)
.addSpriteToList
    ;andi #$1f<<11,d0          ; sprite type
    andi #$3f,d0          ; sprite type

    ror #6,d0
    or d0,d6
    movem.w d5/d6,(a5,d4)
    addq #1,spriteCount+2-vars(a0)
    lea (a5,d4),a1
	lea spritePosFirst(pc),a0
	;move.l (a0),d0
;    cmpi.l (a0),a1
;    bls.b .refreshFirstYpos
.2
    cmpa.l (a0),a1
    bhi.b .4
    ;bge.b .4

    ;sub.l #10*40,a1
	move.l a1,(a0)
.4
	dbra d3,bobBlitLoop

	;tst.b blitterManagerFinishedF(pc)
	;beq.b .keepOldList
.eofSpriteList
	clr.l (a6)      ;mark eof bobdrawlist
;.keepOldList
	lea spriteCount(pc),a0
	move.w 2(a0),d0
	move.w d0,(a0)
   ; move.l spritePOsMem,d4
   ;add.l #$f00,spritePosFirst
   ;move.l spritePosFirst,d4
   rts
.xbounds
	dc.w 45,360
.ybounds
	dc.w 44,290
.hitModYColBox
	dc.w 	0,0
	dc.w 	0,0
	dc.w	-3,8
	dc.w	-3,3
	dc.w	-3,0

;	clr.l (a6)      ;mark eof bobdrawlist

    If 0=1
.refreshFirstYpos
    move.l a1,(a0)	; refresh upfirst y-coord in list
    bra .2
	dbra d3,bobBlitLoop
	bra.b .eofSpriteList
	ENDIF
;.refreshSpritePosFirst
    ;bra.w objectListNextEntry
.deleteSprite
   	clr.w objectListAnimPtr(a2)
	lea objCount(pc),a1
	subq #1,(a1)
    bra.w objectListNextEntry

    ;!!!: Objectcode: code called each frame update. Usually used for bitmap animation, but can do other things too


;   ****
;   draw blitter object
;   ****
; #MARK:  prepare blitter objects

_d1target EQUR D1
_a0cutmask EQUR a0
_d6source EQUR d6



	moveq #$1f,d0
	ror #5,d0

bobPrepareDraw
	move.l (a4),a0  ;objectDefSourcePointer
    adda.l bobSource(pc),a0             ; Adress of sourcebitmap
	andi #$ff,d0
	jmp ([(animCases).w,pc,d0.w*8])      ; jump to specific anim code

;FIXME: Execute code only after draw-check
animReturn
	;tst.b blitterManagerFinishedF(pc)
	;beq objectListNextEntry

;	lea blitterManagerFinishedF(pc),a3
;	tst.b (a3)
;	beq objectListNextEntry
    clr.l d4
    clr.l d7
	move.b objectDefWidth(a4),d4       ; bob-Width in pixels

    move d4,d7
    move d4,d5
    lsl #1,d5
    ;lsr #1,d7
	addq #7,d4
	lsr #3,d4
	addq #1,d4			; bob-width for blitter

    clr.l d6
	move objectListX(a2),d6
	move objectListY(a2),a3
    move.l a2,a1        ; is children object -> add all parent coords
.readParent
    move.l objectListMyParent(a1),a1
    tst.l a1
    beq.b .noMoreChildren
    add.w objectListX(a1),d6
    add.w objectListY(a1),a3
    bra.b .readParent
.noMoreChildren
	sub d2,d6           ;Convert absolute to relative Screenposition
    add d7,d6           ; central x-coord


   	move d2,d1
	andi #$0f,d1
    move d6,d0          ; leftmost x-coord
    add d6,d5           ; rightmost x-coord
    add d1,d6

    move.l collidingList+4(pc),a1
    move.l a2,(a1)
    movem.w d0/d5,collTableXCoords(a1)
    move objectDefModulus(a4),d1

    moveq #viewLeftClip,d7
    cmp d7,d0                 ;   bob leaves screen to the left?
    bgt.b .bobBlitCheckRight       ; completely in visible area? yes

    move d5,d4
    sub d7,d4                   ; touches invisible area?
    bmi.w objectListNextEntry          ; not any more. dont draw


    move d7,d5                  ; draw partially
    sub d0,d5
    move d5,d7
    andi #%11110000,d5
    add d5,d6
    lsr #3,d7
    move d7,d5

    adda.w d7,a0
    moveq #16+15,d0
    add d0,d4
    lsr #4,d4
    add d5,d1

    move d4,d7      ; blit only empty column? Skip!
    subq #1,d7
    beq objectListNextEntry

    bra.b .bobBlitCheckedLeftRight
.bobBlitCheckRight
    move #viewRightClip,d7
	cmp d7,d5                        ;leaves screen to the right?
	ble.w .bobBlitCheckedLeftRight
    move d7,d4
    sub d0,d4                      ; right border -> calculate new width
    bmi objectListNextEntry

    lsr #3,d4
    clr.w d5
    move.b objectDefWidth(a4),d5
    lsr #2,d5
    sub d4,d5
    lsr #1,d4
	addq #1,d4                       ; new bobwidth
    addq #1,d5
    add d5,d1

.bobBlitCheckedLeftRight
    move d1,(a6)	;bobDrawBLTMOD

    clr.l d0
    clr.l d1
	clr.l d5
	move.b objectDefHeight(a4),d5
    move.b d5,d0
    lsr #1,d0

    move a3,d1
	;move objectListY(a2),d1
    ;sub plyPos+plyPosYDyn,d5
	sub d0,d1
    	move d1,d7
	add d5,d7

    move.w d1,collTableYCoords(a1) ; write y-coord to collission table
    moveq #spriteShotHeight-2,d0
    add d7,d0

    move.w d0,collTableYCoords+2(a1) ; write y-coord to collission table
				; d5 = bobhoee
				; d1 = bobypos
    ;sub.w plyPos+plyPosYDyn,d1
;	tst d1
    move plyPos+plyPosYDynAlt(pc),d0
    cmp d0,d1
    bge.b bobBlitCutDown
.bobBlitCutUp
    sub d0,d1
    ;subq #2,d1
    ;sub #10,d1
	neg d1
	sub d1,d5
	ble.w objectListNextEntry
    ;add.l (a1,d1*4),a0

    clr.w d0
    move.w objectDefModulus(a4),d0
    addq #2,d0
    clr.w d7
    move.b objectDefWidth(a4),d7
    lsr.w #2,d7
    add.w d7,d0
    lsl.w #2,d0
	;subq #2,d1
    muls d0,d1
    adda.w d1,a0
	clr.l d1
    move.w plyPos+plyPosYDynAlt(pc),d1
	bra.b addToColTable
bobBlitCutDown
    ;add #10,d1
    move.w #displayWindowStop+$100-viewUpClip-40,d0  ; attn.! value modified in player manager

	cmp d0,d7
    ;cmpi #displayWindowStop+$100-viewUpClip-40,d7
	bls.b addToColTable
	sub d0,d7
    ;sub #displayWindowStop+$100-viewUpClip-40,d7
	sub d7,d5
	bmi.w objectListNextEntry
	addq #1,d5

addToColTable

    btst.b #5,objectListAttr(a2)
    bne.b .notHitable
    moveq #collListEntrySize,d7
    lea collidingList+4(pc),a1
    add.l d7,(a1)
    lea bobCountHitable(pc),a1
    addq #1,(a1)
.notHitable

	lea bobAdrTable(pc),a1
	;clr.l _d1target
	move.w (a1,d1*2),_d1target          ; get y-positions memory offset
    move d6,d0
    lsr #3,d6

	add.l d6,_d1target      ; add x-position to mainplane pointer
    bclr #0,_d1target

    move d0,d7
    moveq #$f,d6
    and.l d6,d7
	ror #4,d7

	move.l a0,d6
    btst.b #6,objectListAttr(a2)      ; melt bob with background, or just stamp (a lot faster!)?
    beq.b .mergeWithBackground
    tst.b objectListHit(a2)  ; stamp
    bpl.b .noHitStamp
    bchg.b #6,objectListHit(a2)
    btst.b #6,objectListHit(a2)
    beq.b .keepHitMarker
    clr.b objectListHit(a2)
.keepHitMarker
   	or #%0000100111110000,d7
	adda.w objectDefMask(a4),a0
   	subq #1,d5	; kill lowest line to avoid pixeljunk
   	bpl.b drawBob
   	clr.w d5
    bra.b drawBob
.noHitStamp
   	or #%0000100111110000,d7
    bra.b drawBob
.mergeWithBackground                ; melt
    adda.w objectDefMask(a4),a0
    tst.b objectListHit(a2)
    bpl.b .noHitMerge
    bchg #6,objectListHit(a2) ; keep white for at least 2 frames
    btst #6,objectListHit(a2)
    beq.b .keepHitMarker2
    clr.b objectListHit(a2)
.keepHitMarker2
    or #$0ffa,d7
    bra.b drawBob
.noHitMerge
    or #$0fca,d7

drawBob

	move d7,bobDrawBLTCON0(a6)               ; roll pixels for smooth movement
	movem.l _d1target/_d6source/_a0cutmask,bobDrawBLTPT(a6);   , d1=Target, d6=BobSource, a0=CutMask
 	lsl #8,d5; x 4 for 4 bitplanes, add bob height to blit control word
	or d5,d4

	clr.w d1
	move.b objectListAttr(a2),d6 ; bckground restore
	roxr #1,d6	; bit = 1 = no restore
	roxr #1,d1	; yes -> set bit 15 in size.w
    or d1,d4
   	move d4,bobDrawBLTSIZE(a6)
	lea bobDrawListEntrySize(a6),a6

objectListNextEntry
	dbra d3,bobBlitLoop

	;tst.b blitterManagerFinishedF(pc)
	;beq.b .keepOldList
	clr.l (a6)      ;mark eof bobdrawlist
;.keepOldList
	lea spriteCount(pc),a0
	move.w 2(a0),d0
	move.w d0,(a0)


    rts
bobAdrTable  blk.w 256,0

; #MARK:  - COLLISSION MANAGER

xModifier
	dc.w 4,8,18,18,20,24

collisionManager
    move shotCount(pc),d7
	beq irqDidColManager	; back to IRQ

    move.l collidingList+8(pc),a3
    move.l a3,a2
    lea collListBobOffset(a2),a2
    move.l a3,a5    ; load adress of collision table
    moveq #collListEntrySize,d4
    move.l d4,a4            ; preload some registers...

    ;move.l a3,a6
    clr.l d1
    clr.l d2
    ;clr.l d3
    subq #1,d7
    move d7,d6
    ;move d7,d4

    ;moveq #3,d0

	move plyPos+plyPosYDynAlt(pc),d3
colDetectObject
	move bobCountHitable(pc),a1
	tst.w a1
	beq chkBckCol

	moveq #40,d4
	move.l viewPosition+viewPositionAdd(pc),d1	; modify x-check <->scroll speed
	lsl.l #1,d1
	swap d1
	move.w (xModifier,pc,d1*2),d2
	sub.w d2,d4

	moveq #-47,d1
	moveq #1,d2
	sub.w d2,a1
	lea collTableYCoords(a2),a0
.loadShot
    move d1,d0
    add.w collTableYCoords(a5),d0         ; load shot y-coords
    add.w d3,d0
    move a1,d6	; no of hitable objects
    move.l a0,a6
.chkBob
	move.l (a6),d5
	cmp d5,d0
	bgt.b .noYCol
	swap d5
	cmp d5,d0
	blt.b .noYCol

	move.w d4,a2     ; check x collissionbox
	add.w collTableXCoords-2(a5),a2     ; load shot x-coords; memory optimized for shots

	move.l 4(a6),d5
	cmp d5,a2
	bgt.b .noYCol
	swap d5
	cmp d5,a2
	bge hitObject

    ;cmp2.w (a6),d0 ;chk y-collissionbox collTableYCoords
    ;bcs.b .noYCol   ; is higher or lower? Skip!

    ;cmp2.w 4(a6),a2; modified pointer to collTableXCoords
    ;bcc.w hitObject
.noYCol
    add.l a4,a6
    dbra d6,.chkBob
    add.l a4,a5
    dbra d7,.loadShot
chkBckCol
	lea bobAdrTable(pc),a0
	move.l 	mainPlanesPointerAsync(pc),a1
	;move.l mainPlanesPointer+4(pc),a1
	moveq #20,d5
	move plyPos+plyPosYDyn(pc),d3
	clr.l d1
	move.l a3,a6

	moveq #3,d7
	moveq #-52,d0	;y-offset
	moveq #16,d5	;x-offset
	move.l a3,a6
    move shotCount(pc),d4
	bra.b .firstLoop
.chkBckLoop
    move d0,d1
    add.w collTableYCoords(a6),d1         ; load shot y-coords
    add.w d3,d1			; add y-scroll coord
    move.w (a0,d1.l*2),d2     ; y bitmap offset
    move d5,d1
    add.w collTableXCoords-2(a6),d1         ; load shot x-coords
    lsr d7,d1
    add.w d1,d2	; add x-byte-offset
 ;   bclr #0,d2
	;ALERT alert03,d2
	tst.w (a1,d2.l)     ; check background
	bne.b hitBackground
    adda a4,a6
.firstLoop
    dbra d4,.chkBckLoop
colQuit
	bra irqDidColManager

hitBackground		; hit static background
;    move.w #$ffff,(a1,d2.l)
	tst.b dialogueActive(pc)
	bne irqDidColManager	; dialoge running->no shot<->bckgnd check

	bfffo (a1,d2.l){0:31},d0	; get leftmost set bit
	moveq #15,d3
	sub d0,d3
	moveq #-1,d0
	bclr d3,d0
	subq #1,d3
	bclr d3,d0
	moveq #mainPlaneWidth,d1

	moveq #2,d6
	lea mainPlanesPointer(pc),a2
.outerLoop
	move.l (a2),a1
	moveq #3,d7
.loop
	and.w d0,(a1,d2.l)	;erase pixels from background
	adda.w d1,a1
	dbra d7,.loop
	lea 4(a2),a2
	dbra d6,.outerLoop

	move.l (a6),a0           ; collTableAnimActionAdr -switch to exit anim
	move collTableXCoords(a6),d0	; get sprite number
	andi #$1f,d0
	    move.l ([hitObjAnim.W,pc,d0.w*4]),a1; get exit anim adress
		move.w animTablePointer+2(a1),(a0);
	move.b #6,objectListCnt(a0) ;

	PLAYFX 9
    cmpi.w #12,particleCount(pc)
    bge irqDidColManager

	move.l ((.hitBckCoords).W,pc,d0.w*4),d4; modify coords for perfekt particle spawn
	move d4,d3
	swap d4
    add.w collTableYCoords(a6),d4         ; load shot y-coords
    clr.w d5
    add.w plyPos+plyPosYDyn(pc),d4
    clr.w d6
    add.w collTableXCoords-2(a6),d3         ; load shot x-coords
	lsl #4,d3
	lsl #8,d4
	lea emitterHitA(pc),a0
	pea irqDidColManager(pc)	; push fake rts adress
	bra particleSpawn           ; call particles subroutine

.hitBckCoords
	dc.l $ffcd0001,$ffcd0001
	dc.l $ffcd0001,$ffcd0001
	dc.l $ffd30001,$ffc50001
	dc.l $ffcd0001
	dc.l $ffcd0001,$ffcd0001
hitShotXMod
	dc.b	16,16,12,8	; horz shots
	dc.b 	0,0,0,0,0	; diag shots
	even
hitObjAnim
	dc.l cPlyShtXAnimPointer,	cPlyShtXAnimPointer
	dc.l cPlyShtXAnimPointer, 	cPlyShtXAnimPointer
	dc.l cPStPdAXAnimPointer, 	cPStPdBXAnimPointer
	dc.l cPlyShtXAnimPointer
	dc.l cPStSpAXAnimPointer, 	cPStSpBXAnimPointer

hitObject                   ; hit moving object

	move collTableXCoords(a5),d0	; get sprite number

	andi #$1f,d0
	    move.l ([hitObjAnim.W,pc,d0.w*4]),a1; get new anim adress
	;move.l (a1),a1
	;move.w ((hitObjAddY).w,pc,d0.w*2),d0
	;add.w d0,collTableYCoords(a5)	; modify particle y-position
	suba.w #4,a6
    move.l (a5),a0           ; collTableAnimActionAdr- handle player shot
	;	move.l cPlyShtXAnimPointer(pc),a1
		move.w animTablePointer+2(a1),(a0); objectListAnimPtr. object hit, change to exit-animation

   	move.b #6,objectListCnt(a0)
    move.l (a6),a0        ; collTableAnimActionAdr - handle attacker object

    clr.l d7
    clr.l d5
    move.b objectListAttr(a0),d6
    btst #3,d6
    bne .dontMoveOnImpact

; push hit object

	move (a0),d5;objectListAnimPtr
    lea ([(animDefs).w,pc],d5.w),a4 ; get pointer to object definition
    clr.l d4
	move.b animDefType(a4),d4
    lea ([(objectDefs).w,pc],d4*8),a4   ; Pointer to animDefinitions

    move.b objectDefWidth(a4),d7
    lsl #1,d7
    not.b d7
    swap d7
    moveq #9,d1
    lsr.l d1,d7
    move.l viewPosition+viewPositionAdd(pc),d5
    add.l d5,d7
.dontMoveOnImpact
    btst #2,d6
    beq singleObject
;    move bobCountHitable(pc),d0                 ; hit group of objects
    move objCount(pc),d0
    move.l objectList(pc),a1

    suba.w #4,a1
    move.w objectListGroupCnt(a0),d3
    subq.b #1,objectListHit+1(a0)
    move.w objectListHit(a0),d2

    move.w objectListHit(a0),d2

    tst.b d2
    ;beq colHit			 ; hit objects / not destroyed

    bpl.b groupHit
    bra colHitKill          ; destroy single object
	;bra irqDidColManager
groupHit                                    ; hit but hitpoints left


	ADDSCORE 1
   	or.w #$c000,d2	; set white flag
    move.w #4,a4
    btst #3,d6
    beq.b .pushGroupedObject
.animsrchlist
    adda.w a4,a1
    tst (a1)
	beq.b .animsrchlist
    btst.b #2,objectListAttr(a1)
    beq.b .noGroupedObject
    move.w objectListGroupCnt(a1),d4
    cmp.w d3,d4
    bne.b .noGroupedObject
    move.w d2,objectListHit(a1)
.noGroupedObject
    dbra d0,.animsrchlist
    bra.b colHit
.pushGroupedObject
    moveq #2,d7
    swap d7
.animsrchlistG
    adda.w a4,a1
    tst (a1)
	beq.b .animsrchlistG
    btst.b #2,objectListAttr(a1)
    beq.b .noGroupedObjectG
    move.w objectListGroupCnt(a1),d4
    cmp.w d3,d4
    bne.b .noGroupedObjectG
    move.w d2,objectListHit(a1)
    add.l d7,objectListX(a1)        ; push a little on impact
.noGroupedObjectG
    dbra d0,.animsrchlistG
    bra.b colHit

singleObject

    tst.w objectListHit(a0)
    beq colHitNoPoints      ; object hitable, not destroyable
    btst #3,d6
    bne.b .dontMoveOnImpact

    add.l d7,objectListX(a0)        ; push a little on impact
.dontMoveOnImpact
    or.b #$c0,objectListHit(a0)
    subq.b #1,objectListHit+1(a0)             ; hit single object
    beq colHitKill                                 ; hit but hitpoints left
    ;bra.w colHitKill
	;bra irqDidColManager	; back to irq

colHit          ; hit objects / not destroyed
    lea scoreMultiplier+4(pc),a1
	move.l a0,(a1)
    ADDSCORE 1

    PLAYFX 8
; particles after hit moving object
spawnHitParticles
    cmpi.w #12,particleCount(pc)
    bge irqDidColManager		; back to irq

    moveq #40,d3
    add.w collTableXCoords-2(a5),d3
    clr.w d5
	lsl #4,d3

    moveq #-51,d4
    add.w collTableYCoords(a5),d4
    clr.w d6
    add.w plyPos+plyPosYDyn(pc),d4
	lsl #8,d4
    lea emitterHitA(pc),a0
    pea irqDidColManager(pc)	; push fake rts adress
	bra particleSpawn	; call subroutine

colHitNoPoints
    PLAYFX 9
    bra.b spawnHitParticles
colHitKill


    btst.b #2,objectListAttr(a0)
    bne.w .killGroupedObject

    clr.l d5		; hit and killed
	move (a0),d5;objectListAnimPtr
	move.l ((animDefs).w,pc),a5
	lea (a5,d5),a5
    ;lea ([(animDefs).w,pc],d5.w),a5
    clr.l d4
	move.b animDefType(a5),d4
	move.l ((objectDefs).w,pc),a4
	lea (a4,d4*8),a4
    ;lea ([(objectDefs).w,pc],d4*8),a4   ; Pointer to ObjectDefinitions

    move objectDefScore(a4),d0
    add d0,scoreAdder
    bclr.b #7,objectListHit(a0)
	;bra irqDidColManager

    move.b objectDefWidth(a4),d0
    lsl #1,d0
    cmpi.b #90,d0
    bhi .explXtraLrg
;!!!: Change 50 to 46 for bigger eyeroid explo
    cmpi.b #50,d0
    bhi .explLrg
    cmpi.b #25,d0
    bhi.b .explMed


	move.l cExplSmlAnimPointer(pc),a4
	move.w animTablePointer+2(a4),(a0)	; objectListAnimPtr. object hit, change to explosion animation

    andi.b #%10111010,objectListAttr(a0); clr opaque, group, refresh  bit
    bset #5,objectListAttr(a0)        ; set not hitable bit

    move frameCount+2(pc),d0
    andi #%111000,d0
    sub #%111000>>1,d0
    move d0,objectListAccY(a0)       ; vary y-acceleration a little bit
   	move.b #31,objectListCnt(a0)
    add #$2c0,objectListAccX(a0)
    add #$3,objectListX(a0)
.addSoundFX
    ;ALERT alert01,d0
    PLAYFX 3
    bra .parentalCheck
.explMed

	move.l cExplMedAnimPointer(pc),a1
	move.w animTablePointer+2(a1),(a0)	; objectListAnimPtr. object hit, change to explosion animation

    andi.b #%10111010,objectListAttr(a0); clr opaque, group, refresh   bit
    bset #5,objectListAttr(a0)        ; set not hitable bit

   	move.b #63,objectListCnt(a0)
    move frameCount+2(pc),d0
    andi #%111000,d0
    sub #%111000>>1,d0
    move d0,objectListAccY(a0)       ; vary y-acceleration a little bit
    add #$2c0,objectListAccX(a0)
    move.l a0,a6

	move.l cExplSmlAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4	;add small explosion just for the looks...
	moveq #$15,d5
	add.w objectListX(a0),d5
	moveq #-40,d6
	add collTableYCoords(a3),d6                    ; get y-coord from shot
    clr d3
    bsr.w objectInit
    tst.l d6
    bmi irqDidColManager
;    move #0,objectListHit(a4); hitpoints
    move.b #attrIsNotHitable,objectListAttr(a4); attribs

    add #$2c0,objectListAccX(a4)
    andi #%111000,d6
    sub #%111000>>1,d6
    move d6,objectListAccY(a4)       ; vary y-acceleration a little bit
    PLAYFX 4
.parentalCheck
    btst.b #1,objectListAttr(a0)
    bne.b .isParent                           ; hit object is parent?
	tst.b objectListWaveIndx(a0)
	bpl .isWave
	bra irqDidColManager
.isParent
	clr.l d7
    PLAYFX 5
    bclr #1,objectListAttr(a0)
    move.l collidingList+8(pc),a3               ; yes!
    add.l #collListBobOffset,a3
    moveq #collListEntrySize,d3

	move bobCountHitable(pc),d7
	subq #1,d7
.findChildren
	move.l (a3),a2	;collTableAnimActionAdr
	cmp.l objectListMyParent(a2),a0
	beq.b .foundChild
.nextChild
    add.l d3,a3
    dbra d7,.findChildren
	bra irqDidColManager

.foundChild
    move.l a2,a5
.findMoreChildren
    btst.b #1,objectListAttr(a5)
    beq.b .justChild                           ; hit child is parent too?
    ; yes. Find and manage subchildren. Always small explosions
    bclr #1,objectListAttr(a5)        ; clr link bit for correct colldetection
    move.l objectListMyChild(a5),a5

		move.l cExplSmlAnimPointer(pc),a1
		move.w animTablePointer+2(a1),(a5)	; objectListAnimPtr. object hit, change to explosion animation

    andi.b #%10111011,objectListAttr(a5); clr opaque, group   bit
    bset #5,objectListAttr(a5)        ; set not hitable bit

    move.b #31,objectListCnt(a5)
    bra.b .findMoreChildren
.justChild
    clr.l d5                                  ; hit and killed
	move (a2),d5;objectListAnimPtr
    lea ([(animDefs).w,pc],d5.w),a5
    clr d5
	move.b animDefType(a5),d5
    lea ([(objectDefs).w,pc],d5*8),a5   ; Pointer to ObjectDefinitions
    clr.l d5
    move.b objectDefWidth(a5),d5
    lsl #1,d5
    cmpi.b #50,d5
    bhi.b .lrg
    cmpi.b #25,d5
    bhi.b .med
	move.l cExplSmlAnimPointer(pc),a1
	move.w animTablePointer+2(a1),d4
    bra.b .cont
.med
	move.l cExplMedAnimPointer(pc),a1
	move.w animTablePointer+2(a1),d4
    bra.b .cont
.lrg
	move.l cExplLrgAnimPointer(pc),a1
	move.w animTablePointer+2(a1),d4
.cont
    move d4,(a2)
    move.b #63,objectListCnt(a2)
    ;move.b #%00000100,objectListAttr(a2)
    andi.b #%10111001,objectListAttr(a2); clr opaque, group   bit
    bset #5,objectListAttr(a2)        ; set not hitable bit

    move.w #$50,objectListAccX(a2)
    clr.w objectListAccY(a2)
    bra.w .nextChild
.explLrg

	move.l cExplLrgAnimPointer(pc),a1
	move.w animTablePointer+2(a1),(a0)	; objectListAnimPtr. object hit, change to explosion animation
    andi.b #%10111010,objectListAttr(a0); clr opaque, group, refresh   bit
    bset #5,objectListAttr(a0)        ; set not hitable bit

    move frameCount+4(pc),d0
    andi #%11100,d0
    sub #%11100>>1,d0
    move d0,objectListAccY(a0)       ; vary y-acceleration a little bit

	move.b #31,objectListCnt(a0)
    add #$190,objectListAccX(a0)

	move.l cExplMedAnimPointer(pc),a1
	move.w animTablePointer+2(a1),d4	;add med explosion just for the looks...
	moveq #25,d5
	add.w objectListX(a0),d5
	moveq #-40,d6
    add collTableYCoords(a3),d6                    ; get y-coord from shot
    ;move collTableYCoords(a3),d6                    ; get y-coord from shot
    clr d3
    bsr objectInit
    tst.l d6
    bmi irqDidColManager	; back to IRQ
    ;move #0,objectListHit(a4); hitpoints
    move.b #attrIsNotHitable,objectListAttr(a4); attribs
    add #$f0,objectListAccX(a4)
	move.b #31,objectListCnt(a4)


    PLAYFX 5

    bra .parentalCheck
.explXtraLrg
	move.l cExplLrgAnimPointer(pc),a1
	move.w animTablePointer+2(a1),(a0)	; objectListAnimPtr. object hit, change to explosion animation
    andi.b #%10111010,objectListAttr(a0); clr opaque, group   bit
    bset #5,objectListAttr(a0)        ; set not hitable bit

   	move.b #31,objectListCnt(a0)
    add #$90,objectListAccX(a0)
    add #20,objectListX(a0)


	move.l cExplLrgAnimPointer(pc),a1
	move.w animTablePointer+2(a1),d4	;add med explosion just     move objectListX(a0),d5
    sub #30,d5
    move objectListY(a0),d6
    sub #25,d6
    clr d3
    bsr.w objectInit
    tst.l d6
    bmi irqDidColManager	; back to IRQ
        ;move #0,objectListHit(a4); hitpoints
    move.b #attrIsNotHitable,objectListAttr(a4); attribs

    add #$50,objectListAccX(a4)
    move #-70,objectListAccY(a4)
    move #$2c,objectListCnt(a4)

    move objectListX(a0),d5
    sub #20,d5
    move objectListY(a0),d6
    add #$16,d6
	clr d3
	bsr.w objectInit
	tst.l d6
	bmi irqDidColManager; back to irq
    ;move #0,objectListHit(a4); hitpoints
    move.b #attrIsNotHitable,objectListAttr(a4); attribs
    add #$d0,objectListAccX(a4)
    move #65,objectListAccY(a4)
    move.b #$3f,objectListCnt(a4)

	move.l cExplLrgAnimPointer(pc),a1
	move.w animTablePointer+2(a1),d4
    ;add explosion just for the looks...
   ; move objectListX(a0),d5
;    add #2,d5
	moveq #25,d5
    add.w objectListX(a0),d5
    moveq #-40,d6
    add.w collTableYCoords(a3),d6                    ; get y-coord from shot
    ;move collTableYCoords(a3),d6                    ; get y-coord from shot
	clr d3
	bsr.w objectInit
    tst.l d6
    bmi irqDidColManager	; back to IRQ
    add #$a0,objectListAccX(a4)
    move.b #$4f,objectListCnt(a4); hitpoints
    move.b #attrIsNotHitable,objectListAttr(a4); attribs

    PLAYFX 5
    bra .parentalCheck
.killGroupedObject


	move (a0),d5;objectListAnimPtr	; get score
	move.l ((animDefs).w,pc),a5
	lea (a5,d5),a5
    clr.l d4
	move.b animDefType(a5),d4
	move.l ((objectDefs).w,pc),a4
	lea (a4,d4*8),a4
	move objectDefScore(a4),d1
  	lea scoreAdder(pc),a3


    move.w #4,a4
    ;move.w objectListGroupCnt(a0),d3
  	move.l cExplSmlAnimPointer(pc),a5
	move.w animTablePointer+2(a5),d7
	moveq #63,d6
	sub.w a6,a6
.animsrchlistX
    adda.w a4,a1
    tst (a1)
	beq.b .animsrchlistX
    btst.b #2,objectListAttr(a1)
    beq.b .noGroupedObjectX
    move.w objectListGroupCnt(a1),d4

    cmp.w d3,d4
    bne.b .noGroupedObjectX
	tst.w a6
	beq.b .cancelGroup
.return
	move.w d7,(a1)	; objectListAnimPtr. object hit, change to explosion animation
    andi.b #%10111011,objectListAttr(a1); clr opaque, group   bit
    bset #5,objectListAttr(a1)        ; set not hitable bit
    lsl objectListAccY(a1)       ; vary y-acceleration a little bit
    lsl objectListAccX(a1)       ; vary y-acceleration a little bit
	move d0,d5
	andi #$f,d5
	add.w d6,d5

	move.b d5,objectListCnt(a1)
    add d1,(a3)
.noGroupedObjectX
	dbra d0,.animsrchlistX

	PLAYFX 5
	bra irqDidColManager
.cancelGroup
	move.l objectListTriggersB(a1),a5
	clr.w (a5)
	clr.b launchTableRptCountdown(a5)
	add #1,a6
	bra.b .return

.isWave				; is in of obj wave?
	clr.w d0
	move.b objectListWaveIndx(a0),d0
;	ALERT alert01,d0
	lea objCopyTable(pc),a1
	sub.b #1,(a1,d0)
	bne irqDidColManager	; back to IRQ
	ADDSCORE 50
	move.l waveBnusAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4	;add bonus display
	move objectListX(a0),d5
	move objectListY(a0),d6
	add.w #$15,d5
	clr d3
	bsr objectInit
    ; is sprite therefore attribs are assigned by objects-list. $40=bonus icon
.quitWave
	bra irqDidColManager

; MARK: - LAUNCH MANAGER
launchManager
	move.l launchTableBuffer(pc),a0
    move.l launchTableEntryLength(pc),a6
	move viewPosition+viewPositionPointer(pc),d0
	move d0,d5
    tst.w launchTableAnim(a0)
    bmi .enemQuit
    bne .foundValidEntry       ;   is 0? past wave, unvalid!
.enemPreFetchWave               ;   preloop to determine first valid entry in launchTable. Table needs to be sorted
    REPT 10
    adda.l a6,a0
    tst.w (a0)      ;launchTableAnim
    bne.b .foundValid       ;   is 0? past wave, unvalid!
    ENDR
    bra.b .enemPreFetchWave
.foundValid
    bmi .enemQuit               ;   is >$7fff? reached end of list
    move.l a0,launchTableBuffer
    bra .foundValidEntry
.enemFetchWave
    REPT 10
    adda.l a6,a0
    tst.w (a0)                  ; read launchTableAnim entry
    bne.s .foundValidEntry       ;   is 0? already launched
    ENDR
    bra.b .enemFetchWave
.foundValidEntry
    bmi .enemQuit               ;   is >$7fff? reached end of list
	cmp launchTableX(a0),d0
	bcs .enemQuit
   ; moveq #1,d6

;	move.b launchTableRptr(a0),d0
;	ALERT alert01,d0

	tst.b launchTableRptr(a0)
	bne.b .copyObject
    clr.l d6
    clr.l d5
    move.w launchTableY(a0),d6
	tst.b launchTableAttribs(a0)
	bpl.b .singleStaticX
	move launchTableX(a0),d5
    bra.b .singleDynX
.singleStaticX	; single object
  	move viewPosition+viewPositionPointer(pc),d5
.singleDynX
	add.w #$160,d5
	move.w (a0),d4;launchTableAnim
	bsr objectInitLaunchList
	tst.l d6
	bmi .enemFetchWave
	st.b objectListWaveIndx(a4)
    clr.w launchTableAnim(a0)	; delete launch entry
	bra .enemFetchWave	; get next
.copyObject
;		ALERT alert01,d7
;	tst.b launchTableRptCountdown(a0)
;   beq .launchCopied
;	bra.b .launchCopied
	sub.b #1,launchTableRptCountdown(a0)
	bcc.w .enemNextWave
.enemChckRythm              ; launch delay until music permits

	move.b launchTableRptrDist(a0),launchTableRptCountdown(a0)


	;move.b launchTableRptr(a0),d7

;.copyObject
	sub.b #1,launchTableRptr(a0)
	;move.b #1,launchTableRptr(a0)
	beq.w .enemEndWave		; overflow? was single object
	;bmi.b .launchCopied		; copied obj? Set Wave attribs
.launchCopied			; launch copied object
	bmi .firstEntry
.contLaunch

		clr.l d6
    	move.w launchTableY(a0),d6
		tst.b launchTableAttribs(a0)
		bpl.b .copiedStaticX
    	clr.l d5
		move launchTableX(a0),d5
		bra.b .copiedInit
.firstEntry
		move.w a0,d7
		lsr #3,d7
		andi #$f,d7	; generate wave fingerprint
	;ALERT alert01,d7
		lea objCopyTable(pc,d7),a1
		bclr #7,launchTableRptr(a0)
		clr.w d0
		move.b launchTableRptr(a0),d0
		move.b d0,(a1)		; store no of obj==mark as wave
		clr.b 16(a1); reset shoot counter
;		add #1,(a1)	;
		bra.b .contLaunch
.copiedStaticX
    	clr.w d5
  		move viewPosition+viewPositionPointer(pc),d5
.copiedInit
		add.w #$160,d5
		move.w (a0),d4;launchTableAnim
		clr.w d3
		bsr objectInitLaunchList
		tst.l d6
		bmi .enemFetchWave
		move.w a0,d7
		lsr #3,d7
		andi #$f,d7	; generate wave fingerprint
		move.b d7,objectListWaveIndx(a4)	; store index in obj struc
;		bra.b .groupedChk
	;bra .enemFetchWave	; get next
.groupedChk
 	btst #2,d3
 	beq.b .noGroup
 	move.l a0,objectListTriggersB(a4)	;abused for storing pointer / cancel wave if killed
    move.w a0,objectListGroupCnt(a4); needed for comparing
.noGroup
 ;   tst.l d6
 ;   bmi .enemFetchWave
    move.b launchTableRptYAdd(a0),d6
    ext.w d6
	add.w d6,launchTableY(a0)
	bra.w .enemFetchWave
.enemEndWave
    clr.w launchTableAnim(a0)
.enemNextWave
	bra.w .enemFetchWave
.enemQuit
    bra irqNoMoreLaunches
objCopyTable	; store index and no of copied objects for wave bonus
	blk.w 16,0		; entrys

attrIsNoRefresh=$01
attrIsParent=$02
attrIsGroup=$04
attrIsNoImpact=$08
attrIsPlyShot=$10
attrIsNotHitable=$20
attrIsNoOpaque=$40
attrIsBonus=$40
attrIsSprite=$80

    ; #MARK: - OBJECT INIT

    ; d3 = 1 -> player or enem shot

		;AnimList-Addresse in d4
			;x/y-koordinaten in d5/d6
            ; d6 returns errorcode -1 if too many objects

    ;objectListAttr attribs:
    ;bit 0 = $01 = no background refesh (useful for static anim objects). Set label refr in object@map.  old: object is big / restart scrolling after kill
    ;bit 1 = $02 = object is parent. Can only be set by being called from animdefs-objectcode
    ;bit 2 = $04 = object belongs to one group of objects
    ;bit 3 = $08 = object doesnt move on shot-impact
    ;bit 4 = $10 = object is player shot, added as basic-obj to collision list
    ;bit 5 = $20 = bob not hitable e.g. explosion. sprite is never hitable.
    ;bit 6 = $40 = non-opaque bob, not mixing with background. faster! If sprite, marks bonus icon
    ;bit 7 = $80 = sprite; 0 = bob




objectInit	; launch manually, not from launch list
            ; handle attrib.b and hitpoint.w by code after init
	move.l d5,a4
    move objCount(pc),d5
    sub spriteCount(pc),d5
    sub.w #enemiesMax-2,d5
    bmi.b initObjManually
	bra tooManyObjects
objectInitSprite


    ;swap d5
    move.l d5,a4
    ;move spriteCount(pc),d5
    move spriteCount(pc),d5
    sub #bulletsMax+shotsMax,d5
    bpl tooManySprites
initObjManually
	move.l a4,d5
	lea objectList(pc),a4

    ;move.l objectList,a4
	btst #0,d3
	beq.b .noShot	; is player shot?
	; yes
	move.l (a4),a4
	bra.b .animsrchlist
.noShot
    move.l 4(a4),a4
.animsrchlist
	moveq #4,d3
	tst.w (a4)
    beq.s .foundSlot
.animsrchlistB
	adda.l d3,a4
	tst.w (a4)
    bne.s .animsrchlistB ; write to adress register dont affect .foundObjectSlot
	;suba.w d3,a4
.foundSlot
    swap d5
    clr d5
	move.l d5,objectListX(a4)
    swap d6
    clr d6
	move.l d6,objectListY(a4)	; coords
    move.l viewPosition+viewPositionAdd(pc),d3
    lsl.l #5,d3
    clr.w d3
    move.l d3,objectListAcc(a4)      ; start with same x-momentum as x-scrolling and no y-acc
    swap d5
    swap d6

	move d4,(a4); objectListAnimPtr - pointer to animDefinitions
    clr.b objectListLoopCnt(a4)
	lea objCount(pc),a1
	addq #1,(a1)

  	move.l animDefs(pc),a1
	move.b animDefCnt(a1,d4.w),d3
    move.b d3,objectListCnt(a4)    ; lifespan

    ; following values resetted only if being launched from list and if needed, not in manual mode

    clr.l objectListMyParent(a4)   ; clear parent pointer
    st.b objectListWaveIndx(a4)   ; clear wave index ($ff)
    clr.l objectListTriggers(a4)   ; clear triggers
    ;clr.l objectListTriggersB(a4)   ; clear triggers
    rts
tooManySprites
	ALERT alertTooManySprites,spriteCount
	moveq #-1,d6
	rts
tooManyObjects
	ALERT alertTooManyObjects,objCount
	moveq #-1,d6
	rts

objIniChkSprite
    move spriteCount(pc),d5
    sub #bulletsMax+shotsMax,d5
    bmi.b iniObjLaunchlist
    bra.b tooManySprites
	
	
	
	
objectInitLaunchList:           ; launch by lauchlist, not manually. Attribs and hitpoints taken care off
	swap d5
    btst #7,d3
    bne.b objIniChkSprite
    move objCount(pc),d5
    sub spriteCount(pc),d5
    sub #enemiesMax-2,d5
    bpl.b tooManyObjects
iniObjLaunchlist
    lea objectList+4(pc),a4
    move.l (a4),a4      ;  object data table, bob offset
    ;clr d0
    ;move.l ([(objectList+4).w,pc,d0]),a4
.animsrchlist
	moveq #4,d3
	tst.w (a4)
    beq.s .foundObjectSlot
.animsrchlistB
	adda.w d3,a4
	tst.w (a4)
    bne.s .animsrchlistB ; write to adress register dont affect ccr
.foundObjectSlot
    ;swap d5
    clr d5
	move.l d5,objectListX(a4)
    swap d6
    clr d6
	move.l d6,objectListY(a4)	; coords
    move.l viewPosition+viewPositionAdd(pc),d3
    lsl.l #6,d3
    clr d3
    move.l d3,objectListAcc(a4)      ; start with same x-momentum as x-scrolling and no y-acc
    swap d5
    swap d6

	move d4,(a4); objectListAnimPtr - pointer to animDefinitions
    moveq #0,d3
    move.b launchTableHitpoints(a0),d3

    move d3,objectListHit(a4); hitpoints
    move.b launchTableAttribs(a0),d3

    move.b d3,objectListAttr(a4);
    clr.b objectListLoopCnt(a4)
noGroup
	lea objCount(pc),a1
	addq #1,(a1)
  	move.l animDefs(pc),a1
	move.b animDefCnt(a1,d4.w),d4
    move.b d4,objectListCnt(a4)    ; lifespan
    clr.l objectListMyParent(a4)   ; clear parent pointer
    clr.l objectListMyChild(a4)   ; clear child pointer
	clr.l objectListTriggers(a4); reset object triggers
	clr.l objectListTriggersB(a4); again
    rts

	Include bobCustomAnim.s

    Include alert.s



wrtScore               ; draw 2 numbers -> sprite
                            ; d7.b = bcd number, a1 = address
    move d7,d5
    asr d6,d7
    and.w d3,d7
    and.w d3,d5
	lea 8(a1),a3
;#FIXME: Optimize – new data structure, align bitmit and shdw, bitmap and shdw ...
    move.l (a0,d5*8),d0     ; read 4 lines from right digit
    move.l (a0,d7*8),d1     ; 4 lines from left digit
    move.b d1,d2
    lsl d4,d2
    or.b d0,d2
    move.w d2,(a1)
    add.l a4,a1

    asr.l d4,d0
    asr.l d4,d1
    move.b d1,d2
    lsl d4,d2
    or.b d0,d2
    move.w d2,(a1)
    add.l a4,a1

    asr.l d4,d0
    asr.l d4,d1
    move.b d1,d2
    lsl d4,d2
    or.b d0,d2
    move.w d2,(a1)
    add.l a4,a1

    asr.l d4,d0
    asr.l d4,d1
    move.b d1,d2
    lsl d4,d2
    or.b d0,d2
    move.w d2,(a1)
    add.l a4,a1

    move.b 4(a0,d5*8),d0        ; lowest line
    move.b 4(a0,d7*8),d1
    asl.w d4,d1
    or.b d0,d1
    move.w d1,(a1)

	move.l (a2,d5*8),d0     ; read 4 lines from right digit
    move.l (a2,d7*8),d1     ; 4 lines from left digit
    move.b d1,d2
    lsl d4,d2
    or.b d0,d2
    move.w d2,(a3)
    add.l a4,a3

    asr.l d4,d0
    asr.l d4,d1
    move.b d1,d2
    lsl d4,d2
    or.b d0,d2
    move.w d2,(a3)
    add.l a4,a3

    asr.l d4,d0
    asr.l d4,d1
    move.b d1,d2
    lsl d4,d2
    or.b d0,d2
    move.w d2,(a3)
    add.l a4,a3

    asr.l d4,d0
    asr.l d4,d1
    move.b d1,d2
    lsl d4,d2
    or.b d0,d2
    move.w d2,(a3)
    add.l a4,a3

    move.b 4(a2,d5*8),d0        ; lowest line
    move.b 4(a2,d7*8),d1
    asl.w d4,d1
    or.b d0,d1
    move.w d1,(a3)
    rts


;
; #MARK: - SCORE MANAGER

scoreManager

    clr.l d0

    move scoreAdder(pc),d0
    bne.b scoreDisplay
	tst.b updateStatDispExtra(pc)	; update extra stats?
	bne drawHighExtras
    move.w scoreHighSuccessFlag(pc),d1
    bmi drawHighBlink
    rts


scoreDisplay

	; handle multiplier
    lea 8*8+fxTable(pc),a4      ; pitch also serves as multiplier count
    lea scoreMultiplier(pc),a3

    move.w (a4),d1
    lsr #4,d1
    move.b ((.scoreMulti).w,pc,d1.w),2(a3)     ;

    tst d1
    beq.b .2
    subq.w #2,(a4); sub from countup
    bra.b .2
.scoreMulti
    dc.b 4,3,2,2,1,1,0,0
.1
    ;moveq #$3f,d0	; hit counter
    ;move.w d0,(a4)
    ;move.w #$100,d1
    ;move.w d1,2(a3)   ; reset multiplier and compare

.2
	move.w #60*3,(a3)  ; keep chain for 3 seconds, then reset

    lea (score+scoreAdd+4,pc),a5
    lea (score,pc),a6
    clr.l d1
    tst.w (a3)
    beq .drawStats	; zero multiplier -> skip
    ;clr.w d1
    move.b 2(a3),d1    ; load multiply value
	cmp.b 3(a3),d1 ; unchanged? Skip!
	beq.b .skipDispUpdate
    bsr drawMultiply
     ; ALERTSETLINE 10
    ;jmp .muls2
;tst.b updateStatDispExtra(pc)
.skipDispUpdate
	move.b d1,3(a3)
    jmp ([(.multiplyCases).w,pc,d1.w*4])
.multiplyCases
    dc.l .drawStats,.muls2,.muls3,.muls4,.muls5
.muls2
    ;bra .keepOn
    ;moveq #1,d0
    lsl #1,d0
;    tst.b d1
 ;   bmi.b .drawStats
  ;  bsr drawMultiply
    bra.b .drawStats
.muls3
    move d0,d2
    lsl #1,d0
    add d2,d0
    ;tst.b d1
    ;bmi.b .drawStats
    ;bsr drawMultiply
    bra.b .drawStats
.muls4
    lsl #2,d0
    ;tst.w d1
    ;bmi.b .drawStats
    ;bsr drawMultiply
    bra.b .drawStats
.muls5
    move d0,d2
    lsl #2,d0
    add d2,d0
    ;tst.b d1
    ;bmi.w .drawStats
    ;bsr drawMultiply

.drawStats

	;ALERT alert01,d0
	;move.l spriteScoreBuffer(pc),a2
	;bsr drawHighExtras
	lea updateStatDispExtra(pc),a0
	st.b (a0)
    move.l a6,a4
    addq.l #4,a4
writeThis
	lea scoreAdder(pc),a0
	clr.w (a0)

    moveq #0,d1          ; convert score to add from binary -> bcd number. att: four bcd digits max!
    move.l d1,d3
    move.l d1,d7
    moveq #3,d2
    move #-1,d3
    moveq #10,d4
    moveq #4,d5

.convertLoop
    cmp d4,d0
    blt .foundRemainder
    sub d4,d0
    addq #1,d7
    bra .convertLoop
.foundRemainder
    swap d7
    or.l d7,d0
    add.w d0,d1
    ror.w d5,d1
    swap d0
    and.l d3,d0
    moveq #0,d7
    dbra d2,.convertLoop
    move d1,scoreAdd+2(a6)


    moveq #0,d0                  ; calc new score
    add #0,d0
    abcd -(a5),-(a4)
    abcd -(a5),-(a4)
    abcd -(a5),-(a4)
    abcd -(a5),-(a4)

.scoreToSprite	;   write score
    lea fontNumbers(pc),a0
	lea fontNumbersShdw(a0),a2
    clr.l d2
    clr.w d5
    clr.w d7
    moveq #$f,d3
    moveq #16,d4
    move.l d4,a4
    lsr #1,d4
    moveq #4,d6

    move.b scoreNew(a6),d7              ; check first two digits of score. Changed?
    move.b scoreOld(a6),d5
    cmp.b d5,d7
    beq.b .chkNext2

    move.b d7,scoreOld(a6)              ;   yes
    ;lea ([(spriteScoreBuffer).w,pc],(spriteLineOffset*spriteScoreHeight+6).w),a1
	move.l spriteScoreBuffer(pc),a1
	lea spriteLineOffset*(spriteScoreHeight)+16(a1),a1

    andi #$f,d7
    or #$b0,d7
    bsr wrtScore                            ; write to sprite
.chkNext2
    addq.l #1,a6                         ; second two digits ...
    move.b scoreNew(a6),d7
    move.b scoreOld(a6),d5
    cmp.b d5,d7
    beq.b .chkNext3

    move.b d7,scoreOld(a6)
    ;lea ([(spriteScoreBuffer).w,pc],(spriteLineOffset*spriteScoreHeight+16+2).w),a1
	move.l spriteScoreBuffer(pc),a1
	lea spriteLineOffset*(spriteScoreHeight)+16+2(a1),a1
    bsr wrtScore
.chkNext3
    addq.l #1,a6                         ; third two digits ...
    move.b scoreNew(a6),d7
    move.b scoreOld(a6),d5
    cmp.b d5,d7
    beq.b .chkNext4

    move.b d7,scoreOld(a6)
    ;lea ([(spriteScoreBuffer).w,pc],(spriteLineOffset*spriteScoreHeight+16+4).w),a1
		move.l spriteScoreBuffer(pc),a1
	lea spriteLineOffset*(spriteScoreHeight)+16+4(a1),a1

    bsr wrtScore
.chkNext4
    addq.l #1,a6                         ; fourth two digits ...
    move.b scoreNew(a6),d7
    move.b scoreOld(a6),d5
    cmp.b d5,d7
    beq.b drawHighscore
    move.b d7,scoreOld(a6)
    ;lea ([(spriteScoreBuffer).w,pc],(spriteLineOffset*spriteScoreHeight+16+6).w),a1
    	move.l spriteScoreBuffer(pc),a1
	lea spriteLineOffset*(spriteScoreHeight)+16+6(a1),a1
	bsr wrtScore

drawHighscore

    move.l scoreHigh(pc),d6
    cmp.l score(pc),d6
    bgt.w drawHighToGo                        ; is highscore higher than score?



    tst.w scoreHighSuccessFlag(pc)
    beq.b .newHigh
    rts
.newHigh
    move.b fxTable(pc),d7
    tst.b fxCountdown(pc)
    cmp.b fxPrioPlaying(pc),d7             ; prio newFx < currentFx? Skip ...


    PLAYFX 10                                ; got new high!
    move.w #$fe00,scoreHighSuccessFlag
    rts
drawHighBlink

    move.w scoreHighSuccessFlag,d2
    ;ALERT alert01,d2
	;WAITVBLANK

    add.w #1,scoreHighSuccessFlag
    beq .blinked
    moveq #%1000,d2
    cmpi #$ff00,d1
    bls .blinkFast
    lsr #1,d2
.blinkFast
    and d2,d1                       ; to blink or not to blink
    beq.b .clear
.draw
    lea newHighscorePixels(pc),a0
	move.l spriteScoreBuffer(pc),a1
	lea 16(a1),a1
    moveq #spriteScoreHeight-2,d7
        moveq #16,d4

.drawHighMsg
    movem.l (a0)+,d1-d4
    movem.l d1-d4,(a1)                  ; draw New High msg to sprite
    lea 16(a1),a1
    dbra d7,.drawHighMsg
.drawScore
    move (scoreAdder,pc),d0             ; continue with scoredraw
    bne scoreDisplay
	;move.l spriteScoreBuffer(pc),a2
	bra drawHighExtras
    rts
.clear
    moveq #spriteScoreHeight-2,d7
	move.l spriteScoreBuffer(pc),a1
	lea 16(a1),a1
;    lea ([(spriteScoreBuffer).w,pc],16.w),a1
.clearLoop
    clr.l (a1)+
    clr.l (a1)+
    clr.l (a1)+
    clr.l (a1)+
    dbra d7,.clearLoop
    bra.b .drawScore
.blinked        ; finished highscore blink
    move.w #1,scoreHighSuccessFlag
	lea updateStatDispExtra(pc),a0
	st.b (a0)
quit
	rts


drawHighToGo
    tst.b scoreMultiplier+2(pc)
    beq.b .lowMultiplier
    tst scoreMultiplier(pc)
    bne.b quit
.lowMultiplier
    lea scoreHighDelta(pc),a6
    move.l scoreHigh(pc),d6
    move.l d6,(a6)
    addq #4,a6
    lea score+4(pc),a5
    ;add #0,d0
    clr.w d0
    sbcd -(a5),-(a6)
    sbcd -(a5),-(a6)
    sbcd -(a5),-(a6)
    sbcd -(a5),-(a6)
    cmpi.l #$50000-1,(a6)    ; check if high delta > 50000
    bgt drawGo4High       ; TODO: Gameplay - Balance - Valua High Delta kicks in


    clr.l d2
    clr.w d5
    clr.w d7
    moveq #$f,d3
    moveq #spriteDMAWidth/4,d4
    move.l d4,a4
    lsr #1,d4
    moveq #4,d6

    lea scoreHighDelta(pc),a6
    move.b 1(a6),d7
    andi #$f,d7
    or #$a0,d7
 ;   lea ([(spriteScoreBuffer).w,pc],16+2.w),a1
	move.l spriteScoreBuffer(pc),a1
	lea 16+2(a1),a1
    bsr wrtScore
    move.b 2(a6),d7
    ;lea ([(spriteScoreBuffer).w,pc],16+4.w),a1
	move.l spriteScoreBuffer(pc),a1
	lea 16+4(a1),a1
    bsr wrtScore
    move.b 3(a6),d7
    ;lea ([(spriteScoreBuffer).w,pc],16+6.w),a1
	move.l spriteScoreBuffer(pc),a1
	lea 16+6(a1),a1
	;move.b #$00,d7
    bsr wrtScore

;.updateDeltaText
    tst.b updateStatDispExtra(pc)	; update only if needed
    bne.b .writeDeltaText
    rts
.writeDeltaText
	move.l spriteScoreBuffer(pc),a2
    moveq #spriteDMAWidth/4,d4
	lea 17(a2),a3
	moveq #%00100010,d0			; draw H-Char
	move.b d0,(a3)
	move.b d0,(a3,d4)
	move.b d0,spriteDMAWidth/4(a3,d4*2)
	move.b d0,(a3,d4*4)
	moveq #%00111110,d0
	move.b d0,(a3,d4*2)
	moveq #%00010001,d0			; draw H-Shadow
	move.b d0,8(a3)
	move.b d0,8(a3,d4)
	move.b d0,8+spriteDMAWidth/4(a3,d4*2)
	move.b d0,8(a3,d4*4)
	moveq #%00000001,d0
	move.b d0,8(a3,d4*2)

drawHighExtras	; draw extra stats,[spritecorebuffer] in a2

    clr.b updateStatDispExtra
	move.l spriteScoreBuffer(pc),a2
	lea 16(a2),a2
	lea plyBase(pc),a5

	lea statDisp(pc),a3
	clr.w d0
	move.b plyWeapUpgrade(a5),d0
	;moveq #spriteDMAWidth/4,d4

	lea (a3,d0*4),a3
	move.l (a3),d0
    move.b d0,24(a2)
    lsr.l #8,d0
	move.b d0,8(a2)
    lsr.l #8,d0
	move.b d0,16(a2)
    lsr.w #8,d0
	move.b d0,(a2)

	lea statDisp(pc),a3
	move.w plyAcclXCap(a5),d0	; get current player speed
	;subq #1,d0
	;lsr #2,d0
	subq #4,d0
	lsr #1,d0
	lea (a3,d0*4),a3
	lea 48(a2),a2
	move.l (a3),d0

    move.b d0,24(a2)
    lsr.l #8,d0
	move.b d0,8(a2)
    lsr.l #8,d0
	move.b d0,16(a2)
    lsr.w #8,d0
	move.b d0,(a2)


;	move d0,d1
;	lsr #8,d1
 ;   move.b d1,(a2)
  ;  move.b d0,8(a2)
   ; adda.w d4,a2
   ; move.b d1,(a2)
   ; move.b d0,8(a2)
	rts

drawGo4High
	lea go4HighPixels(pc),a0
	move.l spriteScoreBuffer(pc),a1
	lea 16(a1),a1
    moveq #spriteDMAWidth/4,d4
    moveq #spriteScoreHeight-2,d7            ; draw go 4 high
.drawGo4High
    movem.l (a0)+,d0-d3
    movem.l d0-d3,(a1)
    lea 16(a1),a1
    dbra d7,.drawGo4High

	bra drawHighExtras

drawMultiply
	SAVEREGISTERS
	move.l 4(a3),a0
	tst.l a0
	beq.b .skipSpriteSpawn
	;move.b d1,3(a3)
	move.l chainBnsAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4	;add chain display
	move objectListX(a0),d5
	move objectListY(a0),d6
    add.w #$15,d5
    clr d3
    bsr.w objectInit
    ; is sprite therefore attribs are assigned by objects-list. $40=bonus icon

	lea spriteChain8pixels+64+4,a2
	move d1,d2
	lsl #2,d1
	add d2,d1
	lsl #2,d1

	lea spriteChain8pixels+128,a1
	lea -20(a1,d1),a1 ; num pixels pointer
    moveq #spriteDMAWidth/8,d4
;#FIXME: loaded later in code again - edit
    movem.l (a1)+,d1-d3/d5-d6
    move.l d1,(a2)
    move.l d2,(a2,d4)
    move.l d3,(a2,d4*2)
    lea (a2,d4*2),a2
    move.l d5,(a2,d4)
    move.l d6,(a2,d4*2)	; draw number to sprite bitmap
.skipSpriteSpawn
    move.w scoreHighSuccessFlag(pc),d1
    bmi.b .quit             ; only draw if highmsg is not blinking
    lea multiplyPixels(pc),a0
	move.l spriteScoreBuffer(pc),a1
	lea 16(a1),a1
    moveq #spriteScoreHeight-2,d7            ; draw score multiply msg
    moveq #spriteDMAWidth/4,d4
.drawMulsMsg
    movem.l (a0)+,d1-d3/d5
    movem.l d1-d3/d5,(a1)
    lea 16(a1),a1
    dbra d7,.drawMulsMsg

	clr.w d1
    move.b scoreMultiplier+2(pc),d1
    lea 8+fontNumbers(pc,d1*8),a1
    lea 96(a1),a3	; shadow
	move.l spriteScoreBuffer,a2
	lea 16+7(a2),a2
	lea 8(a2),a4

	; draw muls num
    moveq #8,d5
    move.l (a1)+,d1
    move.b d1,(a2)
    adda.w d4,a2
    lsr.l d5,d1
    move.b d1,(a2)
    adda.w d4,a2
    lsr.l d5,d1
    move.b d1,(a2)
    adda.w d4,a2
    lsr.w d5,d1
    move.b d1,(a2)
    adda.w d4,a2
    move.b (a1),(a2)

    move.l (a3)+,d1	; draw shadow
    move.b d1,(a4)
    adda.w d4,a4
    lsr.l d5,d1
    move.b d1,(a4)
    adda.w d4,a4
    lsr.l d5,d1
    move.b d1,(a4)
    adda.w d4,a4
    lsr.w d5,d1
    move.b d1,(a4)
    adda.w d4,a4
    move.b (a3),(a4)
.quit
	RESTOREREGISTERS
	rts

fontNumbers                 ; memory for storing numbers -> quick draw. Conversion at _precalc
    blk.b 2*8*12 ;12
fontNumbersShdw=96
    cnop 0,4
newHighscorePixels; Highscore Pixeldata. First two words: sprite 7 DMA Highsuccess. 3rd word: sprite 7 manual Highsuccess, 4th word: sprite 7 manual High Delta
	dc.w %000000000100010,%0111111001000100,%1000010011111001,%1111001000010000
	dc.w %000000000010001,%0000000100100010,%0100001000000100,%0000100100001000

	dc.w %000000000110010,%0100000001000100,%1000010000100010,%0000001000010000
	dc.w %000000000001001,%0010000000100010,%0100001000010001,%0000000100001000

	dc.w %000000000101010,%0111110001010100,%1111110000100010,%1111001111110000
	dc.w %000000000010101,%0000001000101010,%0000001000010001,%0000100000001000

    dc.w %000000000100110,%0100000001101100,%1000010000100010,%0001001000010000
    dc.w %000000000010001,%0010000000010010,%0100001000010001,%0000100100001000

    dc.w %000000000100010,%0111111001000100,%1000010011111001,%1111001000010000
    dc.w %000000000010001,%0000000100100010,%0100001000000100,%0000100100001000

multiplyPixels; Multiply pixeldata
    dc.l %01111100011110001111,%00011111000111110000000000000000
    dc.l %00000010000001000000,%10000000100000001000000000000000

    dc.l %10000000100000010000,%10010000100100000010100000000000
    dc.l %01000000010000001000,%01001000010010000001010000000000

    dc.l %01111000100000010000,%10011111000111100001000000000000
    dc.l %00000100010000001000,%01000000100000010000100000000000

    dc.l %00000100100000010000,%10010000100100000010100000000000
    dc.l %00000010010000001000,%01001000010010000001010000000000

    dc.l %11111000011110001111,%00010000100111110000000000000000
    dc.l %00000100000001000000,%10001000010000001000000000000000

	IF 0=1
multiplyPixels; Multiply pixeldata
    dc.l %00011111001111000111,%10011111001111110000000000000000
    dc.l %00000000100000100000,%01000000100000001000000000000000

    dc.l %00100000010000101000,%01010000101000000001010000000000
    dc.l %00010000001000010100,%00101000010100000000101000000000

    dc.l %00011110010000001000,%01011111001111100000100000000000
    dc.l %00000001001000000100,%00100000100000010000010000000000

    dc.l %00000001010000101000,%01010000101000000001010000000000
    dc.l %00000000101000010100,%00101000010100000000101000000000

    dc.l %00111110001111000111,%10010000101111110000000000000000
    dc.l %00000001000000100000,%01001000010000001000000000000000
	ENDIF
highDeltaPixels	; shadow is calculated
	dc.b 0
    dc.b %00100000
    dc.b %01010000
    dc.b %11111000


go4HighPixels
    dc.w %01111,%0001111000000110,%001000010111110,%0111110100001000
    dc.w %00000,%1000000100000001,%000100001000001,%0000001010000100

    dc.w %10000,%0010000100001010,%001000010001000,%1000000100001000
    dc.w %01000,%0001000010000101,%000100001000100,%0100000010000100

    dc.w %10111,%1010000100010010,%001111110001000,%1011110111111000
    dc.w %01000,%0101000010001001,%000000001000100,%0100001000000100

    dc.w %10000,%1010000100011111,%0001000010001000,%1000010100001000
    dc.w %01000,%0101000010000000,%1000100001000100,%0100001010000100

    dc.w %01111,%1001111000000010,%001000010111110,%0111110100001000
    dc.w %00000,%0100000100000001,%000100001000001,%0000001010000100

statDisp
	dc.b %00100000	; 4 weap & speed stat displays
	dc.b %00100000
	dc.b %00010000	; shadow
	dc.b %00010000

	dc.b %00101000
	dc.b %00101000
	dc.b %00010100
	dc.b %00010100

	dc.b %00101010
	dc.b %00101010
	dc.b %00010101
	dc.b %00010101

	dc.b %00101010
	dc.b %00100100
	dc.b %00010101
	dc.b %00010010

    Include audio.s

	;    Incbin reshoot:data/scoreExtras

colorAlphaTable ;pseudo colorRegs which define brightness of bplCol0, bplCol1 etc. 16 values per Col
    dc.w $00,$01,$04,$05,$10,$11,$14,$15
    dc.w $40,$41,$44,$45,$50,$51,$54,$55

    dc.w $02,$03,$06,$07,$12,$13,$16,$17
    dc.w $42,$43,$46,$47,$52,$53,$56,$57

    dc.w $08,$09,$0c,$0d,$18,$19,$1c,$1d
    dc.w $48,$49,$4c,$4d,$58,$59,$5c,$5d

    dc.w $0a,$0b,$0e,$0f,$1a,$1b,$1e,$1f
    dc.w $4a,$4b,$4e,$4f,$5a,$5b,$5e,$5f

    dc.w $20,$21,$24,$25,$30,$31,$34,$35
    dc.w $60,$61,$64,$65,$70,$71,$74,$75

    dc.w $22,$23,$26,$27,$32,$33,$36,$37
    dc.w $62,$63,$66,$67,$72,$73,$76,$77

    dc.w $28,$29,$2c,$2d,$38,$39,$3c,$3d
    dc.w $68,$69,$6c,$6d,$78,$79,$7c,$7d

    dc.w $2a,$2b,$2e,$2f,$3a,$3b,$3e,$3f
    dc.w $6a,$6b,$6e,$6f,$7a,$7b,$7e,$7f

font
    Incbin incbin/font.raw
fontEnd

continueBitmap
	Incbin incbin/continue.raw
continueBitmapE

    SECTION chipData, DATA_C
    Include coplist.s

; MARK: - Level Data -

    cnop 0,8
titleSprites            ; 8 sprites 64 x 49 pixels
    Incbin incbin/titleSprites
titleSpritesOffset=(*-titleSprites)/8
titleSpritesPalette
    Incbin incbin/titleSprites.pal

    cnop 0,8
titleSoundIcon
;    Incbin reshoot:data/titleSpriteDistrib
;    Incbin reshoot:data/amiga32_logo
;	Incbin reshoot:data/evoke_logo
	;Incbin reshoot:data/classiccomputing.raw
	Incbin incbin/options		; 32 pixel sprite, no ctrl words
titleCopyRight
	Incbin incbin/copyright.raw

;!!!: Move to Fast-RAM!
coplineAnimPointers
    blk.l noOfCoplineAnims,0

    cnop 0,8	; align to 8 byte border for correct display
spritePlayerShot	; export as 64px sprites, not attached, no control
    Incbin incbin/playerShot.raw

    cnop 0,8
spritePlayerBasic	; save as 36 px high, 64 px wide attached sprite, no ctrl words
    Incbin incbin/pplayerShip.raw
spritePlayerBasicEnd


    cnop 0,4
spriteShotPod	; export as 32px wide sprites, 8 pix high, not attached, no control words
    Incbin incbin/playerShotPod.raw

spriteShotSpread	; export as 64px wide sprites, 4 px high, not attached, no control words
    Incbin incbin/playerShotSpread.raw

    cnop 0,4
spriteBullet8pixels	; export as 32px wide sprites, not attached, no control words
	Incbin incbin/enembull8.raw
	cnop 0,4

spriteBonus8pixels	; export as 32px wide sprites, not attached, no control words
    Incbin incbin/waveBonus.raw
	cnop 0,4
spriteChain8pixels	; ""
    Incbin incbin/chainBonus.raw
    Incbin incbin/chainBonusNums.raw
	cnop 0,4
spriteBullet4pixels ; export as 16px wide sprites, not attached, no control words
    Incbin incbin/enembull4.raw

    cnop 0,4
spriteBullet4Xpixels ; export as 32px wide sprites, not attached, no control words
    Incbin incbin/enembull4X.raw
spriteBullet4XpixelsSize=*-spriteBullet4Xpixels




;tileSourcePalette24:
;    Incbin reshoot:data/mainplanetiles.pal

playerShotColors
    Incbin incbin/playerShots.pal
        ; obtained color data by using PicCon, creating palette and saving it as 8 bit copperlist; import into xcode and delete all BPLCON and COLOR entrys.

enemShotColors
    Incbin incbin/enembull.pal
gfxSourcePaletteShip
    Incbin incbin/pplayerShip.pal
	even

    ;}

