;
;   macro.s
;
;
;   Created by Richard Löwenstein on 4.07.15.
;
;

;   Debbuging Macros
;   {



DEBUGBREAK  MACRO   ; use this with FS-UAE debugger. Stop with F11+D->Terminal->type in fi $cf4f for EXGL.l a7,a7 or $cd4e for exg.l a6,a6. Code then continues and stops right here.
    dc.w $cf4f
    ENDM
DEBUGB  MACRO   ; use this with FS-UAE debugger. Stop with F11+D->Terminal->type in fi $cf4f for EXGL.l a7,a7 or $cd4e for exg.l a6,a6. Code then continues and stops right here.
    dc.w $cd4e
    ENDM
ERRORBREAK	MACRO
	dc.w $cf4f
	ENDM
CALLEXEC	MACRO
	move.l	Execbase,a6
	jsr	_LVO\1(a6)
	ENDM
CALLDOS		MACRO
	move.l	DOSBase(pc),a6
	jsr	_LVO\1(a6)
	ENDM
CALLGFX		MACRO
	move.l	GFXbase(pc),a6
	jsr	_LVO\1(a6)
	ENDM
CALLINTUITION		MACRO
	move.l	INTUbase(pc),a6
	jsr	_LVO\1(a6)
	ENDM

ALLOCMEMSHELL	MACRO
	; print allocated memory to aux:(shell)
	; usage: ALLOCMEMSHELL <register>,text
		IFNE SHELLHANDLING
			movem.l d0-d7/a0-a6,-(sp)
			lea .\@2(pc),a6
			move.l \1,d0
			bsr shellNum
			movem.l (sp)+,d0-d7/a0-a6
			bra .\@1
.\@2		dc.b 	"$$$$$$$$$ KB used for"
			dc.b	" \2",0
			ALIGNLONG
.\@1
		ENDIF
		ALLOCMEMORY
		ENDM

ALLOCMEMORY	MACRO
	bsr _allocMem
	ENDM
_allocMem	
	IFNE SHELLMEMORY
	bsr shellMemAllocd
	ENDIF
	CALLEXEC AllocVec
	tst.l d0
	beq .noMemory
	rts
.noMemory
	move.l (sp),tempVar	; provide current pc
	bra errorMemory


COLORHELL	MACRO

	clr.w CUSTOM+BPLCON3
.1	move.w d0,CUSTOM+COLOR00
	add #1,d0
	bra .1
		ENDM

AVAILMEMORY	MACRO
	IFEQ (RELEASECANDIDATE||DEMOBUILD)
	moveq #-1,d0
	move.l #MEMF_CHIP,d1
	CALLEXEC AvailMem
	ENDIF
	ENDM

PLAYFX	MACRO
	movem.l d0-d1/a0/a6,-(sp)
	lea CUSTOM,a6
	lea fxTable+(\1-1)*12(pc),a0
	cmpi.w #14000,4(a0); 	sanity check of sample length
	bhs .\@1
	bsr	_mt_playfx
.\@1
	movem.l (sp)+,d0-d1/a0/a6

	ENDM

	
RASTERCOLOR      MACRO	; write color to border color
	IFNE SHOWRASTERBARS
	clr.w $dff106
	move.w \1,$dff180
    ENDIF
    ENDM

WAITSECSSET	Macro
	move.l a0,-(sp)
	lea _tempo(pc),a0
	move.l #\1,(a0)
	lea frameCount+4(pc),a0
	clr.w (a0)
	move.l (sp)+,a0
	ENDM
WAITSECS 	Macro
	bsr _waitSecs
	ENDM
_waitSecs	; d0 = seconds	; called by macro WAITSECS
	move.l _tempo(pc),d0
	muls #50,d0
	lea frameCount+4.l(pc),a5
.wait
	cmp.w (a5),d0
	bhi .wait
	rts
_tempo
	dc.l 0

WAITVBLANK  MACRO
	jsr _waitvblank
	ENDM
_waitvblank
    movem.l d0-d1,-(sp)
	move.w frameCount+4.l(pc),d0
.m1
	move.w frameCount+4.l(pc),d1
	cmp.w d0,d1
	beq.b .m1
    movem.l (sp)+,d0-d1
    rts
	
ADDSCORE MACRO
    IF \1>7
    add.w #\1,scoreAdder
    ELSE
    addq.w #\1,scoreAdder
    ENDIF
    ENDM

SAVEREGISTERS   MACRO
    movem.l d0-d7/a0-a6,-(a7)
    ENDM
SAVEREGISTERSIRQ   MACRO
    movem.l d1-d7/a0-a6,-(a7)
    ENDM

RESTOREREGISTERS    MACRO
	movem.l (a7)+,d0-d7/a0-a6
	ENDM
RESTOREREGISTERSQUICK	MACRO	
	move.l (a7)+,d7
	move.l (a7)+,d6
	move.l (a7)+,d5
	move.l (a7)+,d4
	move.l (a7)+,d3
	move.l (a7)+,d2
	move.l (a7)+,d1
	move.l (a7)+,d0
	move.l (a7)+,a6
	move.l (a7)+,a5
	move.l (a7)+,a4
	move.l (a7)+,a3
	move.l (a7)+,a2
	move.l (a7)+,a1
	move.l (a7)+,a0
    ENDM
RESTOREREGISTERSIRQ    MACRO
    movem.l (a7)+,d1-d7/a0-a6
    ENDM

FASTRANDOM	MACRO
	move.l	d1,-(sp)
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	lea     fastRandomSeed(pc),a0
	movem.l  (a0),d0/d1					; AB
	swap    d1						; DC
	add.l   d1,(a0)					; AB + DC
	add.l   d0,4(a0)				; CD + AB
	move.l	(sp)+,a0
	move.l	(sp)+,d0
	move.l	(sp)+,d1
	ENDM
fastRandomF
	lea	fastRandomSeed.l(pc),a1
	movem.l	(a1),d4/d5				; AB
	swap	d5						; DC
	add.l	d5,(a1)					; AB + DC
	add.l	d4,4(a1)				; CD + AB
	rts


SAFECOPPER MACRO
    WAITVBLANK
    ENDM
RESTORECOPPER MACRO
    WAITVBLANK
    st.b irqColorFlag
    WAITVBLANK
    WAITVBLANK
    ENDM

COPPERSUBLIST    Macro
    SAFECOPPER
    move.l #\1,d0
    bsr rasterListBuild
    RESTORECOPPER
    WAITVBLANK
    move.l #\1,d0
    move d0,irqCopJmp+2
    swap d0
    move d0,irqCopJmp
    st.b irqColorFlag
    WAITVBLANK
    Endm


MSGACCL	MACRO
	IF ALERTHANDLING=1
	SAVEREGISTERS
	move.w (a2),d0
	move.l animDefs(pc),a3
	move.l (a3,d0.w),d0
	MSG02 msgAcclList,d0

	move.l objectListAcc(a2),d0
	lsr #4,d0
	swap d0
	lsr #4,d0
	swap d0
	MSG03 msgAcclVals,d0
	RESTOREREGISTERS
	ENDIF
	ENDM

MSG	MACRO
	IF ALERTHANDLING=1
    move.l #\1,alertText
    move.l \2,alertNumber
    add #1,alertLine
    andi #3,alertLine
    jsr AlertManager
    ENDIF
    ENDM


MSG01	MACRO
    IF ALERTHANDLING=1
    move.l #\1,alertText
    move.l \2,alertNumber
    move #0,alertLine
    jsr AlertManager
    ENDIF
    ENDM
MSG02   MACRO
    IF ALERTHANDLING=1
    move.l #\1,alertText
    move.l \2,alertNumber
    move #2,alertLine
    jsr AlertManager
    ENDIF
    ENDM
MSG03   MACRO
    IF ALERTHANDLING=1
    move.l #\1,alertText
    move.l \2,alertNumber
    move #4,alertLine
    jsr AlertManager
    ENDIF
    ENDM
MSG04   MACRO
    IF ALERTHANDLING=1
    move.l #\1,alertText
    move.l \2,alertNumber
    move #6,alertLine
    jsr AlertManager
    ENDIF
    ENDM


ALERT01	MACRO
    IF ALERTHANDLING=1
    move.l #\1,alertText
    move.l \2,alertNumber
    move #0,alertLine
    jsr AlertManager
    ENDIF
    ENDM
ALERT02   MACRO
    IF ALERTHANDLING=1
    move.l #\1,alertText
    move.l \2,alertNumber
    move #2,alertLine
    jsr AlertManager
    ENDIF
    ENDM
ALERT03   MACRO
    IF ALERTHANDLING=1
    move.l #\1,alertText
    move.l \2,alertNumber
    move #4,alertLine
    jsr AlertManager
    ENDIF
    ENDM
ALERT04   MACRO
    IF ALERTHANDLING=1
    move.l #\1,alertText
    move.l \2,alertNumber
    move #6,alertLine
    jsr AlertManager
    ENDIF
    ENDM


ALERTSETLINE   MACRO
    IF ALERTHANDLING=1
    move.w \1,alertLine
    ENDIF
    ENDM

WAITFB	Macro
.\@1	tst.b $bfe001
	bmi.b .\@1
	Endm

QUITNOW	Macro
	move.l startupQuit(pc),a0
	tst.l a0
	beq .\@1
	jmp (a0)
.\@1	rts
	Endm

TIMERSTART 	Macro
	move.w d0,-(sp)
	clr.l timer
	move.b $bfd500,d0
	lsl #8,d0
	move.b $bfd400,d0
	move.w d0,timer
	move.w (sp)+,d0
	Endm
TIMERFETCH	Macro
	move.w d0,-(sp)
	move.b $bfd500,d0
	lsl #8,d0
	move.b $bfd400,d0
	sub.w d0,timer
	move.w (sp)+,d0
	Endm
timer
	dc.w 0

	
	clr.l d1
	move.b $bfd500,d1
	lsl #8,d1
	move.b $bfd400,d1
	sub.w d1,d0
	ALERT01 m2,d0

;   Common Macros

WAITBLIT   Macro
	tst.b $dff002
.\@
	btst #6,$dff002
	bne.b .\@
    Endm




ALIGNLONG MACRO				; Align to longword
	CNOP	0,4			;
	ENDM		

ALIGNQUAD MACRO				; Align to quadword
	CNOP	0,8			;
	ENDM	
	
;   Copperliste Macros

CMOVE		Macro
		  dc.w		\1&$1fe,\2
		Endm
CMOVEL		Macro
		  dc.w		\1&$1fe,\2
          dc.w      (\1+2)&$1fe,\3
		Endm

CMOVELC		Macro
		  dc.w		\1&$1fe,0
          dc.w      (\1+2)&$1fe,0
		Endm
CWAIT		Macro
		  dc.w		\1!1
          ;dc.w -2
		  dc.w		-2	; Comp.-Enable-Mask
		Endm
CNOOP   MACRO
    CMOVE NOOP,0
        ENDM
CEND        Macro
		  dc.w		$ffff,$fffe
		Endm

RASTERBARINIT	Macro
	IFNE SHOWRASTERBARS
	move #-1,$dff180
	move.w $dff006,d7
	lsr #8,d7
	move.w d7,rasterBarNow
	ENDIF
	ENDM
	
RASTERBARRESULT Macro
	IFNE SHOWRASTERBARS
	clr.w $dff106
	move.w #$510,$dff180
	move.w $dff006,d7
	lsr #8,d7
	sub.w rasterBarNow,d7
	cmp.w rasterBarMax,d7
	bls .isLower
	move.w d7,rasterBarMax
.isLower
	MSG03 msgRasterbarNow,d7
	move.w rasterBarMax,d7
	MSG04 msgRasterbarMax,d7
	ENDIF
	ENDM

WAITRASTER  Macro
.\@1
    move $dff006,d0
    lsr #8,d0
    cmpi #\1,d0
    blt .\@1
    Endm

GETOBJECTPOINTER    MACRO   ; get Pointer to bobObjectDefinitions
    move (\1),d0;objectListAnimPtr
    lea ([animDefs,pc],d0.w),\2
    clr.l d0
    move.b animDefType(\2),d0
    lea ([objectDefs,pc],d0.w*8),\2
    ENDM
;	Exmaple Code:
;	move (a0),d5;objectListAnimPtr
;	lea ([animDefs,pc],d5.w),a4 ; get pointer to object definition
;	clr.l d4
;	move.b animDefType(a4),d4
;	lea ([objectDefs,pc],d4.w*8),a4   ; Pointer to animDefinitions
;	clr.l d7
;	move.b objectDefHeight(a4),d7
;	....

GETOBJECTDEFBASE	MACRO
	move (a6),d0;objectListAnimPtr
    lea ([animDefs,pc],d0.w),\1
    clr.w d0
	move.b animDefType(\1),d0
    lea ([objectDefs,pc],d0*8),\1   ; Pointer to animDefinitions


	ENDM

TEST_FILLBITPLANE	MACRO
;	Draw 20 lines of 64 pixels to bitplane. Modify modulus to your needs
; 	USAGE: TEST_FILLBITPLANE r ->	bitplane adress
	movem.l \1/d0,-(sp)
	moveq #20,d0
.\@1
	move.l #-1,(\1)
	move.l #-1,4(\1)
	add.l #40*4,\1
	dbra d0,.\@1
	movem.l (sp)+,\1/d0
ENDM
	
WRITECOLOR		Macro
	jsr writeCol
	endm

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

sort		Macro
    move.l \1,a0	 ; address of array
 	move.w \2,d0 	; memsize of arrayitems in bytes
    subq #4,d0
    beq .end
    asr.w #2,d0   	; calculate number of items
;    subq #1,d0
.loop2
    move.l a0,a2
 	move.l a0,a1
 	add.l #4,a2
 	move.w d0,d1
 	subi.w #1,d1
.loop1
    move.l (a1)+,d2
    move.l (a2)+,d3
    cmp.l d2,d3
 	bge .skip
 	move.l (a1),d3	; swap numbers
 	move.l -4(a1),(a1)
 	move.l d3,-4(a1)
.skip
    dbra d1,.loop1
 	subi.w #1,d0
 	bgt .loop2
.end
 	Endm


SEARCHXML4VALUE   Macro
    moveq #$7f,d4
    move.l #\2,d0 ; search for ASCII-term. Max 4 chars. Returns with first number in (a0)
        ;   free to use: d3,d7,a0-a7
    cmp.l -1\1,d0
    beq.b .\@2
    move.l -1\1,d5
    move.w \1+,d1
    move.b \1+,d1
    move.l #"/map",d1
    move.l #"yer>",d2
.\@1
    asl.l #8,d5
    move.b \1+,d5
    cmp.l d5,d0
    beq.b .\@2            ; Term found
    cmp.l d5,d1
    beq.b .\@3
    cmp.l d5,d2
    beq.b .\@3
    dbra d4,.\@1
.\@3
    moveq #-1,d4
.\@2
    ENDM


SEARCHXML4VALUEShort   Macro
    moveq #$1f,d4
    move.l #\2,d0 ; search for ASCII-term. Max 4 chars. Returns with first number in (a0)
        ;   free to use: d3,d7,a0-a7
    cmp.l -1\1,d0
    beq.b .\@2
    move.l -1\1,d5
    move.w \1+,d1
    move.b \1+,d1
    move.l #"/map",d1
    move.l #"yer>",d2
.\@1
    asl.l #8,d5
    move.b \1+,d5
    cmp.l d5,d0
    beq.b .\@2            ; Term found
    cmp.l d5,d1
    beq.b .\@3
    cmp.l d5,d2
    beq.b .\@3
    dbra d4,.\@1
.\@3
    moveq #-1,d4
.\@2
    Endm

searchXML4Anim   Macro
    moveq #$4f,d4
    move.l #\2,d0 ; search for ASCII-term. Max 4 chars. Returns with first number in (a0)
        ;   free to use: d3,d6,d7,a0-a7
    cmp.l -1\1,d0
    beq.b .\@2
    move.l -1\1,d5
    move.w \1+,d1
    move.b \1+,d1
    move.l #"anim",d1
    move.l #"/pli",d2
.\@1
    asl.l #8,d5
    move.b \1+,d5
    cmp.l d5,d0
    beq.b .\@2            ; Term found
    cmp.l d5,d1
    beq.b .\@3
    cmp.l d5,d2
    beq.b .\@3
    dbra d4,.\@1
.\@3
    moveq #-1,d4
.\@2
    Endm



asciiToNumber   Macro       ; ax = Memorylocation of ASCII-number
                            ; dx    =   desired register with result
                            ; free to use: d3-d7, a0-a7

            moveq #0,\2
            cmpi #$222f,\1   ; found empty quote -> no number?
            beq.b .\@3
            moveq #0,d0
            moveq #10,d1
            move #"0",d2
.\@1

            move.b  \1+,d0     ;get digit,increment A0
            sub.b     d2,d0      ;subtract $30
            cmp.b    d1,d0       ;test,if valid
            bcc.b     .\@1            ;no,then continue search
            add     d0,\2        ;insert nibble
.\@2
            move.b  \1+,d0     ;get digit,increment A0
            sub.b     d2,d0      ;subtract $30
            cmp.b     d1,d0       ;test,if valid
            bcc.b     .\@3        ;no,then done
            mulu    d1,\2       ;shift result
            add     d0,\2        ;insert nibble
            bra.b     .\@2        ;and continue
.\@3
    Endm

CLEARMEMORY   Macro       ; first argument.l  = memory adress
                            ; 2nd argument.l  = memory size
                        ; memorysize needs to be longword-dividable
    move.l \1,a6
    move.l \2,d7
    bsr.w clearmem
    Endm

clearmem

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
    ;}




