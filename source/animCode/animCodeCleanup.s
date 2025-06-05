

;//
;//  bobCustomAnim.s
;//  Reshoot2
;//
;//  Created by Richard Löwenstein on 08.03.17.
;//
;//

;{


    ;!!!: Animcode: code called from each frame update. Usually used for bitmap animation, but can do other things too
    ;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter bitmap load adress or use a0 if return to bobblitnext / not animreturn
	    cnop 0,4


    	;	#MARK: boulderdash
boulderDash
	lea objectListTriggersB(a2),a3

	tst.w (a3)
	bne .didLaunch
	move.w viewPosition+viewPositionPointer(pc),d5	; get viewports x-coord and store
	add #350,d5
	andi #$fff0,d5
	move.w d5,(a3)
.didLaunch
	sub.b #1,2(a3)
	bpl .noBoulderLaunch
	; launch new boulder
	move.b #$14,2(a3)		; reset countdown
	;cmpi.b #8,3(a3)		; no more than 6 pcs
	;bge.w .noBoulderLaunch
	add.b #1,3(a3)
.init
	SAVEREGISTERS
	;getAnimAdress bouldersAnimPointer,boul,ders
	move.l bouldersAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
	lea objectListTriggersB(a2),a3
	move.w (a3),d5
	move.w objectListY(a2),d6
    st.b d3
	bsr objectInit
	tst.l d6
	bmi .tooManyObj
	clr.w objectListAccX(a4)
	move #1<<4,objectListAccY(a4)
	move.b #attrIsImpactF,objectListAttr(a4)
	move.w #1<<2,objectListHit(a4)

.tooManyObj
    RESTOREREGISTERS
.noBoulderLaunch
	bra objectListNextEntry


boulders
    moveq #10,d7		;x-pffset
    moveq #8,d0
	clr.l d6
    add.w objectListY(a2),d0         ; load object y-coords
    cmpi.w #$f4,d0							; low on screen? Don´t test
	bhi .quit
    add.w objectListX(a2),d7         ; load obj x-coords
    move.w viewPosition+viewPositionPointer(pc),d5
    andi #$fff8,d5		; reduce resolution for optimized obj coords
    sub d5,d7
    cmpi #$34,d7
    ble.w .quit	; left border, dont test
	
	moveq #$2<<4,d4		; load y-acc
	;clr.l d0
    lea AddressOfYPosTable(pc),a3
    move.w (a3,d0.w*2),d0     ; y bitmap offset
    tst.w objectListAccY(a2)
    beq .touchedDown
;# !!!: use mainPLaneAsync instead?
	;move.l mainPlanesPointerAsync(pc),a1		; detects bckgnd only!
	move.l mainPlanesPointer+8(pc),a1	; detects bckgnd & objects
    bra .loadViewport
.touchedDown
;	move.l mainPlanesPointerAsync(pc),a1
	move.l mainPlanesPointer+8(pc),a1
.loadViewport
    adda.l d0,a1
    lsr #3,d7
    adda.w d7,a1             ; add x-byte-offset
    ;move.w #$ffff,4(a1)
    tst.w (a1)			; has touched ground?
    beq .accY
.hasCollided
	clr.w objectListAccY(a2)
	bra animReturn
.accY
	cmpi #30<<4,objectListAccY(a2)
	bge.b .maxYAcc
	add d4,objectListAccY(a2)
.maxYAcc
.quit
	bra animReturn


    	;	#MARK: EVENT HUB ENDS

    ;	#MARK: - Worm
wormSptC
	move.w objectListX(a2),d7
	bra.b wormSptASkip
wormSptA
	move #340,d7
	sub.w objectListX(a2),d7
wormSptASkip
	add.w viewPosition+viewPositionPointer(pc),d7
	lsr #4,d7
	andi #$7,d7
	bra.b goldEntry
	
wormSptB
wormSptD
	moveq #28,d7
	add.b objectListCnt(a2),d7
	lsr #1,d7
	andi #$f,d7
	move.b (.anim,pc,d7),d7
    lea (a0,d7.w*4),a0
	bra animReturn
.anim
	dc.b 	0,1,2,3,4,5,6,7
	dc.b	7,6,5,4,3,2,1,0

	;	#MARK: - Golden Orb

goldOrbA
	move #340,d7
	sub.w objectListX(a2),d7
	add.w viewPosition+viewPositionPointer(pc),d7
	lsr #4,d7
	andi #$7,d7
goldEntry
    lea (a0,d7.w*4),a0
	tst.b objectListTriggersB+3(a2)	; killcheck bit set?
	beq animReturn	; no
	lea killBounds(pc),a1
	bra killCheck
	
goldOrbB
	moveq #28,d7
	add.b objectListCnt(a2),d7
	lsr #1,d7
	andi #$f,d7
    lea (a0,d7.w*4),a0
	bra animReturn

    ;	#MARK: - Asteroid Path Block
astBlock
	move.w objectListX(a2),d0
	andi #%100,d0
	lea (a0,d0.w),a0 
	tst.b objectListTriggersB+3(a2)	; killcheck bit set?
	beq animReturn	; no
	lea killBounds(pc),a1
	bra killCheck


    ;	#MARK: - Asteroid

astrOffset
    dc.b 0,0,0,1,1,1,2,2
    dc.b 3,3,4,4,5,5,6,6
    dc.b 7,7,8,9,10,11,12,12
    dc.b 13,13,13,14,14,14,15,15
	
	dc.b 15,15,14,14,14,13,13,13
	dc.b 12,12,11,11,10,9,8,7
	dc.b 7,6,6,5,5,4,4,3
	dc.b 3,2,2,2,1,1,1,0
astrAni96



	move.w frameCount+2(pc),d7
	lsr #2,d7
	andi #$3f,d7
	clr.l d6
	move.b ((astrOffset).w,pc,d7),d6
	move.l d6,d5
	lsl.l #3,d6
	lsl.l #2,d5
	add.l d5,d6
	add.l d6,a0

	move.w objectListHit(a2),d7
	cmpi #10,d7
	bhi.w .quit
	SAVEREGISTERS
	move.l astrKilCAnimPointer(pc),a4	;switch to medium asteroid
	move.w animTablePointer+2(a4),d7
	move.w d7,(a2)	;
    move #2<<2,objectListHit(a2); hitpoints
    move.b #attrIsOpaqF,objectListAttr(a2); attribs
    st.b objectListTriggersB(a2)
;	add.w #$20,objectListX(a2)
    move.w #100,d7
    sub.w objectListY(a2),d7
    lsl #1,d7
    move.w d7,objectListAccY(a2)
    move.w #-10<<4,objectListAccX(a2)
    move #4<<2,objectListHit(a2); hitpoints

	;add smallsized asteroid
	
	;getAnimAdress astrKilBAnimPointer,astr,KilB
	move.l astrKilBAnimPointer(pc),a4
	;move.l cExplSmlAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
    move objectListX(a2),d5
    add.w #$70,d5
    moveq #20,d6
    add objectListY(a2),d6                    ; get y-coord
    st.b d3
    bsr.w objectInit
    tst.l d6
    bmi .quit
    st.b objectListTriggersB(a4)
    move.w #120,d7
    sub.w objectListY(a4),d7
    lsl #1,d7
    move.w d7,objectListAccY(a4)
    move.w #20<<4,objectListAccX(a4)
    move #2<<2,objectListHit(a4); hitpoints
	move.b #0,objectListAttr(a4); attribs

	;add large asteroid

	;getAnimAdress astrKilAAnimPointer,astr,KilA
	move.l astrKilAAnimPointer(pc),a4
	;move.l cExplSmlAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4	;add small explosion just for the looks...
    move objectListX(a2),d5
    add.w #$25,d5
    moveq #8,d6
    add objectListY(a2),d6                    ; get y-coord
    st.b d3
    bsr.w objectInit
    tst.l d6
    bmi .quit
    st.b objectListTriggersB(a4)
    move #8<<2,objectListHit(a4); hitpoints
	move.b #attrIsOpaqF,objectListAttr(a4); attribs
	
	move.w #180,d7
    sub.w objectListY(a4),d7
    ;lsl #1,d7
    move.w d7,objectListAccY(a4)
    move.w #5<<4,objectListAccX(a4)
	
	lea emitterKillA(pc),a0
	lea storePlayerPos(pc),a1           ; add particles
	move.w objectListX(a4),d3;plyPosX
	sub.w viewPosition+viewPositionPointer(pc),d3
	add.w #50,d3
	lsl #4,d3
	move.w objectListY(a4),d4
	sub.w #16,d4
	lsl #8,d4
    clr.w d5    ; x-acc
    clr.w d6    ; y-acc
	bsr particleSpawn
	RESTOREREGISTERS
	ADDSCORE 500
    PLAYFX 5
    PLAYFX 4
.quit
	bra animReturn

bigRocka

	move frameCount+4(pc),d0
	lsl #1,d0
	andi #$0f<<3,d0
	lea (a0,d0),a0
	bra animReturn
	
astrAnim

	tst.b objectListTriggersB(a2)
	beq modAcc	; first draw? Modify accl!
astrAniB
	tst.l objectListMyParent(a2)
	bne.b .isChild
    move.w objectListX(a2),d7
    move.w objectListY(a2),d5
    move d7,d6
	sub.w viewPosition+viewPositionPointer(pc),d6
	
	move.l .xbounds(pc),d0
	cmp d0,d6
	bgt killObject	; out of view right?
	swap d0
	cmp d0,d6
	blt killObject	; out of view left?

	move.l .ybounds(pc),d0
	cmp d0,d5
	bgt killObject
	swap d0
	cmp d0,d5
	blt killObject
	
	;cmp2.w (.xbounds,pc),d6
	;bcs.w killObject
	;cmp2.w (.yBounds,pc),d5
	;bcs.b killObject	; left screen? Get rid of object!
	;bra animReturn
.isChild
    move.w a2,d6
    btst #2,d6
    beq.b .animVar
    sub.w d5,d7
    bra.b .skip
.yBounds
	dc.w -$10,$110
.xBounds
	dc.w -$10,370
.animVar
    ;add.w d5,d7
.skip

	tst.l objectListAcc(a2)
	beq.b .static
	move frameCount+4(pc),d6
	lsr #2,d6
	move.w objectListAccY(a2),d7
	ror #3,d7
	sub.w d7,d6

.draw
    andi #%1111,d6
	clr.l d7
    move.b objectDefWidth(a4),d7
    lsr #2,d7
    muls d7,d6
    lea (a0,d6.w),a0
	bra animReturn
.static
	move.w objectListX(a2),d6
	bra.b .draw
modAcc
	st.b objectListTriggersB(a2)
    move.b $bfe601,d7	; get random number
    move d7,d6
    andi #$0f,d7
    sub #$08,d7
    lsl #4,d7
    add.w #50,d7
	add.w d7,objectListAccX(a2)

    andi #$0f,d6
    sub #$08,d6
    lsl #4,d6
    ;move.w #-150,d6
	add.w d6,objectListAccY(a2)
	bra animReturn



;#MARK: - boneWing
boneWing
;    bra animReturn
	move.w frameCount+2(pc),d7
	lsr #2,d7
	andi #$f,d7
	clr.w d6
	move.b (.frames,pc,d7),d6
    lea (a0,d6.w),a0
	move.b (.accY,pc,d7),d6
	lsl #2,d6
	ext.w d6
	add.w d6,objectListAccY(a2)
    bra animReturn
.frames
	dc.b 0,4,8,12,16,20,24,28
	dc.b 24,20,16,8,4,4,0,0
.accY
	dc.b 0,0,0,0,0,0,-2,-2
	dc.b 0,1,2,3,2,1,0,0
	
    ;	#MARK: - spherePod
sphPod16
	clr.w d7
	
	;move.w frameCount+2(pc),d7
	add.w objectListX(a2),d7
	;lsr #1,d6
	lsr #2,d7
	add.b d6,d7
	andi #$f,d7
    lea (a0,d7.w*2),a0
	btst #0,objectListTriggersB+3(a2)	; killcheck bit set?
	beq animReturn	; no
	lea killBounds(pc),a1
    bra killCheck	; check exit view
	

bonCrush
    move.b objectListCnt(a2),d6
    not d6
	andi #$f<<2,d6
	lea (a0,d6.w),a0
    bra animReturn

    ;	#MARK: - JelyFish
	
jelyFish
	clr.l d6
	move.w objectListAccY(a2),d6
	neg d6
	lsr #5,d6
	clr.w d7
	move.b (.anims,pc,d6),d7
	lea (a0,d7),a0
	lea .bounds(pc),a1
    bra killCheck	; check exit view
.anims
	dc.b 0,4,8,12,16,20,24,28,24,20,16,12,8,4
.bounds
	dc.w -$10,380
	dc.w -$10,$110



    ;	#MARK: - Pentagon

pentagon
	lea objectListTriggers(a2),a1
	tst.b (a1)
	bne.b .shoot
    move frameCount+2(pc),d6
    asr #2,d6
    andi #$0f,d6
    move.b .frames(pc,d6),d6
    lea (a0,d6*4),a0
    bra animReturn
.frames
	dc.b 0,1,2,3,4,5,6,7
	dc.b 7,6,5,4,3,2,1,0
.anims
	dc.b 1,1,1,1
	dc.b 1,1,2,2
	dc.b 2,2,2,2
	dc.b 3,3,3,3

	dc.b 3,3,3,3
	dc.b 3,3,3,3
	dc.b 3,3,3,3
	dc.b 3,3,3,3

	dc.b 3,4,3,2
	dc.b 3,4,3,2
	dc.b 3,4,3,2
	dc.b 3,4,3,2

	dc.b 3,4,3,2
	dc.b 3,3,3,3
	dc.b 2,2,2,2
	dc.b 1,1,1,1

.shoot
	move.w objectListX(a2),d0
	sub.b #1,(a1)
    clr.w d0
	move.b (a1),d0
	lsr #1,d0
    move.b (.anims,pc,d0),d0
    add.b #7,d0
    lea (a0,d0*4),a0
    cmpi #11,d0
    bne animReturn
    btst #0,objectListCnt(a2)
    bne animReturn
    SAVEREGISTERS
	lea (.ret,pc),a5
	move.l a2,a6
;	move.l pentShotAnimPointer(pc),a4
;	bra pentShot
.shotOffset	;x and y
	dc.w 25<<4,-9<<4
	dc.w 40<<4,-7<<4
	dc.w 45<<4,5<<4
	dc.w 30<<4,11<<4
	dc.w 19<<4,-2<<4
.ret
	tst.l d6
	bmi .quit
	clr.w d0
	lea objectListTriggersB(a2),a1
	move.b #$28,objectListTriggersB+3(a4)	; set max speed
	move.b 1(a1),d0
	add.b #1,1(a1)
	move.l .shotOffset(pc,d0*4),d0
	move.w d0,d1
	;clr.w d1
	move d1,objectListAccY(a4)
	swap d0
		move.l viewPosition+viewPositionAdd(pc),d2	; mod x-factor related to scrollspeed
	lsl.l #8,d2
	swap d2
	move d0,objectListAccX(a4)
	PLAYFX 18
.quit
	RESTOREREGISTERS
	bra animReturn

    ;	#MARK: - wall controller

wallCtrl
	tst.b objectListTriggers(a2)
	beq objectListNextEntry
	bpl.b .initAction
	move.b objectListCnt(a2),d6
	lea plyPos(pc),a1
	sub.b #1,d6
	move.b d6,plyDistortionMode(a1)
 	bra objectListNextEntry
.initAction
	move.l cExplLrgAnimPointer(pc),a3
	move.w animTablePointer+2(a3),d4
	
	movem.l 16+l2WallStop(pc),a1/a3
	move.w d4,(a1)
	move.w d4,(a3)
	moveq #31,d4
	move.b d4,objectListCnt(a1)
	move.b d4,objectListCnt(a3)
	clr.b objectListAttr(a1)
	clr.b objectListAttr(a3)
	st.b objectListTriggers(a2)

	PLAYFX 5
;		bra objectListNextEntry
	SAVEREGISTERS
	move.w objectListX(a1),d3
	move.w objectListY(a1),d4
	bsr .emit
	RESTOREREGISTERS

	SAVEREGISTERS
	move.w objectListX(a3),d3
	move.w objectListY(a3),d4
	bsr .emit
	RESTOREREGISTERS
	lea objectListNextEntry(pc),a5
	;cmpi.b #statusFinished,gameStatus(pc)
	;beq animReturn		; dont slowdown in level 4
	bra scrolSlo

.emit
	lea emitterKillC(pc),a0
	sub.w viewPosition+viewPositionPointer(pc),d3
	add #110,d3
	lsl #4,d3
	lsl #8,d4
	clr.w d5
	clr.w d6
	bra particleSpawn           ; call particles subroutine

wallblck
	
	move frameCount+4(pc),d0
	lsr #2,d0
	andi #1<<3,d0
	lea (a0,d0),a0
	;bra animReturn
	tst.w objectListHit(a2)
	beq animReturn
	cmpi.w #14<<2,objectListHit(a2)
	bhi animReturn	; switch to full refresh when kill is imminent
	bclr.b #0,objectListAttr(a2)
	bra animReturn


	
	
	
;	#MARK: - Animate Moth Main

mothMain
	move.w frameCount+4(pc),d4
	andi #%11000,d4
	lea (a0,d4),a0
	lea .killbounds(pc),a1
    bra killCheck	; check exit view
.killBounds
	dc.w -$38,335
	dc.w -$10,$110

;	#MARK: Animate Moth Turrets


mothTurAC		; boss turrets
	tst.b objectListTriggers(a2)
	bne.b .isActive	; turret is shooting
	move.l objectListMyParent(a2),a1
	tst.l a1
	beq.b .isActive
	;nop
	tst.b objectListTriggers(a1)	; has mother approached?
	sne.b objectListTriggers(a2)	; if yes, enable missiles
.isActive

;mothTurAC	; worm turrets
	clr.w d6
    move.w frameCount+4(pc),d5
    lsr #4,d5
    addx d6,d6
    add d6,d6
    lea (a0,d6),a0
    bra animReturn
brikTurB
mothTurB	; anim prior to shot
	clr.w d5
	move.b objectListCnt(a2),d5
	andi #3,d5
	lea 4(a0,d5*2),a0
    bra animReturn
	
;	#MARK: Homing Missile

homeMisl

    clr.l d6
    move objectListAccY(a2),d5

    bmi.b .yNeg
    cmpi #2<<6,d5
    bgt.b .yPosMax
    cmpi #1<<6,d5
    bgt.b .yPosMid
    moveq #10,d7
    bra.b .yDone
.yPosMid
    moveq #15,d7
    bra.b .yDone
.yPosMax
    moveq #20,d7
    bra.b .yDone
.yNeg
    cmpi #-2<<6,d5
    bls.b .yNegMax
    cmpi #-1<<6,d5
    bls.b .yNegMid
    moveq #10,d7
    bra.b .yDone
.yNegMid
    moveq #5,d7
    bra.b .yDone
.yNegMax
    clr.w d7
.yDone

    move.w objectListAccX(a2),d5
    move.w viewPosition+viewPositionAdd(pc),d4
    sub.w d4,d5
    bmi.b .xNeg
    cmpi #2<<6,d5
    bgt.b .xPosMax
    cmpi #1<<6,d5
    bgt.b .xPosMid
    moveq #2,d6
    bra.b .xDone
.xPosMid
    moveq #3,d6
    bra.b .xDone
.xPosMax
    moveq #4,d6
    bra.b .xDone
.xNeg
    cmpi #-2<<6,d5
    bls.b .xNegMax
    cmpi #-1<<6,d5
    bls.b .xNegMid
    moveq #2,d6
    bra.b .xDone
.xNegMid
    moveq #1,d6
    bra.b .xDone
.animOffsetMatrix
    dc.b 28,30,0,2,4
    dc.b 26,28,0,4,6
    dc.b 24,24,24,8,8
    dc.b 22,20,16,12,10
    dc.b 20,18,16,14,12
    even
.xNegMax
    clr.w d6
.xDone
    add d6,d7
    clr.w d4
    move.b ((.animOffsetMatrix).w,pc,d7),d4
	lea (a0,d4),a0
	tst.b objectListTriggers(a2)	; target player?
	beq animReturn
	clr.w d0
	move.b objectListCnt(a2),d5
	lsr #4,d5
	addx d0,d0
	lsl #5,d0
	lea (a0,d0),a0 ; flicker if targeting

    lea plyPos(pc),a1
    move.l viewPosition+viewPositionAdd(pc),d5
    add.l d5,objectListX(a2)	; x neutral to scrolling speeding
    moveq #-20,d0
    add plyPosX(a1),d0
    sub objectListX(a2),d0
    asr #4,d0        ; a-shift needed to keep sign
    move #200,d7
	add.w objectListAccX(a2),d7
	cmpi #400,d7
	bgt.b .reduceX
.s1
    add d0,objectListAccX(a2)
	moveq #-44,d0
    add plyPosY(a1),d0
    sub objectListY(a2),d0
    asr #4,d0
    move #200,d7
	add.w objectListAccY(a2),d7
	cmpi #400,d7
	bgt.b .reduceY
.s2
    add d0,objectListAccY(a2)
.noNewTargeting
	lea .bounds(pc),a1
    bra killCheck
.bounds
	dc.w $30,330
	dc.w $08,$f0
.reduceX
	asr objectListAccX(a2)
	bra.b .s1
.reduceY
	asr objectListAccY(a2)
	bra.b .s2



    	;	#MARK: L4 Bricklabyrinth
	; trig0=launch flag; trig1=child type; trig3=no.of.bricks; define gap through hitcnt in launchlist, y-launchdirection depends on y-launchposition
	; trig0=	 init
	; trig1=	addChild. 0= nil, 1=eyeShot, 2=sprayShot, ...
brickMed
	tst.b objectListTriggers(a2)
	bne.b .initBrick	; first call? init stuff!
		nop
	IF 1=1
	st.b objectListTriggers(a2)
	moveq #-$20,d5
	and.w d5,objectListX(a2)	; position at 32px border
	add #32*2,objectListX(a2)
	
	cmpi.w #$80,objectListY(a2)
	shi.b d6
	ext.w d6
	move #1<<8,d7
	eor d6,d7
	move d7,objectListAccY(a2)
	ENDIF
.initBrick

	tst.b objectListTriggers+1(a2)
	beq.b .addChild
	movem.l d3/a4,-(sp)
	clr.w d0
	move.b objectListTriggers+1(a2),d0
	sf.b objectListTriggers+1(a2)
	add.w d0,d0
	move.w (.childType,pc,d0),d0
.jmpAdr
	jmp .jmpAdr(pc,d0.w)
.childType
	dc.w .tooManyObj-.jmpAdr-2,.oceanEye-.jmpAdr-2,.discEye-.jmpAdr-2,.tubeTurret-.jmpAdr-2
.oceanEye
	move.l brickEyeAnimPointer(pc),a4
	bra.b .contInit
.tubeTurret
	move.l brickTurAnimPointer(pc),a4
	;move.l 	tubeTuLLAnimPointer(pc),a4
	bra.b .contInit
.discEye
	move.l brickDscAnimPointer(pc),a4
.contInit
	move.w animTablePointer+2(a4),d4
    st.b d3
	clr.w d5
	clr.w d6
	bsr objectInit
	tst.l d6
	bmi .tooManyObj
	move.l a4,objectListMyChild(a2)
	move.l a2,objectListMyParent(a4)
	move.b #attrIsImpactF,objectListAttr(a4)
	move.w #4<<2,objectListHit(a4)
	
	cmpa.l a2,a4		; new entry higher in list then current enty?
	bls.b .tooManyObj
	movem.l (sp)+,d3/a4
    addq #1,d3		; yes, process one add. object to avoid flicker
	bra.b .addChild
.tooManyObj
	movem.l (sp)+,d3/a4
.addChild

    moveq #30,d6		;x-offset
    clr.l d4
    add.w objectListY(a2),d4         ; load object y-coords
    add.w objectListX(a2),d6         ; load obj x-coords
    sub.w viewPosition+viewPositionPointer(pc),d6
	
    lea AddressOfYPosTable(pc),a3

						; brick moves up dwn, tst collission
	move.l d6,d5
	move.l d4,d0
	cmpi.w #$20,d4							; high on screen? Don´t test
	bls .quit
	cmpi.w #$e4,d4							; low on screen? Don´t test
	bhi .quit
	cmpi #$40,d6
	bls .quit
	cmpi #370,d6
	bhi .quit
	
	tst.w objectListAccY(a2)
	beq.w .goesLftRgt
	bmi.w .goesUp
	add #16,d0				; sensor@lower border
	bra .switchYDir
.goesUp
	sub #18,d0				; sensor@upper border
.switchYDir
    move.w (a3,d0.w*2),d0     ; y bitmap offset
	move.l mainPlanesPointerAsync(pc),a1
	lea (a1,d0.l),a1
    lsr #3,d5
    lea (a1,d5),a1	; add x-byte-offset

    tst.w (a1)			; has touched something
    beq .quit
	
		moveq #$1f,d5
		not.l d5
		and.l d5,d4
		add #$10,d4
		move.w d4,objectListY(a2)	; fix y-position
		;clr.l objectListAccY(a2)	; stop moving up/dwn
	

		move.l d4,d0	; check if move lft or rgt
		move.l d6,d5
	;	add.w #30,d5		; tst left sensor
		move.w (a3,d0.w*2),d0     ; y bitmap offset
		move.l mainPlanesPointerAsync(pc),d7
		add.l d0,d7
		lsr #3,d5
	;adda.w d5,a1             ; add x-byte-offset
		lsr.l #1,d7
		add.l d7,d7
		move.l d7,a1
		lea 4(a1,d5),a1	; -2 would be left sensor
		;move.w #$ffff,(a1)
		tst.w (a1)	; right sensor
		bne.b .xGoLft
		move #$10<<4,d7	; move right
		bra .applyXAcc
.xGoLft
		move #-$18<<4,d7	; move lft
.applyXAcc
	;andi #$fffc,objectListX(a2)
		move.l viewPosition+viewPositionAdd(pc),d6
		lsl.l #4,d6
		add.w d6,d7
		move d7,objectListAccX(a2)
		clr.w objectListAccY(a2)
		bra .quit

						; brick moves lft rgt, tst collission
	;bra .quit
.goesLftRgt
	;bra .quit
	move.l d6,d5
	move.l d4,d0
	tst.w objectListAccX(a2)
	beq.w .quit
	bmi.w .goesLft
	add.w #16,d5						; sensor@right border
	bra .switchXDir
.goesLft
	sub #12,d5						; sensor@left border
.switchXDir
    move.w (a3,d0.w*2),d0     ; y bitmap offset
    ;# !!!: use mainPLaneAsync instead?

	move.l mainPlanesPointerAsync(pc),a1
    ;move.l mainPlanesPointer(pc),a1
    adda.l d0,a1
    asr #3,d5
	
    adda.w d5,a1             ; add x-byte-offset
    tst.w (a1)			; has touched?
    beq .quit
	clr.w objectListAccX(a2)	; stop moving lft / rgt
	add.w #8,objectListX(a2)
	andi #$fff0,objectListX(a2)

		move.l d4,d0			; check if move up or dwn
		move.l d6,d5
		add.w #30,d0
		move.w (a3,d0.w*2),d0     ; y bitmap offset
		;# !!!: use mainPLaneAsync instead?

		move.l mainPlanesPointerAsync(pc),a1
		adda.l d0,a1
		lsr #3,d5
		adda.w d5,a1             ; add x-byte-offset
		tst.w (a1)
		bne.b .xGoDwn
		move #$1<<8,d7	; move dwn
		bra .applyYAcc
.xGoDwn

		move #-1<<8,d7	; move up
.applyYAcc
	    move d7,objectListAccY(a2)
.chgDirFlag
		;lea objectListTriggers(a2),a1
	;move.b #15,(a1)
.quit
	;RESTOREREGISTERS
	lea .bounds(pc),a1
    bra killCheck
;.kill
	;move.l cExplMedAnimPointer(pc),a3
	;move.w animTablePointer+2(a3),(a2)
	;move.b #31,objectListCnt(a2)
	;lea .bounds(pc),a1
    ;bra killCheck
.bounds
	dc.w -$10,$440
	dc.w -$30,$120
	





    ;	#MARK: - Animate tile

tileAnim
	move.b objectListCnt(a2),d0
	lsr #2,d0
	andi #%111,d0
	move.b .animFrames(pc,d0),d0
	lea (a0,d0),a0
		lea killBounds(pc),a1
	bra killCheck
.animFrames
	dc.b 0,0,2,2,4,4,4,2
	
        ;}

