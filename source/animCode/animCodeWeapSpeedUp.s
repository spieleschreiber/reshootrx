
    ;	#MARK: - Speedup and Weapon Upgrade
       ;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter bitmap load adress


killTutorial
	;jmp (a3)
	move.l emtyAnimAnimPointer(pc),a1
	move.w animTablePointer+2(a1),d4
	move.l objectListMyChild(a2),a1
	cmp.l objectListMyParent(a1),a2	; a2 = self
	bne .noRelationship	; sometimes sprite manager kills objects at border - make sure intended relationship is still valid

	move.w d4,(a1)	; tutorial icon -> empty Anim
	moveq #1,d0
	move.b d0,objectListCnt(a1)
	move.b d0,objectListLoopCnt(a1)
	clr.l objectListMyParent(a1)
.noRelationship
	jmp (a3)

spedUpgr
	move.w frameCount+2(pc),d0
	andi #$f<<1,d0
	lea (a0,d0.w),a0 ; add anim offset

	bsr checkProximity
	
	cmpi.w #21,d0
	bhs upgrNoHit
	tst.w plyBase+plyCollided(pc)
	bne upgrNoHit

	lea .returnSped(pc),a3
	tst.l objectListMyChild(a2)
	bne killTutorial
.returnSped
	move.l cExplSmlAnimPointer(pc),a1
	move.w animTablePointer+2(a1),(a2)
	move.b #40,objectListCnt(a2)

	lea plyBase(pc),a1
	cmpi.w #plyAcclXMin+2*2,plyAcclXCap(a1) ; already got highest speed?
	bge.w upgrMaxedOut
	PLAYFX vocSpeedup
	add.w #2,plyAcclXCap(a1)
	add.w #2,plyAcclYCap(a1)
	ADDSCORE 2500
	bra animReturn
upgrMaxedOut
	ADDSCORE 5000
    PLAYFX 12
upgrNoHit
	lea killBounds(pc),a1
	bra killCheck	; check exit view

weapupgr
	move.w frameCount+2(pc),d0
	andi #$f<<1,d0
	lea (a0,d0.w),a0 ; add anim offset
	
	bsr checkProximity
	cmpi.w #21,d0
	bhs upgrNoHit
	tst.w plyBase+plyCollided(pc)
	bne upgrNoHit

	lea .returnWeap(pc),a3
	tst.l objectListMyChild(a2)
	bne killTutorial
.returnWeap
	move.l cExplSmlAnimPointer(pc),a1
	move.w animTablePointer+2(a1),(a2)
	move.b #40,objectListCnt(a2)
	
	lea plyBase(pc),a1
	cmpi.b #plyWeapUpgrMax,plyWeapUpgrade(a1) ; already got best weapon?
	bge upgrMaxedOut
	PLAYFX vocWeapon
	add.b #1,plyWeapUpgrade(a1)
	move.b plyWeapUpgrade(a1),d7
    clr.w d0
    move.b d7,d0
    subq.b #1,d7
    lsl #5,d7
    addq #1,d7
    move.b d7,plyWeapSwitchFlag(a1)
	ADDSCORE 2500
	bra animReturn

weapdstr
	lea plyPos(pc),a1
	move.b objectListCnt(a2),d0
	move.b d0,d4
	subq.b #1,d4
	move.b d4,plyDistortionMode(a1)
	bra animReturn


