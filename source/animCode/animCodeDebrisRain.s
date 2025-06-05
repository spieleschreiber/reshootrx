

	;	#MARK: - debrisRain. Add some Debris to background
	  
	;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter bitmap load adress or use a0 if return to bobblitnext / not animreturn

	; 	local trigger 0 = control density
	; 	trig1024	full debris density
	;	trig1034	medium density
	;	trig1039	low density

debrsCtl
	move.b objectListTriggers(a2),d7
	move.w frameCount+2(pc),d0
	;move d0,d4
	and.b d0,d7
	bne objectListNextEntry
	movem.l d1-d3/a4-a6,-(sp)
	move.l debrisA2AnimPointer(pc),a4
	btst #2,d0
	beq .small
	move.l debrisA3AnimPointer(pc),a4
.small

	move.w animTablePointer+2(a4),d4
	lea fastRandomSeed(pc),a6
.loop
	movem.l  (a6),d5/d6
	andi #$3f,d5
	lsl #2,d5	; $3f->$ff
	add #170,d5
	andi #$3f,d6
	clr.w d6
	add.w viewPosition+viewPositionPointer(pc),d6

	st.b d3
	bsr objectInit
	tst.l d6
	bmi.b .forceQuit	; no more object slots available

	movem.l  (a6),d0/d1
	swap    d1
	add.l   d1,(a6)
	add.l   d0,4(a6); generate random nums
	lsr #6,d0
	
	move.w d0,objectListAccY(a4)
	lsr.b #1,d1
	add.b #7,d1
	move.b d1,objectListCnt(a4)
	move.b #attrIsNotHitableF,objectListAttr(a4); attribs
	move.l a4,a1
.quit
	movem.l (sp)+,d1-d3/a4-a6
	bsr modifyObjCountAnim
	bra objectListNextEntry
.forceQuit
	movem.l (sp)+,d1-d3/a4-a6
	bra objectListNextEntry

.rasterCritical	SET	200

debrsObj	; spawns debris after explosion
	;bra objectListNextEntry

	movem.l d1-d3/a4-a6,-(sp)
	move.l objectListTriggers(a2),d4
	move.w d4,d2	; duration of animation
	swap d4
	move.l objectListTriggersB(a2),d5	; fetch x- and y-position
	move.w d5,d6
	swap d5
	st.b d3
	;move.l debrisA3AnimPointer(pc),a4
	;move.w animTablePointer+2(a4),d4
	bsr objectInit
	tst.l d6
	lea fastRandomSeed(pc),a6
	movem.l (a6),d0/d1
	swap	d1
	add.l	d1,(a6)
	add.l	d0,4(a6); generate random nums
	asr #6,d1
	asr #6,d0
	sub.w d2,d0	; modify y-momentum -> go north
	;MSG02 m2,d1
	move.w d1,objectListAccX(a4)
	move.w d0,objectListAccY(a4)
	move.w d1,d2
	asr #5,d2
	add.w d2,objectListX(a4)	; widen area of explosion

	swap d1
	lsr.b #4,d1
	add.b #10,d1
	;MSG02 m2,d1
	move.b d1,objectListCnt(a4)

	move.b #attrIsNotHitableF,objectListAttr(a4); attribs
	move.l a4,a1
	movem.l (sp)+,d1-d3/a4-a6
	bsr modifyObjCountAnim
	bra objectListNextEntry


	;	#MARK: Debris Animations pointer to code
debris	SET	basic1w8frame30fps
