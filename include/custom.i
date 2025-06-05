**
**	$Filename: hardware/custom.i $
**	$Release: 2.04 Includes, V37.4 $
**	$Revision: 36.6 $
**	$Date: 91/04/30 $
**
**	Offsets of Amiga custom MEMF_CHIP registers
**
**	(C) Copyright 1985-1999 Amiga, Inc.
**	    All Rights Reserved
**	CUSTOMIZED 2025 Richard Löwenstein 
**

* This instruction for the copper will cause it to wait forever since
* the wait command described in it will never happen.
*
COPPER_HALT     equ     $FFFFFFFE
*
*******************************************************************************
*
* This is the offset in the 680x0 address space to the custom chip registers
* It is the same as  _custom  when linking with AMIGA.lib
*
CUSTOM          equ     $DFF000

*
* Various control registers
*


BLTDDAT		equ	$000
DMACONR		equ	$002
VPOSR		equ	$004
VHPOSR		equ	$006
DSKDATR		equ	$008
JOY0DAT		equ	$00a
JOY1DAT		equ	$00c
CLXDAT		equ	$00e
ADKCONR		equ	$010
POT0DAT		equ	$012
POT1DAT		equ	$014
POTGOR		equ	$016
SERDATR		equ	$018

REFPTR		equ	$028
VPOSW		equ	$02a
VHPOSW		equ	$02c
COPCON		equ	$02e
SERDAT		equ	$030
SERPER		equ	$032
POTGO		equ	$034
JOYTEST		equ	$036
STREQU		equ	$038
STRVBL		equ	$03a
STRHOR		equ	$03c
STRLONG		equ	$03e

*
* Disk control registers
*

DSKBYTR		equ	$01a
INTENAR		equ	$01c
INTREQR		equ	$01e
DSKPT		equ	$020
DSKPTH		equ	$020
DSKPTL		equ	$022
DSKLEN		equ	$024
DSKDAT		equ	$026
DSKSYNC		equ	$07e



*
* Blitter registers
*

BLTCON0		equ	$040
BLTCON1		equ	$042
BLTAFWM		equ	$044
BLTALWM		equ	$046
BLTCPT		equ	$048
BLTCPTH		equ	$048
BLTCPTL		equ	$04a
BLTBPT		equ	$04c
BLTBPTH		equ	$04c
BLTBPTL		equ	$04e
BLTAPT		equ	$050
BLTAPTH		equ	$050
BLTAPTL		equ	$052
BLTDPT		equ	$054
BLTDPTH		equ	$054
BLTDPTL		equ	$056
BLTSIZE		equ	$058
BLTCMOD		equ	$060
BLTBMOD		equ	$062
BLTAMOD		equ	$064
BLTDMOD		equ	$066
BLTCDAT		equ	$070
BLTBDAT		equ	$072
BLTADAT		equ	$074

*
* Copper control registers
*

COP1LC		equ	$080
COP1LCH		equ	$080
COP1LCL		equ	$082
COP2LC		equ	$084
COP2LCH		equ	$084
COP2LCL		equ	$086
COPJMP1		equ	$088
COPJMP2		equ	$08a
COPINS		equ	$08c


DIWSTRT		equ	$08e
DIWSTOP		equ	$090
DDFSTRT		equ	$092
DDFSTOP		equ	$094
DMACON		equ	$096
CLXCON		equ	$098
CLXCON2     equ $10E
INTENA		equ	$09a
INTREQ		equ	$09c
ADKCON		equ	$09e

*
* Audio channel registers
*

AUD0LC		equ	$0a0
AUD0LCH		equ	$0a0
AUD0LCL		equ	$0a2
AUD0LEN		equ	$0a4
AUD0PER		equ	$0a6
AUD0VOL		equ	$0a8
AUD0DAT		equ	$0aa
AUD1LC		equ	$0b0
AUD1LCH		equ	$0b0
AUD1LCL		equ	$0b2
AUD1LEN		equ	$0b4
AUD1PER		equ	$0b6
AUD1VOL		equ	$0b8
AUD1DAT		equ	$0ba
AUD2LC		equ	$0c0
AUD2LCH		equ	$0c0
AUD2LCL		equ	$0c2
AUD2LEN		equ	$0c4
AUD2PER		equ	$0c6
AUD2VOL		equ	$0c8
AUD2DAT		equ	$0ca
AUD3LC		equ	$0d0
AUD3LCH		equ	$0d0
AUD3LCL		equ	$0d2
AUD3LEN		equ	$0d4
AUD3PER		equ	$0d6
AUD3VOL		equ	$0d8
AUD3DAT		equ	$0da

*
*  The bitplane registers
*

BPLPT	    equ $0e0
BPL1PT		equ	$0e0
BPL1PTH		equ	$0e0
BPL1PTL		equ	$0e2
BPL2PT		equ	$0e4
BPL2PTH		equ	$0e4
BPL2PTL		equ	$0e6
BPL3PT		equ	$0e8
BPL3PTH		equ	$0e8
BPL3PTL		equ	$0ea
BPL4PT		equ	$0ec
BPL4PTH		equ	$0ec
BPL4PTL		equ	$0ee
BPL5PT		equ	$0f0
BPL5PTH		equ	$0f0
BPL5PTL		equ	$0f2
BPL6PT		equ	$0f4
BPL6PTH		equ	$0f4
BPL6PTL		equ	$0f6
BPL7PT		equ	$0f8
BPL7PTH		equ	$0f8
BPL7PTL		equ	$0fa
BPL8PT		equ	$0fc
BPL8PTH		equ	$0fc
BPL8PTL		equ	$0fe



BPLCON0		equ	$100
BPLCON1		equ	$102
BPLCON2		equ	$104
BPLCON3		equ	$106
BPL1MOD		equ	$108
BPL2MOD		equ	$10a
BPLCON4		equ	$10c

BPLDAT	    equ $110
BPL1DAT		equ	$110
BPL2DAT		equ	$112
BPL3DAT		equ	$114
BPL4DAT		equ	$116
BPL5DAT		equ	$118
BPL6DAT		equ	$11a
BPL7DAT     equ $11c
BPL8DAT     equ $11e

*
* Sprite control registers
*



SPRPT	    equ $120

SPR	    	equ $140

SPR0PT		equ	$120
SPR0PTH		equ	$120
SPR0PTL		equ	$122
SPR1PT		equ	$124
SPR1PTH		equ	$124
SPR1PTL		equ	$126
SPR2PT		equ	$128
SPR2PTH		equ	$128
SPR2PTL		equ	$12a
SPR3PT		equ	$12c
SPR3PTH		equ	$12c
SPR3PTL		equ	$12e
SPR4PT		equ	$130
SPR4PTH		equ	$130
SPR4PTL		equ	$132
SPR5PT		equ	$134
SPR5PTH		equ	$134
SPR5PTL		equ	$136
SPR6PT		equ	$138
SPR6PTH		equ	$138
SPR6PTL		equ	$13a
SPR7PT		equ	$13c
SPR7PTH		equ	$13c
SPR7PTL		equ	$13e
SPR0POS		equ	$140
SPR0CTL		equ	$142
SPR0DATA	equ	$144
SPR0DATB	equ	$146
SPR1POS		equ	$148
SPR1CTL		equ	$14a
SPR1DATA	equ	$14c
SPR1DATB	equ	$14e
SPR2POS		equ	$150
SPR2CTL		equ	$152
SPR2DATA	equ	$154
SPR2DATB	equ	$156
SPR3POS		equ	$158
SPR3CTL		equ	$15a
SPR3DATA	equ	$15c
SPR3DATB	equ	$15e
SPR4POS		equ	$160
SPR4CTL		equ	$162
SPR4DATA	equ	$164
SPR4DATB	equ	$166
SPR5POS		equ	$168
SPR5CTL		equ	$16a
SPR5DATA	equ	$16c
SPR5DATB	equ	$16e
SPR6POS		equ	$170
SPR6CTL		equ	$172
SPR6DATA	equ	$174
SPR6DATB	equ	$176
SPR7POS		equ	$178
SPR7CTL		equ	$17a
SPR7DATA	equ	$17c
SPR7DATB	equ	$17e

*
* Color registers...
*
COLOR	    equ $180
COLOR00		equ	$180
COLOR01		equ	$182
COLOR02		equ	$184
COLOR03		equ	$186
COLOR04		equ	$188
COLOR05		equ	$18a
COLOR06		equ	$18c
COLOR07		equ	$18e
COLOR08		equ	$190
COLOR09		equ	$192
COLOR10		equ	$194
COLOR11		equ	$196
COLOR12		equ	$198
COLOR13		equ	$19a
COLOR14		equ	$19c
COLOR15		equ	$19e
COLOR16		equ	$1a0
COLOR17		equ	$1a2
COLOR18		equ	$1a4
COLOR19		equ	$1a6
COLOR20		equ	$1a8
COLOR21		equ	$1aa
COLOR22		equ	$1ac
COLOR23		equ	$1ae
COLOR24		equ	$1b0
COLOR25		equ	$1b2
COLOR26		equ	$1b4
COLOR27		equ	$1b6
COLOR28		equ	$1b8
COLOR29		equ	$1ba
COLOR30		equ	$1bc
COLOR31		equ	$1be
HTOTAL		equ	$1c0
HSSTOP		equ	$1c2
HBSTRT		equ	$1c4
HBSTOP		equ	$1c6
VTOTAL		equ	$1c8
VSSTOP		equ	$1ca
VBSTRT		equ	$1cc
VBSTOP		equ	$1ce
SPRHSTRT	equ	$1d0
SPRHSTOP	equ	$1d2
BPLHSTRT	equ	$1d4
BPLHSTOP	equ	$1d6
HHPOSW		equ	$1d8
HHPOSR		equ	$1da
BEAMCON0	equ	$1dc
HSSTRT		equ	$1de
VSSTRT		equ	$1e0
HCENTER		equ	$1e2
DIWHIGH		equ	$1e4
BPLHMOD		equ	$1e6
SPRHPT		equ	$1e8
SPRHPTH		equ	$1e8
SPRHPTL		equ	$1ea
BPLHPT		equ	$1ec
BPLHPTH		equ	$1ec
BPLHPTL		equ	$1ee
FMODE		equ	$1fc
NOOP        equ $1fe

aud	    EQU   $0A0
aud0	    EQU   $0A0
aud1	    EQU   $0B0
aud2	    EQU   $0C0
aud3	    EQU   $0D0

* AudChannel
ac_ptr	    EQU   $00	; ptr to start of waveform data
ac_len	    EQU   $04	; length of waveform in words
ac_per	    EQU   $06	; sample period
ac_vol	    EQU   $08	; volume
ac_dat	    EQU   $0A	; sample pair
ac_SIZEOF   EQU   $10

* SpriteDef
sd_pos	    EQU   $00
sd_ctl	    EQU   $02
sd_dataa    EQU   $04
sd_dataB    EQU   $06
sd_SIZEOF   EQU   $08








Open		=	-30
Close		=	-36

WaitTOF     =   -270

Execbase	=	4
MEMF_ANY        =   0
MEMF_CHIP		=	1<<1
MEMF_FAST		=	1<<2
MEMF_CLEAR   	=   1<<16
MEMF_LARGEST	=	1<<17	; returns larget chunk of memory, also does memory list sanity test (and gurus if sth wrong)
MEMF_TOTAL		=	1<<19

; hardware/intbits.i

INTB_SETCLR    EQU   (15)  ;Set/Clear control bit. Determines if bits
			   ;written with a 1 get set or cleared. Bits
			   ;written with a zero are allways unchanged.
INTB_INTEN     EQU   (14)  ;Master interrupt (enable only )
INTB_EXTER     EQU   (13)  ;External interrupt
INTB_DSKSYNC   EQU   (12)  ;Disk re-SYNChronized
INTB_RBF       EQU   (11)  ;serial port Receive Buffer Full
INTB_AUD3      EQU   (10)  ;Audio channel 3 block finished
INTB_AUD2      EQU   (9)   ;Audio channel 2 block finished
INTB_AUD1      EQU   (8)   ;Audio channel 1 block finished
INTB_AUD0      EQU   (7)   ;Audio channel 0 block finished
INTB_BLIT      EQU   (6)   ;Blitter finished
INTB_VERTB     EQU   (5)   ;start of Vertical Blank
INTB_COPER     EQU   (4)   ;Coprocessor
INTB_PORTS     EQU   (3)   ;I/O Ports and timers
INTB_SOFTINT   EQU   (2)   ;software interrupt request
INTB_DSKBLK    EQU   (1)   ;Disk Block done
INTB_TBE       EQU   (0)   ;serial port Transmit Buffer Empty

INTF_SETCLR    EQU   (1<<INTB_SETCLR)
INTF_INTEN     EQU   (1<<INTB_INTEN)
INTF_BLIT      EQU   (1<<INTB_BLIT)
INTF_COPER      EQU   (1<<INTB_COPER)
INTF_VERTB     EQU   (1<<INTB_VERTB)
INTF_PORTS     EQU   (1<<INTB_PORTS)


; hardware/dma.i

DMAF_SETCLR    EQU   $8000
DMAF_AUDIO     EQU   $000F  * 4 bit mask
DMAF_AUD0      EQU   $0001
DMAF_AUD1      EQU   $0002
DMAF_AUD2      EQU   $0004
DMAF_AUD3      EQU   $0008
DMAF_DISK      EQU   $0010
DMAF_SPRITE    EQU   $0020
DMAF_BLITTER   EQU   $0040
DMAF_COPPER    EQU   $0080
DMAF_BPLEN    EQU   $0100
DMAF_MASTER    EQU   $0200
DMAF_BLITHOG   EQU   $0400
DMAF_ALL       EQU   $01FF  * all dma channels

* read definitions for dmaconr
* bits 0-8 correspnd to dmaconw definitions
DMAF_BLTDONE   EQU   $4000
DMAF_BLTNZERO  EQU   $2000

DMAB_SETCLR    EQU   15
DMAB_AUD0      EQU   0
DMAB_AUD1      EQU   1
DMAB_AUD2      EQU   2
DMAB_AUD3      EQU   3
DMAB_DISK      EQU   4
DMAB_SPRITE    EQU   5
DMAB_BLITTER   EQU   6
DMAB_COPPER    EQU   7
DMAB_BPLEN    EQU   8
DMAB_MASTER    EQU   9
DMAB_BLITHOG   EQU   10
DMAB_BLTDONE   EQU   14
DMAB_BLTNZERO  EQU   13

; 	BPLCON

HIRES 	EQU		15
BPU3	EQU		04
BPU2	EQU		14
BPU1	EQU		13
BPU0	EQU		12
HAM		EQU		11
DPF		EQU		10
CONCOL	EQU		09
LACE	EQU		02
ECSENA	EQU		00

HIRESF	EQU		(1<<HIRES)
BPU3F	EQU		(1<<BPU3)
BPU2F	EQU		(1<<BPU2)
BPU1F	EQU		(1<<BPU1)
BPU0F	EQU		(1<<BPU0)
HAMF		EQU		(1<<HAM)
DPFF		EQU		(1<<DPF)
CONCOLF		EQU		(1<<CONCOL)
LACEF	EQU		(1<<LACE)
ECSENAF	EQU		(1<<ECSENA)

;	BPLCON2
PF2PRI		EQU		06
PF2PRIF		EQU	(1<<PF2PRI)
RDRAM		EQU		08
RDRAMF		EQU	(1<<RDRAM)
KILLEHB		EQU		09	
KILLEHBF	EQU	(1<<KILLEHB)

;	BPLCON3

BRDSPRT		EQU	01
SPRES0	EQU		06
SPRES1	EQU		07
LOCT	EQU		09
	IFEQ SHOWRASTERBARS
BRDRBLNK	set	05
	ELSE
BRDRBLNK	set	04
	ENDIF
PF2OF2	EQU		12
PF2OF1	EQU		11
PF2OF0	EQU		10
BANK2	EQU		15
BANK1	EQU 	14
BANK0	EQU		13

BRDSPRTF	EQU	(1<<BRDSPRT)
SPRES0F	EQU	(1<<SPRES0)
SPRES1F	EQU	(1<<SPRES1)
LOCTF	EQU	(1<<LOCT)
BRDRBLNKF	EQU	(1<<BRDRBLNK)
PF2OF2F	EQU	(1<<PF2OF2)
PF2OF1F	EQU	(1<<PF2OF1)
PF2OF0F	EQU	(1<<PF2OF0)
BANK0F	EQU	(1<<BANK0)
BANK1F	EQU	(1<<BANK1)
BANK2F	EQU	(1<<BANK2)

