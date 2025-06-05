;//
;//  coplist2.s
;//  Reshoot2
;//
;//  Created by Richard Löwenstein on 30.01.19.
;//

    ; #MARK: - Game Finale entry and exit

gameFinStart SET $103       ; copper sub list, one line scrolling
parSpriteY	SET 	gameFinStart
copGameFin
	CMOVE BPLCON0,ECSENAF!CONCOLF!HAMF!BPU0F
	CMOVE BPLCON1,1<<10+%1001

	; !!! attn. if adding content above, since copGameFinBPLPT is  referenced relatively to copGameFin in coplist.s!

copGameFinBPLPT
    CMOVELC $e0
    CMOVE BPLCON3,BRDRBLNKF
	CMOVE DDFSTRT,$3c
	CMOVE DDFSTOP,$c0
red		SET		$90
green	SET		$90
blue	SET 	$90

	REPT $05	; five scanlines
parSpriteY	SET parSpriteY+1
parSpriteX SET $3a
   		REPT 5
			dc.w (parSpriteY<<8)&$ff00+parSpriteX-$4!1
			dc.w $ff<<8+%11111110
			CMOVE $170,(parSpriteY<<8)&$ff00+parSpriteX+3

		CMOVE COLOR01,rgbHigh
red		SET	red+$0c
green	SET	green+$0c
blue	SET	blue+$0c
rgbHigh	SET	(red&$f0)<<4!(green&$f0)!(blue&$f0)>>4

			;    dc.w $02<<8+(parSpriteX-$4)!1	; code for "waiting next line"
			;    dc.w $80fe
			;    CMOVE $170,(parSpriteY<<8)&$ff00+parSpriteX+3
			;	dc.w $02df,$80fe
parSpriteX     SET parSpriteX+$20
    	ENDR
red		SET		red-$34
green	SET		green-$34
blue	SET		blue-$34
    ENDR
	dc.w $02df,$80fe	; wait for next scanline

	CMOVE BPL1MOD,-40
	CMOVE BPLCON0,ECSENAF!CONCOLF!BPU0F
    CMOVE BPLCON3,BRDRBLNKF
	CMOVE COLOR01,$000
	CMOVE DDFSTRT,$3c
	CMOVE DDFSTOP,$60
	CMOVE	BPL1MOD,0
	CMOVE	BPL2MOD,0
		CMOVE BPLCON3,$F000!BRDRBLNKF
		CMOVE BPLCON3,$f000!BRDRBLNKF

   		CMOVE COLOR05,$48C  ;sprite text color right
   		CMOVE COLOR06,$26A
   		CMOVE COLOR07,$37B
   		CMOVE COLOR21,$48C  ;sprite text color left
   		CMOVE COLOR22,$26A
   		CMOVE COLOR23,$37B
   		

	;INCBIN incbin/ending_copperlist.pal
copGameFinQuit
	blk.l 4,0



