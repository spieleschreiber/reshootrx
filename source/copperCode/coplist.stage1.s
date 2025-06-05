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
	PRINTT "*** Compiling Stage 1 Copperlist"
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

stopColFade	SET	126
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
red0		SET 	.startColByte<<4		; start values
green0	SET 	.startColByte<<4
blue0	SET 	.startColByte<<4
red1		SET 	.startColByte<<4		; start values
green1	SET 	.startColByte<<4
blue1	SET 	.startColByte<<4
red2		SET 	.startColByte<<4		; start values
green2	SET 	.startColByte<<4
blue2	SET 	.startColByte<<4
red3		SET 	.startColByte<<4		; start values
green3	SET 	.startColByte<<4
blue3	SET 	.startColByte<<4
red4		SET 	.startColByte<<4		; start values
green4	SET 	.startColByte<<4
blue4	SET 	.startColByte<<4
red5		SET 	.startColByte<<4		; start values
green5	SET 	.startColByte<<4
blue5	SET 	.startColByte<<4
red6		SET 	.startColByte<<4		; start values
green6	SET 	.startColByte<<4
blue6	SET 	.startColByte<<4
red7		SET 	.startColByte<<4		; start values
green7	SET 	.startColByte<<4
blue7	SET 	.startColByte<<4
redFac0		SET 	(red0-$23<<4)	; target values
greenFac0	SET 	(green0-$04<<4)
blueFac0		SET		(blue0-$04<<4)

redFac1		SET 	(red1-$7d<<4)	; target values
greenFac1	SET 	(green1-$45<<4)
blueFac1		SET		(blue1-$34<<4)

redFac2		SET 	(red2-$a8<<4)	; target values
greenFac2	SET 	(green2-$57<<4)
blueFac2		SET		(blue2-$34<<4)

redFac3		SET 	(red3-$9c<<4)	; target values
greenFac3	SET 	(green3-$93<<4)
blueFac3		SET		(blue3-$50<<4)

redFac4		SET 	(red4-$99<<4)	; target values
greenFac4	SET 	(green4-$89<<4)
blueFac4		SET		(blue4-$34<<4)

redFac5		SET 	(red5-$92<<4)	; target values
greenFac5	SET 	(green5-$66<<4)
blueFac5		SET		(blue5-$34<<4)

redFac6		SET 	(red6-$64<<4)	; target values
greenFac6	SET 	(green6-$3a<<4)
blueFac6		SET		(blue6-$34<<4)

redFac7		SET 	(red7-$9c<<4)	; target values
greenFac7	SET 	(green7-$9e<<4)
blueFac7		SET		(blue7-$84<<4)
rgbHigh	SET		0	; empty containers for hi and lo byte of color value
rgbLow	SET		0

COPCOLSPLIT	Macro
	IF (parSpriteY=\1)
	CMOVE BPLCON3,PF2OF2F|BRDRBLNKF
	dc.w COLOR00
	dc.w \2
	dc.w COLOR17
	dc.w \2
	dc.w COLOR18
	dc.w \2
	dc.w COLOR19
	dc.w \2
	dc.w COLOR20
	dc.w \2
	dc.w COLOR21
	dc.w \2
	dc.w COLOR22
	dc.w \2
	dc.w COLOR23
	dc.w \2
	ENDIF
	ENDM

COLORFADE MACRO
redA	SET 	(red0-((redFac0/colFadeRasters)*parSpriteY-1400))>>4
greenA SET	 (green0-((greenFac0/colFadeRasters+3)*parSpriteY-1500))>>4
blueA	SET	(blue0-((blueFac0/colFadeRasters+3)*parSpriteY-1500))>>4
rgbHigh0old	SET	rgbHigh0
rgbHigh0	SET	(redA&$f0)<<4!(greenA&$f0)!(blueA&$f0)>>4
rgbLow0	SET	(redA&$f)<<8!(greenA&$f)<<4!(blueA&$f)
		dc.w (parSpriteY<<8)&$fffe+$03
		dc.w $ff<<8+%11111110
	CMOVE BPLCON3,PF2OF2F|BRDRBLNKF
	IFNE (rgbHigh0old-rgbHigh0)
	dc.w COLOR00
	dc.w rgbHigh0
	;PRINTV rgbHigh0
	;PRINTV rgbLow0
	ENDIF

redA	SET 	(red1-((redFac1/colFadeRasters+5)*parSpriteY-1100))>>4
greenA SET	 (green1-((greenFac1/colFadeRasters+4)*parSpriteY-1200))>>4
blueA	SET	(blue1-((blueFac1/colFadeRasters+5)*parSpriteY-1300))>>4
rgbHigh1old	SET	rgbHigh1
rgbHigh1	SET	(redA&$f0)<<4!(greenA&$f0)!(blueA&$f0)>>4
rgbLow1	SET	(redA&$f)<<8!(greenA&$f)<<4!(blueA&$f)
	IFNE (rgbHigh1old-rgbHigh1)
	dc.w COLOR18
	dc.w rgbHigh1
	ENDIF

redA	SET 	(red2-((redFac2/colFadeRasters+6)*parSpriteY-1000))>>4
greenA SET	 (green2-((greenFac2/colFadeRasters+4)*parSpriteY-1000))>>4
blueA	SET	(blue2-((blueFac2/colFadeRasters+3)*parSpriteY-1000))>>4
rgbHigh2old	SET	rgbHigh2
rgbHigh2	SET	(redA&$f0)<<4!(greenA&$f0)!(blueA&$f0)>>4
rgbLow2	SET	(redA&$f)<<8!(greenA&$f)<<4!(blueA&$f)
	IFNE (rgbHigh2old-rgbHigh2)
	dc.w COLOR19
	dc.w rgbHigh2
	ENDIF

redA	SET 	(red3-((redFac3/colFadeRasters+4)*parSpriteY-900))>>4
greenA SET	 (green3-((greenFac3/colFadeRasters+0)*parSpriteY-400))>>4
blueA	SET	(blue3-((blueFac3/colFadeRasters+2)*parSpriteY-900))>>4
rgbHigh3old	SET	rgbHigh3
rgbHigh3	SET	(redA&$f0)<<4!(greenA&$f0)!(blueA&$f0)>>4
rgbLow3	SET	(redA&$f)<<8!(greenA&$f)<<4!(blueA&$f)
	IFNE (rgbHigh3old-rgbHigh3)
	dc.w COLOR22
	dc.w rgbHigh3
	ENDIF

redA	SET 	(red4-((redFac4/colFadeRasters+3)*parSpriteY-600))>>4
greenA SET	 (green4-((greenFac4/colFadeRasters+4)*parSpriteY-800))>>4
blueA	SET	(blue4-((blueFac4/colFadeRasters+2)*parSpriteY-800))>>4
rgbHigh4old	SET	rgbHigh4
rgbHigh4	SET	(redA&$f0)<<4!(greenA&$f0)!(blueA&$f0)>>4
rgbLow4	SET	(redA&$f)<<8!(greenA&$f)<<4!(blueA&$f)
	IFNE (rgbHigh4old-rgbHigh4)
	dc.w COLOR21
	dc.w rgbHigh4
	ENDIF

redA	SET 	(red5-((redFac5/colFadeRasters+3)*parSpriteY-800))>>4
greenA SET	 (green5-((greenFac5/colFadeRasters+3)*parSpriteY-900))>>4
blueA	SET	(blue5-((blueFac5/colFadeRasters+2)*parSpriteY-900))>>4
rgbHigh5old	SET	rgbHigh5
rgbHigh5	SET	(redA&$f0)<<4!(greenA&$f0)!(blueA&$f0)>>4
rgbLow5	SET	(redA&$f)<<8!(greenA&$f)<<4!(blueA&$f)
	IFNE (rgbHigh5old-rgbHigh5)
	dc.w COLOR20
	dc.w rgbHigh5
	ENDIF

redA	SET 	(red6-((redFac6/colFadeRasters+3)*parSpriteY-1000))>>4
greenA SET	 (green6-((greenFac6/colFadeRasters+3)*parSpriteY-900))>>4
blueA	SET	(blue6-((blueFac6/colFadeRasters+3)*parSpriteY-900))>>4
rgbHigh6old	SET	rgbHigh6
rgbHigh6	SET	(redA&$f0)<<4!(greenA&$f0)!(blueA&$f0)>>4
rgbLow6	SET	(redA&$f)<<8!(greenA&$f)<<4!(blueA&$f)
	IFNE (rgbHigh6old-rgbHigh6)
	dc.w COLOR17
	dc.w	rgbHigh6
	ENDIF

redA	SET 	(red7-((redFac7/colFadeRasters+2)*parSpriteY-600))>>4
greenA SET	 (green7-((greenFac7/colFadeRasters+3)*parSpriteY-500))>>4
blueA	SET	(blue7-((blueFac7/colFadeRasters+2)*parSpriteY-700))>>4
rgbHigh7old	SET	rgbHigh7
rgbHigh7	SET	(redA&$f0)<<4!(greenA&$f0)!(blueA&$f0)>>4
rgbLow7	SET	(redA&$f)<<8!(greenA&$f)<<4!(blueA&$f)
	IFNE (rgbHigh7old-rgbHigh7)
	dc.w COLOR23
	dc.w rgbHigh7
	ENDIF
	CMOVE BPLCON3,PF2OF2F!LOCTF!BRDRBLNKF
	dc.w COLOR00
	dc.w	rgbLow0
	dc.w COLOR17
	dc.w	rgbLow6
	dc.w COLOR18
	dc.w	rgbLow1
	dc.w COLOR19
	dc.w	rgbLow2
	dc.w COLOR20
	dc.w	rgbLow5
	dc.w COLOR21
	dc.w	rgbLow4
	dc.w COLOR22
	dc.w	rgbLow3
	dc.w COLOR23
	dc.w	rgbLow7
	ENDM

; write to sprite
			CMOVE SPR7PTL,0
			CMOVE SPR7PTH,0	; pointer to left score panel

    CMOVE FMODE,%1111  ;64 pixel sprites

	CWAIT (displayWindowStart<<8)!$df
	CMOVE BPL1MOD,mainPlaneWidth*(mainPlaneDepth-1)
	CMOVE COLOR14,$111	; left score panel shadow
	CMOVE COLOR30,$111	; right score panel shadow
    ;COLORFADE
	CMOVE BPLCON1,0		; init scroll register
		dc.w BPL2MOD
		dc.w -1*40
		;dc.w
		;dc.w -98*40
		; begin drawing view

    REPT noOfScanlines
parSpriteX SET $4e
		; score view area / coloring

	IF parSpriteY>104
	IFEQ ((parSpriteY-displayWindowStart+4)&$3f)
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
	ENDIF



	IF (parSpriteY<spriteScoreYPosition+spriteScoreHeight)
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
			CMOVE SPR7PTL,0
			CMOVE SPR7PTH,0
		CMOVE BPLCON2,%011011	; sprites 6/7 behind of playfield
		CMOVE COLOR13,$457	; reset ship color + sprite parallax color
		CMOVE COLOR15,$eef	; reset ship color
			CMOVE SPR6POS,$50e0	; reposition scroll sprite
			CMOVE SPR7POS,$50e0	; reposition scroll sprite
			CMOVE SPR6CTL,$2802
			CMOVE SPR7CTL,$2802
	ENDIF



	ELSE

;	COPCOLSPLIT $32,$830
;	IF 0=1
	COPCOLSPLIT $33,$840
	COPCOLSPLIT $34,$841
	COPCOLSPLIT $35,$962
;	ENDIF
	COPCOLSPLIT $36,$a62
	COPCOLSPLIT $37,$d84
	COPCOLSPLIT $38,$ea8
	COPCOLSPLIT $39,$fcc
	COPCOLSPLIT $3a,$fed
	COPCOLSPLIT $3b,$fff
	COPCOLSPLIT $3c,$fee




		IF (parSpriteY=spriteScoreYPosition+122)	; reposition parallax sprite
			CMOVE SPR6POS,$5070	; reposition scroll sprite
			CMOVE SPR7POS,$5090	; reposition scroll sprite
			CMOVE BPLCON3,BANK2F!BANK1F!BANK0F!PF2OF2F|BRDRBLNKF
			CMOVE COLOR30,$522
			CMOVE COLOR14,$522
		ENDIF

		IF (parSpriteY=spriteScoreYPosition+126)	; reposition parallax sprite
			CMOVE BPLCON3,BANK2F!BANK1F!BANK0F!PF2OF2F|BRDRBLNKF
			CMOVE COLOR30,$422
			CMOVE COLOR14,$422
		ENDIF

		IF (parSpriteY=spriteScoreYPosition+130)	; reposition parallax sprite
			CMOVE BPLCON3,BANK2F!BANK1F!BANK0F!PF2OF2F|BRDRBLNKF
			CMOVE COLOR30,$421
			CMOVE COLOR14,$421
		ENDIF
		IF (parSpriteY=spriteScoreYPosition+134)	; reposition parallax sprite
			CMOVE BPLCON3,BANK2F!BANK1F!BANK0F!PF2OF2F|BRDRBLNKF
			CMOVE COLOR30,$321
			CMOVE COLOR14,$321
		ENDIF
		IF (parSpriteY=spriteScoreYPosition+148)	; reposition parallax sprite
			CMOVE BPLCON3,BANK2F!BANK1F!BANK0F!PF2OF2F|BRDRBLNKF
			CMOVE COLOR30,$310
			CMOVE COLOR14,$310
		ENDIF
		IF (parSpriteY=spriteScoreYPosition+160)	; reposition parallax sprite
			CMOVE BPLCON3,BANK2F!BANK1F!BANK0F!PF2OF2F|BRDRBLNKF
			CMOVE COLOR30,$200
			CMOVE COLOR14,$200
		ENDIF

		IF (parSpriteY>spriteScoreYPosition+120)
		IFEQ (parSpriteY&$7)
.redColorOld	SET .redColor
.redColor	SET ((parSpriteY-92)&$f0)<<4|$22
	IFNE .redColor-.redColorOld
		CMOVE BPLCON3,PF2OF2F|BRDRBLNKF
		dc.w COLOR00
		dc.w .redColor
		ENDIF

		CMOVE BPLCON3,PF2OF2F!LOCTF!BRDRBLNKF
		dc.w COLOR00
		dc.w ((parSpriteY-60)&$f)<<8
	ENDIF
		ENDIF
	ENDIF

   ;ENDIF
	IF (parSpriteY>=230)&(parSpriteY<=234)	; needed to avoid display glitch when player sprite crosses rasterline
		dc.w (parSpriteY<<8)&$ff00+$bb
		dc.w $ff<<8+%11111110

	ELSE
		dc.w (parSpriteY<<8)&$ff00+$df
		dc.w $ff<<8+%11111110
	ENDIF

    IFEQ ((parSpriteY)&1)
	CMOVE BPLCON1,0
	IF (parSpriteY>=spriteScoreYPosition+14)&(parSpriteY<=spriteScoreYPosition+stopColFade)
    ;IFEQ (parSpriteY&3)
	COLORFADE
	;ENDIF
	ENDIF
 	ENDIF



 	; set up modulus for axelay scroller


.yOffset	SET 18
	IF parSpriteY>40+.yOffset

.sinOld	SET	.sinMem
.sin	SET ((326-parSpriteY-.yOffset)*3/(parSpriteY-.yOffset))
.sinMem	SET .sin
		IF parSpriteY>30+.yOffset
		If (.sin)!=(.sinOld)
.addEQ	SET	59
.addEQA	SET	0
.addEQB	SET	7
		ENDIF

		IFNE .addEQ
.addEQ	SET 	.addEQ-1
	IFNE	.addEQA
.addEQA	SET	.addEQA-1
	IF	.addEQ>30
.sin	SET	.sin+1
	ENDIF
		ELSE
	IF	.addEQ>30
	IF .addEQB>0
.addEQB	SET .addEQB-1
	ENDIF
	ELSE
.addEQB	SET .addEQB+1
.sin	SET .sin+1
	ENDIF

.addEQA	SET .addEQB
	ENDIF
	ENDIF
	ENDIF

.mod2val	SET	.mod2val+.sin
.modify		SET	0

	IF (parSpriteY=94)
	;CMOVE BPL2MOD,1*40
.mod2Val	SET .mod2Val+4
	ENDIF

	IF (parSpriteY=60)
.modify	SET -12*40
		ENDIF


	IF (parSpriteY=118+.yOffset)
.modify	SET	-256*40
		ENDIF
	IF (parSpriteY=178+.yOffset)
.modify	SET	-256*40
	ENDIF
	IF (parSpriteY<101+.yOffset)
	IF (parSpriteY<40+.yOffset)
	IF 	(.mod2val)>280
.mod2Val	SET .mod2Val-256
.sin	SET .sin-256
	ENDIF
	ELSE
	IF 	(.mod2val)>256
.mod2Val	SET .mod2Val-256
.sin	SET .sin-256
	ENDIF
	ENDIF
	ENDIF
.modifierOld	SET .modifier
.modifier	SET .sin*40+.modify
	IFNE .modifier-.modifierOld
	dc.w BPL2MOD
	dc.w .modifier
	ENDIF
	ENDIF

	; end of axelay scroller


	; mark start of escalate view
        IF (parSpriteY=escalateStart+1)
        CMOVE NOOP,1     ; escalate start marker
        CMOVE COP1LCH,0
        CMOVE COP1LCL,0
        CMOVE NOOP,0   ; jump to init escalate view
        ENDIF
        IF (parSpriteY=escalateStart+escalateHeight-11)
        CMOVE NOOP,2     ; mark escalate end
        ENDIF
	; mark of dialogue view
        IF (parSpriteY=dialogueStart+1)
        CMOVE NOOP,9     ; dialogue start marker
        CMOVE COP1LCH,0
        CMOVE COP1LCL,0
        CMOVE NOOP,0   ; jump to init escalate view
        ENDIF
        ; ATTN: dialogue view needs only one entry (above) and one exit point (underneath)
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
		;CMOVE COLOR00,$000
		CMOVE BPLCON3,$f000!BRDRBLNKF
		CMOVE COLOR31,$a07
		CMOVE COLOR30,$503
		CMOVE COLOR29,$102
		;CMOVE BPL2MOD,40
	CMOVE BPLCON3,PF2OF2F|BRDRBLNKF
.blueSky	SET $820
	dc.w COLOR00
	dc.w .blueSky
	dc.w COLOR17
	dc.w .blueSky
	dc.w COLOR18
	dc.w .blueSky
	dc.w COLOR19
	dc.w .blueSky
	dc.w COLOR20
	dc.w .blueSky
	dc.w COLOR21
	dc.w .blueSky
	dc.w COLOR22
	dc.w .blueSky
	dc.w COLOR23
	dc.w .blueSky
	CMOVE COLOR01,$3bb	; ugly color fix for CD32 color bug

	blk.w 8,0


