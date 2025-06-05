
	;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter bitmap load adress or use a0 if return to bobblitnext / not animreturn

	;	#MARK: - Spinner
	;	Killcheck always active
	; 	trig1792+x to init code
	;	trig1025	randomX (0-255), randomY (0-63)


	; Some remarks for setting up animlist for beautiful spintype-based atack waves

	; incase yadd = 1, copied objects are launched such so they keep their y-onscreen launchposition and do not move with environment
	;	incase yadd = 0 copies objects are launch so to keep their y-environment launchposition and do move with enviroment
	;	{best practice to create beautiful curved patterns: create one with yadd=0 or modify existing one. Then, if you want to use it with yadd=1, modify initial y-acceleration so that it subtracts scrolling speed.
	;	example: Scrollspeed of 8 is equivalent to yacc of -128. Therefore, if initial yacc of object is set to yacc470 in animlist with yadd set to 0 in launchlit: create alt animlist entry with yacc342 (470-128) if launchlist yadd1}
	; Text above in brackets, as code has been modified since and such animlist modiciations are no longer needed.

spinners
	;andi.w #$fff0,objectListX(a2)
	;or.w #$08,objectListX(a2)	; just for test. bits0-3 = 8 means word-sized alignment in bitmap, no pixelshift in blittercode -> smaller blitsize
;	tst.b objectListTriggers+3(a2)	; temporarily disable as it does not work with homeShot code. Re-implement with custom animlist code (triggered by code etc... ) if needed

;	bne .modifyAccl

	;tst.b objectListTriggersB+3(a2)
	;beq .init
.retMod
	clr.w d0
	clr.w d4
	move.w objectListAccX(a2),d6
	;smi d4
	;andi.b #2,d4
	;add.b #5,d4	; optimise x-pointer for acceleration east and west
	;move.w d6,d5

	asr.w #5,d6
	spl d5
	andi.b #$1f,d5
	add.w #$10,d6
	cmpi.b #32,d6
	scc.b d4	;-1 if out of range
	and.b d4,d5
	not.b d4
	and.b d4,d6
	or.b d5,d6
	andi #$1f,d6
	move d6,d7		; d7 contains x-pointer

	move.w objectListAccY(a2),d6
	move d6,d5
	asr.w #6,d6
	asr.w #5,d5
	add.w d5,d6

	clr.l d5
	tst.b objectListAttr(a2)	; adjust angle and scrollspeed only if yadd = 1 within launchlist aka keep object on  screenposition
	bmi .noAdjust
	move.l viewPosition+viewPositionAdd(pc),d5
	move.l d5,d4
	lsl.l #3,d5
	lsl.l #2,d4
	add.l d4,d5	; *12
.noAdjust
	swap d5
	not d5
	add d6,d5
	spl d4
	andi.w #$1f,d4
	add.w #$10,d5
	cmpi.b #$20,d5
	scc.b d6	;-1 if out of range
	and.b d6,d4
	not.b d6
	and.b d6,d5
	or.b d4,d5
	andi #%11110,d5
	lsl #5,d5
	add.w d5,d7
.anim
	move.b (tanTable,pc,d7),d4
	lea (a0,d4.w),a0
	btst.b #attrIsKillBorderExit,objectListAttr(a2)	; killcheck bit set?
	beq animReturn	; no
	lea killBounds(pc),a1
	bra killCheck	; check exit view
.init

	IFNE 0
.modifyAccl
	jsr FASTRANDOM_A1	; preload random numbers to d4/d5
	clr.w d0
	move.b objectListTriggers+3(a2),d0
	move.w (.jmpTable-2,pc,d0.w*2),d0
	sf.b objectListTriggers+3(a2)
.jmp
	jmp .jmp(pc,d0.w)
.jmpTable
	dc.w .1-.jmp-2,.2-.jmp-2,.3-.jmp-2,.4-.jmp-2
.2
	lsr.b #1,d4
	lsr.b #2,d5	; range 0 to 63
	bra .modX
.1
	lsr.b #2,d4
	lsr.b #3,d5
.modX
	ext.w d4
	add.w d4,objectListX(a2)
	add.w d4,objectListAccX(a2)
	add.w d4,objectListAccX(a2)
	;add.w d4,objectListAccX(a2)
	bra .modY
.3
	ext.w d5
	asl.w #2,d5
	;MSG02 m2,d5
	sub.w d5,objectListAccY(a2)
	bra .retMod
.4
	ext.w d4; range -$ff80 to $7f
	add #288,d4	; default mod = 160
	;lsr.b #1,d5	; range 0 to 63
	move.w d4,objectListX(a2)
.modY
	ext.w d5
	sub.w d5,objectListY(a2)
	bra .retMod
	ENDIF
