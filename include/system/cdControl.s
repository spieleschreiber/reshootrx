

; RESHOOT.repeat  27. 7. 2016
; Copyright (c) 2016 Richard Lšwenstein
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
*  \     \/      \    \     \    /    |    :___/¯|    \    \   |/     /   *
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

	even

	include "cd.i"
	
;  NAME
 ;      OpenDevice - Open a CD unit for access

  ; SYNOPSIS
   ;    error = OpenDevice("cd.device", UnitNumber, IORequest, flags);
    ;   D0                 A0           D0          A1         D1



;  NAME
 ;      OpenDevice - Open a CD unit for access

  ; SYNOPSIS
   ;    error = OpenDevice("cd.device", UnitNumber, IORequest, flags);
    ;   D0                 A0           D0          A1         D1


		move.l	4, a6
		;PRINTV _LVOCreateMsgPort
		CALLDOS	CreateMsgPort
		move.l	d0, a5            ; a5 = MsgPort

		move.l	a5, a0
;		move.l	#IOSTD_SIZE, d0
		move.l	#200, d0
		CALLDOS	CreateIORequest
		move.l	d0, a4            ; a4 = IOStdReq

		lea	deviceName, a0
		moveq    #0, d0
		move.l   a4, a1
		clr.l    d1
		CALLDOS	OpenDevice


		CALLDOS	DoIO

			 illegal

_ioreq:
	dc.l	0,0	; LN_SUCC, LN_PRED
	dc.b	NT_REPLYMSG,0	; LN_TYPE, LN_PRI
	dc.l	0	; LN_NAME
	dc.l	_msgport	; MN_REPLYPORT
	dc.w	IOSTD_SIZE	; MN_LENGTH
	dc.l	0	; IO_DEVICE
	dc.l	0	; IO_UNIT
	dc.w	0	; IO_COMMAND
	dc.b	0,0	; IO_FLAGS, IO_ERROR
	dc.l	0	; IO_ACTUAL
	dc.l	0	; IO_LENGTH
	dc.l	0	; IO_DATA
	dc.l	0	; IO_OFFSET

handlername  dc.b     "test cd handler", 0
deviceName  dc.b      "cd.device", 0
;deviceName  dc.b      "input.device", 0
	even
	
		move.l	4, a6
		CALLDOS	CreateMsgPort
		move.l	d0, a5            ; a5 = MsgPort

		move.l	a5, a0
;		move.l	#IOSTD_SIZE, d0
		move.l	#200, d0
		CALLDOS	CreateIORequest
		move.l	d0, a4            ; a4 = IOStdReq

		lea	deviceName, a0
		moveq    #0, d0
		move.l   a4, a1
		clr.l    d1
		CALLDOS     OpenDevice
		
			 illegal

	


	    ;}
