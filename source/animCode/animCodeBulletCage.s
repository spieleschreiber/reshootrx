

	; #MARK: - bulletCage formerly known as eyeRoid
	;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter bitmap load adress or use a0 if return to bobblitnext / not animreturn
bultCage
	; triggers+0		bit0	trig1024=swinging anim, 1025=flyby anim
	;					bit1	trig1024=shotStream	1026=shotWhenHit
	; triggers+1		bullet frequency: trig1280=lot - 1283=not so much
	;	code 	trig1280	(every 2nd frame)
	;	...
	;	code	trig1283	(every 32nd frame, half a second)

	; triggers+2		bullet direction 0 (trig1536)=at player,trig1537=north,trig1568=west, trig1600=south, trig1632=east

	add.b #1,objectListTriggersB(a2)
	move.w objectListY(a2),d0
	sub.w viewPosition+viewPositionPointer(pc),d0
	move.w d0,d4
	btst #0,objectListTriggers(a2)
	bne.b .basicAnim
	move.b objectListTriggersB(a2),d0
	lsr #3,d0
	btst #3,d0
	sne d4
	andi.b #$7,d4
	eor.b d4,d0	; animation frames 0->7->0
	andi.w #$07,d0
	bra .setB
.basicAnim
	add.w #50,d0	; flyby anim
	divu #38,d0
.setB
	move.b d0,objectListTriggersB+1(a2)
	move.w d0,d5
	lsl #2,d0
	add.w d5,d0
	add.w d5,d0
	lea (a0,d0),a0	; animate
	moveq #39,d7
	add.w d4,d7
	cmpi #$105,d7
	bcc .q	; object reached south bounds? stop shooting

	btst #1,objectListTriggers(a2)
	beq .bulletStream
	move.w objectListHit(a2),d7
	lsr #2,d7
	lea objectListTriggersB+2(a2),a1

	tst.w (a1)
	beq .firstInit
	cmp.w (a1),d7
	beq animReturn
	move.w d7,(a1)
	bra .initBullet
.firstInit
	move.w d7,(a1)
	bra animReturn
.bulletDirection
	lea (.retB,pc),a5
	move.l objectListTriggersB(a2),-(sp)
	move.l objectListTriggers(a2),-(sp)
	move.l a2,-(sp)
	;sf.b objectListTriggers+1(a2)	; workaround for stSpiral code, as this byte needs to be 0
	move.l a2,a6
	move.b objectListTriggers+3(a2),d5
	move.b #0,objectListTriggers(a2)
	move.b #0,objectListTriggers+1(a2)
	move.b #3,objectListTriggers+3(a2)
	move.b d5,objectListTriggersB(a2)
	bra stSpiral
.retB
	move.l (sp)+,a2
	move.l (sp)+,objectListTriggers(a2)
	move.l (sp)+,objectListTriggersB(a2)

	bra .ret
.bitwise
	dc.b 3,7,$f,$1f
	even
.bulletStream
		move.b objectListTriggersB(a2),d7	; launch bullets
		move.b objectListTriggers+1(a2),d5
		ext.w d5
		move.b .bitwise(pc,d5.w),d5
		and.b d5,d7
		bne .q
.initBullet
	movem.l d1-d3/a0/a4-a6,-(sp)
	move.b objectListTriggers+2(a2),d0
	bne .bulletDirection
	lea (.retHome,pc),a5
	move.l a2,a6
	bra homeShot
.retHome
	add.w #14,objectListY(a4)
.ret
	tst.l d6
	bmi .skip
	move.b objectListTriggersB+1(a2),d0
	ext.w d0
	move.b .posOffset(pc,d0.w),d5
	ext.w d5
	move.w d5,d6
	sub.w d5,objectListX(a4)
	sub.w #5,d6
	add.w d6,objectListY(a4)
	jsr FASTRANDOM_A1
	asr.w objectListAccX(a4)
	moveq #8,d6
	asr.w objectListAccY(a4)
	asr.w d6,d4
	add.w d4,objectListAccX(a4)
	asr.w d6,d5
	add.w d5,objectListAccY(a4)
	;PLAYFX 16
	move.l a4,a1
   	movem.l (sp)+,d1-d3/a0/a4-a6
	bsr modifyObjCountAnim
.q	lea killBounds(pc),a1
	bra killCheck	; check exit view

.skip
   	movem.l (sp)+,d1-d3/a0/a4-a6
	bra animReturn
.posOffset
	dc.b 11,9,6,1,-2,-4,-8,-11
