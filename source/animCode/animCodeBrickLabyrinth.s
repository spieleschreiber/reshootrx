
        ;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter bitmap load adress or use a0 if return to bobblitnext / not animreturn

    	;	#MARK: L4 Bricklabyrinth


	; trig0		launch flag
	; trig1		at first call: child type. 0= nil (trig1280), 1=eyeShot (trig1281), 2=sprayShot (trig1282), ... .
	; trig1 	at runtime = flag If >0 avoid animation and do collission check with background
	; trig2		available
	; trig3		behaviour of brick. 0,1,2,3,4,5,6 aligns to South, West, North, East
		; (add trig1792, 1793, 1794 or 1795 to animlist)
		; ATTN: On init, if trig+3 is set to 1792 (0),code will determine up or down-heading depending on objects spawn position
		;Idle (add trig1796 to animlist)
		;IdleRebound (add trig1797 to animlist)
		;IdleHitAndMove (add trig1798 to animlist). States 0-3 self-modified by automove code. Automove only works with objects sized 32 x 32 (?).
		;isChild (add trig1799 to animlist). Has been attached to parent object. Not animated, not borderkilled
		;idleB (add trig1800 to animlist). Only 2 frames of animation, not 4

	; y-launchdirection depends on y-launchposition
	; trig0=	 init
brickMed
	tst.b objectListTriggersB+2(a2)
	bne .isChild
	tst.b objectListTriggers(a2)
	bne .controlBrick	; first call or additional call in case of re-initialise of heading

	; Init stuff

	st.b objectListTriggers(a2)
	move.b objectListHit+1(a2),objectListTriggersB+1(a2); needed in case of rebound-type

	add #8,objectListX(a2)
	and.w #$fff0,objectListX(a2)	; position at 32px border
	add #8,objectListY(a2)
	and.w #$fff0,objectListY(a2)	; position at 32px border
	move.b objectListTriggers+3(a2),d5
	;beq .doHeading
	cmpi.b #3,d5
	bhi .headingDone

	andi.w #3,d5
	move.w .headingTable(pc,d5*2),d0
	move.w d0,objectListAccX(a2)
	move.w .headingTable+8(pc,d5*2),d0
	move.w d0,objectListAccY(a2)
.headingDone
	;add #16,objectListX(a2)
	;andi.w #$fff0,objectListX(a2)	; align to 16 bit position
	move.b #postDestroyForceLrgExplosion,objectListDestroy(a2)
	
	tst.b objectListTriggers+1(a2)	; if zero at first call? Has no child
	beq .controlBrick

	move.l  objectListMyChild(a2),a1
	tst.l a1
	beq .addChild
	;bra .controlBrick
;	tst.w objectListGroupCnt(a2)	; attached object, initialised?
;	bne .colWithBckOnlyRet			; yes!
	
	move.w objectListGroupCnt(a1),d6
	btst #0,d6	; bit is set to 1 at init, 0 when child is attached
	bne .controlBrick	; is child object fully initialised with all its childs? Not yet.
	bset #0,d6
	move.w d6,objectListGroupCnt(a2)
	move.b #attrIsLinkF,objectListAttr(a2)
	move.w objectListHit(a2),d4
.nextChild
	move.w d6,objectListGroupCnt(a1)
	move.w d4,objectListHit(a1)
	move.l a2,objectListMainParent(a1)
	
	move.l objectListMyChild(a1),a1
	tst.l a1
	bne .nextChild
	bra .controlBrick

.addChild
	movem.l d1-d3/a4-a6,-(sp)
	clr.l d0
	move.b objectListTriggers+1(a2),d0
;	sf.b objectListTriggers+1(a2)
	move.w (.childType,pc,d0*2),d0
.jmpAdr
	jmp .jmpAdr(pc,d0.w)
.childType
	dc.w .noAction-.jmpAdr-2,.tentacle-.jmpAdr-2,.discEye-.jmpAdr-2,.tubeTurret-.jmpAdr-2
.headingTable
	dc.w 0,-.brickAcceleration,0,.brickAcceleration
	dc.w		.brickAcceleration,0,-.brickAcceleration,0

.tentacle	; attach basic tentBase Object
	move.l tentBaseAnimPointer(pc),a4
	;move.l debrsObjAnimPointer(pc),a4
	;move.l tentHeadAnimPointer(pc),a4
	bra.b .contInit
.tubeTurret
	;move.l brickTurAnimPointer(pc),a4
	;move.l 	tubeTuLLAnimPointer(pc),a4
	bra.b .contInit
.discEye
	move.l tentBaseAnimPointer(pc),a4
.contInit
	move.w animTablePointer+2(a4),d4
	st.b d3
	clr.w d5
	clr.w d6
	move #8,d6
	bsr objectInit
	tst.l d6
	bmi .noAction
	bsr modifyObjCountAnim
	move.w a4,objectListGroupCnt(a2)
	move.w objectListHit(a2),d2
	move.w d2,objectListHit(a4)
		;move #40,objectListY(a4)
	move.l a4,objectListMyChild(a2)
	move.l a2,objectListMyParent(a4)
	move.l a2,objectListMainParent(a4)
	clr.l objectListMyChild(a4)
	move.b #attrIsLinkF,objectListAttr(a2)
	move.l a4,a1
	movem.l (sp)+,d1-d3/a4-a6
	bra .controlBrick
.noAction
	movem.l (sp)+,d1-d3/a4-a6
.controlBrick
	clr.l d6
	tst.b objectListTriggers+1(a2)
	bne.b .colWithBckOnly

	move.l mainPlanesPointer+4(pc),a3
.colWithBckOnlyRet
.brickAcceleration	 SET 	1<<8
	clr.l d6
	move.w #156-$140,d6		;x-offset
	moveq #16,d0
	add.w objectListY(a2),d0         ; load object y-coords
	add.w objectListX(a2),d6         ; load obj x-coords
	sub.w viewPosition+viewPositionPointer(pc),d0

	clr.l d5
	clr.w d7
	move.b objectListTriggers+3(a2),d7
	move.w (.directionTable,pc,d7.w*2),d7
.jmp
	jmp .jmp(pc,d7.w)
.directionTable
	dc.w	.goSouth-.jmp-2,.goWest-.jmp-2
	dc.w 	.goNorth-.jmp-2,.goEast-.jmp-2
	dc.w	.goIdle-.jmp-2,.rebound-.jmp-2
	dc.w	.hitAndMove-.jmp-2,.isChild-.jmp-2
	dc.w 	.goIdleB-.jmp-2
	RSSET	0
.headingSouth		rs.b	1
.headingWest		rs.b	1
.headingNorth		rs.b	1
.headingEast		rs.b	1
.headingIdle		rs.b	1

.colWithBckOnly
	move.l mainPlanesPointer+0(pc),a3
	bra .colWithBckOnlyRet
.modifyPos
	rts
	add.w #3,objectListX(a2)
	add.w #3,objectListY(a2)
	andi.w #$fff8,objectListX(a2)
	andi.w #$fff8,objectListY(a2)
	rts
.rebound
	clr.l objectListAcc(a2)
	move.b objectListHit+1(a2),d4
	cmp.b objectListTriggersB+1(a2),d4	; was hit?
	beq .animate
	move.b d4,objectListTriggersB+1(a2)	; yes
	sub #12,d0
	move.l mainPlanesPointer+0(pc),a3
	clr.l d6
	move.w #156-$140,d6		;x-offset
	moveq #16,d0
	add.w objectListY(a2),d0         ; load object y-coords
	add.w objectListX(a2),d6         ; load obj x-coords
	sub.w viewPosition+viewPositionPointer(pc),d0

	bsr .queryNorthSensorJumpin				; adjust north sensor
	bne .animate
	move.w #-120,objectListAccY(a2)	; modify to adjust rebound distance per hit
	;sub.w #1,objectListY(a2)			; slide brick northwards
.animate
	btst #4,frameCount+3(pc)
	seq d0
	andi.w #$8,d0
	lea (a0,d0),a0
	lea killBoundsWide(pc),a1
	bra killCheck	; check exit view

.hitAndMove
	clr.l objectListAcc(a2)
	move.b objectListHit+1(a2),d4
	cmp.b objectListTriggersB+1(a2),d4	; was hit?
	beq .quit
	move.b #.headingNorth,objectListTriggers+3(a2)
	move.w #-.brickAcceleration,objectListAccY(a2)
	bra .quit
.goSouth
	tst.l objectListAcc(a2)
	beq .south
	bsr .querySouthSensor
	beq .acclSouth
	clr.l objectListAcc(a2)	; blocked north and south. Find alternative direction
	;bra .quit
.south
	bsr .modifyPos
	bsr .queryEastSensor
	beq .acclEast
	bsr .queryWestSensor
	beq .acclWest
	bra .acclNorth
.acclSouth
	move.w #.brickAcceleration,objectListAccY(a2)
	move.b #.headingSouth,objectListTriggers+3(a2)
	bra .quit

.querySouthSensor
	tst.b objectListTriggers+2(a2)
	beq .forcedQuit

	clr.w d5
	cmpi.w #$fc,d0
	bhs .southForcedExit
	move.l d6,d4
	move.l a3,a1
	;move.l .mainPlaneB(pc),a1
	;add.w #18,d4
	lsr #3,d4		; x-coord
	bmi .q
	cmpi.w #$118,d4
	bhi .q
	lea (a1,d4.w),a1	; add x-byte-offset
	move.l d0,d4
	add.w #17,d4
	bmi .q
	cmpi #$fe,d4
	bhi .q
	IFNE 1

	move.l a3,a1
	move.w AddressOfYPosTable(pc,d4.w*2),d4 ; y bitmap offset
	lea -2(a1,d4.l),a1
	move.l d6,d7
	ror.l #3,d7
	lea (a1,d7.w),a1; add x-byte-offset
    clr.w d7
	swap d7
	rol #3,d7	; put bit pointer in place
	andi.w #$f,d7
	add #6,d7

	;bfset (0*40*4)+40(a1){d7:30}
	;bfset (40*4*7)+40(a1){d7:3}
	;bfset (40*4*-7)+40(a1){d7:3}
	;clr.w d5
	;rts

	bftst (a1){d7:28}
	sne d5
	bftst 40*4(a1){d7:28}
	sne d4
	or.b d4,d5
	;clr.l d5
	ELSE

	move.w AddressOfYPosTable(pc,d4.l*2),d5     ; y bitmap offset
	lea (a1,d5.l),a1
	move.w (a1),d5
	ENDIF
	rts
.southForcedExit
	clr.w d5
	rts

.goEast
	tst.l objectListAcc(a2)
	beq .east
	bsr .queryEastSensor
	beq .acclEast
	clr.l objectListAcc(a2)	; blocked north and south. Find alternative direction
	;bra .quit
.east
	bsr .modifyPos
	bsr .queryNorthSensor
	beq .acclNorth
	bsr .querySouthSensor
	beq .acclSouth
	bra .acclWest
.acclEast
	move.w #.brickAcceleration,objectListAccX(a2)
	move.b #.headingEast,objectListTriggers+3(a2)
	bra .quit
.queryEastSensor
	tst.b objectListTriggers+2(a2)
	beq .forcedQuit
	; d6 contains x-coord
	; d0 contains y-coord
	clr.l d4
	move.w d0,d4
	bmi .q
	cmpi.w #$fe,d4
	bhi .q
	cmpi.w #$100,d6
	bhi .q

	move.l a3,a1
	move.w AddressOfYPosTable(pc,d4.w*2),d4 ; y bitmap offset
	lea 2(a1,d4.l),a1
	move.l d6,d7
	ror.l #3,d7
	lea (a1,d7.w),a1; add x-byte-offset
    clr.w d7
	swap d7
	rol #3,d7	; put bit pointer in place
	andi.w #$f,d7
	add #5,d7

	;bfset 40(a1){d7:2}
	;bfset (40*4*7)+40(a1){d7:3}
	;bfset (40*4*-7)+40(a1){d7:3}
	;clr.w d5
	;rts

	bftst (a1){d7:2}
	sne d5
	bftst 40*4*7(a1){d7:2}
	sne d4
	or.b d4,d5
	bftst 40*4*-7(a1){d7:2}
	sne d4
	or.b d4,d5
	bftst (40*4*13)+0(a1){d7:2}
	sne d4
	or.b d4,d5
	bftst (40*4*-13)+0(a1){d7:2}
	sne d4
	or.b d4,d5

	rts
.q
.forcedQuit
	clr.w d5
	rts

.goWest
	tst.l objectListAcc(a2)
	beq .west
	bsr .queryWestSensor
	beq .acclWest
	clr.l objectListAcc(a2)	; blocked north and south. Find alternative direction
	;bra .quit
.west
	bsr .modifyPos
	bsr .querySouthSensor
	beq .acclSouth
	bsr .queryNorthSensor
	beq .acclNorth
	bra .acclEast
.acclWest
	move.w #-.brickAcceleration,objectListAccX(a2)
	move.b #.headingWest,objectListTriggers+3(a2)
	bra .quit
.queryWestSensor
	; d6 contains x-coord
	; d0 contains y-coord
	tst.b objectListTriggers+2(a2)
	beq .forcedQuit
	clr.l d4
	move.w d0,d4
	bmi .q
	cmpi.w #$fe,d4
	bhi .q
	cmpi.w #$10,d6
	ble .q	; quit to left handside

	move.l a3,a1
	move.w AddressOfYPosTable(pc,d4.w*2),d4 ; y bitmap offset
	lea -2(a1,d4.l),a1
	move.l d6,d7
	ror.l #3,d7
	lea (a1,d7.w),a1; add x-byte-offset
    clr.w d7
	swap d7
	rol #3,d7	; put bit pointer in place
	;add #1,d7

	;bfset (a1){d7:3}
	;bfset 40*4*10(a1){d7:3}
	;bfset 40*4*-10(a1){d7:3}
	;clr.w d5
	;rts

	bftst (a1){d7:2}
	sne d5
	bftst 40*4*7(a1){d7:2}
	sne d4
	or.b d4,d5
	bftst 40*4*-7(a1){d7:2}
	sne d4
	or.b d4,d5
	bftst (40*4*13)+0(a1){d7:2}
	sne d4
	or.b d4,d5
	bftst (40*4*-13)+0(a1){d7:2}
	sne d4
	or.b d4,d5
	rts

.goNorth
	tst.l objectListAcc(a2)
	beq .north
	bsr .queryNorthSensor
	beq .acclNorth
	clr.l objectListAcc(a2)	; blocked north and south. Find alternative direction
	;bra .quit
.north
	bsr .modifyPos
	bsr .queryWestSensor
	beq .acclWest
	bsr .queryEastSensor
	beq .acclEast
	bra .acclSouth
.acclNorth
	move.w #-.brickAcceleration,objectListAccY(a2)
	move.b #.headingNorth,objectListTriggers+3(a2)
	bra .quit
.queryNorthSensor
	tst.b objectListTriggers+2(a2)
	beq .forcedQuit

.queryNorthSensorJumpin
	move.l d6,d4
	move.l a3,a1
	lsr #3,d4		; x-coord
	bmi .q
	cmpi.w #$118,d4
	bhi .q
	lea (a1,d4.w),a1	; add x-byte-offset
	move.l d0,d4
	sub.w #17,d4
	bmi .q

	IFNE 1
	move.l a3,a1
	move.w AddressOfYPosTable(pc,d4.w*2),d4 ; y bitmap offset
	lea -2(a1,d4.l),a1
	move.l d6,d7
	ror.l #3,d7
	lea (a1,d7.w),a1; add x-byte-offset
    clr.w d7
	swap d7
	rol #3,d7	; put bit pointer in place
	andi.w #$f,d7
	add #6,d7
	;bfset (0*40*4)+80(a1){d7:24}
	;bfset (40*4*7)+40(a1){d7:3}
	;bfset (40*4*-7)+40(a1){d7:3}
	;clr.w d5
	;rts

	bftst (a1){d7:28}
	sne d5
	bftst -4*40(a1){d7:28}
	sne d4
	or.b d4,d5
	;clr.l d5
	ELSE




	move.w AddressOfYPosTable(pc,d4.l*2),d5     ; y bitmap offset
	lea (a1,d5.l),a1
	move.w (a1),d5
	or.w 40*4(a1),d5
	ENDIF
	rts
.goIdleB
	clr.l objectListAcc(a2)
	bra .animate
.goIdle
	clr.l objectListAcc(a2)
.quit
	move.l objectListTriggers(a2),d7
	;move.w objectListX(a2),d7
	;add.w objectListY(a2),d7
	tst.b objectListTriggers+1(a2)
	bne.b .doNotAnimate
	;bra .doNotAnimate
	move.b objectListCnt(a2),d7
	add.w a2,d7
	lsr #1,d7
	andi.w #$f,d7
	move.b (brickFrames,pc,d7),d7
	clr.l d4
	move.b objectDefWidth(a4),d4       ; bob-Width in pixels
	lsr #4,d4
	lsl d4,d7
	lea (a0,d7.w),a0
.doNotAnimate
	lea killBoundsWide(pc),a1
	bra killCheck	; check exit view
.isChild	; customized code for use by Facturo boss only
	move.b #1,objectListTriggersB+2(a2)
	clr.w d0
	move.b objectListTriggers(a2),d0
	lsr #6,d0
	beq .shootingMode
	move.b objectListTriggers+2(a2),d0
	move.b d0,objectListTriggersB+3(a2)
.shootingMode
	move.b objectListTriggersB+3(a2),d0
	seq d4
	andi.b #attrIsNotHitableF,d4
	move.b d4,objectListAttr(a2)
	lea 4(a0,d0*4),a0
	bra animReturn

brickFrames
	dc.b 0,0,2,2,2,4,4,6
	dc.b 6,2,4,6,4,4,2,2
	even
