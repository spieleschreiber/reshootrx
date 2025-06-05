

	; #MARK: -
	;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter bitmap load adress or use a0 if

tilterXX

	tst.b objectListTriggers+3(a2)
	bne .shoot
	move objectListAccX(a2),d6
	asr #5,d6
.anim
	andi #$1f,d6
	move.b ((.offset).w,pc,d6.w),d6
	lea (a0,d6.w),a0 
	bra animReturn
.shoot
	add.b #1,objectListTriggersB+1(a2)
	move.b objectListTriggersB+1(a2),d6
	lsr #1,d6
	bra .anim
.offset
	dc.b 	4*0,4*0,4*1,4*1,4*2,4*3,4*4,4*5
	dc.b	4*6,4*7,4*8,4*9,4*10,4*10,4*11,4*11
	dc.b 	4*11,4*10,4*10,4*9,4*8,4*7,4*6,4*5
	dc.b 	4*4,4*3,4*2,4*2,4*1,4*1,4*1,4*0
	even

tilterFV
	move.w #114,d0
	add.w plyBase+plyPosX(pc),d0
	sub.w plyBase+plyPosXDyn(pc),d0
	move.w objectListX(a2),d6
	sub.w d0,d6
	tst.b objectListTriggers+3(a2)
	bne .accelerate
.retAccl
	asr #4,d6
	tst.w d6
	bpl .farLeft
	clr.w d6
.farLeft
	cmpi.w #10,d6
	blt .farRight
	move.w #10,d6
.farRight
	lea (a0,d6.w*4),a0
	lea killBounds(pc),a1
	bra killCheck
.accelerate
	move.w objectListX(a2),d0	; get exit x-accl related to x-pos player
	sub.w	plyBase+plyPosX(pc),d0
	sub.w #$a9,d0
	asl #1,d0
	move.w d0,objectListAccX(a2)
	sf.b objectListTriggers+3(a2)
	bra .retAccl
