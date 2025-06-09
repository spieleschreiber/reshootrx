
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
animBasicOffsets
    blk.w 4,0
non_Anim
    bra animReturn
emptyObj
	bra objectListNextEntry

    	;	#MARK: exit level and campaign
exitStage
	SAVEREGISTERS
	lea plyBase(pc),a5
	tst.b plyWeapUpgrade(a5)
	bmi objectListNextEntry	; is dying while reaching exit? Disable xit!

	move.b objectListTriggers+2(a2),d0
	ext.w d0
	move.w .jmpTable(pc,d0.w*2),d7
	jmp .jmpTable(pc,d7.w)
.jmpTable
	dc.w	.fadeVolume-.jmpTable	; move player, fade music, init explos	;[trig1536]
	dc.w	.movePlayer-.jmpTable	; move player, init explos, init spritetable[trig1537]
	dc.w	.doAchievementBoss-.jmpTable;[call this by trig1538]	
	dc.w	.doAchievementShots-.jmpTable;[call this by trig1539]
	dc.w	.doAchievementChain-.jmpTable;[trig1540]
	dc.w	.initTransition-.jmpTable;[trig1541]
.nilAction
	bra objectListNextEntry
.fadeVolume
    move.w #64,d1
    sub.b objectListCnt(a2),d1
    ;lsr.b #2,d1
    move.w #musicFullVolume,d0
    sub.w d1,d0
   	tst d0
   	bmi.b .movePlayer
    lea CUSTOM,a6
    jsr _mt_mastervol
.movePlayer
	lea plyBase(pc),a1
	st.b plyExitReached(a1)	; disable player control
.playerVesselXParkPos	SET $7a
.playerVesselYParkPos	SET $dc
	;move.l #(.playerVesselXParkPos&$ff<<2),d4
	;MSG01 m1,d4
	;move.w plyPosX(a1),d4
	;andi #$ff<<2,d4
	btst #0,objectListTriggersB(a2)
	bne .explosAndTables
	move.w plyPosX(a1),d4
	andi.w #$ff<<2,d4
	cmpi #(.playerVesselXParkPos&$ff<<2),d4
	bne .forceMove
	cmpi #.playerVesselYParkPos,plyPosYABS(a1)
	bcc .initSpriteTable
.forceMove
	clr.l d4
	move.w #.playerVesselYParkPos,d4	; max. y-position of player vessel
	sub.w plyPosYABS(a1),d4	; way to move
	moveq #11,d5
	lsl.l d5,d4
	add.l d4,plyPosY(a1)
	
	move #.playerVesselXParkPos,d4
	sub.w plyPosX(a1),d4
	ext.l d4
	lsl.l d5,d4
	add.l d4,plyPosX(a1)
	swap d4
	rol.l #3,d4
	move.w d4,plyPosAcclX(a1)	; this controls animation 
.reachedParkPosition
	lea     fastRandomSeed(pc),a5
	movem.l  (a5),d4/d5					; AB
	swap    d5						; DC
	add.l   d5,(a5)					; AB + DC
	add.l   d4,4(a5)				; CD + AB
	    ;May use d0,d4,d5,d6,d7,a0,a1,a3. Ma
	 
	 ; process delete-picture-border with filter applied 
	 
.oneScanline	SET 	mainPlaneDepth*mainPlaneWidth/4
.delScanlines SET	30
	clr.w d0
	st.b d0
	sub.b objectListTriggers(a2),d0
	beq .noExplo
	move.l fxPlanePointer(pc),a6
	lea -$a000(a6),a6	; set pointer to end of mainPlanesMemory
	
	moveq #$5,d2
   	ror.w #3,d2	; (mainPlaneWidth*mainPlaneDepth)*256
	move.l #(mainPlaneWidth*mainPlaneDepth)*256,d2
    move.l mainPlanesPointerAsync(pc),a1
	;move.l mainPlanesPointer+4(pc),a3
	;move.l mainPlanesPointer+0(pc),a3
	    
	move.w d0,d7
	andi #$ff,d7
	mulu #mainPlaneDepth*mainPlaneWidth,d7
	lea (a1,d7.l),a1
	;lea (a3,d7.l),a3
	
	lea noiseFilter+7*4(pc),a0

	move #.delScanlines,d3
	move d0,d7
	add d3,d7
	sub #256,d7
	;bmi .delAllScanlines
	;sub d7,d3		; do not process scanlines below lower border
.delAllScanlines
	cmpa.l a6,a1	; memory overflow area? If yes clr d2 to not write to twin screen buffer
	bhi .overflow
.overflowReturn
	move.l (a0),d4	; visual filter = 0? Keep deleting stuff!
	beq .keepDeleting
	lea -4(a0),a0
;	ror.l d5,d4 	; set visual filter
.keepDeleting
	move #.oneScanline-1,d7
.filterOneScanline
	move.l (a1),d0
	and.l d4,d0
	move.l d0,(a1,d2.l)
	move.l d0,(a1)+
	dbra d7,.filterOneScanline 
	dbra d3,.delAllScanlines

	; init some explosions

	cmpi.b #50,objectListCnt(a2)
	bls .noFX 	; no sfx close to upper border, set focus on achievement sfx 
	move.b frameCount+5(pc),d7
	lsl #5,d7
	tst.b d7
	bne .noFX
	lea CUSTOM,a6
	lea fxTable+(fxInitExplosionM-1)*12(pc),a0
	btst #8,d7
	sne d0
	andi #12,d0
	lea (a0,d0.w),a0
	bsr	_mt_playfx	; init M or L explosion sound
.noFX
	move d5,d0
	andi #$3f,d0
	
	add.b #1,objectListTriggers(a2)
	move.b objectListCnt(a2),d5
	move d5,d6
	andi #3,d6	; switch to 1 if framerate drops too much on CD32
	beq .noExplo
	andi #$7,d5
	lsl #5,d5
	add #195,d5
	eor d0,d5
	
	st.b d6
	sub.b objectListTriggers(a2),d6
	muls #320,d6
	lsr.l #8,d6
	
	add viewPosition+viewPositionPointer(pc),d6
	sub #60,d6
	move.l cExplLrgAnimPointer(pc),a1
	move.w animTablePointer+2(a1),d4
    st.b d3
	bsr objectInit
	tst.b d6
	bmi .noExplo 
	move d0,objectListAccX(a4)
	;move #200,d1
	andi #3,d0
	lsl #2,d0
	add d0,objectListY(a4)
	move #600,objectListAccY(a4)
	move.b #31,objectListCnt(a4); length of start anim
	move #0,objectListHit(a4); hitpoints
	move.b #attrIsNotHitableF,objectListAttr(a4);
.noExplo
	RESTOREREGISTERS
	bra objectListNextEntry
.explosAndTables
	bsr .updateBossAchvmnt
	bra .reachedParkPosition
.initSpriteTable
	bsr .modCoplist
	SAVEREGISTERS
	lea plyBase(pc),a0	
	lea .achievements(pc),a2

	move.w plyShotsFired(a0),d0
	cmpi #5000,d0
	blo .shotsWithinBounds		; more than 5000 shots? Cut!
	move #4999,d0
	move.w d0,plyShotsFired(a0)
.shotsWithinBounds
	bsr convertHexToBCD
    lea .achievementsShot-.achievements+7(a2),a3
    bsr .doConversion
    moveq #4,d0
    sub d7,d0
    move.b d0,.achievementsShot-.achievements(a2)	; adjust x-alignemt to left border 
    
    move.w plyWaveBonus(a0),d0
    beq .noChains
	cmpi #100,d0
	blo .chainWithinBounds		; more than 99 chains? Cut!
	move #99,d0
	move.w d0,plyWaveBonus(a0)
.chainWithinBounds

	bsr convertHexToBCD
    lea .achievementsChain-.achievements+7(a2),a3
    bsr .doConversion
.retChain
    moveq #4,d0
    sub d7,d0
    move.b d0,.achievementsChain-.achievements(a2)	; adjust x-alignemt to left border 
    RESTOREREGISTERS
	bsr .updateBossAchvmnt
	bsr .updateShotsAchvmnt
	bsr .updateChainAchvmnt
	bset #0,objectListTriggersB(a2)	; make sure this subcode is called only once
	bra .reachedParkPosition
.noChains
    move.l #"   0",.achievementsChain-.achievements+3(a2)
    moveq #2,d7
	bra .retChain 
.overflow
	clr.l d2
	bra .overflowReturn
	
.modCoplist ;[trig1537]
	SAVEREGISTERS
	
	move.w gameStatusLevel(pc),d0
	move.w (.addBoss,pc,d0),d0
	move.w d0,plyBase+plyBossBonus

	; temporarily write values to achievement counter
	;move.w #165,plyBase+plyShotsFired
	;move.w #23,plyBase+plyWaveBonus
	; endtemp
	
	clr.w d0
    move.b plyBase+plyWeapUpgrade(pc),d0
    move d0,d4
    lsl #5,d0
    lsl #4,d4
    add d4,d0	; 192 color slots all in all, 4 colors variants = 48 colors slots for fade
	move.l colorFadeTable(pc),a0
	lea (a0,d0),a0
	move.w 2(a0),d1
    move.w 192+2(a0),d3
    move.w 2+(192*2)(a0),d2	; restore player vessel colors

	lea copGameAchievementsQuit,a1
    move.w d1,6(a1)	; main weapon, darkest color
    move.w d2,6+4(a1)	; "", brightest color
    move.w d3,6+8(a1)	; "", middle color

	move.l achievementsEntry(pc),a1
	move.w #COPJMP1,d0
    move.w d0,12(a1); overwrite copJmp trigger
	move.l achievementsQuit(pc),a1
    move.w d0,12(a1); ""
.spriteCharMemsize	SET	charToSpriteMaxRows*charHeight*spriteLineOffset*3

    ;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter 
    
    
	move.l bobSource(pc),a6	;	creat coord conv table here. Do not need early bob entries any more, only explosions
	lea .spriteCharMemsize(a6),a1			;	sprite bitmap storage space
	move.l a1,d0
	move.l a1,a3
	move #(.spriteCharMemsize/4)-1,d7
.clrLoop
	clr.l (a3)+	; clear text area
	dbra d7,.clrLoop
	bsr createTableTextSpritesCoord

	lea copGameAchievements,a0
	move.l bobSource(pc),a1
	lea .spriteCharMemsize(a1),a1	
	;lea .spriteCharMemsize(a1),a1
	bsr installSpritePointers
	RESTOREREGISTERS
	rts
	
.updateShotsAchvmnt
	SAVEREGISTERS
	lea .achievements(pc),a2
	lea plyBase(pc),a0	
	lea tempVar(pc),a5
 	bsr .drawAchvmntShots 
.drawStuff
	lea .achievements(pc),a2
	lea fastRandomSeed(pc),a4
	lea font(pc),a5
	move.l bobSource(pc),a6	;store sprite data
	lea .spriteCharMemsize(a6),a1
	move #$3f,d3
	clr.w d4
	bsr drawTextToSprites
	RESTOREREGISTERS
	rts

.updateBossAchvmnt
	SAVEREGISTERS
	lea .achievements(pc),a2
	lea plyBase(pc),a0	
	lea tempVar(pc),a5
	pea .drawStuff
 	bsr .drawAchvmntBoss

.updateChainAchvmnt
	SAVEREGISTERS
	lea .achievements(pc),a2
	lea plyBase(pc),a0	
	lea tempVar(pc),a5
	pea .drawStuff
 	bsr .drawAchvmntChain

	
.drawAchvmntShots
	move.w plyShotsFired(a0),d0
	add d0,d0
	bsr convertHexToBCD
    lea .achievementsShots-.achievements+7(a2),a3
.doConversion
   	move #3,d7
.convertBCDtoDisplay		; convert bcd num to to displayable ascii chars
    move d1,d2
    lsr.w #4,d1
    andi #$f,d2
    add #$30,d2
    move.b d2,-(a3)
    dbra d7,.convertBCDtoDisplay
.delLeadingZeros			; delete all leading zeroes
	tst.b 1(a3)
	beq .doneWithLeadZeros
	bmi .doneWithLeadZeros 
	cmpi.b #"0",(a3)+
	bne .doneWithLeadZeros
	move.b #" ",-1(a3)
	add #1,d7	; needed to adjust text align elsewhere 
	bra .delLeadingZeros
.doneWithLeadZeros
    lea scoreMultiplier(pc),a4
	clr.l (a4)	; make sure multiplier does not set in
	rts

.drawAchvmntBoss
	move.w plyBossBonus(a0),d0
	bsr convertHexToBCD
    lea .achievementsBoss-.achievements+7(a2),a3
    bra .doConversion

.drawAchvmntChain
	clr.l d0
	move.w plyWaveBonus(a0),d0
	muls #100,d0
	bsr convertHexToBCD
    lea .achievementsChains-.achievements+7(a2),a3
    bra .doConversion

.doAchievementBoss	; called by trig1538
    lea viewPosition(pc),a0
    clr.l viewPositionAdd(a0); stop scrolling
   
	lea plyBase+plyBossBonus(pc),a1
	moveq #1,d6	; multiply achievement score by this value 
.doMulti21	
	move.w (a1),d0
	beq .dontPlayFX
	clr.l d1
.div	SET 10
	move d0,d1
	divu #.div,d1
	seq d7
	andi #1,d7
	add d7,d1	; if result = 0 -> 1
	sub.w d1,(a1)
	bne .isZeroed
	move.b #"0",.achievementsBoss+6	; down to zero? Skip all convert and cleanup code
.decay	SET 30
	move.b #.decay,objectListCnt(a2)	; set wait time until switch to next anim step
.isZeroed
	muls d6,d1	; variable multiply, depending on step in anim 
	lea scoreAdder(pc),a1
	add d1,(a1)	; add
	
	move.b objectListCnt(a2),d0
	and.b #$7,d0
	bne .dontPlayFX
    lsr #1,d0
    add.w #periodBase*2,d0
	lea (fxAchievement*fxSizeOf)+fxTable+6-12(pc),a0
	move.w d0,(a0)	; store modified hitpoints -> fx pitch
    PLAYFX fxAchievement
.dontPlayFX
 	bsr .updateBossAchvmnt
	RESTOREREGISTERS
	bra objectListNextEntry

.doAchievementShots	; called by trig1539
	lea plyBase+plyShotsFired(pc),a1
	moveq #2,d6
	bra .doMulti21

.doAchievementChain	; called by trig1540
	lea plyBase+plyWaveBonus(pc),a1
	moveq #100,d6
	bra .doMulti21
	
.addBoss
	dc.w 2000,3000,4000,5000
.achievements
    dc.b 6,1,"$BATTLE REPORT$",0
    dc.b 5,5,"$BOSS KILL BONUS$",0
.achievementsBoss    dc.b 15,6,"    0",0 
.achievementsShot
    dc.b 5,9,"$xxxx SHOTS X 2$",0
.achievementsShots    dc.b 15,10,"    0",0
.achievementsChain    dc.b 5,13,"$xxxx CHAINS X 100$",0
.achievementsChains    dc.b 15,14,"    0",-1

	even
.initTransition	;[trig1541]
	lea forceExit,a0
	st.b (a0)	; transition & exit
	RESTOREREGISTERS
	bra objectListNextEntry


    	;	#MARK: pathMarker
pathMarker
	bra objectListNextEntry
pathEmit
	bra objectListNextEntry


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

		;	#MARK: - exitKill - kill object on viewexit
		
killCheck	; general check if object leaves view. a1 contains pointer to xbounds.w & ybounds.w
    move.w objectListX(a2),d7
	
	move.l (a1),d0
	cmp d0,d7
	bgt killObject	; out of view right?
	swap d0
	cmp d0,d7
	blt killObject	; out of view left?
;	bra animreturn

    move.w objectListY(a2),d5
	sub.w viewPosition+viewPositionPointer(pc),d5
	
	move.l 4(a1),d0
	cmp d0,d5
	bgt killObject	; unten
	swap d0
	cmp d0,d5
	bgt animReturn
	
    ;cmp2.w (a1),d7
    ;bcs.w killObject
    ;cmp2.w 4(a1),d5
	;bcc animReturn	; left screen? Get rid of object!
killObject
	move.b #1,objectListCnt(a2)
	move.b #1,objectListLoopCnt(a2)
	bra objectListNextEntry
.bounds	; x&y-bounds
killBounds
	dc.w $a0,$1d0
	dc.w -$60,$110
killBoundsWide
	dc.w -$10,490
	dc.w -$100,$110
	
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
	bgt.b killObject	; out of view right?
	swap d0
	cmp d0,d6
	blt.b killObject	; out of view left?

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

	;	#MARK: - debrisRain
    ;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter bitmap load adress or use a0 if return to bobblitnext / not animreturn
debrsCtl
	move.w frameCount+2(pc),d0
	andi #$3,d0
	bne animReturn
	;bra animreturn
	SAVEREGISTERS
	move.l debrisA3AnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4

	;move.l debrisA1AnimPointer(pc),a4
	;move.w animTablePointer+2(a4),d4
	lea fastRandomSeed(pc),a6
.loop
	movem.l  (a6),d5/d6
	andi #$3f,d5
	lsl #2,d5	; $3f->$ff
	add #170,d5
	andi #$3f,d6
	clr.w d6
	;move.w 
	;add.w plyBase+plyPosY(pc),d6
	;sub #$3f,d6
		add.w viewPosition+viewPositionPointer(pc),d6
	;move.w plyBase+plyPosY(pc),d6
	;sub #$af,d6

    st.b d3
	bsr objectInit

	tst.l d6
	bmi.b .quit	; no more object slots available
	movem.l  (a6),d0/d1
	swap    d1
	add.l   d1,(a6)
	add.l   d0,4(a6); generate random nums
	lsr #6,d0
	
	move.w d0,objectListAccY(a4)
	lsr.b #1,d1
	add.b #7,d1
	;move.b #114,d1
	move.b d1,objectListCnt(a4)
	move.b #attrIsNotHitableF,objectListAttr(a4); attribs
.quit
	RESTOREREGISTERS
	bra objectListNextEntry

    ;	#MARK: - boss Roid, boneSnake
boneSnke
	tst.b objectListTriggersB(a2)
	beq .randomizeXAcc
.ret
    move.l objectListMyChild(a2),a1
    move.l objectListMyChild(a1),a1
    move.l objectListMyChild(a1),a1	; get adress of last tail object
    move.w objectListX(a1),d0
	move.b .boneSnakeAnimOffset+2(pc,d0.w),d0
	ext.w d0
    ;lea (a0,d0),a0
	;tst.b objectListTriggersB+3(a2)	; killcheck bit set?
	;beq animReturn	; no
	lea .killBounds(pc),a1
	bra killCheck
.randomizeXAcc
		lea     fastRandomSeed(pc),a0
	movem.l  (a0),d0/d1					; AB
	swap    d1						; DC
	add.l   d1,(a0)					; AB + DC
	add.l   d0,4(a0)				; CD + AB
	andi #$ff,d0
	ext.w d0
	asr #1,d0
	move #$130,d4		; center x position
	sub.w objectListX(a2),d4
	asr #1,d4
	add.w d4,d0
	move.w d0,objectListAccX(a2)
	st.b objectListTriggersB(a2)
	bra .ret
.killBounds
	dc.w $88,$1d0
	dc.w -$60,$110
.boneSnakeAnimOffset
	dc.b 8,4,4,4,0,0

boneSnkB
	move.w objectListX(a2),d0
	add #2,d0
	lea (a0,d0*2),a0
	bra animReturn
boneSnkA
	;ILLEGAL
	sub.l a0,a0
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
	
crabAtak
	    move.w objectListY(a2),d6
	    add.w viewPosition+viewPositionPointer(pc),d6
	        lsr #1,d6
   
	andi #$3<<3,d6
	;move #2<<3,d6
	lea (a0,d6.w),a0
    bra animReturn

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

    ;	#MARK: - Spinner
spinners
	move.w objectListAccX(a2),d6
	asr.w #5,d6
	spl d5
	andi.b #$1f,d5
	add.w #$10,d6
	cmpi.b #32,d6
	scc.b d4	;-1 if out of range
	and.b d4,d5
	not.b d4
	and.b d4,d6
	or.b d5,d6
	andi #$1f,d6
	move d6,d7
	
	move.w objectListAccY(a2),d6
	move d6,d5
	asr.w #6,d6
	asr.w #7,d5
	add.w d5,d6
	
	move.l viewPosition+viewPositionAdd(pc),d5
	lsl.l #2,d5
	swap d5
	not d5
	add d6,d5

	spl d4
	andi.b #$1f,d4
	add.w #$11,d5
	cmpi.b #$20,d5
	scc.b d0	;-1 if out of range
	and.b d0,d4
	not.b d0
	and.b d0,d5
	or.b d4,d5
	andi #%11111,d5
;	MSG03 m2,d5
;	MSG04 m1,d7
	lsl #5,d5
	add.w d5,d7
.anim
	clr.w d4
    move.b (tanTable.w,pc,d7),d4
	;MSG01 m2,d4
	lea (a0,d4),a0
			lea killBounds(pc),a1
    bra killCheck	; check exit view

.animOffsetMatrix	; table transform x/y-vector to anim offet / angle

    ;	#MARK: - eyeRoid
eyesRoid
	; triggers+0		bit0	0=static, 1=move
	;					bit1	0=shotStream	1=shotWhenHit
	; triggers+1		AND-value (shot frequency)
	; triggers+2		shot launch drag  (shot frequency)

    add.b #1,objectListTriggersB(a2)

    move.w objectListX(a2),d0	; flyby anim
	sub.w viewPosition+viewPositionPointer(pc),d0
	cmpi #-20,d0
	ble killObject
	tst.w objectListY(a2)
	bmi killObject
	
	btst #0,objectListTriggers(a2)
	beq.b .basicAnim
	add.w #28,d0	; flyby anim
	divu #48,d0
	move d0,d7
	lsl #2,d0
	add.w d7,d0
	add.w d7,d0
	move d0,d7
	add.b #8,d7
	not.b d7
	move.b d7,objectListTriggersB+1(a2)
	bra .set
.animOffset
	dc.b 0,0,6,6,6,6,12,12
	dc.b 12,18,18,24,24,30,30,36
	dc.b 36,42,42,42,36,36,30,24
	dc.b 18,18,12,6,6,6,0,0
.basicAnim
    move.b objectListTriggersB(a2),d0
	move.b d0,objectListTriggersB+1(a2); sync anim and shot pos
	lsr #2,d0
	andi.w #$1f,d0
	move.b .animOffset(pc,d0),d0
.set
	lea (a0,d0),a0
	btst #1,objectListTriggers(a2)
	beq.b .shotStream
	;tst.b objectListTriggers+2(a2)
	;bne .shotStream
	move.w objectListHit(a2),d7
	lsr #2,d7
	lea (.cmpHit,pc),a1
	cmp.w (a1),d7
	beq animReturn
	move.w d7,(a1)
.shotStream
	move.b objectListCnt(a2),d7	; launch bullets
	and.b objectListTriggers+1(a2),d7
	bne .q
	SAVEREGISTERS
	lea (.ret,pc),a5
	move.l a2,a6
	move.l eyesShotAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
	
	move.b objectListTriggersB+1(a2),d7
	lsr #3,d7
	andi #$f,d7

	move.b .posOffset(pc,d7),d5
	move.b d5,d6
	ext.w d6
	add.w objectListY(a6),d6
	ext.w d5
	add.w #42,d5
	add.w objectListX(a6),d5
    st.b d3
	bsr objectInit
;	moveq #-1,d6
	tst.l d6
	bmi .skip
	move.b #attrIsSpriteF!attrIsNotHitableF,objectListAttr(a4); attribs
	bra .ret
.cmpHit
	dc.w 0
.posOffset
	dc.b -8,-6,-4,-2,1,6,11,13
	dc.b 16,13,11,8,1,-2,-4,-6
.accOffset
	dc.b -100,-100
	dc.b -70,-70
	dc.b -30,-30
	dc.b 10,10
	dc.b 30,30
	dc.b 60,60
	dc.b 90,90
	dc.b 120,120
.ret
	tst.l d6
	bmi .skip
	move.b objectListTriggersB(a2),d7
	lsr #3,d7
	andi #7,d7
	move.w .accOffset(pc,d7*2),d0
	move.b d0,d1
	ext.w d1
	move.b objectListTriggers+2(a2),d7
	lsl #5,d7
	ext.w d7
	lsl #3,d7
	add.w d7,d1

	move.w d1,objectListAccX(a4)
	lsr #7,d0
	ext.w d0
	move.w d0,objectListAccY(a4)
	PLAYFX 16
	
	cmpa.l a2,a4		; new entry higher in list then current enty?
	bls.b .skip	; no
    RESTOREREGISTERS
    addq #1,d3		; yes, process one add. object to avoid flicker
	bra animReturn

.skip
	RESTOREREGISTERS
.q
	bra animReturn

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


	
tilterXX
	;MSG02 m2,d6 
	tst.b objectListTriggers(a2)
	bne .shoot
	
	move objectListAccX(a2),d6
	asr #5,d6
	add.b objectListTriggers+2(a2),d6
	;move #0,d6
	;add.w d4,d6
	;move.l viewPosition+viewPositionAdd(pc),d5
	;asr.l #4,d5
	;sub.w objectListAccX(a2),d5
	;MSG02 m2,d5
	
	;spl d4
	;ext.w d4
	
	;eor.w d4,d6
	;eor #$1f,d6
	move.b d6,objectListTriggers+1(a2)
.anim
	andi #$1f,d6
	move.b ((.offset).w,pc,d6.w),d6
	lea (a0,d6.w),a0 
	bra animReturn
.shoot
	add.b #1,objectListTriggers+1(a2)
	move.b objectListTriggers+1(a2),d6
	lsr #1,d6
	bra .anim
.offset
	;blk.b 32,44
	dc.b 	4*0,4*0,4*1,4*1,4*2,4*3,4*4,4*5
	dc.b	4*6,4*7,4*8,4*9,4*10,4*10,4*11,4*11
	dc.b 	4*11,4*10,4*10,4*9,4*8,4*7,4*6,4*5
	dc.b 	4*4,4*3,4*2,4*2,4*1,4*1,4*1,4*0
	
	;dc.b	24,24,28,32,36,40,44,40
	;dc.b 	40,36,32,28,28,28,24,24
	;dc.b	24,24,20,20,16,12,8,4
	;dc.b	0,4,8,12,16,20,20,24
	;dc.b 4*10,4*9,4*8,4*7,4*6,4*5,4*4,4*3
	
	
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
	
    	;	#MARK: Scroll Controller
scrlCtrl
	; objecttrigger 0 toggles slowdown to stop (trig1025) or alternative speed (trig1026, trig1027 etc.) 
	; objecttrigger 1 toggles acceleration. bit0 = 1 -> accelerate, bit0 =  0 OR bit 1,2,3 (boundary number of objects which inits acceleration proc). (trig1281 = accel.)(trig1283 = accel. if less than 3 objects) 
	lea objectListTriggers(a2),a1
	tst.b (a1)
	bne .slowDown	; trig0 active?
	tst.b 1(a1)
	beq objectListNextEntry	; trig1 active?
.accelerate
	move.b #2,objectListCnt(a2)		; pause cmd flow
	btst #0,1(a1)
	beq .waitObjectEvent	; if bit0 -> accelerate!
.acclScrol
	lea viewPosition(pc),a0
	move #$80,d0
	lsl #2,d0
	sub.l d0,viewPositionAdd(a0)
	movem.l viewPositionScrollspeed(a0),d0/d4	; load viewPositionScrollspeed and viewPositionAdd
	cmp.l d0,d4
	bge objectListNextEntry
	sf.b 1(a1)					; reset trigger
	move.b #1,objectListCnt(a2)
	move.l d0,viewPositionAdd(a0)	; restore original scrollspeed
	bra objectListNextEntry
.waitObjectEvent
	move.b 1(a1),d0
	lsr #1,d0
	cmp bobCountHitable+2(pc),d0
	bhi .acclScrol		
	bra objectListNextEntry
.slowDown
	clr.l d5
	move.b (a1),d5
	sub #1,d5
	lsl #4,d5
	;MSG02 m2,d5
	move.b #2,objectListCnt(a2)	; pause cmd flow
	lea viewPosition(pc),a0
	move #$80,d0
	lsl #2,d0
	add.l d0,viewPositionAdd(a0)
	move.l viewPositionAdd(a0),d4
	not d5
	ext.l d5
	asl.l #8,d5
	cmp.l d5,d4
	ble objectListNextEntry
	;clr.l viewPositionAdd(a0)
	move.b #1,objectListCnt(a2)
	sf.b (a1)
	bra objectListNextEntry
		
    	;	#MARK: Meteor shower emitter

meteoCoordtable
	dc.b 0, 40,90, 140, 240, 120, 70, 190 
metEmitr
	bra objectListNextEntry
	tst plyBase+plyCollided(pc)
	bne.w .noMeteorLaunch

	lea objectListTriggers(a2),a1
	tst.b (a1)
	beq .noMeteorLaunch
	sf.b (a1)

 	add.b #1,1(a1)
 	move.b 1(a1),d0
	SAVEREGISTERS
	move.l meteoMedAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
	move #170,d5
	clr.w d6
	andi #7,d0
	
	move.b (meteoCoordtable,pc,d0),d6
	lsr #1,d6
	add d6,d5
	moveq #-62,d6
	add.w viewPosition+viewPositionPointer(pc),d6
	
    st.b d3
	bsr objectInit
	tst.l d6
	bmi .tooManyObj
	;clr.l objectListHit(a4)
    move.w #3<<2,objectListHit(a4); hitpoints
    move.b #attrIsImpactF,objectListAttr(a4); attribs
    ;move.b #0,objectListAttr(a4); attribs
    lea objectListAttr(a4),a3
    ;ALERT01 m2,a3
	bra .tooManyObj
;    move.b #4,objectListCnt(a4)    ; lifespan


    clr.l objectListMyParent(a4)   ; clear parent pointer
    clr.l objectListMyChild(a4)   ; clear child pointer
	clr.l objectListTriggers(a4); reset object triggers
	clr.l objectListTriggersB(a4); again
	st.b objectListWaveIndx(a4)   ; clear wave index ($ff)
    
    clr.w d7
    move.b $bfe601,d7	; get random number
    move d7,d6
    ;lsl #1,d7
    sub #40,d7
    move #$40,d7
	move.w d7,objectListAccX(a4)

	roxr.b #1,d6
	lsl #1,d6
	clr.l d7
    sub.l viewPosition+viewPositionAdd(pc),d7
    asl.l #8,d7
    swap d7
    add d7,d6
	add #$70,d6
	move #$70,d6
	move d6,objectListAccY(a4)
	
	cmpa.l a2,a4		; new entry higher in list then current enty?
	bls.b .tooManyObj
    RESTOREREGISTERS
    addq #1,d3		; yes, process one add. object to avoid flicker
	bra objectListNextEntry
.tooManyObj
	RESTOREREGISTERS
.noMeteorLaunch
	bra objectListNextEntry


meteoMed
			bra .quit
	clr.l d0
	;clr.l d7
	moveq #12,d7
    add.w objectListY(a2),d7         ; load object y-coords
    move d7,d0
	sub.w viewPosition+viewPositionPointer(pc),d0
    add.w frameCount+2(pc),d7
    add.w objectListX(a2),d7
    lsr #3,d7
    andi #$f,d7
    move.b (.animFrames.w,pc,d7),d7 
    lea (a0,d7),a0	; animate

	tst.w plyPos+plyCollided(pc)
	bne.b .quit			; player died? No coltest


	move.l .yBounds(pc),d6
	cmp d6,d0
	bgt.b .quit
	swap d6
	cmp d6,d0
	blt.b .quit

    ;cmp2.w (.yBounds,pc),d0	: too low or far? Skip col test
	;bcs.b .quit
	
	clr.l d7
	move #-170,d7
    add.w objectListX(a2),d7	; load obj x-coords – plyPosX
    ;ALERT01 m2,d7
	move.l .xBounds(pc),d6
	cmp d6,d7
	bgt.b .quit
	swap d6
	cmp d6,d7
	blt.b .quit
		
	
    ;cmp2.w (.xBounds,pc),d7
    ;bcs.b .quit	; out of view left or right? dont coltest

    lea AddressOfYPosTable(pc),a3	; check col with rocks
	clr.l d6
	move d0,d6
	move.w (a3,d0.w*2),d0     ; y bitmap offset
	move.l mainPlanesPointerAsync(pc),a1
	adda.l d0,a1
	lsr.l #3,d7

    adda.l d7,a1             ; add x-byte-offset
	tst.w (a1)	; chk bckgnd collission
	bne.b .initColl
.quit
	;move.l objectListTriggersB(a2),d0
	tst.b objectListTriggersB+3(a2)	; killcheck bit set?
	beq animReturn	; no
	;bra animReturn
	lea killBounds(pc),a1
	bra killCheck
.yBounds
	dc.w $20,$f8
.xBounds
	dc.w $0,$120
.animFrames
	dc.b 0,4,8,12,16,20,24,28
	dc.b 28,24,20,16,12,8,4,0
.initColl

	lea plyPos(pc),a1
	tst.b plyCollided(a1)
	bne.b .quit	; player dies? Dont collide with debris
	
.hasCollided
	;move #$f0,d6
	SAVEREGISTERS
	clr.l d1
	;move.b viewPosition+viewPositionPointer+1(pc),d1
	;ALERT03 m2,d1
    clr.l d1
    clr.w d4
    move.b objectDefHeight(a4),d4
	
	move d6,d1
    lsr #1,d4
    sub.w d4,d1
	move.w (a3,d1.w*2),d1     ; y bitmap offset
    move.l mainPlanesPointerAsync(pc),a1
    add.l d7,d1
	adda.l d1,a1
	move d6,d0
	clr.w d1
    move.b objectDefHeight(a4),d1
    subq #1,d1
	;ALERT01 m2,d6
	sub.w d4,d0
	add.b d1,d0
	bcc .yOverflow	; does object overflow lower border?
	sub.b d0,d1		; yes -> modify object height
	sub #2,d1
.yOverflow

   	
   	;clr.l d1
	moveq #mainPlaneWidth,d2
	lea (8*8),a5
	movem.l d1/a0/a1,-(sp)
.drawMain
	moveq #3,d0
.drawToPlane					; stamp meteorite into bitplane
		move.l (a1),d4
		move.l (a0),d5
		move.l 4*8(a0),d3
		not.l d3
		and.l d3,d4	; mask source
		or.l d5,d4
		move.l d4,(a1)
		adda.l a5,a0
		adda.l d2,a1
	dbra d0,.drawToPlane
	dbra d1,.drawMain
	movem.l (sp)+,d0/a0/a1

    clr.w d4
    
    move.b objectDefHeight(a4),d4
    clr.l d1
    
    
   	move d6,d1
    lsr #1,d4
    sub.w d4,d1
;    sub #2,d1
	move.w (a3,d1.w*2),d1     ; y bitmap offset
    move.l mainPlanesPointerAsync(pc),a1
    add.l d7,d1
	adda.l d1,a1
	
	clr.w d7
	move.b viewPosition+viewPositionPointer+1(pc),d7
	add.b d6,d7
	bcs .skip	; overflow on lower border? Skip copy draw


	;ALERT01 m2,d7
;.skipCC
	;move d6,d0
	clr.w d7
    move.b objectDefHeight(a4),d7
    subq #1,d7
	;add d7,d1
	;ALERT01 m2,d6
	;sub.b viewPosition+viewPositionPointer+1(pc),d7
	;add.b d7,d6
	;bcc .yOverflowB	; does object overflow lower border?
	;ALERT01 m2,d1
	;sub.b d1,d7		; yes -> modify object height
	;sub #2,d7
.yOverflowB

	movem.l mainPlanesPointer(pc),a3/a4/a6
	adda.l d1,a3
	adda.l d1,a4
	adda.l d1,a6

	moveq #$5,d1
   	ror.w #3,d1	; (mainPlaneWidth*mainPlaneDepth)*256 = $a000

	;move.l d0,d7
.drawSecondary
	moveq #3,d0
.drawToPlaneB					; stamp meteorite into bitplane
		move.l (a1),d4
		move.l (a0),d5
		move.l 4*8(a0),d3
		not.l d3
		and.l d3,d4	; mask source
		or.l d5,d4
		move.l d4,(a3,d1.l)
		move.l d4,(a4,d1.l)
		;moveq #-1,d4
		move.l d4,(a6,d1.l)
		adda.l a5,a0
		adda.l d2,a1
		add.l d2,d1
	dbra d0,.drawToPlaneB
	dbra d7,.drawSecondary
	
	
	
.skip
	move.l cExplLrgAnimPointer(pc),a3
	move.w animTablePointer+2(a3),(a2)    ; objectListAnimPtr. object hit, change to explosion animation
	move.b #31,objectListCnt(a2)    ;
	;add.w #$2,objectListX(a2)
	sub.w #24,objectListY(a2)
	move.b #attrIsNotHitableF,objectListAttr(a2); attribs
	PLAYFX 4
	
	move.w objectListX(a6),d4         ; load shot y-coords
    clr.w d5
   ; add.w plyPos+plyPosXDyn(pc),d4
    clr.w d6
    ;move.w collTableXCoords-2(a6),d3         ; load shot x-coords
	;lsl #4,d3
	;lsl #8,d4
	move.w #-140,d3
	add.w objectListX(a2),d3
    ;add #90,d3
	sub.w plyBase+plyPosXDyn(pc),d3
	lsl #4,d3;	move objectListX(a2),d3
	move objectListY(a2),d4
	sub.w viewPosition+viewPositionPointer(pc),d4
	add #35,d4
	;move #80,d4
	lsl #8,d4
	clr.w d5
	clr.w d6
	
    lea emitterMetShower(pc),a0
    bsr particleSpawn           ; draw particles
.qqq
	RESTOREREGISTERS
	bra objectListNextEntry
	
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

;	#MARK: - Animate tube tentacles

tubeHead
	move.l objectListMyParent(a2),a1
	beq animReturn
	move.w objectListY(a1),d4
	lsr #1,d4
	
	move.w objectListX(a1),d5
	smi d6
	andi #$02,d6
	add d4,d4
	;add #2,d4
	move.w d4,objectListY(a2)	; copy parentY to objectY
	add d6,d5
	move.w d5,objectListX(a2)	; copy parentY to objectY	- adjust position of head

	moveq #7,d4
	move.w objectListY(a1),d5 ; sync animframe/angle to y-dist
	tst.w objectListX(a1)
	smi d6	; object is to the left? sub.w d5,objxpos! 
	ext.w d6
	eor d6,d5
	add d5,d4
tubHeadGen
	;tst.w d4
	spl d5	; animframe not be lower than 0
	ext.w d5
	and d5,d4

	cmpi #$f,d4	; animframe not be higher than $f
	scc d5
	or d5,d4 
	andi #$f,d4

	tst.b objectListTriggers(a2)
	beq .noAlert
	btst #0,frameCount+3(pc)
	seq d5
	andi #$10,d5
	add d5,d4
.noAlert
	lea (a0,d4*2),a0
	bra animReturn


tubeTenR
	moveq #7,d4
	sub.w objectListY(a2),d4
	bra tubeTenGen
tubeTenL
;	bra animReturn
	moveq #7,d4
	add.w objectListY(a2),d4
tubeTenGen
	smi d5
	
	cmpi #$f,d4
	;blo .222
	;move #$f,d4
.222
	scc d6
	or d6,d4 

	ext.w d5
	eor d5,d4
	andi #$f,d4
	lea (a0,d4*2),a0
	bra animReturn

tubeBase
    ;May use d0,d4,d5,d6,d7,a1,a3

	move.w frameCount+4(pc),d7
	move d7,d6
	lsr #1,d7
	lsr #2,d6
	sub d6,d7
	andi #%0111,d7
	move.b .animFrames(pc,d7),d7
	lea (a0,d7),a0	; animate body / heart

	; control position of child objects / tube body
	move.l objectListMyChild(a2),a1
	move.l plyBase+plyPosY(PC),d0
	sub.l objectListY(a2),d0
	move.l d0,d4
	asr.l #4,d0
	asr.l #6,d4
	sub.l d4,d0
	clr.w d7
	move.w objectListAccY(a1),d7
.modifyYPos
	tst.l a1
	beq .skip
	move.l d0,d7

	clr.l d6
	clr.l d5
	move.b objectListCnt(a1),d6
	move #$70,d5
	sub.b sineTable(pc,d6),d5
	lsl.l #8,d5
	lsl.l #1,d5
	add.l d5,d7
	move.l d7,objectListY(a1)
	move.l objectListMyChild(a1),a1
	bra .modifyYpos
.skip
	lea killBoundsWide(pc),a1
	bra killCheck
.animFrames
	dc.b 2,2,2,4,6,6,0,0

;	#MARK: - OceanEye
oceanEye
oceanEyU
	tst.b objectListTriggers(a2)
	beq.b .basicAnim
	lea 8(a0),a0	; bright eye
	tst.b objectListTriggersB+3(a2)	; killcheck bit set?
	beq animReturn	; no
	lea killBounds(pc),a1
	bra killCheck
.basicAnim
	clr.w d0
	move.w frameCount+4(pc),d4
	lsr #4,d4
	addx d0,d0
	add.w d0,d0
	add.w d0,d0
	lea (a0,d0),a0
	tst.b objectListTriggersB+3(a2)	; killcheck bit set?
	beq animReturn	; no
	lea killBounds(pc),a1
	bra killCheck



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
	move.w .jmpAdr(,pc,d0),d0

	jmp .jmpAdr(pc,d0.w)
.jmpAdr
	dc.w .tooManyObj-.jmpAdr,.oceanEye-.jmpAdr,.discEye-.jmpAdr,.tubeTurret-.jmpAdr
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
	


	;	#MARK: Debris Animations
debris
	;bra animReturn
	move.b objectListCnt(a2),d7
	;move.b #3,d6
	;move.b objectListY+1(a2),d7
	;swap d7
	;lsr #5,d7
	;add.b d6,d7
	;MSG02 m2,d6
	
	;lsr.b d6,d7
	;lsr #1,d7
	andi #$f<<1,d7
	lea (a0,d7),a0
	bra animReturn
	
	;	#MARK: Invader explosions
expl_lrg
    move.b objectListCnt(a2),d6
    lsl #1,d6
    not d6
	andi #$7<<3,d6
	lea (a0,d6.w),a0
    bra animReturn
expl_med
    move.b objectListCnt(a2),d6
    not d6
	andi #$7<<2,d6
	lea (a0,d6.w),a0
    bra animReturn
expl_sml
    move.b objectListCnt(a2),d6
    lsr #1,d6
    not d6
	andi #$7<<1,d6
	lea (a0,d6.w),a0
    bra animReturn

    ;	#MARK: - Summon Mist
mistObjc
	tst.b objectListTriggersB(a2)
	bne.b .clear
	lea rastListMover(pc),a1
	move.w (a1),d6
	move.w d6,d5
	lsr #6,d6
	lsr.w d5,d6
	andi #$7f,d6
	st.b objectListTriggersB(a2)
.clear
	lea fxPlanePointer(pc),a0
	move.l 12(a0),a1
	move.l 4(a0),a0
	SAVEREGISTERS
	move.b objectListCnt(a2),d6
	move d6,d0
	andi.w #3,d0
	lsr #2,d6
;	sub #4,d6
	;not d6
	andi.w #$3f,d6
	lea .addPlane(pc),a3
	move.l (a3,d0*4),d4
	move d4,d5
	clr.w d4
	swap d4
	adda.l d4,a0
	adda.l d4,a1
	move.b #$ff,d3
	adda.w d6,a1
	adda.w d6,a0
	move.l objectListTriggers(a2),d6
	tst.b objectListTriggers(a2)
	beq.b .fill
	clr.b d5
	clr.b d3
.fill
	move.w #fxPlaneWidth,d4
	move.w #fxplaneHeight-1,d7
.drawRow
	move.b (a1),d6
	and.b d5,d6
	move.b d6,(a0)
	move.b 1(a1),d6
	and.b d3,d6
	move.b d6,1(a0)
	adda.w d4,a0
	adda.w d4,a1
	dbra d7,.drawRow
	RESTOREREGISTERS
	bra objectListNextEntry
.addPlane	; bitplane offset and bitmask
	;dc.w $c+fxPlaneWidth*fxplaneHeight*2,$ff
	;dc.w $c+fxPlaneWidth*fxplaneHeight*1,$3f
	;dc.w $c,$0f
	;dc.w $c,$03


    ;	#MARK: - Kraken Animation

krakenSmall
	move.l objectListAcc(a2),d7    ; get x- and y-acceleration
	move.w viewPosition+vPyAccConvertWorldToView(pc),d0
	
	sub.w d7,d0 ; convert to y-acceleration in view
	swap    d7
	move.w    d7,d6
	add.w    d0,d6
	smi    d6
	sub.w    d0,d7
	smi    d7
	eor.b    d7,d6
	
   	move d6,d7
	andi #32,d6
	not d7
	andi #2,d7
	move.b objectListAcc+1(a2,d7),d7
	lsr.b #3,d7
	add.b d6,d7
	lea (a0,d7),a0
	lea killBounds(pc),a1
	bra killCheck

    ;	#MARK: - Control VFX Layer 

vfxController
    ;trig1281: init copy of VFX Upper Bitmap to Lower Bitmap
    
    ;trig1024	stop vfx scrolling
    ;trig1040 	init northsouth scrolling, med speed
    ;trig1070	init ns scrolling, high speed 
    ;trig1024+64+x	init southnorth scrolling, high speed
    
    ;trig1537	set vfx wave anim speed to idle
    ;trig1544	set vfx wave anim speed to idle
     
	tst.b objectListTriggers+1(a2)
	bne .copyVfx
.cont
	lea viewPosition+vfxPositionAdd(pc),a1
	move.b objectListTriggers+2(a2),d7
	beq .tstModSpeed
	sub #1,d7
	move.b d7,3(a1)	; vfxAnimSpeed
.tstModSpeed
	move.b objectListTriggers(a2),d7
	beq objectListNextEntry
	moveq #31-16,d6
	and.b frameCount+3(pc),d6
	bne .quit
	move.b 1(a1),d6
	cmp.b d6,d7
	ble objectListNextEntry
	shi d6
	andi #1,d6
	cmpi.b #64,d7	; bit 6 set? Scroll southnorth
	shi d7
	;eor.b #1,d7
	ext.w d7
	eor.w d7,d6		; negative add value
	seq d7
	sub.b d7,d6
	lsl #1,d6
	add.w d6,(a1)
.quit
    bra objectListNextEntry
.copyVfx
	SAVEREGISTERS
.delScanlines SET	30
.oneScanline	SET 	mainPlaneDepth*mainPlaneWidth/4
	lea noiseFilter+8*4(pc),a0

	clr.w d0
	move.b objectListCnt(a2),d0
	not.b d0
	move d0,d1
	cmpi.b #256-.plotLines,d0
	bhi .stopCopy
	muls #40,d0

	move.l fxPlanePointer+4(pc),a1
	add.w d0,a1
.loopOut
.plotLines SET	8
	move.w #.plotLines-1,d6
	move.w 80*256-40,d2
.nextLine
	move.l a1,a2
	lea 40*256(a2),a3
	move.l (a0),d4	; visual filter = 0? Keep deleting stuff!
	lea -4(a0),a0
	move.w viewPosition+vfxPosition(pc),d5
	lsr #3,d5
	cmpi.w #100,d5	; copyframe out of sight? Switch to no noise copymode
	sls d7
	ext.w d7
	ext.l d7
	or.l d7,d4
	andi #7,d1
	rol.l d1,d4
	move.w #3,d5
.plotBitplane
	move #9,d3
.loop
	move.l (a2)+,d7
	and.l d4,d7
	move.l d7,(a3)+
	dbra d3,.loop
	lea 80*256-40(a2),a2
	lea 80*256-40(a3),a3
	dbra d5,.plotBitplane
	lea 40(a1),a1
	dbra d6,.nextLine
.quitB
	RESTOREREGISTERS
	bra .cont
.stopCopy
	clr.b objectListTriggers+1(a2)
	bra .quitB


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
	

    ;	#MARK: - Animate Dialogue

;May use d0,d4,d5,d6,d7,a1,a3

dialogue

	lea copGameDialogueExit,a1
	tst.b objectListTriggers(a2)
	bne .restoreCoplist
	SAVEREGISTERS
	lea copGameDialgExitBPLPT,a1
    move.l mainPlanesPointer+0(pc),d7
    add.l #(dialogueStart-displayWindowStart+dialogueHeight-1)*mainPlaneDepth*mainPlaneWidth,d7
 	moveq #40,d0
 	bsr .updateBPLPT

	lea copDialogueBPLPT,a1
	moveq #30,d7
	add.l a0,d7
.add SET 256/8
	cmp.w 6(a1),d7
	beq .updateDone	; update bitplane pointers only if different
	moveq #32,d0
 	bsr .updateBPLPT
.updateDone

    lea copGameDialgExitBPLPT,a1 
	tst.b objectListTriggers+1(a2)
	beq .initBaddieColors

	move.l copperDialogueColors(pc),a0
	lea $50(a0),a0
	move.l a0,copInitColorswitch
	sf.b objectListTriggers+1(a2)
	
	tst.l (fxSpeechBaddie,pc)
	beq .initBaddieColors
	PLAYFX fxSpeechBaddie
.initBaddieColors

	tst.b dialogueIsActive(pc)
	bne .quit
.initCoplist		; first run -> init coplist
	move.l copperDialogueColors(pc),copInitColorswitch	; init hero colors @ vbi
	WAITVBLANK
    lea copGameDialogueExit,a1
    moveq #4,d2 
	add.l dialogueExit(pc),d2
    move.w d2,copGameDialgQuit+6-copGameDialogueExit(a1)
    swap d2
    move.w d2,copGameDialgQuit+2-copGameDialogueExit(a1)	; modify return jump to main coplist

	lea coplist,a0
    move.w copBPLCON0+2-coplist(a0),d0
    move.w copBPLCON2+2-coplist(a0),d1
	move.w d0,copGameDialgExitBPLCON0+2-copGameDialogueExit(a1)
    move.w d1,copGameDialgExitBPLCON2+2-copGameDialogueExit(a1)
	move.w #$54af,-4(a1)	; reset waitcmd for players cop-sublist split

	lea (viewStageTable,pc),a0
	lea copDialogueFlex,a2
	bsr subViewFlexFiller

	WAITVBLANK
	move.l dialogueEntry(pc),a1
	move.w #COPJMP1,12(a1); overwrite copJmp trigger

	st.b dialogueIsActive

	tst.l (fxSpeechHero,pc)
	beq .quit
	PLAYFX fxSpeechHero
.quit
	RESTOREREGISTERS
	bra objectListNextEntry
.restoreCoplist
    sf.b dialogueIsActive
	move.l dialogueEntry(pc),a1
	move.w #NOOP,12(a1); overwrite copJmp trigger
	bra objectListNextEntry
.updateBPLPT
    move d7,6(a1)
	swap d7
	move d7,2(a1)
	swap d7
	add.l d0,d7
    move d7,6+8(a1)
    swap d7
    move d7,2+8(a1)
    swap d7
    add.l d0,d7
    move d7,6+16(a1)
    swap d7
    move d7,2+16(a1)
	swap d7
    add.l d0,d7
    move d7,6+24(a1)
    swap d7
    move d7,2+24(a1)
	rts

subViewFlexFiller
	move.w gameStatusLevel(pc),d0
	move.w (a0,d0.w*2),d0
	lea (a0,d0.w),a0
	
	move.w #NOOP,d4
	move #10,d5	; no. of entrys in copDialogueFlex
	move.l (a0)+,d1
	move.l d1,(a2)+
.fetchCopFlex
	movem.w (a0)+,d0/d1
	cmp.w d4,d0
	beq .cleanUp
	movem.w d0/d1,(a2)
	lea 4(a2),a2
	dbra d5,.fetchCopFlex
.cleanUp
	move.w (a0)+,d0	; get exit COLOR00
	move.w #NOOP,d4
	swap d4
	clr.w d4
	bra .fillUpLoop
.loop
	move.l d4,(a2)+
.fillUpLoop
	dbra d5,.loop
	rts
viewStageTable	
	; dialogue table pointers
	dc.w .stage0-viewStageTable,.stage1Escalation-viewStageTable,.stage2-viewStageTable,.stage3-viewStageTable, .stage4-viewStageTable
	; escalation table pointers
	dc.w .stage0-viewStageTable-10,.stage1Dialogue-viewStageTable-10,.stage2-viewStageTable-10,.stage3-viewStageTable-10,.stage4-viewStageTable-10
.stage0
;	CMOVE COLOR00,0
	CMOVE BPLCON3,$a<<12|BRDRBLNKF|%111<<9
	CMOVE NOOP,0
	dc.w $520
.stage1Escalation
	CMOVE BPLCON3,$0020
	CMOVE COLOR00,$b99
	CMOVE COLOR17,$caa
	CMOVE COLOR18,$da9
	CMOVE COLOR19,$dda
	CMOVE COLOR20,$cb9
	CMOVE COLOR21,$db9
	CMOVE COLOR22,$c99
	CMOVE COLOR23,$dcc
	CMOVE BPLCON3,$a<<12|BRDRBLNKF|%111<<9
	CMOVE BPL2MOD,-33*40
	CMOVE NOOP,0
	dc.w -1
.stage1Dialogue
	CMOVE BPLCON3,$0020
	CMOVE COLOR00,$744
	CMOVE COLOR17,$854
	CMOVE COLOR18,$a64
	CMOVE COLOR19,$aa6
	CMOVE COLOR20,$974
	CMOVE COLOR21,$a74
	CMOVE COLOR22,$743
	CMOVE COLOR23,$a99
	CMOVE BPLCON3,$a<<12|BRDRBLNKF|%111<<9
	CMOVE NOOP,0
 	dc.w $744
.stage2
	CMOVE BPLCON3,$a<<12|BRDRBLNKF|%111<<9
	CMOVE NOOP,0
	dc.w $668
.stage3
	CMOVE BPLCON3,$a<<12|BRDRBLNKF|%111<<9
;	CMOVE BPLCON3,$0020
	CMOVE NOOP,0
	dc.w $010
.stage4
	CMOVE BPLCON3,$a<<12|BRDRBLNKF|%111<<9
	CMOVE $100,0
	CMOVE NOOP,0
	dc.w $56d


    ;	#MARK: - Animate Escalation

esclQuit        ; fade boss music
    SAVEREGISTERS

    lea (animTriggers,pc),a1
    ;lea objectListTriggersB(a2),a1
    tst.b 2(a1)       ; fade music?
    bne .fadeInMain
    clr.w d1    ; fade out boss music
    move.w #255,d1
    sub.b objectListCnt(a2),d1
    lsr.b #2,d1
    move.w #musicFullVolume,d0
    sub.w d1,d0
    bpl .keep
    clr d0
.keep
	lea CUSTOM,a6
    bsr _mt_mastervol
    RESTOREREGISTERS
    bra animReturn
.fadeInMain
    clr.w d1
    move.b objectListCnt(a2),d1
    lsr #2,d1
    move.w #musicFullVolume,d0
    sub.w d1,d0
    bpl .keep
    clr d0
    bra.b .keep

esclThis            ; initialise excalation object
	SAVEREGISTERS		; yes!

    lea (animTriggers,pc),a1
    tst.b 2(a1)       ; fade music?
    bne .musicFaded
	clr.w d1
	move.w #255,d1
	sub.b objectListCnt(a2),d1
	lsr.b #2,d1
	move.w #musicFullVolume,d0
	sub.w d1,d0
    bpl.b .keep
    clr d0
.keep
	lea CUSTOM,a6
    bsr _mt_mastervol
	RESTOREREGISTERS
	bra objectListNextEntry
.musicFaded
	tst.b 3(a1)       ; distort escal text?
	beq.b .zoomText
						; yes!

	moveq #5,d4
    add.b objectListCnt(a2),d4
   	lea escalateIsActive(pc),a5
	move.b d4,(a5)
	bra .quitEscalate
.zoomText
	lea copEscalateBPLPT,a1
    tst plyPos+plyCollided
    bne .quitEscalate
	
	move.l #escalationBitmap,d7
	;sub #8,d7
	move #$f,d2
	moveq #-4,d0		; filter
	moveq #32,d4		; 32 bytes width*64 px height
	lsl #6,d4

    clr.l d5
    clr.l d6
    move d4,d5
    move d4,d6
.escalScale=15
.escalBase=30
	cmpi.b #.escalBase+.escalScale,objectListCnt(a2) ; big logo
	bhi.b .exitMedLogo
	add.l d4,d7
	clr.l d6
.exitMedLogo
	cmpi.b #.escalBase,objectListCnt(a2) ; med logo
    bhi.b .exitSmallLogo
    add.l d4,d7
    clr.l d5
    clr.l d6
.exitSmallLogo
    and.l d0,d7         : filter lower bits - otherwise wrong display on real AGA
	;move d7,6(a1)

;move d7,6+8(a1)             ; write adress to copper sublist
    move d7,6(a1)
	swap d7
	move d7,2(a1)
    swap d7
    cmpi.b #.escalBase+.escalScale*2,objectListCnt(a2)
    bhi.b .initMedLogo
       add.l d5,d7
.initMedLogo
;add.l d4,d7
    and.l d0,d7
    move d7,6+16(a1)

    swap d7
    move d7,2+16(a1)
    swap d7
    cmpi.b #.escalBase+.escalScale*3,objectListCnt(a2)
    bhi.b .initBigLogo
    add.l d6,d7
.initBigLogo
    and.l d0,d7
    move d7,6+8(a1)
    swap d7
    move d7,2+8(a1)
    swap d7
.quitEscalate
    lea copGameEscExitBPLPT,a1        ; write fxplane-pointers to BPLPT-coplist A and B lower viewport
    move.w #escalateStart-displayWindowStart,d0
    add.w #escalateHeight+1,d0

escalateModifyGameviewBplpt
    lea copBPLPT+4+6,a5
    move.w (a5),d1
    swap d1
    move.w 4(a5),d1
    muls #fxPlaneWidth,d0
    add.l d0,d1
    moveq #40,d0
	sub.l d0,d1
	moveq #12,d0
	moveq #-8,d3
    and.l d3,d1
   	lea gameStatusLevel(pc),a0	; preps - which kind of parallax anim?
	move.w gameStatusLevel(pc),d0
	move.w (.mod,pc,d0.w*2),d0	; get bitmap modulus
	
    move d1,6(a1)
    swap d1
    move d1,2(a1)
    swap d1
    add.l d0,d1

    move d1,6+8(a1)
    swap d1
    move d1,2+8(a1)
    swap d1
   	add.l d0,d1

    move d1,6+16(a1)
    swap d1
    move d1,2+16(a1)
    swap d1
    add.l d0,d1

    move d1,6+24(a1)
    swap d1
    move d1,2+24(a1)
    
   	RESTOREREGISTERS
    bra objectListNextEntry
.mod
	dc.w 	fxPlaneWidth*fxplaneHeight
	dc.w 	fxPlaneWidth*fxplaneHeight
	dc.w 	fxPlaneWidth*1024
	dc.w	fxPlaneWidth*fxplaneHeight*2
	dc.w 	fxPlaneWidth*fxplaneHeight
	
	
    ;	#MARK: - Animate and handle Tutorial
tutorial
	;bra animReturn
	bra objectListNextEntry
    ;	#MARK: - Animate and handle Continue
	
contActn
	lea plyPos(pc),a1
	SAVEREGISTERS
	lea continueBitmap,a0
	move.b plyContinueAvail(a1),d2
	bpl.b .showContMsg
	moveq #(continueBitmapE-continueBitmap)/2,d0
	adda d0,a0	; show restart message
	bra.b .noNum	; dont draw number
.showContMsg
	move.l a0,a3
	andi #$07,d2
	lea font,a4
	moveq #fontHeight-1,d6
.drawNumber	; show no. of continues, draw into source bitmap
	move.b (a4,d2),d0
	adda.w #fontBitmapWidth,a4
	move.b d0,(a3)
	adda.w #8,a3
	dbra d6,.drawNumber
.noNum

	moveq #10,d6
	move.l mainPlanesPointer+4(pc),a3
	move.w #(mainPlaneWidth*mainPlaneDepth*40)+10,d7
	adda.w d7,a3
	moveq #mainPlaneWidth,d7
	move.l objectListTriggersB(a2),a5
	tst.l a5
	beq .saveBckgnd
.drawLine
	movem.l (a0)+,d0-d1
	moveq #mainPlaneDepth-1,d2
.drawBitmaps
	movem.l (a5)+,d4-d5
	or.l d0,d4
	or.l d1,d5
	movem.l d4-d5,(a3)
	adda.w d7,a3
	subq #1,d2
	bmi.b .nextLine
	bne.b .drawBitmaps
	btst #3,frameCount+5
	beq.b .drawBitmaps
	not.l d0
	not.l d1
	movem.l (a5)+,d4-d5
	and.l d0,d4
	and.l d1,d5
	movem.l d4-d5,(a3)
	adda.w d7,a3
.nextLine
	dbra d6,.drawLine
.bckgndSaved
	RESTOREREGISTERS
	
	tst.b plyContinueAvail(a1)	; bit 7 true -> continue flagged
	bmi.b .isFlagged
	move.w plyJoyCode(a1),d7	; hold firebutton during anim->continue
	btst #STICK_BUTTON_ONE,d7
	beq.b .FBreleased
	moveq #1,d1
	add frameCount(pc),d1
	add.b d1,plyFire1Hold(a1)
	move.b plyFire1Hold(a1),d7
	cmpi.b #3*50,plyFire1Hold(a1); more than 3 seconds?
	bls.b .isFlagged
	tst.b plyContinueAvail(a1)
	beq.b .lastContinue
	sub.b #1,plyContinueAvail(a1)
.lastContinue
	bset #7,plyContinueAvail(a1)
.isFlagged
	bra objectListNextEntry
.FBreleased
	clr.b plyFire1Hold(a1)
	bra objectListNextEntry
	
.saveBckgnd
.sizeOfBckgnd=11*8*4
	move.l mainPlanes+12,a5
	add.l diskBufferSize,a5
	move.w #.sizeOfBckgnd,d5
	suba d5,a5	; store bckground at the very end of bitmap memory
	move.l a5,objectListTriggersB(a2)
	moveq #mainPlaneDepth*11,d2
	bra.b .skip
.saveBitmap
	movem.l (a3),d4-d5
	adda d7,a3
	movem.l d4-d5,(a5)
	adda #8,a5
.skip
	dbra d2,.saveBitmap
	RESTOREREGISTERS
	bra objectListNextEntry

        ;}

