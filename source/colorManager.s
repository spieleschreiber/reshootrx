
;	#MARK: - COLOR MANAGER

;	#MARK: - color player
colorPlayer

; #MARK: Set ship, shot, bullet colors (a0 = player pal, a1 = shot pal). Also parallax sprites
	;rts
	;set sprite ship colors -> colRegs 224ff
								move.l					#$e*16,d4																																																									;224 > 240
								moveq					#15,d7
.colShipSprRead
								lea						1(a0),a0
								move.w					d4,d3
								move.b					(a0)+,d0
								move.b					(a0)+,d1
								move.b					(a0)+,d2
								WRITECOLOR
								addq					#1,d4
								dbra					d7,.colShipSprRead

;	#MARK: - enemy bullet colors
								cmpi.w					#3,gameStatusLevel(pc)
								seq						d0
								andi					#enemShotColors_stage3-enemShotColors,d0
								lea						enemShotColors(pc,d0),a1																																																					;enem shot colors
								moveq					#$c,d4
								lsl.b					#4,d4																																																										; $c0 -> color regs 192
								moveq					#0,d3
								moveq					#2,d7
.colSprRead
								clr.l					d0
								lea						1(a1),a1
								move.b					(a1)+,d0
								move.b					(a1)+,d1
								move.b					(a1)+,d2

								move					d4,d3
								add						#32+5,d3																																																									; 224+5 = bank 7, +$a
								WRITECOLOR																																																															; set sprite 3	; bullet colors basic version
								move					d4,d3
								add						#32+9,d3																																																									; 224+9 = bank 7, +$12
								WRITECOLOR																																																															; set sprite 5
								move					d4,d3
								add						#48+5,d3																																																									; 240+5 = bank 7, +$2a
								WRITECOLOR																																																															; set sprite 2
								move					d4,d3
								add						#48+9,d3																																																									; 240+9 = bank 7, +$32
								WRITECOLOR																																																															; set sprite 4
								addq					#1,d4
								dbra					d7,.colSprRead

	; set xtra weapon colors
								lea						CUSTOM,a6
								move					#%1110000000000000,BPLCON3(a6)
								move					#$b80,COLOR17(a6)																																																							; from dark to bright
								move					#$ec0,COLOR19(a6)
								move					#$ff0,COLOR18(a6)
								rts

colorManager
;MARK: Game MainPlane Colors
	;	#MARK: - load main palette
 	;move.l mainPlanePalette(pc),a0
								move.l					#colorDefsFile,d1																																																							; Load main color data
								move.l					diskBuffer+4(pc),d2
								moveq					#16*4+8*4,d3																																																								; 16+8 colors
								bsr						createFilePathOnStage
								bsr						loadFile
								tst.l					d0
								beq						errorDisk

								IFEQ					(RELEASECANDIDATE||DEMOBUILD)
								IF						1=1																																																											; set all colors to bright blue. Just for checking if all colors are set correctly
								move					#256,d7
								clr.b					d0
								clr.b					d1
								st.b					d2
								bra						.qqqqq
.loopq1
								move					d7,d3
								WRITECOLOR
.qqqqq
								dbra					d7,.loopq1
								ENDIF
								ENDIF

								IF						0=1																																																											; set some colors to blue
								move					#2,d7
.loopq2
								move					#0,d0
								move					#0,d1
								move					#-1,d2
								move					d7,d3
								add						#241,d3
								WRITECOLOR
.qq
								dbra					d7,.loopq2
								ENDIF


	; escalation colors. font colors set within escl coplist
								move					#7,d7
								move.w					gameStatusLevel(pc),d0
								lea						.reds(pc,d0*8),a0
								lea						copEscalateReds+2,a6
.loop
								move.b					(a0)+,(a6)																																																									; set 7 red shaded main visual  layer colors
								lea						4(a6),a6
								dbra					d7,.loop

								lea						gameStatusLevel(pc),a0
								move.w					(a0),d0
								move.w					(.jmpTable,pc,d0.w*2),d0

								move.l					diskBuffer+4(pc),a0																																																							; color rgbs in 24 bit format
								lea						colorAlphaTable,a1
								clr.l					d3
								clr.l					d4
								clr.l					d5
.jmp								jmp						.jmp(pc,d0.w)
.jmpTable		; color jumper
								dc.w					.stage0-.jmpTable+2
								dc.w					.stage1-.jmpTable+2
								dc.w					.stage2-.jmpTable+2
								dc.w					.stage3-.jmpTable+2
								dc.w					.stage4-.jmpTable+2
								dc.w					.stage5-.jmpTable+2
.reds
								dc.b					$2,$6,$3,$6,$4,$3,$4,$c																																																						; bone valley
								dc.b					$2,$6,$4,$6,$4,$2,$6,$6																																																						; ??
								dc.b					$2,$6,$2,$8,$5,$4,$3,$3
								dc.b					$0,$6,$4,$6,$4,$2,$6,$6																																																						; ??
								dc.b					$0,$6,$4,$6,$4,$2,$6,$6																																																						; ??
								dc.b					$0,$6,$4,$6,$4,$2,$6,$6																																																						; ??


;	#MARK: colors stage 0

.stage0
								clr.w					d3
								clr.w					d4
								clr.w					d5

								move					#(1<<fxPlaneDepth)-5,d7
.colRead0
								move					#11,d0
								sub						d7,d0

								move.l					a1,a2
								move.l					a0,a3
								move					#(1<<mainPlaneDepth)-1,d6																																																					; loop through all 16 colors
.colWriteFade0               ; inner loop, write 16 colors with progressing hue
	;clr.w d3
								move					(a2)+,a4																																																									; which color register?
								lea						1(a3),a3
								move.b					(a3)+,d0
								move.b					(a3)+,d1
								move.b					(a3)+,d2
								IF						0=1																																																											; 1=1 to test greyscale alpha
								move					#1,d0
								move					#1,d1
								move					#1,d2
								ENDIF

								clr.l					d3
								clr.l					d4
								clr.l					d5
								move					#11,d5
								sub						d7,d5
	;move #0,d0
								move.b					.vfxColors0+1(pc,d5*4),d3
								move.b					.vfxColors0+2(pc,d5*4),d4
								move.b					.vfxColors0+3(pc,d5*4),d5
								cmpi					#(1<<mainPlaneDepth)-1,d6																																																					; check if bitplan is 0
								bne						.doColor0
.base							SET						4
.range							SET						12*32

								move					d7,a5

								move					d3,d0
								move					d4,d1
								move					d5,d2
    ;lsr #1,d0
    ;lsr #1,d1
    ;lsr #1,d2
								move					a5,d7
								bra.b					.writeColor0
.s0AlphaScaler
								dc.b					$00,$04,$08,$10
								dc.b					$18,$1c,$20,$24
								dc.b					$28,$30,$38,$44
								dc.b					$60,$00

    ; do fx colors for nontransparent playfield pixels
.doColor0

								add						d3,d5
								add						d4,d5
								lsl						#4,d5
								move					a5,d4
	;lsr #1,d4
								move					#12,d3
								sub						d4,d3
								seq						d4
								move					d3,d5
								move.b					(.s0AlphaScaler,pc,d5.w),d5

	;lsl #4,d5

	;andi #1,d4
								or						d4,d3																																																										; avoid div by zero exception
	;divu d3,d5
	;sub #100,d5
	;bpl .ss4
	;sf.b d5
.ss0
	;sf.b d5
	;move.b #15,d5

								add.b					d5,d0
								bcc.b					.keepRR0
								st.b					d0
.keepRR0
								add.b					d5,d1
								bcc.b					.keepGG0
								st.b					d1
.keepGG0
								add.b					d5,d2
								bcc.b					.keepBB0
								st.b					d2
.keepBB0

.writeColor0
	; write colors
								exg.l					a4,d3
    ;moveq #-1,d0
    ;moveq #-1,d1
    ;moveq #-1,d2
  ;clr.w d0
  ;clr.w d1	; set color to blue
								WRITECOLOR																																																															; 8 shades of colors at 0000
								exg.l					a4,d3
								dbra					d6,.colWriteFade0

								lea						32(a1),a1
								dbra					d7,.colRead0
								rts
.vfxColors0
								INCBIN					stage0/vfx.pal																																																						; used to be stage4, now its stage0

								move					#(1<<fxPlaneDepth)-5,d7

.colRead3
								move.l					a1,a2
								move.l					a0,a3
								move					#(1<<mainPlaneDepth)-1,d6																																																					; loop through all 16 colors
.colWriteFade3               ; inner loop, write 16 colors with progressing hue
	;clr.w d3
								move					(a2)+,a4																																																									; which color register?
								lea						1(a3),a3
								move.b					(a3)+,d0
								move.b					(a3)+,d1
								move.b					(a3)+,d2
    ;bra .doColor3
								cmpi					#(1<<mainPlaneDepth)-1,d6																																																					; check if bitplan is 0
								bne						.doColor3

    ; set vfx colors for transparent background

    ;cmpi #(1<<fxPlaneDepth)-5,d7
    ;bne .s1


    ;lea 0,a6
    ;movem.w (a6),d3-d5 ; shading-values to begin with (rgb)
.s1
    ; do fx colors for transparent playfield pixels
.base							SET						10
.range							SET						12*32
								move					d7,a5
								move					#.base+$b,d7																																																								;254
								sub						a5,d7
								mulu					#.range,d7																																																									; range, 74*18 means maximum from 0 to $f0 (approx.)
								lsr.w					#5,d7
								add.b					d7,d0
								bcc.b					.keepR3
								st.b					d0
.keepR3
								move					#.base,d7
								sub						a5,d7
								mulu					#.range,d7
								lsr.w					#5,d7
								add.b					d7,d1
								bcc.b					.keepG3
								st.b					d1
.keepG3
								move					#.base,d7
								sub						a5,d7
								mulu					#.range,d7
								lsr.w					#5,d7
								add.b					d7,d2
								bcc.b					.keepB3
								st.b					d2
.keepB3
								move					a5,d7
								bra.b					.writeColor

    ; do fx colors for nontransparent playfield pixels
.doColor3
								add.b					d3,d0
								bcc.b					.keepRR3
								st.b					d0
.keepRR3
								add.b					d4,d1
								bcc.b					.keepGG3
								st.b					d1
.keepGG3
								add.b					d5,d2
								bcc.b					.keepBB3
								st.b					d2
.keepBB3
.writeColor
	; write colors
								exg.l					a4,d3
    ;moveq #-1,d0
    ;moveq #-1,d1
    ;moveq #-1,d2
  ;clr.w d0
  ;clr.w d1	; set color to blue
								WRITECOLOR																																																															; 8 shades of colors at 0000
								exg.l					a4,d3
								dbra					d6,.colWriteFade3

								lea						32(a1),a1
								add.b					#$12,d3																																																										; add red to main pal
								bcc						.keepRRR3
								st.b					d3
.keepRRR3
								add.b					#$12,d4																																																										; add green to main palette
								bcc.b					.keepGGG3
								st.b					d4
.keepGGG3
								add.b					#$12,d5																																																										;add blue to main pal
								bcc.b					.keepBBB3
								st.b					d5
.keepBBB3
								dbra					d7,.colRead3
								rts
;.vfxColors0
;	INCBIN	stage0/vfx.pal	; used to be stage4, now its stage0


;	#MARK: colors stage 1


.stage1
.storeColors

; #MARK: install main palette

								WAITVBLANK
								lea						5(a0),a0
								lea						64(a0),a2
								moveq					#1,d3
								move.w					#14,d7
.wrtFrntCol
								move.b					(a0)+,d0
								move.b					(a0)+,d1
								move.b					(a0)+,d2
	;moveq #$cf,d0
	;moveq #3,d1
	;moveq #9,d2
								WRITECOLOR
								addq					#1,a0
								addq					#1,d3
								dbra					d7,.wrtFrntCol

								moveq					#17,d3
								move.w					#7,d7
.wrtBckCol
								move.b					(a2)+,d0
								move.b					(a2)+,d1
								move.b					(a2)+,d2
	;moveq #-1,d0
	;moveq #-1,d1
	;moveq #-1,d2
								WRITECOLOR
								addq					#1,a2
								addq					#1,d3
								dbra					d7,.wrtBckCol
								rts



;	#MARK: colors stage 2
.stage2

;    lea lv0boneShades,a2
 ;   movem.w (a2),d3-d5 ; shading-values to begin with (rgb)
								clr.w					d3
								clr.w					d4
								clr.w					d5


								move					#(1<<fxPlaneDepth)-5,d7

.2colRead3B
								move					#11,d0
								sub						d7,d0
	;move #0,d0
								move.b					.vfxColors2+1(pc,d0*4),d3
								move.b					.vfxColors2+2(pc,d0*4),d4
								move.b					.vfxColors2+3(pc,d0*4),d5
	;move.w #-1,d3
	;move.w #-1,d4
	;move.w #-1,d5
	;clr.w d4
	;clr.w d5
								move.l					a1,a2
								move.l					a0,a3
								move					#(1<<mainPlaneDepth)-1,d6																																																					; loop through all 16 colors

.2colWriteFade3B               ; inner loop, write 16 colors with progressing hue
	;clr.w d3
								move					(a2)+,a4																																																									; which color register?
								lea						1(a3),a3

								move.b					(a3)+,d0
								move.b					(a3)+,d1
								move.b					(a3)+,d2

								clr.l					d3
								clr.l					d4
								clr.l					d5
								move					#11,d5
								sub						d7,d5
								move.b					.vfxColors2+1(pc,d5*4),d3
								move.b					.vfxColors2+2(pc,d5*4),d4
								move.b					.vfxColors2+3(pc,d5*4),d5

    ;bra .2doColor3
								cmpi					#(1<<mainPlaneDepth)-1,d6																																																					; check if bitplan is 0
								bne						.2doColor3B
;    bra.b .2writeColorB

    ; do fx colors for transparent playfield pixels
.base							SET						4
.range							SET						12*32
								move					d7,a5

								move					d3,d0
								move					d4,d1
								move					d5,d2
   ; lsr #1,d0
    ;lsr #1,d1
    ;lsr #1,d2
								move					a5,d7
								bra.b					.2writeColorB

    ; do fx colors for nontransparent playfield pixels
.2doColor3B
.muls							SET						16
.lsr							SET						5
								cmpi					#(1<<fxPlaneDepth)-5,d7																																																						; darkest vfx layer color? Skip color modification
								beq						.2writeColorB

								move					#((1<<fxPlaneDepth)-5)*2,d5
								sub						d7,d5
								sub						d7,d5
								muls					#10,d5
	;add #50,d5
								bpl						.2ss1
								move					#35,d5																																																										; set value for lowest storm density areas
.2ss1
								add.b					d5,d0
								bcc.b					.2keepRR3B
								st.b					d0
.2keepRR3B
								add.b					d5,d1
								bcc.b					.2keepGG3B
								st.b					d1
.2keepGG3B
								lsr.b					#1,d5
								add.b					d5,d2
								bcc.b					.2keepBB3B
								st.b					d2
.2keepBB3B
.2writeColorB
	; write colors
								exg.l					a4,d3

								WRITECOLOR																																																															; 8 shades of colors at 0000
								exg.l					a4,d3
								dbra					d6,.2colWriteFade3B
								lea						32(a1),a1
								dbra					d7,.2colRead3B
								rts
.vfxColors2
								INCBIN					stage2/vfx.pal

;	#MARK: colors stage 3

.stage3
;    lea lv0boneShades,a2
 ;   movem.w (a2),d3-d5 ; shading-values to begin with (rgb)
								clr.w					d3
								clr.w					d4
								clr.w					d5


								move					#(1<<fxPlaneDepth)-5,d7

.colRead3B
								move					#11,d0
								sub						d7,d0
	;move #0,d0
								move.b					.vfxColors3+1(pc,d0*4),d3
								move.b					.vfxColors3+2(pc,d0*4),d4
								move.b					.vfxColors3+3(pc,d0*4),d5
	;move.w #-1,d3
	;move.w #-1,d4
	;move.w #-1,d5
	;clr.w d4
	;clr.w d5
								move.l					a1,a2
								move.l					a0,a3
								move					#(1<<mainPlaneDepth)-1,d6																																																					; loop through all 16 colors

.colWriteFade3B               ; inner loop, write 16 colors with progressing hue
	;clr.w d3
								move					(a2)+,a4																																																									; which color register?
								lea						1(a3),a3



								move.b					(a3)+,d0
								move.b					(a3)+,d1
								move.b					(a3)+,d2
								IF						1=0
								move.b					d0,d3
								move.b					d1,d4
								move.b					d2,d5
								lsr						#4,d3
								lsr						#4,d4
								lsr						#4,d5
								muls					#299,d3
								muls					#587,d4
								muls					#114,d5
								add.w					d3,d4
								add.w					d5,d4
								divu					#1000,d4																																																									; brightness of main color
								move.w					d4,a5
								ENDIF
								clr.l					d3
								clr.l					d4
								clr.l					d5
								move					#11,d5
								sub						d7,d5
	;move #0,d0
								move.b					.vfxColors3+1(pc,d5*4),d3
								move.b					.vfxColors3+2(pc,d5*4),d4
								move.b					.vfxColors3+3(pc,d5*4),d5

    ;bra .doColor3
								cmpi					#(1<<mainPlaneDepth)-1,d6																																																					; check if bitplan is 0
								bne						.doColor3B
    ; do fx colors for transparent playfield pixels
.base							SET						4
.range							SET						12*32
								move					d7,a5

								move					d3,d0
								move					d4,d1
								move					d5,d2
    ;lsr #1,d0
    ;lsr #1,d1
    ;lsr #1,d2
								move					a5,d7
								bra.b					.writeColorB

    ; do fx colors for nontransparent playfield pixels
.doColor3B
.muls							SET						16
.lsr							SET						5
								cmpi					#(1<<fxPlaneDepth)-5,d7																																																						; darkest vfx layer color? Skip color modification
								beq						.writeColorB

								add						d3,d5
								add						d4,d5
								lsl						#4,d5
								move					a5,d4
								lsr						#1,d4
								move					#22,d3
								sub						d4,d3
								seq						d4
	;andi #1,d4
								or						d4,d3																																																										; avoid div by zero exception
								divu					d3,d5
								sub						#60,d5
								bpl						.ss1
								sf.b					d5
.ss1
								add.b					d5,d0
								bcc.b					.keepRR3B
								st.b					d0
.keepRR3B
								add.b					d5,d1
								bcc.b					.keepGG3B
								st.b					d1
.keepGG3B
								lsr.b					#1,d5
								add.b					d5,d2
								bcc.b					.keepBB3B
								st.b					d2
.keepBB3B
	;lsr #1,d2

.writeColorB
	; write colors
								exg.l					a4,d3
								WRITECOLOR																																																															; 8 shades of colors at 0000
								exg.l					a4,d3
								dbra					d6,.colWriteFade3B
								lea						32(a1),a1
								dbra					d7,.colRead3B
								rts
.vfxColors3
								INCBIN					stage3/vfxColors3.pal


;	#MARK: colors stage 4

.stage4
								clr.w					d3
								clr.w					d4
								clr.w					d5

								move					#(1<<fxPlaneDepth)-5,d7
.colRead4
								move					#11,d0
								sub						d7,d0

								move.l					a1,a2
								move.l					a0,a3
								move					#(1<<mainPlaneDepth)-1,d6																																																					; loop through all 16 colors
.colWriteFade4               ; inner loop, write 16 colors with progressing hue
	;clr.w d3
								move					(a2)+,a4																																																									; which color register?
								lea						1(a3),a3
								move.b					(a3)+,d0
								move.b					(a3)+,d1
								move.b					(a3)+,d2
								IF						0=1																																																											; 1=1 to test greyscale alpha
								move					#1,d0
								move					#1,d1
								move					#1,d2
								ENDIF

								clr.l					d3
								clr.l					d4
								clr.l					d5
								move					#11,d5
								sub						d7,d5
	;move #0,d0
								move.b					.vfxColors4+1(pc,d5*4),d3
								move.b					.vfxColors4+2(pc,d5*4),d4
								move.b					.vfxColors4+3(pc,d5*4),d5
								cmpi					#(1<<mainPlaneDepth)-1,d6																																																					; check if bitplan is 0
								bne						.doColor4
.base							SET						4
.range							SET						12*32

								move					d7,a5

								move					d3,d0
								move					d4,d1
								move					d5,d2
    ;lsr #1,d0
    ;lsr #1,d1
    ;lsr #1,d2
								move					a5,d7
								bra.b					.writeColor4
.skyAlphaScaler
								dc.b					$00,$00,$00,$10
								dc.b					$20,$40,$50,$60
								dc.b					$70,$80,$90,$a0
								dc.b					$b0,$c0,$d0,$f0

    ; do fx colors for nontransparent playfield pixels
.doColor4

								add						d3,d5
								add						d4,d5
								lsl						#4,d5
								move					a5,d4
	;lsr #1,d4
								move					#12,d3
								sub						d4,d3
								seq						d4
								move					d3,d5
								move.b					(.skyAlphaScaler,pc,d5.w),d5

	;lsl #4,d5

	;andi #1,d4
								or						d4,d3																																																										; avoid div by zero exception
	;divu d3,d5
	;sub #100,d5
	;bpl .ss4
	;sf.b d5
.ss4
	;sf.b d5
	;move.b #15,d5

								add.b					d5,d0
								bcc.b					.keepRR4
								st.b					d0
.keepRR4
								add.b					d5,d1
								bcc.b					.keepGG4
								st.b					d1
.keepGG4
								add.b					d5,d2
								bcc.b					.keepBB4
								st.b					d2
.keepBB4

.writeColor4
	; write colors
								exg.l					a4,d3
    ;moveq #-1,d0
    ;moveq #-1,d1
    ;moveq #-1,d2
  ;clr.w d0
  ;clr.w d1	; set color to blue
								WRITECOLOR																																																															; 8 shades of colors at 0000
								exg.l					a4,d3
								dbra					d6,.colWriteFade4

								lea						32(a1),a1
								dbra					d7,.colRead4
								rts
.vfxColors4
								INCBIN					stage4/vfxColors.pal

;	#MARK: colors stage 05 outro

.stage5
								clr.w					d3
								clr.w					d4
								clr.w					d5

								move					#(1<<fxPlaneDepth)-5,d7
.colRead5
								move					#11,d0
								sub						d7,d0

								move.l					a1,a2
								move.l					a0,a3
								move					#(1<<mainPlaneDepth)-1,d6																																																					; loop through all 16 colors
.colWriteFade5               ; inner loop, write 16 colors with progressing hue
								move					(a2)+,a4																																																									; which color register?
								lea						1(a3),a3
								move.b					(a3)+,d0
								move.b					(a3)+,d1
								move.b					(a3)+,d2

								cmpi					#(1<<mainPlaneDepth)-1,d6																																																					; check if bitplan is 0
								bne						.doColor5

    ; set vfx colors for transparent background

.base							SET						4
.range							SET						12*32

								move					d7,a5
    ;moveq #-1,d1
    ;moveq #-1,d2
    ;moveq #-1,d3
								bra						.doColor5
								bra.b					.writeColor5
    ; do fx colors for nontransparent playfield pixels
.doColor5

								add						d3,d5
								add						d4,d5
								lsl						#4,d5
								move					a5,d4
								move					#12,d3
								sub						d4,d3
								seq						d4
								move					d3,d5
								move.b					(.outroAlphaScaler,pc,d5.w),d5
	;or d4,d3	; avoid div by zero exception

.ss5

								add.b					d5,d0
								bcc.b					.keepRR5
								st.b					d0
.keepRR5
								add.b					d5,d1
								bcc.b					.keepGG5
								st.b					d1
.keepGG5
								add.b					d5,d2
								bcc.b					.keepBB5
								st.b					d2
.keepBB5
;	clr.w d0
;	clr.w d1
;	clr.w d2

.writeColor5
								exg.l					a4,d3
;	clr.w d0
;	clr.w d1
;	clr.w d2
								WRITECOLOR																																																															; 8 shades of colors at 0000
								exg.l					a4,d3
								dbra					d6,.colWriteFade5

								lea						32(a1),a1
								dbra					d7,.colRead5
								rts
.outroAlphaScaler
								dc.b					$00,$04,$06,$08
								dc.b					$0a,$0c,$10,$14
								dc.b					$16,$18,$1a,$1c
								dc.b					$20,$20

enemShotColors
								dc.b					0,$6c,$20,0																																																									; outline of bullets
								dc.b					-1,$d0,$d0,0
								dc.b					0,$ff,-1,-1																																																									; centre of bullets, centre of vessel exhaust -> pulsating color
enemShotColors_stage3
								dc.b					0,$99,$99,$99																																																								;	darkest color
								dc.b					0,$cc,$fe,$c9																																																								; 	max brightness
								dc.b					0,155,210,5																																																									;	medium color


playerVesselPalette
								Incbin					incbin/palettes/ship.pal
								even

								

wrtTextOneShortPlane
								move.w					#mainPlaneWidth,d7
								bra.b					wrtTextOP
wrtTextOnePlane
								move.w					#mainPlaneWidth*mainPlaneDepth,d7
	;move.w #mainPlaneWidth,d7
wrtTextOP
								move.l					a3,-(sp)
								lea						wrt1plane(pc),a3																																																							; jump vector
								bra						wrtTextSkip
wrtTextBitmap
	;  	a0.l	-> 	textaddress
	; 	d0		->	x-coord
	;	d1		->	y-coord
	;	a5/a6	->	targetscreens (doublebuffer, base) optimised for write to 3 bitplanes
    ;	destroys a1,a2,a4,a5,a6,d0,d1,d2,d3,d4,d6

								move.l					a3,-(sp)
								lea						wrt3planes(pc),a3
wrtTextSkip
								cmp.l					#0,a5
								beq						.quitText
								moveq					#0,d3
								clr.l					d4
								st.b					d4																																																											;=$000000ff
								and.l					d4,d0
								asl						#1,d4
								and.l					d4,d1
								divu					#8,d0
								muls					#mainPlaneWidth*mainPlaneDepth,d1
								andi.l					#$3f,d0
								add.l					d0,d1
								move.l					d1,a1
								add.l					a5,a1
								clr.l					d4
    ;sf.b d4
								lea						font,a4

.readChar
								move.l					a1,a2
								moveq					#0,d6
								move.b					(a0)+,d6
								beq						.quitText
								cmpi.b					#"@",d6
								bgt						.gotLetter
								sub						#" ",d6
								move.b					charConvTable(pc,d6),d6
								jsr						(a3)
								addq.l					#1,d4
								bra						.readChar
.gotLetter
								sub						#49,d6
								jsr						(a3)
								addq.l					#1,d4
								bra						.readChar
.quitText
								move.l					(sp)+,a3
								rts
charConvTable
								dc.b					15,11,0,10,128,129,13,0																																																						; 32 - 39 " ","!","$"(Color Switch),"%"(NOOP), #"(Delta),"&"(%)
								dc.b					0,0,0,0,0,14,12,0																																																							; 40-47, "-","."
								dc.b					0,1,2,3,4,5,6,7,8,9																																																							; 48-57
wrt3planes
								move					#8,d5
								move					d4,d3
								move					#3,d2
.wrtLine
								move.b					4(a4,d6*8),d1
								move.b					d1,(mainPlaneWidth*4)*4(a2,d3)
								move.l					(a4,d6*8),d1
								move.b					d1,(mainPlaneWidth*4)*3(a2,d3)
								lsr.l					d5,d1
								move.b					d1,(mainPlaneWidth*4)*2(a2,d3)
								lsr.l					d5,d1
								move.b					d1,(mainPlaneWidth*4)*1(a2,d3)
								lsr.w					d5,d1
								move.b					d1,(mainPlaneWidth*4)*0(a2,d3)
								clr.b					(mainPlaneWidth*4)*5(a2,d3)
								clr.b					(mainPlaneWidth*4)*6(a2,d3)
								add.w					#mainPlaneWidth,d3
								dbra					d2,.wrtLine
								rts
wrt1plane
								move					d4,d3
								moveq					#fontHeight-2,d2
.wrtLine
								move					#8,d5
								move					d4,d3
								move.b					4(a4,d6*8),d1
								move.b					d1,(mainPlaneWidth*4)*4(a2,d3)
								move.l					(a4,d6*8),d1
								move.b					d1,(mainPlaneWidth*4)*3(a2,d3)
								lsr.l					d5,d1
								move.b					d1,(mainPlaneWidth*4)*2(a2,d3)
								lsr.l					d5,d1
								move.b					d1,(mainPlaneWidth*4)*1(a2,d3)
								lsr.w					d5,d1
								move.b					d1,(mainPlaneWidth*4)*0(a2,d3)
								clr.b					(mainPlaneWidth*4)*5(a2,d3)
								clr.b					(mainPlaneWidth*4)*6(a2,d3)
								rts


; #MARK: - TITLE MANAGER BEGINS
