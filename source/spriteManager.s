
; #MARK: - SPRITE MANAGER

spriteManagerPlayer
;	#MARK: sprite player code
	clr.l		d6

	lea			spritePlayerDMA(pc),a0
	movem.l		(a0),d0-d1/a5-a6
	exg.l		d0,a5
	exg.l		d1,a6
	movem.l		d0-d1/a5-a6,(a0)			; switch double buffered dma lists

	lea			copSprite01,a0				; write dma pointers to coplist
	move.l		a5,d0
	move.l		a6,d1
	move		d0,6(a0)
	swap		d0
	move		d0,2(a0)
	move		d1,14(a0)
	swap		d1
	move		d1,10(a0)


	lea			plyBase(pc),a1
	lea			copGamePlyBody,a5

	move.w		plyPosX(a1),d4				; player x-position
	;sub.w plyPosXDyn(a1),d4
	move.w		plyPosYABS(a1),d2		;	y-position
	add			#50,d2
	moveq		#playerBodyHeight,d5
	add.w		d2,d5
	clr.b		d3
	lsl.w		#8,d2					; move vertical start bit 8 in place
	addx.b		d3,d3

	lsl.w		#8,d5					; vertical stop bit 8
	addx.b		d3,d3

	lsr.w		#1,d4					; horizontal start bit 0
	addx.b		d3,d3
	add.b		#$44,d4
	move.b		d4,d2					; make first control word
	move.b		d3,d5					; second control word
	rol			#5,d6					; add 35 & 70 ns pixelcoord
	andi		#%11000,d6
	bset		#7,d6					; attach bit
	or			d6,d5

	move.w		d2,0+2(a5)											; SPRxPOS
	move.w		d5,4+2(a5)											; SPRxCTL
	move.w		d2,8+2(a5)											; SPRxPOS
	move.w		d5,12+2(a5)											; SPRxCTL
	moveq		#1,d6
	sub.b		plyBase+plyFire1AutoB(pc),d6
	seq.b		d6
	ext.w		d6
	move.w		d6,d4
	andi		#(spritePlayerBasicEnd-spritePlayerBasic)/2,d6		; add shoot illumination

	lea			spritePlayerBasic(d6),a0							; set pointer to anim frame

	move.w		plyBase+plyPosAcclX(pc),d6
	tst.w		plyBase+plyPosAcclX(pc)
	beq.b		.idle												; moves left or right? No!
	spl.b		d6													; yes - tilt anim
	ext.w		d6
.sprSize	SET			(spritePlayerBasicEnd-spritePlayerBasic)
	andi		#.sprSize,d6
	lea			.sprSize(a0,d6),a0
.idle
	move		frameCount+4(pc),d7
	lsr			#1,d7
	andi		#$07<<1,d7
	move.w		.frameOffsetTable(pc,d7),d1
	
	lea			(a0,d1.w),a0
	move.l		a0,d6

	btst		#1,d7
	bne			.skipEvenFrames
.exhaustOffset	SET			(20*8*2)+4						; ship acceleration  -> exhaust size
	lea			.exhaustOffset(a0),a2
	clr.w		d7
	move.b		plyBase+plyAcclXCap+1(pc),d7
	sub.b		#6,d7
	beq			.skip
	move.w		frameCount+2(pc),d1
	andi.w		#1,d1
	add.b		d7,d1
	move.b		.fireFrame-2(pc,d1.w),d7
.skip
	lsl			#4,d7
	lea			spritePlayerExhaust(pc,d7.w),a1
	movem.l		(a1)+,d1/d2/d3/d4					; 8 lines of pixeldata
	move		#8,d5
	move.b		d1,48(a2)
	lsr.l		d5,d1
	move.b		d1,32(a2)
	lsr.l		d5,d1
	move.b		d1,16(a2)
	lsr			d5,d1
	move.b		d1,(a2)

	move.b		d3,56(a2)
	lsr.l		d5,d3
	move.b		d3,40(a2)
	lsr.l		d5,d3
	move.b		d3,24(a2)
	lsr			d5,d3
	move.b		d3,8(a2)

	;lea (28*16)+0(a2),a2
	move.b		d2,112(a2)
	lsr.l		d5,d2
	move.b		d2,96(a2)
	lsr.l		d5,d2
	move.b		d2,80(a2)
	lsr			d5,d2
	move.b		d2,64(a2)

	move.b		d4,120(a2)
	lsr.l		d5,d4
	move.b		d4,104(a2)
	lsr.l		d5,d4
	move.b		d4,88(a2)
	lsr			d5,d4
	move.b		d4,72(a2)

.skipEvenFrames


	move.w		d6,16+2(a5)
	swap		d6
	move.w		d6,16+6(a5)


.frameMod			SET			.sprSize/16
.xOffsetLeft		SET			1
.xOffsetRight		SET			5
.bitplaneOffset		SET			8
.lineOffset			SET			16
.testCase			SET			2*.lineOffset+.xOffsetLeft
.yOffset			SET			7
	;btst #0,frameCount+3(pc)
	;beq .keepPos
	move.w		frameCount+2(pc),d2
	btst		#4,d2
	seq			d4
	andi.w		#$9c,d4														; animframe offset

	;clr.l d0
	andi		#$f,d2
	lea			plyBase+plyRemXPos(pc),a2
	movem.w		plyBase+plyPosX(pc),d0
	move.w		d0,(a2,d2.w*2)
	sub			#4,d2														; add visual intertia by fetching xpos with three frames delay
	andi		#$f,d2
	move.w		(a2,d2*2),d1
	;andi #3,d2
	sub.w		d1,d0														; valuerange.w -8 to 8

	asr			#1,d0														; control x-inertia
	add			#4,d0
	move		d0,d2
	smi.b		d1
	cmpi.b		#8,d0
	sge.b		d3															; >8?
	andi.b		#1,d3
	or.b		d3,d1														; create eor modify byte
	ext.w		d1
	and.w		d1,d2
	eor.w		d2,d0														; avoid values <0 and >8

	lea			((.lineOffset*(3+.yOffset))+playerBodyHeight*16,a0),a3
.idleXClr
	lea			spritePlayerContainer,a2

	lea			.restore+.yOffset*4(pc),a4
	clr.w		d7
	tst.w		plyBase+plyPosAcclX(pc)
	beq			.idleXY
	spl			d7
	and.w		#32+16,d7
	add.w		#32+16,d7
.idleXY
	lea			(a4,d7),a4

	move.b		plyBase+plyWeapUpgrade(pc),d7
	spl			d6
	and.b		d6,d7									; player fatal hit? Keep d7 >= 0
	move.b		.offsetTable(pc,d7),d7
	lea			(a2,d7*2),a2							; add upgrade offset
	lea			(a2,d4.w*2),a2							; add animframe offset
	moveq		#11-.yOffset,d7
.clrContrns
	move.w		(a4)+,d6								; fetch ship outlines
	movem.l		(a2)+,d2/d5
	lsl.l		d0,d2
	lsl.l		d0,d5
	or.b		d6,d2
	move.w		d2,.xOffsetLeft+.bitplaneOffset(a3)		; bitplane 0 right, 1.row
	swap		d2
	lsr.w		#8,d6
	or.w		d6,d5
	;move #-1,d5
	move.w		d5,.xOffsetLeft(a3)						; bitplane 1 right, 1.row

	move.w		(a4)+,d6
	move.b		d6,d3
	sf.b		d6
	or.w		d6,d2
	move.w		d2,.xOffsetRight+.bitplaneOffset(a3)	; bitplane 0 right, 1.row
	swap		d5
	lsl			#8,d3
	;lsl #3,d5
	or.w		d3,d5
	;move #-1,d5
	move.w		d5,.xOffsetRight(a3)								; bitplane 1 right, 1.row
	lea			16(a3),a3
	dbra		d7,.clrContrns

	moveq		#.yOffset,d7
.clrContrns1
	movem.l		(a2)+,d4/d5
	lsl.l		d0,d4
	lsl.l		d0,d5
	;move.w d4,.xOffsetLeft+.bitplaneOffset-(2*8*0)(a3)	; bitplane 0 right, 1.row
	move.w		d5,.xOffsetLeft+.bitplaneOffset-(2*8*28)(a3)		; bitplane 0 right, 1.row
	move.w		d5,.xOffsetLeft-(2*8*28)(a3)						; bitplane 1 right, 1.row
	move.w		d4,.xOffsetLeft-(2*8*28)(a3)						; bitplane 1 right, 1.row
	swap		d4
	swap		d5

	move.w		d4,.xOffsetRight+.bitplaneOffset-(2*8*28)(a3)		; bitplane 0 right, 1.row
	move.w		d5,.xOffsetRight-(2*8*28)(a3)						; bitplane 1 right, 1.row
	move.w		d5,.xOffsetRight-(2*8*28)(a3)						; bitplane 1 right, 1.row
	lea			16(a3),a3
	dbra		d7,.clrContrns1
.keepPos
	bra			.fuk
.fireFrame
					dc.b		3,5,6,7
.offsetTable
					dc.b		0,13*4,26*4,39*4
	;SAVEREGISTERS
.restore	; bitmap data taken from ship_0a.raw, row/byte 496 to 672
					dc.b		1,1,$80,$80
					dc.b		0,1,0,$80
					dc.b		1,1,$80,$80
					dc.b		0,1,0,$80
					dc.b		1,1,$80,$80
					dc.b		3,2,$c0,$40
					dc.b		3,2,$c0,$40
					dc.b		3,2,$c0,$40
					dc.b		3,3,$c0,$c0
					dc.b		3,3,$c0,$c0
					dc.b		3,3,$c0,$c0
					dc.b		1,1,$80,$80
	; bitmap data taken from ship_0b.raw, row/byte 496 to 672
					dc.b		0,0,$80,$40
					dc.b		0,0,$e0,$e0
					dc.b		0,0,$e0,$e0
					dc.b		0,0,$e0,$e0
					dc.b		0,0,$b0,$70
					dc.b		0,0,$d0,$30
					dc.b		0,0,$f8,$18
					dc.b		0,0,$f8,$78
					dc.b		0,0,$d8,$f8
					dc.b		0,0,$e0,$e0
					dc.b		0,0,$c0,$c0
					dc.b		0,0,$c0,$40
	; bitmap data taken from ship_0c.raw, row/byte 496 to 672
					dc.b		1,2,0,0
					dc.b		7,7,0,0
					dc.b		7,7,0,0
					dc.b		7,7,0,0
					dc.b		$d,$e,0,0
					dc.b		$b,$c,0,0
					dc.b		$1f,$18,0,0
					dc.b		$1f,$1e,0,0
					dc.b		$1b,$1f,0,0
					dc.b		7,7,0,0
					dc.b		3,3,0,0
					dc.b		3,2,0,0

.fuk


	lea			(playerBodyHeight*16,a0),a0
	move.l		a0,d0
	move.w		d0,16+10(a5)
	swap		d0
	move.w		d0,16+14(a5)
	lea			copSplitList(pc),a0
	move.l		(a0)+,a1						; get pointer to offset table

	move.w		(a0),d6							; no of lines
	sub			#1,d6
	beq			sprManPlyReturn

	move.l		(a1)+,a2						; get adress of current subcoplist -> pointer to BPLCON1
	lea			-16(a2),a2
	lea			plySprSaveCop(pc),a5
	lea			copGamePlyBodyRestore,a4
	lea			copGamePlyBodyReturn+2,a6
	movem.l		(a5),a0/d0-d2
	tst.l		a0
	beq			.firstRun
	movem.l		d0-d2,(a0)
.firstRun
	moveq		#3,d7							; y-offset playerpos / rastersplit
	add.w		plyBase+plyPosYABS(pc),d7		; get scanline
	lsr			#1,d7
	cmp			d6,d7
	blo			.yPosOK
	move		d6,d7
.yPosOK
	move.w		(a1,d7*2),d7					; pointer to entry in coplist
	lea			2(a2,d7),a2
	tst.b		dialogueIsActive(pc)
	bne			.dialogueMod
	tst.b		escalateIsActive(pc)
	bne			.escalateMod
.cont
	movem.l		(a2),d0-d2						; get original entrys
	move.l		a2,12(a5)						; save coplist adress
	movem.l		d0-d2,(a5)						; save entrys
	movem.l		d0-d2,(a4)						; write copied commands to temp coplist

	lea			12(a2),a4
	move.l		a4,d0
	move.w		d0,(a6)
	swap		d0
	move.w		d0,4(a6)						; copjmp bck to original coplist

	move.w		#COPJMP2,(a2)												; write copjmp code -> coplist. Inits copjmp to copGamePlyBody
	bra			sprManPlyReturn
.escalateMod
	cmpi.w		#escalateStart+escalateHeight-50,plyBase+plyPosYABS(pc)		; get player y-pos
	bhi			.cont
	cmpi.w		#escalateStart-48,plyBase+plyPosYABS(pc)					; get player y-pos
	bls			.cont
	lea			copGameEscalateSplits,a2
	move.w		plyBase+plyPosYABS(pc),d7
	;lsr #2,d7
	sub.w		#50,d7
	lea			(a2,d7*4),a2
	bra			.cont
.dialogueMod
	cmpi.w		#$42,plyBase+plyPosYABS(pc)									; get player y-pos
	bhi			.cont

	lea			copGameDialogueExit,a2
	moveq		#45,d7
	add.b		plyBase+plyPosYABS+1(pc),d7
	move.b		d7,-4(a2)													; modify copper wait within dialogue view
	bra			.cont
.add	SET			.sprSize/16
.muls	SET			0
.frameOffsetTable
		REPT		8
		dc.w		.muls
.muls	SET			.muls+.add													;player vessel height * 8
		ENDR
plySprSaveCop
		blk.l		4,0

spritePlayerExhaust
		INCBIN		incbin/player/exhaust0
		INCBIN		incbin/player/exhaust1
		INCBIN		incbin/player/exhaust2
		INCBIN		incbin/player/exhaust3
		INCBIN		incbin/player/exhaust4
		INCBIN		incbin/player/exhaust5
		INCBIN		incbin/player/exhaust6
		INCBIN		incbin/player/exhaust7


;	#MARK: general sprite code
spriteManager
	clr.l		d0
	clr.l		d1
	clr.l		d2
	clr.l		d3

	lea			CUSTOM,a6
	lea			spriteWriteLastYPos(pc),a0			; clear for sprites 2-5 -> not 6,7 -> not part of multiplexing code
	movem.l		d0-d3,(a0)

	lea			copSpriteLists(pc),a0
	add.w		#1,32(a0)
	move.w		32(a0),d7
	;lsl #1,d7
	andi		#%11000,d7
	move.l		(a0,d7.w*1),d0
	move.l		d0,36(a0)

	move		d0,copInitSprPtLW
	swap		d0
	move		d0,copInitSprPtHW
	swap		d0
		;move.l d0,36(a0)
	move.l		d0,a1
	move.w		2(a1),d2							; get address of sprite dma memory
	swap		d2
	move.w		6(a1),d2

	lea			spriteDMAListDynOffsets(pc),a0		; reset list of dynamic pointers.w
	move.l		d2,(a0)+
	movem.l		8(a0),d4-d5
	movem.l		d4-d5,(a0)
.sprModifiedFlag=2

	move.l		d2,a6								; get base pointer.l
	;ALERT01 m2,a6
	movem.l		spritePlayerDMA+8(pc),a3/a4			; fetch pointers to sprite 0 / 1 dma (basic shot, xtra shot)
	move		spriteCount(pc),d7
	subq		#1,d7
	bmi.w		.closeDMA

	move.l		spritePosFirst(pc),a1

	IFNE		DEBUGSPRITEPOSMEM
	move.l		spritePosMem(pc),a5
	ALERT01		m2,a5
	lea			spritePosMemSize(a5),a5
	ALERT02		m2,a5
	ALERT03		m2,a1
	move.l		spritePosLast(pc),d6
	ALERT04		m2,d6
	ENDIF

	lea			spriteWriteLastYPos(pc),a5
    ;sub.l a6,a6			; reset dynamic spritedmamem-offset
    ;move frameCount+4(pc),d0
    ;lsr #1,d0
   ; andi #3,d0
	moveq		#0,d0								; reset pointer to sprite-no

		;#MARK: sprite bullets loop
		;
		; a1	pointer sprite chain list
		; a3	pointer player shot dma sprite
		; a5	remember last y stop position+1
		; a6 = target base address
		; d5 	dynamic offset to target
	moveq		#4,d6
	bra.b		.firstEntry
.nextSprite
	adda.w		d6,a1
	tst.w		(a1)
	bne.b		.firstEntry
	adda.w		d6,a1
	tst.w		(a1)
	bne.b		.firstEntry
	adda.w		d6,a1
	tst.w		(a1)
	bne.b		.firstEntry
	adda.w		d6,a1
	tst.w		(a1)
	beq.b		.nextSprite
.firstEntry
	move.l		(a1),d2
	clr.l		(a1)								; clear up sprite list
	move		d2,d4								; x-position in lower word
	move		d2,d1								; prep animjump
	swap		d2									; y-position
	rol			#7,d1								; jump to different animation routines
	andi.w		#$3f<<1,d1
	;move #35<<1,d1

	;jmp .sprBullet8C
				move.w		.spriteAnimCases.w(pc,d1),d1
				jmp			.spriteAnimCases(pc,d1)
.spriteAnimCases
.sc
				dc.w		0,.sprPlyShotA-.sc,.sprPlyShotB-.sc,.sprPlyShotC-.sc,.sprPlyShotD-.sc,.sprPlyShotE-.sc,.sprPlyShotF-.sc
		; sprite 0-6

				dc.w		.sprPlyShotA1-.sc,.sprPlyShotB1-.sc,.sprPlyShotC1-.sc,.sprPlyShotD1-.sc,.sprPlyShotE1-.sc,.sprPlyShotF1-.sc
		; sprite 7-12

				dc.w		.sprPlyShotA2-.sc,.sprPlyShotB2-.sc,.sprPlyShotC2-.sc,.sprPlyShotD2-.sc,.sprPlyShotE2-.sc,.sprPlyShotF2-.sc
		; sprite 13-18

				dc.w		.sprPlyShotA3-.sc,.sprPlyShotB3-.sc,.sprPlyShotC3-.sc,.sprPlyShotD3-.sc,.sprPlyShotE3-.sc,.sprPlyShotF3-.sc
		; sprite 19-24

				dc.w		.sprBonus8A-.sc,.sprBonus8B-.sc,.sprChain8A-.sc,.sprChain8B-.sc													;25-28
				dc.w		.bulletBasicX1-.sc,.bulletBasicX2-.sc,.bulletBasic-.sc,.sprBullet8C-.sc											;29-32
				dc.w		.sprBullet8B-.sc,.sprBullet8A-.sc,.sprTutSpeedA-.sc,.sprTutSpeedB-.sc											;33-36
				dc.w		.sprTutPowerUpA-.sc,.sprTutPowerUpB-.sc,.sprInstSpwn-.sc,.sprAlertA-.sc											;37-40
				dc.w		.sprAlertB-.sc,.sprAlertC-.sc																					;41,42
				dc.w		.sprAlertD-.sc,.sprAlertE-.sc																					;43,44
				dc.w		.sprPause-.sc																									;45

	; control player shots


.spritelineMod	SET			spriteLineOffset/2*playerShotHeight
.sprPlyShotF3	; basic shot totally fractured
				lea			spritePlayerShot+.spritelineMod*23(pc),a2
				bra			.sprDrawXtraSht
.sprPlyShotE3
				lea			spritePlayerShot+.spritelineMod*22(pc),a2
				bra			.sprDrawXtraSht
.sprPlyShotD3
				lea			spritePlayerShot+.spritelineMod*21(pc),a2
				bra			.sprDrawXtraSht
.sprPlyShotC3
				lea			spritePlayerShot+.spritelineMod*20(pc),a2
				bra			.sprDrawXtraSht
.sprPlyShotB3
				lea			spritePlayerShot+.spritelineMod*19(pc),a2
				bra			.sprDrawShot
.sprPlyShotA3	; a3 = pointer to sprite 0, a4 = pointer to sprite 1
				lea			spritePlayerShot+.spritelineMod*18(pc),a2
				bra			.sprDrawShot

.sprPlyShotF2	; first fractures
				lea			spritePlayerShot+.spritelineMod*17(pc),a2
				bra			.sprDrawXtraSht
.sprPlyShotE2
				lea			spritePlayerShot+.spritelineMod*16(pc),a2
				bra			.sprDrawXtraSht
.sprPlyShotD2
				lea			spritePlayerShot+.spritelineMod*15(pc),a2
				bra			.sprDrawXtraSht
.sprPlyShotC2
				lea			spritePlayerShot+.spritelineMod*14(pc),a2
				bra			.sprDrawXtraSht
.sprPlyShotB2
				lea			spritePlayerShot+.spritelineMod*13(pc),a2
				bra			.sprDrawShot
.sprPlyShotA2	; a3 = pointer to sprite 0, a4 = pointer to sprite 1
				lea			spritePlayerShot+.spritelineMod*12(pc),a2
				bra			.sprDrawShot


.sprPlyShotF1	; first fractures
					lea			spritePlayerShot+.spritelineMod*11(pc),a2
					bra			.sprDrawXtraSht
.sprPlyShotE1
					lea			spritePlayerShot+.spritelineMod*10(pc),a2
					bra			.sprDrawXtraSht
.sprPlyShotD1
					lea			spritePlayerShot+.spritelineMod*9(pc),a2
					bra			.sprDrawXtraSht
.sprPlyShotC1
					lea			spritePlayerShot+.spritelineMod*8(pc),a2
					bra			.sprDrawXtraSht
.sprPlyShotB1
					lea			spritePlayerShot+.spritelineMod*7(pc),a2
					bra			.sprDrawShot
.sprPlyShotA1	; a3 = pointer to sprite 0, a4 = pointer to sprite 1
					lea			spritePlayerShot+.spritelineMod*6(pc),a2
					bra			.sprDrawShot


.sprPlyShotF	; basic shots
					lea			spritePlayerShot+.spritelineMod*5(pc),a2
					bra			.sprDrawXtraSht
.sprPlyShotE
					lea			spritePlayerShot+.spritelineMod*4(pc),a2
					bra			.sprDrawXtraSht
.sprPlyShotD
					lea			spritePlayerShot+.spritelineMod*3(pc),a2
					bra			.sprDrawXtraSht
.sprPlyShotC	; spread shot right
					lea			spritePlayerShot+.spritelineMod*2(pc),a2
					bra			.sprDrawXtraSht
.sprPlyShotB	; spread shot left
					lea			spritePlayerShot+.spritelineMod(pc),a2
					bra			.sprDrawShot
.sprPlyShotA	; basic shot north. a3 = pointer to sprite 0, a4 = pointer to sprite 1
					lea			spritePlayerShot(pc),a2

.sprDrawShot

    ;    d6= height, d2=y-position, d4 = x-position
;	#MARK: sprite make control words

	move		#-playerShotHeight-1,d3								; check if sprites overlap
	sub.b		-(playerShotHeight+1)*spriteLineOffset(a4),d3
	add			d2,d3												; <0 if overlap
	smi			d3
	sub.w		d3,d2												; +1 to ypos if overlap

.firstSprite

	; optimised sprite write, cope with non-PAL area only
	clr.b		d3
	moveq		#playerShotHeight,d1
	add.w		d2,d1												; y stop position
	lsl.w		#8,d2												; move vertical start bit 8 in place
	addx.b		d3,d3
	lsl.w		#8,d1												; vertical stop bit 8
	addx.b		d3,d3
	lsr.w		#1,d4												; horizontal start bit 0
	addx.b		d3,d3
	add.b		#$30,d4
	move.b		d4,d2												; make first control word
	move.b		d3,d1
	move.w		d2,(a4)												; SPRxPOS
	move.w		d1,8(a4)											; SPRxCTL

.offset		SET			spriteLineOffset

.wrtLine

	movem.l		(a2)+,d1-d4											; get one scanline
	cmp.l		.offset+24(a4),d4
	bne			.drawPixels
	cmp.l		.offset+16(a4),d3
	beq			.keepPixels
.drawPixels
				; write 4 scanlines * 4 times
	IF			1=0
	moveq		#-1,d1
	move.l		d1,d2
	move.l		d2,d3
	move.l		d3,d4
	ENDIF
	move.l		d1,.offset(a4)
	move.l		d2,.offset+8(a4)
	move.l		d3,.offset+16(a4)
	move.l		d4,.offset+24(a4)

	REPT		11
	movem.l		(a2)+,d1-d4
	IF			0=1
	move.l		#$fffff000,d1
	move.l		d1,d2
	move.l		d2,d3
	move.l		d3,d4
	ENDIF
.offset			SET			.offset+spriteLineOffset*2
	move.l		d1,.offset(a4)
	move.l		d2,.offset+8(a4)
	move.l		d3,.offset+16(a4)
	move.l		d4,.offset+24(a4)
	ENDR
	adda.w		#(playerShotHeight+1)*spriteLineOffset,a4
	dbra		d7,.nextSprite
	bra			.closeDMA
.keepPixels
	adda.w		#(playerShotHeight+1)*spriteLineOffset,a4
.endLoopPlyShot
	dbra		d7,.nextSprite
	bra			.closeDMA

.sprDrawXtraSht
    ;  d2=y-position, d4 = x-position
;	#MARK: sprite control words xtra shot


	move		#-playerShotHeight-1,d3								; check if sprites overlap
	sub.b		-(playerShotHeight+1)*spriteLineOffset(a3),d3
	add			d2,d3												; <0 if overlap

	smi			d3
	sub.w		d3,d2												; +1 to ypos if overlap

	; optimised sprite write, cope with non-PAL area only
	clr.b		d3
	moveq		#playerShotHeight,d1
	add.w		d2,d1												; y stop position

	lsl.w		#8,d2												; move vertical start bit 8 in place
	addx.b		d3,d3
	lsl.w		#8,d1												; vertical stop bit 8
	addx.b		d3,d3
	lsr.w		#1,d4												; horizontal start bit 0
	addx.b		d3,d3
	add.b		#$30,d4
	move.b		d4,d2												; make first control word
	move.b		d3,d1
	move.w		d2,(a3)												; SPRxPOS
	move.w		d1,8(a3)											; SPRxCTL

.offset		SET			spriteLineOffset


	movem.l		(a2)+,d1-d4											; get one scanline
	cmp.l		.offset(a3),d1
	beq			.keepPixelsXtra
			;bra .keepPixelsXtra
				; write 4 scanlines * 4 times

	move.l		d1,.offset(a3)
	move.l		d2,.offset+8(a3)
	move.l		d3,.offset+16(a3)
	move.l		d4,.offset+24(a3)

	REPT		11
	movem.l		(a2)+,d1-d4
.offset		SET			.offset+spriteLineOffset*2
	move.l		d1,.offset(a3)
	move.l		d2,.offset+8(a3)
	move.l		d3,.offset+16(a3)
	move.l		d4,.offset+24(a3)
	ENDR
.keepPixelsXtra
	adda.w		#(playerShotHeight+1)*spriteLineOffset,a3
	dbra		d7,.nextSprite
	bra			.closeDMA

	;	#MARK: sprites 8 px height
.coll8Overlap
	btst.b		#0,frameCount+5(pc)
	beq			.endLoop
	move		#spriteLineOffset*(spriteDMAHeight+1),d3
	move		d5,d1										; restore current offset to dma table
	sub.w		d3,d1										; sub one line
	sub.w		d3,d1
	tst.b		.sprModifiedFlag(a6,d1)
	beq			.overwrite4pxSpriteB
	sf.b		.sprModifiedFlag(a6,d5)						; old sprite = 8px, modify pointers
	sub.w		d3,d5
	sub.w		d3,d5
	bra			.skipAddBigg
.overwrite4pxSpriteB
	; 4px sprite has already been stored, replace it with 8px sprite
	sub.w		d3,d5
	add.w		d3,(a0,d0*2)
	bra			.skipAddBigg

.sprPause		; pause message
	lea			spritePause(pc),a2
	bra			.bullet8Draw
.sprInstSpwn		; post kill quick resume sprite
	lea			spriteInstaSpawn(pc),a2
	clr.w		d1
	move.b		plyBase+plyFire1Flag(pc),d1
	tst.w		d1
	beq			.idleAnim
	move.w		d1,d3
	lsr			#3,d1
	lsr			#5,d3
	sub.w		d3,d1
	lsl			#6,d1

	tst.w		transitionFlag(pc)							; cap anim frame number as it would too high with wipe transition
	beq			.instSpwnAnim
	move.w		#19<<6,d1
.instSpwnAnim
	lea			(a2,d1.w),a2
	bra			.bullet8Draw
.idleAnim
	move.w		frameCount+2(pc),d1
	lsl			#4,d1
	andi.w		#%10000000,d1
	bra			.instSpwnAnim
.sprTutSpeedA		; speedup tutorial icon
	lea			spriteTutorial8pixels(pc),a2
	add.w		plyBase+plyPosXDyn(pc),d4			; add x-scroll-offset
	bra.b		.bullet8Draw
.sprTutSpeedB
	lea			spriteTutorial8pixels+64(pc),a2
	add.w		plyBase+plyPosXDyn(pc),d4
	bra.b		.bullet8Draw
.sprTutPowerUpA		; powerup tutorial icon
	lea			spriteTutorial8pixels(pc),a2
	add.w		plyBase+plyPosXDyn(pc),d4
	bra.b		.bullet8Draw
.sprTutPowerUpB
	lea			spriteTutorial8pixels+128(pc),a2
	add.w		plyBase+plyPosXDyn(pc),d4
	bra.b		.bullet8Draw
.sprBullet8A
	lea			spriteBullet8(pc),a2
	bra.b		.bullet8Draw
.sprBullet8B
	lea			spriteBullet8+8*8(pc),a2
	bra.b		.bullet8Draw
.sprBullet8C
	;move frameCount+2(pc),d1
	;add d7,d1	; add some dynamix to animation
	move		d2,d1
	lsr			#2,d1

	andi		#7,d1
	move.l		(spriteAnimTableBullet8,pc,d1*4),a2
	bra.b		.bullet8Draw
.sprBonus8A		; wave bonus
	lea			spriteBonus8pixels(pc),a2
	bra.b		.bullet8Draw
.sprBonus8B
	lea			spriteBonus8pixels+64(pc),a2
	bra.b		.bullet8Draw
.sprAlertA		; alert text sprite
	lea			spriteAlert(pc),a2
	bra.b		.bullet8Draw
.sprAlertB		; alert dart southwards
	lea			spriteAlert+128(pc),a2
	bra.b		.bullet8Draw
.sprAlertC		; alert dart westwards
	lea			spriteAlert+256(pc),a2
	bra.b		.bullet8Draw
.sprAlertD		; alert dart northwards
	lea			spriteAlert+64(pc),a2
	bra.b		.bullet8Draw
.sprAlertE		; alert dart eastwards
	lea			spriteAlert+192(pc),a2
	bra.b		.bullet8Draw

.sprChain8A		; chain bonus
	lea			spriteChain8pixels(pc),a2
	bra.b		.bullet8Draw
.sprChain8B		; chain number, adressed indirectly
	move.l		((spriteAnimTableChain).W,pc),a2
.bullet8Draw
	sub			#2,d2
	addq		#1,d0
	andi		#3,d0													; which sprite slot
	move.w		(a0,d0*2),d5											; get current offset

	cmp.w		(a5,d0*2),d2
	ble			.coll8Overlap
	add.w		#2*(spriteLineOffset*(spriteDMAHeight+1)),(a0,d0*2)
.skipAddBigg

.m								MACRO
.fullFilled						SET					0
								IF					.fullFilled=1																																																								; init for test with full filled sprite
								moveq				#-1,d1
								move.l				d1,d3
								ENDIF
								ENDM
	; draw pixels to dma memory
								movem.l				(a2)+,d1/d3
								.m
								move.l				d1,spriteLineOffset(a6,d5)
								move.l				d3,8+spriteLineOffset(a6,d5)
								movem.l				(a2)+,d1/d3
								.m
								move.l				d1,2*spriteLineOffset(a6,d5)
								move.l				d3,8+(2*spriteLineOffset)(a6,d5)
								movem.l				(a2)+,d1/d3
								.m
								move.l				d1,3*spriteLineOffset(a6,d5)
								move.l				d3,8+(3*spriteLineOffset)(a6,d5)
								movem.l				(a2)+,d1/d3
								.m
								move.l				d1,4*spriteLineOffset(a6,d5)
								move.l				d3,8+(4*spriteLineOffset)(a6,d5)
								movem.l				(a2)+,d1/d3
								.m
								move.l				d1,5*spriteLineOffset(a6,d5)
								move.l				d3,5*spriteLineOffset+8(a6,d5)
								movem.l				(a2)+,d1/d3
								.m
								move.l				d1,6*spriteLineOffset(a6,d5)
								move.l				d3,6*spriteLineOffset+8(a6,d5)
								movem.l				(a2)+,d1/d3
								.m
								move.l				d1,7*spriteLineOffset(a6,d5)
								move.l				d3,7*spriteLineOffset+8(a6,d5)
								movem.l				(a2)+,d1/d3
								.m
								move.l				d1,8*spriteLineOffset(a6,d5)
								move.l				d3,8*spriteLineOffset+8(a6,d5)
								IFEQ				.fullFilled
								clr.l				9*spriteLineOffset(a6,d5)
								clr.l				8+(9*spriteLineOffset)(a6,d5)
								ELSE
								.m
								move.l				d1,9*spriteLineOffset(a6,d5)
								move.l				d3,9*spriteLineOffset+8(a6,d5)
								ENDIF
								st.b				.sprModifiedFlag(a6,d5)																																																						; set modified flag in 2nd spriteslot
								moveq				#9,d1																																																										; modify height
								bra					.makeControlWordsAlt																															



;	#MARK: sprites 4 px height
.bulletBasicX1
	st.b		.sprModifiedFlag(a6,d5)
	lea			spriteBullet4Xpixels(pc),a2
	bra			.bulletDraw
.bulletBasicX2
	st.b		.sprModifiedFlag(a6,d5)
	lea			spriteBullet4Xpixels+(spriteBullet4XpixelsSize/2)(pc),a2
	bra			.bulletDraw

.bulletOverlap
	btst.b		#0,frameCount+5(pc)
	beq			.endLoop													; draw new sprite only every 2nd frame, else keep old sprite
	move		#spriteLineOffset*(spriteDMAHeight+1),d3
	move		d5,d1
	sub.w		d3,d1
	sub.w		d3,d1
	tst.b		.sprModifiedFlag(a6,d1)
	bne			.overwriteBigSprite
	sub.w		d3,d5
	bra			.skipAdd
.overwriteBigSprite	; old sprite = 8px, modify pointers
	sf.b		.sprModifiedFlag(a6,d5)
	sub.w		d3,(a0,d0*2)												; modify pointer to next sprite dma init
	sub.w		d3,d5
	sub.w		d3,d5
	bra			.skipAdd

	sub.w		#1*(spriteLineOffset*(spriteDMAHeight+1)),d5
	tst.b		.sprModifiedFlag(a6,d5)
	bpl			.skipAdd
	sub.w		#1*(spriteLineOffset*(spriteDMAHeight+1)),d5
	bra			.skipAdd
.bulletBasic
    ;lea spriteBullet4pixels(pc),a2
	lea			spriteLineOffset(a6),a2
.bulletDraw
	addq		#1,d0
	andi		#3,d0														; which sprite slot
	move.w		(a0,d0*2),d5												; get current offset

	cmp.w		(a5,d0*2),d2
	ble			.bulletOverlap
.shotDraw
	add.w		#spriteLineOffset*(spriteDMAHeight+1),(a0,d0*2)
.skipAdd
	move.l		(a2),d1
	move.l		8(a2),d3											; get one line
	;move.l ,d3
	cmp.l		spriteLineOffset(a6,d5),d1
	bne			.draw
	cmp.l		spriteLineOffset+8(a6,d5),d3
	bne			.draw

	tst.b		.sprModifiedFlag(a6,d5)								; tst modified flag
	beq.b		.makeControlWords
.draw
	move.l		d1,spriteLineOffset(a6,d5)
	move.l		d3,spriteLineOffset+8(a6,d5)

	lea			16(a2),a2
	move.l		(a2),d1
	move.l		8(a2),d3											; get next line
	move.l		d1,2*spriteLineOffset(a6,d5)
	move.l		d3,2*spriteLineOffset+8(a6,d5)
	lea			16(a2),a2

	move.l		(a2),d1
	move.l		8(a2),d3											; get next line
	move.l		d1,3*spriteLineOffset(a6,d5)
	move.l		d3,3*spriteLineOffset+8(a6,d5)
	lea			16(a2),a2

	move.l		(a2),d1
	move.l		8(a2),d3											; get next line
	move.l		d1,4*spriteLineOffset(a6,d5)
	move.l		d3,4*spriteLineOffset+8(a6,d5)
.makeControlWords
    ;    d6 = height, d2=y-position, d4 = x-position
;	#MARK: sprite make control words
	sf			.sprModifiedFlag(a6,d5)
	move		d6,d1
.makeControlWordsAlt
	add.w		d2,d1												; y stop position

	move		d1,(a5,d0*2)										; save y stop for later compare

	clr.b		d3

	lsl.w		#8,d2												; move vertical start bit 8 in place
	addx.b		d3,d3

	lsl.w		#8,d1												; vertical stop bit 8
	addx.b		d3,d3

	lsr.w		#1,d4												; horizontal start bit 0
	addx.b		d3,d3
	add.b		#$30,d4
	move.b		d4,d2												; make first control word
	move.b		d3,d1												; second control word

	move.w		d2,(a6,d5)											; SPRxPOS
	move.w		d1,8(a6,d5)											; SPRxCTL

	IFNE		DEBUG
	move.l		spriteDMAMem+8(pc),d1
	lea			(a6,d5),a2
	cmp.l		d1,a2
	bls			spriteManagerError
	lea			9*spriteLineOffset+8(a6,d5),a2
	cmp.l		d1,a2
	bls			spriteManagerError

	add.l		#spriteDMAMemSize,d1
	lea			(a6,d5),a2
	cmp.l		d1,a2
	bhi			spriteManagerError
	lea			9*spriteLineOffset+8(a6,d5),a2
	cmp.l		d1,a2
	bhi			spriteManagerError
	ENDIF
.endLoop
	dbra		d7,.nextSprite

.closeDMA	; attn: this marks entry point after ply shot draw

	clr.l		(a3)							; close dma channel sprite 0
	clr.l		8(a3)
	clr.l		(a4)							; close dma channel sprite 1
	clr.l		8(a4)

	move.w		#spriteDMAListOffset,d0
	movem.l		(a0),d0-d1
	clr.l		(a6,d0)							; close dma channel sprites 2-5
	clr.l		8(a6,d0)						; close dma channel sprites 2-5
	swap		d0
	clr.l		(a6,d0)
	clr.l		8(a6,d0)						; close dma channel sprites 2-5
	clr.l		(a6,d1)
	clr.l		8(a6,d1)
	swap		d1
	clr.l		(a6,d1)
	clr.l		8(a6,d1)

.quit
	IFNE		DEBUG
	move.l		spritePlayerDMA+16(pc),a5		; check for memory under / overflow in player shots
	cmpa.l		a3,a5							; underflow
	bhi			.overFlow
	cmpa.l		a4,a5
	bhi			.overFlow

	lea			spritePlayerDMASize(a5),a5
	tst.l		a3
	beq			.overflow
	cmpa.l		a3,a5							; overflow
	bls			.overFlow
	tst.l		a4
	beq			.overflow
	cmpa.l		a4,a5
	bls			.overFlow

	move.l		spriteDMAMem+8(pc),a4			; check for memory under / overflow in enemy bullets
	lea			spriteDMAMemSize(a4),a5
	move.w		(a0)+,d6
	cmpi.w		#spriteDMAListOffset*4,d6
	bhi			.overflow
	lea			(a6,d6),a3
	cmpa.l		a3,a4
	bhi			.underflow
	cmpa.l		a3,a5
	bls			.overFlow

	move.w		(a0)+,d6
	cmpi.w		#spriteDMAListOffset*4,d6
	bhi			.overflow
	lea			(a6,d6),a3
	cmpa.l		a3,a4
	bhi			.underflow
	cmpa.l		a3,a5
	bls			.overFlow

	move.w		(a0)+,d6
	cmpi.w		#spriteDMAListOffset*4,d6
	bhi			.overflow
	lea			(a6,d6),a3
	cmpa.l		a3,a4
	bhi			.underflow
	cmpa.l		a3,a5
	bls			.overFlow

	move.w		(a0),d6
	cmpi.w		#spriteDMAListOffset*4,d6
	bhi			.overflow
	lea			(a6,d6),a3
	cmpa.l		a3,a4
	bhi			.underflow
	cmpa.l		a3,a5
	bls			.overFlow
	ENDIF
	rts
					IFNE		DEBUG
.underflow
.overflow
spriteManagerError
					IFNE		SHELLHANDLING
					jsr			shellSpriteDMAMemError
					ENDIF
					QUITNOW
					ENDIF

spriteAnimTableChain
					dc.l		spriteChain8pixels+64

spriteAnimTableBullet8
.tempVal			SET			2*8*8
					REPT		8
					dc.l		spriteBullet8+.tempVal
.tempVal			SET			.tempVal+(8*8)
					Endr

spriteWriteLastYPos
					blk.w		4,0
spriteDMAListDynOffsets	; 4 x store.w for sprite dma pointers. Reset values stored in upper two longwords
					dc.l		0
					dc.w		0,0,0,0
.tempA				SET			(spriteLineOffset*(spriteDMAHeight+1))*1
.tempB				SET			spriteDMAListOffset
					dc.w		.tempA
					REPT		3
.tempA				SET			.tempA+.tempB
					dc.w		.tempA																											; setup static source table
					ENDR

					cnop		0,4
spriteBullet8	; export as 32px wide sprites, not attached, no control words. 2 spawn frames, 8 rotate frames
					Incbin		incbin/bullet8
					cnop		0,4

spriteBonus8pixels	; export as 32px wide sprites, 16 px high, not attached, no control words
					Incbin		incbin/collect_wave.raw
					cnop		0,4
spriteChain8pixels	; text "chain" + 4 numbers as sprites, 32 px wide, 40 px high, not attached, no control words
					Incbin		incbin/collect_chain.raw
					cnop		0,4
spriteTutorial8pixels	; save as sprite, 32 px wide, 24 px high, not attached, no control words
					Incbin		incbin/collect_tutorial.raw
spriteInstaSpawn	; save as sprite, 32 px wide, not attached, no control words
					Incbin		incbin/instSpwn.raw
spritePause	; save as sprite, 32 px wide, not attached, no control words
					Incbin		incbin/pause.raw
spriteAlert	; save as sprite, 32 px wide, 16 px high, not attached, no control words. ? Anim frames
					Incbin		incbin/alert.raw

spriteBullet4pixels ; export as 16px wide sprites, not attached, no control words
					INCBIN		incbin/bullet

					cnop		0,4
spriteBullet4Xpixels ; export as 32px wide sprites, not attached, no control words
					Incbin		incbin/bulletSpawn
spriteBullet4XpixelsSize	=	*-spriteBullet4Xpixels

spritePlayerShot	; export as 32px sprites, not attached, no control
					Incbin		incbin/player/weapon.raw
;    Incbin incbin/player/weapons_0a.raw
spritePlayerShotEnd
;	#MARK: SPRITE MANAGER ENDS
