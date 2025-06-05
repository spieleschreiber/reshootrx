
	;	code may not use a5,a6,d7
	; 	a6	->	pointer to caller object


homeHrd4
	move.b optionStatus(pc),d0
	bpl homeShotFail	; diff is high? Do not shoot
	bra homeSht4
homeHrd2
	tst.b optionStatus(pc)
	bpl homeShotFail	; diff is high? Do not shoot
homeSht2		; launch projectile every 8 calls
	move #%1,d2
	bra.b homeSht4entry
homeSht4	; launch projectile every 4 calls
	
	move #%11,d2
homeSht4entry
	move.b objectListWaveIndx(a6),d0
	bmi homeShotSwitch

	moveq #$f,d3
	and d3,d0
	lea objCopyTable+16(pc),a0
	add.b #1,(a0,d0)
	move.b (a0,d0),d0
	and d2,d0
	bne homeShotQ
homeShotSwitch
	move.l homeShotPointer(pc),a1
	jmp (a1)	; low difficulty: homeShot. High difficulty: homeShotLead
homeShotQ
	jmp (a5)

	; #MARK: - Init Homeshot / Biggshot

	;	bullets typically spawn at center of object. set trigger 3 to modify bullet y spawn position.  Add to animlist:
	;	code trig1792	-> add 0
	;	code trig1793	-> add 4
	;	code trig1794	-> add 6
	;	code trig1795	-> add 8
	;	...
	;	code trig1798	-> add -12
	;	code trig1800	-> add -8
	;	code trig1803	-> add -2
	;	code trig1804	-> add +17	; this is a fix

	;	code trig1792+x	-> add 0,4,6,8,10,12,-12,-10,-8,-6,-4,-2

lasrShot
	move.l circLsrAAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
	bsr getCoordsBlitter
	GETOBJECTPOINTER a6,a0
	add.w #15,d5
	add.w #4,d6
		GETOBJECTPOINTER a6,a0
	sub.w #$0e,d5

	clr.w d2
	move.b objectDefHeight(a0),d2
	lsr #1,d2
	clr.w d0
	move.b objectListTriggers+3(a6),d0
	add.b homeShotYOffset(pc,d0.w),d2
	ext.w d2	; extend sign in case spawn position is outside of object frame
	add.w d2,d6	; modify spawn y-position

	move.w d5,d0
	move.w d6,d1
    sf.b d3
    bsr objectInit
    tst.l d6
	bmi homeShotFail
	bsr modifyObjCount

	move.b #attrIsSpriteF!attrIsNotHitableF,objectListAttr(a4); attribs
	clr.w d3
	lea plyBase(pc),a0
	sub.w plyPosX(a0),d0
	sub.w #17,d0
	add.w #20,d1
	bra homeShotGotCoordsB

;	move.l bascShotAnimPointer(pc),a4
;	bra homeShotInit


biggShot
homeShot	; killed small homeshot for optimized UX: Huge bullets are recognisable as autotarget, small ones as bullet spray
	move.l biggShotAnimPointer(pc),a4
	
		; launch homing bullet towards current player position
homeShotInit
	move.w plyBase+plyDiffBulletDelta(pc),d0
	move.l a6,a2
	bsr checkProximity

	cmp.w plyBase+plyDiffBulletDelta(pc),d0	; can be either $30 or $38
	blo homeShotFail ; too close to main character. Do not shoot
	bsr getCoordsSprite
homeShotGotCoords

	GETOBJECTPOINTER a6,a0
	
	;add.w plyBase+plyPosXDyn(pc),d5
	sub.w #$21,d5
	;add.w #$08,d6
	clr.w d2

	move.b objectDefHeight(a0),d2
	lsr #1,d2
	clr.w d0
	move.b objectListTriggers+3(a6),d0
	add.b homeShotYOffset(pc,d0.w),d2
	ext.w d2	; extend sign in case spawn position is outside of object frame
	add.w d2,d6	; modify spawn y-position

	move.w d5,d0
	move.w d6,d1
    sf.b d3
	move.w animTablePointer+2(a4),d4
	bsr objectInit
	tst.b plyBase+plyWeapUpgrade(pc)	; if player is killed, dont add bullets
	bmi homeShotFail
	tst.l d6
	bmi homeShotFail
	bsr modifyObjCount

	move.b #attrIsSpriteF!attrIsNotHitableF,objectListAttr(a4); attribs
	clr.w d3	
	lea plyBase(pc),a0
	sub.w plyPosX(a0),d0
homeShotGotCoordsB
	sub.w plyPosY(a0),d1
	bra homeShotDirection
homeShotYOffset
	dc.b 0,4,6,8,10,12,-12,-10,-8,-6,-4,-2,17,36
	even
	; #MARK: - Init Homeshot Lead

homeHard	; bullet only on hard diffculty
	tst.b optionStatus(pc)
	bpl homeShotFail	; diff is high? Do not shoot
homeShotLead	; launch homing bullet with lead
	bsr getCoordsSprite
	GETOBJECTPOINTER a6,a0
	;add.w plyBase+plyPosXDyn(pc),d5
	sub.w #$21,d5	; set x launch position
	add.w #12,d6	; set y launch position
	clr.w d2

	move.b objectDefHeight(a0),d2
	lsr #1,d2
	clr.w d0
	move.b objectListTriggers+3(a6),d0
	add.b homeShotYOffset(pc,d0.w),d2
	ext.w d2	; extend sign in case spawn position is outside of object frame
	add.w d2,d6	; modify spawn y-position

	move.l biggShotAnimPointer(pc),a4
	;move.l bascShotAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4

    move.w d5,d0
    move.w d6,d1
	sf.b d3
	bsr objectInit
	tst.b plyBase+plyWeapUpgrade(pc)	; if player is killed, dont add bullets
	bmi homeShotFail

	tst.l d6
	bmi homeShotFail
	bsr modifyObjCount


	move.b #attrIsSpriteF!attrIsNotHitableF,objectListAttr(a4); attribs
	clr.w d3
	sub.w plyBase+plyPosX(pc),d0
	sub.w plyBase+plyPosY(pc),d1

	;lea plyBase(pc),a1   ; calculate distance to player using manhattan method

	tst.l objectListMyParent(a6)
	bne .getParent
	move.l a6,a1
.done
	move #-200,d4
	add.w objectListX(a1),d4
	add.w plyBase+plyPosXDyn(pc),d4
	sub.w plyBase+plyPosX(pc),d4
	smi d6
	ext.w d6
	eor.w d6,d4	; distX range 0-255

	moveq #-5,d5
	add.w objectListY(a1),d5
	sub plyBase+plyPosY(pc),d5
	smi d6
	ext.w d6
	eor.w d6,d5			; distY range 0-255
	add.w d4,d5			; full distance 0-512

	lsr #6,d5
	move #$08,d4
	sub.w d5,d4
	beq homeShotDirection ; Avoid Div0-Exception
	move.l plyBase+plyPosAcclX(pc),d2
	clr.l d3
	move.w d2,d3	; y-Acc 0-$880
	swap d2			; x-acc 0-$a80

	asr #1,d2
	tst.w d2
	smi d6
	ext.w d6
	eor.w d6,d2
	divs d4,d2
.maxXReach	SET 	$58
.maxYReach	SET		$60
	cmpi.w #.maxXReach,d2
	bhs .cutX
.retX
	eor.w d6,d2
	sub.w d2,d0; estimated x-position
	asr #1,d3
	tst.w d3
	smi d6
	ext.w d6
	eor.w d6,d3
	divu d4,d3
	cmpi.w #.maxYReach,d3
	bhs .cutY
.retY
	eor.w d6,d3
	sub.w d3,d1	; estimated y-position
	bra homeShotDirection
.cutX
	move #.maxXReach,d2
	bra .retX
.cutY
	move #.maxYReach,d3
	bra .retY
.getParent	; very simple system to get primary object, works with only one relationship layer
	move.l objectListMyParent(a6),a1
.loopRelatives
	tst.l objectListMyParent(a1)
	beq .done
	move.l objectListMyParent(a1),a1
	bra .loopRelatives

	; point bullet towards players position
homeShotDirection
	PLAYFX fxEnemBullet
	;PLAYFX fxLighting
	add #170,d0	; adjust players x-coord to world coords
	add.w plyBase+plyPosXDyn(pc),d0
	;move.w plyBase+plyPosXDyn(pc),d2
	;MSG01 m2,d2
	move d0,d2
	lsr #2,d0
	lsr #4,d2
	sub d2,d0; make sure x-pointer >0 & <$40

	lsl #1,d0
	move.b d0,d3

	clr.w d4
	add #225,d1	; adjust players y-coord to world coords
	lsr #2,d1
	lsl #1,d1	; kill bit 0
	move.b d1,d5

	tst.b d3
	smi d3
	bclr #0,d3
	eor.b d3,d0	; player is left -> inverse pointer

	tst.b d5
	smi d5
	bclr #0,d5
	eor.b d5,d1	; player is above -> inverse pointer 
	lsl #6,d1
	add d1,d0	; add y-row to x-column / table pointer
	
	clr.w d4
	move.w (bulletVectorsFast,pc,d0),d1	; fetch x- & y-delta vector
	move.b d1,d4
	lsl #1,d4
	move.l viewPosition+viewPositionAdd(pc),d6
	lsl.l #8,d6
	swap d6
	ext.w d5
	eor.w d5,d4			; player is above -> negative value	
	add d4,d6
	
	lsr #8,d1	; shift to x-vector
	ext.w d3
	eor d3,d1		; player is left -> negative value
	lsl #2,d1
	movem.w d1/d6,objectListAcc(a4)	; write x- and y-accl

	clr.l d6
homeShotFail	; d6=-1
	jmp (a5)


	; #MARK: - Init Spiral Shot
	; add "code	stSpiRst" in animlist to reset spiral counter in case of consecutive bullet waves

	; 	objectListTriggers -> set statu
	;	bullet type (bit 0-2)
	;	launch position y offset (bit 3-5)
	;	add object inertia (bit 6)
	;	trig1024	- 	bascShotAnimPointer
	;	trig1025	- 	biggShotAnimPointer
	;	trig1026	- 	circLsrAAnimPointer
	;	trig1027	- 	huntMislAnimPointer
	;	trig1028	- 	beesHiveAnimPointer

	;	trig1024	- 	+0 y offset 0
	;	trig1032	- 	+8 y-offset -5
	;	trig1040	- 	+16 y-offset 7
	;	trig1048	- 	+24 y-offset -17
	;	trig1056	- 	+32 y-offset -23
	;	trig1064	- 	+40 y-offset -10
	;	trig1072	- 	+48 y-offset 20
	;	trig1080	- 	+56 y-offset -127

	;	trig1088	- 	+64 add emitter object's inertia to bullet

	;	objectListTriggers+1 angle offset, trig1281 = 1, trig1285 = 5 clockwise; trig1404 = rotate counterclockwise. clockwise value calculated by .b << 1, so trig 1407 (1280+127) is max. value
	;	+32 switch east/west or north/south,
	;	trig1312	aim four directions
	;	trig1344 	aim two directions

	;	trig1311 	two-armed spiral


	;	objectListTriggersB+2 as counter in case of single (not copied) launcher object
	; example for clockwise and anticlockwise congruence: trig1283 - trig1205

	; 	trig1536 	player-related bullet angle
	;	trig1537 	north
	;	trig1568	west
	;	trig1600	south
	;	trig1632	east - max. val is 1663

	; add "code stHarder" to animlist for spiral bullet, that spawn only on hard difficulty. Use with caution, as this command is not entirely tested

	; ATTN: Make sure that if using stHarder on single objects, they must not contain "copy" command in map-table. Else code will bug or crash.

homingBulletMinDist	SET $30

stSpHead	; (code stSpHead) launch homebullet from 1st object in copied/linked chain

	lea homeShotHead(pc),a1
	tst.l (a1)
	beq .findEntry
	SAVEREGISTERS
	move.l (a1),a6
.gotEntry
	;move.l a6,a2
	;bsr checkProximity
	;cmp.w plyBase+plyDiffBulletDelta(pc),d0		; can be either $30 or $38
	;blo homeShotFail ; too close to main character. Do not shoot
.sss
	;move.l a1,a6
	;move.b #0,objectListTriggers(a6)
	;MSG02 m2,a6
	lea .ret(pc),a5
	;jmp (a5)
	bra stSpiral
.ret
	RESTOREREGISTERS
	jmp (a5)
.findEntry
	move.l a6,(a1)
	bra stSpHead


stSpiralHard
	tst.b optionStatus(pc)
	bmi stSpiral	; diff is high? Launch bullet
	clr.w d3
	move.b objectListWaveIndx(a6),d3	; single object will be $ff
	bpl .multipleObjects

	lea objectListTriggersB(a6),a0	; single launcher object - triggerB+0.b stores shooting angle
	bra .modifyAngle
.multipleObjects
	lea objSpiralBulletTable(pc,d3.w),a0
.modifyAngle
	move.b objectListTriggers+1(a6),d0
	sub.b d0,(a0)	; modify shooting angle
	bmi .modifiedAngle
	or.b #$80,(a0)
.modifiedAngle
	jmp (a5)
.retMod

stSpiral	; shoot spiral wave
	clr.w d2
	move.b objectListTriggers(a6),d2
	move.w d2,d3
	lsr #3,d2
	andi.w #7,d2
	andi.w #7,d3

	move.w .objectType(pc,d3.w*2),d4
	lea bobCodeCases(pc,d4),a4
	move.l (a4),a4
	pea .gotCoords
	cmpi.b #2,d3
	bge .isBlitterObject
	bra getCoordsSprite
.isBlitterObject
	bra getCoordsBlitter
.gotCoords
	move.w animTablePointer+2(a4),d4

	GETOBJECTPOINTER a6,a0
	;move.w plyBase+plyPosXDyn(pc),d0
	clr.w d0
	and.b .objectSpriteOrBob(pc,d3.w*1),d0
	add.w d0,d5
	sub.w #$22,d5	; set x launch position
	move.b .addYOffset(pc,d2),d2
	ext.w d2
	move.w d2,a2
	add.w d2,d6

	add.w #14,d6	; set y launch position
	move.w d5,d0
	move.w d6,d1
	clr.w d2
	move.b .objectXSpawnOffset(pc,d3.w),d2
	;ext.w d2
	add.w d2,d5
	move.b .objectYSpawnOffset(pc,d3.w),d2
	;clr.w d2
	add.w d2,d6
	clr.w d2
	move.b objectDefHeight(a0),d2
	lsr #1,d2
	add.w d2,d6


	; ugly but not timing relevant fix for strange bug that caused occasional bullets to deviate from bullet pattern
	cmpi.b #2,d3
	bge .circOrHunt
	sf.b d3
	
	bsr objectInit	; only use this for bullets, not circular
	tst.l d6
	bmi homeShotFail
.contSpawn
	
	bsr modifyObjCount
	move.b objectListTriggers(a6),d2
	andi.b #7,d2
	ext.w d2
	move.b .objectAttribs(pc,d2),objectListAttr(a4); set hitable/non-hitable attribs
	move.b .objectHitpoints(pc,d2),d2
	move.w d2,objectListHit(a4); set hitable/non-hitable attribs
	clr.w d2
	;clr.w d3
	move.b objectListWaveIndx(a6),d3	; single object will be $ff
	bpl .multipleObjects
		lea objectListTriggersB(a6),a0	; single launcher object - triggerB+0.b stores shooting angle
	move.w plyBase+plyPosX(pc),d2
	sub.w plyBase+plyPosXDyn(pc),d2
	move.w plyBase+plyPosY(pc),d6
	bra .fetchCounter
.circOrHunt
	move.l a6,a4
	sf.b d3
	bsr objectInitOnTopOfSelf
	tst.l d6
	bmi homeShotFail
	bra .contSpawn
.objectType
	dc.w bascShotAnimPointer-bobCodeCases, biggShotAnimPointer-bobCodeCases,circLsrAAnimPointer-bobCodeCases,huntMislAnimPointer-bobCodeCases,beesHiveAnimPointer-bobCodeCases
.objectXSpawnOffset	; basic offsets for sprites or bobs
	dc.b 0,0,32,32,32
.objectYSpawnOffset
	dc.b 0,16,5,-36,32
.objectSpriteOrBob
	dc.b -1,-1,0,0,0
.objectAttribs
	dc.b attrIsNotHitableF,attrIsNotHitableF,attrIsNotHitableF,0,0
.objectHitpoints
	dc.b 0,0,0,4<<2,6<<2
	even
.addYOffset		; some additional y-offsets. Set pointer to value by adding "code trig1024,1032,1040,1048 etc. plus objecttype e.g. huntMisl 3 = 1051" to animList
	dc.b 0,-5,7,-17,-23,-10,20,-127
	even
.multipleObjects
	lea objSpiralBulletTable(pc,d3.w),a0
	move.w plyBase+plyPosX(pc),d2
	sub.w plyBase+plyPosXDyn(pc),d2
	move.w plyBase+plyPosY(pc),d6
.fetchCounter

	tst.b (a0)	; ATTN: Bit 0 used to determine as reset-trigger
	beq .setAngle
.modifyAngle
	moveq #$7f,d6
	move.b objectListTriggers+1(a6),d0
	;lsl #1,d0
	sub.b d0,(a0)	; rotate shooting angle
	bmi .retMod
	or.b #$80,(a0)
.retMod
	move.b (a0),d2
	and.b d6,d2	; filter bit 7
	move.w d2,d0
	and d6,d0
	moveq #$7f/2,d5
	sub.b sineTable(pc,d0),d5
	ext.w d5
	move d5,d4
	asl #2,d4
	asl #3,d5	; created x-acc
	;add.w d4,d5

	moveq #$3f,d1
	move #$5f,d0
	sub.w d2,d0
	and d6,d0
	sub.b sineTable(pc,d0),d1
	ext.w d1

	move.w d1,d2
	move.w d1,d4
	;asl.w #1,d4
	asl #2,d1
	add.w d2,d1
	add.w d4,d1

	tst.l objectListMyParent(a6)
	bne .getParent
	move.l a6,a1
.done

	btst.b #6,objectListTriggers(a6)
	bne .noInertia

	move.w objectListAccY(a1),d6
	;asl #1,d6
	sub.w d6,d1	; add x- and y-inertia to keep bullet pattern beautiful
	;

	move.w objectListAccX(a1),d0
	asr #1,d0
	add.w d0,d5
.noInertia
	sub.w viewPosition+viewPositionAdd(pc),d1
	clr.l d6
	sub.w d1,d6	; y-acceleration
	;asl #1,d6
	movem.w d5/d6,objectListAcc(a4)

	move.b frameCount+3(pc),d0
	lea .fxDelay(pc),a1
	move.b .fxDelay(pc),d1
	sub.b d1,d0
	cmpi.b #2,d0
	bls .skip
	add.b d1,d0
	move.b d0,(a1)	; need to at least 1 frame between re-calling SFX for quality
	PLAYFX fxLighting
.skip
	jmp (a5)
.getParent	; very simple system to get primary object, works with only one relationship layer
	move.l objectListMyParent(a6),a1
.loopRelatives
	tst.l objectListMyParent(a1)
	beq .done
	move.l objectListMyParent(a1),a1
	bra .loopRelatives
.fxDelay
	dc.w 0

.setAngle
	clr.w d5
	move.b objectListTriggers+2(a6),d5	; if != 0, fetch player-related angle
	andi.b #$7f,d5
;	tst.b d5
	bne .initFixedAngle

	;move.w frameCount+2(pc),d3	; d2=0 -> up, 32->left, 64->down, 96->right

	;	emitter object x-coord in d0, y-coord in d1

	move.l #235,d3	; do y-offset
	add.w a2,d3		; add addYOffset
	sub.w d6,d3
	add.w d1,d3	; values 0 - 255
	scs d4	; lower than 0?
	ext.w d4
	and.w d4,d3	;	make it 0
	divs #12,d3
	tst.w d3
	spl.b d4	; lower than 0?
	and.b d4,d3	; if yes, set to 0
	ext.w d3
	cmpi.b #31,d3
	blt .chkOverflowTop
	moveq #31,d3
.chkOverflowTop
	lsl #5,d3	; muls 32

	move.w #370,d5
	add.w d2,d5	; compare with player x-coord
	sub.w d0,d5	; values 0 - 255
	move d5,d4
	move d4,d2
	lsr #4,d2	;/8
	lsr #6,d4	;/32
	sub.w d4,d2	;/24
	lsr #3,d5	;/8
	sub.b d2,d5

	tst.b d5
	spl.b d4	; lower than 0?
	ext.w d4
	and.w d4,d5	; if yes, set to 0
	cmpi.w #31,d5
	bls .chkOverflowRight
	moveq #31,d5
.chkOverflowRight
;	move.w #1,d5
	or.w d5,d3
	move.b tanTable(pc,d3.w),d5
	lsl #1,d5
	IFNE 1
	clr.w d4
	;move.b #$01,objectListTriggers+1(a6)
	move.b objectListTriggers+1(a6),d4
	move.w d4,d6
	lsl #2,d4
	add.w d6,d4
	ext.w d4
	neg.w d4
	sub.w d4,d5	; modify initial angle, so bullet spray covers a large area left and right of player ship
	ENDIF
.initFixedAngle
	andi.w #$7f,d5
	tst.w d5
	seq d6
	andi.b #1,d6
	or.b d6,d5
	or.b #$80,d5
	move.b d5,(a0)	; store initial direction. 0 = up, $20 = left, $40 = down, $60 = right
	bra .modifyAngle

stReset	; add "code stSpiRst" to animlist -> reset angle -> get new player-related angle with next stSpiral-command
	move.b objectListWaveIndx(a6),d3	; single object will be $ff
	ext.w d3
	bpl .multipleObjects

	lea objectListTriggersB(a6),a0
	bra .resetAngle
.multipleObjects
	lea objSpiralBulletTable(pc,d3.w),a0
.resetAngle
	;btst #0,(a0)
	;bne .isReset
	sf (a0)
.isReset
	jmp (a5)


	; #MARK: - Handle Hunter Missile Explosion

mislExpl
	move.l cExplSmlAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
	move d4,objectListAnimPtr(a6)   ; object hit, change to explosion animation
	;bclr #6,objectListAttr(a6)        ; clr opaque bit for proper expl-display
	move.b #15,objectListCnt(a6)
	;add #$10,objectListAccX(a6)
	jmp (a5)


bulletVectorsMed
	;Incbin incbin/bulletVectorTable_slow
	Incbin incbin/bulletVectorTable_med
bulletVectorsFast
	Incbin incbin/bulletVectorTable_fast

