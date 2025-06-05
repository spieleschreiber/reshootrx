

    ;	#MARK: - boss Roid, boneSnake
        ;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter bitmap load adress or use a0 if return to bobblitnext / not animreturn

boneSnke
	tst.b objectListTriggersB(a2)
	beq .randomizeXAcc
.ret
    move.l objectListMyChild(a2),a1
    tst.l a1
    beq .skipAnim
    move.l objectListMyChild(a1),a1
    move.l objectListMyChild(a1),a1	; get adress of last tail object
    move.w objectListX(a1),d0
	move.b .boneSnakeAnimOffset+2(pc,d0.w),d0
	ext.w d0
    lea (a0,d0),a0
.skipAnim
	lea .killBounds(pc),a1
	bra killCheck
.randomizeXAcc
	lea	fastRandomSeed(pc),a1
	movem.l  (a1),d0/d4					; AB
	swap    d4						; DC
	add.l   d4,(a1)					; AB + DC
	add.l   d0,4(a1)				; CD + AB
	andi #$ff,d0
	ext.w d0
	asr #1,d0
	move #$130,d4		; center x position
	sub.w objectListX(a2),d4
	asr #1,d4
	add.w d4,d0
	move.w d0,objectListAccX(a2)
	st.b objectListTriggersB(a2)
	bra .ret
.killBounds
	dc.w $88,$1d0
	dc.w -$60,$110
.boneSnakeAnimOffset
	dc.b 8,4,4,4,0,0

boneSnkB
	bra animReturn
	move.w objectListX(a2),d0
	add #2,d0
	lea (a0,d0*2),a0
	bra animReturn
