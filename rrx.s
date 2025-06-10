

;PX  25. 5. 2025
; Copyright (c) 2025 spieleschreiber UG | Richard Löwenstein


	PRINTT
	PRINTT		"*** Compiling RRX.S"


	INCDIR		source/system/				; search these folders for includes
	INCDIR		source/copperCode/
	INCDIR		source/animCode/
	INCDIR		source/customCode/
	INCDIR		source/
	INCDIR		include/
	INCDIR		include/system/

	INCLUDE		!targetControl.i				; define important target vars
	INCLUDE		cia.i
	INCLUDE		custom.i
	INCLUDE		exec_lib.i
	INCLUDE		dos_lib.i
	INCLUDE		intuition_lib.i
	INCLUDE		graphics_lib.i
	INCLUDE		constants.i

	SECTION		CODE
	INCLUDE		macro.s

_start
	INCLUDE		startUp.s					;startup-code is in here													
	INCLUDE		loadFile.s
	INCLUDE		errorMessengers.s
	INCLUDE		inputHandler.s
	INCLUDE		saveState.s
	INCLUDE		initGameStructure.s
	INCLUDE		colorManager.s
	INCLUDE		opening.s
	INCLUDE		titleManager.s
	INCLUDE		initLevelManager.s
	INCLUDE		mainManager.s
	INCLUDE		sharedCode.s
	INCLUDE		initGameManager.s
	INCLUDE		mainGameLoop.s
	INCLUDE		blitterManager.s
	INCLUDE		fillManager.s
	INCLUDE		interruptManager.s
	INCLUDE		screenManager.s
	INCLUDE		rasterListManager.s
	INCLUDE		particleManager.s
	INCLUDE		spriteManager.s
	INCLUDE		parallaxManager.s
	INCLUDE		playerManager.s
	INCLUDE		objectMoveManager.s
	INCLUDE		objectListManager.s	
	INCLUDE		objectListPrep.s
	INCLUDE		collissionManager.s
	INCLUDE		animCodeMain.s
	INCLUDE		dataGeneral.s

	INCLUDE		objectInitManager.s	 
	INCLUDE		launchManager.s
	INCLUDE		scoreManager.s
	Include		customMain.s

	INCLUDE		audioManager.s


	INCLUDE		alert.s
	INCLUDE		exit.s
	IFNE		SANITYCHECK
	INCLUDE		sanityCheck.s
	ENDIF

	SECTION		CHIPSTUFF, DATA_C

	INCLUDE		copperCode/coplist.s
	INCLUDE		dataChipmen.s
