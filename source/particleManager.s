
; #MARK: - PARTICLE MANAGER BEGINS
particleManager
				lea			particleClear(pc),a6
				movem.l		particleDrawBase(pc),a4-a5
				lea			mainPlaneWidth*mainPlaneDepth(a4),a1
				lea			mainPlaneWidth*mainPlaneDepth(a5),a2
				clr.l		d4
.clrLoop
				move.w		(a6)+,d4
				beq.b		.allCleared
				move.b		(a4,d4.l),(a5,d4.l)
				move.b		(a1,d4.l),(a2,d4.l)
				bra.b		.clrLoop
.allCleared
;	clr.w (a3)
.draw

				lea			AddressOfYPosTable(pc),a0
				lea			particleBits(pc),a1
				lea			particleBitmapOffset(pc),a2
				lea			particleDrawBase(pc),a3
				movem.l		mainPlanesPointer+4(pc),a4/a5

				move.l		a5,(a3)
				move.l		a4,4(a3)
				lea			mainPlaneWidth*mainPlaneDepth(a4),a5
				lea			particleClear(pc),a3
				lea			particleTable-partEntrySize(pc),a6

				moveq		#7,d0
				clr.l		d1
				clr.l		d2
				clr.w		d3
				move		#240,d4																					; y-bounds
				move		#280<<4,d2																				; x-bounds
				clr.l		d5
				move.w		#partEntrySize,d6
				move		#particlesMaxNo-1,d7
				bra.w		.loop
.nextParticle
				lea			(a6,d6),a6
    ;lea partEntrySize(a6),a6
				move.w		(a6),d1																					; load x-Position
				bne			.drawParticle
.loop
				dbra		d7,.nextParticle
				clr.w		(a3)																					; mark end of particle clear list
				bra			irqDidParticleManager

.drawParticle
				move.b		partLifeCntdwn(a6),d3
				sub.b		d3,partLifetime(a6)																		; lifetime
				bcs.b		.killPart

				cmp			d2,d1
				bhi			.killPart																				; out of bounds left or right?

				move.b		partYPos(a6),d3																			; y-position
    ;move #200,d3
				cmp			d4,d3
				bhi.b		.killPart																				; out of bounds up or down?
				move		d1,d5
				lsr			#4,d5
				lsr			d0,d1																					; x-byte-offset
				and.w		d0,d5
				move.b		(a1,d5),d5																				; read particle definition
				add.w		(a0,d3*2),d1																			; add y bitmap offset

				move.b		partLifetime(a6),d3
				lsr.b		#6,d3
				add.w		(a2,d3.w*2),d1																			; add bitplane offset
				move.w		d1,(a3)+																				; bitmap byte restore pointer
				eor.b		d5,(a5,d1.l)																			; plot top line
				eor.b		d5,(a4,d1.l)																			; plot second line

				move.l		partXAccl(a6),d5																		; move particle
				add.l		d5,partXPos(a6)

				dbra		d7,.nextParticle
				clr.w		(a3)																					; mark end of particle clear list
				bra			irqDidParticleManager

.killPart
				clr.w		(a6)																					; delete
				dbra		d7,.nextParticle
				clr.w		(a3)																					; mark end of particle clear list
				bra			irqDidParticleManager

    ; particleTable a0, x-pos D3, y-pos D4, xacc D5, yacc d6
    ; 	x d3 (0-255) << 4
	;	y d4 (0-255) << 8
particleSpawn

				clr.l		d0

				lea			particleTable-partEntrySize(pc),a6

				lea			ptEnd-4(pc),a3

				move.w		d5,a1
				move.w		d3,a2
				moveq		#-1,d1
				lea			partEntrySize,a5
.readParticle
				move.l		(a0)+,d0
				beq.b		.noMoreParticles
				move.b		d0,d7

				ext.w		d7																						; y-acc
				asl			#3,d7
    ;move #-400,d7
				asr.l		#8,d0
				move.b		d0,d2
				ext.w		d2																						; x-acc

				move.w		d0,d3
				clr.b		d3																						; y-add
				swap		d0
				ext.w		d0
				lsl.l		#4,d0																					; x-add

				add.w		d0,a2
				add.w		d3,d4

				add.w		d2,a1
				add.w		d7,d6
.findSlot
				adda.w		a5,a6
				tst.w		(a6)																					; particle available?
				bne.b		.findSlot

				cmp.l		a3,a6
				bhi			.noMoreParticles

				move.w		a1,d5
				move.w		a2,d3
				swap		d3
				move		d4,d3
				swap		d5
				move		d6,d5
				movem.l		d3/d5,(a6)

				move.b		(a0)+,d1
				move.w		d1,partLifetime(a6)
				add			#1,a0
				bra.b		.readParticle
.noMoreParticles
				rts
emitterBulletHitsBck
				dc.b		0,0,-1,-12,21,0
				dc.b		-1,1,0,17,24,0
				dc.b		0,-2,-3,2,17,0
				dc.b		-1,-1,-5,-7,23,0
				dc.b		-1,3,5,-40,25,0
				dc.b		-1,-4,-10,90,20,0
				dc.l		0
emitterExtraLoss
				dc.b		0,0,-1,-127,8,0
				dc.b		-1,1,0,-127,12,0
				dc.b		0,-2,-3,80,9,0
				dc.b		-1,-1,-5,-40,5,0
				dc.b		-1,-4,-10,90,7,0
				dc.b		0,4,5,-90,9,0
				dc.b		2,4,-5,90,8,0
				dc.b		3,5,10,-70,10,0
				dc.b		-3,-5,-20,-70,8,0
				dc.b		2,3,10,-90,6,0
				dc.b		-2,-3,10,90,6,0
				dc.b		-4,7,10,90,6,0
				dc.b		4,-7,10,90,6,0
				dc.b		-1,0,-10,120,6,0
				dc.b		1,0,-10,120,6,0
				dc.b		0,-2,10,127,12,0
				dc.b		0,-2,10,-127,9,0
				dc.b		0,-2,-10,-127,3,0
				dc.l		0
emitterKillA
				dc.b		0,0,-1,-70,3,0
				dc.b		-1,1,0,-75,7,0
				dc.b		0,-2,-3,64,5,0
				dc.b		-1,-1,-5,-20,2,0
				dc.b		-1,-4,-10,70,3,0
				dc.b		0,4,5,-50,3,0
				dc.b		2,4,-5,38,4,0
				dc.b		3,5,10,-40,5,0
				dc.b		-3,-5,-20,-50,4,0
				dc.b		2,3,10,-50,3,0
				dc.b		-2,-3,10,50,3,0
				dc.b		-4,7,10,40,3,0
				dc.b		4,-7,10,60,3,0
				dc.b		-1,0,-10,73,3,0
				dc.b		1,0,-10,66,3,0
				dc.b		0,-2,10,78,5,0
				dc.b		0,-2,10,-63,4,0
				dc.b		0,-2,-10,-75,1,0
				dc.l		0
emitterKillB
				dc.b		-3,-4,-1,-60,1,0
				dc.b		0,-2,10,60,4,0
				dc.b		0,-2,10,-87,3,0
				dc.l		0
				dc.b		0,-2,-10,-77,1,0
				dc.b		-1,1,0,-60,3,0
				dc.b		0,-2,-3,50,2,0
				dc.b		-2,-3,10,40,2,0
				dc.b		-4,7,0,45,2,0
				dc.b		4,-7,-10,33,2,0
				dc.b		-1,-1,-5,-20,1,0
				dc.b		2,4,-5,30,3,0
				dc.b		3,5,10,-30,4,0
				dc.b		-3,-5,-20,-20,3,0
				dc.b		-1,-4,-10,30,2,0
				dc.b		0,4,5,-35,2,0
				dc.b		2,3,10,-31,2,0
				dc.b		-1,0,-10,30,4,0
				dc.b		1,0,-10,50,5,0
				dc.l		0
emitterKillC
				dc.b		3,4,15,-70,1,0
				dc.b		-3,-5,-20,30,3,0
				dc.b		-1,-4,-10,40,2,0
				dc.b		0,4,5,-40,2,0
				dc.b		2,4,-5,40,3,0
				dc.b		3,5,10,-50,4,0
				dc.b		-1,1,0,-66,3,0
				dc.b		0,-2,-3,56,2,0
				dc.b		-2,-3,10,45,2,0
				dc.b		-4,7,0,39,2,0
				dc.b		4,-7,-10,53,2,0
				dc.b		-1,-1,-5,-25,1,0
				dc.b		2,3,10,-40,2,0
				dc.b		-1,0,-10,50,4,0
				dc.b		1,0,-10,55,5,0
				dc.b		0,-2,10,65,4,0
				dc.b		0,-2,10,-85,3,0
				dc.b		0,-2,-10,-67,1,0
				dc.l		0
emitterHitA
				dc.b		-2,-2,1,-70,4,0
				dc.b		-3,-2,-4,-20,7,0
				dc.b		-3,-2,10,-10,8,0
				dc.b		1,2,-20,4,6,0
				dc.b		0,3,14,32,4,0
				dc.l		0
emitterHitB
				dc.b		-4,-4,-4,-85,4,0
				dc.b		-5,-2,9,-20,7,0
				dc.b		-2,-1,10,-21,9,0
				dc.b		1,3,-30,-17,8,0
				dc.b		0,4,2,19,5,0
				dc.l		0
emitterMetShower
				dc.b		-10,-10,-10,50,5,0
				dc.b		2,4,10,30,3,0
				dc.b		3,7,-2,14,4,0
				dc.b		5,3,-10,12,7,0
				dc.b		6,5,20,50,2,0
				dc.b		3,5,10,-40,4,0
				dc.b		-1,1,0,-70,3,0
				dc.b		0,-2,-3,35,4,0
				dc.b		-2,-3,10,50,6,0
				dc.b		-4,7,0,20,4,0
				dc.b		4,-7,-10,33,7,0
				dc.b		-1,-1,-5,-30,3,0
				dc.b		2,3,10,-50,2,0
				dc.b		-1,0,-10,60,1,0
				dc.b		1,0,-10,70,5,0
				dc.b		0,-2,10,65,7,0
				dc.b		0,-2,10,-77,4,0
				dc.b		0,-2,-10,-57,3,0
				dc.l		0

				RSRESET
partXPos		rs.w		1
partYPos		rs.w		1
partXAccl		rs.w		1
partYAccl		rs.w		1
partLifetime	rs.b		1
partLifeCntdwn	rs.b		1
partEntrySize	rs.w		1


particlesMaxNo	=	32
particleBits
				dc.b		%11000000,%00100000, %00110000,%00010000, %00001100,%00000110,%00000011, %00000001
particleBitmapOffset
				dc.w		mainPlaneWidth*3, mainPlaneWidth*2, mainPlaneWidth*1, mainPlaneWidth*1
particleBase
particleDrawBase
				dc.l		0,0,0
particleClear
				blk.w		particlesMaxNo+1,0
	; particleTable at end of code
particleTable
				blk.b		(particlesMaxNo+1)*partEntrySize,0

ptEnd
; #MARK: PARTICLE MANAGER ENDS