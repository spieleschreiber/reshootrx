;//
;//  sanityCheck.s
;//  px
;//
;//  Created by Richard Löwenstein on 14.07.23.
;//  Copyright © 2023 spieleschreiber. All rights reserved.
;//
	IFNE SANITYCHECK
objectSanityCheck

	lea .objCount(pc),a0	; reset display text
	move.w #"00",2(a0)
	move.w #"00",8(a0)
	move.w #"00",14(a0)


	; check number of shots

	clr.l d7
	move.l objectList(pc),a6
	move.w #shotsMax-1,d6
.loopAllShots
	tst.w (a6)
	beq.b .emptySlotShots
	add.w #1,d7
.emptySlotShots
	lea 4(a6),a6
	dbra d6,.loopAllShots
	tst.w d7
	beq .zeroShots
.buildSprNum
	divs #10,d7
.skip
	add #"0",d7
	move.b d7,2(a0)
	swap d7
	add #"0",d7
	move.b d7,3(a0)
.zeroShots

	; check number of objects w/o shots

	clr.l d7
	move.l objectList+4(pc),a6
	move.w #tarsMax+shotsMax-1,d6
.loopAllTars
	tst.w (a6)
	beq.b .emptySlotTars
	add.w #1,d7
.emptySlotTars
	lea 4(a6),a6
	dbra d6,.loopAllTars

	tst.w d7
	beq .zeroTars
.retLoopB
	divs #10,d7
	add #"0",d7
	move.b d7,8(a0)
	swap d7
	add #"0",d7
	move.b d7,9(a0)
.zeroTars


	; check number of all objects

	clr.l d7
	IFNE 0
	move.l objectList+4(pc),a6
	move.w #tarsMax+shotsMax-1,d6
.loopAllObjs
	tst.w (a6)
	beq.b .emptySlotObjs
	add.w #1,d7
.emptySlotObjs
	lea 4(a6),a6
	dbra d6,.loopAllObjs
	ENDIF

	move.w objCount(pc),d7
	tst.w d7
	beq .zeroObj
	divs #10,d7
	add #"0",d7
	move.b d7,14(a0)
	swap d7
	add #"0",d7
	move.b d7,15(a0)
.zeroObj


.print
    move.w #120,d0	; x-pos at the very right
    move.w #237,d1	; y-pos at the very bottom
    move.l mainPlanesPointer+8(pc),a5
    lea 40(a5),a5
    bsr wrtTextOnePlane
	move.l mainPlanesPointer+8(pc),a5
	lea (mainPlaneWidth*mainPlaneDepth*243)(a5),a5
    lea 56(a5),a5
	move.w #3,d7
.clear
	move.l #-1,(a5)+
	dbra d7,.clear
    bra.b .contB
.objCount
	dc.b "SHAA LSTAA CNTAA",0
	even
.contB
	rts
	ENDIF

