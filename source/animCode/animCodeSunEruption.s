

	; #MARK: - Animate Sun Eruption

;May use d0,d4,d5,d6,d7,a1,a3


	; ATTN uses tempVar+12 to store 4 longwords
	; add code trig1025 in animlist to prevent mirroring
	; add code trig1024 in animlist to permit mirroring
	; add code trig1281 in animlist to allow 1 frame animation

sunAnIdl
	move.b objectListCnt(a2),d7
	ext.w d7
	move.b d7,d6
	lsr.b #2,d6
	lsr.b #3,d7
	add.b d6,d7
	andi #$3<<2,d7
	move.w d7,d6
	lsr #1,d7
	add.w d6,d7
	lea (a0,d7.w),a0

sunErupt
	SAVEREGISTERS
	tst.b plyBase+plyWeapUpgrade(pc)
	bmi .playerDies	; is dying while reaching exit?

	;move.b objectListTriggers(pc),d0
	move.b objectListTriggers(a2),d0
	tst.b objectListTriggers(a2)
	bne .outaHere
	lea objectDefSize(a4),a4	; get and prepare next object in display chain
	;move.w objectListX(a2),d7

	tst.b objectListTriggers+2(a2)
	beq .sunFlare
	cmpi.w #210,objectListX(a2)
	sle d7
	bra .contMirror
.sunFlare
	cmpi.w #110,objectListX(a2)
	sge d7
.contMirror
	tst.b d7
	bne .objectEastBound
	tst.b objectDefScore(a4)	; ready for leftside position?
	bne .mirrorThis
	bra .outaHere
.objectEastBound
	tst.b objectListTriggers+1(a2)
	sne d0
	andi.w #objectDefSize,d0
	lea (a4,d0),a4
	tst.b objectDefScore(a4)
	beq .mirrorThis
	bra .outaHere
.mirrorThis
	move.l (a4),a0
	adda.l bobSource-vars(a5),a0
	;move.w objectListX(a2),d0

	clr.l d0
	move.b objectListCnt(a2),d0
	cmpi.b #9,d0	; range 1-8. Will never be 0!
	bcc .outaHere
	move.l	#$0f0f0f0f,a3
	move.l	#$55555555,d3
	move.l	#$33333333,d2

	clr.w d6
	move.b objectDefHeight(a4),d6       ; bob-Width in pixels
	move d6,d5
	lsr #3,d6	; 1/8 of height
	lsl #2,d6	; *4 for 4 bitmaps

	cmpi.b #8,d0
	bne .firstPassAddRow	; bugfix to prevent visual glitch
	add.b #1,d6
.firstPassAddRow

	clr.w d4
	move.b objectDefWidth(a4),d4
	muls d4,d5
	lsr #3,d5	; 1/8 of total no. of object mem footprint
	sub #1,d0
	bne .setDirectionFlag
	move.b d7,objectDefScore(a4)	; Last mirror action? Set flag!
.setDirectionFlag
	muls d0,d5
	lea (a0,d5.w),a1
	bra .outerLoop
.doRows
	lea tempVar+12,a6
	movem.l (a1),d0/d4/d5/d7	; load upto 128 Pixels width
	movem.l d0/d4/d5/d7,(a6)
	clr.w d5
	move.b objectDefWidth(a4),d5       ; bob-Width in pixels
	lsr #4,d5
	move d5,d0
	lsl #2,d0
	lea (a1,d0),a1	; modify source pointer
	move.l a1,a2	;
	bra .loop
.doSingleRow
	move.l (a6)+,d0
	beq .emptyRow
	move.l d3,d1
	and.l    d0,d1
	eor.l    d1,d0
	add.l    d1,d1
	lsr.l    #1,d0
	or.l     d1,d0

	move.l d2,d1
	and.l    d0,d1
	eor.l    d1,d0
	lsl.l    #2,d1
	lsr.l    #2,d0
	or.l     d1,d0

	move.l a3,d1
	and.l    d0,d1
	eor.l    d1,d0
	lsl.l    #4,d1
	lsr.l    #4,d0
	or.l     d1,d0

	rol.w    #8,d0
	swap     d0
	rol.w    #8,d0
.emptyRow
	move.l d0,-(a2)
.loop
	dbra d5,.doSingleRow
.outerLoop
	dbra d6,.doRows
.outaHere
	RESTOREREGISTERS
	bra animReturn
.playerDies
	move.b #255,objectListCnt(a2)	; stop animating, to prevent display corruption
	move.l objectListMyParent(a2),a2
	tst.l a2
	beq .outaHere
	clr.l objectListAccY(a2)
	bra .outaHere

	; #MARK: - Handlign Triceratops
tricrMng
	tst.b objectListTriggers+3(a2)
	sne d0
	andi.w #2,d0
	sub.w d0,a0
	bra sunErupt
