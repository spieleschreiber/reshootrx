;//
;//  coplist.title.s
;//  Proxima 3
;//
;//  Created by Richard Löwenstein on 02.02.19.
;//

;#MARK: - Intro
	INCDIR $AMIDEV
	INCDIR source
	INCDIR source/system; search these folders for includes
	INCLUDE targetcontrol.s
	INCLUDE custom.i
	INCLUDE constants.i
	PRINTT "*** Compiling Title Copperlist"

CMOVE		Macro
		  dc.w		\1&$1fe,\2
		Endm
CMOVEL		Macro
		  dc.w		\1&$1fe,\2
          dc.w      (\1+2)&$1fe,\3
		Endm

CMOVELC		Macro
		  dc.w		\1&$1fe,0
          dc.w      (\1+2)&$1fe,0
		Endm
CWAIT		Macro
	dc.w		\1!1
	dc.w		-2	; Comp.-Enable-Mask
			Endm
CNOOP   MACRO
    CMOVE NOOP,0
        ENDM
CEND        Macro
		  dc.w		$ffff,$fffe
		Endm

noOfScanlines SET 25
parSpriteY SET displayWindowStart+24
parSpriteCheck	 SET parSpriteY



red		SET 	$91<<4		; start values
green	SET 	$94<<4
blue	SET 	$9a<<4
redA	SET	red
greenA	SET	green
blueA	SET	blue
redFac		SET 	(red-$e0<<4)	; target values
greenFac	SET 	(green-$e0<<4)
blueFac		SET		(blue-$e0<<4)
rgbHigh	SET		0	; empty containers for hi and lo byte of color value
rgbLow	SET		0

GETRGB	MACRO
redA	SET 	(red-((redFac/noOfScanlines)*factor))>>4
greenA SET	 (green-((greenFac/noOfScanlines)*factor))>>4
blueA	SET	(blue-((blueFac/noOfScanlines)*factor))>>4
	ENDM

DITHER	MACRO
factorB	SET factor/3
redB	SET 	(red-((redFac/noOfScanlines)*factorB))>>4
greenB SET	 (green-((greenFac/noOfScanlines)*factorB))>>4
blueB	SET	(blue-((blueFac/noOfScanlines)*factorB))>>4
		dc.w (redB&$f0)<<4!(greenB&$f0)!(blueB&$f0)>>4
		ENDM

COLORFADE MACRO
	dc.w (parSpriteY<<8)&$fffe+$03
	dc.w $ff<<8+%11111110
	CMOVE BPLCON3,BANK0F!BANK1F!BANK2F!BRDSPRTF!SPRES1F

factor	SET parSpriteY-(displayWindowStart+24)
	GETRGB
rgbHigh	SET	(redA&$f0)<<4!(greenA&$f0)!(blueA&$f0)>>4
	dc.w COLOR18
	dc.w rgbHigh
	dc.w COLOR19
	DITHER

factor	SET factor+$01
	GETRGB
rgbHigh	SET	(redA&$f0)<<4!(greenA&$f0)!(blueA&$f0)>>4
	dc.w COLOR22
	dc.w rgbHigh
	dc.w COLOR23
	DITHER

factor	SET factor+$02
	GETRGB
rgbHigh	SET	(redA&$f0)<<4!(greenA&$f0)!(blueA&$f0)>>4
	dc.w COLOR26
	dc.w rgbHigh
	dc.w COLOR27
	DITHER


	CMOVE BPLCON3,BANK0F!BANK1F!BANK2F!BRDSPRTF!SPRES1F!LOCTF

factor	SET parSpriteY-(displayWindowStart+24)
	GETRGB
rgbLow	SET	(redA&$f)<<8!(greenA&$f)<<4!(blueA&$f)
	dc.w COLOR18
	dc.w rgbLow

factor	SET factor+$01
	GETRGB
rgbLow	SET	(redA&$f)<<8!(greenA&$f)<<4!(blueA&$f)
	dc.w COLOR22
	dc.w rgbLow

factor	SET factor+$02
	GETRGB
rgbLow	SET	(redA&$f)<<8!(greenA&$f)<<4!(blueA&$f)
	dc.w COLOR26
	dc.w rgbLow
	ENDM


fadeRed		SET	$00<<4
fadeGreen	SET	$2b<<4
fadeBlue	SET	$2b<<4
rasterline	SET 	displayWindowStart
textspriteLine	SET	parSpriteCheck+noOfScanlines+40
textspriteSize	SET	155

    CMOVE BPLCON3,BANK0F!BANK1F!BANK2F!BRDSPRTF!SPRES1F
    CMOVE FMODE,%0000000000001111  ;64 pixel sprites
    CMOVE BPLCON2,%111111
    CMOVE DDFSTRT,$48
    CMOVE DDFSTOP,$b0


	; set colors for shadow
	CMOVE BPLCON3,BANK0F!BANK1F!BANK2F!BRDSPRTF!SPRES1F
.shadowUp	SET $111
	CMOVE COLOR17,.shadowUp
	CMOVE COLOR21,.shadowUp
	CMOVE COLOR25,.shadowUp

	; set colors for number logo part
.red		SET	$e22
.dither		SET	$c22
	CMOVE COLOR29,.shadowUp
	CMOVE COLOR30,.red
	CMOVE COLOR31,.dither

	CMOVE BPLCON3,BANK0F!BANK1F!BANK2F!BRDSPRTF!SPRES1F!LOCTF
	CMOVE COLOR17,0
	CMOVE COLOR21,0
	CMOVE COLOR25,0
	CMOVE COLOR29,0


	; set colors for upper logo part
	REPT noOfScanlines
	COLORFADE
parSpriteY     SET parSpriteY+$1
	ENDR


	; set colors for lower logo part
	dc.w (parSpriteY<<8)&$fffe+$03
	dc.w $ff<<8+%11111110
.lightGray	SET 	$888
.dither		SET		$666
	CMOVE BPLCON3,BANK0F!BANK1F!BANK2F!BRDSPRTF!SPRES1F
	dc.w COLOR18
	dc.w .lightGray
	dc.w COLOR19
	dc.w .dither
	dc.w COLOR22
	dc.w .lightGray
	dc.w COLOR23
	dc.w .dither
	dc.w COLOR26
	dc.w .lightGray
	dc.w COLOR27
	dc.w .dither


	; set colors for spieleschreiber logo
	CWAIT $7001
.medRed	SET	$e88
    CMOVE COLOR17,liteRed
    CMOVE COLOR21,liteRed
    CMOVE COLOR25,liteRed
    CMOVE COLOR29,liteRed
    CMOVE COLOR18,.medRed
    CMOVE COLOR22,.medRed
    CMOVE COLOR26,.medRed
    CMOVE COLOR30,.medRed
    CMOVE COLOR19,liteGray
    CMOVE COLOR23,liteGray
    CMOVE COLOR27,liteGray
    CMOVE COLOR31,liteGray


	REPT 100
	dc.w (rasterline<<8)&$fffe!$03
	dc.w $ff<<8+%11111110

fadeRed		SET		fadeRed+3
fadeGreen	SET 	fadeGreen+7
fadeBlue	SET		fadeBlue+7
redA	SET 	fadeRed>>4
greenA SET	 fadeGreen>>4
blueA	SET	fadeBlue>>4
rgbHigh	SET	(redA&$f0)<<4!(greenA&$f0)!(blueA&$f0)>>4
rgbLow	SET	(redA&$f)<<8!(greenA&$f)<<4!(blueA&$f)

	IF (rasterline<textspriteLine-4)
	CMOVE BPLCON3,BRDSPRTF!SPRES1F
	dc.w COLOR03
	dc.w rgbHigh
	CMOVE BPLCON3,BRDSPRTF!LOCTF!SPRES1F
	dc.w COLOR03
	dc.w	rgbLow
	ENDIF



rasterline	SET	rasterline+$1

	ENDR




	CWAIT $ffdf
	CWAIT $2c01

	INCBIN incbin/copper/intropic.pal.cop	; add palette
	blk.w 8,0


