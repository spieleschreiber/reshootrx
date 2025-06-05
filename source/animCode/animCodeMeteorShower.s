

    	;	#MARK: Meteor shower emitter

;May use d0,d4,d5,d6,d7,a1,a3
;	a5		=	vars

	;	add commands to animlist "code" +:
	;	trig1025 ff.- 	high density
	;	trig1035 ff.- 	medium density
	;	trig1055 ff.- 	low density
	;	trig1087 ff.- 	very low density

	;	trig1564	- 	head west
	;	trig1600	- 	head south
	;	trig1632	- 	head east
	;	trig1663 	-	head north

	;	trig1792|3	-	slow
	;	trig1794|5	-	medium
	;	trig1796|7	-	fast

	even

meteoCoordtable	;
	; min x-position = 19, max = 208

	dc.b 0,4,0,24,0,46,0,62	 ; x-range 1 to 81 max.
	dc.b 1,0,20,0,80,0,144,0
meteoCtr

	tst plyBase+plyCollided(pc)
	bne.w .noMeteorLaunch
	lea objectListTriggers(a2),a1
	move.b (a1),d0
	beq objectListNextEntry

	sub.b #1,objectListTriggersB+3(a2)
	beq .spawn
	bpl objectListNextEntry
.spawn
	move.b d0,objectListTriggersB+3(a2)
	move.b fastRandomSeed-vars+6(a5),d0
	andi.b #3,d0
	add.b #1,d0
	add.b d0,1(a1)
	move.b 1(a1),d0
	andi #7,d0

	SAVEREGISTERS
	clr.w d5
	moveq #1,d5
	add.b 3(a1),d5
	clr.w d6
	move.b 2(a1),d6
	moveq #$7f/2,d7
	andi.w #$7f,d6
	sub.b sineTable(pc,d6),d7
	ext.w d7
	asl d5,d7	; created y-acc
	swap d7


	move.w #$3f,d7
	move #$5f,d4
	sub.w d6,d4
	and #$7f,d4
	sub.b sineTable(pc,d4),d7
	ext.w d7
	asl d5,d7

	move.w	fastRandomSeed-vars(a5),d4
	andi #$3f,d4
	clr.w d6
	move.b (8+meteoCoordtable,pc,d0),d6
	bne .putOnYAxis
	;bra .tooManyObj
	clr.w d5
	move.b (meteoCoordtable,pc,d0),d5
	lsl #2,d5
	add.w #132,d5
	add.w d4,d5
	clr.w d6
	tst.w d7
	spl d6
	ext.w d6
	andi #272,d6
	sub #22,d6
	bra .added
.putOnYAxis
	tst.l d7
	smi d5
	ext.w d5
	andi #309,d5
	;clr.w d5
	add.w #147,d5	; reasonable range 147 to 456
	add.w d4,d6
	;lsr #2,d4
	;add.w d4,d5
.added
	add.w viewPosition+viewPositionPointer(pc),d6
	move.l meteoMedAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
	st.b d3
	bsr objectInit
	tst.l d6
	bmi .tooManyObj
	;clr.l objectListHit(a4)

	moveq #8<<2,d4
	tst.b optionStatus(pc)
	spl d5
	andi.w #2<<2,d5
	sub.w d5,d4	; on easy, sub 2 hitpoints

    move.w d4,objectListHit(a4); hitpoints
    move.b #attrIsOpaqF,objectListAttr(a4); attribs
    lea objectListAttr(a4),a3
    clr.l objectListMyParent(a4)   ; clear parent pointer
    clr.l objectListMyChild(a4)   ; clear child pointer
	clr.l objectListTriggers(a4); reset object triggers
	clr.l objectListTriggersB(a4); again
	st.b objectListWaveIndx(a4)   ; clear wave index ($ff)

	movem.l	fastRandomSeed-vars(a5),d4/d5				; AB
	swap	d5						; DC
	add.l	d5,fastRandomSeed-vars(a5)					; AB + DC
	add.l	d4,fastRandomSeed-vars+4(a5)				; CD + AB
	;move.b #8,d0
	;add.w d4,objectListX(a4)


	;MSG01 m2,d0
	move.b objectListTriggers+2(a2),d0
	moveq #8,d6
	sub.b objectListTriggers+2(a2),d6
	ext.w d6
	ext.l d6
	;add.w d0,objectListAccX(a4)
	;move.w objectListX(a4),d7
	;move.w #390,d7
	;sub.w objectListX(a4),d7
	;eor.w #511,d7
	;muls.w d6,d7
	move.w #200,objectListAccX(a4)	; straighten acceleration to make room for player ship

;	move.w objectListY(a4),d7
;	sub.w viewPosition+viewPositionPointer(pc),d7
;	add #220,d7
;	move.w d7,objectListAccY(a4)
	move.w viewPosition+viewPositionAdd(pc),d0
	lsl #8,d0
	sub.w d7,d0
	move.w d0,objectListAccY(a4)
	move.w objectListY(a4),d7
	add #90,d7
	sub.w viewPosition+viewPositionPointer(pc),d7
	lsr #1,d7
	;sub #50,d7
	add.w d7,objectListAccY(a4)

	swap d7
	;ext.w d7
	;asl #3,d7
	move.w d7,objectListAccX(a4)
	move.w objectListX(a4),d7
	sub #310,d7
	;add #220,d7
	add.w d7,objectListAccX(a4)


.sksk
	cmpa.l a2,a4		; new entry higher in list then current enty?
	bls.b .tooManyObj
    RESTOREREGISTERS
    addq #1,d3		; yes, process one add. object to avoid flicker
	bra objectListNextEntry
.tooManyObj
	RESTOREREGISTERS
.noMeteorLaunch
	bra objectListNextEntry


	;	#MARK: Meteor itself

meteoMed
	
	clr.l d0
	moveq #12,d7
    add.w objectListY(a2),d7         ; load object y-coords
    move d7,d0
	sub.w viewPosition+viewPositionPointer(pc),d0
	;clr.l d7
    move.w objectListX(a2),d7
    ;lsr #1,d7
    sub.b objectListCnt(a2),d7
	tst.b objectListTriggers(a2)
	bne .32frames
    lsr #3,d7
    andi #$f,d7
    bra .drawFrame
.32frames
    lsr #3,d7
    andi #$1f,d7
.drawFrame
    ;move.b (.animFrames.w,pc,d7),d7
    lea (a0,d7*4),a0	; animate

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
	;move.w #-1,40(a1)
	tst.w (a1)	; chk bckgnd collission
	bne.b .initColl
.quit
	btst.b #attrIsKillBorderExit,objectListAttr(a2)	; killcheck bit set?
	;beq animReturn	; no
;	bra animReturn
	lea killBoundsWide(pc),a1
	bra killCheck
.yBounds
	dc.w $10,$f0
.xBounds
	dc.w 0,$110

.initColl

	lea plyPos(pc),a1
	tst.b plyCollided(a1)
	bne.b .quit	; player dies? Dont collide with debris
	
.hasCollided
	move.b #3,killShakeIsActive-vars(a5)

	SAVEREGISTERS
	clr.l d1
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

	movem.l d7/a0/a3/a4/a5/a6,-(sp)
	movem.l mainPlanesPointer(pc),a3/a5/a6
	adda.l d1,a3
	adda.l d1,a5
	adda.l d1,a6

	move d6,d0
	clr.w d1
	move.b objectDefHeight(a4),d1

	subq #1,d1
	sub.w d4,d0
	add.b d1,d0
	bcc .yOverflow	; does object overflow lower border?
	sub.b d0,d1		; yes -> modify object height
	sub #2,d1
.yOverflow

   	
   	;clr.l d1
	moveq #mainPlaneWidth,d2
	;lea (8*16),a4
.drawMain
	clr.l d7
	tst.b objectListTriggers(a2)
	sne d7
	andi.b #8,d7
	add.b #8,d7	; can be either 8 or 16
	lsl #3,d7

	moveq #3,d0
.drawToPlane					; stamp meteorite into bitplane
		move.l (a1),d4
		move.l (a0),d5
		move.l (a0,d7),d3
		not.l d3
		and.l d3,d4	; mask source
		or.l d5,d4
		;moveq #-1,d4
		;move.l d4,(a1)
		move.l d4,(a3)
		move.l d4,(a5)
		move.l d4,(a6)

		adda.l d7,a0
		adda.l d7,a0
		adda.l d2,a1
		adda.l d2,a3
		adda.l d2,a5
		adda.l d2,a6
	dbra d0,.drawToPlane
	dbra d1,.drawMain
	movem.l (sp)+,d7/a0/a3/a4/a5/a6
	clr.w d4
	move.b objectDefHeight(a4),d4
	clr.l d1

	move d6,d1
    lsr #1,d4
    sub.w d4,d1
	move.w (a3,d1.w*2),d1     ; y bitmap offset
    move.l mainPlanesPointerAsync(pc),a1
    add.l d7,d1
	adda.l d1,a1

	clr.w d3
	move.b viewPosition+viewPositionPointer+1(pc),d3
	add.w d6,d3
	clr.w d6
	move.b objectDefHeight(a4),d6
	subq #1,d6
	;move.w #$100,d4
	;sub.w d7,d4
	cmp.w #$f0,d3
	bcc .skip


.yOverflowB

	movem.l mainPlanesPointer(pc),a3/a4/a6
	adda.l d1,a3
	adda.l d1,a4
	adda.l d1,a6

	moveq #$5,d1
	ror.w #3,d1	; (mainPlaneWidth*mainPlaneDepth)*256 = $a000
.drawSecondary
	clr.l d7
	tst.b objectListTriggers(a2)
	sne d7
	andi.b #8,d7
	add.b #8,d7	; can be either 8 or 16
	lsl #3,d7

	moveq #3,d0
.drawToPlaneB					; stamp meteorite into bitplane
		move.l (a1),d4
		move.l (a0),d5
		move.l (a0,d7),d3
		not.l d3
		and.l d3,d4	; mask source
		or.l d5,d4
		;moveq #-1,d4
		move.l d4,(a3,d1.l)
		move.l d4,(a4,d1.l)
		move.l d4,(a6,d1.l)
		adda.l d7,a0
		adda.l d7,a0
		adda.l d2,a1
		add.l d2,d1
	dbra d0,.drawToPlaneB
	dbra d6,.drawSecondary

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
	;bra animReturn
;May use d0,d4,d5,d6,d7,a1,a3

	GETOBJECTPOINTER a2,a4
		;move objectDefAttribs(a4),d0	; fetch attribs and anim pointer
	move.l (a4),a0
	adda.l bobSource-vars(a5),a0             ; Adress of sourcebitmap
	bra animReturn
	;bra objectListNextEntry
	
