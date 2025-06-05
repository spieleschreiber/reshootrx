

; #MARK: - SHARED CODE - INIT'D BY ANIMLIST, CALLED FROM OBJECT MOVE LOOP

	;	code may not use a5,a6,d7
	; 	a6	->	pointer to caller object


; #MARK: draw object on top

	IFNE 0
drwOnTop ; move object in drawlist order to last spot -> change prio.Beware: Updates only ONE main child object!

	move.w objCount(pc),d6
;	sub.w spriteCount(pc),d6
	subq #1,d6
	bcs .quit
	
	moveq #4,d1
	move.l objectList+4(pc),a1
	;lea 4(a6),a1
.slotOcc
	tst.w (a1)
	adda.l d1,a1
	beq .slotOcc
	dbra d6,.slotOcc
	;adda.l d1,a1
	;rts
	move.l (a6),(a1)
	move.l objectListX(a6),objectListX(a1)
	move.l objectListY(a6),objectListY(a1)
	move.l objectListAcc(a6),objectListAcc(a1)
	move.l objectListHit(a6),objectListHit(a1)
	move.l objectListGroupCnt(a6),objectListGroupCnt(a1)
	move.l objectListTriggers(a6),objectListTriggers(a1)
	move.l objectListTriggersB(a6),objectListTriggersB(a1)
	move.l objectListMyParent(a6),a0
	move.l a0,objectListMyParent(a1)
	move.l objectListMyChild(a4),objectListMyChild(a1)
	
	clr.l (a6)
	clr.l objectListMyParent(a6)
	clr.l objectListMyChild(a6)
	tst.l a0
	beq.b .quit
	move.l a1,objectListMyChild(a0)
.quit
	rts
	IFNE 0	; outcommented some old code, as I dont understand the purpose. Remove after 1.11.22
	move (a1),d0;objectListAnimPtr
    move.l animDefs(pc),a5
    move.b animDefCnt(a5,d0),d0
    ;beq .zeroCnt	; cnt of 0 -> execute next step immediately

    move.b d0,objectListCnt(a1)
	dbra d7,animLoop
	bra irqDidObjMoveManager	; back to irq
	;move.l a0,a6
	rts
	ENDIF
	ENDIF

; #MARK: spawn explosion at object position

	;	code may not use a5,a6,d7
	; 	a6	->	pointer to caller object
spwnXplS
	SAVEREGISTERS
    clr.w d5
    clr.w d6
    move.w #-160,d3
	add.w objectListX(a6),d3

    move.w objectListY(a6),d4
    sub.w viewPosition+viewPositionPointer(pc),d4
	lsl #4,d3
	lsl #8,d4

    lea emitterExtraLoss(pc),a0	; switch two emitters randomly

	bsr particleSpawn	; call subroutine
	RESTOREREGISTERS
	jmp (a5)
	move.l cExplSmlAnimPointer(pc),a4
	move.w #1,d0
	bra spwnXplJump
spwnXplL
	move.l cExplLrgAnimPointer(pc),a4
	clr.w d0
spwnXplJump
	move.w animTablePointer+2(a4),d4 objectListAnimPtr. object hit, change to explosion animation
	st.b d3
	move.w objectListX(a6),d5
	move.w objectListY(a6),d6
	bsr.w objectInit
	tst.l d6
	bmi .quit
	move.w objectListAccY(a6),d5
	sub.w #800,d5
	move.w d5,objectListAccY(a4)	; negative accl to create impression of trail
	move.b #attrIsNotHitableF,objectListAttr(a4); attribs
	lea	fastRandomSeed(pc),a1
	movem.l  (a1),d4/d5					; AB
	swap	d5						; DC
	add.l	d5,(a1)					; AB + DC
	add.l	d4,4(a1)				; CD + AB
	
	and.w .xrange(pc,d0*2),d4
	;clr.w d4
	;andi.w #$3f,d4
	sub.w  .xOffset(pc,d0.w*2),d4
	;sub.w #$60/2,d4
	add.w d4,objectListAccX(a4)	; vary explosion movement a bit
	sub.w d4,objectListX(a4)	; vary explosion movement a bit
	PLAYFX fxExplBig
.quit
	jmp (a5)
.xrange
	dc.w $3f,0
.xOffset
	dc.w $60/2,0
; #MARK: ; add child objects to main object

addChild
	; add "code trig102x" to animlist; set trigger 0,1,2 etc. -> set AnimPointer to address in AnimList
	; trig1024 mechMed
	; trig1026 sunErptL
	; trig1027 sunErptR
	; trig1028 riglBody (3 objects)
	; trig1029 riglBody (2 objects)
	; trig1030 riglBody (1 object)

	; make sure AnimPointer has been added to pointer list at label .animPointers
	; make sure number of child objects has been added to list at label .childCount

	; add "code addChild" to animlist to add  childs objects
	;


	clr.w d4
	move.b objectListTriggers(a6),d4
	move.b .childCount(pc,d4),d2
	ext.w d2
	move.w .animPointers(pc,d4*2),d4
	lea (bobCodeCases,pc,d4),a2
	;lea mechMedLAnimPointer(pc,d4*2),a2
	move.b #attrIsLinkF,objectListAttr(a6); set link attribs
	move.w a6,objectListGroupCnt(a6)	; link comparator

	move.w objectListHit(a6),d0

	move.l a6,a0
.base
	move.l (a2),a4
	move.w animTablePointer+2(a4),d4
	st.b d3
	clr.w d5
	clr.w d6
	move.l a6,a4
	bsr objectInitOnTopOfSelf	; init object
	tst.l d6
	bmi customCodeQuit
	bsr modifyObjCount

	;move.w #0,objectListHit(a4)
;	clr.b objectListAttr(a4); set link attribs
	;move.l a6,objectListTriggersB(a4)
	move.l a6,objectListMainParent(a4)
	move.l a0,objectListMyParent(a4)
	clr.l objectListMyChild(a4)
	move.l a4,objectListMyChild(a0)		; set relationship
	;btst #1,d2
	;sne d3
	;andi.b #attrIsOpaqF,d3	; draw wings opaque, exhaust non-opaque
	;or.b #attrIsOpaqF,d3
	move.b #attrIsLinkF,objectListAttr(a4); set link attribs, always draw
	;move.w objectListHit(a6),d0
	
	move.w d0,objectListHit(a4)
	;move.w #0,objectListHit(a4)
	
	move.w a6,objectListGroupCnt(a4)
	move.l a4,a0
	;move.b #postDestroyForceLrgExplosion,objectListDestroy(a4)	; set destroy effect
	move.b #postDestroyForceLrgExplosion,objectListDestroy(a6)
	add.b #1,d7	; adjust loopcounter
	lea 16(a2),a2	; init left wing, right wing, exhaust flame
	dbra d2,.base
	;bset.b #attrIsNotHitable,objectListAttr(a6)    ; mark parent
.lastEntry
	jmp (a5)
.animPointers
	dc.w mechMedLAnimPointer-bobCodeCases
	dc.w mechVinLAnimPointer-bobCodeCases
	dc.w sunErptLAnimPointer-bobCodeCases
	dc.w sunErptRAnimPointer-bobCodeCases
	dc.w riglBodyAnimPointer-bobCodeCases	; used by boss 4
	dc.w riglBodyAnimPointer-bobCodeCases	; uses Rigelobjects riglbody, riglwest and riglanch, does not use rigleast
	dc.w riglBodyAnimPointer-bobCodeCases	; uses riglbody only
.childCount
	dc.b	2,2,0,0,3,2,0
	even


;	#MARK: play soundeffects

	;add "code playfx01" to play spawn sound

playSpwn
	PLAYFX fxSpawnBoss0
	jmp (a5)


;	#MARK: set / reset global animTriggers

	;add "code clrTrigs" to set global animTriggers to 0

clrTrigs
	lea animTriggers(pc),a0
	clr.l (a0)
	jmp (a5)
setTrigs
	lea animTriggers(pc),a0
	moveq #-1,d0
	move.l d0,(a0)
	jmp (a5)

;	#MARK: apply custom hitpoints to object
setHitPt
	move.w #240<<2,d0
	tst.b optionStatus(pc)
	bmi .isHard
	move.w #210<<2,d0
.isHard
	move.w d0,objectListHit(a6)
	jmp (a5)

setHitPB
	move.w #280<<2,d0
	tst.b optionStatus(pc)
	bmi .isHard
	move.w #240<<2,d0
.isHard
	move.w d0,objectListHit(a6)
	jmp (a5)



;	#MARK: init single Object

	; 	a4 		=	pointer to animation.Load example:move.l bossEastAnimPointer(pc),a4
	;	d0		=	hitpoints
	; ATTN You MUST set object attributes after return from subroutine!
	
initObject
	move.w animTablePointer+2(a4),d4
	st.b d3
	clr.w d5
	clr.w d6
	bsr objectInit
	tst.l d6
	bmi.b .ret
	bsr modifyObjCount
	;move.b d0,objectListAttr(a4)
	lsl.w #2,d0
	;andi.b #%11111100,d0
	move.w d0,objectListHit(a4)
.ret
	rts



;	#MARK: get objects world coords parent or child

getCoordsSprite	; choose this if want to trigger sprite-based object
	move objectListX(a6),d5
	move objectListY(a6),d6
	move.l objectListAcc(a6),d4
	beq .noInertiaObject
	asr.w #7,d4
	sub.w d4,d6
	swap d4
	asr.w #7,d4
	sub.w d4,d5
.noInertiaObject
	move.l a6,a1        ; is children object -> add all parent coords
    move.l objectListMyParent(a1),a1
    tst.l a1
    bne.b .gotChildren
	rts
.gotChildren
	add.w objectListX(a1),d5
	add.w objectListY(a1),d6
	move.l objectListAcc(a1),d4
	beq .noInertiaParent
	asr.w #7,d4
	sub.w d4,d6
	swap d4
	asr.w #7,d4
	sub.w d4,d5
.noInertiaParent
	move.l objectListMyParent(a1),a1
	tst.l a1
	bne.b .gotChildren
	rts

getCoordsBlitter; ; choose this if want to trigger blitter-based object
	move objectListX(a6),d5
	move objectListY(a6),d6
	move.l a6,a1        ; is children object -> add all parent coords
    move.l objectListMyParent(a1),a1
    tst.l a1
    bne.b .gotChildren
	rts
.gotChildren
	add.w objectListX(a1),d5
	add.w objectListY(a1),d6
	move.l objectListMyParent(a1),a1
	tst.l a1
	bne.b .gotChildren
	rts

; #MARK: 	modify Objectcounter if new object position is higher than old one

modifyObjCount	; spawned new object in customcode? Check if  loopcounter needs modification

	cmp.l objectList+8(pc),a4
	bhs .return
	cmpa.l a6,a4	; A6=current object, a4=new object. Is new object position higher in objList than parent ? If true -> objCounter=+1
	shi d3
	and.b #1,d3
	add.b d3,d7	; adjust objCounter
.return
	rts


; #MARK: 	define object as deletable if it leaves screen

exitKill
	bset #attrIsKillBorderExit,objectListAttr(a6)
	jmp (a5)
bulletLaunchSkipper        ; counter for bullet launch in worms etc. Use: Launch projectile every xth iteration
	dc.b    0
bulletLaunchSkipperMisl
	dc.b    0
	even
; #MARK: END SHARED SUBCODE

