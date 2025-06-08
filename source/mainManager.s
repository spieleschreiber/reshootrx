
; #MARK: - MAIN MANAGER
testJmp
								move.w				#1,d0
								rts


_Main
	;QUITNOW
								tst					errorFlag
								bne					.quitMain
.mainLoop

	;jsr initGame

								move.b				gameStatus(pc),d0
								andi.w				#$f,d0
								addq.b				#1,gameStatus
								clr.w				d0
								move.w				(.jmpTable,pc,d0.w*2),d0
								move.w				#testJmp-.off,d0
.off
								
								jsr					.off(pc,d0.w)
								tst.b				forceQuitFlag(pc)
								beq.b				.mainLoop
.quitMain
								rts
.jmpTable
								IFEQ				DEMOBUILD
								dc.w				mainIntro-.off-2,mainTitle-.off-2
								dc.w				initGame-.off-2
								dc.w				initGame-.off-2
								dc.w				initGame-.off-2
								dc.w				initGame-.off-2
								dc.w				initGame-.off-2
								dc.w				initGame-.off-2
								dc.w				mainReset-.off-2
								ELSE
								dc.w				mainIntro-.off-2,mainTitle-.off-2
								dc.w				initGame-.off-2
								dc.w				mainReset-.off-2
								dc.w				mainTitle-.off-2
								ENDIF
statusIntro					=	0
statusTitle					=	1
statusLevel0				=	2
statusLevel1				=	3
statusLevel2				=	4
statusLevel3				=	5
statusLevel4				=	6
statusLevel5				=	7
statusLevel6				=	8
statusFinished				=	10

mainGameOver
								rts
mainInit
								rts
mainReset
    ;move.b #statusLevel0,gameStatus
								move.b				#statusTitle,gameStatus
								rts


