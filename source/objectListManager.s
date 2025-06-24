
; #MARK:  - OBJECT LIST MANAGER

objectListManager
; Eingangswerte:
    ;A2 =   objectList
    ;A3 =   bobpostab
    ;A4 =   objectDefinitionTable
    ;A5 =   pointer to vars
    ;A6 =   bobDrawList


	lea					animBasicOffsets(pc),a0						; predefine basic anim offsets
	move.b				AudioRythmAnimOffset(pc),d6
	andi				#$f,d6
	move				d6,(a0)

	lea					vars(pc),a5
	clr.w				spriteCount+2-vars(a5)						; 2.w = temp counter, static 1.w = static
	clr					shotCount-vars(a5)


	move.w				bobCountHitable-vars(a5),d0
	move.w				d0,bobCountHitable-vars+2(a5)
	clr					bobCountHitable-vars(a5)

	lea					memoryPointers(pc),a0
	move.l				collidingList+8-memoryPointers(a0),a6
	move.l				a6,collidingList-memoryPointers(a0)
	move.w				#collListBobOffset,d6
	adda.w				d6,a6
	move.l				a6,collidingList+4-memoryPointers(a0)

	move.l				bobDrawList+4(pc),a6

	move.l				objectList-memoryPointers(a0),a2
	subq.l				#4,a2

	move.w				viewPosition+viewPositionPointer(pc),d2

	move.l				spritePosMem-vars(a5),a0
	lea					spritePosMemSize-4(a0),a0
	move.l				a0,spritePosFirst							; reset mem pointer to sprite with lowest y-coord

	IFNE				DEBUG
	clr.l				spritePosLast
	ENDIF

	clr.w				bobCount+2-vars(a5)

	move				objCount(pc),d3
	bra					objectListNextEntry
bobBlitLoop
	moveq				#4,d0
.findObject
	lea					4(a2),a2
	move				(a2),d0										;objectListAnimPtr
	beq.b				.findObject

	lea					([animDefs-vars,a5],d0.w),a0
	clr.l				d4
	move.b				animDefType(a0),d4
	lea					([objectDefs,pc],d4.w*8),a4					; Pointer to animDefinitions


	move				objectDefAttribs(a4),d0						; fetch attribs and anim pointer

	tst.w				d0
	bpl					bobPrepareDraw								; draw sprite or bob?
;   ****
;   add object to sprite dma list
;   ****
	;ALERT01 m2,d0
; #MARK:  prepare sprite lists

hybridSpriteJumpin
	moveq				#-100,d6
	add					objectListX(a2),d6

	move.w				#30,d5
	add					objectListY(a2),d5

	tst.l				objectListMyParent(a2)
	bne					.isChild - add parents coords
.retChild

	IFEQ				1											; testing code which takes care of playershots y-pos / moving up / increased density on y-axis
	tst.w				plyBase+plyPosAcclY(pc)
	bpl					.22
	btst				#12,d0										; is shot?
	beq.b				.22
	clr.l				d7
	move				plyBase+plyPosAcclY(pc),d7
	ext.l				d7
;	ALERT01 m2,d7
	lsl.l				#8,d7
	lsl.l				#4,d7
	add.l				d7,objectListY(a2)
.22
	ENDIF

   ;add.w plyPos+plyPosYDyn(pc),d6;;Convert absolute to relative Screenposition
	move.l				.xbounds(pc),d1								; sprite within view?
	cmp					d1,d6
	bhi					.deleteSprite
	swap				d1
	cmp					d1,d6
	bls					.deleteSprite								; exited to left border


	;sprite
	sub.w				viewPosition+viewPositionPointer(pc),d5		; convert to absolute screenposition
	move.l				.ybounds(pc),d1
	cmp					d1,d5
	bge					.deleteSprite								; exited border down
	swap				d1
	cmp					d1,d5
	ble					.deleteSprite								; exited border up

	move				d5,d4										; scale to possible slot in y-order, factor 24
	lsl					#3,d4										;
	move.l				spritePosMem-vars(a5),a0
.spriteSort

	tst					(a0,d4.w)
	bne					.forceSlot									; no empty slot? Force one!
.spriteSorted
	lea					(a0,d4.w),a0
	btst				#12,d0										; is shot?
	bne					.addShotToColList							; yes - add to shot collission list
	; check bullet background collission

	tst.b				objectListTriggers+3(a2)
	beq					.addedShotToColList
	move.w				d6,d4
	sub.w				#$1c,d4
	;sub.w plyPos+plyPosYDyn(pc),d4;Convert absolute to relative
	lsr					#3,d4										; get x-pos-byte

	add.w				yBecomesAddress-($2a*2)(pc,d5.w*2),d4	; add bitmap y-adress

	move.l				mainPlanesPointerAsync(pc),a3
	;move.l	mainPlanesPointer+8(pc),a3

	; use mainPlanesPointerAysnc instead for detection background detection, no objects
	; use mainPlanesPointer+8 instead for detection background detection and objects
	tst.b				(a3,d4.l)
	bne					.bckColKillBullet

.addedShotToColList
	add.w				plyPos+plyPosYDyn(pc),d6					;Convert absolute to relative

	andi				#$3f,d0										; sprite type
	ror					#6,d0
	or					d0,d6
	movem.w				d5/d6,(a0)
	addq				#1,spriteCount+2-vars(a5)
	;add #1,spriteCount+2
	cmpa.l				spritePosFirst-vars(a5),a0
	bhi.b				.refreshFirstYpos
	move.l				a0,spritePosFirst-vars(a5)					; only store if new address is lower than old
.refreshFirstYpos

	IFNE				DEBUG
	cmpa.l				spritePosLast-vars(a5),a0
	bls.b				.refreshLastYpos
	move.l				a0,spritePosLast-vars(a5)					; pointer to highest sprite adress
.refreshLastYpos




	; check for memory overflow
	move.l				spritePosMem-vars(a5),a1
	cmpa.l				a1,a0
	bls					.spriteError
	lea					spritePosMemSize-12(a1),a1
	cmpa.l				a1,a0
	bhi					.spriteError
	ENDIF
.eofSpriteLoop
	dbra				d3,bobBlitLoop
.eofSpriteList
	bra					objectListQuit
.forceSlot
; sprite sorter looks for free slot. if not available, find next free slot with. Upto 4 sprites with same y-coord
;    bra.w objectListNextEntry
 ;   moveq #3,d7
.findNiceSlot
	addq				#4,d4
	move				(a0,d4),d1
	beq					.spriteSorted
	cmp					d5,d1
	bls					.findNiceSlot
	bra.w				objectListNextEntry
.addShotToColList
	move.l				collidingList-vars(a5),a1					;yes -> write to collission list
	move.l				a2,(a1)
	andi				#$1f,d0
	move				d0,d7
	movem.w				d5/d6/d7,collTableYCoords(a1)				; write pure y-coord and x-coord to coll list (handling a little bit different for shots for optimized memory access). Write sprite number too
	moveq				#collListEntrySize,d7
    ;lea collidingList(pc),a1
	add.l				d7,collidingList-vars(a5)
	addq				#1,shotCount-vars(a5)
	bra					.addedShotToColList

.bckColKillBullet	; Bullet hit background - trigger particles, init bullet death

	sf.b				objectListTriggers+3(a2)					; kill collission detection
	SAVEREGISTERS

	move.l				bascShtXAnimPointer(pc),a3
	move.w				animTablePointer+2(a3),(a2)					; switch to bullet death anim

	move.b				#1,objectListCnt(a2)						; set anim count manually for first frame

	; add particle system
	moveq				#-27,d3
	add.w				d6,d3
	;sub.w plyPos+plyPosYDyn(pc),d3;Convert absolute to relative
	lsl					#4,d3										; set x-pos

	moveq				#-40,d4
	add.w				d5,d4
	lsl					#8,d4										; set y-pos
	clr.w				d6											; no x- and y-inertia
	clr.w				d5

	lea					emitterBulletHitsBck(pc),a0
	bsr					particleSpawn								; call particleEmitter

	RESTOREREGISTERS
	bra					.addedShotToColList

	IFNE				DEBUG
.spriteError
	IFNE				SHELLHANDLING
	jsr					shellSpriteMemError
	ENDIF
	QUITNOW
.memCorrupt
	ENDIF
.xbounds
	dc.w				20,320
.ybounds
	dc.w				32,295

.isChild
	move.l				a2,a1										; is children object -> add all parent coords
.readParent
	move.l				objectListMyParent(a1),a1
	tst.l				a1
	beq					.retChild
	add.w				objectListX(a1),d6
	add.w				objectListY(a1),d5
	bra.b				.readParent

.deleteSprite
	tst.l				objectListMyParent(a2)
	bne					objectListNextEntry							; sprite is attached to parent object, let parent object do killjob
	move.l				emtyAnimAnimPointer(pc),a3
	move.w				animTablePointer+2(a3),(a2)
	move.b				#1,objectListCnt(a2)
	bra.w				objectListNextEntry

    ;!!!: Objectcode: code called each frame update. Usually used for bitmap animation, but can do other things too



; #MARK:  prepare blitter objects



;	moveq		#$1f,d0
;	ror			#5,d0

bobPrepareDraw
	move.l		(a4),a0									;objectDefSourcePointer
	adda.l		bobSource-vars(a5),a0					; Adress of sourcebitmap
	andi		#$ff,d0
	;TOSHELL		 "bobPrepareDraw",d0
	jmp			([(animCases).w,pc,d0.w*8])				; jump to specific anim code

;FIXME: Execute code only after draw-check
animReturn
	clr.l		d4
	clr.l		d7
	move.b		objectDefWidth(a4),d4					; bob-Width in pixels
	move		d4,d5
	move		d4,d7
	addq		#7,d4
	lsr			#3,d4
	addq		#1,d4									; bob-width for blitter

	clr.l		d6
	move		objectListX(a2),d6
	sub			d5,d6									; center x-position


	move		objectListY(a2),a3
	tst.l		objectListMyParent(a2)
	bne			bobBlitIsChild
bobBlitChildReturn

	move		objectDefModulus(a4),d1
;	move d6,d0	; d6 = center coord
;	sub d5,d0	; d0 = leftmost x-coord
	add			d6,d5									; d5 = rightmost x-coord

	move.l		collidingList+4(pc),a1
	move.l		a2,(a1)
	add.w		d5,d7
	movem.w		d6/d7,collTableXCoords(a1)				; left / right border

	; check left clipping
	move		plyBase+plyViewNorthClip(pc),d0
	cmp.w		d0,d6									;   bob outside left handside of view?
	ble			bobBlitCutLeft							; yes - cut!

    ; check right clipping
	move		plyBase+plyviewSouthClip(pc),d5
	cmp			d5,d7									;leaves screen to the right?
	bgt			bobBlitCutRight

bobBlitDidHorizontalClip

	move		d1,(a6)									;bobDrawBLTMOD
	clr.l		d0
	clr.l		d1
	clr.l		d5
	move.b		objectDefHeight(a4),d5
	move.b		d5,d0
	lsr			#1,d0

	move		a3,d1									; y-pos relative
	sub			d2,d1									; sub viewPositionPointer, get abs(y-pos)
	move		d1,d7
	add			d5,d7
	move.w		d1,collTableYCoords(a1)					; write y-coord left corner to collission table
	moveq		#spriteDMAHeight-2,d0
	add			d7,d0
	move.w		d0,collTableYCoords+2(a1)				; write y-coord right corner
				; d5 = bobhoee
				; d1 = bobypos

	;check clip view upper border
	move		#viewUpClip,d0
	cmp			d0,d1
	blt			bobBlitCutUp

	;check clip view lower border
	move.w		#viewDownClip,d0						; attn.! value modified in player manager
	cmp			d0,d7
	bhi			bobBlitCutDown

addToColTable
	btst.b		#attrIsNotHitable,objectListAttr(a2)
	bne.b		.notHitable
	moveq		#collListEntrySize,d7
	add.l		d7,collidingList+4-vars(a5)
	addq		#1,bobCountHitable-vars(a5)
.notHitable

	move.w		yBecomesAddress(pc,d1*2),d1			; get y-positions memory offset

	sub			#viewXOffset,d6
	move		d6,d0
	lsr			#3,d6

	subq.l		#4,d1
	add.l		d6,d1									; add x-position to mainplane pointer
	bclr		#0,d1

	move		d0,d7
	moveq		#$f,d6
	and.l		d6,d7
	beq			blitZeroX								; word-aligned blit, no pixelshift? Reduce blit size!

retBlitZeroX
	ror			#4,d7
	btst		#1,objectListHit+1(a2)					; stamp
	bne			hitDisplay
	or			#$0fca,d7
drawBob
	move.l		a0,bobDrawSource(a6)					; store source adress
	move.w		objectDefMask(a4),a0					; get source mask offset
	movem.w		d1/d7/a0,bobDrawTargetOffset(a6)		; store pointer to target adress, bltcon0, source mask offset,

	lsl			#8,d5									; x 4 for 4 bitplanes, add bob height to blit control word
	or			d5,d4

	IFNE		DISABLEOPAQUEATTRIB
	btst.b		#attrIsOpaq,objectDefAttribs(a4)
	bne			blitEnableOpaque
retblitEnableOpaque
	ENDIF

	IFNE		BLITNORESTOREENABLED
	btst		#attrIsOpaq,objectDefAttribs(a4)
	bne			bobIsOpaque
bobRetIsOpaque
	ENDIF
	move		d4,bobDrawBLTSIZE(a6)
	add			#1,bobCount+2-vars(a5)
	cmp.l		bobDrawList+16(pc),a6
	bcc			objectListQuit
	lea			bobDrawListEntrySize(a6),a6

objectListNextEntry
	dbra		d3,bobBlitLoop

objectListQuit
	clr.l		(a6)									;mark eof bobdrawlist

	; check amount of objects. If too many: forbid new objects spawning

	clr.w		objectWarning-vars(a5)
	move.w		spriteCount+2-vars(a5),d0
	move.w		d0,spriteCount-vars(a5)
	cmpi		#bulletsMax-1,d0
	bhi			issueWarningSprites

	move.w		bobCount+2-vars(a5),d0
	move.w		d0,bobCount-vars(a5)
	cmpi		#tarsMax,d0
	bhi			issueWarningBobs
	rts
blitZeroX
	sub			#1,d4									; modify blitsize
	add			#2,(a6)									; modify modulus
	bset		#15,(a6)								; flag for use in blittermanager
	bra			retBlitZeroX
hitDisplay
	bchg		#0,objectListHit+1(a2)
	btst		#0,objectListHit+1(a2)
	beq.b		.keepHitMarker2
	andi.b		#$fc,objectListHit+1(a2)
.keepHitMarker2
	or			#$0ffa,d7
	bra			drawBob

bobBlitIsChild
	move.l		a2,a1									; is children object -> add all parent coords
.readParent
	move.l		objectListMyParent(a1),a1
	tst.l		a1
	beq			bobBlitChildReturn
	add.w		objectListX(a1),d6
	add.w		objectListY(a1),a3
	bra.b		.readParent


bobBlitCutLeft
	move		d0,d7
	sub			d6,d7									; left hangover

	add.w		plyBase+plyPosYDyn(pc),d6
	andi		#$f,d6
	add			d0,d6
	add			#1,d6									; new x-coord

	lsr			#4,d7
	add			#1,d7
	sub			d7,d4									; new blit x-size
	cmpi		#2,d4									; x-blitsize < 2?
	blt			objectListNextEntry						; yes - out of view
	lsl			#1,d7									; only 2,4,6 ...
	add			d7,a0									; modify bitplane fetch adress
	add			d7,d1									; ... and modulo
	bra			bobBlitDidHorizontalClip
bobBlitCutRight
	sub			d5,d7
	lsr			#4,d7
	add			#1,d7
	sub			d7,d4
	cmpi		#2,d4									; x-blitsize < 2?
	blt			objectListNextEntry						; yes - out of view
	lsl			#1,d7
	add			d7,d1
	bra			bobBlitDidHorizontalClip

bobBlitCutUp
	sub			d0,d1
	;sub #3,d1
	neg			d1
	sub			d1,d5
	ble.w		objectListNextEntry
    ;add.l (a1,d1*4),a0
	clr.w		d0
	move.w		objectDefModulus(a4),d0
	addq		#2,d0
	clr.w		d7
	move.b		objectDefWidth(a4),d7
	lsr.w		#2,d7
	add.w		d7,d0
	lsl.w		#2,d0
	muls		d0,d1
	adda.w		d1,a0									; modify source adress

	clr.l		d1
	move		#viewUpClip,d1							; topmost y-coord
	bra			addToColTable
bobBlitCutDown
	sub			d0,d7
	sub			d7,d5
	bmi.w		objectListNextEntry
	addq		#1,d5
	bra			addToColTable

	IFNE		DISABLEOPAQUEATTRIB
blitEnableOpaque
	bset		#15,bobDrawMaskOffset(a6)
	;sub.b #1,d4		; modify blitsize
	;add #2,(a6)		; modify modulus
	;cmpi.b #$ca,d7
	;beq retblitEnableOpaque
	move.l		a0,d0
	add.l		d0,bobDrawSource(a6)					; store source adress
	bra			retblitEnableOpaque
	ENDIF

	IFNE		BLITNORESTOREENABLED
bobIsOpaque
	bset		#15,d7
	bra			bobRetIsOpaque
	ENDIF

issueWarningSprites
	ALERT01		msgTooManySprites,spriteCount(pc)
	st.b		objectWarning+1-vars(a5)
	rts
issueWarningBobs
	ALERT01		msgTooManyObjects,bobCount(pc)
	st.b		objectWarning-vars(a5)
	rts


