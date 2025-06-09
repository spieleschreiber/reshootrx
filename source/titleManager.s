



        ; MARK: - TITLESCREEN INIT
mainTitle

					IF					INITWITH=30
					lea					gameStatusLevel(pc),a0
					move.w				#-1,(a0)																														; reset level status pointer
					ENDIF
					lea					vars(pc),a5
					sf.b				gameInActionF-vars(a5)																											; disable gamecode in interrupt
					sf.b				blitterManagerFinished-vars(a5)																									; no buffer swapping
					clr.w				escalateIsActive-vars(a5)																										; reset escalateIsActive, dialogueIsActive,
					sf.b				killShakeIsActive-vars(a5)																										; reset killShakeIsActive
					sf.b				plyCheatEnabled+plyBase-vars(a5)																								; reset cheatflag

					IF					INITWITH=30
					sf.b				introLaunched-vars(a5)																											; temp to always start music
					ENDIF
					tst.b				introLaunched-vars(a5)
					bne					.keepIntroMusicPlayin																											; keep start music playing if first init of titlescreen
					IF					INITWITH=30
					sf.b				d0
					bsr					installAudioDriver																												; for testing only. Launch if titlescreen is init'ed first
					ENDIF
					move.w				#-1,gameStatusLevel-vars(a5)
					bsr					initAudioTrack
.keepIntroMusicPlayin
					sf.b				introLaunched-vars(a5)																											; temp to always start music
					clr.b				fxInit-vars(a5)

;    tst.b gameStatus
 ;   bpl .skipFirstStart             ; init fade-coplist and copFadeCnt to copy with first fade
  ;  bclr.b #7,gameStatus      ; killbit, indicating that first launch of titlescreen has happened
;.skipFirstStart

					sf.b				titleHighFlag-vars(a5)
					move.w				#-1,gameStatusLevel-vars(a5)

					lea					CUSTOM,a6
	;move.w #DMAF_BPLEN,DMACON(a6); sprites and bpl dma off
	;	move.w #DMAF_SETCLR|DMAF_SPRITE,DMACON(a6); enable sprites
	;move #BRDRBLNKF,BPLCON3(a6); 	black screen
					clr.w				COLOR00(a6)

					bsr					blankSprite
					jsr					prepareDisplay

	; prepare artwork (64 colors, 6 bitplanes)

					lea					titlePicFilename(pc),a0
					move.l				a0,d1
					bsr					createFilePathOnStage
					jsr					GetFileInfo
					tst.l				d0
					beq					errorDisk
					move.l				(fib_Size.w,pc),d7																												; fetch size of raw picture
					move.l				d7,tempVar+28
					move.l				d7,d3
					divu				#6,d7


	; prep bitplane pointers
					lea					copBPLPT,a5
					move.l				artworkBitplane(pc),d1
					move.l				d1,d2
					moveq				#7,d6
.prepBitplaneAdress
					move				d1,6(a5)
					swap				d1
					move				d1,2(a5)
					swap				d1
					add.l				d7,d1
					lea					8(a5),a5
					dbra				d6,.prepBitplaneAdress


	; load title artwork


					lea					titlePicFilename(pc),a0
					move.l				a0,d1
					bsr					createFilePathOnStage
					bsr					loadFile
					tst.l				d0
					beq					errorDisk


	;WAITSECSSET 6
	;WAITSECS

					lea					scrMngOffset(pc),a0
					move.w				#screenManagerLv0-jmpSrcMngOffset,(a0)


					lea					CUSTOM,a6																														; setup copperlist
	;clr.w copBPL2ModOffset+2

					move.w				#$38,DDFSTRT(a6)
					move.w				#$a0,DDFSTOP(a6)
					move.w				#$2ca6,COPDIWSTRT+2																												; window
					move.w				#$b100,COPDIWHIGH+2
					move.w				#$289c,DIWSTOP(a6)
					move				#ECSENAF!BPU1F!BPU2F!CONCOLF,copBPLCON0+2

					move.w				#$8800,copBPLCON1+2
					move.w				#KILLEHBF!%111111,copBPLCON2+2
					move.w				#BRDSPRTF|BRDRBLNKF,copBPLCON3+2
					move.w				#%0000000000001111,FMODE(a6)																									;64 pixel sprites
	;move.w #BRDSPRTF|SPRES1F,CUSTOM+BPLCON3
	;clr.w CUSTOM+Color00
	;move.w #$32b4,COPDIWSTRT+2
	;move.w #$3920,COPDIWHIGH+2	; set transition

	;WAITSECSSET 6
	;WAITSECS

					WAITVBLANK
					lea					(titleCopFilename,pc),a0
					bsr					loadMainCopList
					lea					copGameDefault,a0																												; copy return address to coplist
					movem.l				(a0),d0-d3
					movem.l				d0-d3,(a1)																														; copy return cmd chain to eof coplist




	; dynamic store in tempvar:  0.l -> SPR0PTH, +4.l -> SPR0POS, +8.l COLOR17, +12.l SPR0PTH+SPR0POS II (spieleschreiber), +16.l COLORS29-31 engine colors, +20.l pointer to BPLCON1-list
	; predef´d store in tempvar: +24.l Base of coord conv table, +28.l -> size of artwork, +32.w fadeCounter,+34.w pointer to high ranking display name,+36.w pointer to high ranking data table
	; fetch dynamic pointers from coplist

					move.l				copperGame(pc),a0
					lea					(tempVar,pc),a2
.findPointers
					cmpa.l				a1,a0
					bhi					.foundPointers
					lea					4(a0),a0
					cmpi.w				#NOOP,(a0)
					bne					.findPointers
					move.w				2(a0),d0
					lea					4(a0),a0
					move.l				a0,(a2,d0*4)
					bra					.findPointers
.foundPointers

					clr.l				d7
					lea					titleSprites,a5																													; init sprite-DMA / title logo
					move.l				#$445e6d00,d5
					move.w				#titleSpritesOffset,d7
					bsr					titleShowSprites
					suba				d7,a0
					sub.b				#14,1(a0)
					suba				d7,a0
					sub.b				#14,1(a0)

	; prepare text sprites

					move.l				(tempVar,pc),a0
					move.l				mainPlanes+4(pc),a1
					bsr					installSpritePointers

	; prepare spieleschreiber sprites

					move.l				(12+tempVar,pc),a0
					move.l				#titleSpieleschreiber,d0
					move.l				#titleSpieleschreiber+(titleSpieleschreiberEnd-titleSpieleschreiber)/2,d1
					move.w				d0,6(a0)
					move.w				d1,8+6(a0)
					swap				d0
					swap				d1
					move.w				d0,2(a0)
					move.w				d1,8+2(a0)

					move.l				tempVar+28(pc),d7																												; fetch size of raw picture
					move.l				artworkBitplane(pc),a6																											; create conversion table x/y coords to sprite address
					lea					(a6,d7),a6																														; pointer to position conversion table
					bsr					createTableTextSpritesCoord

	;#MARK: Check and enter new highscore entry

					lea					newHighText(pc),a6
					move.b				#14,(a6)																														; reset "new"-text
					lea					tempVar+36(pc),a5
					clr.l				(a5)																															; reset marker to ranking table
				; attn: (a5) accessed again incase of highscore

					lea					score(pc),a3
					cmpi.l				#$99999999,(a3)
					bne					.ScoreBugfix																													; ugly fix for some bug that lead to having a score of 99999999 when entering highscore view. Cause  remains mysterious
					clr.l				(a3)
.ScoreBugfix
					IFNE				HIGHSCORE_OVERRIDE
					move.l				#HIGHSCORE_OVERRIDE,(a3)																										; MODIFY SCORE IF NEEDED FOR TESTING
					ENDIF

					lea					highData(pc),a4																													; new hiscore?
					move.l				(a3),d1
					moveq				#9,d7																															; no of high entrys
.compareHigh
					move.l				(a4),d0
					cmp.l				d0,d1
					bhi.b				.gotHigh																														; found new highscore – prepare setup
					lea					8(a4),a4
					dbra				d7,.compareHigh
					bra.w				.buildHighDisplay																												; no new highscore - further preps

	; copy score to highscore table
.gotHigh
					moveq				#10,d6
					sub.b				d7,d6
					move.b				d6,titleHighFlag

					move				d6,d4
					muls				#(titleHighHeroesEnd-titleHighHeroes)/10,d4
					sub					#4,d4
					move.w				d4,(a5)+																														; store pointer to displayed name

					move				d6,d4
					lsl					#3,d4
					sub					#4,d4
					move.w				d4,(a5)																															; ; store pointer to database name

					add.b				#2,d6
					move.b				d6,1(a6)																														; display "new" at y-coord

					lea					highDataEnd(pc),a1
					lea					-8(a1),a0
					tst.b				d7
					beq					.skipMove
					subq				#1,d7
.moveHigh
					move.l				-(a0),-(a1)
					move.l				-(a0),-(a1)
					dbra				d7,.moveHigh
.skipMove
					move.l				d1,(a0)																															; copy score to hero table

	; generate alphanumerical code for upload score to website. BCD-score in d0.l converted to string with numbase 23 (vs. bin, dec, hex etc.) plus checksum

.numBase			=					23
.encodeHighscore
					lea					scoreHighEncoded+9(pc),a0
					move.l				#"XXXX",d1
					move.l				d1,d2
					movem.l				d1-d2,-9(a0)																													; reset encoding space. Two rightmost numbers do not need reset, as they are always written
					clr.l				d1
					clr.l				d2
					clr.l				d7

					move.l				score(pc),d0																													; fetch last score
					move.l				#.numBase,d3																													; load code numbase
.loopDigit
					divul.l				d3,d1:d0																														; d1 = remainder, d0 = result
					beq					.lastDigit
					add.l				d1,d2
					add.b				#"A",d1
					move.b				d1,-(a0)																														; store -> encoding space
					bra					.loopDigit
.lastDigit
					add.l				d1,d2
					add.b				#"A",d1
					move.b				d1,-(a0)																														; store leftmost digit
					divul.l				d3,d1:d2																														; calc checksum. ; d1 = remainder, d2 = result

					move.b				#.numBase-1,d0
					sub.b				d1,d0
					add.b				#"A",d0
					move.b				d0,-(a0)																														; store remainder of checksum


					IF					0=1
; decoding needed only for testing ...

    ; Highscore Decoder
    ; Decode 8 char alphanumerical string into number in Motorola bcd (binary coded decimal)-format: $11 means 11 dec, $20 means 20 dec)

    ;	-> field of 8 bytes / chars. Can contain letters a to x, where a to w stand for numerical value, x stands for end of field

		; ATTN: Read doc "how to decode rp3 highscore" for detailed instruction on how the code is built
    ;	Examples
    ;
    ; 	RF 		decodes to 		5
    ;	DT			->	 		13
    ;	OWJ			->			203
    ;	DBAS		->			223
    ;	WBAW		->			227
    ;	UBBA		->			228
    ;	TBBB		->			229
    ;	DBJAJ		->			4229
    ;	SBQCFD		->			74229
    ;	QQPSWE		->			474229
    ;	KQIJJDN		->			6474722
    ;	MRAQNPEO	->			946474795
    ;
    ;	You would start decoding at the rightmost character.

    ;	num value is based on a number system with number base 23 (as opposed to the usual 2,10 or 16)

    ;	Read rightmost byte / digit. Scale it down to a number of 0 to 22 by subtracting 65 (representing ASCII-value of the letter "A") of byte
    ;	Multiply result with 1, copy to output result
    ;	Read digit second to the right. Scale it down to a number of 0 to 22
    ;	Multiply the result with 23, add to output result
    ;	Read digit third to the right. Scale it down to a number of 0 to 22
    ;	Multiply the result with 23*23, add to output result
    ;	Read digit fourth to the right. Scale it down to a number of 0 to 22
    ;	Multiply the result with 23*23*23, add to output result
    ; 	and so on, until digit second to the left is reached
    ;
	;	The leftmost digit contains checksum is NOT to be added to output result

    ;	d4 -> 4 bytes output result in bcd-format (score)


					lea					scoreHighEncoded+9(pc),a0																										; pointer to end of string
    ;move.b #"F",-3(a0)
					clr.l				d2
					clr.l				d4

					move.l				#.numBase,d3																													; number base = 23 (as opposed to the usual 2,10 or 16)
					move.l				#1,d7																															; reset digitshifter
.fetchDigit		; loop through string
					clr.l				d0
					move.b				-(a0),d0																														; read rightmost char
					cmpi.b				#"X",d0																															; char is X, Y or Z? Quit!
					bge					.reachedLastDigit
					sub.b				#"A",d0																															; sub 65. A -> 0, B -> 1, C -> 2 ... W = 22
					add.l				d0,d2																															; add result to checksum
					move.l				d0,d1																															; save for later use
					mulu.l				d7,d0																															; Multiply result with digitshifter
					add.l				d0,d4
					mulu.l				d3,d7																															; modify digitshifter by multiplying it with numBase 23. 1. loop -> 1, 2. loop = 1*23, 3. loop = 23*23 = 529, 4. loop = 23*23*23 = 12167 ...
					bra					.fetchDigit

.reachedLastDigit
					sub.l				d0,d4																															; adjust outputvalue
					sub.l				d1,d2																															; adjust checksum adder
					divul.l				d3,d0:d2																														; divide checksum by 23. ; d0 = remainder, d2 = result
					move.b				#.numBase-1,d3																													; what is 22 minus ...
					sub.b				d2,d3																															; ... result of division?
					cmp.b				d3,d1																															; d1 = encoded checksum, d3 = calculated checksum. Identical?
					beq					.outputThis																														; yes!
					illegal																																				; no
.outputThis
					ENDIF

	;#MARK: Create displayable Highscore table

.buildHighDisplay

					bsr					resetScores

					moveq				#9,d7
					lea					highData(pc),a3
					lea					titleHighHeroes(pc),a4
.drawHeroesLoop
					lea					(a3),a0																															; pointer to fetch number
					lea					9(a4),a1																														; pointer to draw number
					bsr.w				writeScoreToCharSprites
		; a0 now contains pointer to highData origin
		; a1 now contains pointer to number text+1
					lea					4(a1),a1
					move.b				#"$",(a1)+																														; red colors
					move.w				(a0)+,(a1)+
					move.b				(a0)+,(a1)+																														; copy name

					lea					8(a3),a3
					lea					(titleHighHeroesEnd-titleHighHeroes)/10(a4),a4
					dbra				d7,.drawHeroesLoop

					lea					scoreHighEncoded+1(pc),a0																										; copy encoded chars to displayable text
					lea					titleHighWeb+10(pc),a1

					move.l				#"    ",d0
					move.l				d0,d1
					movem.l				d0-d1,(a1)																														; clear display area

					clr.w				d7
.fetchEntry
					move.b				(a0)+,d0
					add					#1,d7
					cmpi.b				#"X",d0
					bge					.fetchEntry
					lsr					#1,d7
.fetchCode
					move.b				d0,(a1,d7)
					add					#1,d7
					move.b				(a0)+,d0
					cmpi.b				#"X",d0
					blt					.fetchCode																														; write centered code into display area

	;movem.l (a0),d0-d1


					bsr					titleClrTextArea


					WAITVBLANK
					lea					CUSTOM,a6																														; setup copperlist
					move.l				#coplist,COP1LC(a6)
					move.w				COPJMP1(a6),d0	: re-init copper
					move.w				#DMAF_SETCLR!DMAF_COPPER,DMACON(a6)																								; enable copper, bitplanes, sprites
;	WAITSECS 2	; just for drama ...
					move.w				#DMAF_SETCLR!DMAF_BPLEN|DMAF_SPRITE,DMACON(a6)																					; enable copper, bitplanes, sprites
	;#MARK: Title Mainloop
					RSRESET
titStatEnterHigh	rs.b				1
titStatShowHigh		rs.b				1
titStatShowCreds	rs.b				1
titStatShowMsg		rs.b				1
titStatShowOptions	rs.b				1
titStatInitGame		rs.b				1
					bsr					titleClrTextArea
					lea					tempVar(pc),a0
					lea					fastRandomSeed(pc),a4
					lea					font(pc),a5																														; pointer font
					move.l				24(a0),a6																														; pointer to sprite->text coord conv table

					tst.b				titleHighFlag(pc)
					sne					d7
					add.b				#1,d7
					move.b				d7,titleViewIndx

					lea					titleCursor(pc),a3
					clr.w				(a3)																															; set cursor position to initial position

					move.w				#titleCounter,32(a0)																											; set transition counter
					lea					titleMessage(pc),a0
					st.b				(a0)																															; prepare reset of "titleMessage"
titleCounter		SET					$40*6+$40
titleFirstView		SET					titStatShowHigh																													; defines first and last screen within title basic loop
titleLastView		SET					titStatShowMsg
titleMainLoop
	;QUITNOW
					bsr					titleKickVessel
					bsr					titleJetEngines
					bsr					titleFlashFirebutton
					WAITVBLANK

					bsr					titleTestFirebutton

;	QUITNOW

					lea					tempVar(pc),a0
					sub					#1,32(a0)
					bmi					.switchView
					move				#$3f,d3
					move.w				32(a0),d0
					cmpi				#$3f,d0
					bgt					.tstFadeOut
					andi				#$3f,d0
					move				d0,d3
					bra					.noTransition
.tstFadeOut
					cmpi				#titleCounter-$3f,d0
					blt					.noTransition
					neg					d0
					andi				#$3f,d0
					move				d0,d3
.noTransition
					clr.w				d4
					clr.w				d7
					move.b				titleViewIndx(pc),d7
					move.w				titleJumpTable(pc,d7.w*2),d7
;	pea titleMainLoop(pc)	; return from sub to loop entry
.off					jsr					.off(pc,d7.w)
					bra					titleMainLoop

.switchView
					move.w				#titleCounter,32(a0)
					lea					titleMessage(pc),a0
					st.b				(a0)																															; prepare reset of "titleMessage"
					lea					titleViewIndx(pc),a0
					add.b				#1,(a0)
					cmpi.b				#titleLastView,(a0)
					bls					titleMainLoop
					move.b				#titleFirstView,(a0)
					bra					titleMainLoop
		; titles view-specific code


	;#MARK: Title Init Game
titleInitGame
					lea					copperGame(pc),a3
					movem.l				(a3),a3/a4																														; start coplist, end of coplist
					sub.l				a3,a4
					move.w				a4,d7
					lsr					#2,d7
.findBPLCON3
					lea					4(a3),a3
					cmpi.w				#BPLCON3,(a3)
					beq					.modBPLCON3
.retMod
					dbra				d7,.findBPLCON3

					lea					transitionFlag(pc),a1
					move				#transitionOut,(a1)																												; init fadeout
.fadeOut
					WAITVBLANK
					bsr					titleKickVessel
					bsr					titleJetEngines
					lea					titleOptions(pc),a2
					move				#$3f,d3
					bsr					drawTextToSprites
					lea					transitionFlag(pc),a1
					tst.w				(a1)
					bne.b				.fadeOut

					lea					CUSTOM,a6
					move.w				#DMAF_COPPER!DMAF_BPLEN!DMAF_SPRITE,DMACON(a6)																					; sprites and bpl dma off
					lea					4(sp),sp																														; pull return adress of stack
					rts																																					; return to main game controller
.modBPLCON3
					or.w				#BRDRBLNKF,2(a3)
					bra					.retMod

		;#MARK: Title Enter High

titleEnterHigh
					cmpi				#$40,32(a0)
					bhi					.fadeIn
					move.w				#$40,32(a0)																														; text only fade in, then keep solid state
.fadeIn
					bsr					titleEnterInitials
					lea					titleHighEnterA(pc),a2
					btst				#5,AudioRythmFlagAnim(pc)
					bne					.switch
					lea					titleHighEnterB(pc),a2
.switch
					bsr					drawTextToSprites
					lea					titleHighHeroes(pc),a2
					bsr					drawTextToSprites

					tst.b				optionStatus(pc)
					bmi					.highDiff
					lea					newHighText(pc),a2
					bra					drawTextToSprites
.highDiff
					lea					titleHighWeb(pc),a2																												; also displays "NEW"-msg
					bra					drawTextToSprites

	;#MARK: Title Show Highscore Table
titleShowHigh
					lea					titleHighTitle(pc),a2
					bsr					drawTextToSprites
					lea					titleHighHeroes(pc),a2
					bra					drawTextToSprites

	;#MARK: Title Show Message
titleShowMsg	; spawn single messages insync to music beat
					lea					titleMessage(pc),a0
					tst.b				(a0)
					bmi					.resetMsg																														; first call, text table needs some adjusting
					lea					1(a0),a2
					bsr					drawTextToSprites
					cmpi.b				#20,AudioRythmFlagAnim(pc)
					beq					.newText
					cmpi.b				#9,AudioRythmFlagAnim(pc)
					beq					.newText
					cmpi.b				#14,AudioRythmFlagAnim(pc)
					bne					titleReturn
.newText
					tst.b				(a2)
					bmi					titleReturn
					sf.b				-(a2)
					bra					titleReturn
.resetMsg
					sf.b				(a0)+
.resetMessage		; hide all messages
					tst.b				(a0)+
					bmi					.isNeg
					bne					.resetMessage
.isNeg
					st.b				-1(a0)																															; set end of line flag
					tst.b				(a0)																															; reached end of titleMessage?
					bmi					titleReturn
					bra					.resetMessage

		;#MARK: Title Show Credits
titleShowCreds
					lea					titleCredits(pc),a2
					bsr					drawTextToSprites
					rts

		;#MARK: Title Show Options
titleMaxOptions		SET					2																																; number of options
titleShowOptions
	;QUITNOW
					SAVEREGISTERS
					lea					tempVar(pc),a0
					cmpi				#$40,32(a0)
					bhi					.fadeInn
					move.w				#$40,32(a0)																														; text only fade in, then keep solid state
.fadeInn
					IFEQ				(RELEASECANDIDATE||DEMOBUILD)
	; choose stage, only in devbuild or prerelease build
					move.b				gameStatus(pc),d4
					add.b				#"1"-statusLevel0,d4
					move.b				d4,titleOptionsStagePointer+18

					moveq				#0,d4
					moveq				#5,d7																															; keys 1-6
.queryDirectionals
					tst.w				keyArray+Key1(pc,d7*4)
					bne					.action
					dbra				d7,.queryDirectionals
					bra					.noAction
.action
					add.w				#statusLevel0,d7
					move.b				d7,gameStatus
.noAction
					ENDIF

					move.l				plyBase+plyJoyCode(pc),d0
					lea					titleOptions(pc),a0
					lea					titleCursor(pc),a6
					lea					optionStatus(pc),a5

					move				d0,d1
					swap				d0
					cmp.w				d0,d1
					beq					titleNoAction

    ; process up and down
titleControlOptions

	; handle Konami cheat code query
					tst.b				d0
					beq					.retUnchanged																													; no button modified

					lea					.cheatCode(pc),a2																												; cheat combo check
					clr.w				d5
					move.b				(a2),d5
					move.b				1(a2,d5.w),d3
					add.b				#1,(a2)
					cmp.b				d3,d0																															;combo continued?
					bne.b				.resetCheatCombo
					cmpi.b				#7,d5
					blt.b				.retUnchanged
	; cheat enabled
					lea					plyBase(pc),a2
					st.b				plyCheatEnabled(a2)
					PLAYFX				fxSpawn
.resetCheatCombo
					clr.b				(a2)
.retUnchanged

					clr.w				d3
					move.b				(a6),d3
					move.b				d3,titleCursorOld-titleCursor(a6)
					move.w				titleOption(pc,d3*2),d3
					move.w				(a0,d3),d3
					btst				#JOY_DOWN,d0
					beq					.tstDown
					cmpi.b				#2,(a6)
					bge					.noOptionChange
					add.b				#1,(a6)
					bra					.optionProcessed
.cheatCode
					dc.b				0
					dc.b				08,08,04,04,01,02,02,01																											; Konami cheat sequence UUDDRLLR
					even

.tstDown
					btst				#JOY_UP,d0
					beq					.noOptionChange
					tst.b				(a6)
					beq					.noOptionChange
					sub.b				#1,(a6)
					bra					.optionProcessed
.noOptionChange
					move.b				#0,d3
.optionProcessed
					clr.w				d7
					move.b				(a6),d7

					moveq				#titleMaxOptions,d6
.resetOptions
					move.w				titleOption(pc,d6*2),d5
					andi.b				#$fe,2(a0,d5)
					dbra				d6,.resetOptions

					moveq				#5,d5
					add					d7,d5																															; prepare bitmarker for toggle code

					move.w				titleOption(pc,d7*2),d7
					or.b				#1,2(a0,d7)
					move.w				(a0,d7),d6
					move.w				d3,titleOptionsClearColW-titleOptions(a0)																						; clear recent white text
					move.w				d6,titleOptionsClearColR-titleOptions(a0)																						; clear old red text


	; toggle option
					btst				#JOY_LEFT,d0
					beq					.tstRight
					bclr				d5,(a5)
					bra					.toggleProcessed
.tstRight
					btst				#JOY_RIGHT,d0
					beq					.toggleProcessed
					bset				d5,(a5)


.toggleProcessed
					move				d5,d6
					btst				d5,(a5)
					sne					d5
					lsl.b				#7,d5																															; 0 or $80
					sub					#5,d6
					move.w				titleOptionToggle(pc,d6*2),d7
					andi.b				#$7f,1(a0,d7)
					or.b				d5,1(a0,d7)																														; copy bit into y-coord. If <$80 msg will not be displayed
					eor.b				#$80,d5
					andi.b				#$7f,8+1(a0,d7)
					or.b				d5,8+1(a0,d7)

					RESTOREREGISTERS
					lea					titleOptions(pc),a2
					bsr					drawTextToSprites
	;sub.b #-1,titleOptionsClearColW-titleOptions+1(a0)	; outcommented as purpose is unclear, and caused bad bug / crash
	;sub.b #-1,titleOptionsClearColW-titleOptions+1(a0)
					rts
titleNoAction
					RESTOREREGISTERS
					lea					titleOptions(pc),a2
					bra					drawTextToSprites
					IFNE				(RELEASECANDIDATE||DEMOBUILD)
titleOption
					dc.w				titleOptionsMsc-titleOptions, titleOptionsSFX-titleOptions, titleOptionsDiff-titleOptions
titleOptionToggle
					dc.w				titleToggleMsc-titleOptions, titleToggleSFX-titleOptions, titleToggleDiff-titleOptions
					ELSE
titleOption
					dc.w				titleOptionsMsc-titleOptions, titleOptionsSFX-titleOptions, titleOptionsDiff-titleOptions, titleOptionsStage-titleOptions
titleOptionToggle
					dc.w				titleToggleMsc-titleOptions, titleToggleSFX-titleOptions, titleToggleDiff-titleOptions
					ENDIF
	;#MARK: Several functions used within title display

titleFlashFirebutton
	; flash Firebutton-message insync to music
					clr.w				d7
					move.b				AudioRythmFlagAnim(pc),d7
					sne					d7
					andi				#2,d7																															; 0 or 2	; flash freq

					tst.b				titleViewIndx(pc)
					seq					d6
					andi.w				#1,d6																															; 1 = highscore entry view, 0 = basic view
					lsl					d6,d7																															; 0 or (2 / 4)	; indicator (0,2,4)
					move.w				.titleFBmessages(pc,d7),d7																										; pointer to message
					lea					(titleFirebutton,pc,d7),a2																										; fetch msg adress
					move				#$3f,d3
					bra					drawTextToSprites
.titleFBmessages
					dc.w				0,titleFirebuttonB-titleFirebutton,titleFirebuttonC-titleFirebutton

titleEnterInitials
					SAVEREGISTERS
					lea					tempVar+36(pc),a5
					move.l				(a5),d5
					lea					titleCursorFlash(pc),a3
					lea					titleHighInitials(pc),a4
					lea					titleCursor(pc),a6

					clr.w				d7
					move.b				(a6),d7																															; fetch cursor position

					lea					plyBase(pc),a0
					move.l				plyJoyCode(a0),d0
					move				d0,d1
					swap				d0
					cmp.w				d0,d1
					beq					.charProcessed
	; process char position index left and right

					btst				#JOY_LEFT,d0
					beq					.testRight
					tst.b				(a6)
					beq.b				.indexProcessed
					subq.b				#1,(a6)
					clr.b				(a3)
					bra					.indexProcessed
.testRight
					btst				#JOY_RIGHT,d0
					beq					.indexProcessed
					cmpi.b				#2,(a6)
					bge.b				.indexProcessed
					addq.b				#1,(a6)
					clr.b				(a3)
.indexProcessed


    ; process char up and down

					btst				#JOY_UP,d0
					beq					.testDown
					cmpi.b				#"Z",(a4,d7)
					bge.b				.charProcessed
					add.b				#1,(a4,d7)
					bra					.charProcessed
.testDown
					btst				#JOY_DOWN,d0
					beq					.charProcessed
					cmpi.b				#"A",(a4,d7)
					ble.b				.charProcessed
					sub.b				#1,(a4,d7)
.charProcessed
					move.w				(a4),d6
					move.b				2(a4),d4
					lea					highData(pc),a1
					move.w				d6,(a1,d5.w)																													; copy to database
					move.b				d4,2(a1,d5.w)
					swap				d5
					lea					titleHighHeroes(pc),a1
					lea					(a1,d5.w),a1
					move.b				#"%",-1(a1)																														; white color
					move.w				d6,(a1)																															; copy to display
					move.b				d4,2(a1)

					add.b				#1,(a3)
					btst.b				#4,(a3)
					bne					.keepChar
					move.b				#" ",(a1,d7)
.keepChar
.noHigh
					RESTOREREGISTERS
					rts

titleJetEngines
					move.l				(tempVar+16,pc),a0																												; fetch pointer to coplist colors regs
					tst.l				a0
					beq					.quit
					move.w				frameCount+4(pc),d7
					btst				#2,d7
					seq					d7
					andi				#6<<1,d7
					move.l				(.colVar,pc,d7),d1																												; read color values
					move.w				d1,6(a0)
					swap				d1
					move.w				d1,2(a0)
					move.l				(4+.colVar,pc,d7),d1																											; read color values
					move.w				d1,14(a0)
					swap				d1
					move.w				d1,10(a0)
					move.l				(8+.colVar,pc,d7),d1																											; read color values
					move.w				d1,22(a0)
					swap				d1
					move.w				d1,18(a0)
.quit
					rts
.colVar
	;dc.w $fd6,$ff4,$ff7,$ff9,$ffa,$ffd	; original colors
	;dc.w $fc4,$ff0,$ff4,$ff8,$ff8,$ffa	; variations
					dc.w				$cb4,$cc2,$cc5,$cc7,$cc8,$ccb																									; original colors
					dc.w				$cb2,$cc0,$cc2,$cc6,$cc6,$cc8																									; variations

titleKickVessel
					move.l				tempVar+16(pc),a0
					tst.l				a0
					beq					.quit
					lea					-$2a(a0),a0

					move.b				AudioRythmFlagAnim(pc),d0
					beq					.ss
					sub.b				#1,AudioRythmFlagAnim
.ss
					btst				#1,d0
					seq					d7
					andi				#$37,d7
					eor					d7,d0																															; count up to $1f, count down to $0

					clr.l				d4
					move				d0,d4
	;divs #16,d0
					lsr					#5,d0
					add					#$1,d0
					divs				#30,d4																															; prepare max. dynamic x-range
					add					#1,d4
	;sub d4,d0
					andi.w				#%01111,d4
					move.w				(a4),d1																															; get rnd number
					andi				#$07,d1																															; prepare max. dynamic y-range
					lsr					d0,d1																															; modify y-range insync to audio beat

					lsl					#5,d1																															; calc mod offset
					sub.w				#8,d1																															; adjust
					move				d1,(a0)																															; write bplmod
					move				d1,4(a0)


					move.l				tempVar+20(pc),a0																												; fetch pointer to coplist
					tst.l				a0
					beq					.quit
					lea					20+6(a0),a0																														; adjust
					moveq				#$4,d5
					moveq				#$1f,d6
					move				#displayWindowStop+$100-$c8,d7																									; no of scanlines
					lea					fastRandomSeed(pc),a4
.1
					movem.l				(a4),d1-d2																														; ABCD
					swap				d2																																; DC
					add.l				d2,(a4)																															; AB + DC
					add.l				d1,4(a4)																														; CD + AB
					and					d6,d1
					lsr					d4,d1
					move.w				224+scrollXbitsTable(pc,d1*2),d1
					move				d1,d2
					lsl					d5,d2
					or					d2,d1
					move.w				d1,(a0)
					lea					28(a0),a0
					dbra				d7,.1
.quit
					rts

titleTestFirebutton

					move.w				plyBase+plyJoyCode(pc),d7
					btst				#STICK_BUTTON_ONE,d7																											; check firebutton 1
					bne.b				.fireButton

					IFEQ				(RELEASECANDIDATE||DEMOBUILD)
					tst.w				keyArray+LShift(pc)
					bne.w				.quit
					tst.w				keyArray+RShift(pc)
					bne.w				.quit
					ENDC
					rts
					IFEQ				(RELEASECANDIDATE||DEMOBUILD)
.quit
					QUITNOW
					ENDIF

.fireButton

					lea					titleViewIndx(pc),a0
					tst.b				(a0)
					bne					titleInitOptions																												; status = highscore entry
					SAVEREGISTERS
					jsr					saveHighscores
					RESTOREREGISTERS
					add.b				#1,(a0)																															; yes

					lea					titleCursor(pc),a3
					move.b				#titleMaxOptions,(a3)																											; set cursor position to "Start Mission" in option screen
					bset.b				#4,1(a3)
					bsr					titleEnterInitials																												; make sure new initials get fully displayed

					lea					tempVar(pc),a0
					move.w				#$40*6,32(a0)

					lea					titleHighHeroes(pc),a2																											; set draw color of initials to all white
					moveq				#9,d7
.setWhite
					move.b				#"%",21(a2)																														; initials
					lea					(titleHighHeroesEnd-titleHighHeroes)/10(a2),a2
					dbra				d7,.setWhite

					clr.w				d4
					moveq				#$3f,d3
					lea					clearHighFrags(pc),a2
					lea					newHighText(pc),a0
					move.w				(a0),(a2)
					bsr					drawTextToSprites																												; clear undesired text fragments

.waitRelease

					WAITVBLANK
					bsr					titleKickVessel
					bsr					titleJetEngines
					clr.w				d4
					moveq				#$3f,d3
					lea					titleHighHeroes(pc),a2
					bsr					drawTextToSprites
					lea					titleHighTitle(pc),a2
					bsr					drawTextToSprites

					move.w				plyBase+plyJoyCode(pc),d7
					btst				#STICK_BUTTON_ONE,d7																											; check firebutton 1
					bne.b				.waitRelease
titleReturn
					rts
titleInitOptions
					lea					tempVar+32(pc),a2
					move				#$30,(a2)																														; init fade out

					cmpi.b				#titStatShowOptions,(a0)
					bne					.initOptionLoop
					move.b				#titStatInitGame,(a0)																											; switch to init game code
					rts

	; fadeout current title text
.initOptionLoop
					bsr					titleKickVessel
					bsr					titleJetEngines
					lea					titleFirebuttonD(pc),a2
					bsr					drawTextToSprites																												; clear firebutton message during fadeout
					WAITVBLANK
					lea					tempVar+32(pc),a0
					sub					#1,(a0)																															; text faded out?
					bmi					.waitReleaseOptions																												; yes

					move.w				(a0),d3
					clr.w				d7
					move.b				titleViewIndx(pc),d7
					move.w				titleJumpTable(pc,d7.w*2),d7
	
.off				jmp					(.off,pc,d7.w)																													; keep displaying current view
					bra					.initOptionLoop

.waitReleaseOptions
	; fadeout current title text

					btst				#STICK_BUTTON_ONE,plyBase+plyJoyCode(pc)																						; check firebutton 1
					bne.b				.waitReleaseOptions

					move				#titleCounter,(a0)																												; reset fade
					lea					titleCursor(pc),a2
					move.b				#2,(a2)																															; set cursor to last position
					move.b				#titStatShowOptions,titleViewIndx-titleCursor(a2)
					SAVEREGISTERS
					move.l				plyBase+plyJoyCode(pc),d0
					lea					titleOptions(pc),a0
					move.l				a2,a6
					lea					optionStatus(pc),a5
					bra					titleControlOptions																												; run option display once to get text highlighted
titleClrTextArea
					SAVEREGISTERS
					move.l				tempVar+24(pc),a6																												; pointer to sprite->text coord conv table
					move.l				(a6),a6
					move.w				#2203,d7
.loopClr
					clr.l				(a6)+
					dbra				d7,.loopClr
					RESTOREREGISTERS
					rts
	;#MARK: Filenames and tables
titleJumpTable
					dc.w				titleEnterHigh-titleJumpTable
					dc.w				titleShowHigh-titleJumpTable
					dc.w				titleShowCreds-titleJumpTable
					dc.w				titleShowMsg-titleJumpTable
					dc.w				titleShowOptions-titleJumpTable
					dc.w				titleInitGame-titleJumpTable

titlePicFilename
					dc.b				"vessel.raw",0
					even
titleCopFilename
					dc.b				"title.cop",0
					even

drawTextToSprites ; text to sprite
	;	a2.l	->	pointer.l to text
	;	d3.l 	->	noisefilter index
	;	d4.w 	->	color indicator (0 or 8)
	;	attn: additional regs needed for  writeCharToSprites!
	;	-> a2.l		pointer to end of text
	;	destroys d0,d1,d2,d4,d5,d6,d7,a1
	;	y-coord = neg -> do not draw line
					movem.l				d3/a0,-(sp)
					lsr					#2,d3
					move.l				noiseFilter(pc,d3*2),d3
					clr.w				d7
.fetchCoords
					clr.w				d4																																; reset color indicator
					movem.w				(a2)+,d5
					clr.w				d6
					move.b				d5,d6
					bmi					.skipRow																														; y=-1 -> do not display text for the moment
					lsr					#8,d5
.fetchChar
					move.w				d5,d0
					move.w				d6,d1
					move.b				(a2)+,d7
					beq					.fetchCoords
					bmi					.lastChar
					cmpi.b				#"@",d7
					bgt					.gotLetter
					sub					#" ",d7
					move.b				charConvTable(pc,d7),d7
					bmi					.switchColor
					bsr					writeCharToSprites
					add					#1,d5
					bra					.fetchChar
.gotLetter
					sub					#49,d7
					bsr					writeCharToSprites
					add					#1,d5
					bra					.fetchChar
.lastChar
					movem.l				(sp)+,d3/a0
					rts
.skipRow
					tst.b				(a2)+
					bmi					.lastChar
					bne					.skipRow
					bra					.fetchCoords
.switchColor
					btst				#0,d7
					bne					.fetchChar
					eor					#8,d4
					bra					.fetchChar


writeCharToSprites
	;	a4.l	->	pointer.l to fastRandomSeed
	;	a5.l	->	pointer.l to font
	; 	a6.l	->	pointer.l to coord conv table
	;	d0.w 	->	x-coord
	;	d1.w 	->	y-coord
	;	d3.l 	->	noisefilter
	;	d4.w	->	color adder (0 or 8 for 64 px sprites)
	; 	d7.w 	->	char.w
	; 	-> char to coord within sprite. 1 bitplane
	;	destroys d0,d1,d2,d3,a0,a1
					lsl					#2,d0
					move				d1,d2
					lsl					#6,d1
					lsl					#5,d2																															; muls y-coord by 96
					add					d1,d0
					add					d2,d0																															; add to x-coord
					move.l				(a6,d0),a1																														; fetch sprite bitmap adress
					lea					(a1,d4),a1
					lea					(a5,d7*8),a0																													; fetch char address
					move.l				(a0)+,d0

					move.l				(a4),d1																															; AB
					move.l				4(a4),d2																														; CD
					swap				d2																																; DC
					add.l				d2,(a4)																															; AB + DC
					add.l				d1,4(a4)																														; CD + AB
					rol.l				d1,d3
					and.l				d3,d0
.spriteOffset		SET					16
					move.b				d0,.spriteOffset*3(a1)
					lsr					#8,d0
					move.b				d0,.spriteOffset*2(a1)
					swap				d0
					move.b				d0,.spriteOffset*1(a1)
					lsr					#8,d0
					move.b				d0,(a1)
					move.b				(a0),d0
					and.b				d3,d0
					move.b				d0,.spriteOffset*4(a1)
					rts


writeScoreToCharSprites
	;	a0.l	->	pointer.l to bcd number.l
	; 	a1.l	->	pointer.l to target text mem (8 bytes)
	;	destroys a1,d0,d1,d2
					moveq				#3,d2
.loop
					move.b				(a0)+,d0
					move				d0,d1
					andi				#$0f,d1
					andi				#$f0,d0
					asr					#4,d0
					add					#"0",d0
					move.b				d0,(a1)+
					add					#"0",d1
					move.b				d1,(a1)+
					dbra				d2,.loop
					rts

installSpritePointers
	;	a0.l	->	pointer.l to start of 6 x spr0pth+spr0ptl
	; 	a1.l	->	pointer.l to sprite bitmap memory
	;	destroys d0,a3

					lea					charToSpriteMaxRows*charHeight*spriteLineOffset(a1),a3
					lea					charToSpriteMaxRows*charHeight*spriteLineOffset*2(a1),a4
installSpriteJumpin

					move.l				a1,d0
					move.w				d0,6(a0)
					move.w				d0,6+24(a0)
					swap				d0
					move.w				d0,2(a0)
					move.w				d0,2+24(a0)
					move.l				a3,d0
					move.w				d0,8+6(a0)
					move.w				d0,8+6+24(a0)
					swap				d0
					move.w				d0,8+2(a0)
					move.w				d0,8+2+24(a0)
					move.l				a4,d0
					move.w				d0,16+6(a0)
					move.w				d0,16+6+24(a0)
					swap				d0
					move.w				d0,16+2(a0)
					move.w				d0,16+2+24(a0)
					rts

createTableTextSpritesCoord
	;	a1.l	->	pointer.l to sprite bitmap data space
	;	a6.l	-> 	pointer.l to coord table storage container
	;	-> char to sprite coord adress table @[artworkBitplane]
	;	destroys tempVar+24, ??

					move.l				a6,tempVar+24
					clr.w				d6
.createConvTable
					move				d6,d0
					muls				#spriteLineOffset*charHeight,d0																									;

					lea					(a1,d0),a3
					lea					charToSpriteMaxRows*charHeight*spriteLineOffset(a1,d0),a4
					lea					charToSpriteMaxRows*charHeight*spriteLineOffset*2(a1,d0),a5
					moveq				#7,d7
.wrtLine
					move.l				a4,8*4(a6)																														; sprite 1
					lea					1(a4),a4
					move.l				a5,16*4(a6)																														; sprite 2
					lea					1(a5),a5
					move.l				a3,(a6)+																														; sprite 0
					lea					1(a3),a3
					dbra				d7,.wrtLine
					lea					16*4(a6),a6
					add					#1,d6
					cmp					#charToSpriteMaxRows,d6																											; 20 lines?
					bcs					.createConvTable
					rts

noiseFilter
					dc.l				0
					dc.l				$00000401
					dc.l				$10402081
					dc.l				$5826c351
					dc.l				$95ac3ac5
					dc.l				$a7bca7bc
					dc.l				$7ef7dfcf
					dc.l				$f7fff3ff
					dc.l				-1
titleOptions
					dc.b				3,1,"CHOOSE YOUR OPTION",0
					IFEQ				(RELEASECANDIDATE||DEMOBUILD)
titleOptionsStage
					dc.b				5,12,"$TESTBUILD ONLY",0
					dc.b				4,13,"$TAP KEYS  1 TO 6",0
titleOptionsStagePointer
					dc.b				4,14,"$TO INIT  STAGE A",0
					ENDIF
titleOptionsDiff
					dc.b				3,10,"$DIFFICULTY",0
titleOptionsSFX
					dc.b				3,8,"$SOUND-FX",0
titleOptionsMsc
					dc.b				3,6,"$MUSIC",0
titleToggleDiff
					dc.b				17,10,"$EASY",0
					dc.b				17,$8a,"$HARD",0
titleToggleSFX
					dc.b				17,8," $ ON",0
					dc.b				17,$88," $OFF",0
titleToggleMsc
					dc.b				17,6," $ ON",0
					dc.b				17,$86," $OFF",0
titleOptionsClearColW
					dc.b				3,0
					blk.b				10," "
					dc.b				0
titleOptionsClearColR
					dc.b				3,0,"$"
					blk.b				10," "
					dc.b				-1
titleMessage
					dc.b				0																																; 0.b status (-1 = reset)
					dc.b				2,4,"ONLY ON $AMIGA$",0
					dc.b				7,12,"$ENJOY THE$ FLOW",0
					dc.b				5,16,"FUELED BY $AGA$",0
					dc.b				3,6,"$HIGHSCORE$ SAVE",0
					dc.b				1,14,"FULL $FRAMERATE$",0
					dc.b				5,8,"$DANCE$ THE BULLETS",0
					dc.b				2,10,"FIVE $STAGES$",0
					dc.b				7,2,"$BOSS$ GALORE",0
					dc.b				-1

titleCredits
					dc.b				1,1,"$PROJECT LEAD$",0
					dc.b				1,2,"RICHARD",0
					dc.b				1,3,"LOEWENSTEIN",0
					dc.b				14,6,"$PIXEL ART$",0
					dc.b				18,7,"KEVIN",0
					dc.b				15,8,"SAUNDERS",0
					dc.b				4,13,"$SONIC ART$",0
					dc.b				4,14,"ALTRAZ",0
					dc.b				4,15,"VIRGILL",-1
titleFirebutton
					dc.b				7,20," TAP FIRE  ",-1
titleFirebuttonB
					dc.b				7,20," TO START  ",-1
titleFirebuttonC
					dc.b				7,20,"TO CONTINUE",-1
titleFirebuttonD
					dc.b				7,20,"           ",-1
titleHighTitle
					dc.b				4,0,"HIGHSCORE HEROES",-1
titleHighEnterA
					dc.b				5,0,"YOU ARE A HERO!",-1
titleHighEnterB
					dc.b				5,0,"ENTER YOUR NAME",-1

titleHighHeroes
.column				SET					0																																; spalte
.row				SET					3																																; zeile
.rowC				SET					.row
.entry				SET					1
.entryOffset		SET					1
.namOffset			SET					20
.scoreOffset		SET					5
					REPT				9
					dc.b				.column+.entryOffset,.row,.entry+"0",". ",0
					dc.b				.column+.scoreOffset,.row, "$00000000$",0
					dc.b				.column+.namOffset,.row,"%TES",0
.row				SET					.row+1
.entry				SET					.entry+1
					ENDR
					dc.b				.column+.entryOffset,.row,"10.",0,.column+.scoreOffset,.row, "$00000000$",0,.column+.namOffset,.row,"$TES",-1
titleHighHeroesEnd

titleHighWeb
					dc.b				3,15,"$ENTER $XXXXXXXX$ AT",0
					dc.b				1,16,"$RP3.SPIELESCHREIBER.DE",0
newHighText
					dc.b				0,0,"YES!",-1
clearHighFrags	; clear NEW-Text after high entry
					dc.b				0,0,"    ",0																													; clr NEW-msg
					dc.b				7,20
					blk.b				11," "																															; clr FB-msg
					dc.b				0,3,15,"$"
					blk.b				5," "																															; clr ENTER-msg
					dc.b				0,9,15
					blk.b				8," "																															; clr XXXXXXXX
					dc.b				0,18,15,"$"
					blk.b				2," "																															; clr AT-msg
					dc.b				0,1,16,"$"
					blk.b				22," "																															; clr RP3...-msg
					dc.b				0
.rowC				SET					3
.column				SET					0
.namOffset			SET					20
					REPT				9
					dc.b				.column+.namOffset,.rowC,"$   ",0
.rowC				SET					.rowC+1
					ENDR
					dc.b				.column+.namOffset,.rowC,"$   ",-1
					even
highData		; actual highscore data saved to NVRAM
					IFEQ				DEMOBUILD
					dc.l				$3000000
					dc.b				"RIC",0
					dc.l				$2750000
					dc.b				"KEV",0
					dc.l				$2500000
					dc.b				"ALT",0
					dc.l				$2250000
					dc.b				"CLA",0
					dc.l				$2000000
					dc.b				"DOR",0
					dc.l				$1250000
					dc.b				"ING",0
					dc.l				$1000000
					dc.b				"FRA",0
					dc.l				$750000
					dc.b				"AND",0
					dc.l				$500000
					dc.b				"GRA",0
highDataLast
					dc.l				$250000
					dc.b				"BOR",0
					ELSE
					dc.l				$3000000
					dc.b				"RIC",0
					dc.l				$2750000
					dc.b				"KEV",0
					dc.l				$2500000
					dc.b				"ALT",0
					dc.l				$2250000
					dc.b				"CLA",0
					dc.l				$2000000
					dc.b				"DOR",0
					dc.l				$100000
					dc.b				"ING",0
					dc.l				$750000
					dc.b				"FRA",0
					dc.l				$500000
					dc.b				"AND",0
					dc.l				$250000
					dc.b				"GRA",0
highDataLast
					dc.l				$100000
					dc.b				"BOR",0
					ENDIF
highDataEnd
					blk.b				10,0																															; fill up to meet NVRAM saving format
					even

; #MARK: TITLE MANAGER ENDS
