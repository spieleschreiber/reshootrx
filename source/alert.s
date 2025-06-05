;//
;//  alert.s
;//  Reshoot2
;//
;//  Created by Richard Löwenstein on 25.03.17.
;//
;//

;{
    ; MARK: - Alert Manager -
    
    IF ALERTHANDLING=1
alertXPos=0
AlertManager
	SAVEREGISTERS
	tst.b gameInActionF
	beq quitAlert	; only display msg if game in action
	tst.l mainPlanesPointer
	beq quitAlert	; if bitmaps not yet init´s -> quit
alertNumJump
    moveq #0,d0
    move alertLine,d0
    andi.w #$07,d0
    move d0,d1
    lsl #2,d0
    add d1,d0
    add d1,d0
    add.w #202,d0
    move d0,alertLine+2
    move.l alertText,a0
    move.b #alertXPos,d0
    move alertLine+2(pc),d1
    move.l mainPlanesPointer,a5
    lea 40(a5),a5
    jsr wrtTextOnePlane
    move.l alertText,a0
    move.b #alertXPos,d0
    move alertLine+2(pc),d1
    move.l mainPlanesPointer+4,a5
    lea 40(a5),a5
    jsr wrtTextOnePlane
    move.l alertText,a0
    move.b #alertXPos,d0
    move alertLine+2(pc),d1
    move.l mainPlanesPointer+8,a5
    lea 40(a5),a5
    jsr wrtTextOnePlane
    add #1,alertLine

    tst.l alertNumber
    beq quitAlert
   
    lea msgNumber,a0
    move.l a0,alertText
    lea 6+8(a0),a0; pointer to eotext+two spaces
    move.l alertNumber,d0
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
    clr.l alertNumber
    bra alertNumJump
quitAlert
    RESTOREREGISTERS
    rts
;# MARK: Alert Text -
alertText
    dc.l 0
alertNumber
    dc.l 0
alertLine
    dc.w 0,0
;# MARK: Alert1
m1
    dc.b "    X      ",0
;# MARK: Alert2
m2
    dc.b "    Y     ",0
;# MARK: Alert3
m3
    dc.b "    YDIFF  ",0
;# MARK: Alert4
m4
    dc.b " SOFTINT LOOP ",0
m5
    dc.b "  frameCount ",0
msgFC
    dc.b "  frameCount ",0
msgFramerate
    dc.b "  FRAMERATE ",0
msgRasterbarNow
    dc.b "   RASTERBARNOW ",0
msgRasterbarMax
    dc.b "   RASTERBARMAX ",0
msgFrameSkip
    dc.b "  SKIP FRAME  ",0
msgGlobFlags
    dc.b "  GLOBALFLAG ",0
msgAcclVals
    dc.b "   ACCL X    Y",0
msgAcclList
    dc.b "   ALST X    Y",0
msgNoAnim
    dc.b "  CANT FIND ANIMATION ",0
msgTooManyObjects
    dc.b "  TOO MANY OBJECTS ",0
msgTooManySprites
    dc.b "  TOO MANY SPRITES ",0
msgMemCorrupt
    dc.b "  MEMORY CORRUPTION ",0
msgTemplate
    dc.b "    ",0
msgNumber
    dc.b "  HEX AAAAAAAA  ",0
    even
    ENDIF
    
    ;}
