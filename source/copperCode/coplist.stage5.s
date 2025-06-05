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

.mod2val	SET	0
.add		SET	0
.addEQ		SET	1
.addEQA		SET	6
.addEQB		SET	1


red		SET 	$0<<4		; start values
green	SET 	0<<4
blue	SET 	$20<<4
redA	SET	red
greenA	SET	green
blueA	SET	blue
redFac		SET 	(red-$00<<4)	; target values
greenFac	SET 	(green-$00<<4)
blueFac		SET		(blue-$40<<4)
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
			PRINTV rgbHigh0
;		IFNE statusHigh
		CMOVE BPLCON3,BRDRBLNKF
;			IFNE (rgbHigh0old-rgbHigh0)
			dc.w COLOR00
			dc.w 0
;			ENDIF
;		ENDIF

;		IFNE statusLow
		CMOVE BPLCON3,LOCTF!BRDRBLNKF
;			IFNE (rgbLow0old-rgbLow0)
			dc.w COLOR00
			dc.w	0
;			ENDIF
;		ENDIF
	ENDIF
	ENDM

COPCOLSPLIT	MACRO
	IF (parSpriteY=\1)
	CMOVE BPLCON3,$e000|BRDRBLNKF;|SPRES1F
	dc.w COLOR02
	dc.w \2
	dc.w COLOR06	; shadow left
	dc.w \3
	dc.w COLOR10	; shadow right
	dc.w \3
	dc.w COLOR26	; shadow center
	dc.w \3

	CMOVE BPLCON3,$f000|BRDRBLNKF;|SPRES1F
	dc.w COLOR02+16+16
	dc.w \2
	dc.w COLOR02+16+24
	dc.w \2
	ENDIF
	ENDM

; write to sprite
			CMOVE SPR7PTL,0
			CMOVE SPR7PTH,0	; pointer to left score panel
    CMOVE FMODE,%1111  ;64 pixel sprites
	CWAIT (displayWindowStart<<8)!$df
	CMOVE BPL1MOD,mainPlaneWidth*(mainPlaneDepth-1)
	CMOVE COLOR14,$111	; left score panel shadow
	CMOVE COLOR30,$111	; right score panel shadow

	CMOVE BPLCON1,0		; init scroll register
		dc.w BPL2MOD
		;dc.w 0
		dc.w -3*40


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
		CMOVE SPR0POS,$0000	; reposition scroll sprite
		CMOVE SPR0CTL,$0000
		CMOVE SPR1POS,$0000	; reposition scroll sprite
		CMOVE SPR1CTL,$0000
		CMOVE SPR6POS,$0000	; reposition scroll sprite
		CMOVE SPR6CTL,$0000
		CMOVE SPR7POS,$0000	; reposition scroll sprite
		CMOVE SPR7CTL,$0000


		CMOVE BPLCON2,%111111	; sprites 6/7 behind of playfield
		CMOVE COLOR13,$457	; reset player vessel spotlight right of the cockpit  + sprite parallax color. Basic color: $457

		CMOVE COLOR15,$eef	; reset ship color
			CMOVE BPLCON3,$f000|BRDRBLNKF;|SPRES1F

		CMOVE COLOR29,$55f;$45e
		CMOVE COLOR30,$55f;$44f
		CMOVE COLOR31,$55f;$34e
		CMOVE BPLCON3,BRDRBLNKF

		;CMOVE COLOR30,0
		ENDIF

		dc.w (parSpriteY<<8)&$ff00+$3f
		dc.w $ff<<8+%11111110

		IF ((parSpriteY>(spriteScoreYPosition+150)))
		dc.w (parSpriteY<<8)&$fffe+$df
		dc.w $ff<<8+%11111110
		CMOVE BPLCON3,BRDRBLNKF
		dc.w ((parSpriteY+1)<<8)&$fffe+$6f
		dc.w $ff<<8+%11111110
		CMOVE BPLCON3,BRDRBLNKF;|SPRES1F
		dc.w ((parSpriteY+1)<<8)&$fffe+$9f
		dc.w $ff<<8+%11111110

		ELSE
		IF (parSpriteY>spriteScoreYPosition+4)
		CMOVE BPLCON3,BRDRBLNKF;|SPRES1F
    CMOVE COLOR00,0
;		    CMOVE BPLCON3,BRDRBLNKF
		ENDIF
		ENDIF

		    IFEQ (parSpriteY&1)
	CMOVE BPLCON1,0

	ENDIF
		
		IF (parSpriteY=spriteScoreYPosition+20)
.x	SET $60
		CMOVE SPR0POS,$4400+.x	; reposition scroll sprite
		CMOVE SPR1POS,$4400+.x+$20	; reposition scroll sprite
		CMOVE SPR2POS,$4400+.x+$40	; reposition scroll sprite
		CMOVE SPR3POS,$4400+.x+$0	; reposition scroll sprite
		CMOVE SPR4POS,$4400+.x+$20	; reposition scroll sprite
		CMOVE SPR5POS,$4400+.x+$40	; reposition scroll sprite
		ENDIF
		IF (parSpriteY=spriteScoreYPosition+21)
		CMOVE SPR0CTL,$2102
		CMOVE SPR1CTL,$2102
		CMOVE SPR2CTL,$2102
		CMOVE SPR3CTL,$1010
		CMOVE SPR4CTL,$1010
		CMOVE SPR5CTL,$1010
		ENDIF
		IFNE 1
		IF (parSpriteY=spriteScoreYPosition+151)
		CMOVE NOOP,6
		CMOVELC SPR6PTH,0	; this is needed as  buffer, values are swapped with upper sprite pointers to animate stuff
		CMOVELC SPR7PTH,0
		;CMOVELC SPR6PTH,0
		;CMOVELC SPR7PTH,0
		CMOVE BPLCON4,$fe
			INCBIN	incbin/palettes/outroship.pal	; insert 16 color palette for main player ship
	CMOVE BPLCON3,$e000|BRDRBLNKF;|SPRES1F
	CMOVE COLOR01,-1	; main mid text sprite;
	CMOVE COLOR02,$f00	; main mid text sprite;
	CMOVE COLOR06,$0	; shadow left text sprite
	CMOVE COLOR10,$0	; shadow right text sprite
	CMOVE BPLCON3,$f220|BRDRBLNKF;|SPRES1F

	;CMOVE $194,-1
		CMOVE SPR6POS,$1052	; reposition scroll sprite
		CMOVE SPR6CTL,$3082
		CMOVE SPR7POS,$1052	; reposition scroll sprite
		CMOVE SPR7CTL,$3082

		ENDIF
		ENDIF
		IF (parSpriteY=spriteScoreYPosition+229)
		IFNE 1
		CMOVE SPR0POS,$1ff	; reposition scroll sprite
		CMOVE SPR1POS,$1ff	; reposition scroll sprite
		CMOVE SPR2POS,$1ff	; reposition scroll sprite
		CMOVE SPR3POS,$1ff	; reposition scroll sprite
		CMOVE SPR4POS,$1ff	; reposition scroll sprite
		CMOVE SPR5POS,$1ff	; reposition scroll sprite
		ENDIF
		ENDIF
		IF (parSpriteY=spriteScoreYPosition+211)
		CMOVE SPR6POS,0	; reposition ship sprite
		CMOVE SPR6CTL,0
		CMOVE SPR7POS,0	; reposition ship sprite
		CMOVE SPR7CTL,0
;		CMOVE BPLCON0,0
		ENDIF
		IF (parSpriteY=spriteScoreYPosition+246)
	CMOVE BPLCON0,0
		ENDIF

	COPCOLSPLIT $40,$40d,$40d	; fade-in colors scroller north
	COPCOLSPLIT $45,$50d,$30c
	COPCOLSPLIT $46,$50c,$30c


	IF (parSpriteY=$44)
	dc.w (parSpriteY<<8)&$fffe+$6f
	dc.w $ff<<8+%11111110
	CMOVE BPLCON3,$f000|BRDRBLNKF;|SPRES1F
	dc.w COLOR02+16+16
	dc.w $c
	dc.w COLOR02+16+16
	dc.w $d
	dc.w COLOR02+16+16
	dc.w $e
	CMOVE BPLCON3,$e000|BRDRBLNKF;|SPRES1F
	dc.w COLOR10	; shadow right
	dc.w $a
	CMOVE BPLCON3,$f000|BRDRBLNKF;|SPRES1F
	dc.w COLOR02+16+24
	dc.w $c
	dc.w COLOR02+16+24
	dc.w $8
	dc.w COLOR02+16+24
	dc.w 6
	ENDIF

	IF (parSpriteY=$45)
	;dc.w (parSpriteY<<8)&$fffe+$67
	;dc.w $ff<<8+%11111110
	CMOVE BPLCON3,$f000|BRDRBLNKF;|SPRES1F
	dc.w COLOR02+16+16
	dc.w $c
	dc.w COLOR02+16+16
	dc.w $d
	dc.w COLOR02+16+16
	dc.w $e
;	dc.w (parSpriteY<<8)&$fffe+$89
	;dc.w $ff<<8+%11111110
	CMOVE BPLCON3,$e000|BRDRBLNKF;|SPRES1F
	dc.w COLOR10	; shadow right
	dc.w $b
	CMOVE BPLCON3,$f000|BRDRBLNKF;|SPRES1F
	dc.w COLOR02+16+24
	dc.w $c
	dc.w COLOR02+16+24
	dc.w $a
	dc.w COLOR02+16+24
	dc.w $6
	ENDIF
	
	IF (parSpriteY=$46)
	dc.w (parSpriteY<<8)&$fffe+$89
	dc.w $ff<<8+%11111110
	CMOVE BPLCON3,$e000|BRDRBLNKF;|SPRES1F
	dc.w COLOR10	; shadow right
	dc.w $c
	CMOVE BPLCON3,$f000|BRDRBLNKF;|SPRES1F
	dc.w COLOR02+16+24
	dc.w $d
	dc.w COLOR02+16+24
	dc.w $b
	dc.w COLOR02+16+24
	dc.w $9
	ENDIF

	IFNE 1
	COPCOLSPLIT $47,$50b,$30b
	COPCOLSPLIT $48,$60a,$20a
	COPCOLSPLIT $49,$708,$209
	COPCOLSPLIT $4a,$906,$207
	COPCOLSPLIT $4b,$b04,$205
	COPCOLSPLIT $4c,$c03,$203
	COPCOLSPLIT $4d,$d02,$102
	COPCOLSPLIT $4e,$e01,$101
	COPCOLSPLIT $4f,$f00,0

	COPCOLSPLIT $112,$30b,$30b		; fade-in colors scroller south
	COPCOLSPLIT $111,$50a,$30a
	COPCOLSPLIT $110,$708,$309
	COPCOLSPLIT $10f,$906,$207
	COPCOLSPLIT $10e,$b04,$205
	COPCOLSPLIT $10d,$c03,$203
	COPCOLSPLIT $10c,$d02,$102
	COPCOLSPLIT $10b,$e01,$101
	COPCOLSPLIT $10a,$f00,0
	ENDIF

	;CMOVE BPLCON3,$0000|BRDRBLNKF
	;CMOVE COLOR01,-1

 	; set up modulus for axelay scroller


	IFNE 1

.yOffset	SET 18
	IF parSpriteY>25+.yOffset

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

	IF (parSpriteY=72+.yOffset)
.modify	SET -8*40
		ENDIF

	IF (parSpriteY=60+.yOffset)
;.modify	SET -256*40
		ENDIF


	IF (parSpriteY=106+.yOffset)
.modify	SET	-256*40
		ENDIF

	IF (parSpriteY=156+.yOffset)
.modify	SET	-256*40
	ENDIF

	IF (parSpriteY=266+.yOffset)
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
	ENDIF

	; mark achievements view
        IF (parSpriteY=$38)
        CMOVE NOOP,11     ; achievements start marker
        CMOVE COP1LCH,0
        CMOVE COP1LCL,0
        CMOVE NOOP,0   ; jump to init achievements view
        ENDIF
        IF (parSpriteY=$148)
        CMOVE NOOP,12     ; achievements clean up marker
        CMOVE COP1LCH,0
        CMOVE COP1LCL,0
        CMOVE NOOP,0   ; jump to init achievements view
        ENDIF
parSpriteY     SET parSpriteY+$1
	ENDR

				;INCBIN	incbin/palettes/outroship.pal	; insert 16 color palette for main player ship

	CMOVE BPLCON3,BRDRBLNKF
	;CMOVE COLOR00,$000
	CMOVE COLOR01,$002	; ugly color fix for CD32 color bug
		dc.w (parSpriteY<<8)&$ff00+$df
		dc.w $ff<<8+%11111110

	;CWAIT $2001

	blk.w 8,0


