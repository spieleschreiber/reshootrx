

	;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter bitmap load adress or use a0 if return to bobblitnext / not animreturn

	;	#MARK: Scroll Controller
;	toggle active scrolling (trigger 0)
	; 	trig1025	to initiate scroll modification

;	restartCondition (trigger 1)
	;	trig1282	re-start if < 2 active object
	;	trig1284	re-start if < 3 active object
	;	trig1286	re-start if < 4 active object
	;	trig1288	re-start if < 5 active object
	;	trig1290	re-start if < 6 ...

;	targetPace (trigger 2)
	;	trig1536 	slow down to halt
	;	trig1537 	accelerate to 1/16 pace
	;	trig1538 	accelerate to 1/8 pace
	;	trig1539 	accelerate to 1/4 pace
	;	trig1540 	accelerate to 1/2 pace
	;	trig1541 	keep basic pace
	;	trig1542 	accelerate to 2x pace
	;	trig1543 	accelerate to 4x pace
	;	trig1544 	accelerate to 8x pace

	;	trig1545 	accelerate to 1/16 pace back
	;	trig1546 	accelerate to 1/8 pace back
	;	trig1547 	accelerate to 1/4 pace back
	;	trig1548 	accelerate to 1/2 pace back
	;	trig1549 	keep basic acceleration
	;	trig1550 	accelerate to 2x pace back
	;	trig1551 	accelerate to 4x pace back
	;	trig1552 	accelerate to 8x pace back

;	postRestartPace (trigger 3)
	; 	this is copied from trigger 3 to trigger 2 if restartCondition = true
	; 	if 0, original scroll speed is triggered
	;	Values are identical to targetPace, for example:
	;	trig1792	accelerate to basic pace
	;	trig1798	accelerate to 2x pace
	;	...
	;	trig1801	accelerate to 1/16 pace back

scrlCtrl
	;lea objectListAnimPtr(a2),a1
	;MSG01 m2,a1
	;move.l objectListMyParent(a2),d0
	;MSG02 m2,d0
	;move.l objectListGroupCnt(a2),d0
	;MSG03 m2,d0
	;move.l frameCount+2(pc),d0
	;MSG03 m2,d0

	clr.l d0
	tst.b plyBase+plyWeapUpgrade(pc)
	bmi objectListNextEntry	; player death scene playing, leave scrolling unmodified

	lea objectListTriggers(a2),a1

	move.b objectListTriggersB(a2),d0
	bne .retriggerScrolling
	tst.b (a1)
	beq .quit	; no scroll modification desired
.modifyScrollPace
	clr.l d5
	clr.w d7

	lea viewPosition(pc),a0
	move #$80,d0
	lsl #2,d0

	move.b 2(a1),d7
	beq .brakeToZero
	move.w .tempScrollDivider-2(pc,d7*2),d7	; get pace and direction values
	move.b d7,d6
	ext.w d6
	ext.l d6
	lsr.w #8,d7
	move.l viewPosition+viewPositionScrollspeed(pc),d5
	lsl.l #4,d5
	asr.l d7,d5
	eor.l d6,d5
	tst.l d6
	bmi .slowDown	; going backwards?

	cmpi.w #4,d7
	bgt .slowDown
	sub.l d0,viewPositionAdd(a0)
	move.l viewPositionAdd(a0),d4
	cmp.l d5,d4
	bgt objectListNextEntry
	bra .target
.slowDown
.brakeToZero
	add.l d0,viewPositionAdd(a0)
	move.l viewPositionAdd(a0),d4
	cmp.l d5,d4
	blt objectListNextEntry
.target
	sf.b (a1)
	move.b 1(a1),d7	; fetch desired number of objects
	lsr.b #1,d7
	move.b d7,objectListTriggersB(a2)
	move.l d5,viewPositionAdd(a0)
	tst.b objectListTriggersB+1(a2)
	bne killObject
.quit
	bra objectListNextEntry
.tempScrollDivider
	dc.b 8,0,7,0,6,0,5,0,4,0,3,0,2,0,1,0
	dc.b 8,-1,7,-1,6,-1,5,-1,4,-1,3,-1,2,-1,1,-1

.retriggerScrolling
	moveq #-1,d4
	add.w objCount(pc),d4
	sub.w shotCount(pc),d4	; number of total objects ./. player bullets
	clr.w d0
	move.b objectListTriggersB(a2),d0	; get desired number of active objects
	beq objectListNextEntry	; if zero, never re-accelerate or if defined in animlist

	cmp.w d4,d0
	bls objectListNextEntry
	move.b 3(a1),d0	; get re-accl value
	seq d7
	andi.b #5,d7	; in case of zero, accel to original pace
	add.b d7,d0
	move.b d0,2(a1)
	st.b (a1)
	sf.b objectListTriggersB(a2)
	st.b objectListTriggersB+1(a2)
	bra objectListNextEntry
