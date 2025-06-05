


; RESHOOT.repeat  27. 7. 2016
; Copyright (c) 2016 Richard Löwenstein



;!!!: Customcode: code called from objectMoveManager. Init by animlist -> code-command. a6 contains pointer to objectlist, a5 contains return-address
;
    ;code may not use a5,a6,d7
	; a6 = pointer to caller object



	IFNE 0

; #MARK: - Scroll Control Code

scrolSlo
	moveq #$8,d5
	bra.b scrolCalc
scrolMed
	moveq #$10,d5
	bra.b scrolCalc
scrolFst
	moveq #$20,d5
scrolCalc
	ror.l #4,d5
	swap d5
	bra.b scrolWrite
scrolRes
    lea viewPosition(pc),a3
    move.l viewPositionScrollspeed(a3),d5  ;viewPositionScrollspeed - init scroll speed
	move.l d5,viewPositionAdd(a3)
    jmp (a5)
scrolWrite
    lea viewPosition(pc),a3
	move.l d5,viewPositionAdd(a3)
    jmp (a5)

; #MARK: - Init Hunter Missile
	; caller trig1= at launch: 0 = basic, 1 = motha ; 128=lv4 boss
	;trig2= 1 huntmode disabled
mislInit                ; homing in missile
	;getAnimAdress homeMislAnimPointer,home,Misl
	tst.b objectListTriggers(a2)
	beq.b .mothaLaunch
	move.l homMislBAnimPointer(pc),a4
	bra.b misllaunch
.mothaLaunch
	move.l homeMislAnimPointer(pc),a4
misllaunch
	move.w animTablePointer+2(a4),d4
	bsr getCoords
    st.b d3
	bsr objectInit
    tst.l d6
    bmi.b mislQuit
	move.w #-100,objectListAccX(a4)
    move #2<<2,objectListHit(a4); hitpoints
    move.b #0,objectListAttr(a4); attribs
	PLAYFX 6
mislQuit
    jmp (a5)

mislBoss
	move.l hmMslBosAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
	move.l objectListMyParent(a6),a0
	move.w objectListX(a0),d5
	move.w objectListY(a0),d6
    st.b d3
	bsr objectInit
    tst.l d6
    bmi.b mislQuit
	subq.w #4,objectListX(a4)
	add.w #20,objectListY(a4)
    move #2<<2,objectListHit(a4); hitpoints
    sf.b objectListAttr(a4)
	PLAYFX 6
	jmp (a5)
	
mislExpl
    ;getAnimAdress mislExplAnimPointer,misl,Expl
	move.l mislExplAnimPointer(pc),a4
    move.w animTablePointer+2(a4),d4
    move d4,objectListAnimPtr(a6)   ; object hit, change to explosion animation
    bclr #6,objectListAttr(a6)        ; clr opaque bit for proper expl-display
   	move.b #15,objectListCnt(a6)
    add #$10,objectListAccX(a6)
    jmp (a5)
	
	
; #MARK: Init Moth Weapons
mothChld    ; init child
	tst.b objectListTriggers+1(a6)
	bne.b .reversed
	move.l mothTurAAnimPointer(pc),a4
	moveq #50,d5
	moveq #-14,d6
	bsr .initMothChild

	move.l mothTurCAnimPointer(pc),a4
	moveq #40,d5
	moveq #-23,d6
	bsr .initMothChild
	jmp (a5)
.reversed
	move.l mothTuA2AnimPointer(pc),a4
	moveq #50,d5
	moveq #-14,d6
	bsr .initMothChild

	move.l mothTuC2AnimPointer(pc),a4
	moveq #40,d5
	moveq #-23,d6
	bsr .initMothChild
	jmp (a5)
.initMothChild
    bset.b #1,objectListAttr(a6)    ; mark parent
    move.w animTablePointer+2(a4),d4
    st.b d3

	;move.w objectListX(a6),d5
	;move.w objectListX(a6),d6
	bsr objectInit
    tst.l d6
    bmi.b .quit
    clr.l objectListTriggers(a4)
    st.b objectListHit(a4); hitpoints
    move.b #attrIsImpactF,objectListAttr(a4); attribs
    move.l a6,objectListMyParent(a4)
.quit
    rts

; #MARK: Init L3 boss tail


l3brAdTa    ; init child
;    getAnimAdress mothChdCAnimPointer,moth,ChdC
	move.l l3brTaiAAnimPointer(pc),a4	; first element-> individual positioning
    move.l a6,a2
    moveq #4,d0
    bset.b #1,objectListAttr(a6)    ; mark parent
.nextChild
    move.w animTablePointer+2(a4),d4
    moveq #10,d5
    moveq #0,d6
    st.b d3

    bsr objectInit
    tst.l d6
    bmi.b .okay
    move.b #attrIsImpactF,objectListAttr(a4); attribs
    st.b objectListHit(a4); hitpoints
    move.b d0,objectListCnt(a4)
    move.l a4,objectListMyChild(a2)
    move.l a2,objectListMyParent(a4)
    move d0,d1
    asl #3,d1
	add.b d1,objectListCnt(a4)
    move.l a4,a2
	move.l l3brTailAnimPointer(pc),a4
	dbra d0,.nextChild

    move.l a0,a4	; add turret to tail
	move.l mothTuBsAnimPointer(pc),a4
    move.w animTablePointer+2(a4),d4
    moveq #-10,d5
    moveq #1,d6
    st.b d3

	bsr objectInit
    tst.l d6
    bmi.b .okay
    move.b #attrIsImpactF,objectListAttr(a4); attribs
    st.b objectListHit(a4); hitpoints
    move.l a4,objectListMyChild(a2)
    move.l a2,objectListMyParent(a4)
    ;dbra d0,.nextChild
.okay
    jmp (a5)

; #MARK: - Init asteroid tentacle

astrTenc
	bset.b #1,objectListAttr(a6)    ; mark parent

    ;move.w #3,objectListHit(a0); hitpoints
    ;move.b #attrIsImpactF,objectListAttr(a0); attribs
	;move.l #0,(a4)
    ;move.l #210,objectListX(a4)
    ;move.l #20,objectListY(a4)
    ;move.l a6,objectListMyParent(a4)
    ;move.l a4,objectListMyChild(a6)
.quit
;	move.l (sp)+,a5
	jmp (a5)


	
;	#MARK: - L2 Wall Init


l2wallStop	=tube 	tempVar
wallInit
	lea l2wallStop(pc),a0

	move.l wallBrkeAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
    st.b d3
	move #330,d5
	move #28,d6
	bsr objectInit
	tst.l d6
	bmi.b .quit
	move.l a4,16(a0)
	st.b objectListHit(a4)
    move.b #attrIsImpactF!attrIsOpaqF,objectListAttr(a4);

	move.l wallBrkeAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
    st.b d3
	move #330,d5
	move #224,d6
	bsr objectInit
	tst.w d6
	bmi.b .quit
	move.l a4,20(a0)
	st.b objectListHit(a4)
    move.b #attrIsImpactF!attrIsOpaqF,objectListAttr(a4);
.quit
	;st.b objectListTriggers(a6)
	jmp (a5)


;	#MARK: - L3 Ocean Boss
keepTrack	= 	tempVar

l3brInit
	
	lea (animTriggers,pc),a0
	clr.l (a0)

	moveq #40<<1,d1	; hitpoints muzzle
	move.b d1,3(a0)
	move #2<<2,d0
	lea keepTrack+16(pc),a0
	move.l l3brTethAnimPointer(pc),a4
	bsr lxObjInit	; add teeth
	move.l a4,a3
	move #$20,objectListTriggersB(a4)
	move.b #attrIsImpactF,objectListAttr(a4);
	move.w d1,objectListHit(a4)
	
	lea keepTrack(pc),a0
	clr.w d0	; modify animFrame
	move.l l3brEyUpAnimPointer(pc),a4
	bsr lxObjInit
	move.b #attrIsImpactF!attrIsNotHitableF!attrIsNoRefreshF,objectListAttr(a4);

	clr.w d0
	lea keepTrack+8(pc),a0
	move.l l3brEyDnAnimPointer(pc),a4
	bsr lxObjInit
	move.b #attrIsImpactF!attrIsNotHitableF!attrIsNoRefreshF,objectListAttr(a4);

	move #2<<2,d0
	lea keepTrack+32(pc),a0
	move.l l3brHeadAnimPointer(pc),a4
	bsr.b lxObjInit
	move.l a3,objectListMyParent(a4)
	move.l a4,objectListMyChild(a3)
	st.b objectListHit(a4)
	move.b #attrIsImpactF,objectListAttr(a4);

	move #2<<2,d0
	lea keepTrack+24(pc),a0
	move.l l3brHelmAnimPointer(pc),a4
	bsr.b lxObjInit
	move.l a3,objectListMyParent(a4)
	move.l a4,objectListMyChild(a3)
	st.b objectListHit(a4)
	move.b #attrIsImpactF,objectListAttr(a4);

	jmp (a5)

mothc

;	#MARK: - L2 / L4 Sky Boss

l2bsInit	; boss global controller for level 2

	lea (animTriggers,pc),a0
	clr.l (a0)

	move #607,d5
	move #95,d6
	lea keepTrack(pc),a0
	move #0,d0	; modify animFrame
	bsr.b l2initRoid

	move #590,d5
	move #125,d6
	move #2<<2,d0
	lea keepTrack+8(pc),a0
	bsr.b l2initRoid

	move #605,d5
	move #160,d6
	move #3<<2,d0
	lea keepTrack+16(pc),a0
	bsr.b l2initRoid
	jmp (a5)

l2initRoid
	move.l eyeRoidBAnimPointer(pc),a4
lxObjInit

    st.b d3
	move.w animTablePointer+2(a4),d4
	add.w viewPosition+viewPositionPointer(pc),d5
	bsr objectInit
	clr.l objectListTriggers(a4)   ; clear all triggers
	move.b d0,objectListTriggersB(a4)
	move.w #20<<2,objectListHit(a4)
	move.b #attrIsImpactF,objectListAttr(a4);
	move.l a4,(a0)
	GETOBJECTPOINTER a4,a1
	move.l (a1),d0
	move.l d0,4(a0)
	rts

	IFNE 0
l2WsInit	; init wasp object in level 2 and level 4. l2 and l4 call separate animlists

	move.l waspMainAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
    st.b d3

	move.w #340,d5
	add.w viewPosition+viewPositionPointer(pc),d5
	move.w #140,d6
	bsr objectInit
	clr.l objectListTriggers(a4)   ; clear all triggers
	move.b #attrIsNotHitableF!attrIsImpactF,objectListAttr(a4); will be changed within object
	
	cmpi.b #statusFinished,gameStatus(pc)
	seq.b d0
	ext.w d0
	clr.w d1
	move.b .hitpoints(pc,d0.w),d1
	move.w d1,objectListHit(a4)

	lea (animTriggers,pc),a0
	add.b #1,3(a0)	; init next step in l2 boss controller

	lea keepTrack+24(pc),a0
	move.l a4,(a0)
	
	PLAYFX 21	; boss war cry
	jmp (a5)
	dc.b	81	; hitpoints l4 boss ; 81
.hitPoints
	dc.b 	80		; hitpoints l2 boss
l0bsKeepTrack	= 	tempVar

;	#MARK: - L0 Space Boss
l0bsInit
	move.l l0bsMainAnimPointer(pc),a4
	bsr initObject
	clr.l objectListTriggersB(a4)   ; clear all triggers
	move.w objectListHit(a6),d0
    move.w d0,objectListHit(a4)

    move.b #attrIsImpactF!attrIsOpaqF,objectListAttr(a4);
	lea l0bsKeepTrack(pc),a1
	move.l a4,(a1)
	jmp (a5)

;	#MARK: - L1 Sun Boss

l1bsKeepTrack	= 	tempVar
l1bsInit

	lea (animTriggers,pc),a0
	clr.l (a0)
	lea l1bsKeepTrack(pc),a0

	move.l l1bsMainAnimPointer(pc),a4
;	move #60,d5
;	move #128,d6
	bsr initObject
	clr.l objectListTriggers(a4)   ; clear all triggers
	move.l a4,16(a0)
    move.b #attrIsImpactF!attrIsOpaqF,objectListAttr(a4);

	move.l l1bsEyUpAnimPointer(pc),a4
	bsr initObject
	move.l a4,20(a0)
	
	move.l l1bsEyDnAnimPointer(pc),a4
	bsr initObject
	move.l a4,24(a0)

	move.l l1bsPiUpAnimPointer(pc),a4
	bsr initObject
	lea l1bsKeepTrack(pc),a0
	move.l a4,(a0)
	GETOBJECTPOINTER a4,a1
	move.l (a1),d0
	move.l d0,4(a0)
    move.b #attrIsImpactF!attrIsOpaqF,objectListAttr(a4);
    move.w objectListHit(a6),d6
    move.w d6,objectListHit(a4)

	move.l l1bsPiDnAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
	bsr initObject
	lea l1bsKeepTrack+8(pc),a0
	move.l a4,(a0)
	GETOBJECTPOINTER a4,a1
	move.l (a1),d0
	move.l d0,4(a0)
    move.b #attrIsImpactF!attrIsOpaqF,objectListAttr(a4);
    move.w objectListHit(a6),d6
    move.w d6,objectListHit(a4)
	add.b #20,objectListCnt(a1)	; fix to keep cnt flow
	jmp (a5)

l1eyesUp		; init eye projectile
	move.l donutBsAAnimPointer(pc),a4
	bsr initObject
	tst.l d6
	bmi l1quit
	moveq #112,d6
	move #45,objectListY(a4)
	bra.b l1eyes
l1eyesDn		; init eye projectile
	move.l donutBsBAnimPointer(pc),a4
	bsr initObject
	tst.l d6
	bmi l1quit
	moveq #-112,d6
	move #216,objectListY(a4)
l1eyes
	clr.w d0
	move.b objectListTriggers+1(a6),d0
	asl d0,d6
	asr #7,d6
	move d6,objectListAccY(a4)
	move.b #attrIsImpactF,objectListAttr(a4);
    move.w #1<<2,objectListHit(a4);
l1quit
	jmp (a5)





;	#MARK: - Init Wasp Skull
waspIntA    ; init child
	clr.w d1
	move.l waspChdAAnimPointer(pc),a4
	cmpi.b #statusFinished,gameStatus(pc)	; level 2?
	bne waspSkip; no!
	
	clr.w d0	init boss subtype in level 4
	lea (animTriggers,pc),a0
	move.b (a0),d0
	andi #3,d0
	lsl #4,d0
	lea waspChdAAnimPointer(pc),a4
	move.l (a4,d0),a4
	;lea (a4,d0),a4
	bra waspSkip
waspPointers
	blk.l 3,0

; #MARK: Init lv2 Wasp Face / lv4 chin
waspIntB    ; init child
	moveq #4,d1
	move.l waspChdBAnimPointer(pc),a4
    bra.w waspSkip
; #MARK: Init Wasp Tail
waspIntC    ; init child
    ;getAnimAdress waspIntCAnimPointer,wasp,Stg1
	move.l waspStg1AnimPointer(pc),a4
    move.l a5,-(sp)
    lea (.waspTemp,pc),a5
    moveq #8,d1
    bra waspSkip    ; jump forth and back to apply different attribs to wasps tail
.waspTemp
	cmpi.b #statusFinished,gameStatus(pc)
	sf.b d0
	andi #attrIsOpaqF,d0
    move.b d0,objectListAttr(a4); sting transparent only in level 4
    move.l (sp)+,a5
    jmp (a5)
waspSkip
	;move.w animTablePointer+2(a1),d5
    bset.b #1,objectListAttr(a6)    ; mark parent
    move.w animTablePointer+2(a4),d4
    move objectListX(a6),d5
    move objectListY(a6),d6
    
    GETOBJECTDEFBASE a4
    moveq #0,d5
    move.b objectDefWidth(a4),d5
    lsl #1,d5
    add objectListX(a6),d5
    moveq #0,d3
    moveq #-10,d6
    add objectListY(a6),d6
    st.b d3

    bsr objectInit
    tst.l d6
    bmi.b .quit
	lea (waspPointers,pc),a1
	move.l a4,(a1,d1)

    st.b objectListHit(a4); hitpoints
    clr.b objectListAttr(a4); attribs
    move.l a6,objectListMyParent(a4)
	clr.l objectListAcc(a4)
.quit
    jmp (a5)
isHitble
    move.l objectListMyParent(a6),a1
    tst.l a1
    bne.b .hasParent
    move.l a6,a1
.hasParent
    bclr.b #5,objectListAttr(a1)
    jmp (a5)
notHitbl
    move.l objectListMyParent(a6),a1
    tst.l a1
    bne.b .hasParent
    move.l a6,a1
.hasParent
    bset.b #5,objectListAttr(a1)
	jmp (a5)

; #MARK: Init Wasp Shot
waspSht2
	PLAYFX 6

    movem.l a5-a6,-(sp)
    move.l objectListMyParent(a6),a6
    lea (waspShtRet,pc),a5
	move.l bigTShotAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
	move objectListY(a6),d6
	sub #32,d6
	lea cBulSpryB(pc),a0
	jmp (bulCurt8B,pc)
waspSht1
	PLAYFX 6
    movem.l a5-a6,-(sp)
    move.l objectListMyParent(a6),a6
    lea (waspShtRet,pc),a5
	move.l bigTShotAnimPointer(pc),a4
    jmp (bulCurt8,pc)
waspShtRet
    movem.l (sp)+,a5-a6
	jmp (a5)
	;bra cBluSpr
	
waspVuln
    move.l objectListMyParent(a6),a1
	cmpi.b #statusFinished,gameStatus(pc)
	bne.b .isLevel2
	lea (animTriggers,pc),a3	; level 4 boss fleeing? Dont change vuln bit
	tst.b 2(a3)
	bmi.b .quit
.isLevel2
    bclr.b #5,objectListAttr(a1)
.quit
    jmp (a5)
waspUnvu
    move.l objectListMyParent(a6),a1
    bset.b #5,objectListAttr(a1)
    jmp (a5)
    
waspTail
	clr.l d5                                  ; hit and killed
	move (a6),d5;objectListAnimPtr
	lea ([animDefs,pc],d5.w),a0
	clr d5
	;move.b animDefType(a0),d5
	
	move.b #2,animDefType(a0)

	jmp (a5)
	ENDIF
	
	
cExplMed
    ;getAnimAdress cExplMedAnimPointer,cExp,lMed
	move.l cExplMedAnimPointer(pc),a4
    move.w animTablePointer+2(a4),d4
    move d4,(a6)   ; objectListAnimPtr object hit, change to explosion animation
    bclr #6,objectListAttr(a6)        ; clr opaque bit for proper expl-display
   	move.b #15,objectListCnt(a6)
    ;    add #$10,objectListAccX(a6)
    jmp (a5)

	IFNE 0
pentShot
	move.w animTablePointer+2(a4),d4
	move objectListY(a6),d6
	addq #4,d6
	GETOBJECTDEFBASE a0
	clr.l d5
	move.b objectDefWidth(a0),d5
	lsl #1,d5
	add objectListX(a6),d5
    sf.b d3
	bsr objectInit
	tst.l d6
	bmi.b .quit
	move.b #attrIsSpriteF!attrIsNotHitableF,objectListAttr(a4); attribs
.quit
	jmp (a5)

    ; #MARK: - Init basic homeshot


l4bsShtA
	move.l a5,-(sp)
	lea .l4Ret(pc),a5
	bra homeShot
.l4Ret
	tst.l d6
	bmi.b .quit
	move.w frameCount+4(pc),d0
	rol.b #4,d0
	moveq #$7f,d1
	and d1,d0
	lea sineTable(pc),a0
	sub.b (a0,d0),d1
	ext.w d1
	lsl #2,d1
	sub #280,d1
	add.w d1,objectListAccY(a4)
	asr #2,d1
	add.w d1,objectListAccX(a4)
	sub #12,objectListX(a4)
	add #19,objectListY(a4)
.quit
	move.l (sp)+,a5
	jmp (a5)


homeShtV	;

	ENDIF

	;code may not use a5,a6,d7
	; a6 = pointer to caller object
	
	
shotPtrn
	move.l bascShotAnimPointer(pc),a4

	move.w animTablePointer+2(a4),d4
	bsr getCoords
	GETOBJECTPOINTER a6,a0
;	bra retTilt
	
	
	add.w plyBase+plyPosXDyn(pc),d5
	sub.w #$21,d5
	clr.l d2
	move.w d5,d2
	add.w #12,d6
	clr.w d3
	move.b objectDefHeight(a0),d3
	lsr #1,d3
	add.w d3,d6	; modify objects position data
	sf.b d3
	bsr  objectInit
	PLAYFX fxEnemBullet
	move.b objectListTriggers+3(a6),d0	; fetch pattern code (set by adding "code trig179x" to anim table. 1792=0, 1793=1, 1794=2... 1919=127)
	clr.w d0
	move.b objectListLoopCnt(a6),d0
	;btst #3,d0
	;sne d4
	;andi #$f,d4
	;eor.w d4,d0
	lsl #4,d0
	add.w #64*10,d0
	move.w (bulletVectorsFast,pc,d0),d1	; fetch x- & y-delta vector
	clr.w d4
	move.b d1,d4
	lsl #1,d4
	move.l viewPosition+viewPositionAdd(pc),d6
	lsl.l #8,d6
	swap d6
	add d4,d6
	
	;move d2,d1
	sub.w #$80,d2
	;move.w d2,d3
	;lsr #4,d3
	;add.w d3,d2
	;lsl #7,d2
	muls #110,d2
	;lsl #7,d3
	;asl #6,d2
	;MSG01 m2,d1
	;MSG02 m2,d1
	sub.w d2,d1
	;sub.w d3,d1
	;sub.w #$0000,d1
;	move.w d1,d2
	;asr.w #4,d2
	;sub.w d2,d1
	asr #6,d1	; shift to x-vector
	;asl #2,d1
	;sub.w d1,d2
	;move.w #$ffff,d2
	movem.w d1/d6,objectListAcc(a4)	; write x- and y-accl


	jmp (a5)


	
	
	IFNE 0

;#################### OLDSTUFF

	add #210,d1
	lsr #3,d1	; make sure dy is >0 and <$1f in extreme situations
	move #$1f,d1
		lsl #6,d1
		lsl #1,d0
		add d1,d0
	ALERT02 m2,d2
	ALERT01 m2,d0
		ext.w d2
		add.w d2,objectListAccX(a4)
		clr.w objectListAccY(a4)
	    jmp (a5)
	    ;;;;;;;;
	    
	    
	move.l d0,d2
	swap d1
	divu d0,d1

	swap d1
	tst.w d1
	bne .1
	move #1,d1
.1
	ext.l d1
	;ALERT02 m2,d1

	divu d1,d0
	ext.l d0
		;ALERT01 m2,d0
homeShotAddLead
	;clr.w d0
	;clr.w d1
	neg d0
	asl.w #1,d0
	move.w d0,objectListAccX(a4)
	swap d1
	sub.l #$40,d1
	move.w d1,objectListAccY(a4)
	    
 	move.l bascShotAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
	
; start old code
;homeShot
	tst.w plyBase+plyCollided(pc)
	bne homeShotQuit 
	PLAYFX 6
	;bsr getCoords	; get coords of source object
	;sub.w viewPosition+viewPositionPointer(pc),d6
	
;	moveq #-1,d5
	;cmpi #328,d6
	;bcc homeShotQb	; parent entered screen?

	lea plyBase(pc),a0
	move.w plyPosX(a0),a2
	move.w plyPosY(a0),a3
homeShotInit
 	move.l bascShotAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
	bsr getCoords
	GETOBJECTPOINTER a6,a0
homeShotLate
    add.w plyBase+plyPosXDyn(pc),d5
    sub.w #$21,d5
	add.w #12,d6
	move.b objectDefHeight(a0),d2
	lsr #1,d2
	add.w d2,d6	; modify objects position data

    move.w d5,d1
    move.w d6,d2
    sf.b d3

    bsr objectInit
    tst.l d6
    bmi homeShotQuit
    move.b #attrIsSpriteF!attrIsNotHitableF,objectListAttr(a4); attribs
	move.w d1,d5
	move.w d2,d6
	bra.b targetPlayer
homeShotTarget
	bsr getCoords
targetPlayer
	; d5 = bulletX, d6=bulletY, a2=playerX, a3=playerY
	tst.b optionStatus(pc)
	bmi homeShotaddLead
targetPlayerRet
	move.w a2,d0	; get stored player x coord
	add #170,d0

	move.l a6,a1
.findChild
	move.l objectListMyParent(a1),a1
    tst.l a1
    beq.b .allChilds
	add.w objectListX(a1),d5
	bra.b .findChild
.scrollLeadMod
;	dc.w -$25,$f0,$18,$60,$88
	dc.w -$5,-$26,-$68,-$a4,-$e4
.allChilds
	sub.w d5,d0
	swap d0

    move.w d0,d1
    asl.l #1,d0        ; a-shift needed to keep sign
    add.w d1,d0
    swap d0
	move.w d0,objectListAccX(a4)
    
	clr.l d1
	sub.l viewPosition+viewPositionAdd(pc),d1	; mod x-factor related to scrollspeed
	lsl.l #1,d1
	swap d1
		move.w (.scrollLeadMod,pc,d1*2),d2

    add.w a3,d2
    sub d6,d2	; y-pos of object
    move d2,d1
	add.w d1,d2
	subq #4,d2
	move.w d2,objectListAccY(a4)
homeShotQf
    jmp (a5)
    
bulCurt8
    move.w animTablePointer+2(a4),d4
    move objectListY(a6),d6
    sub #32,d6
    lea cBulSpry(pc),a0
bulCurt8B
    GETOBJECTDEFBASE a4
	
    move objectListX(a6),d5
.formation
    move.l (a0)+,d0
    beq .lastFormation
    add #$4,d6
	sf.b d3
    bsr objectInit
    tst.l d6
    bmi.b .lastFormation
    move.b #attrIsSpriteF!attrIsNotHitableF,objectListAttr(a4); attribs
    add d0,d1
    move d1,objectListAccY(a4)
    swap d0
    add d0,d2
    move d2,objectListAccX(a4)
    bra.b .formation
.lastFormation
    jmp (a5)
	
bigBul3T
    lea cBulSpryBig4(pc),a0
	move.l bigTShotAnimPointer(pc),a4
    move.w animTablePointer+2(a4),d4
    moveq #-12,d6
    add.w objectListY(a6),d6
	moveq #40,d5
    add.w objectListX(a6),d5
	GETOBJECTDEFBASE a4
    bra bascShotAltX

cBlSp1FB	; 9 small shots in c-formation, flipped, every 4th frame
	move.b objectListWaveIndx(a6),d0
	bmi cBlSp1FA
	moveq #%11,d2
	moveq #$f,d3
	and d3,d0
	lea objCopyTable+16(pc),a0
	add.b #1,(a0,d0)
	move.b (a0,d0),d0
	and d2,d0
	beq cBlSp1FA
	jmp (a5)
cBlSp1FA	; 9 small shots in c-formation, flipped
	PLAYFX 6
	move.l bascShotAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
    move objectListY(a6),d6
    sub #22,d6
    lea cBulSpryFlipped(pc),a0
    bra bascShot
cBulSp1A	; 9 small shots in c-formation, every 4th frame
	move.b objectListWaveIndx(a6),d0
	bmi cBulSpr1
	move #%111,d2
	moveq #$f,d3
	and d3,d0
	lea objCopyTable+16(pc),a0
	move.b (a0,d0),d1
	add.b #1,(a0,d0)
	and d2,d1
	beq cBulSpr1
	jmp (a5)
cBulSpr1	; 9 small shots in c-formation
    ;getAnimAdress bascShotAnimPointer,basc,Shot
	PLAYFX 6
	move.l bascShotAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
    move objectListY(a6),d6
    sub #22,d6
    
    lea cBulSpry(pc),a0
    bra bascShot
cBulSpr4	; 3 big shots in c-formation left->right
    lea cBulSpryBig4Flipped,a0
	move.l biggShotAnimPointer(pc),a4
    move.w animTablePointer+2(a4),d4
    moveq #-12,d6
    add.w objectListY(a6),d6
	moveq #40,d5
    add.w objectListX(a6),d5
	GETOBJECTDEFBASE a4
    PLAYFX 6
    bra bascShotAltX
cBulSpr2			; 3 big shots in c-formation
    ;getAnimAdress bascShotAnimPointer,basc,Shot
    lea cBulSpryBig4(pc),a0
;	move.l biggShotAnimPointer(pc),a4
	move.l bascShotAnimPointer(pc),a4
    move.w animTablePointer+2(a4),d4
    move objectListY(a6),d3
    ;add #8,d2
	PLAYFX 6
    bra bascShot
cBulSpr3
    lea cBulSpryFormBack,a0
    ;getAnimAdress bascShotAnimPointer,basc,Shot
	move.l bascShotAnimPointer(pc),a4
    move.w animTablePointer+2(a4),d4
    move objectListY(a6),d6
    sub #22,d6
    PLAYFX 6

bascShot
    GETOBJECTDEFBASE a4

    move objectListX(a6),d2
bascShotAltX
.formation
    move.l (a0)+,d0
    beq.b .lastFormation
    move.w d2,d5
    move.w d3,d6
    move #$100,d5
    ;addq #2,d6
    move.l #$FFFE1899,d6
    sf.b d3
    bsr objectInit
    tst.l d6
    bmi.b .lastFormation
    move.b #attrIsSpriteF!attrIsNotHitableF,objectListAttr(a4); attribs
    add d0,d1
    move d1,objectListAccX(a4)
    swap d0
    ;add d0,d4
    ;move #$20,d4
    move d0,objectListAccY(a4)
    bra.b .formation
.lastFormation
    jmp (a5)
    
cBulSpry
    dc.w -12<<4,-12<<4
    dc.w -6<<4,3<<4
    dc.w -5<<4,3<<4
    dc.w -3<<4,3<<4
    dc.w -1<<4,3<<4
    
    dc.w 1<<4,3<<4
    dc.w 3<<4,3<<4
    dc.w 5<<4,3<<4
    dc.w 7<<4,3<<4
    dc.l 0
cBulSpryB
	dc.w -12<<4,-14<<4
	dc.w -6<<4,3<<4
	dc.w -5<<4,3<<4
	dc.w -3<<4,3<<4
	dc.w -1<<4,3<<4
	
	dc.w 1<<4,3<<4
	dc.w 3<<4,3<<4
	dc.w 5<<4,3<<4
	dc.w 7<<4,3<<4
	dc.l 0
cBulSpryFlipped
    dc.w 47<<4,-12<<4
    dc.w 6<<4,3<<4
    dc.w 5<<4,3<<4
    dc.w 3<<4,3<<4
    dc.w 1<<4,3<<4
	
    dc.w -1<<4,3<<4
    dc.w -3<<4,3<<4
    dc.w -5<<4,3<<4
    dc.w -7<<4,3<<4
    dc.l 0
cBulSpryBig4
    dc.w -7<<4,-7<<4
    dc.w -3<<4,3<<4
    dc.w 3<<4,3<<4
    dc.l 0
cBulSpryBig4Flipped
    dc.w 67<<4,-7<<4
    dc.w 3<<4,3<<4
    dc.w -3<<4,3<<4
    dc.l 0

cBulSpryFormBack
    dc.w 48,23<<2
    dc.w 7,-3<<2
    dc.w 6,-3<<2
    dc.w 5,-3<<2
    dc.w 4,-3<<2
    dc.w 3,-3<<2
    dc.w 2,-3<<2
    dc.w 1,-3<<2
    dc.w 0,-3<<2
    dc.w -1,-3<<2
    dc.w -2,-3<<2
    dc.w -3,-3<<2
    dc.w -4,-3<<2
    dc.w -5,-3<<2
    dc.w -6,-3<<2
    dc.l 0
	
retarget            ;adjust x- and y-vector to follow player; works for any object; intervalls controlled by animDefs-List
    ;    screenFlicker
    lea plyPos(pc),a1
    moveq #-50,d0
    add.w (a1),d0;plyPosX
    move.w viewPosition+vPyAccConvertWorldToView(pc),d5
    lsr #3,d5
    ;asl.l #5,d5
    ;swap d5
    moveq #30,d6
    sub d6,d0
    move objectListX(a6),d4
    sub d4,d0
    asr #1,d0        ; a-shift needed to keep sign
    add d5,d0
	
	clr.w d2
	move.b objectListTriggersB+3(a6),d2	; get MaxAcc
	
	tst.w d2
	beq.b .setMax
.retSet
	move.b #$28,d2
	move.w d2,d3
	neg.w d3

	lsl #2,d0
	tst.w d0
    bmi .xIsNeg
	tst.w objectListAccX(a6)
	bmi.b .xValue
	cmp.w d2,d0
    blt.b .xValue
    move.w d2,d0
    bra.b .xValue
.setMax
	move.b #$28,d2
	bra.b .retSet
.xIsNeg
	tst.w objectListAccX(a6)
	bpl.b .xValue
    cmp.w d3,d0
    bgt .xValue
    move d3,d0
.xValue
	;lsl #2,d0
    add d0,objectListAccX(a6)
	
    moveq #-10,d0
    add.w plyPosY(a1),d0
    sub d6,d0
    sub objectListY(a6),d0
    bmi .yIsNeg
	tst.w objectListAccY(a6)
	bmi.b .yValue
    cmp d2,d0
    blt.b .yValue
    move d2,d0
    bra.b .yValue
.yIsNeg
	tst.w objectListAccY(a6)
	bpl.b .yValue
    cmp d3,d0
    bgt.b .yValue
    move d3,d0
.yValue
	lsl #2,d0
	add d0,objectListAccY(a6)
	jmp (a5)
	ENDIF
	
; #MARK: - Handle escalation -

initEscl
;    jmp (a5)
	lea copEscalateBPLPT,a1
	move.l #escalationBitmap,d0
	move.w d0,6(a1)
	move.w d0,8+6(a1)
	move.w d0,16+6(a1)
	swap d0
	move.w d0,2(a1)
	move.w d0,8+2(a1)
	move.w d0,16+2(a1)
	
	pea .ret(pc)	; need to set BPLTPT7-pointer
	bra smEscalUpdateBPLPT
.ret
	lea (viewStageTable+10,pc),a0
	lea copEscalateFlex,a2
	bsr subViewFlexFiller

    PLAYFX 7
	lea coplist,a0
	lea copGameEscalateExit,a1
	move.w d0,copGameEscExitCOLOR00+6-copGameEscalateExit(a1) ;get BPL2MOD in d1 from subViewFlexFiller
	move.w d1,copGameEscExitBPL2MOD+2-copGameEscalateExit(a1)	; d7 set by subViewFlexFiller

    move.w copBPLCON0+2-coplist(a0),d0
    move.w copBPLCON2+2-coplist(a0),d1
    move.w copBPLCON3+2-coplist(a0),d2
	move.w d0,copGameEscExitBPLCON0+2-copGameEscalateExit(a1)
    move.w d1,copGameEscExitBPLCON2+2-copGameEscalateExit(a1)
    ;move.w #$ff20,d2
	move.w d2,copGameEscExitBPLCON3+2-copGameEscalateExit(a1)
	
	;lea copGameDialogueExit,a1 
	move.l escalateExit(pc),d2
	add.l #$4,d2
    move.w d2,copGameEscQuit+6-copGameEscalateExit(a1)
    swap d2
    move.w d2,copGameEscQuit+2-copGameEscalateExit(a1)	; modify return jump to main coplist
    
;;   jmp (a5)
	move.b #1,escalateIsActive

	WAITVBLANK	; wait one frame -> raslistmove built correct gamecoplist
	move.l escalateEntry(pc),a1
	move.w #COPJMP1,12(a1); overwrite copJmp trigger

    jmp (a5)

	ENDIF
    

