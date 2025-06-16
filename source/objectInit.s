
    ; #MARK: - OBJECT INIT RUNTIME

		; -> d3 	false/0 = sprite, true/$ff=bob
		; -> d4 	AnimList-Address
		; -> d5/d6 	x/y-coordinates
            ; d6 returns errorcode -1 if too many objects

    ;objectListAttr attribs:
    ;bit 0 = $01 = no background refesh (useful for static anim objects). Set label refr in object@map
    ;bit 1 = $02 = object is killed if exits screen
    ;bit 2 = $04 = object belongs to one group of objects
    ;bit 3 = $08 = available
    ;bit 4 = $10 = available
    ;bit 5 = $20 = bob not hitable e.g. explosion. sprite is never hitable.
    ;bit 6 = $40 = opaque flag. Override potential cookieblit, force copyblit. If sprite->attach bonus icon
    ;bit 7 = $80 = sprite; 0 = bob








objectInitOnTopOfSelf	; alternative jumpin for object init. Does not alter pointer to earliest available object (objectList+8)
.browseObjList	; jump-in to spawn object ranked higher/displayed on top of current object
	lea			4(a4),a4
	tst.w		(a4)
	beq.s		.foundSlot
	lea			4(a4),a4
	tst.w		(a4)
	beq.s		.foundSlot
	lea			4(a4),a4
	tst.w		(a4)
	beq.s		.foundSlot
	bra			.browseObjList
.foundSlot
	cmp.l		objectList+8(pc),a4
	bls			.return
	move.l		a4,objectList+8									; only update if current object is higher than old one
.return
	bra			writeObject
objectInitShot
	move.l		objectList(pc),a4
		;	load fixed pointer to object data table shot objects -> a4
	tst.w		(a4)
	beq			writeObject

.animsrchlistShotB
	lea			4(a4),a4
	tst.w		(a4)
	beq			writeObject
	lea			4(a4),a4
	tst.w		(a4)
	beq			writeObject
	lea			4(a4),a4
	tst.w		(a4)
	bne.s		.animsrchlistShotB
	bra			writeObject

objectInit	; launch in runtime, not from launch list
            ; handle ONLY attrib.b and hitpoint.w by code after init
	; destroys a1,a4,d3,d4,d5,d6
	IFNE		DEBUG
	ext.w		d3
	tst.b		objectWarning+1(pc,d3.w)
	bne			tooManyObjects
	ENDIF

	movem.l		objectList+4(pc),a1/a4

	;	load fixed pointer to object data table, non-shot objects -> a1
	;	dynamic pointer ->	a4

	IFNE		DEBUG											; check if object pointer does not corrupt shot reserved space
	cmp.l		a1,a4
	bcc			.allOkay
	IFNE		SHELLHANDLING
	jsr			shellObjListRuntimeError
	ENDIF
	QUITNOW
.allOkay
	ENDIF


	;lea objectListEntrySize-(shotsMax*4)-4(a1),a1
;.animsrchlist
	tst.w		(a4)
	beq.s		obInitfoundSlot
obInitanimsrchlistB	; jump-in to spawn object ranked higher/displayed on top of current object
	lea			4(a4),a4
	tst.w		(a4)
	beq.s		obInitfoundSlot
	lea			4(a4),a4
	tst.w		(a4)
	beq.s		obInitfoundSlot
	lea			4(a4),a4
	tst.w		(a4)
	bne.s		obInitanimsrchlistB
obInitfoundSlot
	lea			4(a4),a1
	move.l		a1,objectList+8									; store earliest object entry slot
writeObject
	cmpi.w		#tarsMax+bulletsMax+shotsMax,objCount(pc)
	bhs			tooManyObjects
	swap		d5
	clr			d5
	move.l		d5,objectListX(a4)
	swap		d6
	move.l		d6,objectListY(a4)
	clr.l		objectListAcc(a4)

	move		d4,(a4)											; objectListAnimPtr - pointer to animDefinitions
	lea			objCount(pc),a1
	addq		#1,(a1)
	move.l		animDefs(pc),a1

	move.b		animDefCnt(a1,d4.w),d4
	lsl			#8,d4
	move.w		d4,objectListCnt(a4)							; lifespan.b, clr.b destroy

	clr.l		objectListMainParent(a4)						; clear parent pointer
	clr.l		objectListMyParent(a4)							; clear parent pointer
	clr.l		objectListMyChild(a4)							; clear child pointer
	moveq		#-1,d4
	sf.b		d4
	rol.l		#8,d4
	move.l		d4,objectListGroupCnt(a4)						; -1.w =objectListGroupCnt, 0.b=objectListLoopCnt, -1.b=objectListWaveIndx
	clr.l		objectListLaunchPointer(a4)						; clear launchListPointer
	clr.l		objectListTriggers(a4)							; clear triggers
	clr.l		objectListTriggersB(a4)							; clear triggers

	clr.l		d6												; object implemented, set flag
	rts
tooManyObjects
	moveq		#-1,d6
	rts

    ; #MARK: - OBJECT INIT LAUNCHLIST


objectInitLaunchList:           ; launch by lauchlist, not manually. Attribs and hitpoints taken care off
	move.w		objectWarning,a1

	movem.l		objectList+4(pc),a1/a4
	;	load fixed pointer to object data table, non-shot objects -> a1
	;	->	d6		OK	=	0; Failed	<>	0
	;	->	a4		dynamic pointer
	;	->	d3		object attrib flag


	lea			objectListEntrySize-8(a1),a1					; add offset for  overflow check
	ext.w		d3
	tst.b		objectWarning+1(pc,d3.w)
	bne			tooManyObjects
.animsrchlist
	moveq		#4,d3
	tst.w		(a4)
	beq.s		.foundSlot
.animsrchlistB
	lea			4(a4),a4
	tst.w		(a4)
	beq.s		.foundSlot
	lea			4(a4),a4
	tst.w		(a4)
	beq.s		.foundSlot
	lea			4(a4),a4
	tst.w		(a4)
	bne.s		.animsrchlistB
.foundSlot
	sub.l		a4,a1
	tst.l		a1
	bmi			tooManyObjects
	lea			4(a4),a1
	move.l		a1,objectList+8									; pointer to next available objectslot

	swap		d5
	clr			d5
	move.l		d5,objectListX(a4)
	swap		d6
	clr			d6
	move.l		d6,objectListY(a4)								; coords

	clr.l		objectListAcc(a4)
	move		d4,(a4)											; objectListAnimPtr - pointer to animDefinitions
	clr.w		d3
	move.b		launchTableHitpoints(a0),d3
	tst.b		optionStatus(pc)
	bmi			.storeHitpoint
	move.b		.hitTableEasy(pc,d3.w),d3
.storeHitpoint
	lsl			#2,d3
	move		d3,objectListHit(a4)							; bit 2-15=hitpoints. bits 0-1=hit-blink
	move.b		launchTableAttribs(a0),d3
	move.b		d3,objectListAttr(a4)							;
;noGroup
	lea			objCount(pc),a1
	addq		#1,(a1)
	move.l		animDefs(pc),a1
	move.b		animDefCnt(a1,d4.w),d4
	seq			d6
	sub.b		d6,d4											; add 1 incase of first entry duration=0 within animlist
	lsl.w		#8,d4
	move.b		#postDestroyLowDebris,d4						; basic destroy setting = 1 only if spawn by launchlist
	move.w		d4,objectListCnt(a4)							; set.b lifespan, clr.b destroy
	clr.l		objectListMainParent(a4)						; clear parent pointer
	clr.l		objectListMyParent(a4)							; clear parent pointer
	clr.l		objectListMyChild(a4)							; clear child pointer
	clr.l		objectListLaunchPointer(a4)						; clear launchListPointer
	clr.l		objectListTriggers(a4)							; reset object triggers
	clr.l		objectListTriggersB(a4)							; again
	clr.l		objectListGroupCnt(a4)
	st.b		objectListWaveIndx(a4)							; clear wave index ($ff)
	;clr.b objectListLoopCnt(a4)   ; clear LoopCnt
	clr.l		d6
	rts

.hitTableEasy	; alternative hitvalues for easy mode 
	dc.b		$00,$01,$01,$02,$02,$03,$03,$06					; $07
	dc.b		$05,$05,$05,$06,$06,$07,$08,$0a					; $0f
	dc.b		$0a,$0a,$0b,$0c,$10,$0d,$0e,$10					;	$17
	dc.b		$11,$12,$12,$13,$13,$14,$14,$15					;	$1f
	dc.b		$16,$16,$17,$17,$18,$19,$1a,$1a					;	$27
	dc.b		$1b,$1b,$1c,$1d,$1e,$1e,$1f,$1f					;	$2f
	dc.b		$24,$21,$21,$22,$23,$24,$25,$26					;	$37
	dc.b		$26,$27,$27,$28,$28,$29,$2a,$2b					;	$3f
	dc.b		$30,$30,$31,$31,$33,$33,$46,$35					;	$47
	dc.b		$36,$36,$37,$38,$39,$3a,$3a,$4f					;	$4f
	dc.b		$3b,$3b,$3c,$3d,$3e,$3e,$3f,$3f					;	$57
	dc.b		$40,$40,$41,$41,$42,$42,$43,$43					;	$5f
	dc.b		$60,$44,$45,$45,$46,$46,$47,$47					;	$67
	dc.b		$48,$48,$49,$49,$4a,$4a,$4b,$4c					;	$6f
	dc.b		$4d,$4d,$4e,$4e,$4f,$4f,$50,$50					;	$77
	dc.b		$51,$51,$52,$52,$53,$53,$54,$54		