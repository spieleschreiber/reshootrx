
    ;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter bitmap load adress or use a0 if return to bobblitnext / not animreturn
;	spider: 	add trig1025 early in animlist for left handside object


	; trig0	bit 0,2,3	main object orientation. Bit#0 manually switch between 0 = east orientation, 1 = west orientation
	;	bit2 	scarejump forbid flag. Switch to 1 for forbid
	;	bit3	object free fall / grounded flag. 0 = free fall, 1 grounded
	;	trig1	scarejump in progress flag. Do not touch
	;	trig2+3	keep track of animation frame. Do not touch


shellAnim	; animate shell children object, e.g. shell case
	;bra animReturn
	move.l objectListMyParent(a2),a1
	tst.w objectListAccY(a1)
	smi d4
	move.b objectListTriggers+2(a2),d5	; compare actual heading with stored heading
	cmp.b d4,d5	; differs? Modify animation pointer
	bne .switchAnim
	tst.b objectListTriggers+1(a1); scarejump in progress
	bne animReturn
	btst.b #3,objectListTriggers(a1)	; main object on ground?
	beq animReturn	; is free falling

	move.w frameCount+2(pc),d4
	andi.w #8,d4
	lsr #2,d4
	btst.b #0,objectListTriggers(a1)	; parent's  heading is east or west?
	sne d5	; true if west
	ext.w d5
	andi.w #-14,d5
	moveq #10,d6
	add.w d5,d6
	sub.w d6,d4
	move.w d4,objectListX(a2)	; modify case's' x-position
	bra animReturn

.switchAnim
	move.b d4,objectListTriggers+2(a2)
	clr.w d5
;	tst.w objectListAccY(a1)
	;smi d5
	andi.w #16,d4	; head north or south
	btst.b #0,objectListTriggers(a1)	; parent's  heading is east or west?
	sne d5
	andi.w #32,d5
	add.b d5,d4
	;move.b objectListTriggers(a1),d5
	move.l shelRgtAAnimPointer(pc,d4),a3
	move.w animTablePointer+2(a3),d4
	move.w d4,(a2)

	move.b #1,objectListCnt(a2)
	move.b #0,objectListLoopCnt(a2)
	bra animReturn


jmpAtak
	btst.b #2,objectListTriggers(a2); scarejump forbidden by animList?
	bne returnJmpAtak	; yes
	tst.b objectListTriggers+1(a2); scarejump in progress
	bne doScareJmp
	bsr checkProximity
	cmpi.w #scareDetectRange,d0
	bhs returnJmpAtak
	; inititalise scare jmp animation
scareDetectRange 	SET	$80
scarePeriod	SET	35
scareJumpHeight	SET 500
scareJumpBallistic	SET 128
	move.l a0,objectListTriggersB(a2)	; save animation frame
	move.b #scarePeriod,objectListTriggers+1(a2)
	move.w objectListX(a2),objectListTriggersB(a2)
	move.w objectListY(a2),objectListTriggersB+2(a2)
	bra returnJmpAtak
doScareJmp

	move.b objectListTriggers+1(a2),d0
	sub.b #1,objectListTriggers+1(a2)
	bne .scareAnimation
						; init spider jump
	btst.b #0,objectListTriggers(a2)	; 0 -> east orientation object, 1-> west orientation object
	seq d0
	ext.w d0
	move.w #10,d7
	eor.w d0,d7
	add.w d7,objectListX(a2)	; modify x-position a bit to enhance drama
	move #scareJumpHeight,d7	; jump height
	eor.w d0,d7
	move.w d7,objectListAccX(a2)
	bclr.b #3,objectListTriggers(a2)
	move.w objectListY(a2),d7
	move.w plyBase+plyPosY(pc),d0
	cmp.w d0,d7
	sls d7
	ext.w d7
	move.w #scareJumpBallistic*3,d4
	eor.w d7,d4
	move.w viewPosition+viewPositionAdd(pc),d0
	lsl #6,d0	;
	;neg.w d4
	
	sub.w d4,d0
	;add.w #400,d0
	;neg d0
	;eor.w d7,d0
	;clr.w d0
	move.w d0,objectListAccY(a2)
	bra animReturn
.scareAnimation
	move.w objectListTriggersB(a2),objectListX(a2)
	move.w objectListTriggersB+2(a2),objectListY(a2)
	move.w objectListTriggers+2(a2),d0	; fetch last walking animation frame before scare jump animation...
	lea (a0,d0),a0	; ...and repeat
	bra animReturn

spiderControl
	tst.b objectListTriggers+1(a2)	; scare jump in progress? Continue
	bne doScareJmp
	btst.b #3,objectListTriggers(a2)	; main object on ground?
	bne jmpAtak
returnJmpAtak
	move.w objectListX(a2),d0
	move.l mainPlanesPointerAsync(pc),a1
	;move.l mainPlanesPointer+8(pc),a1
	moveq #15,d4
	add.w objectListY(a2),d4
	sub.w viewPosition+viewPositionPointer(pc),d4
	spl d6
	ext.w d6
	and.w d6,d4	; negative y-pos -> 0

	cmpi.w #DisplayWindowHeight,d4
	bhs .lowerBorder
.retLowerBorder

	clr.l d6
	move.w AddressOfYPosTable(pc,d4.w*2),d6; get adress offset lowest target bitmap
	btst.b #0,objectListTriggers(a2)
	sne d7
	ext.w d7
	sne d5
	andi.b #3,d5
	moveq #-17,d4
	sub.b d5,d4	; values are -8 (right) or -21 (left)
	add.w objectListX(a2),d4
	asr #3,d4
	add.w d4,d6	; bitmap query adress

.xOffset	SET -19

	move.w .xOffset(a1,d6.l),d0
	or.w .xOffset+mainPlaneWidth(a1,d6.l),d0
	or.w .xOffset+mainPlaneWidth*2(a1,d6.l),d0
	;move.w d0,.xOffset-(mainPlaneWidth*mainPlaneDepth*20)(a1,d6.l)


	or.w .xOffset+(mainPlaneWidth*mainPlaneDepth*4)(a1,d6.l),d0
	or.w .xOffset+(mainPlaneWidth*mainPlaneDepth*4)+mainPlaneWidth(a1,d6.l),d0
	or.w .xOffset+(mainPlaneWidth*mainPlaneDepth*4)+mainPlaneWidth*2(a1,d6.l),d0
	eor.w d7,d0	; use negative bitmap cookie if spider walks left wall
	bfffo d0{16:16},d0; results in $11-$20
	move d7,d5
	andi.b #-$10,d5
	add.b #$20,d5	; $10 for left spider, $20 for right spider
	cmp.b d5,d0
	beq .freeFall	; no bit set in cookie -> no surface found -> fall down
	bset.b #3,objectListTriggers(a2); mark as ground based
	sub.w #$18,d0
	asr #1,d0	; smoothen movement curve
	asl #5,d0
	move.w d0,objectListAccX(a2)
.doAnimation
	;clr.w d0
	move.w frameCount+2(pc),d0
	lsr #1,d0
	andi #%11100,d0
.yFlipAnim
	tst.w objectListAccY(a2)
	smi d1
	andi.w #%100000,d1
	add.w d1,d0
	lea (a0,d0),a0
	move.w d0,objectListTriggers+2(a2)	; save animation frame
.exitAnim
	lea .killBounds,a1
	bra killCheck
.killBounds
	dc.w $90,$1c0
	dc.w -$60,$110
.lowerBorder
	move.w #DisplayWindowHeight,d4
	bra .retLowerBorder
.freeFall
	move #12,d4
	eor.w d7,d4
	add.w d4,objectListAccX(a2)
	clr.w d0
	bclr.b #3,objectListTriggers(a2)	; mark as free fall
	;bra objectListNextEntry
	bra .yFlipAnim

