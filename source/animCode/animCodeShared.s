

;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter bitmap load adress or use a0 if return to bobblitnext / not animreturn

		;	#MARK: - basics: no anim, 8 frames loop, 2 frames loop, empty object kill border


animBasicOffsets
	blk.w 4,0
non_Anim
	bra animReturn
bullEmit
	move.l bossVars+bossChildPointers+(13*4)(pc),a1	; ugly fix. Get main object at this abs adress. Should have been objectTriggers or else, but can't as trigs and trigsB is used by 
	move.l objectListAcc(a1),d0	; get main object accl values
	move.l d0,objectListAcc(a2)
	move.w objectListX(a1),d0
	move.w d0,objectListX(a2)	; copy main object position to bullet emitter
	move.w objectListY(a1),d0
	move.w d0,objectListY(a2)	; copy main object position to bullet emitter
emptyObj
	bra objectListNextEntry
tileAnim	; trig0 defines random or cycling tile animation

	; add "code trig1024" cycling animation
	; add "code trig1025" random animation

	tst.b objectListTriggers(a2)
	bne .random
	clr.w d7
	move.b objectListCnt(a2),d7
.anim
	lsr.b #3,d7
	andi.b #$7,d7
	move.b .tileAnim(pc,d7),d7
.applyFrame
	lea (a0,d7.w),a0
	lea killBounds(pc),a1
	bra killCheck	; check exit view
.tileAnim
	dc.b 2,4,6,8,8,6,4,2
	even
.random
	clr.w d7
	move.b objectListTriggers+1(a2),d7
	beq .idleAnim
	sub.b #1,objectListTriggers+1(a2)
	bne .anim
.setRnd
	lea     fastRandomSeed(pc),a1
	movem.l  (a1),d4/d5					; AB
	swap    d4						; DC
	add.l   d4,(a1)					; AB + DC
	add.l   d5,4(a1)				; CD + AB
	andi.b #$1f,d4
	lsl #1,d4
	add.b #10,d4
	move.b d4,objectListCnt(a2)
	bra .idleAnim
.idleAnim
	clr.w d7
	move.b objectListCnt(a2),d7
	andi.b #1,d7
	lsl #1,d7
	bra .applyFrame

basic1w8frame30fps
	move.b objectListCnt(a2),d7
	lsr.b #1,d7
	andi #$f<<1,d7
	lea (a0,d7.w),a0
	bra animReturn
basic2w16frame30fps
	move.w frameCount+2(pc),d7
	lsl.b #1,d7
	andi #$f<<2,d7
	lea (a0,d7.w),a0
	bra animReturn
basic1w2frame60fps
	;bra animReturn
	move.b objectListCnt(a2),d7
	andi.w #1,d7
	lea (a0,d7.w*2),a0
	btst.b #attrIsKillBorderExit,objectListAttr(a2)	; killcheck bit set?
	beq animReturn	; no
	lea killBounds(pc),a1
	bra killCheck	; check exit view
basic3w2frames5fps	; this is used by extra weapon carrier object only
	;tst.b optionStatus(pc)
	;bmi .noAnim	; diff is high? No extra icon

	move.w objectListX(a2),d7
	lsr.w #5,d7
	andi.w #2,d7
	move.w d7,d0
	lsr.w #1,d0
	add.w d0,d7
	lea 6(a0,d7.w*2),a0
.noAnim

	btst.b #attrIsKillBorderExit,objectListAttr(a2)	; killcheck bit set?
	beq animReturn	; no

emptyKil	; empty object, but killed at the edge
	lea killBounds(pc),a1
	bra killCheck	; check exit view

;	#MARK: - Hybrid Sprite - can run dedicated blitter object code while then delegating draw process to sprite code

;	Define a Bob in Objects-List, so this is called from bob management code, but returns to sprite management code at the end of bob custom code section. Used to display alert sprites, and refresh their position independent from scrolling pace

hybridSprite
	tst.b objectListTriggersB(a2)
	bne .skipSetup
	move.w objectListY(a2),d7
	sub.w viewPosition+viewPositionPointer(pc),d7
	move.w d7,objectListTriggers(a2)
	st.b objectListTriggersB(a2)
.skipSetup
	move.w objectListTriggers(a2),d7
	add.w viewPosition+viewPositionPointer(pc),d7
	move.w d7,objectListY(a2)
	move.l a4,d0
	sub.l objectDefs(pc),d0	; this works only if hybrid sprite objects are at the top of the object def list. Else need to modify this code / sprite number offset

	lsr #4,d0
	add.w #38,d0
	bra hybridSpriteJumpin


;	#MARK: - Double Claw  - object triggers Trig+3 if hit, and if close to player

doblClaw
	tst.b objectListTriggers+3(a2)
	beq .noHit
	move.w a2,d7
	sub.w frameCount+2(pc),d7
.animate
	andi #$f<<1,d7
	lea (a0,d7.w),a0
	lea killBounds(pc),a1
	bra killCheck	; check exit view
.noHit
	move.w objectListTriggersB(a2),d0
	beq .init
	cmp.w objectListHit(a2),d0
	bne .firstHit
.firstHitRet
	move.w objectListX(a2),d0	; get exit x-accl related to x-pos player
	sub.w	plyBase+plyPosX(pc),d0
	sub.w #$b9,d0
.notClose
	move.w a2,d7
	sub.w frameCount+2(pc),d7
	lsr.b #2,d7
	bra .animate
.firstHit
	st.b objectListTriggers+3(a2)
.init
	move.w objectListHit(a2),objectListTriggersB(a2)
	lea     fastRandomSeed(pc),a1
	movem.l  (a1),d0/d4					; AB
	swap    d4						; DC
	add.l   d4,(a1)					; AB + DC
	add.l   d0,4(a1)				; CD + AB
	clr.w d5
	move.b d4,d5
	asr.b #2,d5
	ext.w d5
	move.w d5,objectListAccX(a2)	; apply little bit of x-inertia to create "minefield"-emotion
	bra .firstHitRet


		;	#MARK: - check proximity

checkProximity
	; 	a2 		->	objectList adress
	; 	->		d0 	distance. Followup with
	;	cmpi.w #21,d0, bhs .noHit

	lea plyBase(pc),a1   ; calculate distance to player using manhattan method
	tst plyCollided(a1)	; is already dying
	bne.w .noHit
	
	move #-200,d0
	add.w objectListX(a2),d0
	add.w plyPosXDyn(a1),d0
	sub.w plyPosX(a1),d0
	smi d6
	ext.w d6
	eor.w d6,d0

	moveq #-5,d6
	add.w objectListY(a2),d6
	sub plyPosY(a1),d6
	smi d5
	ext.w d5
	eor.w d5,d6
	add d6,d0
.noHit
	rts



		;	#MARK: - exitKill - kill object on viewexit
		; 	trigger code either by jumping here after animcode has been processed
		; 	or activate by adding "code exitKill" to animlist

killCheck	; general check if object leaves view. a1 contains pointer to xbounds.w & ybounds.w
	tst.l objectListMyParent(a2)
	bne animReturn
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
	move.l emtyAnimAnimPointer(pc),a4
	move.w animTablePointer+2(a4),d4
	move.w d4,(a2)
	move.b #1,objectListCnt(a2)
	;move.b #1,objectListLoopCnt(a2)
	bra objectListNextEntry
.bounds	; x&y-bounds
killBounds
	dc.w $90,$1d0
	dc.w -$60,$110
killBoundsWide
	dc.w $70,$1f0
	dc.w -$90,$110
	
modifyObjCountAnim	; spawned new object in customcode? Check if  loopcounter needs modification
	cmpa.l a2,a1	; A6=current object, a4=new object. Is new object position higher in objList than parent ? If true -> objCounter=+1
	shi d4
	and.b #1,d4
	add.b d4,d3	; adjust objCounter
	rts



;	#MARK: - mergeObjectToBitmap - copy blitter object to bitmap using cpu-based cookiecut

	;	->	d1 	height of object
	;	->	a0 	pointer to object bitmap
	;	->	a1	pointer to background bitmap
	;	->	a2	pointer to source mask
	;	-> 	a3	source modulus
mergeObjectToBitmap
	lea mainPlaneWidth,a4
.drawMain
	moveq #3,d0
.drawToPlane					; copy object to bitplanes
		movem.l (a1),d2/d4		; fetch background
		movem.l (a0),d5/d6		; fetch object bitmap data
;		cmpi #3,d0
;		bne .sss
		;moveq #-1,d5
		;moveq #-1,d6
.sss
		movem.l (a2),d3/d7		; fetch cookie
		not.l d3
		and.l d3,d2	; mask source
		or.l d5,d2

		not.l d7
		and.l d7,d4	; mask source
		or.l d6,d4
		movem.l d2/d4,(a1)
		adda.l a3,a0
		adda.l a3,a2
		adda.l a4,a1
	dbra d0,.drawToPlane
	dbra d1,.drawMain
	rts


	 ; wipe bitmap, 20 lines per call, using noise filter for dithering
	 ;	->	d7 	starting line
	 ;	->	d3	if true (-1), wipe all bitmaps. If false (0), wipe current Aysnc Bitmap
wipeBitmap

.oneScanline	SET 	mainPlaneDepth*mainPlaneWidth/40
.delScanlines SET 32
	clr.w d0
	st.b d0
	sub.b d7,d0
	beq .wipeBitmapQuit

	;moveq #$5,d2
	;ror.w #3,d2	; (mainPlaneWidth*mainPlaneDepth)*256
	move.l #(mainPlaneWidth*mainPlaneDepth)*256,d2
	tst.b d3
	bne .wipeAllBitmaps
	move.l mainPlanesPointerAsync(pc),a1
	lea (a1),a3
	bra .skip
.wipeAllBitmaps
	move.l mainPlanesPointerAsync(pc),a1
.skip
	clr.l d7
	move.w d0,d7
	move.w AddressOfYPosTable-2(pc,d7.w*2),d7

	lea (a1,d7.l),a1

	lea noiseFilter+7*4(pc),a0
	move.l fxPlanePointer(pc),a6
	move.l mainPlaneOneSize(pc),d7	; get full size of one mainPlane
	lsr.l #1,d7
	neg.l d7
	lea -(.delScanlines*mainPlaneWidth*mainPlaneDepth)(a6,d7.l),a6	; set pointer to end of mainPlanesMemory

	move #.delScanlines,d3
	move d0,d7
	add d3,d7
	sub #256,d7
	bmi .delAllScanlines
	sub d7,d3		; do not process scanlines below lower border
.delAllScanlines
	move.l (a0),d4	; visual filter = 0? Keep deleting stuff!
	beq .keepDeleting
	lea -4(a0),a0
.keepDeleting
	cmpa.l a6,a1	; memory overflow area? If yes clr d2 to not write to twin screen buffer
	blo .nextRow	;	A1HigherSameThanA6
.clearD2
	clr.l d2
.nextRow
	move #.oneScanline-1,d7
.filterOneScanline
	REPT 10
	move.l (a1),d0
	and.l d4,d0
	move.l d0,(a1,d2.l)
	move.l d0,(a1)+
	ENDR
	dbra d7,.filterOneScanline
	dbra d3,.delAllScanlines
.wipeBitmapQuit
	rts



	IFNE 0
;	#MARK: - get animation frame angle from x- and y-acceleration

	;	d7 -> 	angle. Add 	move.b (tanTable.w,pc,d7),d4 to get frame sheet offset for 16px wide bobs
getAnimFrameAngle
	move.w objectListAccX(a2),d6
	asr.w #5,d6
	spl d5
	andi.b #$1f,d5
	add.w #$12,d6
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
	asr.w #5,d5
	add.w d5,d6

	move.l viewPosition+viewPositionAdd(pc),d5
	move.l d5,d4
	lsl.l #3,d5
	lsl.w #1,d4
	add.w d4,d5	; *12
	swap d5
	not d5
	add d6,d5

	spl d4
	andi.b #$1f,d4
	add.w #$14,d5
	cmpi.b #$20,d5
	scc.b d0	;-1 if out of range
	and.b d0,d4
	not.b d0
	and.b d0,d5
	or.b d4,d5
	andi #%11111,d5
	lsl #5,d5
	add.w d5,d7
	rts
	ENDIF
