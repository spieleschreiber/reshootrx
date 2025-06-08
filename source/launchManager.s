
; #MARK: - LAUNCH MANAGER
launchManager

	;#FIXME: check - use launchTable or launchTablebuffer. Is buffer still needed?
	move.l		launchTableBuffer(pc),a0
	move.l		launchTableEntryLength(pc),a6
	move		viewPosition+viewPositionPointerLaunchBuf(pc),d0
	move		d0,d5
	lea			launchTableAnim(a0),a5
	tst.w		launchTableAnim(a0)
	bmi			.enemQuit
	bne			.foundValidEntry									;   is 0? past wave, unvalid!

.enemPreFetchWave               ;   preloop to determine first valid entry in launchTable. Table needs to be sorted
								REPT				4
								adda.l				a6,a0
								tst.w				(a0)																																																										;launchTableAnim
								bne					.foundValid																																																									;   is 0? past wave, unvalid!
								ENDR
								bra					.enemPreFetchWave
.foundValid
								bmi					.enemQuit																																																									;   is >$7fff? reached end of list

								lea					launchTableBuffer(pc),a4
								move.l				a0,(a4)
								bra					.foundValidEntry
.enemFetchWave

								REPT				4
								adda.l				a6,a0
								tst.w				(a0)																																																										; read launchTableAnim entry
								bne.s				.foundValidEntry																																																							;   is 0? already launched
								ENDR
								bra					.enemFetchWave
.foundValidEntry
								bmi					.enemQuit																																																									;   is >$7fff? reached end of list

								cmp					launchTableY(a0),d0
								bcc					.enemQuit

								tst.b				launchTableRptr(a0)
								bne.b				.copyObject

	; launch single object

								move.b				launchTableHitpoints(a0),d6
								clr.l				d6
								clr.l				d5
								move.w				launchTableX(a0),d5
								move				viewPosition+viewPositionPointerLaunchBuf(pc),d6
.singleDynX
								move.w				(a0),d4																																																										;launchTableAnim
								st.b				d3
								bsr					objectInitLaunchList
								tst.l				d6
								bmi					.enemFetchWave
								st.b				objectListWaveIndx(a4)
								clr.w				launchTableAnim(a0)																																																							; delete launch entry
								bra					.enemFetchWave																																																								; get next
.copyObject
								sub.b				#1,launchTableRptCountdown(a0)
								bcc.w				.enemNextWave
.enemChckRythm              ; launch delay until music permits

								move.b				launchTableRptrDist(a0),launchTableRptCountdown(a0)
								sub.b				#1,launchTableRptr(a0)
								beq.w				.enemEndWave																																																								; overflow? was single object
.launchCopied			; launch copied object
								bmi					.firstEntry																																																									; is first object? Yes!
.contLaunch
								clr.l				d5
								move.w				launchTableX(a0),d5

								tst.b				launchTableAttribs(a0)
								bpl.b				.copiedStaticY

								move				launchTableY(a0),d6
		;move #$13f0,d6
								bra.b				.copiedInit
.firstEntry
								lea					vars(pc),a1
								clr.l				homeShotHead-vars(a1)																																																						; reset pointer to first object
								move.w				a0,d7
								lsr					#3,d7
								andi				#$f,d7																																																										; create wave fingerprint
								lea					objCopyTable(pc,d7),a1

								bclr				#7,launchTableRptr(a0)
								clr.w				d0
								move.b				launchTableRptr(a0),d0
								move.b				d0,(a1)																																																										; store no of obj==mark as wave
								clr.b				objSpiralBulletTable-objCopyTable(a1)																																																		; reset shoot angle pointer
								bra.b				.contLaunch
.copiedStaticY
								move				viewPosition+viewPositionPointerLaunchBuf(pc),d6
.copiedInit
								move.w				(a0),d4																																																										;launchTableAnim
								st.b				d3
								bsr					objectInitLaunchList
								tst.l				d6
								bmi					.enemEndWave																																																								; too many objects? Kill wave!
		;		move.w objectListY(a4),d7
								move.w				a0,d7
								lsr					#3,d7
								andi				#$f,d7																																																										; generate wave fingerprint
								move.b				d7,objectListWaveIndx(a4)																																																					; store index in obj struc
;		bra.b .groupedChk
	;bra .enemFetchWave	; get next
.groupedChk
								btst				#2,d3
								beq.b				.noGroup
								move.l				a0,objectListLaunchPointer(a4)																																																				;store pointer to launch list entry / cancel wave if killed
								move.w				a0,objectListGroupCnt(a4)																																																					; needed for comparing
.noGroup
								move.b				launchTableRptXAdd(a0),d6
								ext.w				d6
								add.w				d6,launchTableX(a0)
								move				viewPosition+viewPositionPointerLaunchBuf(pc),d0																																															; restore d0
								bra.w				.enemFetchWave
.enemEndWave
								clr.w				launchTableAnim(a0)
.enemNextWave
								bra.w				.enemFetchWave
.enemQuit
								bra					irqNoMoreLaunches

objCopyTable	; store index and no of copied objects for wave bonus
								blk.b				16,0																																																										; entrys
objSpiralBulletTable
								blk.b				16,0
objSpiralplyPosTable
								blk.l				16,0
objCopyEnd
								even
