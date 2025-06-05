;//
;//  animCodeBeehive.s
;//  px
;//
;//  Created by Richard Löwenstein on 11.05.23.
;//  Copyright © 2023 spieleschreiber. All rights reserved.

        ;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter bitmap load adress or use a0 if return to bobblitnext / not animreturn

	; set animTriggersB+2 to stop swarm animation and start dropping (code trig1537)
	; one way to do this is by setting destruction mode in any object onscreen at the time (add to  animlist: code destroyI)

beeshive

	; small bricks, just fallin' down and spawning explosion with each hit'
	move.w frameCount+2(pc),d7
	add.w a2,d7
	move.w d7,d5
	lsr #4,d5
	lsr #3,d7
	add.w d5,d7
	andi.w #$7,d7

	lea (a0,d7.w*2),a0	; animate
	
	move.w objectListHit(a2),d7
	lsr #2,d7


	tst.w objectListTriggers+2(a2)
	beq .firstInit
	btst.b #0,objectListTriggers(a2)
	beq .doSwarm


	tst.b objectListTriggers+3(a2)
	beq .getOnWithIt
	;MSG02 m2,d5

	bra .getOnWithIt
	move.b objectListTriggers+3(a2),d5
	beq .getOnWithIt
	bpl .init
	add.w #10,objectListAccY(a2)
	bra .getOnWithIt
.init
	move.w #-800,objectListAccY(a2)
	move.b #$80,objectListTriggers+3(a2)
.getOnWithIt

	;bra animReturn
	cmp.w objectListTriggers+2(a2),d7
	beq .killBounds
.fireUp
	;bra animReturn
	move.w d7,objectListTriggers+2(a2)
	SAVEREGISTERS	; hit, spawn small explosion
	move.l cExplSmlAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4 objectListAnimPtr. object hit, change to explosion animation
	st.b d3
	move.w objectListX(a2),d5
	move.w objectListY(a2),d6
	bsr.w objectInit
	tst.l d6
	bmi .quit
	move.w objectListAccY(a2),d5
	sub.w #800,d5
	move.w d5,objectListAccY(a4)	; negative accl to create impression of trail
	move.b #attrIsNotHitableF,objectListAttr(a4); attribs
	lea	fastRandomSeed(pc),a1
	movem.l  (a1),d4/d5					; AB
	swap	d5						; DC
	add.l	d5,(a1)					; AB + DC
	add.l	d4,4(a1)				; CD + AB
	andi.w #$7f,d4
	sub.w #$100/2,d4
	add.w d4,objectListAccX(a4)	; vary explosion movement a bit
	move.w objectListY(a2),d6
	move.w viewPosition+viewPositionAdd(pc),d4
	;neg d4
	asl.w #4,d4
	tst.w objectListAccY(a2)
	bmi .goingUp
	clr.w objectListAccY(a2)	;
	;add.w d4,objectListY(a2)	; stop y-acc a bit for enhanced drama
.goingUp
	andi.w #$f,d6
	add.w #$1f,d6
	move.b d6,objectListCnt(a4)
	PLAYFX 4
.quit
	RESTOREREGISTERS
	bra animReturn
	bra .killBounds
.doSwarm
	cmp.w objectListTriggers+2(a2),d7
	beq .dd	; check if hit. If not, quit process
	bset.b #0,objectListTriggers(a2)
.dd
	add.b #1,objectListTriggers+1(a2)
	lea	fastRandomSeed(pc),a1
	movem.l  (a1),d0/d4					; AB
	swap    d4						; DC
	add.l   d4,(a1)					; AB + DC
	add.l   d0,4(a1)				; CD + AB

	move.w (a1),d6
	move.b objectListTriggers+1(a2),d6
	;eor.w d7,d6
.range	SET	$20
	andi.w #.range-1,d6
	beq .acc
;	cmpi.w #.range-1,d6
;	beq .pos
	cmpi.w #.range/2,d6
	bne .killBounds
	move.w objectListAccX(a2),d0
	not.w d0
	move.w d0,objectListAccX(a2)
	move.w objectListAccY(a2),d0
	not.w d0
	move.w d0,objectListAccY(a2)
	bra .killBounds
.pos
	andi.w #7,d0
	add.w objectListTriggersB(a2),d0
	move.w d0,objectListX(a2)
	swap d0
	lsr #8,d0
	sub #700,d0
	;move.w d0,objectListAccY(a2)
	andi.w #$f,d4
	add.w objectListTriggersB+2(a2),d4
	move.w d4,objectListY(a2)
	swap d4
	lsr #8,d4
	sub #128,d4
	;move.w d4,objectListAccX(a2)
	bra .killBounds
.acc
	lsl #4,d6
	or.b #$7f,d6
	move.w d6,d7

	asl #1,d7

	and.w d7,d0
	sub d6,d0
	and.w d7,d4
	sub d6,d4
	move.w d0,objectListAccX(a2)
	move.w d4,objectListAccY(a2)
	bra .killBounds

.firstInit
	move.w d7,objectListTriggers+2(a2)	; store original hitpoints
	btst.b #1,objectListTriggers(a2)	; skip randomizing init position (e.g. if being spawned by another object)
	bne .skipRandomize
.positionRange	SET $3f
	lea	fastRandomSeed(pc),a1
	movem.l  (a1),d0/d4					; AB
	swap    d4						; DC
	add.l   d4,(a1)					; AB + DC
	add.l   d0,4(a1)				; CD + AB
	andi.w #.positionRange,d0
	sub #.positionRange>>1,d0
	andi.w #.positionRange,d4
	sub #.positionRange>>1,d4
	add.w d0,objectListX(a2)
	add.w d4,objectListY(a2)
.skipRandomize
	move.w objectListX(a2),objectListTriggersB(a2)
	move.w objectListY(a2),objectListTriggersB+2(a2)
.killBounds
	lea killBoundsWide(pc),a1
	bra killCheck	; check exit view

