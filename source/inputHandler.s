;//
;//  keyboardHandler.s
;//  px
;//
;//  Created by Richard Löwenstein on 09.08.23.
;//  Copyright © 2023 spieleschreiber. All rights reserved.
;//
; 	define keys in keyArray
;	query keys like this:
;	tst.w keyArray+cursorUp(pc)
;	beq notHit

JOY_UP EQU 3
JOY_DOWN EQU 2
JOY_LEFT EQU 1
JOY_RIGHT EQU 0

STICK_BUTTON_ONE	=	8
STICK_BUTTON_TWO	=	9
STICK_BUTTON_PAUSE	=	10

bit_joyb1 = 7
bit_joyb2 = 14
bit_joyb3 = 12

inputHandler
	lea keyArray(pc),a0
	move.w #(keyArraySize-keyArray)/4,d1
	move.l LOWLVbase(pc),a6
	jsr -$36(a6)	; ATTN - this needs lowlevel.library initialised

	clr.w d3
	clr.w d4
	tst.b keyArray+cursorUp(pc)
	seq d3
	add.w d3,d3

	tst.b keyArray+cursorDown(pc)
	seq d3
	add.w d3,d3

	tst.b keyArray+cursorLeft(pc)
	seq d3
	add.w d3,d3

	tst.b keyArray+cursorRight(pc)
	seq d3
	add.w d3,d3
	lsr.w #8,d3
	eor.w #$f,d3

	tst.b keyArray+fireSecondary(pc)
	seq d4
	add.w d4,d4

	tst.b keyArray+firePrime(pc)
	seq d4
	add.w d4,d4
	sf.b d4
	eor.w #$300,d4
	or.b d3,d4

	IF 0=1	; should read 3rd button, not tested
	btst     #bit_joyb3,$dff016
	seq      d0
	add.w    d0,d0
	ENDIF
.skip
	btst	#bit_joyb2,$dff016
	seq	d0
	add.w	d0,d0

	btst	#bit_joyb1,$bfe001
	seq	d0
	add.w	d0,d0
	move.w	CUSTOM+JOY1DAT,d1

	ror.b	#2,d1
	lsr.w	#6,d1
	andi.w	#%1111,d1
	move.b	(.directionConvTable,pc,d1.w),d0	; 1=right, 2=left, 4=down, 8=up

	or.w d4,d0	; mix keyboard and stick controls

	lea plyBase+plyJoyCode(pc),a0
	move.w (a0),2(a0)	; story old value, needed for input query in title screen
	move.w frameCount+2(pc),d1
	move.w d0,(a0)	; store current input state

	btst #STICK_BUTTON_ONE,d0
	beq .FBreleased
	sub.w 4(a0),d1
	move.w d1,6(a0); no. of frames since fb was released. values <5 = fb tappen, values >8 = fb hold
	bra retInputHandler

FBHOLD		SET	12
FBTAPPED	SET	5

.FBreleased
	;move.w d1,4(a0)
	swap d1
	clr.w d1
	move.l d1,4(a0)	; reset fb buffer
	bra retInputHandler
.directionConvTable	dc.b      0, 4, 5, 1, 8, 0, 1, 9, 10, 2, 0, 8, 2, 6, 4, 0
keyArray


GRAEMEXARCADESTICKMAPPING	SET	0
	IFEQ GRAEMEXARCADESTICKMAPPING
		dc.w $4c,0,$4d,0,$4f,0,$4e,0,$31,0,$32,0	; up, down, left, right, Y, X
		IFEQ (RELEASECANDIDATE||DEMOBUILD)
		dc.w $60,0,$61,0,1,0,2,0,3,0,4,0,5,0,6,0		; left and right shift, 1,2,3,4,5,6
		ENDIF
		ELSE
		dc.w $3e,0,$1e,0,$2d,0,$2f,0,$63,0,$64,0	; up, down, left, right, Q, W
		dc.w $60,0,$61,0,1,0,2,0		; left and right shift, 0,1
	ENDC


keyArraySize
	RSSET	2
cursorUp		rs.l	1
cursorDown		rs.l	1
cursorLeft		rs.l	1
cursorRight		rs.l	1
firePrime		rs.l	1	(Fire primary)
fireSecondary		rs.l	1	(Fire secondary)
	IFEQ (RELEASECANDIDATE||DEMOBUILD)
LShift	rs.l	1
RShift	rs.l	1
Key1	rs.l	1
Key2	rs.l	1
Key3	rs.l	1
Key4	rs.l	1
Key5	rs.l	1
Key6	rs.l	1
	ENDIF
