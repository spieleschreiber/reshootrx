;//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//

; code by Asman from English Amiga Board

; CD32 code needs a lot of cycles. Use Readjoystick whereever possible

; Button types, valid for all types except JP_TYPE_NOTAVAIL
JOY_UP EQU 3
JOY_DOWN EQU 2
JOY_LEFT EQU 1
JOY_RIGHT EQU 0
BUTTON_BLUE EQU 23     ; Blue - Stop; Right Mouse
BUTTON_RED EQU 22      ; Red - Select; Left Mouse; Joystick Fire
BUTTON_YELLOW EQU 21   ; Yellow - Repeat
BUTTON_GREEN EQU 20    ; Green - Shuffle
BUTTON_FORWARD EQU 19  ; Charcoal - Forward
BUTTON_REVERSE EQU 18  ; Charcoal - Reverse
BUTTON_PLAY EQU 17     ; Grey - Play/Pause; Middle Mouse
;in d0 == 0 - port 0
;      == 1 - port 1
;



readJoypad:

    lea	CUSTOM,a0
    lea	CIAA,a1
	;moveq #0,d0
   moveq	#1,d0			;PORT 1


;    moveq	#CIAB_GAMEPORT0,d3	;red button ( port 0 )
;    move.w	#10,d4			;blue button ( port 0 )
;    move.w	#$f600,d5		;for potgo port 0
;    moveq	#joy0dat,d6

; tst.l	d0
;    beq.b	.direction

   moveq	#CIAB_GAMEPORT1,d3	;red port 1
    moveq	#14,d4			;blue port 1
    move.w	#$6f00,d5		;for potgo port 1
    moveq	#joy1dat,d6		;port 1


.direction	moveq	#0,d7

    move.w	(a0,d6.w),d0		;get joystick direction
    move.w	d0,d1
    lsr.w	#1,d1
    eor.w	d0,d1

    btst	#8,d1			;check joystick up
    sne	d7
    add.w	d7,d7

    btst	#0,d1			;check joystick down
    sne	d7
    add.w	d7,d7

    btst	#9,d0			;check joystick left
    sne	d7
    add.w	d7,d7

    btst	#1,d0			;check joystick right
    sne	d7
    add.w	d7,d7
    swap	d7

;two buttons

    btst	d4,(potinp,a0)		;check button blue
    seq	d7
    add.w	d7,d7

    btst	d3,(ciapra,a1)		;check button red
    seq	d7
    add.w	d7,d7

    and.w	#$0300,d7
    asr.l	#2,d7
    swap	d7
    asr.w	#6,d7


; read buttons from CD32 pad

    bset	d3,(ciaddra,a1)		;set bit to out at ciapra
    bclr	d3,(ciapra,a1)		;clr bit to in at ciapra

    move.w	d5,(potgo,a0)

    moveq	#0,d0
    moveq	#8-1,d1
    bra.b	.in

.loop		tst.b	(a1)
    tst.b	(a1)
.in		tst.b	(a1)
    tst.b	(a1)
    tst.b	(a1)
    tst.b	(a1)
    tst.b	(a1)
    tst.b	(a1)

    move.w	(potinp,a0),d2

    bset	d3,(ciapra,a1)
    bclr	d3,(ciapra,a1)

    btst	d4,d2
    bne.b	.next

    bset	d1,d0

.next		dbf	d1,.loop

    bclr	d3,(ciaddra,a1)		;set bit to in at ciapra

    move.w	#$ffff,(potgo,a0)
    swap	d0
    or.l	d7,d0
    rts
joyOldStatus
    dc.l 0

bit_joyb1 = 7
bit_joyb2 = 14
bit_joyb3 = 12

STICK_BUTTON_ONE	=	8
STICK_BUTTON_TWO	=	9
STICK_BUTTON_PAUSE	=	10



READJOYSTICK	MACRO

	IF 0=1	; should read 3rd button, not tested
	btst     #bit_joyb3,$dff016
	seq      d0
	add.w    d0,d0
	ENDIF

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
	move.b	(.conv,pc,d1.w),d0	; 1=right, 2=left, 4=down, 8=up
	bra.b .\@1
.conv	dc.b      0, 4, 5, 1, 8, 0, 1, 9, 10, 2, 0, 8, 2, 6, 4, 0
.\@1
	ENDM
