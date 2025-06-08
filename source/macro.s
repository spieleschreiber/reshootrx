;
;   macro.s
;
;
;   Created by Richard Löwenstein on 4.07.15.
;
;

;   Debbuging Macros
;   {

FILENAMEPREFIX					MACRO
								dc.b					"PROGDIR:data/"
								ENDM

SCR2MOD							Macro																																																																;3 Bitplanes
								dc.l					mainPlaneWidth*mainPlaneDepth*tileHeight*\1
								Endm


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
	move.l	Execbase.w,a6
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
	CALLEXEC AllocVec
	tst.l d0
	beq .\@1
	rts
.\@1
	move.l (sp),tempVar	; provide current pc
	bra errorMemory
	ENDM


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
	move.w #\1,_waitsec
    clr.w frameCount+4
    ENDM
WAITSECS 	Macro
	jsr _WAITSECS
	ENDM


WAITVBLANK  MACRO
	jsr _WAITVBLANK
	ENDM
	
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


SAFECOPPER MACRO
    WAITVBLANK
    ENDM
RESTORECOPPER MACRO
    WAITVBLANK
    st.b irqColorFlag
    WAITVBLANK
    WAITVBLANK
    ENDM

COPPERSUBLIST    MACRO
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
    ENDM


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



sort		MACRO
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
 	ENDM


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
