

;	#MARK: - Animate tube tentacles


	;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter bitmap load adress or use a0 if return to bobblitnext / not animreturn


tentHead
tentTube
	move #15,d6
	add.w objectListX(a2),d6
	sub.w objectListTriggersB(a2),d6
	moveq #16,d7
	add.w objectListY(a2),d7
	lsl #5,d7
	add.w d6,d7
	clr.w d4
	move.b (tanTable.w,pc,d7),d4
	tst.b objectListTriggers(a2)
	bne .flash
.retFlash
	lea (a0,d4.w),a0
	btst.b #attrIsKillBorderExit,objectListAttr(a2)	; killcheck bit set?
	beq animReturn	; no
	lea killBounds(pc),a1
	bra killCheck	; check exit view
.flash
	btst #1,frameCount+3(pc)
	seq d0
	andi #64,d0
	add.w d0,d4

	tst.b optionStatus(pc)
	bmi .retFlash	; hard diff? Animate in any case
	btst.b #1,objectListTriggers(a2)
	beq .retFlash
	sub.w d0,d4
	bra .retFlash

tentBase
    ;May use d0,d4,d5,d6,d7,a1,a3


	move.l objectListMyChild(a2),a1
	;move.w objectListY(a2),d0
	;move.w #10,objectListY(a2)
	;MSG02 m2,d0

	tst.l a1
	beq .skipThis
	SAVEREGISTERS
.loop
	move.w #$100,d0
	move.w #$50,d1
;	move.w frameCount+2(pc),d3
;	sub #15,d3
;	andi #$f,d3
	;MSG01 m2,d3
	clr.w d3
	move.w plyBase+plyRemXPos(pc,d3*2),d4

	sub.w objectListX(a2),d0
	add.w objectListY(a2),d1
	tst.w objectListMyParent(a2)
	beq .isParent
	move.l objectListMyParent(a2),a3
	sub.w objectListX(a3),d0
	add.w objectListY(a3),d1
.isParent
	lea plyBase(pc),a0
	add.w d4,d0
	bpl .allGoodD0
	clr.w d0
.allGoodD0
	tst.b plyBase+plyWeapUpgrade(pc)	; if player killed, skip player y-detect to prevent animation glitch
	bmi .playerKilled

	sub.w plyPosY(a0),d1
	bpl .allGoodD1
.playerKilled
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
	swap d1
	swap d2
	move.l d2,d0
	lsr.l #4,d0
	lsr.l #6,d2
	add.l d0,d2
	lsr.l #4,d1

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
	move.w frameCount+2(pc),d0
	andi.l #$7f,d0
	move.b (sineTable,pc,d0.w),d6
	sub.b #64,d6
	ext.w d6
	ext.l d6
	lsl.l #5,d6
	lsl.l #5,d6
	move.l d6,d7
	asr.l #2,d7
	;clr.l d6
	;move.w objectListTriggersB(a1),d3	; fetch offset
	;move.w #10,d3
	;swap d3
	;add.l d2,d3
	;move.l d3,objectListY(a1)
	move.w objectListTriggersB(a1),d3	; fetch offset
	swap d3
	add.l d1,d3
	move.l d3,objectListX(a1)
	bra .getNext
	;bra .getNextTentacleElement
.repositionTentacle
	add.l d6,d1
	add.l d7,d2
	move.l d1,objectListX(a1)
	move.l d2,objectListY(a1)
.getNext
	move.l d2,objectListY(a1)
.getNextTentacleElement
	move.l objectListMyChild(a1),a1
	tst.l a1
	bne .repositionTentacle
	RESTOREREGISTERS
	;tst.b objectListTriggers+1(a2)
	;bne .skipThis	; animate only when base is vulnerable exclusively
	move.w a4,d7
	add.w frameCount+4(pc),d7
	move d7,d6
	lsr #1,d7
	lsr #2,d6
	sub d6,d7
	andi #%0111,d7
	move.b .animFrames(pc,d7),d7
	lea (a0,d7),a0	; animate body / heart
.skipThis
	lea killBoundsWide(pc),a1
	bra killCheck

.animFrames
	dc.b 4,4,4,8,12,12,0,0
	even
