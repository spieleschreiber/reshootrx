
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

   ;add.w plyPos+plyPosXDyn(pc),d6;;Convert absolute to relative Screenposition
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
	;sub.w plyPos+plyPosXDyn(pc),d4;Convert absolute to relative
	lsr					#3,d4										; get x-pos-byte

	add.w				AddressOfYPosTable-($2a*2)(pc,d5.w*2),d4	; add bitmap y-adress

	move.l				mainPlanesPointerAsync(pc),a3
	;move.l	mainPlanesPointer+8(pc),a3

	; use mainPlanesPointerAysnc instead for detection background detection, no objects
	; use mainPlanesPointer+8 instead for detection background detection and objects
	tst.b				(a3,d4.l)
	bne					.bckColKillBullet

.addedShotToColList
	add.w				plyPos+plyPosXDyn(pc),d6					;Convert absolute to relative

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
	;sub.w plyPos+plyPosXDyn(pc),d3;Convert absolute to relative
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

