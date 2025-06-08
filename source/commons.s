


CLEARMEMORY
    clr.l d0
    clr.l d1
    clr.l d2
    clr.l d3
    clr.l d4
    clr.l d5
    sub.l a0,a0
    sub.l a1,a1
    sub.l a2,a2
    sub.l a3,a3
    sub.l a4,a4
    move.l a6,a5
    adda.l d7,a6
    moveq #$30,d6
    sub.l d6,d7
    divu d6,d7
    clr.l d6
    swap d7
    clr.w d7
    swap d7
.1
    movem.l d0-d6/a0-a4,-(a6)
    dbra d7,.1
    move.l a6,d7
    sub.l a5,d7
    lsr.l #1,d7
    bra.b .3
.2
    clr.w -(a6)
.3
    dbra d7,.2
    rts

_WAITSECS	; d0 = seconds	; called by macro WAITSECS
	move.w _waitsec(pc),d0
	muls #50,d0
	lea frameCount+4.l(pc),a5
.wait
	cmp.w (a5),d0
	bhi .wait
	rts
_waitsec
	dc.w 0

_WAITVBLANK
    movem.l d0-d1,-(sp)
	move.w frameCount+4,d0
.m1
	move.w frameCount+4,d1
	cmp.w d0,d1
	beq.b .m1
    movem.l (sp)+,d0-d1
    rts

FASTRANDOM_A1
	lea	fastRandomSeed.l(pc),a1
	movem.l	(a1),d4/d5				; AB
	swap	d5						; DC
	add.l	d5,(a1)					; AB + DC
	add.l	d4,4(a1)				; CD + AB
	rts

_timer
	dc.w 0

writeCol
; write AGA-color d0/d1/d2 (RGB) to reg d3
	;tst.w d3
	;beq .skip
    movem.l a0/d0-d6,-(a7)

    move.w d0,d4
    move.w d1,d5
    move.w d2,d6
    lsl.w #4,d4
    lsr.w #4,d6
    andi.w #$f00,d4
    andi.w #$0f0,d5
    andi.w #$00f,d6
    or d6,d4
    or d5,d4        ;Highbyte of color value

    lsl.w #8,d0
    lsl.b #4,d1
    andi.w #$f00,d0
    andi.w #$0f0,d1
    andi.w #$00f,d2
    or d1,d0
    or d2,d0        ;Lowbyte of color value

	move d3,d1
	andi.w #$1f,d3
	lsl #1,d3
	add.w #$180,d3
	lea CUSTOM,a0
	lsl #8,d1
    andi #%1110000000000000,d1
	or #BRDRBLNKF,d1
    move d1,BPLCON3(a0)
    move d4,(a0,d3)
    or #LOCTF,d1
    move d1,BPLCON3(a0)
    move d0,(a0,d3)

    movem.l (a7)+,a0/d0-d6
.skip
	rts




    ; #MARK: - SUBROUTINES BEGINS
convertHexToBCD
  	;	d0	->	num in hex format
  	;	->	d1 converted bcd number
  	; destroys d0,d1,d2,d3,d4,d5,d7
								moveq					#0,d1																																																										; convert score to add from binary -> bcd number. att: four bcd digits max!
								move.l					d1,d3
								move.l					d1,d7
								moveq					#3,d2
								move					#-1,d3
								moveq					#10,d4
								moveq					#4,d5
.convertLoop
								cmp.w					d4,d0
								blt						.foundRemainder
								sub						d4,d0
								addq					#1,d7
								bra						.convertLoop
.foundRemainder
								swap					d7
								or.l					d7,d0
								add.w					d0,d1
								ror.w					d5,d1
								swap					d0
								and.l					d3,d0
								moveq					#0,d7
								dbra					d2,.convertLoop
								rts



loadSample	    ; import and init voice sample
				; d1 = pointer to sample binary filename
				; a0	= 	pointer to sample init struc
				; a3	pointer to sample memory pointer


								lea						tempVar(pc),a4
								move.l					a0,8(a4)
								move.l					d1,a5

								move.l					(a3),a1
								tst.l					a1
								beq						.freeMemFirst
								clr.l					(a3)																																																										; clear sample pointer within sfx structure in any case
								SAVEREGISTERS
								move.l					Execbase,a6
								jsr						_LVOFreeVec(a6)
								RESTOREREGISTERS
.freeMemFirst

								bsr						createFilePathOnStage
								bsr						GetFileInfo																																																									; check for sufficient memory
								tst.l					d0
								beq						errorDisk

								move.l					(fib_Size,pc),d0																																																							; filesize
								move.l					#MEMF_CHIP|MEMF_CLEAR,d1
								move.l					Execbase,a6
								jsr						_LVOAllocVec(a6)
								tst.l					d0
								beq						.noMemory																																																									; not enough chipmem, do not play voice sample
								move.l					(fib_Size,pc),d1
								movem.l					d0-d1,(a4)																																																									; store sample pointer, size of sample
								move.l					d0,(a3)

								move.l					a5,d1																																																										; filename
								move.l					d0,d2																																																										; memory pointer
								move.l					(fib_Size,pc),d3																																																							; sample size
								bsr						createFilePathOnStage
								jsr						loadFile
								tst.l					d0
								beq						errorDisk
								movem.l					(a4),d0/d1/a0																																																								; pointer to sample, sample size, sample struc
								add.w					#$70,d0																																																										; skip sample definition entry
								sub.w					#$70,d1																																																										; modify sample length accordingly
								move.l					d0,(a0)
								move.l					d0,a1
								clr.l					(a1)																																																										; clear first word for clean audio playback
								lsr						#1,d1
								move.w					d1,4(a0)
.noMemory
								rts
loadMainCopList
								lea						copperGame(pc),a3
								move.l					(a3),d2
								clr.l					4(a3)																																																										; reset pointer to end of main coplist
								bsr						loadCopList
								lea						-16(a1),a1																																																									; prepare for copying cop1lc-reset to end of list
								lea						irqCopJmp(pc),a0
								move.l					a3,(a0)																																																										; make available in irq
								rts

loadCopList	; a0=pointer to filename, d2=pointer to memory address. Returns end of file adress in a1
								move.l					a0,d1																																																										; pointer to filename
								move.l					d1,d5																																																										;	""
								move.l					d2,d6																																																										; pointer to memory address
								bsr						createFilePathOnStage
								bsr						GetFileInfo
								move.l					(fib_Size.w,pc),d1
								tst.l					d0
								beq						errorDisk

								move.l					d5,d1
								move.l					d6,d2
								move.l					(fib_Size.w,pc),d3
								bsr						createFilePathOnStage
								bsr						loadFile
								tst.l					d0
								beq						errorDisk
								add.l					(fib_Size.w,pc),d2
								move.l					d2,a1
								lea						copperGame(pc),a3
								move.l					d2,4(a3)																																																									; 	store pointer to end of coplist
								rts



resetScores
								lea						score(pc),a0
								move.w					#1,scoreAdder-score(a0)																																																						; some score preps
								move.l					#$99999999,(a0)
								IFNE					SCORE_OVERRIDE
								move.l					#SCORE_OVERRIDE,(a0)
								ENDIF
								clr.w					scoreHighDelta-score(a0)
								clr.b					scoreHighSuccessFlag-score(a0)
								rts

;!!!: Do also clr ply sprite, use this code in intro
blankSprite


								moveq					#7,d0
.wrtSprt
								clr.w					SPR0POS(a6)																																																									; reset sprite positions to disable dma draw bug
								add.w					#8,a6
								dbra					d0,.wrtSprt
								rts

; MARK: SET gameStatus GAME / TITLE
setgameStatus
								lea						gameStatus(pc),a0
	;move.b #1<<optionDiffBit|1<<optionMusicBit|1<<optionSFXBit,1(a0)	; set basic options
								clr.b					1(a0)																																																										; set basic options
								IFNE					RELEASECANDIDATE																																																							; go to title only if releaseversion

								move.b					#statusIntro,(a0)																																																							;  $8000 indicates first call to mainFade-routine
;FIXME: Reset to statusIntro
								ELSE
								IF						INITWITH<20
								move.b					#statusLevel0+INITWITH,(a0)

								move.l					#.levelGetter,d1																																																							; load level specified in file
								move.l					a0,d2
								moveq					#1,d3
								jsr						loadFile
								tst.l					d0
								beq						errorDisk
								lea						gameStatus(pc),a0
								sub.b					#"0"-2,(a0)
								bra.b					.1
.levelGetter
								FILENAMEPREFIX
								dc.b					"levDefs/levelGetter.s",0
								even
.1
								ELSE
								IF						INITWITH=20
								move.b					#statusIntro,(a0)
								ENDIF
								IF						INITWITH=30
								move.b					#statusTitle,(a0)
								ENDIF
								ENDIF
								ENDIF
								rts

installAudioDriver	; init CIA interrupt, running music driver
								SAVEREGISTERS
								tst.b					AudioIsInitiated
								bne.b					.ciaIntRunning

								lea						CUSTOM,a6
								bsr						_mt_remove_cia

								move.l					VBRptr(pc),a0
								lea						CUSTOM,a6
	;st.b d0	; st.b != 0 for PAL
								bsr						_mt_install_cia

								lea						AudioIsInitiated(pc),a0
								st.b					(a0)

.ciaIntRunning
								RESTOREREGISTERS
								rts

initAudioTrack	; init music track. Loads File "mus" from current stage folder; loads file "bos" as needed
	; ATTN: outro music is too big for music memory. Partially overwrittes object memory. Dont bother as it is not needed in stage 5.

								lea						vars(pc),a6
								clr.l					musicTrackB-vars(a6)
								lea						mainMusicFile(pc),a0

								move.l					musicMemory(pc),d2
								bsr						loadCopList
								lea						vars(pc),a6
								move.l					d2,musicTrackB-vars(a6)

								move.b					gameStatus,d0
								andi.w					#$f,d0
								move.w					oneOrTwoTracksFlag(pc),d1
								move.l					d6,a0
								btst					d0,d1
								beq						startAudioTrack																																																								; load boss-track only ingame
								move.l					a0,-(sp)
								lea						bossMusicFile(pc),a0
								bsr						loadCopList
								move.l					(sp)+,a0
startAudioTrack
								tst.l					a0
								beq						.q
								lea						CUSTOM,a6
								sub.l					a1,a1																																																										; get samples from mod-file
								clr.l					d0
								sf.b					d0																																																											; 0=start at beginning
								bsr						_mt_init																																																									;(a6=CUSTOM, a0=TrackerModule, a1=Samples, d0=StartPos.b)	; init audiotrack
								lea						CUSTOM,a6
								move					#musicFullVolume,d0
								bsr						_mt_mastervol																																																								; set music volume

								clr.l					d0
								btst					#optionMusicBit,optionStatus(pc)
								bne						.noMusic
								lea						mt_chan1+_mt_Enable(pc),a4
								st.b					(a4)
								move.b					#%0011,d0
.noMusic
								bsr						_mt_musicmask																																																								; set music mask to 0 incase of noMusic flag set
.q
	;RESTOREREGISTERS
								rts
oneOrTwoTracksFlag
								dc.w					%01111100<<1																																																								;added one bit, due to architecture of maingame controller
mainMusicFile
								dc.b					"mus",0
bossMusicFile
								dc.b					"bos",0



    ; subroutine for precalc of 16 color fades and converting to Amiga AGA-Table. Result: 2 x .w lo/hi-palette per color
shotColorFader:
precalcColorFade
								moveq					#shotColIterations-1,d6

.1
								move.l					a1,a3
								move.l					a2,a4
    ;lea \1,a1
    ;lea \2,a2
								move.w					#3,d7
								moveq					#0,d3
								move.l					d6,d4
								asl.w					#4,d4
								divu					#shotColIterations,d4

    ;integer( A1+ i/A * (A2-A1) )
.2
								moveq					#0,d0
								moveq					#0,d1
								move.b					(a3)+,d0																																																									; d0 = color0
								move.b					(a4)+,d1																																																									; d1 = color1

								move.w					d1,d2
								sub.w					d0,d2																																																										; d2 = c1-c0
								muls.w					d4,d2																																																										; d2 = (c1-c0)*alpha
								asr.w					#4,d2																																																										; d2 = ((c1-c0)*alpha)>>8

								addx.w					d3,d2
								add.w					d2,d0																																																										; d0 = c0 + ((c1-c0)*alpha))>>8
								move.b					d0,(a0)+
								dbf						d7,.2
								dbf						d6,.1

								moveq					#shotColIterations-1,d7
.3
								move.l					-(a0),d0
								move.l					d0,d1
								swap					d1
								move					d1,d2
								lsl.w					#8,d1
								lsl.w					#4,d2
								andi					#$f00,d1																																																									; lobyte    r
								andi					#$f00,d2																																																									; hibyte    r

								move.w					d0,d3
								asr						#4,d3
								move					d3,d4
								lsr						#4,d4
								andi					#$f0,d3																																																										; lobyte    g
								andi					#$f0,d4																																																										; hibyte    g

								move.w					d0,d5
								move					d5,d6
								lsr						#4,d6
								andi					#$f,d5																																																										; lobyte    b
								andi					#$f,d6																																																										; hibyte    b
								or						d1,d5
								or						d3,d5																																																										; lobyte rgb
								or						d2,d6
								or						d4,d6																																																										; hibyte rgb
								move.w					d5,(a0)
								move.w					d6,2(a0)
								dbra					d7,.3
								rts

    ; MARK: SUBROUTINES ENDS

