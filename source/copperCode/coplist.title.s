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



	CMOVE BPLCON3,BRDSPRTF!SPRES1F
	CMOVE COLOR00,0


	;CMOVE COLOR03,$22
	; set colors for shadow
	CMOVE BPLCON3,BANK0F!BANK1F!BANK2F!BRDSPRTF!SPRES1F
.shadowUp	SET $111
	CMOVE COLOR17,.shadowUp
	CMOVE COLOR21,.shadowUp
	CMOVE COLOR25,.shadowUp
    

	; set colors for number logo part
	
.dither		SET	liteRed
	CMOVE COLOR29,.shadowUp
	CMOVE COLOR30,liteRed	 
	CMOVE COLOR31,.dither	 

	CMOVE BPLCON3,BANK0F!BANK1F!BANK2F!BRDSPRTF!SPRES1F!LOCTF
	CMOVE COLOR17,0
	CMOVE COLOR21,0
	CMOVE COLOR25,0
	CMOVE COLOR29,0


	REPT displayWindowStop+256-displayWindowStart
parSpriteY     SET rasterline

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
	ELSE
	IF (rasterline<textspriteLine+textspriteSize)
	CMOVE BPLCON3,BRDSPRTF
	dc.w COLOR03
	dc.w rgbHigh

	CMOVE BPLCON3,BRDSPRTF!LOCTF
	dc.w COLOR03
	dc.w	rgbLow

	ELSE
	dc.w (rasterline<<8)&$fffe!$01
	dc.w $ff<<8+%11111110
	CMOVE BPLCON3,BRDSPRTF
	CMOVE BPLCON3,BANK0F!BANK1F!BANK2F!BRDSPRTF
	CMOVE COLOR21,white
	CMOVE COLOR29,black
	CMOVE DDFSTRT,$38
	CMOVE DDFSTOP,$a0
	dc.w (rasterline<<8)&$fffe!$a3
	dc.w $ff<<8+%11111110
	CMOVE BPLCON3,BANK0F!BANK1F!BANK2F!BRDSPRTF!SPRES1F
	IF (rasterline<textspriteLine+textspriteSize+8)
	;CMOVE COLOR21,white	; colors spieleschreiber logo upper red part. Outcommented to fix display bug on real hardware, and insert DDFSTRT/DDFSTOP. Else -> crash
    CMOVE COLOR22,$e77
    CMOVE COLOR23,liteRed
    CMOVE COLOR29,white
    CMOVE COLOR30,medGray
    CMOVE COLOR31,liteRed
    ELSE
	CMOVE COLOR21,black	; colors spieleschreiber logo lower shadow and copyright part
    CMOVE COLOR29,white
    CMOVE COLOR30,medGray
    ENDIF
	ENDIF
	ENDIF
		
	; set colors for upper logo part
	IF (rasterline>parSpriteCheck)&(rasterline<(parSpriteCheck+noOfScanlines))
	COLORFADE
	ENDIF
	
	; set colors for lower logo part
	IF rasterline=(parSpriteCheck+noOfScanlines)
.dither		SET		darkGray
	CMOVE BPLCON3,BANK0F!BANK1F!BANK2F!BRDSPRTF!SPRES1F
	dc.w COLOR18
	dc.w proximaGray
	dc.w COLOR19
	dc.w .dither
	dc.w COLOR22
	dc.w proximaGray
	dc.w COLOR23
	dc.w .dither
	dc.w COLOR26
	dc.w proximaGray
	dc.w COLOR27
	dc.w .dither
	ENDIF

	; set text sprites
	IF rasterline=textspriteLine-5
    CMOVE NOOP,0
    CMOVELC SPR0PTH
    CMOVELC SPR1PTH
    CMOVELC SPR2PTH
    CMOVELC SPR4PTH
    CMOVELC SPR5PTH
    CMOVELC SPR6PTH

    CMOVE NOOP,1
    CMOVE 	SPR0POS,(rasterline&$ff)<<8+$60
    CMOVE	SPR0CTL,$2802
    CMOVE 	SPR1POS,(rasterline&$ff)<<8+$80
    CMOVE	SPR1CTL,$2802
    CMOVE 	SPR2POS,(rasterline&$ff)<<8+$a0
    CMOVE	SPR2CTL,$2802
    CMOVE 	SPR4POS,(rasterline+2&$ff)<<8+$60
    CMOVE	SPR4CTL,$281a
    CMOVE 	SPR5POS,(rasterline+2&$ff)<<8+$80
    CMOVE	SPR5CTL,$281a
    CMOVE 	SPR6POS,((rasterline+2)&$ff)<<8+$a0
    CMOVE	SPR6CTL,$281a

    CMOVE NOOP,2
	CMOVE BPLCON3,BANK0F!BANK1F!BANK2F!BRDSPRTF
	dc.w COLOR17
	dc.w white	 ; front color sprite chars
	dc.w COLOR18
	dc.w liteRed	 ; secondary front color
	dc.w COLOR21
	dc.w white	; front color sprite chars
	dc.w COLOR22
	dc.w liteRed	 ; secondary front color
	dc.w COLOR25
	dc.w black	; shadow color
	dc.w COLOR26
	dc.w black	; shadow color
	dc.w COLOR29
	dc.w black	; shadow color
	dc.w COLOR30
	dc.w black	; shadow color

    ENDIF
	; display player vessel
	IF rasterline=$bb
	;dc.w (rasterline<<8)&$fffe!$97
	;dc.w $ff<<8+%11111110
	CMOVE BPL1MOD,-16
	CMOVE BPL2MOD,-16
	ENDIF
	IF rasterline=$bc
	CMOVE BPL1MOD,-8
	CMOVE BPL2MOD,-8
	CMOVE BPLCON3,BANK0F!BRDSPRTF
    CMOVE NOOP,4		; marker to fetch colorregs jet engine
    CMOVE COLOR14,0
	CMOVE COLOR15,0
	CMOVE COLOR16,0
	CMOVE COLOR29,0
	CMOVE COLOR30,0
	CMOVE COLOR31,0
	;CMOVE BPL1MOD,-16
	;CMOVE BPL2MOD,-16
	CMOVE NOOP,5	; marker for BPLCON1-list
	ENDIF
	
	IF (rasterline>$bc)&(rasterline<$11e)	; modify x-scroll value each scanline
	dc.w (rasterline<<8)&$fffe!$c7
	dc.w $ff<<8+%11111110
	CMOVE BPLCON1,0
	ENDIF

	IF rasterline=$100+displayWindowStop-9
    CMOVE NOOP,3	; reposition spieleschreiber logo
    CMOVELC SPR3PTH
    CMOVELC SPR7PTH
    CMOVE 	SPR3POS,(rasterline&$ff)<<8+$ad
    CMOVE	SPR3CTL,$280d
    CMOVE 	SPR7POS,(rasterline&$ff)<<8+$bd
    CMOVE	SPR7CTL,$280d
	ENDIF

rasterline	SET	rasterline+$1 
	ENDR
	CMOVE BPL1MOD,-40	; reset modulus -> empty background
	CMOVE BPL2MOD,-40
.lightGray	SET 	$999
.dither		SET		$777
	CMOVE BPLCON3,BANK0F!BANK1F!BANK2F!BRDSPRTF!SPRES1F	; reset some rp3-logo colors
	dc.w COLOR22
	dc.w .lightGray
	dc.w COLOR23
	dc.w .dither
	dc.w COLOR26
	dc.w .lightGray
	dc.w COLOR27
	dc.w .dither


	;CMOVE DDFSTRT,$38
	;CMOVE DDFSTOP,$a0

    INCBIN incbin/copper/title_vessel.pal.cop	; add palette
	blk.w 8,0



