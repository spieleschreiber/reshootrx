    ;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter bitmap load adress or use a0 if return to bobblitnext / not animreturn
	; launchTable attrib opaque needs to be set
	;	trig1025	init FadeIn
	;	trig1281	apply secondary animation
	;	trig3 bit0 spawn type:	0 = spawn in, 1=spawn out. add "trig1792" or "trig1793" to animlist
stealthz
	bsr animateStealth
	lea killBounds(pc),a1
	bra killCheck
animateStealth
	move.l objectListX(a2),d6
	lsl.l #3,d6
	swap d6
	tst.w objectListAccX(a2)
	beq .zeroXAcc
.updateBitmap
	andi #$7<<2,d6
	lea (a0,d6.w),a0
	rts
.zeroXAcc	; rotation synced to screenposition
	cmpi.w #$130,objectListX(a2)
	scc d5
	move.w frameCount+2(pc),d0
	eor.w d5,d0
	add.w d0,d6
	bra .updateBitmap
stealthy
	bsr animateStealth
	tst.b objectListTriggers(a2)
	sne d5

	clr.w d4
	move.b objectListCnt(a2),d4
	btst.b #0,objectListTriggers+3(a2)	; bit1 = true? Spawn Out
	sne d0
	andi.b #63,d0
	;ext.w d0
	eor.b d0,d4
	lsl #2,d4
	eor.b d5,d4
	lsr #4,d4
	;move #15,d4
.drawSpawnAnimation
	
	move.l noiseFilter+2(pc,d4*2),d4
	SAVEREGISTERS
	lea	fastRandomSeed(pc),a3
	lea 32(a0),a1	; load cookie adress into a1

.cookieOffset	SET 64
	moveq #29,d6
.fetchNextLine
	moveq #3,d7
	move.l	(a3),d1					; AB
	move.l	4(a3),d2				; CD
	swap	d2						; DC
	add.l	d2,(a3)					; AB + DC
	add.l	d1,4(a3)				; CD + AB
.fetchOneLine
	move.l	(a0),d0
	or.l .cookieOffset(a0),d0
	or.l .cookieOffset*2(a0),d0
	or.l .cookieOffset*3(a0),d0	; generate cookie
	rol.l	d1,d4
	and.l	d4,d0
	rol.w #2,d4
	move.l d0,(a1)
	move.l d0,.cookieOffset(a1)	; write modified cookie
	move.l d0,.cookieOffset*2(a1)
	move.l d0,.cookieOffset*3(a1)
	dbra d7,.fetchOneLine
	lea 64*4(a0),a0
	lea 64*4(a1),a1
	dbra d6,.fetchNextLine
	RESTOREREGISTERS
.flightAnim
	lea killBounds(pc),a1
	bra killCheck
;	bra animReturn
	IF 0=1	; code not needed as launch is imminent, not related to cloud position
.hideInSky
	move.w #$1a4,d6
	tst.b objectListX(a2)
	bne .isRight
	sub.w #$cc,d6
.isRight
	sub.w plyPos+plyPosXDyn(pc),d6
	move.w d6,objectListX(a2)
	moveq #1,d4
	bra .drawSpawnAnimation


.scanSky
	move.w objectListAccY(a2),d7
	;MSG02 m2,d7

	move.w viewPosition+vfxPosition(pc),d7
	neg.w d7
	lsr #4,d7
	andi #$7e,d7
	cmpi #$1c,d7
	bne .keepParked
	clr.w objectListAccY(a2)
	st.b objectListTriggers(a2)

	bra animReturn
.keepParked
	move.w viewPosition+viewPositionAdd(pc),d6
	lsl #7,d6
	move.w d6,objectListAccY(a2)
	move.b #2,objectListCnt(a2)
	bra animReturn
	ENDIF

