;//
;//  coplist.stars.s
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

stopColFade	SET	10
colFadeRasters	SET stopColFade+20
upGrColor	SET	$69e
parSpriteY SET displayWindowStart+1
colorYSprite SET parSpriteY+7
scoreLines SET spriteScoreHeight-1
noOfScanlines SET displayWindowHeight-2
.startColByte	SET	$ff
.mod2val	SET	0
.add		SET	0
.addEQ		SET	1
.addEQA		SET	6
.addEQB		SET	1

red0		SET $48<<4		; start values
green0	SET 	$53<<4
blue0	SET 	$e4<<4
redFac0		SET 	(red0-$66<<4)	; target values
greenFac0	SET 	(green0-$76<<4)
blueFac0		SET		(blue0-$fc<<4)

rgbHigh	SET		0	; empty containers for hi and lo byte of color value
rgbLow	SET		0

COPCOLSPLIT	Macro
	IF (parSpriteY=\1)
	CMOVE BPLCON3,(%1110<<12)|BRDRBLNKF|PF2OF2F
	dc.w COLOR29
	dc.w \2
	dc.w COLOR30
	dc.w \3
	dc.w COLOR31
	dc.w \4
	ENDIF
	ENDM
	
COLORFADE MACRO
redA	SET 	(red0-((redFac0/(displayWindowHeight+290))*parSpriteY+85))>>4
greenA SET	 (green0-((greenFac0/(displayWindowHeight+290))*parSpriteY+85))>>4
blueA	SET	(blue0-((blueFac0/(displayWindowHeight+290))*parSpriteY+85))>>4
rgbHigh0old	SET	rgbHigh0
rgbHigh0	SET	(redA&$f0)<<4!(greenA&$f0)!(blueA&$f0)>>4
rgbLow0old	SET	rgbLow0
rgbLow0	SET	(redA&$f)<<8!(greenA&$f)<<4!(blueA&$f)

	
statusHigh	SET (rgbHigh0old-rgbHigh0)
statusLow	SET (rgbLow0old-rgbLow0)
	if 1=1
	IFNE statusHigh|statusLow
		dc.w (parSpriteY<<8)&$fffe+$03
		dc.w $ff<<8+%11111110
		IFNE statusHigh
		CMOVE BPLCON3,PF2OF2F|BRDRBLNKF
			IFNE (rgbHigh0old-rgbHigh0)
			dc.w COLOR00
			dc.w rgbHigh0
			ENDIF
		ENDIF
		
		IFNE statusLow
		CMOVE BPLCON3,PF2OF2F!LOCTF!BRDRBLNKF
			IFNE (rgbLow0old-rgbLow0)
			dc.w COLOR00
			dc.w	rgbLow0
			ENDIF
		ENDIF
	ENDIF
	Endif
	ENDM

; write to sprite
			CMOVE SPR7PTL,0
			CMOVE SPR7PTH,0	; pointer to left score panel
		;CMOVE AUD3DAT,0
    CMOVE FMODE,%1111  ;64 pixel sprites
	CWAIT (displayWindowStart<<8)!$df
	CMOVE BPL1MOD,mainPlaneWidth*(mainPlaneDepth-1)
	CMOVE COLOR14,$111	; left score panel shadow
	CMOVE COLOR30,$111	; right score panel shadow
	CMOVE BPLCON1,0		; init scroll register
		dc.w BPL2MOD
		dc.w 0
		;CMOVE BPLCON3,PF2OF2F|BRDRBLNKF
		;CMOVE COLOR00,$fff	; set blue sky color
		CMOVE BPLCON3,PF2OF2F|LOCTF|BRDRBLNKF
		;CMOVE COLOR00,-1
    REPT noOfScanlines
parSpriteX SET $4e
		; score view area / coloring 
	;IF (parSpriteY<spriteScoreYPosition+spriteScoreHeight)
		IF (parSpriteY=spriteScoreYPosition); color score sprite
		CMOVE BPLCON2,%111111	; sprites 6/7 infront of playfield 
		CMOVE BPLCON3,$f000!BRDRBLNKF
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
		CMOVE BPLCON2,%011011	; sprites 6/7 behind of playfield
		CMOVE COLOR13,$457	; reset player vessel spotlight right of the cockpit  + sprite parallax color. Basic color: $457
	
		CMOVE COLOR15,$eef	; reset ship color
			CMOVE SPR6POS,$1098	; reposition scroll sprite
			CMOVE SPR6CTL,0
			CMOVE SPR7POS,$1000	; reposition scroll sprite
			CMOVE SPR7CTL,0
			;CMOVE BPLCON3,PF2OF2F|BRDRBLNKF
			CMOVE BPLCON3,$f000!BRDRBLNKF

		CMOVE COLOR29,$55f;$45e
		CMOVE COLOR30,$55f;$44f
		CMOVE COLOR31,$55f;$34e
		;CMOVE BPLCON3,(%1110<<12)|BRDRBLNKF|PF2OF2F|LOCTF
		;CMOVE COLOR30,0

;		CMOVE COLOR30,$67f;$46e
;		CMOVE COLOR31,$79f;$57e

		ENDIF
	IFNE 1
		IF (parSpriteY>spriteScoreYPosition+4)
parSpriteX	SET $52-12
				; main view area / multiplex sprite 
;		dc.w (parSpriteY<<8)&$ff00+parSpriteX-$10!1
;		dc.w $ff<<8+%11111110
;		CMOVE SPR6POS,(parSpriteY<<8)&$ff00+parSpriteX+$0
parSpriteX     SET parSpriteX+$20
		dc.w (parSpriteY<<8)&$ff00+parSpriteX-$8!1
		dc.w $ff<<8+%11111110
		CMOVE SPR6POS,(parSpriteY<<8)&$ff00+parSpriteX+$0
parSpriteX     SET parSpriteX+$18
		dc.w (parSpriteY<<8)&$ff00+parSpriteX-$18!1
		dc.w $ff<<8+%11111110
		CMOVE SPR6POS,(parSpriteY<<8)&$ff00+parSpriteX+$0
parSpriteX     SET parSpriteX+$18
		dc.w (parSpriteY<<8)&$ff00+parSpriteX-$8!1
		dc.w $ff<<8+%11111110
		CMOVE SPR6POS,(parSpriteY<<8)&$ff00+parSpriteX+$10
		ENDIF
	ENDIF

;	ELSE
	; color-fade-in parallax layer sprite
	COPCOLSPLIT $32,$55f,$45f,$55e
	COPCOLSPLIT $36,$55f,$55e,$55e
	COPCOLSPLIT $38,$45f,$55e,$55d
	COPCOLSPLIT $3a,$45e,$55e,$56d
	COPCOLSPLIT $3d,$45e,$56e,$56d

		;CMOVE DMACON,1<<5	; strange bug in FS-UAE - if sprite DMA is off, bits PF1H0 and PF1H1 work perfectly

   ;ENDIF
		dc.w (parSpriteY<<8)&$ff00+$df
		dc.w $ff<<8+%11111110
		    IFEQ (parSpriteY&1)
	CMOVE BPLCON1,0

	;CMOVE BPL6DAT,0
	ENDIF


	;IF (parSpriteY>50)
	IFEQ ((parSpriteY-displayWindowStart+4)&$3f)
		CMOVE NOOP,15     ; color bullet marker
		dc.w	$80ff	; wait
		dc.w	$80c3
		CMOVE BPLCON3,BANK2F|BANK1F|BANK0F|BRDRBLNKF	; prep colors for next frame update
;		CMOVE BPLCON3,BRDRBLNKF
		CMOVE COLOR05,-1	; set three colors for four sprites
		CMOVE COLOR21,-1
		CMOVE COLOR09,-1
		CMOVE COLOR25,-1

		CMOVE COLOR06,-1
		CMOVE COLOR22,-1
		CMOVE COLOR10,-1
		CMOVE COLOR26,-1

		CMOVE COLOR07,-1
		CMOVE COLOR23,-1
		CMOVE COLOR11,-1
		CMOVE COLOR27,-1

	ENDIF
	;ENDIF
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

        
parSpriteY     SET parSpriteY+$1
	ENDR

;	CMOVE SPR6CTL,0
;	CMOVE SPR7CTL,0
		dc.w (parSpriteY<<8)&$ff00+$df
		dc.w $ff<<8+%11111110
		CMOVE BPLCON3,BRDRBLNKF	; prep colors for next frame update
		CMOVE COLOR00,$55f
		CMOVE COLOR01,$7dc	; ugly color fix for CD32 color bug
	blk.w 8,0


