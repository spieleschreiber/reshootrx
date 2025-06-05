


    ;	#MARK: - boss Roid, boneSnake
        ;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter bitmap load adress or use a0 if return to bobblitnext / not animreturn
mechMedC
	
	move.l objectListTriggers(a2),d0
	move.l objectListMyChild(a2),a3	; left wing
	move.l objectListMyChild(a3),a1	; get exhaust
	move.l objectListMyChild(a1),a1	; get right wing
	tst.l a1
	beq animReturn
	move.l d0,objectListTriggers(a3)
	move.l d0,objectListTriggers(a1)
	lea killBounds(pc),a1
	bra killCheck
mechVinC

	move.l objectListTriggers(a2),d0
	;lea killBounds(pc),a1
	;move.b objectListTriggers+1(a2),d0
	;beq killCheck
;	clr.b objectListTriggers(a2)
	move.l objectListMyChild(a2),a3	; left wing
	move.l objectListMyChild(a3),a1	; get exhaust
	move.l objectListMyChild(a1),a1	; get right wing
	tst.l a1
	beq animReturn
	move.l d0,objectListTriggers(a3)
	move.l d0,objectListTriggers(a1)
	cmp.w #2,gameStatusLevel(pc)
	bne animReturn	; only stage 2 has that laser spitting-spitting mechVinC, so ...

	; laser spitting code

	move.w objectListTriggersB+2(a2),d7
	tst.w d7
	beq .init	; first call? Get Hitcounter
	bmi .noBeam	; beam emitter has been destroyed
	tst.b d0
	beq animReturn	; beam is not active? Return
	sub.w objectListHit(a2),d7
	cmpi.w #100<<1,d7
	bgt .killBeam	; sufficient hitpoints lost, so kill beam emitter - otherwise draw beam

	SAVEREGISTERS
	lea	polyVars(pc),a1
.xOffsetNorth	SET -170<<4
.yOffsetNorth	SET 47<<4
.yMaxSouth		SET 254<<4
	move.w objectListX(a2),d5
	move.w objectListY(a2),d6
	add.w #9,d5
	add.w #3,d6
	lsl #4,d5
	sub.w viewPosition+viewPositionPointer(pc),d6
	move.w objectListAccX(a2),d7
	;asr.w #1,d7
	lsl #4,d6
	;move #200<<4,d5
	;move #10<<4,d6
	move.w d5,d3
	move.w d6,d4
	add #.xOffsetNorth,d3
	add #.yOffsetNorth,d4
	clr.l 16(a1)
	clr.l 16+4(a1)
	clr.l 16+8(a1)
	clr.l 16+12(a1)
	tst.w xA1(a1)
	beq .ff
	lea 16(a1),a1
	
.ff
	move	d3,xA1(a1)
	move	d4,yA1(a1)

	move.w d5,d3
	move.w d6,d4
	;add #.xOffsetNorth-(20<<4),d3
	add #.yMaxSouth,d4
	add.w d7,d3
	add #.xOffsetNorth-(7<<4),d3
	move #.yMaxSouth,d4
	move	d3,xA2(a1)
	move	d4,yA2(a1)

	move.w d5,d3
	move.w d6,d4
	add #.xOffsetNorth+(1<<4),d3
	add #.yOffsetNorth,d4
	move	d3,xB1(a1)
	move	d4,yB1(a1)

	move.w d5,d3
	move.w d6,d4
	add #.xOffsetNorth+(1<<4),d3
	add.w d7,d3
	;add #.xOffsetNorth+(2<<4),d4
	add #.yMaxSouth,d4
	move #.yMaxSouth,d4
	move	d3,xB2(a1)
	move	d4,yB2(a1)
		move.w frameCount+2(pc),d3
	andi #$1f,d3
	bne .noSound
	PLAYFX fxBeam
.noSound
	RESTOREREGISTERS
	bra animReturn
.noBeam
	lea 2(a0),a0	; switch to center destroyed frame
	bra animReturn
.killBeam
	SAVEREGISTERS
	move.l cExplLrgAnimPointer(pc),a1
	move.w animTablePointer+2(a1),d4	;add med explosion replacing shot
	move #34,d5
	sub.w plyBase+plyPosXDyn(pc),d5
	add.w objectListX(a2),d5; get x-coord from mech object
	moveq #40,d6
    add objectListY(a2),d6                    ; get y-coord
    st.b d3
	bsr.w objectInit	; no testing after init needed - there will always be sufficient free objects slot in case
        ;move #0,objectListHit(a4); hitpoints
    move.b #attrIsNotHitableF,objectListAttr(a4); attribs
    move.w viewPosition+viewPositionAdd(pc),d6
    add.w #-$480,d6
    move.w d6,objectListAccY(a4)
    move.b #$2c,objectListCnt(a4)
        PLAYFX 5
            PLAYFX 5
	RESTOREREGISTERS

	lea killShakeIsActive(pc),a1
	move.b #7,(a1)
	st.b objectListTriggersB+2(a2)
	bra animReturn
.init
	move.w objectListHit(a2),objectListTriggersB+2(a2)
	bra animReturn


;	trig1 	negative offset of exhaust y-position
;	add "code trig1295" to sub -15 to y-position
mechVinX	; draw exhaust only if parents y-acceleration is positive
	;move.l objectListTriggersB(a2),a1
	;move.w objectListX(a1),d0
	move.l objectListMyParent(a2),a3
	tst.l a3
	beq .noParent
	move.w objectListX(a3),d4
	neg.w d4
	move.w d4,objectListX(a2)
	move.w objectListY(a3),d4
	neg.w d4
	sub #21,d4
	sub.w objectListTriggers(a2),d4
	move.w d4,objectListY(a2)

	move.l objectListMyParent(a2),a1	; get left wing obj
	move.l objectListMyParent(a1),a1	; get central hub obj
	tst.w objectListAccY(a1)
;	bra basic1w2frame60fps
	beq objectListNextEntry
	bpl basic1w2frame60fps
.noParent
	bra objectListNextEntry


riglBody
	cmpi.w #1,gameStatusLevel(pc)
	bne animReturn
	tst.b (animTriggers+2,pc)	; Beam is active?
	bne .flicker	; yes!
	move.b (animTriggers+1,pc),d0	; only level 0, eye opening up?
.applyFrame	ext.w d0	; choose frame by animlist
	move.w d0,d4
	lsl #2,d0
	lsl #1,d4
	add.w d0,d4
	lea (a0,d4),a0
	bra animReturn
.flicker		; beam is active, switch two frames
	btst.b #0,frameCount+3(pc)
	sne d0
	andi.b #1,d0
	add.b #3,d0
	bra .applyFrame

riglEast
	cmpi.w #1,gameStatusLevel(pc)
	bne animReturn
	tst.b (animTriggers+2,pc)	; Beam is active?
	beq animReturn
	btst.b #0,frameCount+3(pc)
	sne d0
	andi.b #6,d0
	lea (a0,d0),a0
	bra animReturn

riglWest
	cmpi.w #1,gameStatusLevel(pc)
	bne animReturn
	tst.b (animTriggers+2,pc)	; Beam is active?
	beq animReturn	; yes!
	btst.b #0,frameCount+3(pc)
	sne d0
	andi.b #10,d0
	lea (a0,d0),a0
	bra animReturn
