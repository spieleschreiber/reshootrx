
	;	code may not use a5,a6,d7
	;	a6 = pointer to caller object
	;	add "trig102x" to anim table -> set pointer to added object
	;	x = 0 shelLftA, = 1 shelRgtA etc. Add object to customCases.s, Pointers spiderAttachment
	;	add "code spdrAdda" to anim table, to add object

spiderAddAttach
	clr.w d4
	tst.w objectListAccY(a6)
	smi d4
	andi.w #16,d4
	tst.b objectListTriggers(a6)
	sne d5
	andi.b #32,d5
	add.b d5,d4
	move.l shelRgtAAnimPointer(pc,d4),a4
.base
	move.w animTablePointer+2(a4),d4
	st.b d3
	clr.w d5
	clr.w d6
	move.l a6,a4
	bsr objectInitOnTopOfSelf
	tst.l d6
	bmi .quit

	bsr modifyObjCount
	;bset.b #1,objectListAttr(a6)    ; mark parent

	move.w objectListHit(a6),d0
	move.w d0,objectListHit(a4)
	move.b #attrIsLinkF,objectListAttr(a4); set link attribs
	move.b #attrIsLinkF,objectListAttr(a6)
	move.w a4,objectListGroupCnt(a6)	; link comparator
	move.w a4,objectListGroupCnt(a4)
	move.l a4,objectListMyChild(a6)		; set relationship
	move.l a6,objectListMyParent(a4)
	move.l a6,objectListMainParent(a4)
	clr.l objectListMyChild(a4)
	move.b #1,objectListDestroy(a4)	; set destroy effect
	move.b #1,objectListDestroy(a6)
	add.b #1,d7	; adjust loopcounter
	;bsr modifyObjCount
	;bra drwOnTop
.quit
	jmp (a5)
