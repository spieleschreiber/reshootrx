
	
; #MARK: - Attach tutorial icons
addTutSp	
	move.l tutSpdUpAnimPointer(pc),a4
	bra addtutSkip
addTutPw	
	move.l tutPwrUpAnimPointer(pc),a4
addtutSkip
	;move.l waveBnusAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4	;add bonus display
	moveq #-40,d5
	moveq #34,d6
	st.b d3

	bsr objectInit
	tst.l d6
	bmi .quitAttachTut
	bsr modifyObjCount
	or.b #attrIsSpriteF!attrIsBonusF,objectListAttr(a4); tutorial icon is child
	move.l a4,objectListMyChild(a6)
	move.l a6,objectListMyParent(a4)
	move.l a2,objectListMainParent(a4)
	clr.l objectListMyChild(a4)

    ; is sprite therefore attribs are assigned by objects-list. $40=bonus icon
.quitAttachTut
	jmp (a5)
