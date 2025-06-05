

; RESHOOT.repeat  27. 7. 2016
; Copyright (c) 2016 Richard Löwenstein

;	{# <- this lines only purpose is to keep indents and formatting in Xcode right

	

	

;!!!: Customcode: code called from objectMoveManager. Init by animlist -> code-command. a6 contains pointer to objectlist, a5 contains return-address
;
    ;code may not use a5,a6,d7
	; a6 = pointer to caller object
	
    ; some code is handled separately, e.g. in collision manager. therefore some labels are dummies, not used
c_noCode
cPlyShot            ; ply shot
cPlyShtX            ; ply shot exit
cExplSml
cExplLrg
waveBnus
chainBns
cWepDstr
noCode
repeat40
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
	bsr getCoordsBlitter
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
	clr.l objectListMyChild(a4)

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
	clr.l objectListMyChild(a4)

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
	;clr.l objectListMyChild(a4)

    ;move.l a4,objectListMyChild(a6)
.quit
;	move.l (sp)+,a5
	jmp (a5)
; #MARK: - Init tube tentacle

tubeIniR
	clr.w d0
	move.b objectListTriggers(a6),d0
	move.l tubeTurRAnimPointer(pc),d1
	move.l tubeTenRAnimPointer(pc),a4
	bra initTube
tubeIniL	; init tentacle
    clr.w d0
	move.b objectListTriggers(a6),d0
	move.l tubeTurLAnimPointer(pc),d1
	move.l tubeTenLAnimPointer(pc),a4
initTube
    bset.b #1,objectListAttr(a6)    ; mark parent
    move.l a4,a0
    move.l a6,a2
	
	sub.l a3,a3	; draw tube nonopaque where applicable
	swap d4
	clr.w d4
	;move.w #attrIsNotHitableF,d4
    btst.b #6,objectListAttr(a6)
    beq.b .setOpaque
    move.w #attrIsOpaqF,d4
    bclr #6,objectListAttr(a6)
.setOpaque
	swap d4
.nextChild
    move.l a0,a4
    move.w animTablePointer+2(a4),d4
    st.b d3
    clr.w d5
    move #-300,d6
    ;clr.w d6
    bsr objectInit
    tst.l d6
    bmi customCodeQuit
    clr.w objectListHit(a4); can´t be hit
    move a3,d6
	swap d4
	move.w d4,a3	; first tube always opaque, add opaque bit after
	swap d4
    move.b d6,objectListAttr(a4); attribs
    move.l a4,objectListMyChild(a2)
    move.l a2,objectListMyParent(a4)
	clr.l objectListMyChild(a4)

    move d0,d6
    clr.w d5
	move.b objectListTriggers+1(a6),d5	; modify character of curved anim
    asl d5,d6
    add.b d6,objectListCnt(a4)
    ;move.b #1,objectListCnt(a4)
    move.l a4,a2
    dbra d0,.nextChild
	
    move.l d1,a4        ; add turret
    move.w animTablePointer+2(a4),d4
    clr.w d5
	move.b objectListTriggers+2(a6),d5	; modify head/turret offset
	lsl #1,d5
	ext.w d5
    moveq #10,d6
    st.b d3
    bsr objectInit
    tst.l d6
    bmi.b customCodeQuit
    clr.l objectListAcc(a4)	; must not move
    clr.l objectListTriggers(a4)
    clr.w objectListHit(a4); can´t be hit 
    move.b #attrIsImpactF,objectListAttr(a4); attribs
    move.l a4,objectListMyChild(a2)
    move.l a2,objectListMyParent(a4)
customCodeQuit
    jmp (a5)


	
;	#MARK: - L2 Wall Init


l2wallStop	= 	tempVar
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
	
	
; #MARK: - SHARED SUBCODE
; #MARK: draw object on top

drwOnTop ; move object in drawlist order to last spot -> change prio.Beware: Updates only ONE main child object!


	move.w objCount(pc),d6
;	sub.w spriteCount(pc),d6
	subq #1,d6
	bcs.b .quit
	moveq #4,d1
	move.l objectList+4(pc),a1
	;lea 4(a6),a1
.slotOcc
	tst.w (a1)
	adda.l d1,a1
	beq.b .slotOcc
	dbra d6,.slotOcc
	adda.l d1,a1
	move.l (a6),(a1)
	move.l objectListX(a6),objectListX(a1)
	move.l objectListY(a6),objectListY(a1)
	move.l objectListAcc(a6),objectListAcc(a1)
	move.l objectListHit(a6),objectListHit(a1)
	move.l objectListTriggers(a6),objectListTriggers(a1)
	move.l objectListTriggersB(a6),objectListTriggersB(a1)
	move.l objectListMyChild(a6),a0
	move.l a0,objectListMyChild(a1)
	move.l objectListMyParent(a6),objectListMyParent(a1)
	
	clr.l (a6)
	clr.l objectListMyParent(a6)
	clr.l objectListMyChild(a1)
	tst.l a0
	beq.b .quit
	move.l a1,objectListMyParent(a0)
.quit
	rts

;	#MARK: init single Object

initObject
	move.w animTablePointer+2(a4),d4
    st.b d3

	clr.w d5
	clr.w d6
	bsr objectInit
	tst.l d6
	bmi.b .ret
	bsr modifyObjCount
	st.b objectListHit(a4); hitpoints
	move.b #attrIsNotHitableF,objectListAttr(a4);
.ret
	rts



;	#MARK: get objects world coords parent or child

getCoords
    move objectListX(a6),d5
    move objectListY(a6),d6
    move.l a6,a1        ; is children object -> add all parent coords
    move.l objectListMyParent(a1),a1
    tst.l a1
    bne.b .gotChildren
    rts
.getChildren
	add.w objectListX(a1),d5
	add.w objectListY(a1),d6
	move.l objectListMyParent(a1),a1
	tst.l a1
	bne.b .getChildren
	rts
getCoordsLongX
    movem.l objectListX(a6),d5/d6
    move.l a6,a1        ; is children object -> add all parent coords
    move.l objectListMyParent(a1),a1
    tst.l a1
    bne.b .gotChildren
    rts
.gotChildren
    add.l objectListX(a1),d5
    add.l objectListY(a1),d6
    move.l objectListMyParent(a1),a1
    tst.l a1
    bne.b .gotChildren
	move.l objectListMainparent(a6),a1	; return pointer to main parent
	rts

; #MARK: END SHARED SUBCODE

; #MARK: - Init BoneSnake

initSnke
	;jmp (a5)
	moveq #3,d0
	move.b #attrIsImpactF,objectListAttr(a6); attribs
	move.l a6,a2
.swarm
	move.l boneSnkAAnimPointer(pc),a4
	moveq #-20,d5
	moveq #-15,d6
	bsr .initObj
	move.l a4,a1
	move.l boneSnkBAnimPointer(pc),a4
	moveq #10,d5
	moveq #-8,d6
	bsr .initObj
	move.l boneSnkCAnimPointer(pc),a4
	moveq #4,d5
	moveq #-5,d6
	bsr .initObj
	jmp (a5)
.quit
	bsr drwOnTop	; parent on top
	add.b #10,objectListCnt(a1)	; fix to keep cnt flow
	jmp (a5)

.initObj
	move.w animTablePointer+2(a4),d4
    st.b d3
	bsr objectInit
	tst.l d6
	bmi.b .ret
	move.l a4,objectListMyChild(a2)
	move.l a2,objectListMyParent(a4)
	move.l a4,a2

	;st.b objectListTriggersB(a4); no random movement
	st.b objectListHit(a4); hitpoints
	move.b #attrIsImpactF,objectListAttr(a4);
	move.b #1,objectListCnt(a4)
.ret
	rts
shootSnk
	jmp (a5)
	move.w objectListX(a6),d0
	sub.w viewPosition+viewPositionPointer(pc),d0
	bmi .quit
	SAVEREGISTERS
;	move.l astrSmlTAnimPointer(pc),a4
	move.l boneSnkCAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
    st.b d3

	bsr getCoords
	add.w #40,d5
	bsr objectInit
	tst.l d6
	bmi.b .preQuit
	st.b objectListTriggersB(a4); no random movement
	move.w #1<<2,objectListHit(a4); hitpoints
	move.b #attrIsImpactF,objectListAttr(a4);
	clr.l objectListMyParent(a4)
	clr.l objectListMyChild(a4)
	PLAYFX 16
.preQuit
	RESTOREREGISTERS
.quit
	jmp (a5)
.accOffset
	dc.b 250,250
	dc.b 0,0
	dc.b 6,6
	dc.b -100,100
	dc.b 200,-100
	dc.b 50,240
	dc.b -80,$38
	dc.b -80,130

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

homeSht8		; launch projectile every 8 calls
	move #%111,d2
	bra.b homeSht4entry
homeSht4	; launch projectile every 4 calls
	
	move #%11,d2
homeSht4entry
	;move.b objectListWaveIndx(a6),d0
	;bmi homeShot

	moveq #$f,d3
	and d3,d0
	lea objCopyTable+16(pc),a0
	add.b #1,(a0,d0)
	move.b (a0,d0),d0
	and d2,d0
	beq homeShot
homeShotQ
	jmp (a5)
	
	
    ;code may not use a5,a6,d7
homeShot		; launch homing bullet towards current player position
	move.l bascShotAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
	bsr getCoords
	GETOBJECTPOINTER a6,a0
	
    add.w plyBase+plyPosXDyn(pc),d5
    sub.w #$21,d5
	add.w #12,d6
	clr.w d2
	move.b objectDefHeight(a0),d2
	lsr #1,d2
	add.w d2,d6	; modify objects position data

    move.w d5,d0
    move.w d6,d1
    sf.b d3
    bsr objectInit
    tst.l d6
    bmi homeShotQuit
    move.b #attrIsSpriteF!attrIsNotHitableF,objectListAttr(a4); attribs
	clr.w d3	
	lea plyBase(pc),a0
	sub.w plyPosX(a0),d0
	sub.w plyPosY(a0),d1
	bra homeShotDirection

homeShotLead	; launch homing bullet with lead 
	;jmp (a5)
	;move.l biggShotAnimPointer(pc),a4
		move.l bascShotAnimPointer(pc),a4

	move.w animTablePointer+2(a4),d4
	bsr getCoords
	GETOBJECTPOINTER a6,a0
    add.w plyBase+plyPosXDyn(pc),d5
    sub.w #$22,d5	; set x launch position
	add.w #14,d6	; set y launch position
	clr.w d2
	move.b objectDefHeight(a0),d2
	lsr #1,d2
	add.w d2,d6	; modify objects position data

    move.w d5,d0
    move.w d6,d1
	sf.b d3
   	bsr objectInit
    	;cmpa.l a6,a4	; new object higher than parent object in object list? +1 objCounter

    tst.l d6
    bmi homeShotQuit
    clr.l objectListMyChild(a4)
    clr.l objectListMyParent(a4)
    move.b #attrIsSpriteF!attrIsNotHitableF,objectListAttr(a4); attribs

	clr.w d3	
	sub.w plyBase+plyPosX(pc),d0
	sub.w plyBase+plyPosY(pc),d1

	move d0,d2	; calc distance object - player
	sub.w #$53*2,d2
	asr.w #1,d2
	tst.b d2
	smi d3
	eor.b d3,d2
	move d1,d6
	sub.w #$12*2,d6
	asr.w #1,d6
	tst.b d6
	smi d3
	eor.b d3,d6
	add.b d6,d2
	add #4,d2	; adjustment for lead intensity. No lead=0. >12 results in chaotic runaways 
	andi #$ff,d2	; distance obj-ply
	
	move d0,d3
	;lsr #6,d3
	asr #4,d2
	;sub d3,d2
	btst #3,d2
	beq .2
	moveq #7,d2
.2
	move.l plyPos+plyAcclXABS(pc),d3
	lsl.w d2,d3
	asr #3,d3
	sub d3,d1	; add lead to y-acc
	
	swap d3
	lsl.w d2,d3
	asr #3,d3
	sub d3,d0	; add lead to x-acc

	; point bullet towards players position

homeShotDirection
	PLAYFX fxEnemBullet
	;bra homeShotQuit
	move.w objectListTriggersB(a6),d6
	andi #$7f,d6
	move d6,d5
	add #23,objectListTriggersB(a6)
	moveq #63,d5
	sub.b sineTable(pc,d6),d5
	;lsr #1,d5
	ext.w d5
	;add.w d5,d0
		
	
	add #170,d0	; adjust players x-coord to world coords
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
	
	cmpa.l a6,a4	; new object higher than parent object in object list? +1 objCounter
	bls homeShotQuit
	add #1,d7
homeShotQuit
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
	btst #optionDiff,optionStatus(PC)
	tst.b gameOptions(pc)
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
	
; #MARK: - Attach tutorial icons
addTutSp
	
	move.l tutSpdUpAnimPointer(pc),a4
	bra addtutSkip
addTutPw	
	move.l tutPwrUpAnimPointer(pc),a4
addtutSkip
	;move.l waveBnusAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4	;add bonus display
	moveq #-3,d5
	moveq #34,d6
	bsr objectInit
	tst.l d6
	bmi .quitAttachTut
    or.b #attrIsSpriteF!attrIsBonusF,objectListAttr(a4); tutorial icon is child
	move.l a4,objectListMyChild(a6)
	move.l a6,objectListMyParent(a4)
	move.l a2,objectListMainParent(a4)
	clr.l objectListMyChild(a4)
	jmp (a5)
	
dstrEvnt			; set destruction event 
	move.w #destroyBase-bobCodeCases-16,d0
	sub.w d0,d4
	lsr #4,d4	; calc entry number
	move.b d4,objectListDestroy(a6)
	jmp (a5)
	



exitKill	; define object as deletable if it leaves screen
	
	bset #0,objectListTriggersB+3(a6)
	jmp (a5)

bulletLaunchSkipper        ; counter for bullet launch in worms etc. Use: Launch projectile every xth iteration
    dc.b    0
bulletLaunchSkipperMisl
    dc.b    0
bobCodeCases
; pointers to object individual code entry adress and anim struct. Code entry adress gets filled within init code. anim table pointer usually 0 or filled in runtime using getAnimAdress [pointer to var store, name of anim]
; struct:   1.l -> code entry name
;           2.l -> code entry adress
;           3.l -> pointer to anim table entry.
    dc.b    "c_noCode"
    dc.l    c_noCode,0

    dc.b    "emtyAnim"
    dc.l    noCode
emtyAnimAnimPointer
    dc.l    0

	dc.b	"testAnim"
	dc.l	noCode
testAnimAnimPointer
	dc.l	0

	dc.b    "exitKill"
	dc.l    exitKill
exitKillAnimPointer
	dc.l    0

    dc.b    "cExplSml"
    dc.l    noCode
cExplSmlAnimPointer
    dc.l    0
	
    dc.b    "cExplMed"
    dc.l    noCode
cExplMedAnimPointer
    dc.l    0
	
	dc.b    "cExplLrg"
	dc.l    noCode
cExplLrgAnimPointer
	dc.l    0
	
	dc.b    "waveBnus"
	dc.l    noCode
waveBnusAnimPointer
	dc.l    0

	dc.b    "chainBns"
	dc.l    noCode
chainBnsAnimPointer
	dc.l    0

	dc.b    "tutSpdUp"
	dc.l    noCode
tutSpdUpAnimPointer
	dc.l    0

	dc.b    "tutPwrUp"
	dc.l    noCode
tutPwrUpAnimPointer
	dc.l    0

	dc.b    "addTutPw"
	dc.l    addTutPw	; add tutorial PowerUp Icon
	dc.l    0

	dc.b    "addTutSp"
	dc.l    addTutSp	; add tutorial SpeedUp Icon
	dc.l    0

	dc.b 	"bascShot"
	dc.l 	noCode
bascShotAnimPointer
    dc.l    0

	dc.b 	"bascShot"
	dc.l 	noCode
biggShotAnimPointer
    dc.l    0

	dc.b 	"eyesShot"
	dc.l 	noCode
eyesShotAnimPointer
	dc.l    0

	dc.b    "wallInit"
	dc.l    wallInit	;
	dc.l    0

	dc.b    "wallBrke"
	dc.l    noCode
wallBrkeAnimPointer
	dc.l    0

    dc.b    "mislExpl"
    dc.l    mislExpl
mislExplAnimPointer
    dc.l    0

	dc.b    "homeMisl"	; keep homeMisl&mislB together, needed in launch code
	dc.l    noCode
homeMislAnimPointer
    dc.l    0
    dc.b    "homMislB"
    dc.l    noCode
homMislBAnimPointer
    dc.l    0
    dc.b    "hmMslBos"
    dc.l    noCode
hmMslBosAnimPointer
    dc.l    0

    dc.b    "mislInit"
    dc.l    mislInit
    dc.l    0
    dc.b    "mislBoss"
    dc.l    mislBoss
    dc.l    0

    dc.b    "mothTurA"
    dc.l    noCode
mothTurAAnimPointer
    dc.l    0
    dc.b    "mothTuA2"
    dc.l    noCode
mothTuA2AnimPointer
    dc.l    0

    dc.b    "mothTurC"
    dc.l    noCode
mothTurCAnimPointer
    dc.l    0
    dc.b    "mothTuC2"
    dc.l    noCode
mothTuC2AnimPointer
    dc.l    0
    dc.b    "mothChld"
    dc.l    mothChld
mothChldAnimPointer
    dc.l    0
    dc.b    "mothTuBs"
    dc.l    noCode
mothTuBsAnimPointer
    dc.l    0

    

;#MARK: Pointers Scroll Control
	dc.b 	"scrolSlo"
	dc.l	scrolSlo
	dc.l	0

	dc.b 	"scrolMed"
	dc.l	scrolMed
	dc.l	0

	dc.b 	"scrolFst"
	dc.l	scrolFst
	dc.l	0

	dc.b 	"scrolRes"
	dc.l	scrolRes
	dc.l	0


;#MARK: Pointers L3 Midboss

	dc.b 	"l3brInit"
	dc.l	l3brInit
	dc.l	0
	
	dc.b 	"l3brEyUp"
	dc.l	noCode
l3brEyUpAnimPointer
	dc.l	0
	dc.b 	"l3brEyDn"
	dc.l	noCode
l3brEyDnAnimPointer
	dc.l	0
	dc.b 	"l3brHead"
	dc.l	noCode
l3brHeadAnimPointer
	dc.l	0
	dc.b 	"l3brHelm"
	dc.l	noCode
l3brHelmAnimPointer
	dc.l	0
	dc.b 	"l3brTeth"
	dc.l	noCode
l3brTethAnimPointer
	dc.l	0
	dc.b    "l3brAdTa"
	dc.l    l3brAdTa
	dc.l    0
	dc.b    "l3brTail"
	dc.l    noCode
l3brTailAnimPointer
	dc.l    0
	dc.b    "l3brTaiA"
	dc.l    noCode
l3brTaiAAnimPointer
	dc.l    0


	IFNE	0
;#MARK: Pointers Asteroid
	dc.b    "astrTenc"
	dc.l    astrTenc
	dc.l    0


	dc.b 	"astrSmlT"
	dc.l 	noCode
astrSmlTAnimPointer
	dc.l 	0

	dc.b 	"astrKilA"
	dc.l 	astrAni96
astrKilAAnimPointer
	dc.l 	0

	dc.b 	"astrKilB"
	dc.l 	astrAni96
astrKilBAnimPointer
	dc.l 	0

	dc.b 	"astrKilC"
	dc.l 	astrAni96
astrKilCAnimPointer
	dc.l 	0
	ENDIF
	
;#MARK: Pointers Tentacle

	dc.b    "tubeIniL"	; code init 
	dc.l    tubeIniL,0

	dc.b    "tubeIniR"	; 	""
	dc.l    tubeIniR,0

	dc.b    "tubeTenL"	; anim pointer
	dc.l    noCode
tubeTenLAnimPointer
    dc.l    0

    dc.b    "tubeTenR"
    dc.l    noCode
tubeTenRAnimPointer
    dc.l    0

	dc.b    "tubeTurL"
	dc.l    noCode
tubeTurLAnimPointer
	dc.l    0

	dc.b    "tubeTurR"
	dc.l    noCode
tubeTurRAnimPointer
	dc.l    0

	



;#MARK: Pointers Sun Boss

	; anim pointers

	dc.b	"donutBsA"
	dc.l	noCode
donutBsAAnimPointer
	dc.l    0

	dc.b	"donutBsB"
	dc.l	noCode
donutBsBAnimPointer
	dc.l    0

	dc.b	"eyeRoidB"
	dc.l	noCode
eyeRoidBAnimPointer
	dc.l	0

	IFNE 0
;#MARK: Pointers L2 / L4 Sky Boss / Wasp
	; code inits
	dc.b	"l2bsInit"
	dc.l	l2bsInit,0

	dc.b	"l2WsInit"
	dc.l	l2WsInit,0

    dc.b    "waspIntA"
    dc.l    waspIntA,0

    dc.b    "waspIntB"
    dc.l    waspIntB,0

    dc.b    "waspIntC"
    dc.l    waspIntC,0

	dc.b 	"l4bsShtA"
	dc.l	l4bsShtA,0

	dc.b	"waspMain"
	dc.l	noCode
waspMainAnimPointer
	dc.l    0

	dc.b    "waspChdA"
	dc.l    noCode
waspChdAAnimPointer
	dc.l    0

	dc.b    "waspChA2"; ATTN: keep position of waspCha? in relation to waspChdA, needed in waspIntA boss init code
	dc.l    noCode
	dc.l    0

	dc.b    "waspChA3"
	dc.l    noCode
	dc.l    0

    dc.b    "waspChdB"
    dc.l    noCode
waspChdBAnimPointer
    dc.l    0

    dc.b    "waspStg1"
    dc.l    noCode
waspStg1AnimPointer
    dc.l    0

	dc.b    "waspVuln"
	dc.l    waspVuln
	dc.l    0
    dc.b    "waspUnvu"
    dc.l    waspUnvu
    dc.l    0
	
	dc.b    "isHitble"
	dc.l    isHitble
	dc.l    0
    dc.b    "notHitbl"
    dc.l    notHitbl
    dc.l    0
	dc.b    "waspSht1"
	dc.l    waspSht1
	dc.l    0
	dc.b    "waspSht2"
	dc.l    waspSht2
	dc.l    0
	ENDIF


	dc.b    "shotPtrn"
	dc.l    shotPtrn
	dc.l    0

	dc.b    "homeShot"
homeShotPointer    
	dc.l    homeShot
	dc.l    0

	IFNE 1
	dc.b    "homeSht8"
	dc.l    homeSht8
	dc.l    0

	dc.b    "homeSht4"
	dc.l    homeSht4
	dc.l    0
	ENDIF
	
    dc.b    "debrisA2"
    dc.l    c_noCode
debrisA2AnimPointer
    dc.l    0

    dc.b    "debrisA3"
    dc.l    c_noCode
debrisA3AnimPointer
    dc.l    0

    dc.b    "debrisA1"
    dc.l    c_noCode
debrisA1AnimPointer
    dc.l    0

    dc.b    "debrisA4"
    dc.l    c_noCode
debrisA4AnimPointer
    dc.l    0

cPlyShtA
    dc.b    "cPlyShtA"
    dc.l    noCode
cPlyShtAAnimPointer
    dc.l    0

    dc.b    "cPlyShtB"
    dc.l    noCode
cPlyShtBAnimPointer
    dc.l    0

	dc.b	"cPlyShtC"
	dc.l	noCode
cPlyShtCAnimPointer
	dc.l	0

	dc.b	"cPlyShtD"
	dc.l	noCode
cPlyShtDAnimPointer
	dc.l	0

	dc.b	"cPlyShtE"
	dc.l	noCode
cPlyShtEAnimPointer
	dc.l    0

	dc.b	"cPlyShtF"
	dc.l	noCode
cPlyShtFAnimPointer
	dc.l    0

	dc.b	"cPlyShAX"
	dc.l	noCode
cPlyShAXAnimPointer
	dc.l	0

	dc.b	"cPlyShBX"
	dc.l	noCode
cPlyShBXAnimPointer
	dc.l	0

	dc.b	"cPlyShCX"
	dc.l	noCode
cPlyShCXAnimPointer
	dc.l	0

	dc.b	"cPlyShDX"
	dc.l	noCode
cPlyShDXAnimPointer
	dc.l	0

	dc.b	"cPlyShEX"
	dc.l	noCode
cPlyShEXAnimPointer
	dc.l	0

	dc.b	"cPlyShFX"
	dc.l	noCode
cPlyShFXAnimPointer
	dc.l	0

    dc.b    "pictHero"
    dc.l    noCode
pictHeroAnimPointer
    dc.l    0
    dc.b    "pictBoss"
    dc.l    noCode
pictBossAnimPointer
    dc.l    0

;#MARK: Pointers BoneSnake
    dc.b    "initSnke"
    dc.l    initSnke
    dc.l    0

	dc.b 	"boneSnkA"
	dc.l 	noCode
boneSnkAAnimPointer
	dc.l 	0

	dc.b 	"boneSnkB"
	dc.l 	noCode
boneSnkBAnimPointer
	dc.l 	0

	dc.b 	"boneSnkC"
	dc.l 	noCode
boneSnkCAnimPointer
	dc.l 	0

	dc.b 	"shootSnk"
	dc.l 	shootSnk
	dc.l 	0


;#MARK: Pointers Dialogue

    dc.b    "weapDstr"
    dc.l    noCode
weapDstrAnimPointer
    dc.l    0

;#MARK: Meteor Shower
    dc.b    "metEmitr"	; emitter 
    dc.l    noCode
metEmitrAnimPointer
    dc.l	0
    
    dc.b    "meteoMed"	; anim pointer
    dc.l    noCode
meteoMedAnimPointer
    dc.l    0

    dc.b    "brickMed"
    dc.l    noCode
brickMedAnimPointer
    dc.l    0

    dc.b    "brickTur"
    dc.l    noCode
brickTurAnimPointer
    dc.l    0

	dc.b    "brickEye"
	dc.l    noCode
brickEyeAnimPointer
	dc.l    0

	dc.b    "brickDsc"
	dc.l    noCode
brickDscAnimPointer
	dc.l    0


    dc.b    "boulders"
    dc.l    noCode
bouldersAnimPointer
    dc.l    0

    dc.b    "drwOnTop"
    jmp     drwOnTop
    dc.l    0

    dc.b    "showCont"
    dc.l    noCode
showContAnimPointer
    dc.l    0

	dc.b 	"destroyA"
destroyBase	; label needs to be set infront of first destroy Entry 
 	dc.l 	dstrEvnt
	dc.l	0
	dc.b 	"destroyB"
	dc.l 	dstrEvnt
	dc.l	0
	dc.b 	"destroyC"
	dc.l 	dstrEvnt
	dc.l	0
	dc.b 	"destroyD"
	dc.l 	dstrEvnt
	dc.l	0
	dc.b 	"destroyE"
	dc.l 	dstrEvnt
	dc.l	0
	dc.b 	"destroyF"
	dc.l 	dstrEvnt
	dc.l	0
	dc.b 	"destroyG"
	dc.l 	dstrEvnt
	dc.l	0
	dc.b 	"destroyH"
	dc.l 	dstrEvnt
	dc.l	0

	dc.b    "initEscl"
	dc.l    initEscl
	dc.l    0
    dc.b    "muscEscl"
    dc.l    muscEscl
    dc.l    0
	dc.b    "exitEscl"
    dc.l    exitEscl
    dc.l    0

bobCodeCasesEnd
    ;}

