
	; #MARK: - Radial Laser Shot

	; radial laser shot
circLsrA
	clr.w d0
	move.b objectListTriggersB(a2),d0
	beq .setDirection
	;btst #0,objectListCnt(a2)
	;seq d4

	;beq objectListNextEntry
	;andi.w #32,d4
	;add.w d4,d0

	lea -2(a0,d0.w*2),a0
	;bra animReturn
	lea killBounds(pc),a1
	bra killCheck
.setDirection

	move.w objectListAccX(a2),d6
	asr.w #5,d6

	spl d5
	andi.b #$1f,d5
	add.w #$10,d6
	cmpi.b #32,d6
	scc.b d4	;-1 if out of range
	and.b d4,d5
	not.b d4
	and.b d4,d6
	or.b d5,d6
	andi #$1f,d6
	move d6,d7

	move.w objectListAccY(a2),d6
	move d6,d5
	;divu #22,d6
	asr.w #5,d6
	;sub #1,d6
	;asr.w #4,d5
	;add.w d5,d6

	move.l viewPosition+viewPositionAdd(pc),d5
	move.l d5,d4
	lsl.l #2,d5
	lsl.w #1,d4
	add.w d4,d5	; *12
	swap d5
	not d5
	add d6,d5

	spl d4
	andi.b #$1f,d4
	add.w #$11,d5
	cmpi.b #$20,d5
	scc.b d0	;-1 if out of range
	and.b d0,d4
	not.b d0
	and.b d0,d5
	or.b d4,d5
	andi #%11111,d5
	lsl #5,d5
	add.w d5,d7
.anim
	clr.w d4
	move.b (tanTable.w,pc,d7),d4
	andi #$1f,d4
	seq d0
	andi.b #1,d0
	or.b d0,d4
	move.b d4,objectListTriggersB(a2)
	bra objectListNextEntry

	; #MARK: - Hunter Missile


huntMisl
	tst.w objectListTriggersB(a2)
	beq .init
	bra .cont
.init
	lea	fastRandomSeed(pc),a3
	movem.l  (a3),d4/d5					; AB
	swap    d5						; DC
	add.l   d5,(a3)					; AB + DC
	add.l   d4,4(a3)				; CD + AB
	lsr.w #8,d4
	lsr.w #3,d4
	sub.w #16,d4
	swap d4
	lsr.w #8,d4
	lsr.w #3,d4
	sub.w #16,d4
	move.l d4,objectListTriggersB(a2)
	bra .cont
.cont

	move.w objectListAccX(a2),d6
	asr.w #5,d6
	spl d5
	andi.b #$1f,d5
	add.w #$12,d6
	cmpi.b #32,d6
	scc.b d4	;-1 if out of range
	and.b d4,d5
	not.b d4
	and.b d4,d6
	or.b d5,d6
	andi #$1f,d6
	move d6,d7

	move.w objectListAccY(a2),d6
	move d6,d5
	asr.w #6,d6
	asr.w #5,d5
	add.w d5,d6

	move.l viewPosition+viewPositionAdd(pc),d5
	move.l d5,d4
	lsl.l #3,d5
	lsl.w #1,d4
	add.w d4,d5	; *12
	swap d5
	not d5
	add d6,d5

	spl d4
	andi.b #$1f,d4
	add.w #$14,d5
	cmpi.b #$20,d5
	scc.b d0	;-1 if out of range
	and.b d0,d4
	not.b d0
	and.b d0,d5
	or.b d4,d5
	andi #%11110,d5
	lsl #5,d5
	add.w d5,d7
.anim
	clr.w d4
	move.b (tanTable.w,pc,d7),d4



	btst #0,objectListCnt(a2)
	sne.b d0
	andi.b #64,d0
	add.b d0,d4
	lea (a0,d4),a0

	tst.b objectListTriggers(a2)	; target player?
	beq .quitCode
	lea plyPos(pc),a1

	SAVEREGISTERS

	move.w #$108,d0
	move.w #$50,d1
	clr.w d3
	move.l objectListTriggersB(a2),d6
	move.w plyRemXPos+12(a1),d4
	sub.w objectListX(a2),d0
	sub.w plyPosXDyn(a1),d0
	sub.w d6,d0
	swap d6
	add.w objectListY(a2),d1
	add.w d4,d0

	bpl .allGoodD0
	clr.w d0
.allGoodD0
	add.w d6,d1

	sub.w plyPosY(a1),d1
	bpl .allGoodD1
	clr.w d1
.allGoodD1
	lsl #1,d0

	move d1,d2
	asr #2,d2
	sub.b d2,d1; modify y-scalator to optimize targeting
	bpl .limitYRange
	move #$7f,d1
.limitYRange
	cmpi #$40,d1
	scc d5
	andi #$7f,d5
	eor.w d5,d1	; values 0-$3f-0 (up-center-down)

	cmpi #$80,d0
	scc d3
	andi #$fe,d3
	eor.w d3,d0	; values 0-$3f-0 (left-center-right)
	;bcc .overFlow
	tst.b d0
	bpl .ddd
.overFlow
	clr.w d0
.ddd
	cmpi.w #$ff,d0
	bcs .ddddd
	clr.w d0
.ddddd
	lsl #7,d1	; kill bit 0

	add d1,d0	; add y-row to x-column / table pointer
	clr.l d1
	move.w (bulletVectorsMed,pc,d0.w),d1

	clr.l d2
	move.b d1,d2	; x
	lsr.w #8,d1		; y

	tst.b d3
	seq d3
	ext.w d3
	ext.l d3
	eor.l d3,d1

	tst.b d5
	sne d5
	ext.w d5
	ext.l d5
	eor.l d5,d2


	move.w plyAcclXCap(a1),d5
	move.w d5,d6
	lsl #5,d5	; 	*32
	lsl.w #4,d6	;	*8
	add.w d6,d5	;	=*40

	move.w objectListAccX(a2),d4
	tst.w d4
	bpl .eastBound	;	bullet moves right? Yes!
	tst.w d1	; bullet goes left. Accelerate right?
	bpl .addX	;	Just do, no further examination
	neg d5
	cmp.w d5,d4	; accelerate right.
	bcc .addX	; acceleration lower than max?
	bra .s1		; acceleration higher than max, skip further acceleration
.eastBound
	tst.w d1	; bullet moves right
	bmi .addX	; accelerate left? Do!
	cmp.w d5,d4	; d0 < 0
	bcc .s1
.addX
	asr.w #3,d1
	add.w d1,objectListAccX(a2)
.s1

	move.w plyAcclYCap(a1),d5
	move.w d5,d6
	lsl #5,d5	; 	*32
	lsl.w #4,d6	;	*8
	add.w d6,d5	;	=*40

	move.w objectListAccY(a2),d4
	tst.w d4
	bpl .southBound	;	bullet moves right? Yes!
	tst.w d2	; bullet goes left. Accelerate right?
	bpl .addY	;	Just do, no further examination
	neg d5
	cmp.w d5,d4	; accelerate right.
	bcc .addY	; acceleration lower than max?
	bra .s2		; acceleration higher than max, skip further acceleration
.southBound
	tst.w d2	; bullet moves right
	bmi .addY	; accelerate left? Do!
	cmp.w d5,d4	; d0 < 0
	bcc .s2
.addY
	asr.w #3,d2
	add.w d2,objectListAccY(a2)
.s2
	RESTOREREGISTERS
	bra animReturn

.quitCode
	lea .bounds(pc),a1
	lea killBounds(pc),a1
    bra killCheck
.bounds
	dc.w $30,330
	dc.w $08,$f0
