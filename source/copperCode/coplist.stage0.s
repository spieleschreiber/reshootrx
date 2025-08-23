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
	PRINTT "*** Compiling Stage 0 Copperlist"
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
red		SET 	$10		; start values
green	SET 	16
blue	SET 	15
redFac		SET 	(red-$00)/54	; target values
greenFac	SET 	(green+$01)/54
blueFac		SET		(blue+$01)/54

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

copGameStage0:

upGrColor	SET	$69e
parSpriteY SET displayWindowStart+1
colorYSprite SET parSpriteY
scoreLines SET spriteScoreHeight-1
noOfScanlines SET displayWindowStop+$100-displayWindowStart-scoreLines*2

    CMOVE BPL2MOD,$4
    CMOVE BPL1MOD,4
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

		CMOVE BPLCON3,$f000!BRDRBLNKF
   		CMOVE COLOR13,$0  ;reset score color cos it colors player sprite too
		CMOVE NOOP,0	; is BPLCON2 in some coplists
	ENDIF

		dc.w (parSpriteY<<8)&$ff00+$df-(parSpriteY<(displayWindowStart+4))*2	; wait in relation to scanline / modulus timing avoid flicker
		dc.w $ff<<8+%11111110
	CMOVE NOOP,5
	CMOVE BPLCON2,%11!PF2PRIF ; sprites 6&7 video prio down
	;CMOVE BPLCON2,PF2PRIF ; sprites 6&7 video prio down


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



    REPT noOfScanlines-2

;
; copy sprite 6 to playfield
	CMOVE	 BPLCON2,%11111111

parSpriteYOffset SET 60
parSpriteYSize SET 100
	IF	 ((parSpriteY>displayWindowStart+parSpriteYOffset)&&(parSpriteY<displayWindowStart+parSpriteYOffset+parSpriteYSize))
parSpriteX SET $40	
		REPT 5
		dc.w (parSpriteY<<8)&$ff00+parSpriteX-$10!1

		dc.w $ff<<8+%11111110
		CMOVE SPR6POS,(parSpriteY<<8)&$ff00+parSpriteX+3
parSpriteX     SET parSpriteX+$20
		ENDR
	ENDIF
	IF	 (parSpriteY=displayWindowStart+parSpriteYOffset+parSpriteYSize)
	CMOVE SPR6POS,0	; hide parallax sprite	
	ENDIF
	cmove	 spr2pos,$6060
	
	CMOVE spr2ctl,$ff02
;
; build vfx playfield scrolling	
;
    IF (parSpriteY&1)
        CMOVE BPL2MOD,$14	; modifier for playfield scrolling
        dc.w (parSpriteY<<8)&$ff00+$df
        dc.w $ff<<8+%11111110
        CMOVE BPLCON1,0
    ELSE
    	CMOVE BPL2MOD,$14	; static modulus
        dc.w (parSpriteY<<8)&$ff00+$df
        dc.w $ff<<8+%11111110
	ENDIF

; mark start of escalate view
        IF (parSpriteY=escalateStart+1)
        CMOVE NOOP,1     ; escalate start marker
        CMOVE COP1LCH,0
        CMOVE COP1LCL,0
        CMOVE NOOP,0   ; jump to init escalate view
        ENDIF
        IF (parSpriteY=escalateStart+escalateHeight-4)
		CMOVE NOOP,2     ; mark escalate end
        ENDIF


	; mark of dialogue view
        IF (parSpriteY=dialogueStart+1)
        CMOVE NOOP,9     ; dialogue start marker
        CMOVE COP1LCH,0
        CMOVE COP1LCL,0
        CMOVE NOOP,0   ; jump to init escalate view
        ENDIF
        IF (parSpriteY=dialogueStart+dialogueHeight-4)
        CMOVE NOOP,10     ; mark dialogue end
        ENDIF


	; mark achievements view
        IF (parSpriteY=$38)
        CMOVE NOOP,11     ; achievements start marker
        CMOVE COP1LCH,0
        CMOVE COP1LCL,0
        CMOVE NOOP,0   ; jump to init achievements view

        ENDIF
        IF (parSpriteY=$f8)
        CMOVE NOOP,12     ; achievements clean up marker
        CMOVE COP1LCH,0
        CMOVE COP1LCL,0
        CMOVE NOOP,0   ; jump to init achievements view
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

		IF (parSpriteY=lv0parSprSlowEntry-60)
		CMOVE SPR6CTL,0	; sprite scroll slow
		CMOVE BPLCON3,$f020
		CMOVE COLOR29,$a44
		CMOVE COLOR30,$b44
		CMOVE COLOR31,$b44
		ENDIF
	
	;IF parSpriteY<escalateStart
	;PAINTSKY
	;ENDIF$AMIDEV/source/scripts/makefile
	
	;IF parSpriteY>escalateStart+escalateHeight-4
	;PAINTSKY
	;ENDIF



	;CMOVE SPR6POS,0	; hide parallax sprite

; handle lower area

	IF	 (parSpriteY=spriteStatusYPosition-1)			
		CMOVE	 SPR6POS,spriteStatusXPosition<<8+spriteStatusYPosition
		CMOVE SPR6CTL,((spriteStatusYPosition-$100+spriteScoreHeight)<<8)+%110
		CMOVE DMACON,$8200+(1<<7)
		CMOVE NOOP,6
		CMOVE SPR6PTL,0; init score status sprite dma
		CMOVE SPR6PTH,0
		CMOVE BPLCON2,%111111!PF2PRIF; score sprite to front
	ENDIF

	IF	 (parSpriteY>spriteStatusYPosition)			
		IF (parSpriteY=spriteStatusYPosition+1)     ; color score sprite
		CMOVE BPLCON3,$f000!BRDRBLNKF
		CMOVE COLOR13,$88f
		ENDIF
		IF (parSpriteY=spriteStatusYPosition+2)     ; color score sprite
		CMOVE COLOR13,$55b
		ENDIF
		IF (parSpriteY=spriteStatusYPosition+3)
		CMOVE COLOR13,$338
		ENDIF
		IF (parSpriteY=spriteStatusYPosition+4)
		CMOVE COLOR13,$224
		ENDIF
	ENDIF
parSpriteY     SET parSpriteY+$1
	ENDR

	;CMOVE BPLCON3,$1000!BRDRBLNKF
	;CMOVE $180,$7cf
	;CMOVE BPLCON3,$1000!BRDRBLNKF!LOCTF
	;CMOVE $180,$7cf

	CMOVE NOOP,8     ; end of list marker
copGameStage0End     blk.w 8,0

