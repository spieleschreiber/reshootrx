    ;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter bitmap load adress or use a0 if return to bobblitnext / not animreturn

		;	#MARK: exit level and campaign
exitStage
	SAVEREGISTERS
	lea plyBase(pc),a5
	tst.b plyWeapUpgrade(a5)
	bmi objectListNextEntry	; is dying while reaching exit? Disable xit!

	move.b objectListTriggers+2(a2),d0
	ext.w d0
	move.w (.jmpTable,pc,d0.w*2),d7
.jmp	jmp .jmp(pc,d7.w)
.jmpTable
	dc.w	.fadeVolume-.jmpTable+2	; move player, fade music, init explos	;[trig1536]
	dc.w	.movePlayer-.jmpTable+2	; move player, init explos, init spritetable[trig1537]
	dc.w	.doAchievementBoss-.jmpTable+2;[call this by trig1538]	
	dc.w	.doAchievementShots-.jmpTable+2;[call this by trig1539]
	dc.w	.doAchievementWave-.jmpTable+2;[trig1540]
	dc.w	.initTransition-.jmpTable+2;[trig1541]
	dc.w	.credInit-.jmpTable+2;[trig1542]
	dc.w	.credBlank-.jmpTable+2;[trig1543]
	dc.w	.credGratsMsg-.jmpTable+2;[trig1544]
	dc.w	.credSurvMsg-.jmpTable+2;[trig1545]
	dc.w	.credFinalscoreMsg-.jmpTable+2;[trig1546]
	dc.w	.credScroller-.jmpTable+2;[trig1547]
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
	clr.w plyPosAcclX(a1)	; avoid tilt animation
	clr.w plyAcclXCap(a1)
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

	movem.l a2,-(sp)
	move.b objectListTriggers(a2),d7
	sf.b d3
	bsr wipeBitmap				; clear background
	movem.l (sp)+,a2

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

	add.b #1,objectListTriggers(a2)
	move.b objectListCnt(a2),d5
	btst #0,d5
	bne .noExplo
	bsr fastRandomF
	andi.w #$ff,d5
	add.w #180,d5

	st.b d6
	sub.b objectListTriggers(a2),d6
	muls #320,d6
	lsr.l #8,d6
	add viewPosition+viewPositionPointer(pc),d6
	sub #100,d6
	move.l cExplLrgAnimPointer(pc),a1
	move.w animTablePointer+2(a1),d4
    st.b d3
	bsr objectInit		; spawn explosion
	tst.b d6
	bmi .noExplo 
	;move d0,objectListAccX(a4)
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

    lea viewPosition(pc),a0
    clr.l viewPositionAdd(a0); stop scrolling

;	bra .noExplo

	bsr .modCoplist	; ATTN: If copperGameMaxSize too low, this crashes. If jsr disabled, textwrite to sprite causes corrupted display

		; disable bullet color registers in copperlist
	moveq #3,d7
.paintBulletsX
	move.l colorBullet(pc,d7*4),a0
	tst.l a0
	beq .colorBulletsX
	move.w #NOOP,d1
.offset	SET	12
	move.w d1,.offset(a0)
	move.w d1,.offset+4(a0)
	move.w d1,.offset+8(a0)
	move.w d1,.offset+12(a0)

	move.w d1,.offset+16(a0)
	move.w d1,16+.offset+4(a0)
	move.w d1,16+.offset+8(a0)
	move.w d1,16+.offset+12(a0)

	move.w d1,32+.offset(a0)
	move.w d1,32+.offset+4(a0)
	move.w d1,32+.offset+8(a0)
	move.w d1,32+.offset+12(a0)
.colorBulletsX
	dbra d7,.paintBulletsX

	SAVEREGISTERS
	lea plyBase(pc),a0	
	lea .achievements(pc),a2

	clr.l d0
	clr.l d1
	move.w plyShotsFired(a0),d0	; number of shots
		;move.w #1245,d0	; outcomment to test number of shots
	beq .avoidDivZeroException
	move.w plyShotsHitObject(a0),d1	; number of hits
	muls #100,d1
	divu d0,d1
	ext.l d1	; clean up
.avoidDivZeroException
	move.w d1,d0
	muls #100,d1	; adapt for bonus display
	move.w d1,plyShotsFired(a0)
	bsr convertHexToBCD
    lea .achievementsShot-.achievements+7(a2),a3
	bsr .doConversion
    moveq #4,d0
    sub d7,d0
    move.b d0,.achievementsShot-.achievements(a2)	; adjust x-alignment to left border
    

	move.w plyWaveBonus(a0),d1
		;move #51,d1	; outcomment this to test wave bonus
    beq .noWave
	cmpi #100,d1
	blo .waveWithinBounds		; more than 99 waves? Cut!
	move #99,d1
.waveWithinBounds
	move.w d1,d0
	muls #100,d1
	move.w d1,plyWaveBonus(a0)
	bsr convertHexToBCD
    lea .achievementsWave-.achievements+7(a2),a3
    bsr .doConversion
.retWave
    RESTOREREGISTERS
	bsr .updateBossAchvmnt
	bsr .updateShotsAchvmnt
	bsr .updateWaveAchvmnt
	bset #0,objectListTriggersB(a2)	; make sure this subcode is called only once
	bra .reachedParkPosition
.noWave
    move.l #"   0",.achievementsWave-.achievements+3(a2)
    moveq #2,d7
	bra .retWave

.modCoplist ;[trig1537]
	SAVEREGISTERS
	lea plyBase(pc),a6
	move.w gameStatusLevel(pc),d0
	move.w (.addBoss,pc,d0*2),d0
	move.w d0,plyBossBonus(a6)

		;	#MARK: testing: temp values for shots, wave etc.

	; temporarily write values to counters - for testing only
	IFNE 0
	move.w #5000,plyBase+plyBossBonus
	move.w #95,plyBase+plyShotsFired
	move.w #65,plyBase+plyShotsHitObject
	move.w #123,plyBase+plyWaveBonus
	ENDIF
	; endtemp

	bsr .clearSpriteArea

	clr.w d0
    move.b plyWeapUpgrade(a6),d0
    move d0,d4
	lsl #5,d0
	lsl #4,d4
	add d4,d0	; 192 color slots all in all, 4 colors variants = 48 colors slots for fade
	move.l colorFadeTable(pc),a0
	lea (a0,d0),a0
	move.w (a0),d1
    move.w 128(a0),d3
    move.w 2+(128*2)(a0),d2	; restore player vessel colors

	lea copGameAchievementsQuit,a1
	;moveq #-1,d1
	;move.w d1,d2
	;move.w d1,d3

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
    
	bsr .clearSpriteArea
	bsr createTableTextSpritesCoord

	lea copGameAchievements,a0
	move.l bobSource(pc),a1
	lea .spriteCharMemsize(a1),a1

	bsr installSpritePointers
	RESTOREREGISTERS
	rts
.clearSpriteArea
	move.l bobSource(pc),a6	;	creat coord conv table here. Do not need early bob entries any more, only explosions
	lea .spriteCharMemsize(a6),a1			;	sprite bitmap storage space
	move.l a1,d0
	move.l a1,a3
	move #(.spriteCharMemsize/4)-1,d7
.clrLoop
	clr.l (a3)+	; clear text area
	dbra d7,.clrLoop
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
	moveq #8,d3
	add.l bobSource(pc),d3	;store sprite data
	andi.b #%11111000,d3
	move.l d3,a6
	lea .spriteCharMemsize(a6),a1
	move #$3f,d3
	clr.w d4
	bsr drawTextToSprites
	RESTOREREGISTERS
	rts
.credInit				;[trig1542]

	lea plyBase(pc),a1
	st.b plyExitReached(a1)	; disable player control
	move.w #210,(a5)

	lea copGameAchievementsQuit,a1
;    move.w d1,6(a1)	; main weapon, darkest color
 ;   move.w d2,6+4(a1)	; "", brightest color
  ;  move.w d3,6+8(a1)	; "", middle color


	IFNE 0
	move.l #$18000,d0
	add.l d5,d0	; player ship base adress
	clr.l d1
	move #$f40/4,d1		; player ship base adress + 1/4
	move.l d1,d2
	add.w d2,d2				; player ship base adress + 2/4
	move.l d1,d3
	add.w d2,d3				; player ship base adress + 3/4
	add.l d0,d1
	add.l d0,d2
	add.l d0,d3
	move.w d0,6(a5)
	swap d0
	move.w d0,2(a5)
	move.w d1,6+8(a5)
	swap d1
	move.w d1,2+8(a5)
	move.w d2,6+16(a5)
	swap d2
	move.w d2,2+16(a5)
	move.w d3,6+24(a5)
	swap d3
	move.w d3,2+24(a5)
	ENDIF
	move.l achievementsEntry(pc),a1
	move.w #COPJMP1,d0
    move.w d0,12(a1); overwrite copJmp trigger
	move.l achievementsQuit(pc),a1
	move.w d0,12(a1); ""
	bra .quit
.initExit
	move.b #1,objectListCnt(a2)
	move.b #1,objectListLoopCnt(a2)

	bra .quit
.credScroller							;[trig1547]

	move.w plyBase+plyJoyCode(pc),d7
	btst #STICK_BUTTON_ONE,d7; check firebutton 1
	bne .initExit
	tst.w keyArray+firePrime(pc)
	bne .initExit

	lea copGameAchievements,a0
	moveq #8,d3
	add.l bobSource(pc),d3	;store sprite data
	andi.b #%11111000,d3
	move.l d3,a1

	add.w #1,objectListTriggersB(a2)
	clr.l d0
	move.w objectListTriggersB(a2),d0

	move.w #22,d4
	clr.l d5
	move.w #370*16,d5
	cmpi.w #$cc3,d0
	bhs .slowEntry
	move.w #9*16,d5
	add.w #14,d4
.slowEntry
	muls #100,d0
	divu d4,d0

	andi.l #$ffff,d0
	sub.l d5,d0
	bpl .isPositive
	clr.l d0
.isPositive

	andi.l #$fff0,d0
	cmpi.l #2561*16,d0
	bls .reachedEnd
	move.l #2561*16,d0
.reachedEnd

	lea $20000-8(a1,d0.l),a1
.credNoOfLines	SET 2770
	lea .credNoOfLines*spriteLineOffset(a1),a3
	lea .credNoOfLines*spriteLineOffset*2(a1),a4
	bsr installSpriteJumpin
	bra .animShip
.animShip
	move.l copSPR6PTH(pc),a5
	tst.l a5
	beq .q
	move.l bobSource(pc),d5
	move.l #$18000,d1
	add.l d1,d5
	move.w d5,6(a5)
	swap d5
	move.w d5,2(a5)

	move.l bobSource(pc),d5
	andi.b #%11111000,d5
	move.l copSPR6PTH(pc),a5
	tst.l a5
	beq .quit
	add.l d5,d1	; player ship base adress
	clr.l d0
	move.w #488*4,d0; one sprite offset
	move.l d0,d3
	lsr.w #1,d3
	clr.l d2
	move.w frameCount+2(pc),d2
	andi.w #3,d2
	muls d2,d0
	add.l d1,d0
	moveq #1,d7
.wrtSpritePointer
	move.w d0,6(a5)
	swap d0
	move.w d0,2(a5)
	swap d0
	add.l d3,d0
	lea 8(a5),a5
	dbra d7,.wrtSpritePointer

.q	RESTOREREGISTERS
	bra objectListNextEntry


.credBlank							;[trig1543]

		lea .msgBlank(pc),a2
	bra .drawMsg
.credGratsMsg
	lea .msgCongrats(pc),a2
.drawMsg								;[trig1544]
	bsr .clearSpriteArea
	lea fastRandomSeed(pc),a4
	lea font(pc),a5
	moveq #8,d3
	add.l bobSource(pc),d3	;store sprite data. ATTN:
	andi.b #%11111000,d3
	move.l d3,a6
	lea .spriteCharMemsize(a6),a1
	move #$3f,d3
	clr.w d4
	bsr drawTextToSprites
	bra .animShip
.credSurvMsg							;[trig1545]
	lea .msgSurvive(pc),a2
	bra .drawMsg
.credFinalscoreMsg							;[trig1546]
	lea (score,pc),a6
	move.l (a6)+,d1
	moveq #7,d7
	lea .msgFinalscoreNums+11(pc),a3
	bsr .convertBCDtoDisplay	; write score to text memory
	move.b #7,d6
	asr.b #1,d7
	sub.b d7,d6
	lea .msgFinalscore(pc),a2
	move.b d6,.msgFinalscoreNums-.msgFinalscore(a2)	; center text
	bra .drawMsg

.msgBlank
	dc.b 1,1," ",-1
.msgCongrats
	dc.b 3,7,"CONGRATULATIONS HERO",-1
.msgSurvive
	dc.b 7,7,"$YOU SURVIVED$",0
	dc.b 5,8,"RESHOOT PROXIMA 3",-1
.msgFinalscore
	dc.b 5,5,"$YOUR FINAL SCORE $",0
.msgFinalscoreNums
	dc.b 8,7,"        ",-1
	even


.updateBossAchvmnt
	SAVEREGISTERS
	lea .achievements(pc),a2
	lea plyBase(pc),a0	
	lea tempVar(pc),a5
	pea .drawStuff
 	bra .drawAchvmntBoss

.updateWaveAchvmnt
	SAVEREGISTERS
	lea .achievements(pc),a2
	lea plyBase(pc),a0	
	lea tempVar(pc),a5
	pea .drawStuff
 	bra .drawAchvmntWave

.drawAchvmntShots
	move.w plyShotsFired(a0),d0
	;add d0,d0
	bsr convertHexToBCD	; outputs BCD-number in d1
    lea .achievementsShots-.achievements+6(a2),a3
.doConversion
   	move #3,d7
.convertBCDtoDisplay		; convert bcd num to to displayable ascii chars
    move.l d1,d2
    lsr.l #4,d1
    andi.b #$f,d2
    add.b #$30,d2
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
    lea .achievementsBoss-.achievements+6(a2),a3
    bra .doConversion

.drawAchvmntWave
	clr.l d0
	move.w plyWaveBonus(a0),d0
	bsr convertHexToBCD
	lea .achievementsWaves-.achievements+6(a2),a3
	bra .doConversion

		;	#MARK: achievement shots

.doAchievementShots	; called by trig1539
	lea plyBase+plyShotsFired(pc),a1
	moveq #1,d6
	bra .doMulti21

		;	#MARK: achievement wave

.doAchievementWave	; called by trig1540
	lea plyBase+plyWaveBonus(pc),a1
	moveq #1,d6
	bra .doMulti21

		;	#MARK: achievement boss

.doAchievementBoss	; called by trig1538

	clr.l d0
	lea plyBase+plyBossBonus(pc),a1
	moveq #10,d6	; multiply boss score by this value
.doMulti21
	move.w (a1),d0
	beq .dontPlayFX
	clr.l d1
.div	SET 14
	clr.l d1
	move d0,d1
	divs #.div,d1
	seq d7
	andi #1,d7
	add d7,d1	; if result = 0 -> 1
;	move.w frameCount+6(pc),d3
;	muls d3,d1

	sub.w d1,(a1)
	bne .isZeroed
	move.b #"0",.achievementsBoss+6	; down to zero? Skip all convert and cleanup code
.decay	SET 30
	move.b #.decay,objectListCnt(a2)	; set wait time until switch to next anim step
.isZeroed
	;muls d6,d1	; variable multiply, depending on step in anim
	lea scoreAdder(pc),a1
	move.w frameCount+6(pc),d3
	muls #10,d1
	add.w d1,(a1)	; add
	bsr drawScore	; need to update score manually. Else we got a strange bug, that causes wrong score bonus due to framerate issues

	clr.w d0
	move.b objectListCnt(a2),d0
	and.b #$7,d0
	bne .dontPlayFX
	move.b     fastRandomSeed(pc),d0
	move.b objectListCnt(a2),d0
	lsr #3,d0
    add.w #380,d0
	lea (fxAchievement*fxSizeOf)+fxTable+6-12(pc),a0
	move.w d0,(a0)	; store modified hitpoints -> fx pitch
	PLAYFX fxAchievement
.dontPlayFX
 	bsr .updateBossAchvmnt
 	bsr .updateWaveAchvmnt
 	bsr .updateShotsAchvmnt
.quit
	RESTOREREGISTERS
	bra objectListNextEntry


.addBoss
	dc.w 3000,2500,4000,5000,7500	; stages0 and 1 are swapped, thats why ...
.achievements
    dc.b 6,0,"$BATTLE REPORT$",0
    dc.b 5,5,"$BOSS KILL BONUS$",0
.achievementsBoss    dc.b 15,6,"    0",0
.achievementsShot
    dc.b 1,9,"$xxxx& HITACCURACY",0
    dc.b 9,10,"$X1000",0
.achievementsShots
	dc.b 15,10,"    0",0
.achievementsWave
	dc.b 3,13,"$xxxx WAVES BONUS",0
	dc.b 9,14,"$X1000",0
.achievementsWaves
	dc.b 15,14,"    0",-1

	even
.initTransition	;[trig1541]
	lea forceExit,a0
	st.b (a0)	; transition & exit
	RESTOREREGISTERS
	bra objectListNextEntry
