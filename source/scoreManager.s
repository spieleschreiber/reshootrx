
wrtScore               ; draw 2 numbers plus shadow to sprite
                            ; d7.b = bcd number, a1 = address

	move		d7,d5
	asr			#4,d7
	and.w		d3,d7
	and.w		d3,d5

					move.b		4(a0,d5*8),d0						; read lowest line of right number
					move.b		4(a0,d7*8),d1						; left number
					clr.w		d2
					move.b		d0,d2								;
					lsl			d4,d1								; push to position
					sf.b		d1									; andi #$ff00,d1
					or			d1,d2								; fetch two numbers
					move.w		d2,spriteLineOffset*4(a1)			; write bitmap
					lsr			d2
					move.w		d2,8+spriteLineOffset*4(a1)			; write shadow

					move.l		(a0,d7*8),d1						; 4 lines from left digit
					move.l		(a0,d5*8),d0						; read 4 lines from right digit
					clr.w		d2
					move.b		d0,d2
					move.b		d1,d7
					lsl			d4,d7
					sf.b		d7
					or.w		d7,d2
					move.w		d2,spriteLineOffset*3(a1)
					lsr			#1,d2
					move.w		d2,8+spriteLineOffset*3(a1)

					clr.l		d2
					lsr.l		d4,d0
					move.b		d0,d2
					sf.b		d1
					or.w		d1,d2
					move.w		d2,spriteLineOffset*2(a1)
					lsr			#1,d2
					move.w		d2,8+spriteLineOffset*2(a1)

					clr.w		d2
					lsr.l		d4,d0
					lsr.l		d4,d1
					move.b		d0,d2
					sf.b		d1
					or.w		d1,d2
					move.w		d2,spriteLineOffset(a1)
					lsr			#1,d2
					move.w		d2,8+spriteLineOffset(a1)

					lsr.w		d4,d0
					lsr.l		d4,d1
					sf.b		d1
					or.w		d1,d0
					move.w		d0,(a1)
					lsr			d0
					move.w		d0,8(a1)
					rts


;
; #MARK: - SCORE MANAGER

scoreManager
					clr.l		d0
					btst		#0,frameCount+3(pc)
					beq			drawInfoPanel

drawScore
					lea			scoreAdder(pc),a0
					move		(a0),d0
					beq			scoreQuit

					clr.w		(a0)
					tst.b		plyBase+plyCheatEnabled(pc)
					bne			scoreQuit							; only add score if cheatFlag=false

	; handle multiplier
					lea			scoreMultiplier(pc),a3
					add.b		#1,2(a3)
					bcc.b		.maxMultiplier
					move.b		#250,2(a3)
.maxMultiplier
					clr.w		d1
					move.b		2(a3),d1
					lsr			#5,d1
					clr.w		d6
					move.b		((scoreMulti).w,pc,d1.w),d6
					move.w		#60*5,(a3)							; keep chain for 3 seconds, then reset

					lea			(score,pc),a6

					move.l		(a3),d2
					tst.w		(a3)
					beq			scoreQuit							; zero multiplier -> skip
					cmp.b		3(a3),d6							; unchanged? Skip!
					beq.b		.skipDispUpdate
					bsr			initMultiply
.skipDispUpdate
					move.b		d6,3(a3)
.drawStats
					lea			scoreAdder(pc),a0
					clr.w		(a0)								; reset scoreAdder
					bsr			convertHexToBCD
					move		d1,scoreAdd+2(a6)
					move.w		scoreAdd+2(a6),a4
.multiplyScore
					move.l		a6,a4
					addq.l		#4,a4
					lea			(score+scoreAdd+4,pc),a5

					moveq		#0,d0								; calc new score
					add			#0,d0
					abcd		-(a5),-(a4)
					abcd		-(a5),-(a4)
					abcd		-(a5),-(a4)
					abcd		-(a5),-(a4)
					IFEQ		OBJECTSCORETEST
					dbra		d6,.multiplyScore					; loop in case of score multiplier
					ENDIF

.scoreToSprite	;   write score
					lea			font(pc),a0
					clr.w		d5
					clr.w		d7
					moveq		#$f,d3
					moveq		#8,d4

					lea			infoPanelScore,a5
					move.b		scoreNew(a6),d7						; check first two digits of score. Changed?
					move.b		scoreOld(a6),d5
					cmp.b		d5,d7
					beq.b		.chkNext2
					move.b		d7,scoreOld(a6)						;   yes
					move.l		a5,a1
					bsr			wrtScore							; write to sprite
.chkNext2
					addq.l		#1,a6								; second two digits ...
					move.b		scoreNew(a6),d7
					move.b		scoreOld(a6),d5
					cmp.b		d5,d7
					beq.b		.chkNext3

					move.b		d7,scoreOld(a6)
    ;lea ([(spriteScoreBuffer).w,pc],(spriteLineOffset*spriteScoreHeight+16+2).w),a1
					lea			2(a5),a1
					bsr			wrtScore
.chkNext3
					addq.l		#1,a6								; third two digits ...
					move.b		scoreNew(a6),d7
					move.b		scoreOld(a6),d5
					cmp.b		d5,d7
					beq.b		.chkNext4

					move.b		d7,scoreOld(a6)
    ;lea ([(spriteScoreBuffer).w,pc],(spriteLineOffset*spriteScoreHeight+16+4).w),a1
					lea			4(a5),a1
					bsr			wrtScore
.chkNext4
					addq.l		#1,a6								; fourth two digits ...
					move.b		scoreNew(a6),d7
					move.b		scoreOld(a6),d5
					cmp.b		d5,d7
					beq.b		scoreQuit
					move.b		d7,scoreOld(a6)
					lea			6(a5),a1
					bra			wrtScore
scoreQuit
					rts

infoPanelDelta		SET			infoPanelStatus
infoPanelHighscore	SET			infoPanelDelta+10*spriteLineSize
infoPanelHuntem		SET			infoPanelDelta+5*spriteLineSize
infoPanelMultiply	SET			infoPanelDelta+15*spriteLineSize
infoPanelDidIt		SET			infoPanelDelta+20*spriteLineSize
scoreMulti
					dc.b		0,1,1,2,2,3,3,4
; #MARK: Draw Info Panel

drawInfoPanel
					lea			font(pc),a0

					clr.w		d1
;	move.b #4<<5,scoreMultiplier+2
					move.b		scoreMultiplier+2(pc),d1			; got new multiplier?
					lsr			#5,d1
					tst.b		((scoreMulti).w,pc,d1.w)
					bne			.showMultiply						; keep on displaying
	;MSG01 m2,d0

					move.b		scoreHighSuccessFlag(pc),d1			; got new highscore
					bmi			.dispHigh
					bne			.drawHighBlink						; keep on displaying
    ;bne .drawHighscore	; yes - init dsplay

					move.l		scoreHigh(pc),d6
					cmp.l		score(pc),d6
					bgt			.drawDelta							; is highscore higher than score?
; #MARK: draw highscore

.drawHighscore
					PLAYFX		10									; got new high!
					move.b		#1,scoreHighSuccessFlag
.dispHigh
					lea			infoPanelHighscore,a4
					lea			infoPanelDelta,a0
					move.l		a0,a1
					bra			.copyMsgToSprite
.drawHighBlink
					add.b		#1,scoreHighSuccessFlag
					andi.b		#%10000,d1
					bne.b		.showDelta
					lea			infoPanelDidIt,a0
					bra			.showInfoPanel
.showMultiply
					lea			infoPanelMultiDisplay,a0
	;lea infoPanelMultiply,a0
					bsr			.drawMultiplier
					bra			.showInfoPanel
.showDelta
					lea			infoPanelDelta,a0
.showInfoPanel
					move.l		a0,d0
					move.l		copperGame(pc),a1
					move.w		d0,2(a1)
					swap		d0
					move.w		d0,6(a1)
.quit
					rts

	; #MARK: draw delta
.drawDelta
					lea			scoreHighDelta(pc),a6
					move.l		scoreHigh(pc),d6
					move.l		d6,(a6)
					addq		#4,a6
					lea			score+4(pc),a5
    ;add #0,d0
					clr.w		d0
					sbcd		-(a5),-(a6)
					sbcd		-(a5),-(a6)
					sbcd		-(a5),-(a6)
					sbcd		-(a5),-(a6)

					lea			infoPanelDelta,a5
	;lea spritePlayerBasic,a5
					cmpi.l		#$100000-1,(a6)						; check if high delta > 50000
					bgt			.copyHuntem

					clr.w		d5
					clr.w		d7
					moveq		#$f,d3
					moveq		#8,d4

					lea			scoreHighDelta(pc),a6
					move.b		1(a6),d7
					andi		#$f,d7
					or			#$a0,d7

					lea			2(a5),a1
					bsr			wrtScore
					move.b		2(a6),d7
					lea			4(a5),a1
					bsr			wrtScore
					move.b		3(a6),d7
					lea			6(a5),a1
					bsr			wrtScore
					bra			.showDelta

.copyHuntem
					lea					infoPanelHuntem,a4
					move.l				a5,a1
					move.l				4(a4),d1
					cmp.l				4(a5),d1								; Huntem Msg already copied?
					beq					.showDelta								; yes
.copyMsgToSprite
					moveq				#spriteDMAWidth/4,d4
					moveq				#spriteScoreHeight-1,d7					; draw go 4 high
.copy
					movem.l				(a4)+,d0-d3
					move.w				d0,2(a1)
					move.l				d1,4(a1)
					move.w				d2,10(a1)
					move.l				d3,12(a1)
					lea					spriteLineSize(a1),a1
					dbra				d7,.copy
;.quit
					bra					.showDelta
	; #MARK: draw stats

.drawMultiplier	; draw extra stats
	;bra .klklk
					lea					scoreMultiplier(pc),a4
					move.w				(a4),d3
					cmpi				#$ff,d3
					shi					d0
					or.b				d0,d3									; if >$ff -> $ff
					andi.w				#$ff,d3

					lea					infoPanelMultiply,a2


					lsr					#5,d3
					move.l				noiseFilter+1(pc,d3*4),d0
					lea					fastRandomSeed(pc),a4
					move.l				(a4),d1									; AB
					move.l				4(a4),d2								; CD
					swap				d2										; DC
					add.l				d2,(a4)									; AB + DC
					add.l				d1,4(a4)								; CD + AB
					rol.l				d2,d0
					lea					(a0),a1
					moveq				#spriteScoreHeight-1,d5
.copyBitmap
					movem.l				(a2),d3/d4
					lea					16(a2),a2								; get next line
					and.l				d0,d3
					and.l				d0,d4
					movem.l				d3/d4,(a1)								; write bitmap data
					asr.l				d3
					roxr.l				d4
					movem.l				d3/d4,8(a1)								; create shadow
					rol.l				d2,d0
					lea					16(a1),a1
					dbra				d5,.copyBitmap
					rts

	; #MARK: draw multiply

initMultiply
					SAVEREGISTERS
					move.l				4(a3),a0
					tst.l				a0
					beq					.skipSpriteSpawn
	;move.b d1,3(a3)
					move.w				d6,d1
					move.l				chainBnsAnimPointer(pc),a4
					move.w				animTablePointer+2(a4),d4				;add chain display
					move				objectListX(a0),d5
					move				objectListY(a0),d6
    ;sub.w #$15,d5
					bsr					objectInit
					tst.l				d6
					bmi					.quit
					move.l				viewPosition+viewPositionAdd(pc),d2
					asr.l				#8,d2
					sub					#100,d2
					move.w				d2,objectListAccY(a4)					; float up, regardless of scrollspeed
    ; is sprite therefore attribs are assigned by objects-list. $40=bonus icon

					lea					spriteAnimTableChain(pc),a2
					lsl					#6,d1
					lea					spriteChain8pixels(pc,d1),a1			; muls 64
					move.l				a1,(a2)									; modify sprite bitmap pointer

.skipSpriteSpawn
					lea					multiplyPixels(pc),a0
					clr.w				d1
					move.b				scoreMultiplier+2(pc),d1
					lsr					#5,d1
					move.b				((scoreMulti).w,pc,d1.w),d1
					lea					8+font(pc,d1*8),a1
					lea					infoPanelMultiply+7,a2

	; draw muls num

					move				#8,d5
					move.b				4(a1),d1
					move.b				d1,spriteLineOffset*4(a2)				; lowest line
					lsr.b				#1,d1
					move.b				d1,8+spriteLineOffset*4(a2)				; shadow

					move.l				(a1),d1
					move.b				d1,spriteLineOffset*3(a2)
					lsr.b				#1,d1
					move.b				d1,8+spriteLineOffset*3(a2)

					lsr.l				d5,d1
					move.b				d1,spriteLineOffset*2(a2)
					lsr.b				#1,d1
					move.b				d1,8+spriteLineOffset*2(a2)

					lsr.l				d5,d1
					move.b				d1,spriteLineOffset(a2)
					lsr.b				#1,d1
					move.b				d1,8+spriteLineOffset(a2)

					lsr.l				d5,d1
					move.b				d1,(a2)
					lsr.b				#1,d1
					move.b				d1,8(a2)
.quit
					RESTOREREGISTERS
					rts

newHighscorePixels; Highscore Pixeldata. First two words: sprite 7 DMA Highsuccess. 3rd word: sprite 7 manual Highsuccess, 4th word: sprite 7 manual High Delta
					INCBIN				incbin/scorefont_hi.raw
multiplyPixels; Multiply pixeldata
					INCBIN				incbin/scorefont_sc.raw
go4HighPixels
					INCBIN				incbin/scorefont_go.raw
statDisp
					dc.b				%00100000								; 4 weap & speed stat displays
					dc.b				%00100000
					dc.b				%00010000								; shadow
					dc.b				%00010000

					dc.b				%00101000
					dc.b				%00101000
					dc.b				%00010100
					dc.b				%00010100

					dc.b				%00101010
					dc.b				%00101010
					dc.b				%00010101
					dc.b				%00010101

;	dc.b %00101010
;	dc.b %00100100
;	dc.b %00010101
;	dc.b %00010010
; #MARK: SCORE MANAGER ENDS -

