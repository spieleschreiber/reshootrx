
; #MARK:  - COLLISSION MANAGER

collisionManager

	move		shotCount(pc),d7
	beq			irqDidColManager			; back to IRQ

	move.l		collidingList+8(pc),a3
	move.l		a3,a2
	lea			collListBobOffset(a2),a2
	move.l		a3,a5						; load adress of collision table
	moveq		#collListEntrySize,d4
	move.l		d4,a4						; preload some registers...

	clr.l		d0
	clr.l		d1
	clr.l		d2
	subq		#1,d7
	move		d7,d6

	move		bobCountHitable(pc),a1
	tst.w		a1
	beq			.chkBckCol
	moveq		#-34,d1						; y-offset
	sub.w		#1,a1

	lea			collTableYCoords(a2),a0

	move		#$81,a2						; x-offset (increase value -> move hitbox left
	;move plyBase+plyPosXDyn(pc),d4
	;sub d4,a2

.loadShot
	move		d1,d0
	add.w		collTableYCoords(a5),d0						; load shot y-coords

	move		a1,d6										; no of hitable objects
	move.l		a0,a6

	move.w		a2,d2
	add.w		collTableXCoords-2(a5),d2					; load shot x-coords; memory optimized for shots
	;MSG03 m2,d2
	;sub.w #10,d2	; optimal for 32 px objects
	;sub.w #32,d2	; optimal for 32 px objects
	move.w		8(a5),d4									; get sprite number
.chkBob

	move.l		(a6),d5
	cmp2.w		(a6),d0										;chk y-collissionbox collTableYCoords
	bcs.b		.noYCol										; is higher or lower? Skip!

	move.l		4(a6),d5
	cmp			d5,d2
	bgt.b		.noYCol
	swap		d5
	sub.w		(.colXWidth,pc,d4*2),d5
	cmp			d5,d2
	bge			.hitObjectBox
    ;cmp2.w 4(a6),a2; modified pointer to collTableXCoords
    ;bcc.w hitObject
.noYCol
	add.l		a4,a6
	dbra		d6,.chkBob
	add.l		a4,a5
	dbra		d7,.loadShot

	; #MARK:  check hit static
.chkBckCol

	lea			AddressOfYPosTable(pc),a0
	move.l		mainPlanesPointerAsync(pc),a1
	lea			24(a1),a1									; add x offset
	lea			80(a1),a1
	;move.l mainPlanesPointer(pc),a1
	;move.l mainPlanesPointer+4(pc),a2
	;move.l mainPlanesPointer+8(pc),a4


	moveq		#20,d5
	clr.l		d1
	clr.l		d2
	moveq		#collListEntrySize,d4
	moveq		#4,d7
	moveq		#-48,d0										;y-offset
	move		#$1a3,d5									;x-offset (159 if bitexact collission check)
	;sub.w plyPos+plyPosXDyn(pc),d5
	move.l		a3,a6
	lea			28,a5
	lea			$10,a4										; upper border check
	lea			$2d8,a3										; right border check
	move		shotCount(pc),d3
	bra			.firstLoop

	; #MARK:  check hit object
.hitObjectBox
	lea			AddressOfYPosTable(pc),a2
	move.l		mainPlanesPointer+4(pc),a1
	moveq		#-36,d4										;y-offset
    ;moveq #0,d4
	clr.l		d5
	move		#$120,d5									;x-offset
	;sub.w plyBase+plyPosXDyn(pc),d5
	move.w		#-4*mainPlaneDepth*mainPlaneWidth,d3
	add.w		collTableYCoords(a5),d4						; load player y-coords

	move.w		(a2,d4.w*2),d4								; y bitmap offset
	lea			(a1,d4.w),a1

	add.w		collTableXCoords-2(a5),d5
	ror.l		#3,d5
	lea			(a1,d5.w),a1								; add x-byte-offset
	clr.w		d5
	swap		d5
	rol			#3,d5										; put bit pointer in place
	; hitbox check triggered. Now check if actual pixels have been hit
	;bfset (a1,d3.w*2){d5:20}
	;bfset (a1){d5:20}
 	;bra .chkBckCol
	bftst		(a1){d5:20}
	bne			hitObject
	bftst		(a1,d3.w){d5:20}
	bne			hitObject
	bra			.chkBckCol

.chkBckLoop
	move		d0,d1
	add.w		collTableYCoords(a6),d1						; load shot y-coords
	cmp.w		a4,d1
	ble			.skipTest									; close to upper border? Skip!
	clr.l		d2
	move.w		(a0,d1.w*2),d2								; y bitmap offset
	move.w		collTableXCoords-2(a6),d1					; load shot x-coords
	cmp.w		a5,d1
	bls			.skipTest									; offscreen to the left
	add.w		d5,d1
	cmp.w		a3,d1
	bhi			.skipTest									; bullet offscreen to the right?
	move		d1,d6
	lsr			d7,d1
	lsl			#1,d1
	add.w		d1,d2										; add x-byte-offset

	move.w		d6,d1
	andi.w		#%1111,d1									; define left bit border
	move		collTableXCoords(a6),d6						; get sprite number
	add.w		((.bitModifier).W,pc,d6.w*2),d6				; define width of bitfield test
	;bfset (a1,d2.l){d1:d6}

	bftst		(a1,d2.l){d1:d6}
	bne.b		.hitBackground
.skipTest
	adda		d4,a6
.firstLoop
	dbra		d3,.chkBckLoop
.colQuit
	bra			irqDidColManager
.bitModifier
	dc.w		8,14,14,14
.colXWidth
	dc.w		11,18,18,18
.hitBckCoords
	dc.l		$00e0ffec,$00e0ffec							; main shot 0 and 1, 0.w = y-offset 1.w = x-offset
	dc.l		$00e8fff8,$00e8fff0							; right xtra shot, left xtra shot

	; #MARK:  hit static background

.hitBackground		; hit static background, draw damage

	tst.b		dialogueIsActive(pc)
	bne			irqDidColManager							; dialoge running->no shot<->bckgnd check

	;bra .skipBckMod
	moveq		#mainPlaneWidth+16,d7
	sub.l		d7,d2

	lea			fastRandomSeed(pc),a2
	movem.l		(a2),d0/d7									; AB
	swap		d7											; DC
	add.l		d7,(a2)										; AB + DC
	add.l		d0,4(a2)									; CD + AB
	andi.w		#$7,d0
	add.w		AddressOfYPosTable(pc,d0*2),d2				; add randomness to y-position
	;move.w AddressOfYPosTable(pc,d0*2),d0; add randomness to y-position
	andi		#$7,d7
	add.b		d7,d1										; add some randomness to x-position
	move.l		d1,d0
	lsr			#2,d7
	add			d7,d1										; modify x-position of upper line
	moveq		#2,d6
	lea			mainPlanesPointer(pc),a2
	move.l		fxPlanePointer(pc),a4
	lea			-mainPlaneWidth*7(a4),a4
.outerLoop
	move.l		(a2)+,a1									; loop 3 times -> three viewport buffers
	lea			(a1,d2.l),a1								; add x- and y-offset
	lea			mainPlaneWidth*4*256(a1),a3					; load pointer to 2nd screenbuffer
	cmp.l		a4,a3										; memory bound check - overrun?
	ble			.loop
	lea			-mainPlaneWidth*4*256(a1),a3				; yes. Modify pointer
.loop
	   ; bfclr (a1){d1:1}	; clear bits in main view - upper line
	bfclr		mainPlaneWidth(a1){d1:1}
	bfclr		mainPlaneWidth*2(a1){d1:1}					; two added bits -> shading
	bfclr		mainPlaneWidth*3(a1){d1:1}
	lea			mainPlaneWidth*4(a1),a1
	    ;bfclr (a1){d0:2}	; lower line
	bfclr		mainPlaneWidth(a1){d0:2}
	bfclr		mainPlaneWidth*2(a1){d0:2}
	bfclr		mainPlaneWidth*3(a1){d0:2}

	    ;bfclr (a3){d1:2}	; clear bits in secondary view
	bfclr		mainPlaneWidth(a3){d1:2}
	bfclr		mainPlaneWidth*2(a3){d1:2}
	bfclr		mainPlaneWidth*3(a3){d1:2}
	lea			mainPlaneWidth*4(a3),a3
	    ;bfclr (a3){d0:2}
	bfclr		mainPlaneWidth(a3){d0:4}
	bfclr		mainPlaneWidth*2(a3){d0:4}
	bfclr		mainPlaneWidth*3(a3){d0:4}
	dbra		d6,.outerLoop
.skipBckMod
	move.l		(a6),a0										; collTableAnimActionAdr -switch to exit anim
	move		collTableXCoords(a6),d0						; get sprite number
	andi		#$1f,d0

	move.l		([hitObjAnim.W,pc,d0.w*4]),a1				; get exit anim adress
	move.w		animTablePointer+2(a1),(a0)					;
	move.b		#6,objectListCnt(a0)						;

	PLAYFX		9
	move.l		((.hitBckCoords).W,pc,d0.w*4),d4			; modify coords for perfekt particle spawn
	move		d4,d3
	swap		d4
spawn
	add.w		collTableYCoords(a6),d4						; load shot y-coords
	clr.w		d5
    ;move.w plyBase+plyPosXDyn(pc),d6
    ;sub d6,d3
	clr.w		d6
	add.w		collTableXCoords-2(a6),d3					; load shot x-coords
	lsl			#4,d3
	lsl			#8,d4
	lea			emitterHitA(pc),a0
	pea			irqDidColManager(pc)						; push fake rts adress
	bra			particleSpawn								; call particles subroutine

hitObjAnim
	dc.l		cPlyShAXAnimPointer,	cPlyShBXAnimPointer	; pointers to basic exit anims
	dc.l		cPlyShCXAnimPointer, cPlyShDXAnimPointer


	; #MARK:  hit moving object

hitObject                   ; hit moving object. A5 = pointer to bullet adress, A6=pointer to target adress

	lea			plyBase(pc),a1
	add.w		#1,plyShotsHitObject(a1)					; reward accuracy in stage exit view
	move		collTableXCoords(a5),d0						; get sprite number
	andi		#$1f,d0
	move.l		([hitObjAnim.W,pc,d0.w*4]),a1				; get new anim adress
	suba.w		#4,a6
	move.l		(a5),a0										; collTableAnimActionAdr- handle player shot
	
	lea			scoreMultiplier+4(pc),a4
	move.l		a0,(a4)										; make available to chain score sprite spawn

	move.w		animTablePointer+2(a1),(a0)					; objectListAnimPtr. object hit, change to exit-animation

	move.b		#6,objectListCnt(a0)
	move.l		(a6),a0										; collTableAnimActionAdr - handle attacker object

	clr.l		d7
	clr.l		d5
	move.b		objectListAttr(a0),d6
	btst		#2,d6
	beq			singleObject

	tst.l		objectListMainParent(a0)					; is child object?
	bne			.hitRelatedObject
	tst.l		objectListMyChild(a0)						; is main parent?
	bne			.hitRelatedObject


;    move bobCountHitable(pc),d0                 ; hit group of objects
	move		objCount(pc),d6
	move.l		objectList(pc),a1

	suba.w		#4,a1
	move.w		objectListGroupCnt(a0),d3
	tst.w		objectListHit(a0)
	beq			hitObjectIsInvulnerable
	andi		#$fffc,objectListHit(a0)

	subq.w		#4,objectListHit(a0)
	IFEQ		MENTALKILLER
    ;bcs colHitKill
	beq			colHitKill
	bmi			colHitKill
	tst.b		plyBase+plyCheatEnabled(pc)
	bne			colHitKill
	ELSE
	move.w		#-1,objectListHit(a0)
	bra			colHitKill
	ENDIF
	move.w		objectListHit(a0),d0
	or.b		#$3,d0

; hit group / no destruction

	IFEQ		OBJECTSCORETEST
	ADDSCORE	1
	ENDIF
	move.w		#4,a4
.animsrchlist
	adda.w		a4,a1
	tst			(a1)
	beq.b		.animsrchlist
	btst.b		#2,objectListAttr(a1)
	beq.b		.noGroupedObject
	move.w		objectListGroupCnt(a1),d4
	cmp.w		d3,d4
	bne.b		.noGroupedObject
	move.l		a1,a6
	move.w		d0,objectListHit(a1)
.noGroupedObject
	dbra		d6,.animsrchlist
	move.l		a1,a6
	bra			colHit

; hit related object / no destruction

.hitRelatedObject
	IFEQ		OBJECTSCORETEST
	ADDSCORE	1
	ENDIF
;	bra			irqDidColManager
	move.l		objectListMainParent(a0),a6						; fetch main parent
	tst.l		a6
	bne			.hitChild
	move.l		a0,a6											; use parent adress
.hitChild

	tst.w		objectListHit(a6)
	beq			hitObjectIsInvulnerable


	andi		#$fffc,objectListHit(a6)
	subq.w		#4,objectListHit(a6)

	IFEQ		MENTALKILLER
	bmi			colHitKill
	beq			colHitKill
	tst.b		plyBase+plyCheatEnabled(pc)
	bne			colHitKill
	ELSE
	move.w		#-1,objectListHit(a0)
	bra			colHitKill
	ENDIF
	;btst #2,objectListAttr(a2)
	;beq colHit
	move.w		objectListHit(a6),d0
	or.b		#$3,d0
.loopRelationship
	move.w		d0,objectListHit(a6)							; mark every child as hitframe

	move.l		objectListMyChild(a6),a6
	tst.l		a6
	bne			.loopRelationship
	bra			colHit


singleObject

	clr.l		d0
	tst.w		objectListHit(a0)
	beq			hitObjectIsInvulnerable							; object hitable, not destroyable

	andi		#$fffc,objectListHit(a0)
	subq.w		#4,objectListHit(a0)							; hit single object
    ;bcs colHitKill                                 ; hit but hitpoints left
	IFEQ		MENTALKILLER
	beq			colHitKill
	bmi			colHitKill
	tst.b		plyBase+plyCheatEnabled(pc)
	bne			colHitKill
	ELSE
	move.w		#-1,objectListHit(a0)
	bra			colHitKill
	ENDIF
	or.b		#$3,objectListHit+1(a0)							; init blitz
	move.l		a0,a6
          ; hit objects / not destroyed
	clr.w		d0
	add.w		objectListHit(a6),d0
colHit
	lsr			#2,d0
	add			#periodBase,d0
	lea			(fxImpactEnem*fxSizeOf)+fxTable+6-12(pc),a0
	move.w		d0,(a0)											; store modified hitpoints -> fx pitch
	IFEQ		OBJECTSCORETEST
	ADDSCORE	1
	ENDIF
	PLAYFX		fxImpactEnem
; particles after hit moving object
spawnHitParticles
;	bra irqDidColManager

	;move #$a0,a3	; calc x-position of particle emitter

		;move.l #$30,d4
		;move.l #$
		;	bra spawn
;	clr.l d3
    ;sub.w plyBase+plyPosXDyn(pc),d3
;	sub #18,d3
	moveq		#-18,d3
	add.w		collTableXCoords-2(a5),d3
	move		d3,d5
	lsr			#4,d5
	sub			#8,d5											; start particles with some "drall"
	lsl			#4,d3
	moveq		#-27,d4
	add.w		collTableYCoords(a5),d4
	clr.w		d6
	lsl			#8,d4

	lea			emitterHitA(pc),a0								; switch two emitters randomly
	btst		#1,frameCount+5(pc)
	beq			.keepA
	lea			emitterHitB-emitterHitA(a0),a0
.keepA
	pea			irqDidColManager(pc)							; push fake rts adress
	bra			particleSpawn									; call subroutine

hitObjectIsInvulnerable
	PLAYFX		9
	bra			spawnHitParticles

		; #MARK:  killed moving object

colHitKill
	tst.l		objectListMyChild(a0)
	bne			.singleOrFamilyObject
	tst.l		objectListMyParent(a0)
	bne			.singleOrFamilyObject							; prioritize related objects to grouped objects

	btst.b		#2,objectListAttr(a0)
	bne			.killGroupedObject								; hit object of grouped origin

.singleOrFamilyObject
	move.l		objectListMainParent(a0),d0
	beq			.singleObject
	move.l		d0,a0											; get main parent
.singleObject
	clr.l		d5												; hit and killed
	move		(a0),d5											;objectListAnimPtr
	move.l		(animDefs,pc),a6
	lea			(a6,d5),a6
	clr.l		d4
	move.b		animDefType(a6),d4
	move.l		(objectDefs,pc),a4
	lea			(a4,d4*8),a4
	move		objectDefScore(a4),d0
	add.w		d0,scoreAdder

	bclr.b		#1,objectListHit+1(a0)

	tst.b		objectListDestroy(a0)
	bne			.destroySpecial
.retDestrSpecNotGrouped

	clr.w		d0
	move.b		objectDefHeight(a4),d0
	cmpi.b		#48,d0
	bhi			.explLrg
	cmpi.b		#16,d0
	bhi			.explMed

		; #MARK:  init small explosion
.explSml
	move.l		cExplSmlAnimPointer(pc),a4
	move.w		animTablePointer+2(a4),(a0)						; objectListAnimPtr. object hit, change to explosion animation

	andi.b		#%10111010,objectListAttr(a0)					; clr opaque, group, refresh  bit
	bset		#attrIsNotHitable,objectListAttr(a0)			; set not hitable bit

	move.b		#31,objectListCnt(a0)

	move.w		viewPosition+viewPositionAdd(pc),d6
	lsl			#8,d6
	add			#-80,d6
	move.w		d6,objectListAccY(a0)
	move		frameCount+4(pc),d0
	andi		#%1110,d0
	sub			#%1110>>1,d0
	lsl			#4,d0
	move		d0,objectListAccX(a0)							; vary x-acceleration a little bit


;    clr.w objectListAccX(a0)
.addSoundFX
	PLAYFX		3
	bra			.parentalCheck

	; #MARK:  init medium explosion

.explMed

	move.l		cExplMedAnimPointer(pc),a1
	move.w		animTablePointer+2(a1),(a0)						; objectListAnimPtr. object hit, change to explosion animation

	andi.b		#%10111010,objectListAttr(a0)					; clr opaque, group, refresh   bit
	bset		#attrIsNotHitable,objectListAttr(a0)			; set not hitable bit
	move.b		#$3f,objectListCnt(a0)

	move.w		viewPosition+viewPositionAdd(pc),d6
	lsl			#8,d6
	move.w		d6,objectListAccY(a0)
	move		frameCount+4(pc),d0
	andi		#%1110,d0
	sub			#%1110>>1,d0
	lsl			#4,d0
	move		d0,objectListAccX(a0)							; vary x-acceleration a little bit

	move.l		a0,a6
	move.l		cExplSmlAnimPointer(pc),a4
	move.w		animTablePointer+2(a4),d4						;add small explosion just for the looks...
	move		#144,d5
	;add.w plyBase+plyPosXDyn(pc),d5
	add.w		collTableYCoords+2(a5),d5						; get x-coord from shot
	move.w		#-10,d6
	add			objectListY(a0),d6								; get y-coord
	st.b		d3
	bsr.w		objectInit
	tst.l		d6
	bmi			irqDidColManager
;    move #0,objectListHit(a4); hitpoints
	move.b		#attrIsNotHitableF,objectListAttr(a4)			; attribs

	move.b		#$7f,objectListCnt(a4)
	add			#-$380,objectListAccY(a4)
	;clr.w objectListAccY(a4)
	andi		#%11100000,d6
	sub			#%11100000>>1,d6
	move		d6,objectListAccX(a4)							; vary y-acceleration a little bit
	PLAYFX		4

.parentalCheck
	tst.l		objectListMyChild(a0)
	bne.b		.isParent										; hit object is parent?
	tst.l		objectListMyParent(a0)
	bne.b		.isParent										; hit object is child?

	move.b		objectListWaveIndx(a0),d7
	tst.b		objectListWaveIndx(a0)
	bpl			.isWave
	bra			irqDidColManager

.isParent		; find child objects
	move.l		objectListMainParent(a0),a6						; get main parent of hit object.
	tst.l		a6												; is hit object main parent itself?
	bne			.hitChild										; no
	move.l		a0,a6											; yes. copy main parent adress at relevant registers
.hitChild
	move.l		objectListMyChild(a6),a5						; get first child of main parent
	move.l		objectListX(a6),d6								; get world coords main parent
	move.l		objectListY(a6),d7

.loopRelatives
	move.w		(a5),d5											;objectListAnimPtr
	lea			([animDefs,pc],d5.w),a1
	clr.w		d5
	move.b		animDefType(a1),d5
	lea			([objectDefs,pc],d5.w*8),a1						; Pointer to ObjectDefinitions
	move.b		objectDefHeight(a1),d5							; fetch size of object

	cmpi.b		#35,d5
	shi			d4
	cmpi.b		#16,d5
	shi			d5
	andi.b		#16,d5
	andi.b		#16,d4
	add.b		d4,d5											; and determine size of explosion
	move.l		cExplSmlAnimPointer(pc,d5.w),a1
	move.w		animTablePointer+2(a1),(a5)						; objectListAnimPtr. object hit, change to explosion animation

	andi.b		#%10111010,objectListAttr(a5)					; clr opaque, group, link   bit
	bset		#attrIsNotHitable,objectListAttr(a5)			; set not hitable bit

	lsl			objectListAccY(a5)								; improve dynamics
	lsl			objectListAccY(a5)

	lsl			objectListAccX(a5)								; improve dynamics
	lsl			objectListAccX(a5)

	move.b		#31,objectListCnt(a5)							; duration of child explosion
	move.b		#1,objectListLoopCnt(a5)						;

	move.w		objectListX(a5),d4
	lsl			#4,d4
	move.w		d4,objectListAccX(a5)

	add.l		objectListX(a5),d6
	move.l		d6,objectListX(a5)								; modify object position to make it work without parent relationship


	add.l		objectListY(a5),d7
	move.l		d7,objectListY(a5)								; ""

	clr.l		objectListMyParent(a5)							; cancel relationship to enhance explosion dynamics, and enhance object management reliability
	clr.l		objectListMainParent(a5)
.isMainParent
	move.l		objectListMyChild(a5),d5
	clr.l		objectListMyChild(a5)
	move.l		d5,a5
	tst.l		a5
	bne			.loopRelatives
	bra			irqDidColManager


	; #MARK:  init large explosion

.explLrg
	move.l		cExplLrgAnimPointer(pc),a1
	move.w		animTablePointer+2(a1),(a0)						; objectListAnimPtr. object hit, change to explosion animation
	andi.b		#%10111010,objectListAttr(a0)					; clr opaque, group   bit
	bset		#attrIsNotHitable,objectListAttr(a0)			; set not hitable bit
	move.b		#$31,objectListCnt(a0)

	move.w		viewPosition+viewPositionAdd(pc),d6
	lsl			#8,d6
	move.w		d6,objectListAccY(a0)
	move		frameCount+4(pc),d0
	andi		#%1110,d0
	sub			#%1110>>1,d0
	lsl			#4,d0
	move		d0,objectListAccX(a0)							; vary x-acceleration a little bit

	;bra .parentalCheck

	move.l		cExplSmlAnimPointer(pc),a1
	move.w		animTablePointer+2(a1),d4						;add med explosion replacing shot
	move		#134,d5
	;sub.w plyBase+plyPosXDyn(pc),d5
	add.w		collTableYCoords+2(a5),d5						; get x-coord from shot
	moveq		#40,d6
	add			objectListY(a0),d6								; get y-coord
	st.b		d3
	bsr.w		objectInit
	tst.l		d6
	bmi			irqDidColManager								; back to IRQ
        ;move #0,objectListHit(a4); hitpoints
	move.b		#attrIsNotHitableF,objectListAttr(a4)			; attribs
	move.w		viewPosition+viewPositionAdd(pc),d6
	add.w		#-$480,d6
	move.w		d6,objectListAccY(a4)
	move.b		#$2c,objectListCnt(a4)

	move.l		cExplMedAnimPointer(pc),a1
	move.w		animTablePointer+2(a1),d4						;add med explosion just

	moveq		#-22,d5
	add.w		objectListX(a0),d5								; get x-coord from shot
	moveq		#20,d6
	add			objectListY(a0),d6								; get y-coord

	st.b		d3
	bsr.w		objectInit
	tst.l		d6
	bmi			irqDidColManager								; back to irq
    ;move #0,objectListHit(a4); hitpoints
	move.b		#attrIsNotHitableF,objectListAttr(a4)			; attribs
	sub			#$400,objectListAccY(a4)
	move		#-565,objectListAccX(a4)
	move.b		#$1f,objectListCnt(a4)

	move.l		cExplMedAnimPointer(pc),a1
	move.w		animTablePointer+2(a1),d4
    ;add explosion just for the looks...
	moveq		#20,d5
	add.w		objectListX(a0),d5								; get x-coord from shot
	moveq		#-10,d6
	add			objectListY(a0),d6								; get y-coord
	st.b		d3
	bsr.w		objectInit
	tst.l		d6
	bmi			irqDidColManager								; back to IRQ
	sub			#$450,objectListAccY(a4)
	move		#625,objectListAccX(a4)
	move.b		#$17,objectListCnt(a4)							; hitpoints
	move.b		#attrIsNotHitableF,objectListAttr(a4)			; attribs

	PLAYFX		5
	bra			.parentalCheck
.addSmlExplosion


	; kill tentactle and other grouped objects

.killGroupedObject

	move		(a0),d5									;objectListAnimPtr	; get score
	move.l		(animDefs,pc),a5
	lea			(a5,d5),a5
	clr.l		d4
	move.b		animDefType(a5),d4
	move.l		(objectDefs,pc),a4
	lea			(a4,d4*8),a4
	move		objectDefScore(a4),d1
	clr.w		d5										; hit and killed
	move.b		objectDefHeight(a4),d5
	move.w		d5,d4
	lsr			#1,d4
	add.w		d4,objectListY(a0)
	;move.w d5,d4
	lea			scoreAdder(pc),a3

	move.w		#4,a4

	cmpi.b		#160/2,d5
	shi			d7
	cmpi.b		#35/2,d5
	shi			d5
	andi.b		#16,d5
	andi.b		#16,d7
	add.b		d7,d5
	move.l		cExplSmlAnimPointer(pc,d5.w),a5
	move.w		animTablePointer+2(a5),d7
	moveq		#31,d6
	sub.w		a6,a6

	move.w		viewPosition+viewPositionAdd(pc),d2
	lsl			#8,d2
	add			#-30,d2

	move.l		objectList+4(pc),a1
	lea			-4(a1),a1
	move.w		objectListGroupCnt(a0),d3

	move.w		objCount(pc),d0
	sub.w		shotCount(pc),d0
	sub			#1,d0
.animsrchlistX
	adda.w		a4,a1
	tst.w		(a1)
	beq.b		.animsrchlistX
	btst.b		#attrIsLink,objectListAttr(a1)
	beq.b		.noGroupedObjectX
	move.w		objectListGroupCnt(a1),d4
	cmp.w		d3,d4
	bne.b		.noGroupedObjectX
	tst.w		a6
	beq.b		.cancelGroup
.return
	;MSG01 m2,d4
	;add.w d4,objectListY(a1)


	move.w		d7,(a1)									; objectListAnimPtr. object hit, change to explosion animation
	andi.b		#%10111011,objectListAttr(a1)			; clr opaque, group   bit
	bset		#5,objectListAttr(a1)					; set not hitable bit

	;add.w d2,objectListAccY(a1)

	;lsl objectListAccY(a1)       ; vary y-acceleration a little bit

	;lsl objectListAccX(a1)       ; vary y-acceleration a little bit
	move		d0,d5
	lsl			#1,d5
	andi		#$f,d5
	add.w		d6,d5
	move.b		d5,objectListCnt(a1)
	add			d1,(a3)

	;pea .noGroupedObjectX(pc)
	;tst.b objectListDestroy(a0)
	;bne .destroySpecial
	;addq #4,sp
.noGroupedObjectX
	;bra irqDidColManager
	dbra		d0,.animsrchlistX


	PLAYFX		5
	bra			irqDidColManager
.cancelGroup	; modify counter in case linked group has not yet fully spawned before hitpoints=0
	add			#1,a6
	move.l		objectListLaunchPointer(a1),a5
	tst.l		a5										; some object waves are not listlaunched, but manually linked. Do not need nor store repeat pointer. Quit.
	beq			.return
	clr.w		(a5)
	clr.b		launchTableRptCountdown(a5)
	bra			.return

.isWave				; is in of obj wave?
	clr.w		d0
	move.b		objectListWaveIndx(a0),d0
	lea			objCopyTable(pc),a1
	sub.b		#1,(a1,d0)
	bne			irqDidColManager						; back to IRQ
	IFEQ		OBJECTSCORETEST
	ADDSCORE	5000
	ENDIF
	move.l		waveBnusAnimPointer(pc),a4
	move.w		animTablePointer+2(a4),d4				;add bonus display
	move		objectListX(a0),d5
	sub			#$15,d5
	move		objectListY(a0),d6
	st.b		d3
	bsr			objectInit
	tst.l		d6
	bmi			.quitWave
	move.l		viewPosition+viewPositionAdd(pc),d2
	asr.l		#8,d2
	sub			#100,d2
	move.w		d2,objectListAccY(a4)					; float up, regardless of scrollspeed

	lea			plyBase(pc),a4
	add.w		#1,plyWaveBonus(a4)						; add one with each chain spawn. Query in achievements screen

    ; is sprite therefore attribs are assigned by objects-list. $40=bonus icon
.quitWave
	bra			irqDidColManager

	; #MARK:  object destroy special events (debris etc.)

	; insert "code destroyX" into anims-list to add post-death-event
	; 	destroyA	->	init debris 8 pcs
	;	destroyB	->	init debris 16 pcs
	;	destroyC	->	launch autotarget projectile
	;	destroyD	->	force small explosion
	;	destroyE	->	force medium explosion
	;	destroyF	->	force large explosion
	;	destroyG	->	draw relicts to bitplane
	;	destroyH	->	launch weap or speed upgrades
	;	destroyI	->	set global trigger2 | ATTN: Reset trigger2 in object waiting for trigger2-event, using animlist. Use animlist command "code setTrigs" to reset all global triggers.
	;	destroyJ	->	special for boss 3 (snake) - kill attached bullet emitter object
	;	destroyK	->	quit current animlist loop and init alt. animlist entry. Used with mid boss stage 4
	;	destroyL	->	test for facturo boss stage 0 / sky

.rasterCritical		SET					200
.destroySpecial

	clr.w				d4
	move.b				objectListDestroy(a0),d4
	clr.b				objectListDestroy(a0)						; avoid re-init
	move.w				(.destroyJmpTable-2,pc,d4*2),d4
	lea					debrisA3AnimPointer(pc),a2
	moveq				#5,d2
.dstrOffset
	jmp					.dstrOffset(pc,d4)
.dstrEventB
	lea					killShakeIsActive(pc),a1
	move.b				#7,(a1)

	lea					16(a2),a2									; modify pointer to debrisA4AnimPointer
	addq				#6,d2										; add more debris objects
.dstrEventA
	;bra .retDestrSpecNotGrouped
	SAVEREGISTERS
	clr.l				d4
	move.l				debrsObjAnimPointer(pc),a4
	move.w				animTablePointer+2(a4),d4
	clr.l				d5
	clr.l				d6
	move.w				objectListX(a0),d5
	move.w				objectListY(a0),d6

	st.b				d3
	bsr					objectInit									; spawn post-explosion debris controller Object
	tst.l				d6
	bmi.b				.dstrQuit									; no more object slots available
	move.w				objectListX(a0),d5
	swap				d5
	move.w				#8,d5
	add.w				objectListY(a0),d5
	move.l				(a2),a2
	move.w				animTablePointer+2(a2),d0
	swap				d0
	move.l				viewPosition+viewPositionAdd(pc),d1
	lsr.l				#7,d1
	swap				d1
	move				#$600,d0
	sub.w				d1,d0
	;move.w #-$180,d0
	;move.w d1,d0
	move.l				d0,objectListTriggers(a4)					; store animPointer, y-acceleration
	move.l				d5,objectListTriggersB(a4)					; store x- and y-position

	move.w				rasterBarNow(pc),d5							; fetch total system load, value 0-255
	lsr					#6,d5
	lsr.b				d5,d2										; more onscreen action -> less debris
	add.b				#2,d2

	move.b				d2,objectListCnt(a4)						; object lifetime determines number of debris
.dstrQuit
	RESTOREREGISTERS
	bra					.retDestrSpecNotGrouped
.dstrEventC
	SAVEREGISTERS
	lea					.ret(pc),a5
	move.l				a0,a6
	bra					homeShot
.ret
	bra					.dstrQuit

.dstrEventD			; force small explosion
	move.l				a0,a6
	bra					.explSml
.dstrEventE			; force medium explosion
	lea					killShakeIsActive(pc),a1
	move.b				#3,(a1)
	move.l				a0,a6
	bra					.explMed
.dstrEventF			; force large explosion
	lea					killShakeIsActive(pc),a1
	move.b				#7,(a1)
	move.l				a0,a6
	bra					.explLrg
.dstrEventG		; copy boss bob bitmap data to playfield
	SAVEREGISTERS
	lea					plyBase+plyDistortionMode(pc),a1
	sf.b				(a1)										; stop screenshake (beam heat)

	clr.l				d5
	move.w				objectListY(a0),d5
	sub.w				viewPosition+viewPositionPointer(pc),d5
	move.w				AddressOfYPosTable(pc,d5*2),d5				; get y-adress

	move				objectListX(a0),d7
	moveq				#-64,d4
	add.w				d7,d4
;	sub.w plyPos+plyPosXDyn(pc),d5;Convert absolute to relative
	lsr					#4,d4										; set x-pos
	bclr				#0,d4
	add.w				d4,d5
	ext.l				d5
	move.l				d5,a5
	;add.l #3*40,a5
	move				(a0),d5										;objectListAnimPtr	; get score
	move.l				(animDefs,pc),a1
	lea					(a1,d5),a1
	clr.l				d4
	move.b				animDefType(a1),d4
	move.l				(objectDefs,pc),a4
	lea					(a4,d4*8),a4
	move.l				(a4),a0										;objectDefSourcePointer
	adda.l				bobSource(pc),a0							; Adress of sourcebitmap
	move.l				a0,a6
	move.l				mainPlanesPointer+0(pc),a1
	bsr					.copy

	move.l				a6,a0										;objectDefSourcePointer
	move.l				mainPlanesPointer+4(pc),a1
	bsr					.copy

	move.l				a6,a0										;objectDefSourcePointer
	move.l				mainPlanesPointer+8(pc),a1
	bsr					.copy
	bra					.dstrQuit
.copy
	lea					(a1,a5.l),a1
	move				#46,d1										; object heigth
	lea					7*8(a0),a2									; pointer to cookie
	lea					(56+56),a3
	bra					mergeObjectToBitmap
.dstrEventH
	;tst.b optionStatus(pc)
	;bmi .dstrEventF	; diff is high? No extra icon
	SAVEREGISTERS
	lea					dstrEventHToggle(pc),a4
	move.b				(a4),d0
	andi.w				#1,d0
	lsl.b				#4,d0
	add.b				#1,(a4)
	move.l				weapUpgrAnimPointer(pc,d0),a4				; fetch weapUpgr or spedUpgr Animpointer
	clr.w				d0
	bsr					initObject
	move.l				a0,a6
	bsr					getCoordsBlitter
	;clr.l objectListAccX(a4)
	move.b				#1,objectListCnt(a4)
	move.w				d5,objectListX(a4)
	move.w				d6,objectListY(a4)
	move.w				#100,objectListAccY(a4)						; spiral downwards
	move.b				#attrIsNotHitableF,objectListAttr(a4)		; cannot be hit
	RESTOREREGISTERS
	bra					.dstrEventF
.dstrEventI
	lea					animTriggers+2(pc),a4
	st.b				(a4)
	bra					.dstrEventF
.dstrEventJ			; kill boss 3 snake bullet emitter object

	lea					bossVars+bossChildPointers+(13*4)(pc),a6
	move.l				(a6),a6
	move.l				emtyAnimAnimPointer(pc),a0
	move.w				animTablePointer+2(a0),d4
	move.w				d4,(a6)
	move.b				#1,objectListCnt(a6)
	bra					.retDestrSpecNotGrouped

.dstrEventK			; quit current animlist loop and init alt. animlist entry. Used with mid boss stage 4

	;	move.w objectListHit(a6),d0
	;or.b #$3,d0
;.loopRelationship
	;move.w d0,objectListHit(a6)	; mark every child as hitframe

	;move.l objectListMyChild(a6),a6
	;tst.l a6
	;bne .loopRelationship
	;bra colHit
	; a0 contains pointer to main parent
	move.l				mechMedMAnimPointer(pc),a1
	move.w				animTablePointer+2(a1),(a0)					; switch to exit animation
	move.b				#1,objectListCnt(a0)
	move.b				#1,objectListLoopCnt(a0)					; quit current wait loop
	asr.w				objectListAccX(a0)
	asr.w				objectListAccX(a0)
	asr.w				objectListAccX(a0)
	asr.w				objectListAccY(a0)
	;move.w #200,objectListAccY(a0)

	move.w				#0<<2,objectListHit(a0)						; set to indestructible
	move.b				#attrIsNotHitableF,objectListAttr(a0)

	move.l				objectListMyChild(a0),a0					; get left wing
	move.w				#0<<2,objectListHit(a0)
	move.b				#attrIsNotHitableF,objectListAttr(a0)

	move.l				objectListMyChild(a0),a0					; get central piece (exhaust)
	move.b				#1,objectListLoopCnt(a0)
	move.w				#0<<2,objectListHit(a0)						; set to indestructible
	move.b				#attrIsNotHitableF,objectListAttr(a0)

	move.l				objectListMyChild(a0),a0					; get right wing
	move.w				#0<<2,objectListHit(a0)						; set to indestructible
	;move.b #1,objectListLoopCnt(a0)	; quit current wait loop
	move.b				#attrIsNotHitableF,objectListAttr(a0)
	bra					irqDidColManager

.dstrEventL; fix to kill crash with mid boss stage 2
	move.l				bossVars+bossChildPointers+36(pc),a1		; get main parent
	move.w				objectListX(a0),d0
	add.w				objectListX(a1),d0
	move.w				d0,objectListX(a0)							; modify x|y-position
	move.w				objectListY(a0),d0
	add.w				objectListY(a1),d0
	move.w				d0,objectListY(a0)
	clr.l				objectListMyParent(a0)
	clr.b				objectListAttr(a0)
	bra					.dstrEventH

.destroyJmpTable
	dc.w				.dstrEventA-.dstrOffset-2
	dc.w				.dstrEventB-.dstrOffset-2
	dc.w				.dstrEventC-.dstrOffset-2
	dc.w				.dstrEventD-.dstrOffset-2
	dc.w				.dstrEventE-.dstrOffset-2
	dc.w				.dstrEventF-.dstrOffset-2
	dc.w				.dstrEventG-.dstrOffset-2
	dc.w				.dstrEventH-.dstrOffset-2
	dc.w				.dstrEventI-.dstrOffset-2
	dc.w				.dstrEventJ-.dstrOffset-2
	dc.w				.dstrEventK-.dstrOffset-2
	dc.w				.dstrEventL-.dstrOffset-2
dstrEventHToggle
	dc.b				0
	even

								RSRESET
postDestroy						rs.b				1
postDestroyLowDebris			rs.b				1
postDestroyHighDebris			rs.b				1
postDestroyLaunchHomeshot		rs.b				1
postDestroyForceSmlExplosion	rs.b				1
postDestroyForceMedExplosion	rs.b				1
postDestroyForceLrgExplosion	rs.b				1
postDestroyCopyBobToBitmap		rs.b				1
postDestroyLaunchExtra			rs.b				1