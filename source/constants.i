;//
;//  constants.s
;//  px
;//
;//  Created by Richard Löwenstein on 19.08.19.
;//  Copyright © 2019 spieleschreiber. All rights reserved.
;//

; #MARK: - GAME CONSTANTS
;           *******************
;           *** static values
;           *******************

TRUE				=	%11111111
FALSE				=	0

black		SET	$000
darkGray	SET	$666
proximaGray	SET	$888
medGray		SET	$aaa
liteGray	SET	$eee
liteRed		SET	$e22
white		SET	$fff


optionMusicBit	set	 5	;	true	=	Music off
optionSFXBit	set	 6	;	true	=	SFX off
optionDiffBit	set	 7	;	true	= 	hard diff

tarsMax  =  	64	; some bug left, need to add 8 to desired no. of blitter objects
bulletsMax  =   110
shotsMax    =   15
objectsMax  =   shotsMax+bulletsMax+tarsMax
m
AnimPtrNoShotOffset=4*shotsMax

copperGameMaxSize	=	11000&$fff8	; align to size of 8
bobSourceSize	SET		$61000
	;	#MARK: - make sure this is set back to $50000 before release. Make sure to leave some reserve, as end of mem is used to story animcode pointers


musicMemSize	SET		300000&$fffffff8	; should be 330000 as determined by outro music size. outro music partially overwrittes object memory when loaded. Dont bother as no objects are in use in stage 5. Still, re-check everytime you use bobSource to store data
	
	PRINTV	 musicMemSize

;	280000 works

	IFNE 0		; set true to check memory footprint
	PRINTV copperGameMaxSize
	PRINTV bobSourceSize
	PRINTV spritePlayerDMASize
	PRINTV spritePosMemSize
	PRINTV spriteDMAMemSize
	PRINTV spriteParallaxBufferSize
	PRINTV musicMemSize
	PRINTT "TOTAL:"
	PRINTV copperGameMaxSize+bobSourceSize+spritePlayerDMASize+spritePosMemSize+spriteDMAMemSize+spriteParallaxBufferSize+musicMemSize
	ENDIF

mainPlaneDepth   =   4
fxPlaneDepth  =   4

displayWindowStart   =   $2c
displayWindowStop   =   $28
DisplayWindowHeight	= displayWindowStop+$100-displayWindowStart
mainPlaneWidth    =  	40	; .b
mainPlaneHeight    =  	80

fxPlaneWidth 		=	40
fxplaneHeight    	=   512
fxPlaneHeightBig	= 	768

artworkPictureSize =   64*256*8
artworkPaletteSize  =   64*4        ; 64 color entrys 24bit

; MARK: - TILEMAP DEFINITIONS


tileWidth       =   32
tileHeight      =   32
tilesWidth      =   (tileWidth/8)*8          ; 16 tiles
tilesHeight     =   256
tileSourceMemSize      =   tilesWidth*tilesHeight*mainPlaneDepth
tileSourceMaxTile = tilesWidth/4*(tilesHeight/32)

viewXOffset=128
viewLeftClip=viewXOffset+48
viewRightClip=viewXOffset+332
viewUpClip=1
viewDownClip=256+displayWindowStop-44



; #MARK: - PLAYER DEFINITIONS

playerExtraHeight  =   9
playerBodyHeight  =   28
playerShotHeight  =   24
playerShotMaxNo		=	18






spritePlayerWidth  =   $24
spriteScoreHeight  =   5
spriteParallaxHeight = 256*2
spriteScoreXPosition =   162
spriteStatusXPosition =   94
spriteScoreYPosition =   displayWindowStart+$2; should be 2
spriteScoreCtlrWordLo = spriteScoreYPosition<<8+(spriteScoreXPosition)
spriteScoreCtlrWordHi = (spriteScoreYPosition+50-1)<<8!%00000000<<0
spriteParallaxCtlrWordLo = $32<<8+0<<0
spriteParallaxCtlrWordHi = displayWindowStop<<8!%00000010<<0
;spriteParallaxCtlrWordHi=spriteHiCtlrWordHi
spriteDMAHeight    =   4 ; just some typical value for calc memsize
spriteDMAWidth    =   64
spriteLineOffset    = spriteDMAWidth/8*2
spriteLineSize	=	spriteLineOffset
spritePlayerDMASize=2*(((playerShotHeight-5)*playerShotMaxNo))*(spriteDMAWidth/4)

	;#FIXME: Too much memory consumption. Reduce!
spriteDMAMemSize=((bulletsMax+2)*spriteLineOffset*(spriteDMAHeight+1))*4*2; calculated for four bullet sprites; spriteDMAHeight plus control slot; 4 animation frames. Two buffers!
spriteDMAListOffset=((spriteDMAMemSize/4)/8)&$fffc; has to be dividable by 8  
spriteScoreBufferSize  =   spriteLineOffset*(spriteScoreHeight+1)*2
spriteParallaxBufferSize  =   ((spriteParallaxHeight*spriteLineSize)+32)*2
spriteParMultiSize  =   32*4

copSplitListSize   =   256*2
noOfCoplines SET (displayWindowStop+$100-displayWindowStart)/2
noOfCoplineAnims SET $3b
copLinePrecalcSize  =  	noOfCoplines*4*noOfCoplineAnims ; no.lines*size of 1 entry*max width

spritePosMemSize=(294*10) ;space for 294 lines, first 48 not really needed (but kept to speed code up a little). 4 bytes per entry
collListEntrySize   =   12
collListBobOffset   =   shotsMax*collListEntrySize
collListSize =   (tarsMax+4)*collListEntrySize	; bit too big, since bullets would not need slot here. Accelerates object init proc though, so there you go   
	

attrIsNoRefresh			=	0
attrIsKillBorderExit	=	1
attrIsLink				=	2
attrIsAvailB			=	3
attrIsYadd				=	4
attrIsNotHitable		=	5
attrIsOpaq				=	6						; add "attribs 64" to object definition for object without no mask, to save memory and blitter dma cycles
attrIsBonus				=	6						; bit 6 has two tasks. IsBonus is used with sprites only, therefore IsOpaq is meaningless in such cases
attrIsSprite			=	7

attrIsNoRefreshF		=	1<<attrIsNoRefresh
attrIsKillBorderExitF	=	1<<attrIsKillBorderExit
attrIsLinkF				=	1<<attrIsLink
attrIsAvailBF			=	1<<attrIsAvailB
attrIsYaddF				=	1<<attrIsYadd
attrIsNotHitableF		=	1<<attrIsNotHitable
attrIsOpaqF				=	1<<attrIsOpaq
attrIsBonusF			=	1<<attrIsBonus
attrIsSpriteF			=	1<<attrIsSprite


	RSRESET
collTableAnimActionAdr		rs.l	1
collTableYCoords			rs.l	1
collTableXCoords			rs.l	1

	RSRESET
bobRestoreListSource    rs.l 	1
bobRestoreListTarget    rs.l 	1
bobRestoreListBlitSize  rs.w 	1
bobRestoreListEntrySize rs.w	1
bobRestoreListSize  =   (tarsMax+1)*bobRestoreListEntrySize*2
	RSRESET
bobDrawBLTMOD  			rs.w	1
bobDrawBLTSIZE 			rs.w	1
bobDrawTargetOffset		rs.w	1
bobDrawBLTCON0  		rs.w	1
bobDrawMaskOffset		rs.w	1
bobDrawSource    		rs.l 	1
bobDrawListEntrySize	rs.w 	1
bobDrawListSize    = (tarsMax+1)*bobDrawListEntrySize*2

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
launchTableRptXAdd			rs.b	1
launchTableAttribs			rs.b	1	;$80=Launch at static position; $40=non-opaque bob
launchTableHitpoints		rs.b	1
launchTableNotUsed			rs.b	1

;           object-list keeps track of each object. All values stored in lword-pairs with .b,.w & .l-size

objectListAnimPtr=0						;.w
objectListAttr=objectListAnimPtr+2		;.b
objectListNotUsed=	objectListAnimPtr+2	;.b
objectListX=objectsMax*4                 ;.l
objectListEntrySize=objectListX
objectListY=objectListX*2         ;.l
objectListAcc=objectListX*3      ;.l
objectListAccX=objectListAcc      ;.w
objectListAccY=objectListAcc+2   ;.w
objectListHit=objectListX*4       ;.w
objectListCnt=objectListHit+2  ;.b
objectListDestroy=objectListCnt+1  ;.b
objectListMyParent=objectListX*5    ;.l
objectListMyChild=objectListX*6    ;.l
objectListGroupCnt=objectListX*7    ;.w
objectListLoopCnt=objectListGroupCnt+2  ;.b
objectListWaveIndx=objectListGroupCnt+3  ;.b
objectListLaunchPointer=objectListX*8  ;.l
objectListMainParent=objectListX*9  ;.l
objectListTriggers=objectListX*10  ;.l
objectListTriggersB=objectListX*11  ;.l
objectListSize=objectListTriggersB+objectListX
	
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
objectDefSize					rs.w	1	; needed to determine size of data chunk in XML decoding, not used ingame

fontBitmapWidth=320/8
charToSpriteMaxRows	SET 24
fontHeight	SET 6	; size of font
charHeight	SET 8	; size of char (.fontHeight + empty rows)


	; visual appearance, coplist definitions
lv0parSprSlowEntry=145
lv0parSprSlowExit=209

escalateStart=$60       ; copper sub list, one line scrolling
escalateHeight=64
	
dialogueStart=$40
dialogueHeight=50
	
