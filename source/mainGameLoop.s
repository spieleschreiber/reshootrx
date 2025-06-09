
    ; #MARK: - MAIN GAME LOOP
mainGameLoop        	;***Hauptprogramm/Schleife***




		IF					1=0											; display objectlist pointers: shot, objects, dynamic pointer to objects
		movem.l				objectList(pc),d0-d3
		ALERT01				m1,d0
		ALERT02				m1,d1
		ALERT03				m1,d2
		ALERT04				m1,d3
		ENDIF
;	move.w objCount(pc),d0
;	MSG01 m2,d0
;	move.w shotCount(pc),d1

;	MSG02 m2,d1
;	sub.w d1,d0
;	MSG03 m2,d0

		tst.b				blitterManagerLaunch(pc)
		beq					.blitterListNotReady

		tst.b				gameInActionF(pc)
		beq.b				.blitPause
		bsr					fillManager
		bsr					blitterManager
		move.l				CUSTOM+VPOSR,d0
		lsr.l				#7,d0
		move.w				d0,rasterBarNow								; store rasterPosition after blitter draw process

.blitPause
		lea					frameCount(pc),a0							; update frameCount
		move.w				frameCount+6(pc),d0

.noFullFrame
		move				(a0),d1
		beq					.noFullFrame
		add.w				d1,2(a0)
		move				d1,6(a0)									; store actual framerate
		clr.w				(a0)

		move.w				2(a0),d7									; alternate sound-fx (shot and wall-hit pitch) for additional audio dynamics
		move.w				d7,d0
		andi.w				#%111,d0
		beq					.keepPitch
		btst				#5,d7
		seq					d0
		andi.b				#%111<<2,d0
		andi				#%111<<2,d7
		eor.b				d0,d7
		add					#$100,d7
		lea					fxTable+((fxShot-1)*fxSizeOf)+6(pc),a0
		move.w				d7,(a0)
		lea					(fxImpactWall-fxShot)*fxSizeOf(a0),a0
		andi.b				#%1<<4,d7
		lsl.b				#2,d7

		sub.w				#$b0,d7
		move.w				d7,(a0)
.keepPitch
		IFNE				SHOWGLOBALFLAGS
		lea					(animTriggers,pc),a5
		move.l				(a5),d0
		MSG04				msgGlobFlags,d0
		ENDIF

		IF					SHOWFRAMERATE=1
		lea					frameCount+6(pc),a5
		move				(a5),d1
		move.b				.frameNum-1(pc,d1),d0
		lea					.frameRate(pc),a0
		move				d0,d1
		and					#$0f,d1
		add					#"0",d1
		move.b				d1,2(a0)
		move				d0,d1
		lsr					#4,d1
		and					#$0f,d1
		add					#"0",d1
		move.b				d1,1(a0)
.sk1
		move.w				#40,d0
		move.w				#247,d1
		move.l				mainPlanesPointer+0(pc),a5
		lea					40(a5),a5
		bsr					wrtTextOnePlane

		bra.b				.cont
.frameNum
		dc.b				80,37,23,18
.frameRate
		dc.b				" AA",0
		even
.cont
		ENDIF

		bsr					scoreManager
.blitterListNotReady


		IF					SHOWframeCount=1
		lea					frameCount+2(pc),a5
		move.w				(a5),d0
		ALERT01				msgFC,d0
		ENDIF

		IFNE				SHOWOBJECTNO
		lea					.objCount(pc),a0
		move.w				#"00",2(a0)
		move.w				#"00",8(a0)
		move.w				#"00",13(a0)

		clr.l				d7
		move.w				bobCount(pc),d7
		beq					.zeroBob
.retLoopB
		divs				#10,d7
		add					#"0",d7
		move.b				d7,8(a0)
		swap				d7
		add					#"0",d7
		move.b				d7,9(a0)
.zeroBob

		clr.l				d7
		move.w				objCount(pc),d7
		beq					.zeroObj
		divs				#10,d7
		add					#"0",d7
		move.b				d7,13(a0)
		swap				d7
		add					#"0",d7
		move.b				d7,14(a0)
.zeroObj

		clr.l				d7
		move.w				spriteCount(pc),d7
		bne					.buildSprNum
.retLoopA
		clr.l				d7
		bra					.skip
.buildSprNum
		divs				#10,d7
.skip
		add					#"0",d7
		move.b				d7,2(a0)
		swap				d7
		add					#"0",d7
		move.b				d7,3(a0)

.print
		move.w				#120,d0										; x-pos at the very right
		move.w				#247,d1										; y-pos at the very bottom
		move.l				mainPlanesPointer+8(pc),a5
		lea					40(a5),a5
		bsr					wrtTextOnePlane
		bra.b				.contB
.objCount
		dc.b				"SPAA BOBAA OBAA",0
		even
.contB
		ENDIF


		IFNE				SANITYCHECK

		bsr					objectSanityCheck
		ENDIF

		WAITRASTER			30


.noEscape
		move.w				plyPos+plyJoyCode(pc),d0					; read only upper two bytes of controller
		andi				#1<<(STICK_BUTTON_TWO),d0					; only start button bit
		lea					.storeController(pc),a1
		tst.w				(a1)
		bne.b				.sameKey									; only process pause if start was released
		move.w				d0,(a1)
		btst				#STICK_BUTTON_TWO,d0
		bne					.pauseGame
.sameKey
		tst.w				d0
		bne.b				.stillPressed								; was button released?
		clr.w				(a1)										; yes
.stillPressed

		tst.w				transitionFlag(pc)
		bne.w				mainGameLoop

		IFEQ				(RELEASECANDIDATE||DEMOBUILD)
		tst.w				keyArray+LShift(pc)
		bne					forceQuit
		tst.w				keyArray+RShift(pc)
		bne					.fastRestart
		ENDIF

		tst.b				forceExit(pc)
		beq					mainGameLoop
.exit
		lea					transitionFlag(pc),a1
		move				#transitionOut,(a1)							; init fadeout
.fadeOut
		WAITVBLANK
		bsr					blitterManager
		lea					transitionFlag(pc),a1
		tst.w				(a1)
		bne.b				.fadeOut
.fastExit
		lea					CUSTOM,a6
		move.w				#DMAF_BPLEN!DMAF_SPRITE,DMACON(a6)			; switch of bpl dma
		lea					gameInActionF(pc),a0
		sf.b				(a0)										;	avoid
		WAITVBLANK
		WAITVBLANK
		rts

		IFEQ				(RELEASECANDIDATE||DEMOBUILD)
.fastRestart
		; right shift key, restart at level defined on levelGetter.s
		lea					gameInActionF(pc),a0
		sf.b				(a0)										; disable gamecode in interrupt
		WAITVBLANK														; wait a bit -> irq blits may finish
		WAITVBLANK
		WAITVBLANK
		bsr					setgameStatus
	;move.b #statusLevel1,gameStatus			;	should be statusTitle
		bra.b				.fastExit
		ENDIF
.pauseGame
;    bra mainGameLoop
		lea					transitionFlag(pc),a0
		tst.w				(a0)										; no pause if fading
		bne					mainGameLoop
		tst.b				plyBase+plyExitReached(pc)
		bne					mainGameLoop								; no pause if exit reached

		lea					CUSTOM,a6
		tst.b				plyBase+plyWeapUpgrade(pc)
		bmi					.initPause									; skip pause code if not triggered by player but fatal ship hit

		lea					gameInActionF(pc),a0
		btst				#0,(a0)
		beq					.unpauseGame
		bclr				#0,(a0)

		move.w				frameCount+2(pc),tempVar+36					; save frameCounter to keep synced animations in flow afte unpause

		lea					CUSTOM,a6
.vol	SET					0
		move.w				#musicPauseVolume,d0
		bsr					_mt_mastervol

	; init pause icon display

		move.l				pauseMsgAnimPointer(pc),a4
		move.w				animTablePointer+2(a4),d4					;add  object to control quick resume mode
		move				#259+16,d5
		sub.w				plyBase+plyPosXDyn(pc),d5
		moveq				#24,d6
		add.w				viewPosition+viewPositionPointer(pc),d6
		st.b				d3
		jsr					objectInit									; spawn Instant Respawn sprite
		bsr					objectListManager							; update display by hand, as interrupt driven updates are off in pause mode
		bsr					spriteManager
		move.w				#$00<<1,d5									; modify bullet colors to make pause icon look clear

.waitKeyRelease
		pea					.quitPause
		SAVEREGISTERS

		bra					irqJumpIn

.unpauseGame
		move.w				tempVar+36(pc),frameCount+2

		move.w				#5,d7
.loop
		lea					CUSTOM,a6
		move.w				#musicFullVolume,d0
		bsr					_mt_mastervol								; need to call this a couple of time to ensure correct volume. Some kind of bug, I suppose. Prevents exploit of pause to slow down pacing too
		WAITVBLANK
		dbra				d7,.loop
.initPause

		lea					gameInActionF(pc),a0
		bset				#0,(a0)
.quitPause
		bra					mainGameLoop
.storeController
		dc.w				0
    ;bra.b keyQuitGame
;noJoyAction
 ;   clr.l plyPos+plyJoyCode
.quitGame
		btst				#0,(gameInActionF,pc)
		bne					.noEscape									; in action mode? Cant escape to title
		lea					gameStatus(pc),a0
		move.b				#statusTitle,(a0)
	;move.b #statusLevel0,(a0)
		bra.b				mainLoopQuit
forceQuit
		lea					forceQuitFlag(pc),a0
		st.b				(a0)
mainLoopQuit
		lea					gameInActionF(pc),a0
		sf.b				(a0)										; disable gamecode in interrupt

		WAITVBLANK														; wait a bit -> irq blits may finish
		WAITVBLANK
		WAITVBLANK
		rts
