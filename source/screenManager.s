

; #MARK: - SCREENMANAGER BEGINS

	; #MARK: screenmanagerlv0

screenManagerLv0
				move.l		spriteParallaxBuffer+8(pc),a1
				move.l		copSPR6PTH(pc),a5
				tst.l		a5
				beq			setVFXPointers
				move.w		viewPosition+viewPositionPointer(pc),d0

				move		d0,d1
				lsr			#1,d1
				sub			d1,d0
	;lsr #1,d0
				andi		#$ff,d0
				lsl			#4,d0

				lea			(a1,d0),a1
				move.l		a1,d1
				move.w		d1,2(a5)
				swap		d1
				move.w		d1,6(a5)																	; write sprite scroller source adress
	;clr.l d0

				bra			setVFX


	; #MARK: screenmanagerlv4

screenManagerLv4
				move.l		spriteParallaxBuffer+8(pc),a1
				move.l		copSPR6PTH(pc),a5
				tst.l		a5
				beq			setVFX
;Mmove.w viewPositionPointer(a3),d0
				move.w		vfxPosition(a3),d0
	;move d0,d1
				lsr			#5,d0
	;sub d1,d0
	;lsl #1,d0
				andi		#$ff,d0
				lsl			#4,d0
				lea			(a1,d0),a1
				move.l		a1,d1
				move.w		d1,2(a5)
				swap		d1
				move.w		d1,6(a5)																	; write sprite scroller source adress

				move.l		spriteParallaxBuffer+4(pc),a1
	;move.w viewPositionPointer(a3),d0
	;lsr #2,d0
	;move d0,d1
	;lsr #2,d1
	;sub d1,d0
	;andi #$ff,d0
	;lsl #4,d0
				lea			(a1,d0),a1
				move.l		a1,d1
				move.w		d1,2+8(a5)
				swap		d1
				move.w		d1,6+8(a5)																	; write sprite scroller source adress

setVFX
				move.l		fxPlanePointer+4(pc),d0
				clr.l		d7
				move.w		vfxPosition(a3),d7
				sub.w		vfxPositionAdd(a3),d7
				move.w		d7,vfxPosition(a3)
				andi.w		#$ff<<3,d7
				move.w		d7,d5
				lsl.w		#2,d7
				add.w		d5,d7																		; muls #40
				add.l		d7,d0																		; set vfx bitplane
				bra			screenManager

	; #MARK: screenmanagerlv5
screenManagerLv5
				bra			setVFX

	; #MARK: screenmanagerlv1
screenManagerLv1

				move.l		copSPR6PTH(pc),a5
				tst.l		a5
				beq			setVFXPointers
				move.l		spriteParallaxBuffer+8(pc),a1
				move.w		viewPosition+vfxPosition(pc),d0
	;lsr #3,d5
	;move.w viewPosition+viewPositionPointer(pc),d0
				lsr			#4,d0
				move		d0,d1
	;lsr #1,d0
				lsr			#1,d1
				sub			d1,d0
				andi		#$7f,d0
				lsl			#4,d0
				lea			(a1,d0),a1
				move.l		a1,d0
				move.w		d0,2(a5)
				move.w		d0,2+8(a5)
				swap		d0
				move.w		d0,6(a5)																	; write sprite scroller source adress
				move.w		d0,6+8(a5)																	; write sprite scroller source adress

				bra			setVFX


	; #MARK: screenmanagerlv2

screenManagerLv2
				move.l		spriteParallaxBuffer+8(pc),a1
				move.l		copSPR6PTH(pc),a5
				tst.l		a5
				beq			setVFXPointers

				move.w		vfxPosition(a3),d0
				move		d0,d1
				lsr			#3,d0
				andi		#$ff,d0
				lsl			#4,d0
				lea			(a1,d0),a1
				move.l		a1,d1
				move.w		d1,2(a5)
				swap		d1
				move.w		d1,6(a5)																	; write sprite scroller source adress
				bra			screenManagerVerticalSplit

; #MARK: screenmanagerlv3
screenManagerLv3


				move.l		spriteParallaxBuffer+8(pc),a1
				move.l		copSPR6PTH(pc),a5
				tst.l		a5
				beq			setVFXPointers
				move.w		viewPosition+viewPositionPointer(pc),d0

				move.w		vfxPosition(a3),d0
	;move.w viewPositionPointer(a3),d0
	;MSG02 m2,d0
	;move d0,d2
	;lsr #2,d2
	;and.w #$ff<<1,d2	; (s)lowest sprite layer

				move.w		d0,d1
				lsr			#3,d0
				lsr			#4,d1
				add.w		d1,d0																		; sync sprite-based floor scrolling to vfx scroller
	;add d1,d0	; middle sprite layer
				and.w		#$ff<<1,d0
				lea			(a1,d0*8),a1
				move.l		a1,d1
				move.w		d1,2(a5)
				swap		d1
				move.w		d1,6(a5)																	; write sprite scroller source adress

				move.w		vfxPosition(a3),d7
				sub.w		vfxPositionAdd(a3),d7
				move.w		d7,vfxPosition(a3)

				clr.w		d5

				move.w		frameCount+2(pc),d4
				asr			#3,d4
				andi		#$ff,d4

				andi		#$7f,d4
				move.b		sineTable(pc,d4.w),d5
				clr.w		d3
				move.w		#$100,d6
				sub.w		plyBase+plyPosX(pc),d6
				add.w		d6,d5
				lsr			#4,d5
				addx.b		d3,d3																		; 70ns x-pos (1/2 pixel)
				lsl			#3,d3
				lsr			#1,d5
				addx.b		d3,d3																		; 140ns x-pos (1 pixel)
				add.b		#$85,d5
				move.b		d5,19(a5)																	; write SPR6POS x-coord
				move.b		d3,4+19(a5)																	; write SPR6POS x-coord
				lea			copSpr6pos(pc),a4
				moveq		#2,d7
.loop
				move.l		(a4)+,a5
	;move #2,d6
				add.b		#6,d4
				andi.b		#$7f,d4
				move.b		sineTable(pc,d4.w),d5
				add.w		d6,d5
				lsr			#4,d5
				addx.b		d3,d3
				lsl			#3,d3
				lsr			#1,d5
				addx.b		d3,d3
				add.b		#$85,d5
				move.b		d5,3(a5)
				move.b		d3,7(a5)
				dbra		d7,.loop

screenManagerVerticalSplit

	; take care of lower view

				move.l		fxPlanePointer+4(pc),d0
				move.l		d0,d3
				clr.l		d7
				move.w		#127*40,d7
				add.l		d7,d0

				move.w		vfxPosition(a3),d7
				move.l		d7,d4
				clr.l		d6
				ror.l		#5,d7																		; set speed of anim
				smi			d6
				andi.w		#$01,d6
				move.w		mulsThis(pc,d6.w*2),d6
				sub.l		d6,d0																		; add scrolling to smoothen animation
				andi.w		#7,d7
				move.w		mulsThisXtr(pc,d7*2),d7
				add.l		d7,d0
screenManagerMirrorView
				move.l		bpl2modReversal(pc),a5
				clr.l		d7
				move.w		#fxPlaneWidth*1024,d7
				move		#fxPlaneDepth-3,d6
.setVFXPointers
				move		d0,4(a5)
				swap		d0
				move		d0,(a5)																		; update startadress of secondary plane
				lea			8(a5),a5
				swap		d0
				add.l		d7,d0
				dbra		d6,.setVFXPointers
				move		d0,4(a5)
				swap		d0
				move		d0,(a5)

	; take care of upper view

				move.l		d3,d0
				move.l		d4,d7
				ror.l		#5,d7																		; set speed of anim (needs to be 1 for desert, 3 for nautica stage)
				smi			d6
				andi.w		#$01,d6
				moveq		#0,d1

				add.w		mulsThis(pc,d6*2),d1

				add.l		d1,d0																		; add scrolling to smoothen animation
				neg			d7
				andi.l		#7,d7
				move.w		mod2(pc,d7*2),d7
				lsl.l		#2,d7																		; *4
				lsl.l		#5,d7																		;*128
				add.l		d7,d0

				clr.l		d7
				move.w		#fxPlaneWidth*1024,d7
				lea			copBPLPT+10,a5
				move		#fxPlaneDepth-3,d6
.setVFXPointersB
				move		d0,4(a5)
				swap		d0
				move		d0,(a5)																		; update startadress of secondary plane
				lea			16(a5),a5
				swap		d0
				add.l		d7,d0
				dbra		d6,.setVFXPointersB
				move		d0,4(a5)
				swap		d0
				move		d0,(a5)

				clr.l		d7
				move.w		vfxPosition(a3),d7
				sub.w		vfxPositionAdd(a3),d7
				move.w		d7,vfxPosition(a3)

				bra			smSkipVfxWrite
		;#FIXME: optimize code please. setVFX doubled a few times?
mulsThis
				dc.w		0,120
mulsThisXtr
				dc.w		0,40*128,40*128*2,40*128*3
				dc.w		40*128*4,40*128*5,40*128*6,40*128*7
mod2
				dc.w		240,280,0,40,80,120,160,200

_smEscalUpdateBPLPT
				pea			smEscalRet(pc)
smEscalUpdateBPLPT
				lea			copBPLPT+(8*6),a1
				move.w		2(a1),d1
				swap		d1
				move.w		6(a1),d1
.add			SET			(mainPlaneWidth*4*(escalateStart+escalateHeight-displayWindowStart-0))
				add.l		#.add,d1

				lea			copGameEscExitBPLPT+34,a1
				move		d1,4(a1)
				swap		d1
				move		d1,(a1)
				rts

setVFXPointers
				move.l		fxPlanePointer+4(pc),d0
				clr.l		d7
				move.w		frameCount+2(pc),d7
				add.w		frameCount(pc),d7
				add			#1,d7
				neg.b		d7
				rol.l		#2,d7
				sub.b		d5,d7																		; vfx playfield - speed of scrolling
				andi.w		#$ff,d7

				move.w		d7,d5
				lsl.w		#5,d7
				lsl.w		#3,d5
				add.w		d5,d7
				add.l		d7,d0																		; set vfx bitplane
; #MARK: screenmanager main

screenManager

;FIXME: Do two subcoplists with bplpt make sense? Probably not!

; write bplpt pointer visual plane to copsublist. Mainplane is written in blittermanager

				lea			copBPLPT+10,a5
				clr.l		d7
				move.w		#fxPlaneWidth*fxplaneHeight,d7
				move		#fxPlaneDepth-2,d6
.setVFXPointers
				move		d0,4(a5)
				swap		d0
				move		d0,(a5)																		; update startadress of secondary plane
				lea			16(a5),a5
				swap		d0
				add.l		d7,d0
				dbra		d6,.setVFXPointers
				move		d0,4(a5)
				swap		d0
				move		d0,(a5)

smSkipVfxWrite
tileRenderer
	; incase of escalation -> update bplpt7 @escal coplist
				tst.b		escalateIsActive(pc)
				bne			_smEscalUpdateBPLPT
smEscalRet

				lea			copBPLPT+(8*6),a1
				move.w		2(a1),d1
				swap		d1
				move.w		6(a1),d1
.add			SET			(mainPlaneWidth*4*(escalateStart+escalateHeight-displayWindowStart-0))
				add.l		#.add,d1

				lea			copGameEscExitBPLPT+34,a1
				move		d1,4(a1)
				swap		d1
				move		d1,(a1)


				clr.l		d1
				clr.l		d2
				clr.l		d3
				clr.l		d5

				IF			1=0
				move.l		viewPositionPointer(a3),d1
				swap		d1
				andi		#$ff,d1
				ALERT03		m2,d1
				ENDIF

    ;clr d1
    ;swap d1             ; d1 = add to mainPlane-pointer
	;move d1,d4		; save for later compare


;tileRenderer
				move.l		tilemapConverted(pc),a0
				move.w		viewPositionPointer(a3),d7													; calc pointer to tilemapConverted

				clr.w		d0																			; scroll offset modifier
				tst.l		viewPositionAdd(a3)
				beq			tilePointerModified															; scroll northwards?
				bpl			modifyTilePointer
tilePointerModified
				move		tileMapWidth(pc),d2
				lsr			#5,d7
				move		d7,d2
				lsl			#3,d7
				add			d2,d7																		; muls 9
				adda.w		d7,a0																		; source tile         ;

				lea			mainPlanes(pc),a1
				lea			mainPlanesPointer(pc),a6

				movem.l		(a1),d5-d7
				tst.b		blitterManagerFinished(pc)
				beq			.swapGfxBuffers
				exg.l		d5,d7
				exg.l		d6,d7
				movem.l		d5-d7,(a1)
.swapGfxBuffers
				move.b		viewPositionPointer+1(a3),d3
				move.w		AddressOfYPosTable(pc,d3*2),d1
				move.l		d5,a1
				move.l		d6,a2
				move.l		d7,a4
				add.l		d1,d6																		; d6 = mainplanePointer+4
				add.l		d1,d5
				add.l		d1,d7
				movem.l		d5-d7,(a6)

				bclr		#0,d3																		; modify mainPlanePointer for use in tile drawing code
				add.w		d0,d3
	;sub #4,d3
				andi.w		#$fe,d3
				move.w		AddressOfYPosTable(pc,d3*2),d1
				lea			(a1,d1.l),a1
				lea			(a2,d1.l),a2
				lea			(a4,d1.l),a4
				clr.l		d1



	;cmpi.w #1,frameCount+6(pc)
	;bgt screenManagerSmoothScroll	; if framerate >50 fps, scale y-scroll value
smoothScrollRet
				lea			plyBase(pc),a5

				tst			plyCollided(a5)																; ply death seq running? Do not modify x-scrolling
				bne			.noHorzScrolling
				move		#240,d7																		; x-scrolling based on ply x-position
				sub			plyPosX(a5),d7
				clr.w		d5
				move.b		killShakeIsActive(pc),d5
				bne			.addKillShakeX
.retKillShakeX
				move		d7,d5
				lsl			#2,d7
				add			d5,d7
				asr			#3,d7

				move.w		scrollXbitsTable(pc,d7*2),d1
				move		d1,copBPLCON1+2

				asr			#2,d7
				move		d7,plyPosXDyn(a5)
				not			d7
				move		d7,d1
				add			#viewRightClip,d7
				add			#viewLeftClip,d1
				movem.w		d1/d7,plyviewLeftClip(a5)													; dynamically modify left / right clipping
.noHorzScrolling

	;tst.l viewPositionAdd(a3)
	;beq screenManagerNil	; skip tile update if screen don´t scroll
	;bra irqRetScreenManager

; #MARK: screenmanager tiledrawing

				clr.l		d7
				moveq		#9,d1
.drawTileOffset=(mainPlaneWidth-tileWidth/8)+4
				lea			.drawTileOffset,a3
				moveq		#(tileHeight/2)-1,d6
				clr.l		d5																			; read tile

	; a1/a2/a4 contain mainPlanes pointer

				move		viewPosition+viewPositionPointer(pc),d6
				andi		#$1e,d6
				lsl			#4,d6																		; line offset within tile
.tileMemSize	=			(tileHeight-1)*tileWidth/2

				move.w		#.tileMemSize,d4
				sub			d6,d4
				move		d6,d4
		;eor.w #$1f0,d4
				move.l		tileSource(pc),a6
	;lea $130280,a6
				moveq		#$5,d5
				ror.w		#3,d5																		; (mainPlaneWidth*mainPlaneDepth)*256 = $a000
				move.l		#$0f0f0f0f,d6
				moveq		#8,d7
.getTile
				move.b		(a0)+,d0
				bmi			.mirrorVertical																; mirror on y-axis
				move.w		d4,d2

				btst		#6,d0																		; flip on x-axis
				sne			d1
				ext.w		d1
				andi		#$1f0,d1
				eor.w		d1,d2																		; set source adress
				andi.b		#-$20,d1
				add.b		#$10,d1
				extb.l		d1																			; extend .b to .l
				move.l		d1,-(sp)																	; set offset
				andi		#$3f,d0

				moveq		#9,d3
				lsl.w		d3,d0																		; modulus between each tile: 512.b
				lea			(a6,d0.w),a5																; tile source base
				lea			(a5,d2.w),a5																; add yoffset to source base

				REPT		2
				movem.l		(a5),d0-d3																	; load one line of one tile
				add.l		(sp),a5

				move.l		d0,(a1)																		; draw first bitmap to three framebuffers, main view
				move.l		d0,(a1,d5.l)																; secondary view
				add.l		a3,a1
				move.l		d0,(a2)
				move.l		d0,(a2,d5.l)
				add.l		a3,a2
				move.l		d0,(a4)
				move.l		d0,(a4,d5.l)
				add.l		a3,a4

				move.l		d1,(a1)																		; draw scnd bitmap to three framebuffers
				move.l		d1,(a1,d5.l)
				add.l		a3,a1
				move.l		d1,(a2)
				move.l		d1,(a2,d5.l)
				add.l		a3,a2
				move.l		d1,(a4)
				move.l		d1,(a4,d5.l)
				add.l		a3,a4

				move.l		d2,(a1)																		; ....
				move.l		d2,(a1,d5.l)
				add.l		a3,a1
				move.l		d2,(a2)
				move.l		d2,(a2,d5.l)
				add.l		a3,a2
				move.l		d2,(a4)
				move.l		d2,(a4,d5.l)
				add.l		a3,a4

				move.l		d3,(a1)
				move.l		d3,(a1,d5.l)
				add.l		a3,a1
				move.l		d3,(a2)
				move.l		d3,(a2,d5.l)
				add.l		a3,a2
				move.l		d3,(a4)
				move.l		d3,(a4,d5.l)
				add.l		a3,a4
				ENDR


.offset			SET			-(.drawTileOffset*8)+4														; even appearance of tiles
;.offset	SET 4	; uneven appearance
				lea			.offset(a1),a1
				lea			.offset(a2),a2
				lea			.offset(a4),a4
				move.l		(sp)+,d0
				dbra		d7,.getTile
				rts
.mirrorVertical
				move		d4,d2
				clr.l		d5

				btst		#6,d0
				sne			d5
				ext.w		d5
				andi.w		#$1f0,d5																	; set source address
				eor.w		d5,d2																		; reverse read order
				andi.w		#$20,d5
				move.l		d5,-(sp)																	; set offset

				andi		#$3f,d0
				moveq		#9,d1
				lsl.w		d1,d0																		; modulus between each tile: 512.b
				lea			(a6,d0.w),a5																; tile source base
				lea			(a5,d2),a5																	; add yoffset to source base

				move.w		#(mainPlaneWidth*mainPlaneDepth)*256,d5
.draw
				move.l		#$55555555,d3
				move.l		#$33333333,d2
				swap		d7
				move		#1,d7
.drawTwoLinesMirrored
				REPT		4
				move.l		(a5)+,d0
				move.l		d3,d1
				and.l		d0,d1
				eor.l		d1,d0
				add.l		d1,d1
				lsr.l		#1,d0
				or.l		d1,d0

				move.l		d2,d1
				and.l		d0,d1
				eor.l		d1,d0
				lsl.l		#2,d1
				lsr.l		#2,d0
				or.l		d1,d0

				move.l		d6,d1
				and.l		d0,d1
				eor.l		d1,d0
				lsl.l		#4,d1
				lsr.l		#4,d0
				or.l		d1,d0

				rol.w		#8,d0
				swap		d0
				rol.w		#8,d0

				move.l		d0,(a1)
				move.l		d0,(a1,d5.l)
				add.l		a3,a1
				move.l		d0,(a2)
				move.l		d0,(a2,d5.l)
				add.l		a3,a2
				move.l		d0,(a4)
				move.l		d0,(a4,d5.l)
				add.l		a3,a4
				ENDR
				sub.l		(sp),a5
				dbra		d7,.drawTwoLinesMirrored
				swap		d7

.offset			SET			-(.drawTileOffset*8)+4														; even appearance
;.offset	SET 4	; uneven appearance
				lea			.offset(a1),a1
				lea			.offset(a2),a2
				lea			.offset(a4),a4

				move.l		(sp)+,d0
				dbra		d7,.getTile
				rts
.addKillShakeX
				lea			killShakeIsActive(pc),a3
				sub.b		#1,(a3)
				move.b		.killShakeX(pc,d5.w),d5
	;lsr #2,d5
				ext.w		d5
				add.w		d5,d7
				bra			.retKillShakeX
.killShakeX
				dc.b		0,1,-1,1,-2,3,-4,5
modifyTilePointer
				move.w		#-1,d0
				add.w		#256,d7
				bra			tilePointerModified
screenManagerNil
				rts
	; scrolling bits predefined
scrollXbitsTable
.scrollCode		SET			0
.temp			SET			0
				REPT		256
;.scrollCode	SET	((.temp&$3c)>>2)|((.temp&$00)<<8)|((.temp&$c0)<<4)	; temp solution not using 1/4 pixel scrolling

.scrollCode		SET			((.temp&$3c)>>2)|((.temp&$03)<<8)|((.temp&$c0)<<4)							; this works on real hardware

;.scrollCode	SET	((.temp&$00)>>2)|(((.temp+0)&%00)<<8)|((.temp&$c)<<8)	; this works on emulation
				dc.w		.scrollCode
.temp			SET			.temp+1
				ENDR

