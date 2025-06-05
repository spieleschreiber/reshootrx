

; RESHOOT.repeat  27. 7. 2016
; Copyright (c) 2016 Richard L�wenstein
; Modified from Stingrays original file tubularworldspatch.s


;The game tries to use nonvolatile.library to save to the CD32's NVRAM.
;Make sure that this can be accessed in LIBS: and you create a file
;called "ENVARC:sys/nv_location" - a single line of text that is the
;directory name of where you would like saved data to be stored.


;{ <- this lines only purpose is to keep indents and formatting in Xcode right
	
***************************************************************************
*             /                                                           *
*       _____.__ _                                         .___.          *
*      /    /_____________.  _________.__________.________ |   |________  *
*  ___/____      /    ____|_/         |         /|        \|   ._      /  *
*  \     \/      \    \     \    /    |    :___/�|    \    \   |/     /   *
*   \_____________\___/_____/___/_____|____|     |____|\_____________/    *
*     -========================/===========|______\================-      *
*                                                                         *
*   .---.----(*(       TUBULAR WORLDS CD32 PATCH            )*)---.---.   *
*   `-./                                                           \.-'   *
*                                                                         *
*                         (c)oded by StingRay                             *
*                         --------------------                            *
*                               May 2009                                  *
*                                                                         *
*                                                                         *
***************************************************************************

; Patches the disk version of Tubular Worlds so it can be used on CD32
; without the need for any keyboard. Highscores are loaded/saved from/to
; NVRAM and name can be entered using the joystick.


; Nonvolatile offsets
_LVOGetCopyNV		= -30
_LVOFreeNVData		= -36
_LVOStoreNV		= -42
_LVODeleteNV		= -48
_LVOGetNVInfo		= -54
_LVOGetNVList		= -60
_LVOSetNVProtection	= -76


; d0.l: length
; a0.l: file name
; a1.l: destination

loadHighscores
	;bsr.w openLib
	move #highDataEnd-highData,d0
	move.l	d0,d7			; save length
	lea	itemName(pc),a1		; a1: itemName
	lea	appName(pc),a0
	moveq	#1,d1			; killRequesters = true
	move.l	NVBase(pc),d2
    beq.b	.exit   ; predefined highs remain
	move.l d2,a6
	jsr _LVOGetCopyNV(a6)

	tst.l d0
	beq .exit
	move.l	d0,a0
	lea highData(pc),a5	; destination
.copy	move.b	(a0)+,(a5)+		; copy highscores to destination area
	dbra d7,.copy

	move.l d0,a0
	jsr _LVOFreeNVData(a6)
.exit
	;bsr.w closeLib
	rts

; d0.l: length
; a0.l: file name
; a1.l: data

saveHighscores
	lea highData(pc),a2	; a2 = data pointer
	lea	itemName(pc),a1			; a1: itemName
	lea	appName(pc),a0		; appName
; length must be a multiple of 10, original length: 55 bytes hence
; we use 60/10.
	moveq	#(highDataEnd-highData)/10,d0		; length/10
	moveq	#1,d1			; killRequesters = true
	move.l	NVBase(pc),d2
	beq.b	.exit
	move.l d2,a6
	jsr _LVOStoreNV(a6)
.exit
	rts
	cnop 0,4
itemName		dc.b	"highscores",0
appName			dc.b	"rp3",0
		even
	    ;}
