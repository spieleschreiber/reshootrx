
	
; #MARK: - Init tube tentacle


    ;code may not use a5,a6,d7
	; a6 = pointer to caller object

	; add "code trig102x" to determine number of tentacle segments
	; add "code trig128x" to determine full body or base base body vulnerability
	; add "code trig153x" to determine type of head
	; trig1026 to add 3 body parts and one head
	; trig1028 to add 5 body parts and one head
	; trig1280	to have base only hitable
	; trig1281	to have full body hitable
	; full object hitpoints determined by hit-attribute in map data
	; trig1536	to add tentHead to tentacle
	; trig1537	to add tentHedB
	; trig1538	to add tentHedC

tentInit
	move.l tentTubeAnimPointer(pc),a0
	move.w animTablePointer+2(a0),a3
	move.l a6,a2
	;move.w a6,objectListGroupCnt(a6)	; link comparator
	move.b #postDestroyHighDebris,objectListDestroy(a6)
.hitpoints	SET	20<<2

	tst.b objectListTriggers+1(a6)	; if != 0, full object is vulnerable
	sne d0
	ext.w d0
	move.w a6,d1
	and.w d0,d1
	move.w d1,a0
	;move.w #.hitpoints,d2
	clr.l d2
	move.w objectListHit(a6),d2
	;move.w d2,objectListHit(a6)	; base object is always hitable (unless its an empty object)
	and.w d0,d2
	swap d2
	move.b #attrIsLinkF,d2
	and.b d0,d2
	move.w a6,objectListGroupCnt(a6)	; set comparator
.fullBodyHit
	IFNE 1
;
;	lsl #1,d0
	move.b d2,objectListAttr(a6)
	clr.w d0
	move.b objectListTriggers(a6),d0

	clr.w d5
	clr.w d6
	cmpi.w #$130,objectListX(a6)
	scs d1
	andi.b #14,d1
	sub.b #7,d1	; tentacle x-displacement based on left or right screenposition
	ext.w d1
	ELSE
	clr.w d5
	clr.w d6
	ENDIF
.nextChild
	move.w a3,d4
	st.b d3
	bsr objectInit
	tst.l d6
	bmi customCodeQuit
	bsr modifyObjCount
	tst.b d1
	beq .xDisplacement
	;clr.w d1
	move.w d1,objectListTriggersB(a4)	; fetch off
	sf d1
.xDisplacement
	
	move.w a6,objectListGroupCnt(a4)	; set comparator
	move.b d2,objectListAttr(a4); attribs
	swap d2
	move.w d2,objectListHit(a4); can´t be hit
	swap d2
	move.l a4,objectListMyChild(a2)
	move.l a2,objectListMyParent(a4)
	move.l a6,objectListMainParent(a4)
	move.l a4,a2
	dbra d0,.nextChild

	clr.w d4
	move.b objectListTriggers+2(a6),d4
	lsl #4,d4
	move.l tentHeadAnimPointer(pc,d4),a4 ; add turret, choice of 3 head alternatives
	move.w animTablePointer+2(a4),d4
	clr.w d5
	clr.w d6
	st.b d3
	bsr objectInit
    tst.l d6
    bmi.b customCodeQuit
	bsr modifyObjCount

	move.w a6,objectListGroupCnt(a4)	; set comparator
	clr.l objectListAcc(a4)	; must not move
	clr.l objectListTriggers(a4)
	move.b d2,objectListAttr(a4); attribs
	swap d2
	move.w d2,objectListHit(a4); can´t be hit
	move.l a4,objectListMyChild(a2)
	move.l a2,objectListMyParent(a4)
	move.l a6,objectListMainParent(a4)
	clr.l objectListMyChild(a4)
customCodeQuit
	jmp (a5)
