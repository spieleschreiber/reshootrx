;//
;//  coplist3.s
;//  Reshoot2
;//
;//  Created by Richard Löwenstein on 30.01.19.
;//

; #MARK: - City parallax list -

	INCDIR $AMIDEV
	INCDIR source/
	INCDIR source/system/; search these folders for includes
	INCLUDE source/!targetcontrol.i
	INCDIR			include/
	INCLUDE include/custom.i
	INCLUDE source/constants.i
	PRINTT
	PRINTT "*** Compiling Stage 4 Copperlist"
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

s1
red		SET 	$40		; start values
green	SET 	$40
blue	SET 	$40
redFac		SET 	(red-$e0)/54	; target values
greenFac	SET 	(green-$20)/54
blueFac		SET		(blue-$10)/54

rgbHigh	SET		0	; empty containers for hi and lo byte of color value
rgbLow	SET		0

PAINTSKY	Macro
	IF (parSpriteY&%10=0); color mod every 4 scanlines
red	SET 	red-redFac*3
green SET	green-greenFac*2
blue	SET	blue-blueFac*2
rgbHigh	SET	(red&$f0)<<4!(green&$f0)!(blue&$f0)>>4
rgbLow	SET	(red&$f)<<8!(green&$f)<<4!(blue&$f)
		CMOVE BPLCON3,PF2OF2F!BRDRBLNKF
		dc.w COLOR00
		dc.w rgbHigh
		CMOVE BPLCON3,PF2OF2F!LOCTF!BRDRBLNKF
		dc.w COLOR00
		dc.w	rgbLow
	ENDIF
	ENDM

copGameParallaxCity:

upGrColor	SET	$69e
parSpriteY SET displayWindowStart+1
colorYSprite SET parSpriteY
scoreLines SET spriteScoreHeight-1
noOfScanlines SET displayWindowStop+$100-displayWindowStart-scoreLines*2

    CMOVE BPL2MOD,$4
    
    CMOVE BPLCON1,0
		

   ; CMOVE BPLCON3,$f000!BRDRBLNKF
    CMOVE COLOR13,upgrColor			; color extra stats
;		CMOVE BPLCON3,$1000!BRDRBLNKF!$40

;    CMOVE BPLCON3,BANK0F!BANK1F!BANK2F!PF2OF2!BRDRBLNKF
 ;   CMOVE COLOR13,$c4a			; color extra stats
;		CMOVE BPLCON3,$1000!BRDRBLNKF!$40
	CMOVE BPLCON3,PF2OF2F!BRDRBLNKF
	CMOVE COLOR00,$444
	CMOVE BPLCON3,BANK0F!BANK1F!BANK2F!PF2OF2F!BRDRBLNKF
    ; handle upper area
	;CMOVE BPLCON2,%000011!PF2PRIF


    ; handle upper area
	;CMOVE BPLCON2,%000011!PF2PRIF

    REPT scoreLines+1

	dc.w (parSpriteY<<8)&$fffe+$b1
	dc.w $ff<<8+%11111110
	CMOVE BPLCON2,%111111!PF2PRIF

	IF (parSpriteY=colorYSprite); color score sprite
        CMOVE COLOR13,$69e	; upgrades color
		CMOVE COLOR13,$b20
	ENDIF
	IF (parSpriteY=colorYSprite+1); color score sprite
        CMOVE COLOR13,$6af	; ""
		CMOVE COLOR13,$c30
	ENDIF
	IF (parSpriteY=colorYSprite+2)
		CMOVE COLOR13,$6af	; ""
		CMOVE COLOR13,$d50
	ENDIF
	IF (parSpriteY=colorYSprite+3)
		CMOVE COLOR13,$d88	; ""
		CMOVE COLOR13,$e61
	ENDIF
	IF (parSpriteY=colorYSprite+4)
		CMOVE COLOR13,$fa8	; ""
		CMOVE COLOR13,$f82
		dc.w (parSpriteY<<8)&$ff00+$df
		dc.w $ff<<8+%11111110

		CMOVE BPL7DAT,0	; mark color switch and main playfield priority
		CMOVE BPLCON3,$f000!BRDRBLNKF
   		CMOVE COLOR13,$0  ;reset score color cos it colors player sprite too
		CMOVE NOOP,0	; is BPLCON2 in some coplists
	ENDIF

		dc.w (parSpriteY<<8)&$ff00+$df-(parSpriteY<(displayWindowStart+4))*2	; wait in relation to scanline / modulus timing avoid flicker
		dc.w $ff<<8+%11111110
	CMOVE NOOP,5
	CMOVE BPLCON2,%11!PF2PRIF ; sprites 6&7 video prio down


  	 ;IF (parSpriteY&1)
	 ;   CMOVE BPL2MOD,$4
    ;	CNOOP
    ;	CMOVE BPLCON1,0
    ;	ELSE
    ;	CMOVE BPL2MOD,-4
	;ENDIF


parSpriteY     SET parSpriteY+$1
    ENDR

; handle main screen area

	;CMOVE BPLCON2,%000011!PF2PRIF



	;CMOVE BPLCON2,%001001
    REPT noOfScanlines-4
parSpriteX SET $3a
	
    REPT 0
    dc.w (parSpriteY<<8)&$ff00+parSpriteX-$4!1
    dc.w $ff<<8+%11111110
	CMOVE $170,(parSpriteY<<8)&$ff00+parSpriteX+3

parSpriteX     SET parSpriteX+$20
    ENDR
    IF (parSpriteY&1)
        CMOVE BPL2MOD,$14
        dc.w (parSpriteY<<8)&$ff00+$df
        dc.w $ff<<8+%11111110
        CMOVE BPLCON1,0
	IF parSpriteY<escalateStart
	PAINTSKY
	ENDIF
	IF parSpriteY>escalateStart+escalateHeight-4
	PAINTSKY
	ENDIF

    ELSE
    	CMOVE BPL2MOD,$14
        dc.w (parSpriteY<<8)&$ff00+$df
        dc.w $ff<<8+%11111110

	; mark start of escalate view

		IF (parSpriteY=escalateStart+2)
        CMOVE NOOP,1     ; escalate start marker
        CMOVE COP1LCH,0
        CMOVE COP1LCL,0
        CMOVE NOOP,0   ; jump to init escalate view
        ENDIF


	; escalate exit marker
        IF (parSpriteY=escalateStart+escalateHeight-4)
        CMOVE NOOP,2     ; mark escalate end
        CMOVE COP1LCH,0
        CMOVE COP1LCL,0
        CMOVE NOOP,0   ; jump to restore game view
        ENDIF

		IF parSpriteY=154	; reset priority to avoid dialoge glitch
		CMOVE BPLCON2,%11!PF2PRIF
		ENDIF

		IF parSpriteY=180	; reached hor. border, def new color jfade
		; morph from old to new color
redFac		SET 	-redFac	; target values
greenFac	SET 	-greenFac
blueFac		SET		-blueFac
	;ENDIF
		ENDIF
    ENDIF



		IF (parSpriteY=lv0parSprSlowEntry-60)
		CMOVE SPR6CTL,0	; sprite scroll slow
		CMOVE BPLCON3,$f020
		CMOVE COLOR29,$a44
		CMOVE COLOR30,$b44
		CMOVE COLOR31,$b44
		ENDIF

		IF (parSpriteY=lv0parSprSlowExit)
		CMOVE SPR6CTL,0 ; sprite scroll fast
		CMOVE BPLCON3,$f020
		CMOVE COLOR29,$b44
		CMOVE COLOR30,$b54
		CMOVE COLOR31,$b54

		ENDIF

		IF (parSpriteY=lv0parSprSlowExit+45)
		;CMOVE SPR6CTL,0	; sprite scroll slow
		CMOVE BPLCON3,$f020
		CMOVE COLOR29,$b53
		CMOVE COLOR30,$b54
		CMOVE COLOR31,$b56
		ENDIF

        ;#FIXME: mark entry for gameFin copperlist
;.gameFinStart	SET $103
        IF (parSpriteY=$103)	; gameFinStart defined in coplist.credits.s

        CMOVE NOOP,3     ; mark gameFin start
        CMOVE COP1LCH,0
        CMOVE COP1LCL,0
        CMOVE NOOP,0   ; jump to gamefin view
		ENDIF

		IF parSpriteY=$103+5
		CMOVE NOOP,4	; reentry incase of final credits
		ENDIF


parSpriteY     SET parSpriteY+$1
    ENDR
	CMOVE $170,0	; hide parallax sprite

; handle lower area
    CMOVE BPLCON2,%000011!PF2PRIF
colorYSprite SET parSpriteY+1
    REPT scoreLines+2
parSpriteX SET $3a
	REPT 4
    dc.w (parSpriteY<<8)&$ff00+parSpriteX-$4!1
    dc.w $ff<<8+%11111110
	CMOVE $170,(parSpriteY<<8)&$ff00+parSpriteX+3
parSpriteX     SET parSpriteX+$20
    ENDR

	dc.w (parSpriteY<<8)&$fffe+$b9
	dc.w $ff<<8+%11111110
    CMOVE BPLCON2,%111111!PF2PRIF	; score sprite to front

    	IF (parSpriteY=colorYSprite-1)     ; color score sprite
	CMOVE BPLCON3,$f000!BRDRBLNKF
	CMOVE COLOR13,$88f
	ENDIF
	IF (parSpriteY=colorYSprite+1)     ; color score sprite
	CMOVE COLOR13,$66c
	ENDIF
	IF (parSpriteY=colorYSprite+2)
	CMOVE COLOR13,$338
	ENDIF
	IF (parSpriteY=colorYSprite+3)
	CMOVE COLOR13,$224
	ENDIF
		dc.w (parSpriteY<<8)&$ff00+$df+(parSpriteY<(displayWindowStart+3))*4	; wait in relation to scanline / modulus timing avoid flicker
		dc.w $ff<<8+%11111110
	CMOVE BPLCON2,%11!PF2PRIF
    IF (parSpriteY&1)
    ;CMOVE BPL2MOD,$18
    cnoop
    ;cnoop
    ;CMOVE BPLCON1,0
    ELSE
    ;CMOVE BPL2MOD,$18
	;IF parSpriteY<displayWindowStart+210
    ;BLUESKY
    ;ENDIF


    ENDIF

parSpriteY     SET parSpriteY+$1
	ENDR

	;CMOVE BPLCON3,$1000!BRDRBLNKF
	;CMOVE $180,$7cf
	;CMOVE BPLCON3,$1000!BRDRBLNKF!LOCTF
	;CMOVE $180,$7cf

	CMOVE NOOP,8     ; end of list marker
copGameParallaxCityEnd     blk.w 8,0
s2
