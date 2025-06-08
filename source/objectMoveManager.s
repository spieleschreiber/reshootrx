
; #MARK: - OBJECT MOVE MANAGER

objectMoveManager

								move.l				animDefs(pc),a5																																																								; loaded at animlooper
								move.l				objectList(pc),a6
								moveq				#4,d2
								sub.l				d2,a6
								clr.l				d0
								moveq				#2,d2
								move.w				objCount(pc),d7

								bra					animLooper
animLoop
								moveq				#8,d4
.checkEntry
								lea					4(a6),a6
								move.w				(a6),d1																																																										;objectListAnimPtr
								beq.b				.checkEntry
.2
								movem.w				(a5,d1.w),d5/d6																																																								; Accelerate x and y - read from animDefAcc
								add.w				d5,objectListAccX(a6)
								add.w				d6,objectListAccY(a6)

								movem.w				objectListAccX(a6),d5/d6																																																					; movem.w sign extendeds automatically
								lsl.l				d4,d5
								add.l				d5,objectListX(a6)
								lsl.l				d4,d6
								add.l				d6,objectListY(a6)

.3
								subq.b				#1,objectListCnt(a6)
								beq.b				.stepEnds
								dbra				d7,.checkEntry

								bra					irqDidObjMoveManager																																																						; back to irq
.stepEnds
								lea					(a5,d1),a0
								move				animDefEndWaveAttrib(a0),d0
								cmpi.w				#$f0,d0
								bge.b				.initcode
.bobInitNextStep
								addq				#animDefSize,(a6)																																																							;objectListAnimPtr. No. init next animation step
.1
								move				(a6),d0																																																										;objectListAnimPtr
								move.l				animDefs(pc),a5
								move.b				animDefCnt(a5,d0),d0
								beq					.zeroCnt																																																									; cnt of 0 -> execute next step immediately

								move.b				d0,objectListCnt(a6)
								dbra				d7,animLoop

								bra					irqDidObjMoveManager																																																						; back to irq
.zeroCnt
								move.b				#1,objectListCnt(a6)
								move.w				(a6),d1																																																										;objectListAnimPtr
								moveq				#8,d4
								movem.w				(a5,d1.w),d5/d6																																																								; update x and y acceleration, but do not apply to object in case of immediate nextstepping to avoid undesired acceleration
								add.w				d5,objectListAccX(a6)
								add.w				d6,objectListAccY(a6)
								bra					.3
.initcode
								sub.w				#$f0,d0
								moveq				#animDefSize*2,d1
								jmp					((.codeCases).w,pc,d0*4)

.codeCases
								bra.w				.attrNext
								bra.w				.attrLoop
								bra.w				.attrXacc
								bra.w				.attrYacc
								bra.w				.attrXpos
								bra.w				.attrYpos
								bra.w				.attrTrig
								bra.w				.attrRept
.attrXacc
								add					d1,(a6)
								move				animDefNextWave(a0),objectListAccX(a6)
								bra.w				.1
.attrYacc
    ;add d1,(a6)
    ;move animDefNextWave(a0),objectListAccY(a6)
    ;bra.w .1

								add					d1,(a6)
								move				animDefNextWave(a0),d5
								tst.b				objectListAttr(a6)																																																							; incase of static onscreen y-launch position of copied objects, adjust y-acc to keep patterns similar to dynamic onscreen (scrolling) y-launch position
								bmi.b				.modifyYacc
								move.w				viewPosition+viewPositionAdd(pc),d6
								lsl					#7,d6
								neg.w				d6
								sub.w				d6,d5
.modifyYacc
								move				d5,objectListAccY(a6)
								bra.w				.1
.attrXpos
								add					d1,(a6)
								move.w				animDefNextWave(a0),objectListX(a6)
								clr.w				objectListAccX(a6)
								bra					.1
.attrYpos
								add					d1,(a6)
								clr.l				d5
								tst.l				objectListMyParent(a6)
								bne.b				.noChildX
								move				viewPosition+viewPositionPointer(pc),d5
.noChildX
								add					animDefNextWave(a0),d5
								move				d5,objectListY(a6)
								clr.w				objectListAccY(a6)
								bra.w				.1
.attrTrig           ; four triggers available
                    ; bits 8&9 determine triggerslot (256/512)
                    ; bit 10 determines global(0) or objectrelated(1) trigger (1024)
                    ; if trigger>128    -> pause animList until trigger<>0
                    ; if trigger<128    -> write value to trigger

								move.w				animDefNextWave(a0),d4
								move				d4,d5
								lsr					#8,d5
								btst				#2,d5
								bne.b				.objectTrigger
								lea					(animTriggers,pc),a5																																																						;globalTrigger
								bra.b				.triggerType
.objectTrigger
								lea					objectListTriggers(a6),a5
.triggerType
								andi				#3,d5
								tst.b				d4
								bpl.b				.noWait
								tst.b				(a5,d5)																																																										; pause animList
								beq					.1
	;clr.b d4
	;move.b d4,(a5,d5) ; unpause animList
								add					d1,(a6)																																																										; next anim step
								bra.w				.1
.noWait
								add					d1,(a6)																																																										; next anim step
								move.b				d4,(a5,d5)																																																									; write value to trigger
.wait
								bra.w				.1

.getNext
								add					d1,(a6)
								bra.w				.1

.attrRept
    ;clr objectListAccX(a6)
								move.w				animDefNextWave(a0),d4
								move.b				d4,objectListLoopCnt(a6)
								bra.w				.getNext
.attrLoop        ; loop endlessly if rept0
								tst.b				objectListLoopCnt(a6)
								beq.b				.endless
								sub.b				#1,objectListLoopCnt(a6)																																																					; else countdown
								beq.b				.getNext
.endless
								move.w				animDefNextWave(a0),d4
								sub					d4,(a6)
								bra.w				.1


								move.w				animDefNextWave(a0),d4
								sub					d4,(a6)
								move				(a6),d0																																																										;objectListAnimPtr
								move.l				animDefs(pc),a5
								move.b				animDefCnt(a5,d0),d0
;    beq .zeroCnt	; cnt of 0 -> execute next step immediately

								move.b				d0,objectListCnt(a6)
								dbra				d7,animLoop
								bra					irqDidObjMoveManager																																																						; back to irq




;    bra.w .1
.attrNext
								move.w				animDefNextWave(a0),d4
								cmpi.b				#$f0,d4
								beq.b				.animClrBob
										; execute individual code
								add					#animDefSize*2,(a6)																																																							;objectListAnimPtr
								cmpi.l				#$00f000f0,animDefSize(a0)																																																					; code was last entry? yes, then delete bob
								beq					.toLiveAndDie

								lea					.1(pc),a5
								jmp					([bobCodeCases,pc,d4])																																																						; continues at .1
.toLiveAndDie

;	btst.b #attrIsAvail,objectListAttr(a6)
;	bne .rrr

	;ALERTSETLINE 10
.lea							lea					.lea+6(pc),a5
								jmp					(a5)
.animClrBob							; clear main parent object

								lea					objectList+4(pc),a0
								cmp.l				(a0)+,a6																																																									; is new free slot shot or crumbling shot?
								blo					.isLower

								cmp.l				(a0),a6																																																										; is new free slot lower than current pointer?
								bhs					.isHigherOrEqual
								move.l				a6,(a0)																																																										; update dynamic object pointer
.isLower
.isHigherOrEqual
								move.l				objectListMyChild(a6),a0
								clr					(a6)																																																										;objectListAnimPtr
								clr.l				objectListMyChild(a6)
								clr.l				objectListMyParent(a6)
								subq				#1,objCount
								tst.l				a0
								beq					animLooper																																																									; main object has child object? No!

								cmp.l				objectListMyParent(a0),a6																																																					; check valid relationship
								bne					animLooper																																																									; if parent!=child->leave

								move.l				objectList+4(pc),a3																																																							;  fetch object data table adress
								lea					-4(a3),a3
								move.w				objCount(pc),d0
								bra					.findAllChildren
.getChildOfMain     ; find all child-objects of main object

								moveq				#4,d4
								move				#((tarsMax+bulletsMax)/8)-1,d5																																																				; loop
.loop
								REPT				4
								adda.w				d4,a3
								tst					objectListAnimPtr(a3)																																																						;objectListAnimPtr
								bne.b				.getChildOfChild
								ENDR
								dbra				d5,.loop																																																									; if
								bra					animLooper

.getChildOfChild
								move.l				a3,a0																																																										; current object->a0
								cmp.l				objectListMyParent(a0),a6
								beq					.delChildOfChild																																																							; is child of main object? Yes!
								dbra				d0,.getChildOfMain																																																							; No. Continue search
								bra					animLooper

.delChildOfChild
								move.l				a0,a4																																																										; loop through parent-child-chain until last member
								movea.l				objectListMyChild(a4),a0
								clr					objectListAnimPtr(a4)
								clr.l				objectListMyChild(a4)
								clr.l				objectListMyParent(a4)
								clr.l				objectListMainParent(a6)
								subq				#1,objCount
								subq				#1,d0
								bmi					irqDidObjMoveManager																																																						; deleted all objects? Quit!
								cmp.l				a6,a4
								bls.b				.modifyLoopCount
								subq				#1,d7
.modifyLoopCount
								tst.l				a0
								bne					.delChildOfChild																																																							; last child deleted? No!
.findAllChildren
								dbra				d0,.getChildOfMain																																																							; deleted one main-child-chain. 							; Continue search of all of main-objects childs
animLooper
								dbra				d7,animLoop
								bra					irqDidObjMoveManager
