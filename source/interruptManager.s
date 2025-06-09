
; #MARK: - COPPER IRQ
copperInt
				SAVEREGISTERS
				lea					SoftIntServer(pc),a1
				CALLEXEC			Cause											; init software interrupt, delegate further 50 hz code handling without blocking vbi and coper interrupt chain
.skipIntCall

;	moveq #0,d0
				RESTOREREGISTERS
				rts
				IFEQ				(RELEASECANDIDATE||DEMOBUILD)
.skipFrame
				bra					.skipIntCall
				ENDIF
; #MARK: SOFT IRQ

softInt		; interrupt with lowest prio, but higher than mainloop
				SAVEREGISTERS


				bra					inputHandler									; reads keyboard and stick, builds one action
retInputHandler

				tst.b				gameInActionF(pc)
				beq					quitSoftInt

	;#FIXME: code moved from interrupt to blittermanager, to kill display glitches in busy moments. Delete after 31.12.2022
				IFNE				1
				tst.b				blitterManagerFinished(pc)
				beq.b				irqScrMng										; if blitter has not yet finished drawing,  keep old blitter draw list

;	if blitter has finished drawing: buffer -> active
				lea					bobDrawList(pc),a5
				movem.l				(a5),d0-d1
				exg.l				d0,d1
				movem.l				d0-d1,(a5)										; swap drawing queue lists
				lea					12(a5),a5
				movem.l				(a5),d0-d1
				exg.l				d0,d1
				movem.l				d0-d1,(a5)										; swap end of list comparators
				lea					blitterManagerLaunch(pc),a0
				st.b				(a0)											; active list now ready for drawing
				ENDIF

irqScrMng
				lea					viewPosition(pc),a3
				move.w				((scrMngOffset).w,pc),d0
jmpSrcMngOffset
				jsr					jmpSrcMngOffset(pc,d0.w)
irqRetScreenManager
				bsr					rasterListMove
				bsr					plyManager
				bra					spriteManagerPlayer
sprManPlyReturn
				lea					frameCompare(pc),a1
				tst.w				2(a1)
				bne.b				irqSlowMotion
				bra					objectMoveManager
irqSlowMotion
				sub.w				#1,(a1)											; handle framerate
				bpl					irqDidObjMoveManager
				move				2(a1),(a1)
				bra					objectMoveManager
irqDidObjMoveManager
				lea					viewPosition(pc),a3
				move.l				viewPositionAdd(a3),d7
				move.l				viewPositionPointer(a3),d6
				swap				d6
				sub					#$60,d6
				move.w				d6,viewPositionPointerLaunchBuf(a3)
				add.l				d7,viewPositionPointer(a3)						; update viewPosition pointers here -> flickerfree sync of objects and background
				bsr					objectListManager
.blitListUpdate
				bra					collisionManager
irqDidColManager
				bra					particleManager
irqDidParticleManager

				move.w				((sprMngOffset).w,pc),d0
jmpSprMngOffset
				jsr					jmpSprMngOffset(pc,d0.w)						;spritemanager

				tst.w				plyPos+plyCollided(pc)
				bne.b				irqNoMoreLaunches
				bra					launchManager




irqNoMoreLaunches
.noMovement
.skipGamecode


	; apply dynamic colors to enemy bullets

				move				frameCount+2(pc),d5

irqJumpIn	; used by pause function to set bullet colors
				moveq				#3,d7
				moveq				#$7<<1,d6
.paintBullets
				move.l				colorBullet(pc,d7*4),a0
				tst.l				a0
				beq					.colorBullets
				move.w				d5,d0
				btst				#4,d5
				seq					d1
				and.w				d6,d0
				and.b				d6,d1
				eor.b				d1,d0

				move.w				fetchBulletColors(pc,d0),d1
.offset			SET					12
				move.w				d1,.offset+2(a0)
				move.w				d1,.offset+6(a0)
				move.w				d1,.offset+10(a0)
				move.w				d1,.offset+14(a0)

				move.w				16+fetchBulletColors(pc,d0),d1
				move.w				d1,.offset+16+2(a0)
				move.w				d1,16+.offset+6(a0)
				move.w				d1,16+.offset+10(a0)
				move.w				d1,16+.offset+14(a0)

				move.w				32+fetchBulletColors(pc,d0),d1
				move.w				d1,32+.offset+2(a0)
				move.w				d1,32+.offset+6(a0)
				move.w				d1,32+.offset+10(a0)
				move.w				d1,32+.offset+14(a0)

				add					#6,d5
.colorBullets
				dbra				d7,.paintBullets

quitSoftInt
				moveq				#0,d0											; set z-flag -> OS handles further interrupt reqs
				RESTOREREGISTERS													; does not affect flags
				rts

fetchBulletColors
.red			SET					$1<<4
.green			SET					$2<<4
.blue			SET					$2<<4

	; darkest bullet color
				dc.w				-1
				REPT				7
.rgb			SET					(.red&$f0)<<4!(.green&$f0)!(.blue&$f0)>>4
				dc.w				.rgb

.red			SET					.red+24
.green			SET					.green+27
.blue			SET					.blue+38

				IF					(.red>255)
.red			SET					255
				ENDIF
				IF					(.green>255)
.green			SET					255
				ENDIF
				IF					(.blue>255)
.blue			SET					255
				ENDIF
				ENDR


	;	brightest bullet color

.red			SET					$f<<4
.green			SET					$f<<4
.blue			SET					$4<<4
				dc.w				-1
				REPT				7
.rgb			SET					(.red&$f0)<<4!(.green&$f0)!(.blue&$f0)>>4
				dc.w				.rgb

.red			SET					.red+13
.green			SET					.green+13
.blue			SET					.blue+16

				IF					(.red>255)
.red			SET					255
				ENDIF
				IF					(.green>255)
.green			SET					255
				ENDIF
				IF					(.blue>255)
.blue			SET					255
				ENDIF
				ENDR

	; medium bullet color

.red			SET					$a<<4
.green			SET					$a<<4
.blue			SET					$1<<4
				dc.w				-1
				REPT				7
.rgb			SET					(.red&$f0)<<4!(.green&$f0)!(.blue&$f0)>>4
				dc.w				.rgb

.red			SET					.red+21
.green			SET					.green+21
.blue			SET					.blue+6

				IF					(.red>255)
.red			SET					255
				ENDIF
				IF					(.green>255)
.green			SET					255
				ENDIF
				IF					(.blue>255)
.blue			SET					255
				ENDIF
				ENDR
; #MARK: levelspecific jmps
scrMngOffset	=	*+2
				dc.w				0,0
sprMngOffset
				dc.w				0

; #MARK: VERTICAL BLANK IRQ
vertBlancInt
				SAVEREGISTERS



				IFNE				0												; not using ingame sync of audio and video anymore; commented out

				lea					AudioRythmFlagAnim(pc),a0
				tst.b				(a0)
				beq.b				.2
				btst				#4,(a0)
				seq					d0
				andi				#$3f,d0
				sub.b				#1,(a0)											; flag reset in audio.s
				move.b				(a0),d7
				eor					d0,d7
				clr.b				d7
				move.b				d7,1(a0)

.2
				ENDIF
	;bsr keyboardHandler

				tst.l				copInitColorswitch(pc)							; poke .l into this with pointer to colorlist or other alternative coplist in copperformat to safely switch colors; take care of init´ copjmp1@end of colorlist
				bne					.initModifiedCoplist
				move.l				#copGamePlyBody,CUSTOM+COP2LC					; user-init needed every vbi to overwrite OS-init
.cop2started
				lea					frameCount(pc),a0
				addq				#1,(a0)
				addq				#1,4(a0)
;    tst.w plyPos+plyCollided(pc)
 ;   bne .playerDies    ; if player dies, handle framerate(copperIRQ)
.playerLives                  ; do some score stuff
				lea					scoreMultiplier(pc),a1
				tst.w				(a1)											; countdown scoremultiplier?
				beq.b				.1
				subq.w				#1,(a1)											;  yes
				beq					.pitchreset										; no valuable hit for some time?
.1
				tst.w				transitionFlag(pc)
				bne.w				.transition
.vbiQuit
				moveq				#0,d0											; z-flag needs to be clear on vbi / OS convention
				RESTOREREGISTERS
				rts

.initModifiedCoplist
				lea					copInitColorswitch(pc),a0
				move.l				(a0),CUSTOM+COP2LC
				clr.l				(a0)
				clr.w				CUSTOM+COPJMP2
				bra					.cop2started

.pitchreset
				lea					plyPos(pc),a0
				tst.w				plyCollided(a0)
				bne.b				.skipFX
				tst.b				plyExitReached(a0)
				bne.b				.skipFX											; play FX only if player in action
				tst.b				3(a1)											; multiplier < 2?
				beq					.skipFX											; yes!
				PLAYFX				fxKillChain
.skipFX
				clr.w				2(a1)
				bra					.1
.transition
				lea					transitionFlag(pc),a0
				clr.l				d1
				tst.w				(a0)
				bpl					.fadeIn
				move.w				#transitionOut-$18,d0							; fade out
				sub.w				(a0),d0
				SAVEREGISTERS
				tst.w				d0
				spl					d1
				ext.w				d1
				and.l				d1,d0
				not.b				d0
				muls				#36,d0
				lsr.w				#7,d0
				sub.b				#$9,d0
	;sub.b #2,d0
				lea					CUSTOM,a6

				bsr					_mt_mastervol									; set music volume
				RESTOREREGISTERS
				bra.b				.cntDwnFade
.fadeIn
				move.w				(a0),d0
				sub					#30,d0											; set left frame border
.cntDwnFade		sub.w				#4,(a0)
				bvc.b				.gamePaused
				clr.w				(a0)											; fade finished
.gamePaused
	;lea $dff000,a6
				add.w				#$c0,d0
				move.l				d0,d1
				andi				#$ff,d0
				or.w				#(displayWindowStart+1)<<8,d0
				lsr.l				#3,d1
				andi				#$20,d1
				or					#$3100,d1
				move.w				d0,COPDIWSTRT+2
				move.w				d1,COPDIWHIGH+2
.quit
				bra					.vbiQuit

irqCopJmp
				dc.l				0
transitionFlag
				dc.w				0
transitionIn	=	$f0																; $f8
transitionDone	=	$30																; $34
transitionOut	=	$8000!transitionIn
irqColorFlag
				dc.b				0
				even
