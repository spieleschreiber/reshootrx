
	;	code may not use a5,a6,d7


mechVMsl	; launch Missile. Init by adding "code mechVMsl" to animList
		;set missile type )by adding code 	trig153x to animlist
		;	mechMedMedM		trig1532
		;	mechMedVinM		trig1533

		; set y-adjust by adding code	trig179x to animlist
		;	basic missile	-28		trig1792
		;	fireball		+10		trig1793
		;	Vin missile		-12		trig1794

	;move.l objectListTriggers(a6),d6
	clr.w d6
	tst.b objectListTriggers+2(a6)
	seq d6
	andi.b #%10000,d6
	move.l mechVinMAnimPointer(pc,d6),a4; load mech
	;move.l biggShotAnimPointer(pc,d6),a4; load mech
	move.w animTablePointer+2(a4),d4
	st.b d3
	move.w objectListX(a6),d5
	clr.w d6
	move.b objectListTriggers+3(a6),d6
	move.b .yModify(pc,d6.w),d6
	ext.w d6
	add.w objectListY(a6),d6
	move.l a6,a4
	bsr objectInitOnTopOfSelf	; init object
	;bsr objectInit	; init object
	;jmp (a5)
	tst.l d6
	bmi customCodeQuit
	bsr modifyObjCount	; adjust loopcounter
	move.w #4<<2,d0
	tst.b optionStatus(pc)
	spl d1
	andi.w #1<<2,d1
	sub.w d1,d0

	move.w d0,objectListHit(a4)
	;move.w #0,objectListHit(a4)
	move.b #postDestroyForceLrgExplosion,objectListDestroy(a4)
	clr.b objectListAttr(a4); set link attribs
	PLAYFX fxBigBullet
	jmp (a5)
.yModify
	dc.b -28,8,-12
	even

