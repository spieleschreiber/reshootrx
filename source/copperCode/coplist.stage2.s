;//
;//  coplist.submarine.s
;//  PX
;//
;//  Created by Richard Löwenstein on 31.07.19.
;//

	INCDIR $AMIDEV
	INCDIR source
	INCDIR source/system; search these folders for includes
	INCLUDE targetcontrol.s
	INCLUDE custom.i
	INCLUDE constants.i
	PRINTT
	PRINTT "*** Compiling Stage 3 Copperlist"
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
firstColFade	SET	0
upGrColor	SET	$69e
parSpriteY SET displayWindowStart+1
colorYSprite SET parSpriteY+7
scoreLines SET spriteScoreHeight-1
noOfScanlines SET displayWindowHeight-2

dispHeight	SET displayWindowStop+256-displayWindowStart
dispQuarter	SET dispHeight/4

red		SET 	0<<4		; start values
green	SET 	35<<4
blue	SET 	10<<4
redA	SET	red
greenA	SET	green
blueA	SET	blue
redFac		SET 	(red-03<<4)	; target values
greenFac	SET 	(green-15<<4)
blueFac		SET		(blue-08<<4)
rgbHigh	SET		0	; empty containers for hi and lo byte of color value
rgbLow	SET		0

COPCOLSPLIT	Macro
	IF (parSpriteY=\1)
lowCol	SET \2+\3
medCol	SET \2+(\3*2)
highCol	SET \2+(\3*3)


rgbHigh	SET	(medCol&$f0)|(medCol>>1&$f0)>>4
rgbLow		SET	(medCol&$f)<<4|(medCol>>1&$f0)
rgbHighB	SET	(HighCol&$f0)|(HighCol>>1&$f0)>>4
rgbLowB		SET	(HighCol&$f)<<4|(HighCol>>1&$f0)
rgbHighC	SET	(lowCol&$f0)|(lowCol>>1&$f0)>>4
rgbLowC		SET	(lowCol&$f)<<4|(lowCol>>1&$f0)

	CMOVE BPLCON3,BANK2F|BANK1F|BANK0F|BRDRBLNKF
	dc.w COLOR29
	dc.w rgbHigh
	dc.w COLOR30
	dc.w rgbHighB
	CMOVE BPLCON3,BANK2F|BANK1F|BANK0F|BRDRBLNKF|LOCTF|PF2OF1F|PF2OF0F
	dc.w COLOR29
	dc.w rgbLow
	dc.w COLOR30
	dc.w rgbLowB
	ENDIF
	ENDM
	
COLORFADE MACRO
redA	SET 	(red-((redFac/(displayWindowHeight-10))*parSpriteY))>>4
greenA SET	 (green-((greenFac/(displayWindowHeight-10))*parSpriteY))>>4
blueA	SET	(blue-((blueFac/(displayWindowHeight-10))*parSpriteY))>>4
rgbHigh0old	SET	rgbHigh0
rgbHigh0	SET	(redA&$f0)<<4!(greenA&$f0)!(blueA&$f0)>>4
rgbLow0old	SET	rgbLow0
rgbLow0	SET	(redA&$f)<<8!(greenA&$f)<<4!(blueA&$f)
	
	IFEQ firstColFade
firstColFade	SET rgbHigh0 
firstColFadeLo	SET rgbLow0
	ENDIF
statusHigh	SET (rgbHigh0old-rgbHigh0)
statusLow	SET (rgbLow0old-rgbLow0)

	IFNE statusHigh|statusLow
		dc.w (parSpriteY<<8)&$fffe+$03
		dc.w $ff<<8+%11111110
		IFNE statusHigh
		CMOVE BPLCON3,BRDRBLNKF|PF2OF1F|PF2OF0F
			IFNE (rgbHigh0old-rgbHigh0)
			dc.w COLOR00
			dc.w rgbHigh0
			ENDIF
		ENDIF
		
		IFNE statusLow
		CMOVE BPLCON3,LOCTF!BRDRBLNKF|PF2OF1F|PF2OF0F
			IFNE (rgbLow0old-rgbLow0)
			dc.w COLOR00
			dc.w	rgbLow0
			ENDIF
		ENDIF
		ELSE
		IFEQ (parSpriteY&1)
		dc.w (parSpriteY<<8)&$fffe+$03
		dc.w $ff<<8+%11111110
		ENDIF
		ENDIF
	ENDM

; write to sprite 
			CMOVE SPR7PTL,0 
			CMOVE SPR7PTH,0	; pointer to left score panel

    CMOVE FMODE,%1111  ;64 pixel sprites
	CWAIT (displayWindowStart<<8)!$df
	CMOVE BPL1MOD,mainPlaneWidth*(mainPlaneDepth-1)
	CMOVE BPL2MOD,0
	CMOVE COLOR14,$111	; left score panel shadow
	CMOVE COLOR30,$111	; right score panel shadow
    COLORFADE
	CMOVE BPLCON1,0		; init scroll register 

		; begin drawing view  
		
    REPT noOfScanlines
parSpriteX SET $58
		; score view area / coloring 

		IF (parSpriteY=spriteScoreYPosition); color score sprite
		CMOVE BPLCON2,%111111	; sprites 6/7 infront of playfield 
		CMOVE BPLCON3,$fc00!BRDRBLNKF
		CMOVE COLOR13,$fff
		CMOVE COLOR15,$fff
		CMOVE COLOR29,$fff
		CMOVE COLOR31,$fff
upgrColor	SET 	$6af
		ENDIF
		IF (parSpriteY=spriteScoreYPosition+1); color score sprite
		CMOVE COLOR13,$ecf
		CMOVE COLOR15,$ecf
		CMOVE COLOR29,$ffc
		CMOVE COLOR31,$ffc
		ENDIF
		IF (parSpriteY=spriteScoreYPosition+2)
		CMOVE COLOR13,$d8f
		CMOVE COLOR15,$d8f
		CMOVE COLOR29,$fe8
		CMOVE COLOR31,$fe8
		ENDIF
		IF (parSpriteY=spriteScoreYPosition+3)
		CMOVE COLOR13,$b5f
		CMOVE COLOR15,$b5f
		CMOVE COLOR29,$fd6
		CMOVE COLOR31,$fd5
		ENDIF
		IF (parSpriteY=spriteScoreYPosition+4)
		CMOVE COLOR13,$a4f
		CMOVE COLOR15,$a4f
		CMOVE COLOR29,$fc4
		CMOVE COLOR31,$fb3
		dc.w (parSpriteY<<8)&$fffe+$cf
		dc.w $ff<<8+%11111110
			CMOVE NOOP,6
			CMOVE SPR6PTL,0; init parallax scrolling sprite dma
			CMOVE SPR6PTH,0
			CMOVE SPR7PTL,0 
			CMOVE SPR7PTH,0
			CMOVE SPR6POS,$307c	; reposition scroll sprites
		CMOVE SPR6CTL,$ff02
		CMOVE SPR7POS,$3000
		CMOVE SPR7CTL,$3202
		CMOVE BPLCON2,%011011	; sprites 6/7 behind of playfield
		CMOVE COLOR13,$457;$457	; reset ship color 
		CMOVE color14,$012		; reset ship color + sprite parallax color
		CMOVE COLOR15,$eef	; reset ship color
		CMOVE COLOR31,$021
		ENDIF

		IF (parSpriteY=spriteScoreYPosition+8)
		CMOVE BPLCON3,$fc00!BRDRBLNKF
		CMOVE color14,$011		; reset ship color + sprite parallax color
		ENDIF
		IF (parSpriteY=spriteScoreYPosition+12)
		CMOVE BPLCON3,$fc00!BRDRBLNKF
		CMOVE color14,$000		; reset ship color + sprite parallax color
		ENDIF
					CMOVE BPLCON3,BANK2F|BANK1F|BANK0F|BRDRBLNKF
		
		;CMOVE COLOR31,-1

		COPCOLSPLIT $32,26,2
		IF 1=1
		COPCOLSPLIT $38,26,3
		COPCOLSPLIT $40,26,5
		COPCOLSPLIT $42,26,8
		COPCOLSPLIT $44,26,10
		ENDIF

	IFEQ ((parSpriteY-displayWindowStart-1)&$3f)
		CMOVE NOOP,15     ; color bullet marker
		dc.w	$80ff	; wait
		dc.w	$80c3

		CMOVE BPLCON3,BANK2F|BANK1F|BANK0F|BRDRBLNKF	; prep colors for next frame update
	
		CMOVE COLOR05,0	; set three colors for four sprites
		CMOVE COLOR21,0
		CMOVE COLOR09,0
		CMOVE COLOR25,0

		CMOVE COLOR06,0
		CMOVE COLOR22,0
		CMOVE COLOR10,0
		CMOVE COLOR26,0

		CMOVE COLOR07,0
		CMOVE COLOR23,0
		CMOVE COLOR11,0
		CMOVE COLOR27,0
	ENDIF

		IF (parSpriteY=displayWindowStart+dispQuarter)|(parSpriteY=displayWindowStart+dispQuarter*2+1)|(parSpriteY=displayWindowStart+dispQuarter*3)
        CMOVE NOOP,14     ; sprite6pos marker
		CMOVE spr6pos,0
		CMOVE spr6ctl,$1
		ENDIF	

		dc.w (parSpriteY<<8)&$ff00+$df
		dc.w $ff<<8+%11111110

    IF (parSpriteY&1)
;		CMOVE BPLCON3,$e020
yDistort	SET 	parSpriteY>>4
	;CMOVE SPR6CTL,0
	;CMOVE SPR7CTL,0
;	CMOVE NOOP,0
;	CMOVE NOOP,0
	ELSE
	CMOVE BPLCON1,0
	IF (parSpriteY>=spriteScoreYPosition+10)&(parSpriteY<=spriteScoreYPosition+255)
	COLORFADE
	ENDIF
 	ENDIF
	
		; mark 	reversal ofBPL2MOD
        IF (parSpriteY=displayWindowStart+125)
		dc.w (parSpriteY+1<<8)&$ff00+$2f
		dc.w $ff<<8+%11111110

        CMOVE NOOP,13     ; reversal marker
    	CMOVELC BPL2PT
		CMOVELC BPL4PT
		CMOVELC BPL6PT
		CMOVELC BPL8PT
		CMOVE BPL2MOD,-40*2
		ENDIF
	IF (parSpriteY=displayWindowStart+249)
		dc.w (parSpriteY+1<<8)&$ff00+$2f
		dc.w $ff<<8+%11111110

		CMOVE BPL2MOD,40*2
	ENDIF

	; mark start of escalate view
        IF (parSpriteY=escalateStart+1)
        CMOVE NOOP,1     ; escalate start marker
        CMOVE COP1LCH,0
        CMOVE COP1LCL,0
        CMOVE NOOP,0   ; jump to init escalate view
        ENDIF
        IF (parSpriteY=escalateStart+escalateHeight-5)
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
parSpriteY     SET parSpriteY+$1
    ENDR
;	CMOVE SPR6CTL,0
;	CMOVE SPR7CTL,0

		dc.w (parSpriteY<<8)&$ff00+$df
		dc.w $ff<<8+%11111110
		CMOVE BPLCON3,BRDRBLNKF	; prep colors for next frame update
		CMOVE COLOR00,firstColFade
		CMOVE COLOR01,$3ce	; ugly color fix for CD32 color bug
	;frame update
;		CMOVE COLOR00,firstColFadeLo
		
;		CMOVE BPLCON3,$e000!BRDRBLNKF
;				COPCOLSPLIT $32,45,24

;		CMOVE COLOR31,$a07
;		CMOVE COLOR30,$503
;		CMOVE COLOR29,$102
;		CMOVE BPL2MOD,0
	blk.w 8,0


