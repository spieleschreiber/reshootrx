
   ;!!!: Animcode: code called from each frame update. Usually used for bitmap animation, but can do other things too
	;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter bitmap load adress or use a0 if return to bobblitnext / not animreturn
	    cnop 0,4


STEALTHDEBUG	SET	0	; set to 1 to init stealth immediately
BEAMDEBUG	SET	0	; set to 1 to init beam immediately. ATTN: Need to set coords of collidingbox manually!

bossCtrl
.boss
	; de-comment MSGACCL into code, to examine current object accl values, and animlist accl values
	;MSGACCL
;	move.l animTriggers(pc),d7
;	move.l objectListTriggers(a2),d7
;	move.l objectListTriggersB(a2),d7

	lea bossVars+bossHitCmp(pc),a1
	move.w (a1),d7
	move.w objectListHit(a2),d6
	beq.b .notHit
	move.w d6,(a1)
	cmp.w d7,d6
	beq .notHit
	lea killShakeIsActive(pc),a1
	tst.b (a1)
	bne .notHit
	move.b #3,(a1)
.notHit
	lea bossVars(pc),a1
	move.w gameStatusLevel(pc),d0
	move.w (.bossJmpTable,pc,d0.w*2),d0
.jmpBoss	jmp .jmpBoss(pc,d0.w)
.bossJmpTable
	dc.w .main1-.bossJmpTable+2	; sun
	dc.w .main0-.bossJmpTable+2	;
	dc.w .main2-.bossJmpTable+2	;
	dc.w .main3-.bossJmpTable+2
	dc.w .main4-.bossJmpTable+2

	;	#MARK: - .1 launch stealth object

.main	; boss main controller


;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter bitmap load adress or use a0 if

	;	#MARK: - Stage 1 controller / Sky - Facturo Boss

	;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter bitmap load adress or use a0 if return to bobblitnext / not animreturn
	; all turret hit forbidden in bossInit code. Each turret needs dedicated hit permit to allow kill

.main1

	lea (animTriggers,pc),a3
	move.b 3(a3),d0
	beq animReturn	; initial phase, no need to check children objects status
	cmpi.b #1,d0
	beq .main1attachObjects
	tst.b objectListTriggersB+3(a2)
	bne .wipeBitmap
.wipeBitmapRet
	lea bossVars(pc),a1
	;move.b #attrIsNotHitableF,objectListAttr(a2)

	lea 12(a0),a0	; paint full central body with destroyed attachment visuals

	move.l bossChildPointers+4(a1),a3
	move.w (a3),d7
	beq .main1phase2	; second turret killed?
	tst.l objectListMyParent(a3)
	beq .main1phase2 ; object got no parent? Then bullet has taken over this slot
	;animate first turret
	clr.b objectListAttr(a3)	;hit permit
	bra animReturn
.main1phase2
	move.l bossChildPointers(a1),a3
	move.w (a3),d7
	beq .main1phase3	; second turret killed?
	tst.l objectListMyParent(a3)
	beq .main1phase3 ; object got no parent? Then bullet has taken over this slot

	clr.b objectListAttr(a3)	;hit permit
	lea (animTriggers,pc),a3
	move.b (a3),1(a3)
	bra animReturn
.main1phase3
	move.l bossChildPointers+8(a1),a3
	move.w (a3),d7
	beq .main1phase4	; second turret killed?
	tst.l objectListMyParent(a3)	; object got no parent? Then bullet has taken over this slot
	beq .main1phase4
	clr.b objectListAttr(a3)	;hit permit
	lea (animTriggers,pc),a3
	move.b (a3),2(a3)
	bra animReturn
.main1phase4
	cmpi.b #3,d0
	bne .main1initPhase4
	lea (animTriggers,pc),a3
	move.b (a3),1(a3)
	move.b (a3),2(a3)
	bra animReturn
.main1initPhase4	; init final boss
	lea (animTriggers,pc),a3
	move.b #3,3(a3)
	clr.b objectListAttr(a2)
	move.w #100<<2,objectListHit(a2)	; final boss hitpoints
	bra animReturn
.wipeBitmap
	move.b objectListTriggersB+3(a2),d7
	sub.b #1,objectListTriggersB+3(a2)
	andi.b #$3f,d7
	eor.b #$3f,d7
	add.b #144,d7
	movem.l a0/a2/a6/d2/d3,-(sp)
	cmpi.b #$b0,d7
	shi d3	; set to -1 if d7 higher than $a0/upper rows of bitmap area. This way, blitted boss does not get corrupted && final rows of tiled landscape gets cleaned properlay
	bsr wipeBitmap
	movem.l (sp)+,a0/a2/a6/d2/d3
	bra .wipeBitmapRet

.main1attachObjects
	move.b #$80+$7f,objectListTriggersB+3(a2)	; init wipeBitmap row counter
.attachObjects
	move.b #2,3(a3)
	lea bossVars(pc),a1
	move.l a2,bossChildPointers+36(a1)
	moveq #3,d7
.attach
	move.l bossChildPointers(a1),a3
	tst.l a3
	beq .noObject
	move.w (a3),d0	; fetch animlist pointer for compare
	move.w d0,bossChildPointers+16(a1)
	move.l a2,objectListMyParent(a3)

	move.l a3,objectListMyChild(a3)
	move.w objectListX(a3),d0
	sub.w objectListX(a2),d0
	move.w d0,objectListX(a3)	; modify x|y-position
	move.w objectListY(a3),d0
	sub.w objectListY(a2),d0
	move.w d0,objectListY(a3)
	clr.l objectListAcc(a3)	; static object
	st.b objectListTriggersB(a3); mark as container object
	move.b #attrIsNotHitableF,objectListAttr(a3)
.noObject
	lea 4(a1),a1
	dbra d7,.attach
	bra animReturn




	;	#MARK: - Stage 3 controller / Serpentir

	;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter bitmap load adress or use a0 if return to bobblitnext / not animreturn
	; all turret hit forbidden in bossInit code. Each turret needs dedicated hit permit to allow kill


	; ATTN Positions Store Memory Area cleared in bossInit-code

.resetPositionStorage
	move.l bobSource(pc),a4
	move.w #$200-1,d0	; derived from .storeNoPosition (=$100 at time of writing)
.CLEARMEMORY
	clr.l -(a4)
	dbra d0,.CLEARMEMORY
	move.b d1,objectListTriggersB+2(a2)
	bra .storageReady
.playerFatal
	move.b #10,objectListCnt(a2)
	clr.l objectListAcc(a2)
	bra animReturn
.main3
	tst.b plyBase+plyWeapUpgrade(pc)
	bmi .playerFatal
	;bra animReturn
.storeNoPositions	SET	$100
.noOfElementsTotal	SET	12
.positionOffset		SET	$40/(.noOfElementsTotal-1)

	; adjust object spacing depending on acceleration, set  objecttriggers+2
	; add "code trig?" to animlist
	;	trig1557	spacing 21	; 	biggest gap, low speed
	;	trig1544	spacing 12	; 	medium speed
	;	trig1544	spacing 8	;	fast speed


	movem.l a1-a6/d0-d7,-(sp)

	lea bossVars(pc),a1
	lea (animTriggers,pc),a3
	move.l bobSource(pc),a5	; copperlist memory placed right infront of bobSource. Use to store main object position
	lea -8*.storeNoPositions(a5),a5
	move.b objectListTriggers+2(a2),d1
	cmp.b objectListTriggersB+2(a2),d1
	bne .resetPositionStorage
.storageReady
	ext.w d1

	move.w d1,a6
	move.b objectListTriggers+3(a2),d0
	move.b d0,d1
	sub.b #1,objectListTriggers+3(a2)
	andi.w #.storeNoPositions-1,d0
	lsl.w #3,d0

	
	move.l objectListX(a2),d3
	move.l d3,(a5,d0.w)	; store current x-position of main object
	move.l objectListY(a2),d5
	move.l d5,4(a5,d0.w)	; y-position
	move.w objectListHit(a2),d0

	; read stored positions and distribute to snake elements


	lea bossChildPointers(a1),a4
	move.l (a4),a3

	moveq #.noOfElementsTotal-1,d0
	sf.b d2
	;lea 4(a4),a4
.managePositions
	tst.b d2
	beq .mainBodyCoords
	add.w a6,d1		; position store offset - controls gap between elements
	andi.w #.storeNoPositions-1,d1
	move.w d1,d3
	lsl.w #3,d3
	move.l (a4)+,a3
	tst.l a3
	beq .skip
	move.l (a5,d3.w),d5	; fetch stored x-position
	move.l objectListX(a3),d6
	move.l d5,objectListX(a3)
	sub.l d5,d6
	move.l 4(a5,d3.w),d5	; fetch stored x-position
	move.l objectListY(a3),d4
	move.l d5,objectListY(a3)
	sub.l d5,d4

.manageCoords
;	fetch x-acceleration
	asr.l #8,d6
	move.w d6,d5
	;asr.w #6,d5
	asr.w #6,d5
	asr.w #7,d6
	add.w d5,d6
	spl d5
	andi.b #$1e,d5
	add.w #$12,d6
	cmpi.b #32,d6
	scc.b d4	;-1 if out of range
	and.b d4,d5
	not.b d4
	and.b d4,d6
	or.b d5,d6
	andi #$1f,d6
	move d6,d7

;	fetch y-acceleration

	asr.l #8,d4
	move d4,d5
	asr.w #6,d4
	asr.w #7,d5
	add.w d5,d4

	move.l viewPosition+viewPositionAdd(pc),d5
	move.l d5,d3
	lsl.l #3,d5
	lsl.w #1,d3
	add.w d3,d5	; *12
	swap d5
	not d5
	add d4,d5

	spl d4
	andi.b #$1f,d4
	add.w #$13,d5
	cmpi.b #$20,d5
	scc.b d3	;-1 if out of range
	and.b d3,d4
	not.b d3
	and.b d3,d5
	or.b d4,d5
	andi #%11110,d5
	lsl #5,d5
	add.w d5,d7
.anim
	clr.w d4
	move.b (tanTable.w,pc,d7),d4
	lsl #1,d4
	tst.b d2
	beq .mainBodyAnim

	btst #0,d0
	bne .mirrorObject
	eor.w #$10<<2,d4
.mirrorObject
	move.w d4,objectListTriggers(a3)	; store anim frame, to be implemented in objects animcode
.skip
	dbra d0,.managePositions
	movem.l (sp)+,a1-a6/d0-d7
	bra animReturn
.mainBodyCoords
	move.w a6,d6
	lsr #1,d6
	add.w d6,d1		; position store offset - controls gap between
	move.w objectListAccX(a2),d6
	ext.l d6
	neg.l d6
	lsl.l #8,d6
	move.w objectListAccY(a2),d4
	ext.l d4
	neg.l d4
	lsl.l #8,d4
	bra .manageCoords
.mainBodyAnim
	lea (a0,d4),a0
	st.b d2
	;movem.l (sp)+,a1-a6/d0-d7
	;bra animReturn
	bra .managePositions

	;bra .phase4



	;	#MARK: - Stage 0 controller / Ganton
boss0JumpIn	SET 	.main0-.boss
.main0
	move.l objectListAcc(a2),d0
	cmpi.w #-1180,d0
	bge .playSpawnSound
	PLAYFX fxSpawnBoss0
.playSpawnSound
	neg.l d0
	move.w d0,d4	; y-accl
	asr.w #5,d4
	swap d0			; x-accl
	asr.w #5,d0
	move.w d0,d5
	move.w d4,d6
	asr #3,d5
	asr #4,d6
	add #24,d5
	add #30,d6
	move.l a2,a3	; handle east object
	bsr .storePosition

	move.w d0,d5
	move.w d4,d6
	asr #2,d5
	asr #3,d6
	move.l a3,a1
	sub.w objectListX(a1),d5
	sub.w objectListY(a1),d6
	add #37,d6
	sub.w #10,d5
	bsr .storePosition	; handle body object

	clr.l d7
	move.w d0,d5
	move.w d4,d6
	move.w d5,d7
	asr #3,d7
	asr #2,d5
	add.w d7,d5
	move.w d6,d7
	asr #2,d7
	asr #3,d6
	add.w d7,d6
	add.w #45,d6
	tst.b (animTriggers+2,pc)
	beq .drawBoss0
	bra .drawLaser
.drawBoss0
	sub.w objectListX(a3),d5
	sub.w objectListX(a1),d5
	sub.w objectListY(a3),d6
	sub.w objectListY(a1),d6

	pea animReturn
.storePosition
	move.l objectListMyChild(a3),a3	; get riglanch object, use it as east object
	tst.l a3
	beq .noChildB
	move.w d5,objectListX(a3)
	move.w d6,objectListY(a3)
.noChildB
	rts
laserJumpIn	SET 	.drawLaser-.boss
.drawLaser
	SAVEREGISTERS
	lea	polyVars(pc),a1

	move.w objectListAccX(a2),d7
	neg d7
	asr #6,d7
	;sub.w d7,d5
	add.w objectListX(a2),d5
	lsl #4,d5
	add.w objectListY(a2),d6
	sub.w viewPosition+viewPositionPointer(pc),d6
	lsl #4,d6
.xOffsetNorth	SET -170<<4
.yOffsetNorth	SET 47<<4
.yMaxSouth		SET 257<<4

	move.w frameCount+2(pc),d3
	andi #$1f,d3
	bne .noSound
	PLAYFX fxBeam
.noSound
	move.w d5,d3
	move.w d6,d4
	add #.xOffsetNorth,d3
	add #.yOffsetNorth,d4
	move	d3,xA1(a1)
	move	d4,yA1(a1)

	move.w d5,d3
	move.w d6,d4
	;add #.xOffsetNorth-(20<<4),d3
	add #.yMaxSouth,d4
	add.w objectListAccX(a2),d3
	add #.xOffsetNorth-(7<<4),d3
	move #.yMaxSouth,d4
	move	d3,xA2(a1)
	move	d4,yA2(a1)

	move.w d5,d3
	move.w d6,d4
	add #.xOffsetNorth+(3<<4),d3
	add #.yOffsetNorth,d4
;	move #100<<4,d4

	move	d3,xB1(a1)
	move	d4,yB1(a1)

	move.w d5,d3
	move.w d6,d4
	add #.xOffsetNorth+(7<<4),d3
	add.w objectListAccX(a2),d3
	add #.xOffsetNorth+(20<<4),d4
	add #.yMaxSouth,d4
	move #.yMaxSouth,d4
	move	d3,xB2(a1)
	move	d4,yB2(a1)

		;lea CUSTOM,a5
		;bsr fillDrawLine	; draw connection between two north coords

	RESTOREREGISTERS
	bra .drawBoss0

	;	#MARK: - Stage 4 controller Rigel boss

.main4	;	code for sun boss / Rigel
	tst.b objectListTriggers+3(a2)
	beq .initJumpin

	;bset.b #2,objectListAttr(a2); set link attribs, always draw

.rigelHitpoints	SET 500<<2

	move.w objectListHit(a2),d0
	lsr #4,d0
	add.b #2,d0
	move.w frameCount+3(pc),d4
	cmpi #$17,d0
	scs d5
	andi #$17,d5
	or.b d5,d0	; make sure heart does not beat too fast
	divu d0,d4
	lsr #5,d4
	and.w #$3,d4
	lea (a0,d4*2),a0	; heartbeat frames rythm synced to hitpoints

	move.l objectListMyChild(a2),a3	; get body
	move.l objectListMyChild(a3),a3	; get left wing
	move.l objectListMyChild(a3),a1	; get anchor object
	tst.l a1
	beq .noChild
	move.w objectListX(a3),d4
	neg.w d4
	move.w d4,objectListX(a1)	; anchor objects position = hub object position
	move.w objectListY(a3),d4
	neg.w d4
	move.w d4,objectListY(a1)

	tst.b (animTriggers,pc)
	seq d0
	andi.b #attrIsNotHitableF,d0	; hitable only when wings are opened
	move.b d0,objectListAttr(a2)
.noChild
	bra animReturn
.initJumpin

	move.l a2,a3
	st.b objectListTriggers+3(a2)
	;sf.b objectListAttr(a2)
	bset.b #2,objectListAttr(a2); set link attribs, always draw

	move.w #.rigelHitpoints,objectListHit(a2); hardcode hit value as it is zero'ed while adding sun children

.init
	move.l objectListMyChild(a3),a3
	tst.l a3
	beq animReturn
	move.l a2,objectListMainParent(a3)
	move.w #0,objectListHit(a3)	; all children objects cannot be hit
	bra .init

	;	#MARK: - Stage 2 controller / Stealth and LightEye

.main2	; main boss 2 object controller
	clr.w d0
	move.b objectListTriggers+3(a2),d0
	move.w (.jmpTable,pc,d0.w*2),d0
.jmp
	jmp .jmp(pc,d0.w)
.jmpTable
	dc.w 	.main2Body-.jmp-2			; trig1792
	dc.w 	.main2Body-.jmp-2			; trig1793
	dc.w	.stealthController-.jmp-2	; trig1794
	dc.w	.beamController-.jmp-2		; trig1795
	dc.w	.availableController-.jmp-2

.main2Body
	;move.w objectListX(a2),d2
	move.w #$130,objectListX(a2)
	;add #10,objectListX(a2)
	;andi #$ffe0,objectListX(a2)
	tst.b bossStateMachine(a1)
	bne .mainAttackWave
	moveq #-1,d4
	move.l bossChildPointers(a1),a3	; fetch current east pointer
	move.w (a3),d4
	move.l bossEastAnimPointer(pc),a3
	sub.w animTablePointer+2(a3),d4
	lsr.w #6,d4
	seq d4

	move.l bossChildPointers+4(a1),a3
	move.w (a3),d5
	move.l bossWestAnimPointer(pc),a3
	sub.w animTablePointer+2(a3),d5
	lsr.w #6,d5
	seq d5
	move.b d4,d6
	or.b d5,d6
	bne .boss0Animation	; both objects exist - stealth attack rolling
	;bra .boss0Animation
.main0initWave1
	move.l bossStgBAnimPointer(pc),a3
	move.w animTablePointer+2(a3),d0
	move.w d0,(a2)
	move.b #1,objectListCnt(a2)
	;	#MARK: - .2 - control beam emitter & beam itself

	move.w bossHitCmp(a1),objectListHit(a2)	; reset original hitpoint value
	st.b bossStateMachine(a1)
	bra .mainAttackWave

.boss0Animation	; boss 0 animation
	lea tempVar(pc),a3
	move.b (a3),d6
	andi.b #1,d6
	andi.b #2,d4
	andi.w #4,d5

	add.b d4,d5
	;move.w (.getIndex-2,pc,d5),d0
	add.b d6,d5
	move.b (.getIndex-2,pc,d5),d5
	move.b d5,1(a3)
.mainAttackWave
	move.w frameCount+2(pc),d0
	andi.w #2,d0
	lea 8(a0,d0*4),a0	; fastswitch two anims frames
.noAction
	bra animReturn
.getIndex
	dc.b 	0,0
	dc.b	1,1
	dc.b	0,1

.stealthController
.freq	SET	6
	lea tempVar(pc),a3
	add.b #1,(a3)

	move.b 1(a3),d7
	move.b #1,objectListTriggers+3(a2)	; set to main
.launch
	SAVEREGISTERS
	andi.w #%11,d7
.retResetSpiral
	clr.w d5
	clr.w d6
	move.l	.launchAnim(pc,d7*4),a4
	move.l (a4),a4
	;move.l circLsrAAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
	st.b d3
	bsr.w objectInit
	tst.l d6
	bmi .kick
	move.w a2,objectListGroupCnt(a4)
	move a2,d0

	move.b #0,objectListAttr(a4)
	move.w #8<<2,objectListHit(a4); hitpoints
	PLAYFX fxSpawn
.kick
	RESTOREREGISTERS
	bra .boss0Animation

.launchAnim
	dc.l stealthAAnimPointer,stealthBAnimPointer
	dc.l stealthCAnimPointer,stealthDAnimPointer



	;	#MARK: - .2 - control beam emitter & beam itself
	; (drawing is done by fillManager)
.beamController
.width	SET	64/8
noOfFrames	SET	6
	move objectListX(a2),d7
	moveq #-32,d5
	add.w d7,d5
	lsr #4,d5	; set x-pos

	move objectListY(a2),d6
	sub.w viewPosition+viewPositionPointer(pc),d6
	move.w AddressOfYPosTable(pc,d6*2),d6
	SAVEREGISTERS
	move.l mainPlanesPointer+0(pc),a1
	sub #2,d5
	bclr #0,d5
	add.w d5,d6
	lea (a1,d6.w),a1
	lea (56+56),a3
	;move objectListHit(a2),d1  ; stamp

	btst #1,objectListHit+1(a2)  ; stamp
	sne d1

	move d1,d0
	andi.w #1,d0
	sub.w d0,objectListHit(a2)
	andi #8,d1
	lea 40(a0,d1),a0	; pointer to object bitmap
	lea 7*8(a0),a2	; pointer to cookie
	move #47,d1	; object heigth
	bsr mergeObjectToBitmap

	RESTOREREGISTERS



	clr.w d0
	move.b objectListTriggers+1(a2),d0
	move.w (.jmpTableBeam,pc,d0.w*2),d0
	lea polyVars(pc),a1
.jmpBeam
	jmp .jmpBeam(pc,d0.w)
.jmpTableBeam
	dc.w .0Beam-.jmpBeam-2,.1Beam-.jmpBeam-2,.2Beam-.jmpBeam-2

.0Beam	; open eye
	move.b #0,objectListAttr(a2)
	cmpi.b #10,objectListCnt(a2)
	bne .sss
	PLAYFX fxSpawn
	; reset Beam
	lea plyBase+plyDistortionMode(pc),a3
	move.b #8,(a3)	; add bit of screenshake (beam heat)

	move.b #100,objectListTriggers+2(a2); reset beam spawn animation
	;st.b objectListTriggers+3(a2)
	move.l #($80<<16)|($e0<<4),objectListTriggersB(a2)
	clr.w polyBlitAddr+4(a6)

	clr.l 16(a1)
	clr.l 16+4(a1)
	clr.l 16+8(a1)
	clr.l 16+12(a1)	; clear not need coords

.sss
	move #128,d0
	sub.b objectListCnt(a2),d0
.0BeamQuit
 	lsr #5,d0
	lea 16(a0,d0*8),a0
	clr.l xA1(a1)
	bra animReturn
.2Beam	; close eye
	move.b objectListCnt(a2),d0
	cmpi.b #4,d0
	bhi .unhitableState
	move.b #attrIsNotHitableF,objectListAttr(a2)
.unhitableState
	lea plyBase+plyDistortionMode(pc),a3
	sf.b (a3)	; stop screenshake (beam heat)
.stopHeatshake
	bra .0BeamQuit


.1Beam	; shoot beam
	move.b objectListCnt(a2),d0
	andi #$1f,d0
	bne .wooshIsPlaying
	PLAYFX fxBeam
.wooshIsPlaying
	;tst.b objectListTriggers+3(a2)
	;beq .resetBeam
.retReset
	SAVEREGISTERS
	lea	polyVars(pc),a1

	add.w #1,objectListTriggersB(a2)
	move.w objectListTriggersB(a2),d0
	andi #$1ff,d0
	lsr #2,d0 ;$1ff->$7f
	clr.w d2
	move.b #$3f,d2
	sub.b sineTable(pc,d0.w),d2
	not.b d2
	lsl #1,d2
	ext.w d2

	asr #2,d2
	add.w d2,objectListTriggersB+2(a2)
	move.w objectListTriggersB+2(a2),d2
		andi #$1ff<<4,d2
		move.w d2,d4
		sub #64<<4,d2
		move	d2,xA2(a1)
		move	#254<<4,yA2(a1)
		clr.w d3
		move.b objectListTriggers+2(a2),d3
		beq .beamSpawnAnimComplete
		sub.b #1,objectListTriggers+2(a2)
		lsl #3,d3
		add.w d3,d2
.beamSpawnAnimComplete
		sub #50<<4,d2
		move	d2,xB2(a1)
		move	#254<<4,yB2(a1)

.sinTableSize	SET	512
.sinPeakValue	SET	32768/2
		lsr #5,d4
		sub #80,d4
		andi #$1ff,d4
	clr.l d0
	clr.l d1
		move	d4,d0
		andi #.sinTableSize-1,d0
		move	sin_tab(pc,d0*2),d0	; d0 = sin(angle) in 2.14
		move	#.sinTableSize+.sinTableSize/4,d1
		sub	d4,d1
		andi	#.sinTableSize-1,d1
		move	sin_tab(pc,d1*2),d1	; d1 = cos(angle) in 2.14
	asr.l #7,d0
	asr.l #8,d1
.lenBeam	SET 1
	add #142<<4,d0
	add #61<<4,d1	; y-coord east
	move	d0,xA1(a1)	; x-coord 0.w (target, north)
	move	d1,yA1(a1)	; y-coord 0.w (target)
	movem.w d0/d1,-(sp)
		sub #32,d4
		andi #$1ff,d4
		move	d4,d0
		andi #.sinTableSize-1,d0
		move	sin_tab(pc,d0*2),d0	; d0 = sin(angle) in 2.14
		move	#.sinTableSize+.sinTableSize/4,d1
		sub	d4,d1
		andi	#.sinTableSize-1,d1
		move	sin_tab(pc,d1*2),d1	; d1 = cos(angle) in 2.14
	asr.l #7,d0
	asr.l #8,d1
.lenBeam	SET 1
	add #132<<4,d0

;	add #10<<4,d0
	clr.w d3
	move.b objectListTriggers+2(a2),d3
	lsl #1,d3
	add.w d3,d0
	add #61<<4,d1; y-coord west
		move	d0,xB1(a1)	; x-coord 0.w (target, north)
		move	d1,yB1(a1)	; y-coord 0.w (target)
	movem.w (sp)+,d2/d3

		move	d0,xC1(a1)
		move	d1,yC1(a1)
		move	d2,xC2(a1)
		move	d3,yC2(a1)
		lea CUSTOM,a5
		bsr fillDrawLine	; draw connection between two north coords

	lea vars(pc),a3
	move.l collidingList+4-vars(a3),a1

	move.w objectListX(a2),d0
	sub #$20-$2,d0
	move.w d0,collTableXCoords(a1)
	add #$40,d0
	move.w d0,collTableXCoords+2(a1)

	move.w objectListY(a2),d0
	sub.w viewPosition+viewPositionPointer(pc),d0
	move.w d0,collTableYCoords(a1)
	add #46,d0
	move.w d0,collTableYCoords+2(a1)

	move.l a2,collTableAnimActionAdr(a1)
	moveq #collListEntrySize,d7
	add.l d7,collidingList+4-vars(a3)
	addq #1,bobCountHitable-vars(a3)

	RESTOREREGISTERS
	bra objectListNextEntry

.availableController	; ?????

	bra objectListNextEntry


; custom snake animation code
serpBody
	move.w objectListTriggers(a2),d0
	lea (a0,d0.w),a0
	bra animReturn

bossVars
	RSRESET
bossChildPointers	rs.l 	14
bossHitCmp			rs.w 	1
bossStateMachine	rs.w	1
bossVarsSize		rs.w 	0
	blk.b bossVarsSize,0
