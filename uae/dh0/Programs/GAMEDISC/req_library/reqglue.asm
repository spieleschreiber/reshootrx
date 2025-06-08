
	include "libraries/reqbase.i"

	xref	_ReqBase



GLUE	MACRO
	XDEF	_\1
_\1
	ENDM

NEWSYS	MACRO
	PEA	_LVO\1			;4
	BRA	JumpIt			;2 to 4.
	ENDM

STACKOFFSET	EQU	4



GLUE2	MACRO
	XDEF	_\1
_\1
	MOVEM.L	D2-D4/A2-A3/A6,-(SP)
	ENDM

NEWSYS2	MACRO
	MOVE.L	_ReqBase,A6
	JSR	_LVO\1(A6)
	MOVEM.L	(SP)+,D2-D4/A2-A3/A6
	RTS
	ENDM

STACKOFFSET2	EQU	28



	GLUE	Center
	MOVE.L	STACKOFFSET(SP),A0
	MOVEM.L	STACKOFFSET+4(SP),D0-D1
	NEWSYS	Center

	GLUE	SetSize
	MOVEM.L	STACKOFFSET(SP),D0-D1
	NEWSYS	SetSize

	GLUE2	SetLocation
	MOVEM.L	STACKOFFSET2(SP),D0-D2
	NEWSYS2	SetLocation

	GLUE2	ReadLocation
	MOVEM.L	STACKOFFSET2(SP),D0-D2
	NEWSYS2	ReadLocation

	GLUE2	Format
	MOVEM.L	STACKOFFSET2(SP),A0-A2
	NEWSYS2	Format

	GLUE	FileRequester
	MOVE.L	STACKOFFSET(SP),A0
	NEWSYS	FileRequester

	GLUE	ColorRequester
	MOVE.L	STACKOFFSET(SP),D0
	NEWSYS	ColorRequester

	GLUE	ExtendedColorRequester
	MOVE.L	STACKOFFSET(SP),A0
	NEWSYS	ExtendedColorRequester

	GLUE2	DrawBox
	MOVE.L	STACKOFFSET2(SP),A1
	MOVEM.L	STACKOFFSET2+4(SP),D0-D3
	NEWSYS2	DrawBox

	GLUE2	MakeButton
	MOVEM.L	STACKOFFSET2(SP),A0-A2
	MOVEM.L	STACKOFFSET2+12(SP),D0-D2
	NEWSYS2	MakeButton

	GLUE2	MakeScrollBar
	MOVE.L	STACKOFFSET2(SP),A0
	MOVEM.L	STACKOFFSET2+4(SP),D0-D3
	NEWSYS2	MakeScrollBar

	GLUE	PurgeFiles
	MOVE.L	STACKOFFSET(SP),A0
	NEWSYS	PurgeFiles

	GLUE	GetFontHeightAndWidth
	NEWSYS	GetFontHeightAndWidth

	GLUE	MakeGadget
	MOVEM.L	STACKOFFSET(SP),A0-A1	;Parameter are on the stack in the order A0,A1,D0,D1
	MOVEM.L	STACKOFFSET+8(SP),D0-D1
	NEWSYS	MakeGadget

	GLUE	MakeString
	MOVEM.L	STACKOFFSET(SP),A0-A1
	MOVEM.L	STACKOFFSET+8(SP),D0-D1
	NEWSYS	MakeString

	GLUE	MakeProp
	MOVE.L	STACKOFFSET(SP),A0
	MOVEM.L	STACKOFFSET+4(SP),D0-D2
	NEWSYS	MakeProp

	GLUE2	LinkGadget
	MOVEM.L	STACKOFFSET2(SP),A0-A1/A3
	MOVEM.L	STACKOFFSET2+12(SP),D0-D1
	NEWSYS2	LinkGadget

	GLUE2	LinkStringGadget
	MOVEM.L	STACKOFFSET2(SP),A0-A3
	MOVEM.L	STACKOFFSET2+16(SP),D0-D3
	NEWSYS2	LinkStringGadget

	GLUE2	LinkPropGadget
	MOVEM.L	STACKOFFSET2(SP),A0/A3
	MOVEM.L	STACKOFFSET2+8(SP),D0-D4
	NEWSYS2	LinkPropGadget

	GLUE2	GetString
	MOVEM.L	STACKOFFSET2(SP),A0-A2
	MOVEM.L	STACKOFFSET2+12(SP),D0-D1
	NEWSYS2	GetString

	GLUE	RealTimeScroll
	MOVE.L	STACKOFFSET(SP),A0
	NEWSYS	RealTimeScroll

	GLUE	TextRequest
	MOVE.L	STACKOFFSET(SP),A0
	NEWSYS	TextRequest

	GLUE	GetLong
	MOVE.L	STACKOFFSET(SP),A0
	NEWSYS	GetLong

	GLUE	RawKeyToAscii
	MOVEM.L	STACKOFFSET(SP),D0-D1
	MOVE.L	STACKOFFSET+8(SP),A0
	NEWSYS	RawKeyToAscii


;         These  routines  are a little bit more work to write glue code for
; because  they  use  register  beyond  the  scratch  register  D0-D1/A0-A1.
; Therefore  these  registers  have  to be saved before values can be loaded
; into them.



;         This  code was designed to minimize the overhead of the individual
; pieces of glue code for the individual routines.  With this 'helper' code,
; all  the  glue  code for each routine has to do is load the registers from
; the  stack  (no  way  to  avoid that), push the _LVO offset onto the stack
; (hard  to  avoid  doing  something like that) and then branch down to this
; routine.

	XDEF	JumpIt,StackCleanup	;Make these visible to a debugger.

JumpIt
	PEA	StackCleanup		;Push the address of the code that restores A6.
	MOVE.L	4(sp),-(sp)		;Push the _LVO offset further down the stack
	MOVE.L	A6,8(sp)		;so that the old value of A6 can be stored
					;above it.
	MOVE.L	_ReqBase,A6
	MOVE.L	D0,-(sp)
	MOVE.L	A6,D0
	ADD.L	D0,4(sp)		;Add _ReqBase to the _LVO offset so when you go
					;return, you'll branch to the routine.
	MOVE.L	(sp)+,D0
	RTS
StackCleanup
	MOVE.L	(sp)+,A6
	RTS



;;;;;         The  version  of this code for Aztec is really simple, since Aztec
;;;;; doesn't currently expect you to preserve A6.
;;;;
;;;;JumpIt
;;;;	MOVE.L	_ReqBase,A6
;;;;	MOVE.L	D0,-(sp)
;;;;	MOVE.L	A6,D0
;;;;	ADD.L	D0,4(sp)		;Add _ReqBase to the _LVO offset so when you go
;;;;					;return, you'll branch to the routine.
;;;;	MOVE.L	(sp)+,D0
;;;;	RTS







SureText	DC.B	"  Ok  ",0
CancelText	DC.B	"Cancel",0
ResumeText	DC.B	"Resume",0

	even


	GLUE	SimpleRequest
	MOVE.L	STACKOFFSET(SP),A0
	LEA	STACKOFFSET+4(SP),A1
	BRA	SimpleRequest

	GLUE	TwoGadRequest
	MOVE.L	STACKOFFSET(SP),A0
	LEA	STACKOFFSET+4(SP),A1
	BRA	TwoGadRequest



srRegs	REG	A2-A4/D2

;----------------------------------------------------
	public	TwoGadRequest
TwoGadRequest:
;Bool=TwoGadRequest(String,Controls)
;                     A0      A1

	MOVEM.L	srRegs,-(sp)
	LEA.L	SureText,A2
	LEA.L	CancelText,A3
	BRA.S	TheRequest

	public	SimpleRequest
SimpleRequest:

;SimpleRequest(Text,Controls)
;               A0	A1
; This is just a method of telling a user something. It just calls MultiRequest
; with no gadgets.

	MOVEM.L	srRegs,-(sp)
	SUBA.L	A2,A2
	LEA.L	ResumeText,A3

TheRequest

	MOVE.L	_ReqBase,A6	;Load A6 from the data segment _before_ tromping on A4.

	SUB.W	#TR_SIZEOF,SP		;get some temporary storage.

	MOVE.L	SP,A4
	MOVEQ	#TR_SIZEOF/2-1,D2	;because the stack is almost never clear.
1$	CLR.W	(A4)+
	DBF	D2,1$

	MOVE.L	A0,TR_Text(SP)
	MOVE.L	A1,TR_Controls(SP)
	MOVE.L	A2,TR_PositiveText(SP)
	MOVE.L	A3,TR_NegativeText(SP)

	MOVE.W	#$FFFF,TR_KeyMask(SP)

	MOVE.L	SP,A0
	JSR	_LVOTextRequest(A6)

	ADD.W	#TR_SIZEOF,SP

	MOVEM.L	(sp)+,srRegs
	RTS



	END
