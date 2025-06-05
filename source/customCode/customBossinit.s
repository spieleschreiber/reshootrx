
    ;code may not use a5,a6,d7
	; a6 = pointer to caller object


bossInit
.easyDiffDownscale	SET	80
	lea bossVars(pc),a0
	clr.w bossStateMachine(a0)
	move.w objectListHit(a6),bossHitCmp(a0)	; set boss hit compare
	move.w gameStatusLevel(pc),d6

	move.w (.bossJmpTable,pc,d6.w*2),d0
.jmp	jmp .jmp(pc,d0.w)
.bossJmpTable
	dc.w .main0-.bossJmpTable+2
	dc.w .main1-.bossJmpTable+2
	dc.w .main2-.bossJmpTable+2
	dc.w .main3-.bossJmpTable+2
	dc.w .main4-.bossJmpTable+2

.main2	; the eye boss
.eyeBossLaunchpads	SET 30<<2
	move.l bossEastAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
	move.w #.eyeBossLaunchpads,d0
	bsr .callBoss
	move.l a4,bossChildPointers(a0)	; east pointer
	clr.b objectListAttr(a4)	;hit permit

	move.l bossWestAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
	move.w #.eyeBossLaunchpads,d0
	bsr .callBoss
	move.l a4,bossChildPointers+4(a0)
	clr.b objectListAttr(a4)	;hit permit
	clr.w objectListHit(a6)	; set eye object to invulnerable
	jmp (a5)

.main4	; sun boss
.sunBoss	SET 	100
.sunItself	SET		0
	move.l metEmitrAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
	move.w #.sunBoss,d0
	bsr .callBoss
	move.l a4,bossChildPointers+8(a0)

	move.l bossEastAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
	move.w #.sunItself,d0
	bsr .callBoss
	move.l a4,bossChildPointers(a0)	; east pointer
	clr.b objectListAttr(a4)	;hit permit

	move.l bossWestAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
	move.w #.sunItself,d0
	bsr .callBoss
	move.l a4,bossChildPointers+4(a0)
	clr.b objectListAttr(a4)	;hit permit
	jmp (a5)


.main0	; Facturo brick built boss
.brickBuildBoss	SET 	80
	move.l a6,bossVars+bossChildPointers+24
	lea dstrEventHToggle(pc),a4
	clr.b (a4)	; reset weap/sped upgr toggle
	move.l bossCntrAnimPointer(pc),a4	; central attached object
	move.w animTablePointer+2(a4),d4
	move.w #.brickBuildBoss+10,d0
	bsr .callBoss
	move.l a4,bossChildPointers+8(a0)
	clr.b objectListAttr(a4)	;hit permit

	move.l bossFinlAnimPointer(pc),a4	; main object
	move.w animTablePointer+2(a4),d4
	move.w #.brickBuildBoss-40,d0; ATTN real hitpoints defined in animCodeBossController!
	bsr .callBoss
	move.l a4,bossChildPointers+12(a0)
	move.l a4,objectListMyChild(a6)
	clr.b objectListAttr(a4)	;hit permit

	move.l bossEastAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
	move.w #.brickBuildBoss,d0
	bsr .callBoss
	move.l a4,bossChildPointers(a0)	; east pointer
	clr.b objectListAttr(a4)	;hit permit

	move.l bossWestAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
	move.w #.brickBuildBoss+20,d0
	bsr .callBoss
	move.l a4,bossChildPointers+4(a0)
	clr.b objectListAttr(a4)	;hit permit

	clr.w objectListHit(a6)	; set eye object to invulnerable
	jmp (a5)
.callBoss
	tst.w d0	; in case of undestructible object, keep hitpoints to zero
	beq initObject
	tst.b optionStatus(pc)
	spl d1
	ext.w d1
	andi.w #.easyDiffDownscale/3,d1
	sub.w d1,d0
	bra initObject

.main3	; snake boss
	;tst.b plyWeapUpgrade(a6)

	move.l bullEmitAnimPointer(pc),a4	; add bullet emitter to main object. Child would have been better solution, but does not work as this causes bugs with destruction code.
	move.w animTablePointer+2(a4),d4
	bsr initObject
	move.w #-1,objectListHit(a4)
	move.w a6,objectListGroupCnt(a4)
	move.l a6,bossChildPointers+(13*4)(a0)
	move.b #attrIsNotHitableF|attrIsLinkF,objectListAttr(a4); set link attribs, always draw

	move.w #.serpentHitpoints,d2
	tst.b optionStatus(pc)
	spl d1
	ext.w d1
	andi.w #.easyDiffDownscale<<2,d1
	sub.w d1,d2

	moveq #11,d1
.initSnake
.serpentHitpoints	SET	260<<2
	move.l serpBodyAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
	;clr.w d0
	;move.b .hitPoints(pc,d6.w),d0
	bsr initObject

	move.w d2,objectListHit(a4)
	move.l a4,bossChildPointers(a0)
	move.b #attrIsLinkF,objectListAttr(a4); set link attribs, always draw
	move.w a6,objectListGroupCnt(a4)
	lea 4(a0),a0
	dbra d1,.initSnake
	move.w d2,objectListHit(a6)

	move.b #attrIsLinkF,objectListAttr(a6); set link attribs, always draw
	move.w a6,objectListGroupCnt(a6)

	move.l bobSource(pc),a0
	move.w #$200-1,d1	; derived from .storeNoPosition (=$100 at time of writing)
.CLEARMEMORY
	clr.l -(a0)
	dbra d1,.CLEARMEMORY
	jmp (a5)

.main1	; ganton laser-spitting boss
	move.w #300<<2,d0
	tst.b optionStatus(pc)
	spl d1
	ext.w d1
	andi.w #.easyDiffDownscale<<2,d1
	sub.w d1,d0
	move.w d0,objectListHit(a6)
	jmp (a5)

.hitPoints
	dc.b 80,0,$24<<2,2,0	; easy
	dc.b 100,0,$34<<2,2,0	; hard
	even


