
; #MARK: - MAIN MANAGER
testJmp
	move.w		#1,d0
	rts


_Main
	;QUITNOW
	tst			errorFlag
	bne			.quitMain
.mainLoop

	;jsr initGame

	move.b		gameStatus(pc),d0
	andi.w		#$f,d0
	addq.b		#1,gameStatus
	move.w		#2,d0
	move.w		.jmpTable(pc,d0.w*2),d0
	;move.w		#testJmp-.off,d0
	jsr			.jmpTable(pc,d0.w)
	tst.b		forceQuitFlag(pc)
	beq.b		.mainLoop
.quitMain
	rts
.jmpTable
	IFEQ		DEMOBUILD
	dc.w		mainIntro-.jmpTable,mainTitle-.jmpTable
	dc.w		initGame-.jmpTable
	dc.w		initGame-.jmpTable
	dc.w		initGame-.jmpTable
	dc.w		initGame-.jmpTable
	dc.w		initGame-.jmpTable
	dc.w		initGame-.jmpTable
	dc.w		mainReset-.jmpTable
	ELSE
	dc.w		mainIntro-.jmpTable,mainTitle-.jmpTable
	dc.w		initGame-.jmpTable
	dc.w		mainReset-.jmpTable
	dc.w		mainTitle-.jmpTable
	ENDIF
statusIntro		=	0
statusTitle		=	1
statusLevel0	=	2
statusLevel1	=	3
statusLevel2	=	4
statusLevel3	=	5
statusLevel4	=	6
statusLevel5	=	7
statusLevel6	=	8
statusFinished	=	10

mainGameOver
	rts
mainInit
	rts
mainReset
    ;move.b #statusLevel0,gameStatus
	move.b		#statusTitle,gameStatus
	rts


