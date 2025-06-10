;//
;//  stingraysStartup.s
;//  Reshoot2
;//
;//  Created by Richard Löwenstein on 16.03.19.
;//
INTENASET	= %0001000000111110
;		       ab-------cdefg--
;	a: SET/CLR Bit
;	b: Master Bit
;	c: Blitter Int
;	d: Vert Blank Int
;	e: Copper Int
;	f: IO Ports/Timers
;	g: Software Int

DMASET		= %0000001111100000
;		       a----bcdefghi--j
;	a: SET/CLR Bit
;	b: Blitter Priority
;	c: Enable DMA
;	d: Bit Plane DMA
;	e: Copper DMA
;	f: Blitter DMA
;	g: Sprite DMA
;	h: Disk DMA
;	i..j: Audio Channel 0-3

ALIGNLONG	
startUpGame
	IFEQ (RELEASECANDIDATE||DEMOBUILD)
	moveq #-1,d0
	move.l #MEMF_CHIP,d1
	CALLEXEC AvailMem
	move.l d0,memChip
	moveq #-1,d0
	move.l #MEMF_FAST,d1
	CALLEXEC AvailMem
	move.l d0,memFast
                 bra              getFFF
	PRINTV RELEASECANDIDATE
	PRINTV DEMOBUILD


	IFEQ (RELEASECANDIDATE||DEMOBUILD)
	
memChip		dc.l	0
memFast		dc.l	0
memTotal	dc.l	0
	ENDIF

getFFF
	moveq #-1,d0
	move.l #MEMF_ANY,d1
	CALLEXEC AvailMem
	move.l d0,memTotal
	ENDIF

	lea errorNo(pc),a0
	move.b #-1,(a0)	; reset errorFlag
	lea	.VARS(pc),a5
	move.l sp,.Stack-.VARS(a5)	; save stack

	lea .END(pc),a0
	move.l a0,startupQuit	; store return adress if return from code
   	move.l 	d0,DOSBase	; store DOS library base
   	beq .END



	;
	; open libraries
	;


   	lea	.DosName(pc),a1
   	moveq 	#0,d0
   	CALLEXEC OpenLibrary
   	move.l 	d0,DOSBase	; store DOS library base
   	beq .END

	lea	.freeAnimName(pc),a1
	moveq 	#0,d0
   	CALLEXEC OpenLibrary
	move.l d0,freeAnimBase	; freeanim library only exists on CD32. If pointer is zero, dont bother - closelibrary still works

	lea	.GFXname(pc),a1
	moveq	#0,d0
	CALLEXEC OpenLibrary
	move.l	d0,GFXbase	; store Graphics library base
	beq	.END

   	lea	.IntuName(pc),a1
   	moveq 	#0,d0
   	CALLEXEC OpenLibrary
   	move.l 	d0,INTUbase	; store Intuition library base
   	beq .END

	lea	.LOWLVName(pc),a1
					moveq				#40,d0
					move.l				 4.w,a6
					jsr					_LVOOpenLibrary(a6)
   	;CALLEXEC OpenLibrary
   	move.l 	d0,LOWLVbase	; store Intuition library base
   	beq .END

   	lea	.NVName(pc),a1
   	moveq 	#0,d0
	moveq	#1,d1			; killRequesters = true
   	CALLEXEC OpenLibrary
   	move.l 	d0,NVBase	; store NonVolatile library base
	beq .END

	moveq   #1,d0	; instr cache only
	moveq   #-1,d1	; affect all bits
	CALLEXEC CacheControl	; disable all cache but instr cache

	sub.l	a1,a1
    CALLEXEC FindTask
	move.l	d0,a1
	moveq #127,d0
	CALLEXEC SetTaskPri

	CALLINTUITION	CloseWorkBench
	lea	.VARS(pc),a5
	move.b d0,.wbclosed-.VARS(a5)

	CALLEXEC Forbid

	move.l	GFXbase(pc),a6	; contains AGA-chipset?
	lea	.VARS(pc),a5
	move.l	34(a6),.OldView-.VARS(a5)
	sub.l	a1,a1
   	CALLGFX	LoadView		; 	disable given view
   	CALLGFX WaitTOF			; 	wait frame
   	CALLGFX WaitTOF
   	CALLGFX WaitBlit
  	CALLGFX OwnBlitter		; 	get blitter exclusively
	
	clr.w	CUSTOM+FMODE		; reset AGA sprites
	clr.w	CUSTOM+BPLCON3		; reset AGA BPLCON regs

	move.l	$26(a6),.OldCop1-.VARS(a5)	; Store old CL 1
	move.l	$32(a6),.OldCop2-.VARS(a5)	; Store old CL 2
	bsr	.GetVBR
	move.l	d0,.VBRptr-.VARS(a5)
	move.l	d0,a0

	movem.l $8(a0),d0-d3
	lea .exceptHandlers(pc),a6
	movem.l d0-d3,(a6)

	lea access_fault(pc),a1
	lea address_error(pc),a2
	lea illegal_instruction(pc),a3
	lea divide_by_Zero(pc),a4
	movem.l a1-a4,$8(a0)	; new exception handlers

	lea	pot(pc),a1	; 		init CIA
	CALLEXEC OpenResource
	tst.l	d0
	beq.b	.noCIA
	movea.l	d0,a6
	moveq	#-1,d0
	move.w	#$ff00,d1
	jsr	-18(a6)				;WritePotgo()
.noCIA


	***	Store Custom Regs	***

	lea	CUSTOM,a6			; base address
	move #%10,COPCON(a6)	; unlimited copper access

	move.w	$10(a6),.ADK-.VARS(a5)	; Store old ADKCON
	move.w	$1C(a6),.INTENA-.VARS(a5)	; Store old INTENA
	move.w	$02(a6),.DMA-.VARS(a5)	; Store old DMA


	;move.w	#$7FFF,d0
	;move.l	$6c(a0),.OldVBI-.VARS(a5)
	;move.l	$64(a0),OldSoftInt-.VARS(a5)


	move.w	#INTF_BLIT,INTENA(a6)	; forbid blitter interrupts
	move.w	#DMAF_ALL,DMACON(a6)		; disable DMA-channels


	move.w	#!DMAF_SETCLR,DMACON(a6)		; ;enable disk access
	move.w #ECSENAF!CONCOLF,BPLCON0(a6)
	move.w #BRDRBLNKF,BPLCON3(a6)

	lea	CopIntServer(pc),a1
	moveq  #4,d0
	CALLEXEC	AddIntServer         ;Add copper interrupt to system list
	lea	VBLIntServer(pc),a1
	moveq  #5,d0
	CALLEXEC	AddIntServer         ;Add vb interrupt to system list


	;bra .startQuit	-	runs on real 2 MB hardware

	IFNE SHELLHANDLING
	bsr shellLaunch
	ENDIF

	;move.l	GFXbase(pc),a6	; contains AGA-chipset?
	;btst.b	#2,$ec(a6)		; gb_ChipRevBits0
	;beq.w	errorConfig
	;move.l	Execbase,a6
	;btst	#0,296+1(a6)		; 68010+?
	;beq.w errorConfig			; nope.


	bsr	_Precalc

	move.l	freeAnimBase(pc),a1
	CALLEXEC CloseLibrary	; close freeanim.library, animation on CD32

	bsr _Main

***************************************************
*** Restore Sytem Parameter etc.		***
***************************************************
.END
	IFEQ (RELEASECANDIDATE||DEMOBUILD)
	lea	.VARS(pc),a5
	move.l .Stack-.VARS(a5),sp

			IFNE SHELLHANDLING
			WAITVBLANK
			WAITVBLANK
			tst.w errorNo(pc)
			bpl .skipBasics

			move.l #.mainFilename,d1
			clr.l d3
			bsr GetFileInfo        ; get filesize

			move.l (fib_Size.w,pc),d0	; get new memory
			move.l d0,.temp
			bsr shellMainExeSize

			;WAITVBLANK
			;WAITVBLANK
			tst.w errorNo(pc)
			bpl .skipBasics
			moveq #-1,d0
			move.l #MEMF_CHIP,d1
			CALLEXEC AvailMem
			move.l memChip(pc),d1
			sub.l d0,d1
			move.l d1,d0
			add.l d0,.temp
			bsr shellChipMemUsed

			WAITVBLANK
			WAITVBLANK
			moveq #-1,d0
			move.l #MEMF_FAST,d1
			CALLEXEC AvailMem
			move.l memFast(pc),d1
			sub.l d0,d1
			move.l d1,d0
			add.l d0,.temp
			bsr shellFastMemUsed


			WAITVBLANK
			WAITVBLANK
			move.l .temp,d0
			cmpi.l #$190000,d0	; check memory consumption. Too high?
			bcs .memoryOkay
			bsr shellMemoryWarning	; yes. Throw warning
			bra .skipBasics
.memoryOkay
			bsr shellMemoryOkay	; everything is fine
.skipBasics
			ENDIF

	bsr _Exit

.startQuit
	lea gameInActionF(pc),a1
	sf.b (a1)	; disable code in interrupt


	lea	CopIntServer(pc),a1
	moveq  #4,d0
	CALLEXEC	RemIntServer         ; remove copper interrupt
	lea	VBLIntServer(pc),a1
	moveq  #5,d0
	CALLEXEC	RemIntServer         ; remove vertical blank interrupt


	move.l	.VBRptr-.VARS(a5),a0	; restore error exception vectors
	lea .exceptHandlers(pc),a6
	movem.l (a6),d0-d3
	movem.l d0-d3,$8(a0)



	CALLEXEC Permit


	lea	CUSTOM,a6
	move.w	#$8000,d0
	or.w	d0,.INTENA-.VARS(a5)		; SET/CLR-Bit to 1
	or.w	d0,.DMA-.VARS(a5)		; SET/CLR-Bit to 1
	or.w	d0,.ADK-.VARS(a5)		; SET/CLR-Bit to 1
	subq.w	#1,d0
	move.l	.OldCop1(pc),$80(a6)		; Restore old CL 1
	move.l	.OldCop2(pc),$84(a6)		; Restore old CL 2
	move.w	d0,$88(a6)			; start copper1
	move.w	d0,$8a(a6)			; start copper1
	move.w	.DMA(pc),DMACON(a6)		; Restore DMAcon
	move.w	.ADK(pc),ADKCON(a6)		; Restore ADKcon
	;move.w	.INTENA(pc),INTENA(a6)		; Restore Interrupts
	clr.w COPCON(a6)	; limit copper access

	move.l	GFXbase(pc),a6
	move.l	.OldView(pc),a1			; restore old viewport
   	CALLGFX	LoadView
   	CALLGFX WaitTOF
   	CALLGFX WaitTOF
   	CALLGFX WaitBlit
  	CALLGFX DisownBlitter
    tst.b .wbclosed(pc)
    beq .reopenWB
	CALLINTUITION OpenWorkBench
.reopenWB


				IFNE SHELLHANDLING
				moveq #-1,d0			; detect memory leak
				move.l #MEMF_ANY,d1
				CALLEXEC AvailMem
				move.l memTotal(pc),d1
				sub.l d1,d0
				beq .noMemLeak
				neg.l d0
				;bsr shellMemoryLeak	; yes. Throw warning
.noMemLeak
				ENDIF
			   ; jsr shellQuit
				;bsr closeTerminal
.fff

			   ; bsr shellQuit
				;ENDIF

	move.l NVBase(pc),a1
	tst.l a1
	beq .noNVLib
	CALLEXEC CloseLibrary	; close NonVolatile.library
.noNVLib

	move.l LOWLVbase(pc),a1
	tst.l a1
	beq .noLowLvLib
	CALLEXEC CloseLibrary	; close NonVolatile.library
.noLowLvLib


	move.l INTUbase(pc),a1
	tst.l a1
	beq .noINTULib
	CALLEXEC CloseLibrary	; close intuition.library
.noINTULib

	move.l	GFXbase(pc),a1
	tst.l a1
	beq .noGFXLib
	CALLEXEC CloseLibrary	; close graphics.library
.noGFXLib

	move.l	DOSBase(pc),a1
	tst.l a1
	beq .noDosLib
	CALLEXEC CloseLibrary	; close dos.library
.noDosLib
	tst.b errorNo(pc)
	bpl .error
	moveq #0,d0
	rts
	ELSE
	illegal
	ENDIF
	;IFNE SHELLHANDLING
.error
	move #DMAF_SETCLR!DMAF_ALL,$dff096 ;DMA on: blitterpriority, bitplanes, sprites, copper, all audiochannels

	;move.w #100,d2
.bddd
	;move.w #50000,d1
.addd
	;WAITRASTER 20
	;WAITRASTER 19
	;move.w d2,$dff180
	;dbra d1,.addd
	;dbra d2,.bddd
	bsr printError
	moveq #1,d0
	rts

*******************************************
*** Get Address of the VBR		***
*******************************************

.GetVBR	move.l	a5,-(a7)
	moveq	#0,d0			; default at $0
	move.l	$4.w,a6
	btst	#0,296+1(a6)		; 68010+?
	beq.b	.is68k			; nope.
	lea	.getit(pc),a5
	jsr	-30(a6)			; SuperVisor()
.is68k	move.l	(a7)+,a5
	rts

.getit	movec   vbr,d0
	move.l d0,VBRptr
	rte				; back to user state code

*******************************************
*** DATA AREA		FAST		***
*******************************************
	ALIGNLONG
.VARS
.OldView	dc.l	0
.OldCop1	dc.l	0
.OldCop2	dc.l	0
.VBRptr		dc.l	0
.OldVBI		dc.l	0
.ADK		dc.w	0
.INTENA		dc.w	0
.DMA		dc.w	0
.Stack		dc.l	0
.Quit		dc.l	0
.temp		dc.l	0,0
.exceptHandlers	dc.l	0,0,0,0
.DosName	dc.b			"dos.library",0
.GFXname	dc.b			'graphics.library',0
.IntuName	dc.b 			"intuition.library",0
.NVName		dc.b			"nonvolatile.library",0
.LOWLVName	dc.b			"lowlevel.library",0
.freeAnimName		dc.b			"freeanim.library",0
.inputDevice	dc.b 	"input.device",0
.wbclosed	dc.l	0		; 0 = Unable to close Workbench
.mainFilename	dc.b "PROGDIR:px.bin",0
	even
GFXbase		dc.l	0
INTUbase	dc.l	0
DOSBase		dc.l    0
NVBase		dc.l	0
LOWLVbase	dc.l	0
freeAnimBase	dc.l	0
OldSoftInt	dc.l	0
VBIptr		dc.l	0
VBRptr		dc.l	0
Stack
			dc.l	0
ReturnMsg
			dc.l	0
ReturnCode
			dc.l	0
startupQuit
			dc.l	0
	
FireButtonB	       dc.w	1
	
pot	       dc.b	'potgo.resource',0
	ALIGNLONG
CopIntServer
	dc.l  0,0                     ;ln_Succ,ln_Pred
	dc.b  0,9                     ;ln_Type,ln_Pri
	even
	dc.l  CopIntName                 ;ln_Name
	dc.l  0,copperInt             ;is_Data,is_Code
VBLIntServer
	dc.l  0,0                     ;ln_Succ,ln_Pred
	dc.b  0,9                     ;ln_Type,ln_Pri
	even
	dc.l  VBLIntName                 ;ln_Name
	dc.l  0,vertBlancInt             ;is_Data,is_Code
SoftIntServer	; no server, called from copper interrupt
	dc.l  0,0                     ;ln_Succ,ln_Pred
	dc.b  0,9                     ;ln_Type,ln_Pri
	even
	dc.l  softIntName                 ;ln_Name
	dc.l  0,softInt             ;is_Data,is_Code


int
	rts
	
CopIntName	dc.b "int",0
VBLIntName	dc.b "int",0
softIntName	dc.b "int",0
	even