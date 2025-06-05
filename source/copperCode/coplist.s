;//
;//  coplist.s
;//
;//
;//  Created by Richard Löwenstein on 22.06.15.
;//
;//
;{
	
    SECTION MAINCOPLIST, DATA_C

; #MARK: Main Copper List
coplist:

copSprite01             ; display player
	CMOVELC SPR0PTH,0
	CMOVELC SPR1PTH,0
copSprite67             ; displays highscore & parallax
    CMOVELC SPR6PTH,0
    CMOVELC SPR7PTH,0

	;CMOVE BPLCON3,BRDRBLNKF
	;CMOVE COLOR00,0
COPDIWSTRT
	CMOVE DIWSTRT,0
COPDIWHIGH
	CMOVE DIWHIGH,0
  	dc.w $80            ;   -> copSpriteDma; write Spritepointers
copInitSprPtHW
    dc.w    0,$82
copInitSprPtLW
    dc.w    0,$88,0
copInitSprPtReturn
    CWAIT (displayWindowStart-1)<<8!$cd
    
copBPLCON0  CMOVE BPLCON0,ECSENAF!CONCOLF
copBPLCON1  CMOVE BPLCON1,0

copBPLCON2  CMOVE BPLCON2,0    ; Sprite / Playfield Priority
copBPLCON3	CMOVE BPLCON3,0
copBPLCON4  CMOVE BPLCON4,0
copMainInit
    CMOVELC  COP1LC
    CMOVE COPJMP1,0
    CEND

; #MARK: Init General Sprites
; ATTENTION! 8 sprite lists used for shot animation / list swapping. Addressing copSpriteDMA directly no good
copSpriteDMA
    ;CMOVELC SPR0PTH,0
    ;CMOVELC SPR1PTH,0
    CMOVELC SPR2PTH,0
    CMOVELC SPR3PTH,0
    CMOVELC SPR4PTH,0
    CMOVELC SPR5PTH,0
	dc.w $80; return to coplist
copSpriteDMAReturnHW 	= *-copSpriteDMA
    dc.w    0,$82
copSpriteDMAReturnLW	= *-copSpriteDMA
    dc.w    0,$88,0,$1fe,0
copSpriteDMAOffset = *-copSpriteDMA

	REPT 7
    ;CMOVELC SPR0PTH,0
    ;CMOVELC SPR1PTH,0
    CMOVELC SPR2PTH,0
    CMOVELC SPR3PTH,0
    CMOVELC SPR4PTH,0
    CMOVELC SPR5PTH,0
    dc.w $80,0,$82,0,$88,0,$1fe,0
	ENDR
	;blk.w 200,-1
; #MARK: - Maingame copperlist

copGameReturn:           ; Default coplist finish code copied to end of each coppper game sublist
	CWAIT (10<<8)!1         ; wait for end of frame, then restart coplist
copBPLPT
    CMOVELC BPL1PT    ;2 Register schreiben und mit 0 füllen
    CMOVELC BPL2PT
    CMOVELC BPL3PT
    CMOVELC BPL4PT
    CMOVELC BPL5PT
    CMOVELC BPL6PT
    CMOVELC BPL7PT
    CMOVELC BPL8PT
	CMOVE INTREQ,$8010    ; trigger copper interrupt
copGameDone
    CMOVELC COP1LC
    CEND

; #MARK: Re-Init Player Sprite

copGamePlyBody	; subcoplist, called from coplist in runtime, inits ply sprite
	CMOVE SPR0POS,0
	CMOVE SPR0CTL,0
	CMOVE SPR1POS,0
	CMOVE SPR1CTL,0
	CMOVE SPR0PTL,0
	CMOVE SPR0PTH,0
	CMOVE SPR1PTL,0
	CMOVE SPR1PTH,0

copGamePlyBodyRestore
	CMOVE NOOP,0	; filled in runtime with copcmds copied from original coplist
	CMOVE NOOP,0
	CMOVE NOOP,0
	CMOVE CLXDAT,0	; clear spr col poll, to detect hits only with player body not player shots 
copGamePlyBodyReturn
	CMOVE COP1LCL,0
	CMOVE COP1LCH,0
	CMOVE COPJMP1,0


copGameDefault          ; template copper list, no effects. Returns to copGameReturn. Copied to end of other nonbasic-lists. Dont change!
    ;CWAIT $ffdf
 	dc.w  COP1LCH
copGameReturnH
    dc.w    0,COP1LCL
copGameReturnL
    dc.w    0,COPJMP1,0
    CEND

    ; #MARK: - Welcome
copGameWelcome
	CMOVE BPLCON3,BRDRBLNKF
	CMOVE BPLCON0,BPU0F!ECSENAF!CONCOLF
    CMOVE COLOR00,$0
    CMOVE BPLCON1,$4
	CMOVE FMODE,%01
	;CMOVE DDFSTRT,$20
	;CMOVE DDFSTOP,$c0







; NOTE: Crashes after one game. Maybe need to kill another color entry, or find reason for crash if copperlist grows. 





	CMOVE BPL1MOD,mainPlaneWidth*(mainPlaneDepth-1)+8
copGameWelcomeColor
.switchColorsY=displayWindowStart+49
    CWAIT (.switchColorsY<<8)+$df
    CMOVE COLOR01,$fff
	CMOVE DMACON,DMAF_SETCLR!DMAF_BPLEN	; trigger dma bpl
	CWAIT (.switchColorsY+1)<<8+$df
    CMOVE COLOR01,$aae
    CWAIT (.switchColorsY+2)<<8+$df
    CMOVE COLOR01,$77c
    CWAIT (.switchColorsY+3)<<8+$df
    CMOVE COLOR01,$44a
    CWAIT (.switchColorsY+4)<<8+$df
    CMOVE COLOR01,$229
    CWAIT (.switchColorsY+5)<<8+$df
    CMOVE DMACON,DMAF_BPLEN; switch off dma bpl & sprites
    CWAIT $ffdf
copGameWelcomeEnd     blk.w 8,0


    ; #MARK: - Exit
copGameAchievements
    CMOVELC SPR0PTH
    CMOVELC SPR1PTH
    CMOVELC SPR2PTH
    CMOVELC SPR3PTH
    CMOVELC SPR4PTH
    CMOVELC SPR5PTH
    CMOVE SPR0POS,$6058
    CMOVE SPR0CTL,$f000
    CMOVE SPR1POS,$6078
    CMOVE SPR1CTL,$f000
    CMOVE SPR2POS,$6098
    CMOVE SPR2CTL,$f000
    CMOVE SPR3POS,$6058
    CMOVE SPR3CTL,$f001
    CMOVE SPR4POS,$6078
    CMOVE SPR4CTL,$f001
    CMOVE SPR5POS,$6098
    CMOVE SPR5CTL,$f001

    CMOVE BPLCON3,PF2OF2F!BANK2F!BANK1F!BANK0F!BRDRBLNKF
   	CMOVE COLOR01,white	; sprite 1
    CMOVE COLOR02,liteRed
    CMOVE COLOR05,black	; sprite 3
    CMOVE COLOR06,black
    CMOVE COLOR09,black	; sprite 5
    CMOVE COLOR10,black
.dd	SET 32
    CMOVE COLOR01+.dd,white	; sprite 0
    CMOVE COLOR02+.dd,liteRed
    CMOVE COLOR05+.dd,white	; sprite 2
    CMOVE COLOR06+.dd,liteRed
    CMOVE COLOR09+.dd,black	; sprite 4
    CMOVE COLOR10+.dd,black
copGameAchievementsEnd
    CMOVE COP1LCH,0
    CMOVE COP1LCL,0
    CMOVE COPJMP1,0   ; return to current game coplist

copGameAchievementsQuit
    CMOVE BPLCON3,PF2OF2F!BANK2F!BANK1F!BANK0F!BRDRBLNKF
.dd	SET 32
   	CMOVE COLOR01,black
    CMOVE COLOR02,black
   	CMOVE COLOR03,black
copGameAchievementsQuitEnd
    CMOVE COP1LCH,0
    CMOVE COP1LCL,0
    CMOVE COPJMP1,0   ; return to current game coplist

    ; #MARK: - Escalate entry

copGameEscalate
copEscalateBPLPT
    CMOVELC $e4
    CMOVELC $ec
    CMOVELC $f4
	CMOVE BPLCON4,$a0bb	; $80cc escalation colors
	CMOVE BPLCON0,%0110011000000001
    CMOVE BPLCON2,%0000000001000000
	CMOVE BPLCON1,%1000<<12!%001<<4
    ;CMOVE BPLCON0,BPU3F|ECSENAF
copEscalateMODD
	CMOVE BPL2MOD,-8

	CMOVE BPLCON3,$a<<12|BRDRBLNKF
copEscalateReds
	CMOVE COLOR00,0	; 8 main visual colors 
	CMOVE COLOR01,0
	CMOVE COLOR02,0
	CMOVE COLOR03,0
	CMOVE COLOR04,0
	CMOVE COLOR05,0
	CMOVE COLOR06,0
	CMOVE COLOR07,0

	CMOVE COLOR09,$200	; 8 letter colors
	CMOVE COLOR10,$400
	CMOVE COLOR11,$600
	CMOVE COLOR12,$800
	CMOVE COLOR13,$a10
	CMOVE COLOR14,$c10
	CMOVE COLOR15,$c30

	CMOVE BPLCON3,$B<<12|BRDRBLNKF
	CMOVE COLOR17,$300	 ; player and shot sprites
	CMOVE COLOR18,$600
	CMOVE COLOR19,$500
	CMOVE COLOR20,$300
	CMOVE COLOR21,$300
	CMOVE COLOR22,$600
	CMOVE COLOR23,$900
	CMOVE COLOR24,$500
	CMOVE COLOR27,$4f0
	CMOVE COLOR28,$300
	CMOVE COLOR29,$400	; background sprites
	CMOVE COLOR30,$500
	CMOVE COLOR31,$600

copEscalateFlex
	REPT 10
	CMOVE NOOP,0
	ENDR
copEscalSplits	SET 2
copGameEscalateSplits
	REPT (escalateHeight-1)/2
	dc.w ((escalateStart+copEscalSplits)<<8)&$fffe+$c3
	dc.w $ff<<8+%11111110
	CMOVE BPLCON1,0
copEscalSplits	SET copEscalSplits+2	
	ENDR

        ; #MARK: Escalate exit
copGameEscalateExit
	dc.w ((escalateStart+escalateHeight)<<8)&$fffe+$b7
	
	dc.w $ff<<8+%11111110
copGameEscExitBPL2MOD
	CMOVE BPL2MOD,0
copGameEscExitBPLPT
    CMOVELC BPL2PTH
    CMOVELC BPL4PTH
    CMOVELC BPL6PTH
    CMOVELC BPL8PTH
    CMOVELC BPL7PTH	; main layer needs modifying too, due so switchoff during escal 
copGameEscExitBPLCON2
    CMOVE BPLCON2,%100100
    CMOVE BPLCON1,0
copGameEscExitCOLOR00
	CMOVE BPLCON3,BRDRBLNKF
	CMOVE COLOR00,0
copGameEscExitBPLCON3
    CMOVE BPLCON3,BRDRBLNKF
    CMOVE BPLCON4,$00fe
copGameEscExitBPLCON0
    CMOVE BPLCON0,0
    CMOVE BPL2MOD,0
copGameEscQuit
	CMOVE COP1LCH,0
	CMOVE COP1LCL,0
	CMOVE COPJMP1,0   ; return to current game coplist
	CMOVE NOOP,0

    ; #MARK: - Dialogue entry

copGameDialogue
	dc.w ((dialogueStart+2)<<8)&$fffe+$c7
	dc.w $ff<<8+%11111110
;	CMOVE BPLCON0,ECSENAF
	CMOVE BPL1MOD,$58
	CMOVE BPL2MOD,-2040
copDialogueBPLPT
    CMOVELC BPL1PTH
    CMOVELC BPL3PTH
    CMOVELC BPL5PTH
    CMOVELC BPL7PTH
;	dc.w ((dialogueStart+6)<<8)&$fffe+$df
;	dc.w $ff<<8+%11111110
    ;CMOVE BPLCON0,ECSENAF|BPU2F
	;dc.w ((dialogueStart+12)<<8)&$fffe+$df
	;dc.w $ff<<8+%11111110
    CMOVE BPLCON0,ECSENAF|BPU3F|DPFF|CONCOLF
    CMOVE BPLCON2,%0000000000000000
	CMOVE BPLCON1,(%101<<12!%0101<<4)!(%1000<<8!%0101)
	CMOVE BPLCON4,$a0bb
	CMOVE BPL2MOD,0

copDialogueFlex
	REPT 11
	CMOVE NOOP,0
	ENDR
	dc.w $00df,$80fe
	CMOVE BPL2MOD,0
	 ;take care of color splits for font 
	CMOVE BPLCON3,BANK2F|BANK0F|BRDRBLNKF|PF2OF1F|PF2OF0F
.rasCount	SET	0
	REPT 2
.colSplit	SET	0
	REPT 6
.colHero	SET ((.colSplit+5)<<8)|((.colSplit+5)<<4)|((.colSplit+2)<<1)
.colAntagonist	SET ((.colSplit+2)<<9)|((.colSplit+2)<<5)|(.colSplit>>1)&$0f
	dc.w ((dialogueStart+10+.rasCount)<<8)&$fffe+$af
	dc.w $ff<<8+%11111110
	CMOVE COLOR14,.colHero
	CMOVE COLOR15,.colAntagonist
.rasCount	SET	.rasCount+1
.colSplit	SET	.colSplit+1
	ENDR
.rasCount	SET	.rasCount+2
	ENDR

	dc.w ((dialogueStart+10+.rasCount)<<8)&$fffe+$af
	dc.w $ff<<8+%11111110	; this wait handles entry to playerships coppersublist
        ; #MARK: Dialogue exit
copGameDialogueExit
	dc.w ((dialogueStart+dialogueHeight-2)<<8)&$fffe+$a7
	dc.w $ff<<8+%11111110
	CMOVE NOOP,0
	CMOVE NOOP,0
	CMOVE NOOP,0
copGameDialgExitBPLPT
    CMOVELC BPL1PTH
    CMOVELC BPL3PTH
    CMOVELC BPL5PTH
    CMOVELC BPL7PTH
copGameDialgExitBPLCON2
    CMOVE BPLCON2,%100100
    CMOVE BPLCON4,$00fe
	CMOVE BPL1MOD,40*3
	;CMOVE BPL2MOD,40*3
copGameDialgExitBPLCON0
	CMOVE BPLCON0,0
	CMOVE BPLCON1,0
copGameDialgQuit
    CMOVE COP1LCH,0
    CMOVE COP1LCL,0
    CMOVE COPJMP1,0   ; return to current game coplist
    CMOVE NOOP,0

    INCLUDE coplist.credits.s
    ;}
