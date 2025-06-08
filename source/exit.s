
; #MARK: - EXIT CODE BEGINS

_Exit:
								move.l					Execbase,a6
								move.l					mainPlanes+12(pc),a1
								tst.l					a1
								beq.b					.skipThis1
								jsr						_LVOFreeVec(a6)
.skipThis1
								move.l					tilemapBckConverted(pc),a1
								tst.l					a1
								beq.b					.skipThis8
								jsr						_LVOFreeVec(a6)
.skipThis8
								move.l					tilemapConverted(pc),a1
								tst.l					a1
								beq.b					.skipThis26
								jsr						_LVOFreeVec(a6)
.skipThis26
								move.l					copperGame(pc),a1
								tst.l					a1
								beq.b					.skipThis35
								jsr						_LVOFreeVec(a6)
.skipThis35
								move.l					copSplitList(pc),a1
								tst.l					a1
								beq.b					.skipThis36
								jsr						_LVOFreeVec(a6)
.skipThis36
								move.l					launchTable(pc),a1
								tst.l					a1
								beq.b					.skipThis37
								jsr						_LVOFreeVec(a6)
.skipThis37
								move.l					launchTableBuffer+4(pc),a1
								tst.l					a1
								beq.b					.skipThis43
								jsr						_LVOFreeVec(a6)
.skipThis43
								move.l					objectDefs(pc),a1
								tst.l					a1
								beq.b					.skipThis47
								jsr						_LVOFreeVec(a6)
.skipThis47
								move.l					animDefs(pc),a1
								tst.l					a1
								beq.b					.skipThis49
								jsr						_LVOFreeVec(a6)
.skipThis49
								move.l					animTable(pc),a1
								tst.l					a1
								beq.b					.skipThis50
								jsr						_LVOFreeVec(a6)
.skipThis50
								move.l					audioWavTable(pc),a1
								tst.l					a1
								beq.b					.skipThis62
								jsr						_LVOFreeVec(a6)
.skipThis62
								move.l					audioFXHero(pc),a1
								tst.l					a1
								beq.b					.skipThis63
								jsr						_LVOFreeVec(a6)
.skipThis63
								move.l					audioFXBaddie(pc),a1
								tst.l					a1
								beq.b					.skipThis64
								jsr						_LVOFreeVec(a6)
.skipThis64
	;move.l musicMemory(pc),a1
	;tst.l a1
    ;beq.b .skipThis66
	;jsr	_LVOFreeVec(a6)
.skipThis66
								tst.b					AudioIsInitiated(pc)
								beq						.noAudioEver
								lea						CUSTOM,a6
								lea						mt_chan1,a4
								move.b					#0,mt_Enable-mt_chan1(a4)																																																					;disable music playing
								jsr						_mt_end																																																										; stop player
								lea						CUSTOM,a6
								jsr						_mt_remove_cia																																																								; stop CIA-Interrupt
								clr.b					AudioIsInitiated
.noAudioEver
								lea						forceQuitFlag(pc),a0
								sf.b					(a0)


								moveq					#-1,d0																																																										; instr cache bit
								moveq					#-1,d1																																																										; affect all bits
								CALLEXEC				CacheControl																																																								; disable all cache but instr cache

								clr.l					d0
								rts
	; #MARK: EXIT CODE ENDS
