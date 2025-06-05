

    ;	#MARK: - Kraken Animation

krakenSmall
	move.b objectListTriggers(a2),d7
	bne .basicAnimation
	;bra krakenamoeb

	IFNE 0
	move.w objectListAccY(a2),d7
	lsr #1,d7
	andi.w #$f,d7
	lea (a0,d7*2),a0
	bra animReturn
	ENDIF
	move.l objectListAcc(a2),d7    ; get x- and y-acceleration

	move.w viewPosition+vPyAccConvertWorldToView(pc),d0
	sub.w d7,d0 ; convert to y-acceleration in view
	;add #27,d0
	;clr.w d0
	swap	d7
	;smi d6
	;ext.w d6
	;eor.w d6,d7

	; horizontal animation
	move.w	d7,d6
	;tst.w objectListAccX(a2)
.ret
	add.w	d0,d6
	smi		d6
	sub.w	d0,d7
	smi		d7
	eor.b	d7,d6

	move d6,d7
	andi #32,d6
	not d7

	andi #2,d7
	move.b objectListAcc+1(a2,d7),d7
	lsr.b #3,d7

	add.b d6,d7	; add y-frames to x-frames
	lea (a0,d7),a0

	btst.b #attrIsKillBorderExit,objectListAttr(a2)	; killcheck bit set?
	beq animReturn	; no
	lea killBounds(pc),a1
	bra killCheck
.basicAnimation
	btst #0,d7
	seq d6
	ext.w d6
	clr.w d7
	sub.w frameCount+2(pc),d7
	add.w a2,d7
	eor.w d6,d7
	asr #1,d7
	andi.w #$1f,d7
	lea 32(a0,d7),a0
	lea killBounds(pc),a1
	bra killCheck
	bra .ret
krakenAmoeb
	move.l objectListAcc(a2),d7    ; get x- and y-acceleration
	move.w viewPosition+vPyAccConvertWorldToView(pc),d0
	sub.w d7,d0 ; convert to y-acceleration in view
	swap	d7

	sub.w	d0,d7
	smi		d7
	not d7

	andi #2,d7
	move.b objectListAcc+1(a2,d7),d7
	lsr.b #3,d7

	lea (a0,d7),a0
	lea killBounds(pc),a1
	bra killCheck

krakenSpiker
	move.l objectListX(a2),d6
	swap d6

	tst.w objectListAccX(a2)
	beq .zeroXAcc
	sne d5
	ext.w d5
.updateBitmap
	move.w frameCount+2(pc),d0
	eor.w d5,d0
	add.w d0,d6

	andi #$7<<2,d6
	lea (a0,d6.w),a0
	lea killBounds(pc),a1
	bra killCheck
.zeroXAcc	; rotation synced to screenposition
	cmpi.w #$130,objectListX(a2)
	scc d5
	bra .updateBitmap
