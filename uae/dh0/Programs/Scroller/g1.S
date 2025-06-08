
Open		=	-30
Close		=	-36
FindTask	=	-294
SetTaskPri	=	-300
OpenLibrary	=	-552
CloseLibrary	=	-414
AllocMem	=	-198
FreeMem		=	-210
Execbase	=	4
Chip		=	2
Fast		=	4


;game = $3000
;startorg = $780000
;gameorg = startorg+$300
startpos = 00

;editor  = $7c0000
edcoplist = $30000
			; *** Tabellen - Adressen
landscapeadr:		blk.l	$1000
landscpeadr:		blk.l	$1000
;blockadr = $4a000
;blockshdw = $8000
;blockshdw2 = $12000
blockadr:		blk.l	$8000/4
blockshdw:		blk.l	$4000/4
blockshdw2:		blk.l	$4000/4


spradr = 256*200+blockadr
sprshdwadr = $72000
sa = spradr
sl = 370
sm = (sl-256)*200
sb = sl*200+blockadr
sconst = 3*256*40*5+blockadr
;sprshdw = $c800


;bobanimtab = $7f000
;bobpostab = $6f800
;banimtab = $d000
;blockpointer = $e000
;blockpointer2 = $e200
;scr2muls = $e400
;bobcuttab = $e600
;wavecount = $70680

scrMemsize		=	$10000
bobanimtab:		blk.l	$17c/4
bobpostab:		blk.l	$100/4
banimtab:		blk.l	$100/4
blockpointer		blk.l	10*10,0
;blockpointer2 = $e200
scr2muls:		blk.w	256,0
bobcuttab		blk.w	128
wavecount = $70680



			; *** Festwerte
	banxpos=256
	banypos=banxpos*2
	banaccl=banxpos*3
	bancnt=banxpos*4
	banhit=banxpos*5
	banwav=banxpos*6
	
	dispstop=$f6

		f=$ffff

	Section 	killSys, CODE_F
t:
	move.l	Execbase,a6
	sub.l	a1,a1
	jsr FindTask(a6)
	move.l	d0,a1
	moveq#127,d0
	jsr SetTaskPri(a6)

	move#-1,$dff02e
	move $dff01c,savessp+12
	move $dff002,savessp+14

	move#%0100000000000000,$dff09a
	move#%1000011111110000,$dff096

;	move.l Execbase,a6
;	jsr -150(a6)
;	move.l d0,savessp	;Supervisor-mode an
	move.l $6c,savessp+4
	move.l a7,savessp+8

	move.l	#scrMemSize,d0
	move.l	#Chip,d1
	jsr AllocMem(a6)
	beq theEnd
	move.l	d0,scr2base
	
;	lea$0,a0
;	lea$640000,a1
;	move.l#$3fffc/4,d0
saveintuition:
;	move.l(a0)+,(a1)+
;	dbra d0,saveintuition

;	lea gameorg,a0
;	lea game,a1
;	move.l#$3ff8/4,d0
saveintuition2:
;	move.l(a0)+,(a1)+
;	dbra d0,saveintuition2
	;jsr mainstart2
	jmp mainstart2

x:
mainendgame:
	move#$7fff,$dff09a
	;move#0,$dff02e
	;move#$8040,$dff096
	lea intuition(pc),a1
	moveq#0,d0
	move.l 4,a6
	jsr -552(a6)

	move.l 38(a0),$dff080
	move.l 50(a0),$dff084
	move $dff088,$dff088
	move.l a0,a1
	jsr -414(a6)		;Betr.system-Copperliste an
;	move#$8040,$dff096

;	lea $640000,a0
;	lea $0,a1
;	move.l #$3fffc/4,d0
writeintuition:
;	move.l (a0)+,(a1)+
;	dbcs d0,writeintuition
	move#$8040,$dff096

;	move.l savessp,d0
;	move.l 4,a6
;	jsr -156(a6)		;supervisor-modus aus
	;move#$8040,$dff096
	move.l savessp+4,$6c
	move.l savessp+8,a7
	move#$7fff,$dff096
	move#$7fff,$dff09a
	move savessp+12,d0
	or#$8000,d0
	move d0,$dff09a
	move savessp+14,d0
	or#$8000,d0
	move d0,$dff096
	moveq#0,d0	
	;move d0,$dff09a
	;move#%1000000000000000,$dff09c
	;move#%1100000000100000,$dff09a
	;move#%1100000000100000,$dff09c

	move.l	Execbase,a6
	move.l	scr2base,a1
	move.l	#scrMemSize,d0
	jsr FreeMem(a6)
theEnd:
	clr.l	d0
	illegal
m2:
	lea sconst,a0
	lea sb,a1
	move.l#(sl-256)*50,d0
xcopymainspr:
	move.l (a0)+,(a1)+
	dbra d0,xcopymainspr

	lea spradr,a2
	lea sprshdwadr,a3

	move#215,d0
xwrtblockpointer1:
	moveq#9,d1
	move.l a2,a0
	move.l a3,a1
xwrtblockpointer:
	move.l (a0),d7
	or.l 40(a0),d7
	or.l 80(a0),d7
	or.l 120(a0),d7
	or.l 160(a0),d7
	move.l d7,(a1)
	move.l d7,40(a1)
	move.l d7,80(a1)
	move.l d7,120(a1)
	move.l d7,160(a1)
	addq#4,a0
	addq#4,a1
	dbra d1,xwrtblockpointer
	add#200,a2
	add#200,a3
	dbra d0,xwrtblockpointer1
	rts
savessp:
	blk.l 10,0
intuition:
	dc.b "graphics.library",0

	Section	gameData, DATA_C

progbase:
banimtabor:			;x-pos, y-pos, animnum, anz.wiederhol
				;abst.wiederhol, $80 = wdhstart jeweils
				;an alter xpos., hitstaerke
;dc.w 3,$0025,$2140,0
;dc.w 3,$0026,$520,0
;dc.w 20*8+3,$0027,$520,0
;dc.w 40*8+3,$0028,$520,0
;dc.w 3,$5009,$518,0


;dc.l $ffffffffff
	;dc.w 3*8+3,$101f,$900,$00
; 20 Muschel
; 21 Krebs unten
; 30 Krebs oben


;dc.w 0*8+3,$2044,$1401,$40
	;dc.l $ffffffff,$ffffffff


	dc.w 1*8+1,$203f,$518,$0
	dc.w 10*8+3,$d040,$518,0
	dc.w 40*8+3,$3041,$518,0
	dc.w 60*8+3,$d042,$518,0
	dc.w 100*8+3,$4043,$50e,0
	dc.w 114*8+3,$1044,$50e,0
	dc.w 128*8+3,$c045,$50e,0
	dc.w 140*8+3,$3043,$50e,0
	dc.w 154*8+3,$7044,$50e,0
	dc.w 168*8+3,$b045,$50e,0
	dc.w 182*8+3,$2043,$50e,0
	dc.w 200*8+3,$2046,$1520,$25
	dc.w 201*8+3,$8047,$1520,$25
	dc.w 202*8+3,$c048,$1520,$25


;dc.w 130*8+3,$5044,$518,0
;dc.w 131*8+3,$1044,$518,0
;dc.w 130*8+3,$3043,$510,0
;dc.w 140*8+3,$3044,$510,0


;dc.w 80*8+3,$2643,$150c,0
;dc.w 120*8+3,$c621,$2d0,1
;dc.w 132*8+3,$2630,$2d0,1

;dc.w 10*8+3,$d021,$16a0,5


	dc.l $ffffffff,$ffffffff

banim0:					;Standardschuss
	dc.b $50,0,$1,0,  0,0,$1f,0,$80,$80
banim1:					
	dc.b $20,-$10,1,3, 1,0,6,3, 1,0,6,2, 1,0,6,2, 1,0,30,1, $80,$80 
banim2:
	dc.b $20,$10,1,8, 1,0,6,8, 2,0,6,7, 1,0,6,7, 1,0,30,6, $80,$80 

	;dc.b $20,$10,1,1, 2,1,$20,1, $80,4,$80
banim3:
	dc.b $30,-$20,1,1, 2,-1,6,1, 1,-1,6,2, 1,-1,6,3, 0,-1,6,4 
	dc.b 0,0,6,5, $80,$80
	;dc.b $30,-$40,1,1, 0,$11,$40,1, $80,$80
banim4:
	dc.b $30,$20,1,1, 2,1,6,6, 1,1,6,7, 1,1,6,8, 0,1,6,9 
	dc.b 0,0,$12,6, $80,$80

	;dc.b 0,0,1,3, 0,0,1,4, 0,0,1,5, 0,0,1,6, $80,$80
banim5:
	;dc.b 0,0,2,7, 0,0,2,8, 0,0,2,9, 0,0,2,10, 0,0,2,11
	;dc.b 0,0,2,12,0,0,2,13,0,0,2,14, $80,$80
banim6:
	dc.b 0,-2,10,15, 0,2,24,15, $80,6,$80,$80

;0,0,1,15, $80,6
banim7:
	dc.b 10,1,2,34, 0,0,2,32, 0,0,2,33, 0,0,2,34, 0,0,2,35
	dc.b 0,0,2,36, 0,0,2,37, 0,0,2,38, 0,0,2,39, $80,$80

banim8:
	dc.b 10,0,6,26, 0,0,6,27, 0,0,6,28, 0,0,6,29
	dc.b 0,0,6,30, 0,0,6,31, $80,$80
banim9:
	dc.b 0,0,2,22, 0,0,2,23, 0,0,2,24, 0,0,2,25, $80,$80
banima:
	dc.b -4,0,1,2, 0,0,$7f,2, $80,$1f,$1e,$80
banimb:
banimc:
banimd:
banime:
banimf:
banim10:
banim11:
banim12:
banim13:
banim14:
banim15:
banim16:
banim17:
banim18:
banim19:
banim1a:
banim1b:
banim1c:
banim1d:
banim1e:
banim1f:
banim20:
	dc.b 0,0,$4f,43, 0,0,$1f,41, 0,0,$2f,42, -1,-48,1,40, 0,1,$60,40 
	dc.b 1,-48,1,42, 0,0,$1f,41, 0,0,$2f,43, $80,$80
banim21:
	dc.b -9,-2,1,48, 0,0,$2f,48, 8,1,1,48
	dc.b 0,0,$0f,48, $80,$22,$23,$80,$80
banim22:
	dc.b 0,0,$2f,49, -23,4,1,48, 0,0,$28,48, $80,$80
banim23:
	dc.b $40,-$68,1,0, $80,$24,$80
banim24:
	dc.b 0,-2,1,50, 0,0,$0f,50, $80,$25,$26,$27
	dc.b $28,$29,$2a,$2b,$2c,$2d,$2e,$2f,$80,$80
banim25:
	dc.b -20,-55,1,50, 0,1,4,50, 0,1,4,51, 0,1,4,52, 0,3,$30,53, $80,$80
banim26:
	dc.b -16,-53,1,50, 0,1,4,50, 0,1,4,51, 0,1,4,52, 0,2,$40,53, $80,$80
banim27:
	dc.b -11,-52,1,50, 0,1,4,50, 0,1,4,51, 0,1,4,52, 0,2,$40,53, $80,$80
banim28:
	dc.b -8,-60,1,50, 0,1,4,50, 0,1,4,51, 0,1,4,52, 0,2,$42,53, $80,$80
banim29:
	dc.b -3,-57,1,50, 0,1,4,50, 0,1,4,51, 0,1,4,52, 0,2,$42,53, $80,$80
banim2a:
	dc.b 0,-59,1,50, 0,1,4,50, 0,1,4,51, 0,1,4,52, 0,2,$42,53, $80,$80
banim2b:
	dc.b 3,-48,1,50, 0,1,4,50, 0,1,4,51, 0,1,4,52, 0,2,$40,53, $80,$80
banim2c:
	dc.b 7,-50,1,50, 0,1,4,50, 0,1,4,51, 0,1,4,52, 0,2,$40,53, $80,$80
banim2d:
	dc.b 9,-41,1,50, 0,1,4,50, 0,1,4,51, 0,1,4,52, 0,2,$40,53, $80,$80
banim2e:
	dc.b 14,-47,1,50, 0,1,4,50, 0,1,4,51, 0,1,4,52, 0,2,$40,53, $80,$80
banim2f:
	dc.b 19,-54,1,50, 0,1,4,50, 0,1,4,51, 0,1,4,52, 0,3,$30,53, $80,$80
banim30:
	dc.b -9,2,1,54, 0,0,$3f,54, 8,-1,1,54
	dc.b 0,0,$0f,54, $80,$31,$32,$80,$80
banim31:
	dc.b 0,0,$2f,55, -23,-4,1,54, 0,0,$28,54, $80,$80
banim32:
	dc.b $40,-$8,1,0, $80,$33,$80
banim33:
	dc.b 0,2,1,50, 0,0,$0f,50, $80,$34,$35,$36,$37,$38,$39,$3a,$3b
	dc.b $3c,$3d,$3e, $80
	;,$26,$27
	;dc.b $28,$29,$2a,$2b,$2c,$2d,$2e,$2f,$80,$80
banim34:
	dc.b -19,55,1,50, 0,-1,4,50, 0,-1,4,51, 0,-1,4,52, 0,-3,$30,53, $80,$80
banim35:
	dc.b -15,58,1,50, 0,-1,4,50, 0,-1,4,51, 0,-1,4,52, 0,-2,$3c,53, $80,$80
banim36:
	dc.b -11,61,1,50, 0,-1,4,50, 0,-1,4,51, 0,-1,4,52, 0,-3,$34,53, $80,$80
banim37:
	dc.b -8,53,1,50, 0,-1,4,50, 0,-1,4,51, 0,-1,4,52, 0,-2,$3c,53, $80,$80
banim38:
	dc.b -3,59,1,50, 0,-1,4,50, 0,-1,4,51, 0,-1,4,52, 0,-2,$3c,53, $80,$80
banim39:
	dc.b 0,62,1,50, 0,-1,4,50, 0,-1,4,51, 0,-1,4,52, 0,-2,$3c,53, $80,$80
banim3a:
	dc.b 2,57,1,50, 0,-1,4,50, 0,-1,4,51, 0,-1,4,52, 0,-2,$3c,53, $80,$80
banim3b:
	dc.b 7,61,1,50, 0,-1,4,50, 0,-1,4,51, 0,-1,4,52, 0,-2,$3c,53, $80,$80
banim3c:
	dc.b 10,54,1,50, 0,-1,4,50, 0,-1,4,51, 0,-1,4,52, 0,-2,$3c,53, $80,$80
banim3d:
	dc.b 14,57,1,50, 0,-1,4,50, 0,-1,4,51, 0,-1,4,52, 0,-2,$3c,53, $80,$80
banim3e:
	dc.b 18,55,1,50, 0,-1,4,50, 0,-1,4,51, 0,-1,4,52, 0,-3,$30,53, $80,$80
banim3f:
	dc.b -8,1,1,57, 0,0,$70,57, -1,0,$20,57, $80,$80

banim40:
	dc.b -8,-1,1,57, 0,0,$70,57, -1,0,$20,57, $80,$80
banim41:
	dc.b -12,1,1,57, 0,0,$40,57, -1,1,7,57, -1,8,1,57, -1,0,$20,57,$80,$80
banim42:
	dc.b -12,-1,1,57, 0,0,$40,57, -1,-1,7,57, -1,-8,1,57, -1,0,$20,57,$80,$80
banim43:
	dc.b -8,0,1,57, 0,1,21,56, 0,-1,16,57, 0,-1,16,56
	dc.b 0,1,16,56, 0,1,16,57, 0,-1,16,57, 0,-1,16,56
	dc.b 0,1,16,56, 0,1,16,57, 0,-1,16,57, 0,-1,16,56,$80,$80
banim44:
	dc.b -8,0,1,57, 0,1,16,56, 0,-1,16,57, 0,-1,16,56
	dc.b 0,1,16,56, 0,1,16,57, 0,-1,16,57, 0,-1,16,56
	dc.b 0,1,16,56, 0,1,16,57, 0,-1,16,57, 0,-1,16,56,$80,$80
banim45:
	dc.b -8,0,1,57, 0,1,11,56, 0,-1,16,57, 0,-1,16,56
	dc.b 0,1,16,56, 0,1,16,57, 0,-1,16,57, 0,-1,16,56
	dc.b 0,1,16,56, 0,1,16,57, 0,-1,16,57, 0,-1,16,56,$80,$80
banim46:
	dc.b -20,0,1,59, 1,0,28,59, 0,0,34,59, -1,0,28,59
	dc.b 0,0,80,59, $80,$80
banim47:
	dc.b -20,0,1,59, 1,0,28,59, 0,0,34,59, -1,0,26,59
	dc.b 0,0,80,59, $80,$80
banim48:
	dc.b -20,0,1,59, 1,0,28,59, 0,0,34,59, -1,0,32,59
	dc.b 0,0,70,59, $80,$80
banim49:
	dc.b 0,0,0,0, $80,49
banim4a:
banim4b:
banim4c:
banim4d:
banim4e:
banim4f:

banim50:
banim51:
banim52:
banim53:
banim54:
banim55:
banim56:
banim57:
banim58:
banim59:
banim5a:
banim5b:
banim5c:
banim5d:
banim5e:
banim5f:

	dc.b 0

banimadrtab:
	dc.l banim0,banim1,banim2,banim3,banim4,banim5,banim6,banim7
	dc.l banim8,banim9,banima,banimb,banimc,banimd,banime,banimf
	dc.l banim10,banim11,banim12,banim13,banim14,banim15,banim16,banim17
	dc.l banim18,banim19,banim1a,banim1b,banim1c,banim1d,banim1e,banim1f
	dc.l banim20,banim21,banim22,banim23,banim24,banim25,banim26,banim27
	dc.l banim28,banim29,banim2a,banim2b,banim2c,banim2d,banim2e,banim2f
	dc.l banim30,banim31,banim32,banim33,banim34,banim35,banim36,banim37
	dc.l banim38,banim39,banim3a,banim3b,banim3c,banim3d,banim3e,banim3f
	dc.l banim40,banim41,banim42,banim43,banim44,banim45,banim46,banim47
	dc.l banim48,banim49,banim4a,banim4b,banim4c,banim4d,banim4e,banim4f
	dc.l banim50,banim51,banim52,banim53,banim54,banim55,banim56,banim57
	dc.l banim58,banim59,banim5a,banim5b,banim5c,banim5d,banim5e,banim5f
banimchar:	
		; bits 0-2 = animspeed
		; bit3 = $08 = schuss
		; bit4 = $10 = explosion, no colldect.
		; bit5 = $20 = icon, colldect auf ply
		; bit6 = $40 = explos, no colldect, 1 bpl
		; bit7 = $80 = bckgnd n. verknuepfen

	dc.l 15*200+28+sa+sm,$0f048800
	dc.l 16*200+30+sa+sm,$0f058800
	dc.l 16*200+32+sa+sm,$0f068800
	dc.l 16*200+34+sa+sm,$0f078800
	dc.l 16*200+36+sa+sm,$0f098800
;5
	dc.l 16*200+38+sa+sm,$0f0a8800
	dc.l 22*200+30+sa+sm,$0f058800
	dc.l 23*200+32+sa+sm,$0f068800
	dc.l 25*200+34+sa+sm,$0f078800
	dc.l 27*200+36+sa+sm,$0f098800
;10
	dc.l 28*200+38+sa+sm,$0f0a8800
	dc.l 26*200+$5c850,$1f1f1000
	dc.l 26*200+$5c854,$1f1f1000
	dc.l 26*200+$5c858,$1f1f1000
	dc.l 26*200+$5c85c,$1f1f1000
;15
	dc.l 0*200+blockadr+24,$2f34a000
	dc.l 0*200+0+sa+sm,$1f1f5000
	dc.l 0*200+4+sa+sm,$1f1d5000
	dc.l 0*200+8+sa+sm,$1f1b5000
	dc.l 0*200+12+sa+sm,$1f195000
;20
	dc.l 0*200+0+sa+sm,$1f1f5000
	dc.l 0*200+0+sa+sm,$1f1f5000
	dc.l 0*200+32+sa+sm,$f0f1000
	dc.l 0*200+34+sa+sm,$f0f1000
	dc.l 0*200+36+sa+sm,$f0f1000
;25
	dc.l 0*200+38+sa+sm,$f0f1000
	dc.l 0*200+0+sa+sm,$1f1f1000
	dc.l 0*200+4+sa+sm,$1f1d1000
	dc.l 0*200+8+sa+sm,$1f1b1000
	dc.l 0*200+12+sa+sm,$1f191000
;30
	dc.l 0*200+16+sa+sm,$1f171000
	dc.l 0*200+20+sa+sm,$1f151000
	dc.l $20*200+sa+sm,$1f155000
	dc.l $1e*200+4+sa+sm,$1f1a5000
	dc.l $1c*200+8+sa+sm,$1f1f5000
;35
	dc.l $1a*200+12+sa+sm,$1f1f5000
	dc.l $18*200+16+sa+sm,$1f1f5000
	dc.l $16*200+20+sa+sm,$1f1d5000
	dc.l 0*200+24+sa+sm,$1f1a5000
	dc.l 0*200+28+sa+sm,$1f0e5000
;40
	dc.l 0*200+0+sa,$2f1f0000	;Muschel
	dc.l 0*200+6+sa,$2f1a0000
	dc.l 0*200+6+sa,$2f1a0100
	dc.l 0*200+18+sa,$2f1a0000
	dc.l $20*200+0+sa,$2f1f0000	
;45
	dc.l $20*200+6+sa,$2f1a0000
	dc.l $20*200+12+sa,$2f1a0000
	dc.l $20*200+18+sa,$2f1a8000
	dc.l 59*200+16+sa,$1f160100	; Krebsunten
	dc.l 59*200+12+sa,$1f160000
;50
	dc.l 50*200+28+sa,$0f080000	;Kleine Muschelunten
	dc.l 50*200+26+sa,$0f0a0000
	dc.l 50*200+24+sa,$0f0c0000
	dc.l 33*200+24+sa,$0f0e0100
	dc.l 59*200+4+sa,$1f160100	; Krebsoben
;55
	dc.l 59*200+0+sa,$1f160000
	dc.l 11*200+32+sa,$1f150000	; Fluegler
	dc.l 11*200+36+sa,$1f150000	
	dc.l 11*200+32+sa,$1f158000	; Fluegler
	dc.l 11*200+36+sa,$1f158000	


;25
	dc.l 82*200+sa,$6f3e8000
	dc.l 130*200+sa,$5f508000
	dc.l 130*200+sa+$c,$5f578000
	dc.l 130*200+sa+$18,$5f5f8000


	
	section game,CODE

mainstart2:

	move.l#irq2,$6c
	;move#%0111111111111111,$dff09a
	move#%0000000001100000,$dff09a
	move#%1100000000010000,$dff09a	; Copper-IRQ an
;	jmp initcoplist
	
;	move#%0000000000100000,$dff1dc	

	lea scr2muls,a0
	move#255,d0
	moveq#0,d1
setmulstab:
	move d1,(a0)+
	add#3*48,d1
	dbra d0,setmulstab



	lea bobcuttab,a0
	moveq#127,d0
	moveq#0,d1
setmulstab2:
	move d1,(a0)+
	add#3*40,d1
	dbra d0,setmulstab2

	lea bobanimtab,a1
	move.l#$17c/4,d0
setmovcnt3:
	clr.l(a1)+
	dbcs d0,setmovcnt3	;bobpostabelle loeschen
	lea $7e000,a0
 	lea copcolarea,a1
	moveq#31,d0
colwrite:
	move(a0)+,2(a1)
	addq#4,a1
	dbra d0,colwrite
	
	lea banimtabor-8,a0
	lea banimtab,a1
	lea wavecount,a2
	move screenpointer+2,d0
	asr#3,d0
animtabsrch:
	addq#8,a0
	cmp (a0),d0
	bcc.b animtabsrch
	move.l a0,animbuffer
animtabwrite:
	move.b 4(a0),(a2)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	cmpi#$ffff,(a0)
	bne.b animtabwrite
	move.l#$ffffffff,(a1)

	moveq#9,d0
	lea blockpointer,a0
	;lea blockpointer2,a2
	lea blockadr,a1
	;lea blockadr-blockshdw2,a3
wrtblockpointer1:
	moveq#9,d1
wrtblockpointer:
	move.l a1,(a0)+
	;move.l a3,(a2)+
	add#4,a1
	add#4,a3
	dbra d1,wrtblockpointer
	add#200*26-40,a1
	add#40*26-40,a3
	dbra d0,wrtblockpointer1
	
	lea landscpeadr,a0
 	lea landscapeadr,a1
	move.l#$fff,d0
lndscpwrite:
	move.l(a0)+,(a1)+

	dbra d0,lndscpwrite
	lea $2,a6
	move a6,copcolarea+2	


	lea copsprdbl,a0
	move#$2d,d3
	move#dispstop,d0
	sub d3,d0
	move#$03e,d7
	moveq#0,d5
kl1:
	move#5,d1
	move#$48-10,d2
	move#$33,d4

	bsr.w sprplxwait
	bsr.w sprplxwrt
	bsr.w sprplxwait
	bsr.w sprplxwrt

	bsr.w sprplxwrt
	bsr.w sprplxwait
	bsr.w sprplxwrt

	bsr.w sprplxwrt
	bsr.w sprplxwait
	bsr.w sprplxwrt

	bsr.w sprplxwrt
	bsr.w sprplxwait
	bsr.w sprplxwrt

	bsr.w sprplxwrt
	bsr.w sprplxwait
	bsr.w sprplxwrt


	move d3,d6
	addq#2,d6
	add#$10,d6
	andi#$1f,d6
	bne.b sprplxskip

	tst d5
	bne kl4 
	add#$10,d7
	sub.b#$1,d7
	bpl kl4
	sub#2,a6
	move#$ffff,d5

kl4:
	;add#1,d7
	move d7,d6
	move#$1b6,(a0)+
	move d6,(a0)+

	move#$1b4,(a0)+
	add#$10,d6

	move d6,(a0)+
	move#$1b2,(a0)+
	move d6,d5
	andi#$0f,d5
	
	cmpi#$0a,d5
	ble.b sprplxskp3

	move d6,d5
	andi#$ff0,d5
	or#$0a,d5
	move#$0c,d5
	move d5,d6
	move#$fff,d6
sprplxskp3:
	sub#$20,d6
	
	move d6,(a0)+
sprplxskip:
	addq#1,d3
	dbra d0,kl1
	moveq#60,d0
	lea copcolscor,a1
kl2:
	move.l(a1)+,(a0)+
	dbra d0,kl2

;jsr scren2


;	jsr mainprtscreen

	move#120,plycoll
;move.l#sprshdwadr,d0
;sub.l #sa,d0
;move.l d0,sprshdw
;move.l d0,$50000

initcoplist:
	move.l#0,objcount
	move#0,objcount+4
	move.l#$ffffffff,bobpostab+6
	move.l#$ffffffff,bobpostab+512+6
	move.l#coplist,$dff080
	move.l#coplist,$dff084
	move $dff088,$dff088
	move.b#0,copsprdat+11
;rastwait:
	;btst#1,$dff00d
	;bne.b rastwait
;jmp mainendgame

	;jmp editor
rastwait:			;***Hauptprogramm/Schleife***

	move screenrastcnt,d0
;	move d0,$dff180
;cmpi.b#22,d0
	beq.b rastwait

	;move screenrastcnt,screenrastcnt+2
	clr screenrastcnt

	add#1,screenrastcnt+4
	move screenrastcnt,$dff180
	add#1,screenrastcnt+2

;	add.b#1,copsprdat+11
;		bsr.w dobckscroll

;		bsr.w bobmanager

;		bsr.w plymanager	

;		bsr.w collmanager

;	jsr bcksprctrl


;	tst.b $bfe001
;	bmi rastwait
	;btst#1,$dff00d
	;beq.b rastwait


;	cmpi.b#$55,$bfec01
;	bne.w rastwait
	;cmpi#$279,editor
	;bne.b maintstend
		;move#0,$dff02e
		;jmp editor

maintstend:
	clr d7
	move.b $bfec01,d7
	not.b	d7
	ror.b#1,d7
;		move d7, $dff180
	cmpi.b#$4d,d7
	bcc.b rastwait



	;cmpi.b#$4f,$bfec01
	;bne.b rastwait
	jmp mainendgame

sprplxwrt:

	move#$160,(a0)+
	move.b d3,(a0)+
	move.b d2,(a0)+	
	addq#8,d2
	move#$168,(a0)+
	move.b d3,(a0)+
	move.b d2,(a0)+	
	addq#8,d2
	rts
sprplxwait:
	move.b d3,(a0)+
	move.b d4,(a0)+
	move#$fffe,(a0)+
	addq#8,d4
	rts
	move#$58,(a0)+
	move d3,(a0)+
	rts


irq2:
	move.l d0,-(a7)
	move.l $dff004,d0
	andi.l#$fff000ff,d0
	add.l#$0001302a,d0
	move.l d0,$dff02a
	move#$8040,$dff096
	move.l (a7)+,d0
loop:
	addq#1,screenrastcnt
	move screenrastcnt,$dff180
;	jmp loop
;add#1,$80000
	subq#2,screenrastcnt+4
	move$dff01e,$dff09c
	rte


bcksprctrl:
	move screenpointer+2,d0
	lea copsprdat+$46,a0
	lea copsprdat+$56,a1
	
	;not d0
	lsr#4,d0
	move d0,d1
	andi#15,d0
	muls#$690,d0
;add#5,d1
	btst#4,d1
	beq.b bckspr1
	exg a0,a1
bckspr1:
	add#$3000,d0
;	move d0,(a0)
	add#$348,d0
;	move d0,(a1)


	rts
bcksprcnt:
	dc.w 0
dobckscroll:
	lea$dff000,a6
	move#$fe,d7
	bsr bckm1

	lea copr2,a0
	lea copl2,a1

	add#230,d0
	move d0,d1
	cmpi#250,d0
	blt dobck2
	move d7,d1
dobck2:
	move.b d1,(a1)
	move screenrastcnt+4,d5
	asr#1,d5
	move d5,d6
	asl#2,d5
	andi#$f0,d5
	asl#4,d6
	asl#8,d6
	andi#$3000,d6
	or d6,d5
	move d5,26(a0)


	lea copr3,a0
	lea copl3,a1
	add#20,d0
	move d0,d1
	cmpi#250,d0
	blt dobck3
	addq#1,d7
	move d7,d1
dobck3:
	move.b d1,(a1)
	move screenrastcnt+4,d5
	asl#1,d5
	andi#$0f,d5
	asl#4,d5
	move d5,26(a0)


	lea copr4,a0
	lea copl4,a1
	add#20,d0
	move d0,d1
	cmpi#250,d0
	blt dobck4
	addq#1,d7
	move d7,d1
dobck4:
	move.b d1,(a1)
	move screenrastcnt+4,d5
	asl#2,d5
	andi#$0f,d5
	asl#4,d5
	move d5,26(a0)



	bsr screen1
	rts

bckm1:
	lea copr1,a0
	lea copl1,a1

	addq#1,bckl1
	move plypos+2,d0
	asr#4,d0
	sub#60,d0
	move d0,d1
	moveq#0,d2
	move bckl1,d3
	asr#4,d3
	add#$80,d3
	moveq#0,d4
	move d3,d4
	bclr#0,d4
dobckk1:
	cmpi.b#60,d0
	bge dobck1
	moveq#60,d2
	sub d1,d2
	move#29,d1

dobck1:
	muls#3*48,d2
	add.l d2,d3
	move d3,6(a0)
	add#48,d3
	move d3,14(a0)
	add#48,d3
	move d3,22(a0)


	move.b d1,(a1)

	move bckl1,d5
	asr#1,d5
	not d5
	andi#$0f,d5
	asl#4,d5
	move d5,26(a0)

	move bckl1,d5
	asr#2,d5
	andi#$07,d5
	muls#48*3*16,d5
	add.l#$1002a,d5
	add d4,d5
	move.l d5,a0


	move.l#$0046002e,$64(a6)		; actscreen 
	;move.l #$ffffffff,$44(a6)
	move.l#$09ff0000,d3
	moveq#0,d4
	not.l d4


	movem.l d3/d4,$40(a6)

	movem.l d0/a0,$50(a6)
	;move#%0000010000000001,$58(a6)



;move#$ffff,12(a0)
	rts
bckl1:
	dc.w 0


dobckend:



screen1:
	move screenrastcnt+4,d0
	andi#$0f,d0
;move d0,2(a0)
	rts








;	lea copsprdbl,a0

;	lea copcolply,a1
;	moveq#20,d0
;remcopwrt:
;	tst (a1)
;	beq skip
;	move.l (a1)+,(a0)+
;	dbra d0,remcopwrt
	
;skip:

;	lea copcolscor,a1

;moveq#20,d0
;remcopend:
;	move.l (a1)+,(a0)+
;	dbra d0,remcopend
	;move.l#$fffffffe,(a0)

rts


	lea landscapeadr-16,a0
	lea scr2base,a2
	lea screenpointer,a3
copscbltpt:
	lea $80,a4
	lea copbltpt,a5
	lea blockpointer,a6
	moveq#48,d6

	move (a3),d0
	add d0,2(a3)

	moveq#0,d2
	moveq#0,d1
	moveq#0,d3
	moveq#0,d4
	moveq#0,d5
;moveq#0,d6

	move 2(a3),d1


	asr#3,d1
	move d1,d0
	move d1,d2
	asr#1,d2
	asr#1,d1
	move d1,d3
	asr#2,d1
	asr#1,d3
	add d3,a0

	add#$80,d1	;scr2adr = aktuelle startadr-screen
	bclr#0,d1
	move d1,2(a2)
	move d1,6(a2)

	
	move.l 4(a2),d1
	addq#2,d1
	add d5,d1
	move d1,26(a5)
	add d6,d1
	move d1,30(a5)
	add d6,d1
	move d1,34(a5)
	add d6,d1
	;move d1,38(a5)
	add d6,d1
	;move d1,42(a5)
	swap d1
	move d1,2(a5)
	move d1,6(a5)
	move d1,10(a5)
	;move d1,14(a5)
	;move d1,18(a5)


	moveq#15,d6		; x-soft-scroll 
	sub d0,d6
	andi#$0f,d6
	;move d6,d7
	;asl#4,d6
	;or d6,d7
	move d6,copplayinit+10

	andi#$e,d2
	lea scr2add,a1
	move (a1,d2),d2
	
	move.l 4(a2),d1
	add#1,d1
	add#12*8,a0
;bchg#1,d1
	add d2,d1

	;bchg#0,scr2base+1
	;bchg#0,scr2base+5
	move.l scr2base,d2
	move.l scr2base+4,scr2base
	move.l d2,scr2base+4

	move.l#$24002c,d2
	move.l#$09f00000,d3
	moveq#0,d4
	not.l d4
	move#%0010000000000010,d5

	lea$dff000,a3
	moveq#0,d5
	move.b(a0),d5
	bmi.b screenrotate
	add d5,d5
	add d5,d5
	move.l(a6,d5),d0

	move#%0010000010000010,d5

	move.l d2,$64(a3)		; actscreen 
	move.l d3,$44(a3)
	movem.l d3/d4,$40(a3)
	movem.l d0/d1,$50(a3)
	move d5,$58(a3)

	move.l d1,d3
	bset#16,d1
	bset#17,d1
	movem.l d0/d1,$50(a3)
	move d5,$58(a3)
	rts

screenrotate:
	move.l d1,d6
	move.l d1,d7


	bclr#7,d5
	asl#2,d5
	move.l(a6,d5),d0
	add.l#25*40*5,d0
	movem.l d3/d4,$40(a3)
	move#-120-120+36,$dff064
	move#236,$dff066
	moveq#4,d4
screenblock:
	movem.l d0/d1,$dff050
	move#%0000011010000010,$58(a3)
	add#48,d1
	add#40,d0
	dbra d4,screenblock

	move#44,$dff064
	move#44,$dff066
	move.l d3,$40(a3)
	bset#16,d7
	bset#17,d7
	movem.l d6/d7,$50(a3)
	move#%0010000010000010,$58(a3)
	rts
scr2add:
	dc.w 44,$1860+44,$1860*2+44,$1860*3+44,$1860*4+42
	dc.w $1860*5+42,$1860*6+42,$1860*7+42
scr2base:
	dc.l$10080,$20080
screenpointer:
	dc.w 0,startpos*64,0,0	;1.word = scrollrichtung 2.word = y-scroll-cnt
screenrastcnt:
	dc.w 2,0,0

plymanager:
	tst plycoll+2
	bne.w plydocol
	
	move$dff00c,d7
	lea plypos,a6
	move.l (a6),8(a6)
	moveq#0,d5
	moveq#0,d6
	move d5,screenpointer
	
	add#8,screenpointer
	add#8,plypos

	move.l d5,plypos+4
	move plypos,d0
	sub screenpointer+2,d0

	btst#1,d7
	beq.b plygoright
	cmpi#320*8,d0
	bhi.b plygoleft
	add#3*8,4(a6)
	bra.b plygoleft
plygoright:
	btst#9,d7
	beq.b plygoleft
	cmpi#70*8,d0
	bls.b plygoleft
	sub#3*8,4(a6)
plygoleft:
	move d7,d6
	asl#1,d6
	eor d6,d7

	btst#1,d7
	beq.b plynodown
	tst plypos+6
	bne.b plygetblock
	cmpi#224*8,2(a6)
	bhi.b plynodown
	add#3*8,6(a6)

	bra.b plygetblock
plynodown:
	btst#9,d7
	beq.b plygetblock
	cmpi#49*8,2(a6)
	bls.b plygetblock
	sub#3*8,6(a6)



plygetblock:


shotmanager:
	lea plytab,a3
	moveq#0,d6
	move plycnt+4,d3
	add d3,d3
	add d3,d3
	;tst.b plyshot+1
	;bpl shotendctrl

	move.b plyshot,d0
	andi#$80,d0
	move.b $bfe001,d1
	andi#$80,d1
	cmp.b d0,d1
	beq.w shotendctrl
	

	btst#15,$bfe001
	bne.w shotendctrl


	tst.b plyshot+1
	bpl.b shot2
	move.b (a3,d3),plyshot+1
	bmi shot2
	move plypos,d5
	move plypos+2,d6
	sub#28*8,d5
	sub#38*8,d6
	moveq#0,d4
	moveq#0,d7
	jsr bobaniminit
	move.b#2,banhit(a4)
shot2:
	tst.b plyshot+2
	bpl.b shot3
	move.b 1(a3,d3),plyshot+2
	bmi shot3
	move plypos,d5
	move plypos+2,d6
	sub#28*8,d5
	sub#40*8,d6
	moveq#1,d4
	moveq#0,d7
	jsr bobaniminit
	move.b#2,banhit(a4)
	move plypos,d5
	move plypos+2,d6
	sub#28*8,d5
	sub#34*8,d6
	moveq#2,d4
	moveq#0,d7
	jsr bobaniminit
	move.b#2,banhit(a4)
shot3:
	tst.b plyshot+3
	bpl.b shot4
	move.b 2(a3,d3),plyshot+3
	bmi shot4
	move plypos,d5
	move plypos+2,d6
	sub#28*8,d5
	sub#84*8,d6
	moveq#3,d4
	moveq#0,d7
	jsr bobaniminit
	move.b#2,banhit(a4)
	move plypos,d5
	move plypos+2,d6
	sub#48*8,d5
	sub#34*8,d6
	moveq#4,d4
	moveq#0,d7
	jsr bobaniminit
	move.b#2,banhit(a4)


	;tst.b plyshot+3
	;bpl.b shot4
	;move plypos,d5
	;move plypos+2,d6
	;sub#28*8,d6
	;moveq#3,d4
	;moveq#0,d7
	;jsr bobaniminit
	;move.b#15,plyshot+3
shot4:
shotendctrl:
	tst.b plyshot+1
	bmi.b shot2j
	sub.b#1,plyshot+1
shot2j:
	tst.b plyshot+2
	bmi.b shot3j
	sub.b#1,plyshot+2
shot3j:
	tst.b plyshot+3
	bmi.b shot4j
	sub.b#1,plyshot+3
shot4j:



shotquit:
	move.b $bfe001,plyshot







plydocoplist:
	lea plypos,a6
	move 4(a6),d0
	add d0,(a6)
	move 6(a6),d0
	add d0,2(a6)

	tst plycoll
	beq.b plywrtcopl
	sub#1,plycoll
	btst#0,plycoll+1
	beq.b plywrtcopl
	move#0,d6
	move#0,d7
	bra.b plywrtcopl2
plywrtcopl:
	lea plypos,a1
	move(a1)+,d6
	sub screenpointer+2,d6
	move(a1)+,d7
	moveq#0,d5
	btst#3,d6
	beq.b plywrtcopl2
	bset#0,d5
plywrtcopl2:

	asr#4,d6
	asr#3,d7
	add#$20,d6
	;add#$04,d7

	lea copsprdat,a0

	move.b d7,10(a0)
	move.b d7,$10+10(a0)
	;move.b d7,$20+10(a0)
	;move.b d7,$30+10(a0)

	move.b d6,11(a0)
	move.b d6,$10+11(a0)
	addq#8,d6
	;move.b d6,$20+11(a0)
	;move.b d6,$30+11(a0)
	add.b#$10,d7
	;bcc plywrtcopl3
	;bset#1,d5
plywrtcopl3:
	move.b d7,14(a0)
	move.b d7,$10+14(a0)
	;move.b d7,$20+14(a0)
	;move.b d7,$30+14(a0)
	move.b d5,15(a0)
	move.b d5,$10+15(a0)
	;move.b d5,$20+15(a0)
	;move.b d5,$30+15(a0)

	tst plyweap
	bmi.b plyquit
	lea plyweap,a1
	move(a1),d2
	asr#2,d2
	andi#$0e,d2
	move 4(a1,d2),d3
	move 2(a1),d1
	asl#2,d1
	add d1,d3
	add#$8000,d3
	move d3,$20+6(a0)
	add#$358,d3
	move d3,$30+6(a0)




	sub#1,plyweap
plyquit:
;move plypos,bobanimtab+banxpos	
;move plypos+2,bobanimtab+banypos	
	moveq#0,d0
	moveq#0,d1
	moveq#0,d2
	moveq#0,d3
	moveq#0,d4
	moveq#0,d5
	moveq#0,d6
	moveq#0,d7

	rts
plydocol:
	cmpi#250*8,plypos+2
	bgt.b plystopcol

	add#1,plypos+6
	sub#1,plycoll+2
	btst#0,plycoll+3
	bne.w plydocoplist
;move#$fff,$dff180
	moveq#2,d7
	move plypos,d5
	sub#350,d5
	move plypos+2,d6
	sub#32*8,d6
	moveq#7,d4
	bsr.w bobaniminit
	bra.w plydocoplist
plystopcol:
	move screenpointer+2,d0
	add#$270,d0
	move d0,plypos
	move#130*8,plypos+2
	move.l#$780000,plycoll
	bra.w plydocoplist


plypos:
	dc.w startpos*64+$1e8,$378,0,4,0,0,0
plycnt:
	dc.w 0,0,0
plyweap:
	dc.w 0,0,8*10,8*20,8*40,8*80,8*40,8*20,8*10


plyshot:
	dc.w 0,0,0,0
plytab:
	dc.b $10,$ff,$ff,$ff
	dc.b $0c,$ff,$ff,$ff
	dc.b $0a,$ff,$ff,$ff
	dc.b $07,$20,$ff,$ff
	dc.b $06,$1c,$ff,$ff
	dc.b $05,$18,$ff,$ff
	dc.b $04,$14,$ff,$ff
	dc.b $03,$10,$20,$ff
	dc.b $02,$08,$18,$ff
	dc.b $02,$04,$14,$ff
	
plycoll:
	dc.w 0,0
collmanager:
	move#%0000000001111111,$dff098
	move$dff00e,d0
	andi#$2,d0
	beq.b collquit
	tst plycoll
	bne.b collquit
	move.l#-1,plycoll
	move#$fff,$dff180
	move screenpointer+4,d0
	sub#4,d0
	move d0,plypos+4
	move#0,plypos+6
;move#$fff,$dff180
collquit:
	rts


bobmanager:
	move#$fff,$dff180


	lea bobpostab,a3
	lea 512(a3),a4
	lea$dff000,a6
	move.l#$9f00000,d2

				; bobbckgnd wiederherstellen
	moveq#3,d4
	swap d4
bobrestore:
	move.l (a4)+,d5
	bmi.b bobwrtplane
	btst#0,d5
	bne.b bobrestore2
	move d5,d4
	moveq#24,d3
	sub (a4),d3
	andi#%11111,d3
	add d3,d3
	move d3,$64(a6)
	move d3,$66(a6)
	movem.l d4/d5,$50(a6)
	move (a4)+,$58(a6)
	bra.b bobrestore
bobrestore2:
	bclr#0,d5
	move d5,d4
	moveq#24,d3
	sub (a4),d3
	andi#%11111,d3
	add d3,d3
	add#192,d3
	move d3,$64(a6)
	move d3,$66(a6)
	movem.l d4/d5,$50(a6)
	move (a4)+,$58(a6)
	bra.b bobrestore
bobwrtplane:


		
	moveq#0,d1		;bobpostab verschieben
	move.l d1,$64(a6)
	move.l a3,$50(a6)
	move.l #bobpostab+512,$54(a6)
	move.l#%10000000,d1
	move d1,$58(a6)
	move objcount,objcount+2


bobctrl:



bobendctrl:
		;bsr shotmanager
		bsr.w enemanager


ll:
	move objcount,d3
	beq.W boblit

;move#$fff,$dff180

	subq#1,d3
	lea 0,a0
	lea bobanimtab-2,a2
	move.l scr2base+4,a5
	moveq#0,d0
bobanimloop:
	addq#2,a2
	tst(a2)
	beq.b bobanimloop

	move (a2),d0
	move.l d0,a0
bobanimflight:
	move.b(a0),d7
	move.b 1(a0),d6
bobmovelikelist:
	moveq#0,d5
	add.b d7,banaccl(a2)
	move.b banaccl(a2),d5
	ext.w d5
	add d5,banxpos(a2)
	moveq#0,d5
	add.b d6,banaccl+1(a2)
	move.b banaccl+1(a2),d5
	ext.w d5
	add d5,banypos(a2)

bobgetmorebobs:
	;btst#0,3(a0,d0)
	;beq bobanimposit

	;bra bobanimposit

bobanimposit:
	sub.b#1,bancnt(a2)
	bne.w bobanimquit

	cmpi.b#$80,4(a0)	;Naechste Anim-sequenz starten
	beq.b bobanimendseq
	add#4,(a2)
	moveq#0,d0
	move(a2),d0
	move.l d0,a0
	move.b 2(a0),bancnt(a2)
	jmp bobanimquit
bobanimendseq:
	cmpi.b#$80,5(a0)
	beq.b bobanimclrbob

	moveq#0,d4
	move.b 5(a0),d4
	jsr bobaniminitold

bobmorebobs:
	cmpi.b#$80,6(a0)
	beq.b bobanimquit

	moveq#0,d4
	move.b 6(a0),d4
	moveq#1,d7

	move banxpos(a2),d5
	move banypos(a2),d6
	jsr bobaniminit
	move banhit(a2),banhit(a4)
	move.b banwav+1(a2),d7
	lea wavecount,a5
	add.b#1,(a5,d7)
	move.b d7,banwav+1(a4)
	addq#1,a0 
;add#1,(a2)
	bra.b bobmorebobs



	;bra bobanimquit

bobanimclrbob:
	
	move#0,(a2)
	move#0,banxpos(a2)
	move#0,banypos(a2)
	move#0,(a2)

	sub#1,objcount
	tst.b bancnt+1(a2)
	beq.b bobanimquit
	subq#1,objcount+4
bobanimquit:
	dbra d3,bobanimloop

	


boblit:
	move objcount,d3
	beq.W particlectrl
	subq#1,d3

	lea bobanimtab-2,a2
	move.l scr2base+4,a5

	move.l#$ffff0000,$44(a6)


	move screenpointer+2,d2
	asr#3,d2

boblitloop:
	addq#2,a2
	tst(a2)
	beq.b boblitloop

	lea banimchar,a4
	moveq#0,d0
	move (a2),d0
	move.l d0,a0
	moveq#0,d4
	move.b 3(a0),d4
	asl#3,d4
	add.l d4,a4

	moveq#0,d4
	move.b 4(a4),d4
	add#15,d4
	asr#4,d4
	addq#1,d4

	move.l (a4),a0
	move.b 6(a4),d0
;add a2,d0
	andi#%111,d0
	lea bobanshptab,a1
	move d4,d6
	subq#2,d6
	move d6,$76000
	asl#6,d6
	add d6,a1
	asl#3,d0
	add d0,a1

;add d0,d0
	move screenrastcnt+4,d6

;;add a2,d6
	asr#3,d6

	andi.l#7,d6

	move.b (a1,d6),d6
	add d6,a0

;add d6,a0

	
	move banxpos(a2),d6
	asr#3,d6
;move screenpointer,d0

	move d2,d0
;asr#2,d0
	andi#$fff0,d0

	sub d0,d6
	bmi.w bobfindloop
	cmpi#370,d6
	bcc.w bobfindloop

	moveq#0,d1
	move.b 5(a4),d1

	moveq#0,d5
	move banypos(a2),d5
	asr#3,d5
	sub d1,d5
				; d1 = bobhoee
				; d5 = bobypos

	tst d5
	bpl.b bobcutdwn

	lea bobcuttab,a1
	moveq#0,d0
	not d5
	sub d5,d1
	ble.w bobfindloop
	add d5,d5
	add(a1,d5),a0
	moveq#0,d5
	bra.b bobwascut

bobcutdwn:
	move d5,d7
	add d1,d7
	cmpi#dispstop-40,d7
	bls.b bobwascut
	sub#dispstop-40,d7
	sub d7,d1
	bmi.w bobfindloop
	addq#1,d1

bobwascut:
	move d6,d7
	andi#$f,d7
	ror#4,d7
	move d7,$42(a6)
	lea scr2muls,a1
	add d5,d5
	move(a1,d5),d5
	asr#3,d6
	add.l a5,d5
	add d6,d5

	btst#3,6(a4)
	beq.w bobskipcoll


	bclr#0,d5
	move.l d5,a1


	tst.b 288(a1)
	bne.b col
	tst.b 289(a1)
	beq.w bobskipcoll

col:
;move#$fff,$dff180

	movem.l d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6,-(sp)
;col:

		lea banimchar,a1
		lea bobcuttab,a5
		moveq#0,d6
		moveq#0,d4
		moveq#0,d3
		moveq#0,d2
bobcoldop1:
		move banxpos(a2),d0
		move banypos(a2),d1
		subq#8,d1
		subq#8,d1
		;subq#4,d1
		add#12*8,d0

		lea bobanimtab-22,a3
		move objcount+4,d7
		beq.w bobnocol
		subq#1,d7

bobcoldop2:
		addq#2,a3
		tst(a3)
		beq.b bobcoldop2
		move d0,d2
		move d1,d3
		sub banxpos(a3),d2	; bobcol xposdetect
	moveq#0,d5
		move (a3),d5
	move.l d5,a0
	moveq#0,d4
		move.b 3(a0),d4
		asl#3,d4
		moveq#0,d5
		move.b 4(a1,d4),d5
		add#20,d5
		asl#3,d5
	add#18,d2
		cmpi d5,d2
		bcc.w bobcol2

		sub banypos(a3),d3	; bobcol yposdetect
		moveq#0,d5
		move.b 5(a1,d4),d5
		;add#4,d3
		asl#3,d5
		add d3,d5
		sub#18,d3
		cmpi d3,d5
		bcc.w bobcol2

		btst#4,6(a1,d4)
		bne.w bobcol2

		move.b banhit(a2),d0
		subq#1,d0
		sub.b d0,banhit(a3)
		bpl.w bobcolspr

			btst#5,6(a1,d4)
			bne.b bobcoldsticn

			lea wavecount,a1
			moveq#0,d4
			move.b banwav+1(a3),d4
			sub.b#1,(a1,d4)
			bne.b bobcolseticn
					; Komplette Wave abgeballert
					; => Icon!

			moveq#8,d4
			bsr.w bobaniminitold
			moveq#6,d4
			move.l a3,a2
			bsr.w bobaniminitold
			move.b#$4,banhit(a2)
			bra.w bobcolbckgnd
bobcolseticn:				; Explosion Gegner
			move#0,(a2)
			subq#1,objcount
			moveq#8,d4
			move.l a3,a2
			bsr.w bobaniminitold
			bra.w bobcolbckgnd
bobcoldsticn:				; Icon zerstoert
	move#$fff,$dff180
	add#1,plycnt+4
			move#0,(a2)
			move#0,(a3)
			subq#2,objcount
			subq#1,objcount+4
			move banxpos(a2),d7
			sub screenpointer+2,d7
			asr#4,d7
			add#$3c,d7
			move.b d7,copsprdat+$20+11
			addq#8,d7
			move.b d7,copsprdat+$30+11
			move banypos(a2),d7
			sub screenpointer+4,d7
			asr#3,d7
			add#$3c,d7
			move d7,plyweap+2
			move#28,plyweap
			bra.b bobcolbckgnd
bobcol2:
		dbra d7,bobcoldop2
bobnocol:
	moveq#9,d4
	bsr.w bobaniminitold
	bra.b bobcolbckgnd
bobcolspr:
	move#0,(a2)		; Sprite noch nicht zerstoert
	subq#1,objcount
	moveq#2,d7
	move banxpos(a2),d5
	sub#16,d5
	move banypos(a2),d6
	add#14*8,d6
	moveq#7,d4
	bsr.w bobaniminit
	bra.w bobcolbckgnd
bobcolbckgnd:

	movem.l (sp)+,d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6




	bra.w bobfindloop

bobskipcoll:
	btst#6,6(a4)
	beq.b bobfullplane






;bobfullbpl:
	;tst.b 6(a4)
	;bpl bobgetbck
	or#%0000111111001010,d7
	move d7,$40(a6)
	add#4*48,d5
	move.l d5,a1
	bset#0,d5
	move.l d5,(a3)+
	add.l sprshdw,a0
	move.l a0,d6
	movem.l d5/d6/a0/a1,$48(a6)
	moveq#24,d6
	sub.b d4,d6
	andi#%11111,d6
	;move d6,d5
	;add#184,d6
	add d6,d6
	move d6,d5
	add#192,d6
	move d6,$60(a6)
	move d6,$66(a6)
	subq#8,d5
	add#160,d5
	move d5,$62(a6)
	move d5,$64(a6)
	asl#6,d1
	or d1,d4
	move d4,(a3)+
	move d4,$58(a6)
	bra.w bobfindloop



bobfullplane:
	bclr#0,d5
	;tst.b 231-46(a1)
	;bne bobgetbck
	tst.b 6(a4)
	bpl.b bobgetbck

	btst#0,banhit(a2)
	beq.b bobwasnthit1
	add.l sprshdw,a0
	sub.b#1,banhit(a2)
bobwasnthit1:
	or#%0000100111110000,d7
	move d7,$40(a6)
	move.l d5,$54(a6)
	move.l d5,(a3)+
	move.l a0,$50(a6)
	bra.b bobsetoffset
bobgetbck:
	btst#0,banhit(a2)
	beq.b bobwasnthit
;bobwashit:
	or#%0000111111111010,d7
	sub.b#1,banhit(a2)
	dc.w $43f9	
bobwasnthit:
	or#%0000111111001010,d7
	move d7,$40(a6)
	move.l d5,a1
	move.l d5,(a3)+
	move.l a0,d6
	add.l sprshdw,a0
	movem.l d5/d6/a0/a1,$48(a6)

bobsetoffset:
	moveq#24,d6
	sub.b d4,d6
	andi#%11111,d6
	add d6,d6
	move d6,$60(a6)
	move d6,$66(a6)
	subq#8,d6
	move d6,$62(a6)
	move d6,$64(a6)

	move d1,d6
	add d6,d6
	;add d6,d6
	add d1,d6
	asl#6,d6
	or d6,d4
	move d4,(a3)+
	move d4,$58(a6)

bobfindloop:
	dbra d3,boblitloop

particlectrl:
	move#$ffff,(a3)+




bobquit:
	move#$0,$dff180
	rts

objcount:
	dc.w 0,0,0
sprshdw:
	dc.l 0
bobanshptab:
	dc.b 0,0,0,0,0,0,0,0
	dc.b 0,2,4,6,8,6,4,2
	dc.b 0,2,0,2,0,2,0,2
	dc.b 0,2,0,2,0,2,0,2
	dc.b 0,2,0,2,0,2,0,2
	dc.b 0,2,0,2,0,2,0,2
	dc.b 0,2,0,2,0,2,0,2
	dc.b 0,2,0,2,0,2,0,2
	
	dc.b 0,0,0,0,0,0,0,0
	dc.b 0,4,0,4,0,4,0,4
	dc.b 0,4,0,4,0,4,0,4
	dc.b 0,4,0,4,0,4,0,4
	dc.b 0,4,0,4,0,4,0,4
	dc.b 0,4,0,4,0,4,0,4
	dc.b 0,4,0,4,0,4,0,4
	dc.b 0,4,0,4,0,4,0,4

	dc.b 0,0,0,0,0,0,0,0
	dc.b 0,0,6,6,0,0,6,6
	dc.b 0,6,0,6,0,6,0,6
	dc.b 0,6,0,6,0,6,0,6
	dc.b 0,6,0,6,0,6,0,6
	dc.b 0,6,0,6,0,6,0,6
	dc.b 0,6,0,6,0,6,0,6
	dc.b 0,6,0,6,0,6,0,6

	Section game,CODE	
enemanager:
	move.l animbuffer,a0
enemgetseq:
	move screenpointer+2,d0
	move d0,d5
	asr#3,d0
	cmpi (a0),d0
	bcs.w enemquit
	sub.b#1,6(a0)
	bcc.b enemnxtseq
	move.b 5(a0),6(a0)

	sub.b #1,4(a0)
	bmi.b enemendseq
	moveq#0,d6
	move.b 2(a0),d6
	asl#3,d6
	tst.b 7(a0)
	bpl.b enemstrtrgt
	move(a0),d5
	asl#3,d5
enemstrtrgt:
	add#$160*8,d5
	moveq#0,d4
	move.b 3(a0),d4
	moveq#1,d7
	jsr bobaniminit
	lea enemhitab,a1
	moveq#0,d4
	move.b 7(a0),d4
	move d4,d6
	andi#7,d4
	andi#%11111000,d6
	lsr#1,d6
	add.b d6,2(a0)
	move.b (a1,d4),banhit(a4)

	andi.b#%11111000,d6
	add.b d6,2(a0)
	
	move.l a0,d6
	lea banimtab,a6
	sub.l a6,d6
	lsr#3,d6
	move.b d6,banwav+1(a4)

	bra.b enemnxtseq
enemendseq:
	add#8,animbuffer+2
enemnxtseq:
	add#8,a0
	bra.w enemgetseq
enemhitab:
	dc.b 0,2,4,8,16,32,64,$80



enemquit:
;lea 0,a1
	rts
animbuffer:
	blk.l 16,0
bobaniminit:		;AnimList-Addresse in d4
			;x/y-koordinaten in d5/d6
			; d7 = 1 = Gegner/kein Schuss
	lea bobanimtab+60,a4
	
	tst d7
	beq.b bobanimsrchlist

	sub#40,a4
	add#1,objcount+4
	cmpi#2,d7
	bne.b bobanimsrchlist
	sub#20,a4
bobanimsrchlist:
	tst(a4)+
	bne.b bobanimsrchlist

	subq#2,a4
	lea banimadrtab,a1
	add d4,d4
	add d4,d4
	move.l (a1,d4),a1
	move a1,(a4)

	move d5,banxpos(a4)
	move d6,banypos(a4)	;Koordinaten schreiben
	move.b 2(a1),bancnt(a4);Counter initialisieren

	move.b d7,bancnt+1(a4)
	move#0,banaccl(a4)
	addq#1,objcount
	rts
bobaniminitold:
	lea banimadrtab,a4	;d4 = animlistnr.
	add d4,d4		;a2 = bobanimtabadr
	add d4,d4
	move.l(a4,d4),a1
	move a1,(a2)
	move.b 2(a1),bancnt(a2);Counter initialisieren
	move#0,banaccl(a2)
	rts
mainwaitblit:
	bsr.w mainwaitblit2
mainwaitblit2:
	btst#6,$dff002
	bne.b mainwaitblit
	rts

mainprtscreen:
	lea landscapeadr-16,a0
	move screenpointer+2,d0
	asr#5,d0
	andi.l#$fff0,d0	
	add d0,a0

	move.l#$ffffffff,$dff044
	move#0,$dff042
	;move#0,$dff000
	move#%0000100111110000,$dff040

	moveq#2,d1
	move#%0010000010000010,d2

	lea$10080,a2
	move screenpointer+2,d5
	asr#6,d5
	andi.l#$fffc,d5
	add d5,a2
	lea blockpointer,a6
	moveq#10,d7
mainitprtscr:
	lea(a2),a4
	moveq#0,d5
	bsr.b mainitbltblock
	bsr.b mainitbltblock
	bsr.b mainitbltblock
	bsr.b mainitbltblock
	bsr.b mainitbltblock
	bsr.b mainitbltblock
	bsr.b mainitbltblock
	bsr.b mainitbltblock

	addq#4,a2
	dbra d7,mainitprtscr
	rts
mainitbltblock:
	bsr.w mainwaitblit
	lea(a4),a3
	moveq#0,d5
	move.b(a0),d5
	bmi.b maininitbltblock2
	asl#2,d5
	move.l(a6,d5),$dff050
	move.l a3,$dff054
	move#36,$dff064
	move#44,$dff066
	move d2,$dff058
	bra.b maininitbltblock3
maininitbltblock2:
	bclr#7,d5
	asl#2,d5
	move.l(a6,d5),d4
	add.l#25*40*5,d4	
	move.l a3,a5
	moveq#4,d3
maininitbltblock4:
	move.l d4,$dff050
	move.l a5,$dff054
	move#-120-120+36,$dff064
	move#236,$dff066
	move #%0000011010000010,$dff058
	add#48,a5
	add#40,d4
	dbra d3,maininitbltblock4


maininitbltblock3:
	bsr.w mainwaitblit
	move#44,$dff064
	move#44,$dff066
	move.l a3,a5
	add.l#$10000,a5
	movem.l a3/a5,$dff050
	move d2,$dff058

	bsr.w mainwaitblit
	add.l#$10000,a5
	movem.l a3/a5,$dff050
	move d2,$dff058
	add#26*240,a4
	addq#1,a0
	rts
	org $16d000
	load $16d000

coplist:
	dc.w $8e,$3280,$90,$11b8,$92,$30,$94,$c8,$0106,$c40,$1fc,$000f
	dc.w $1c01,-1

copsprdat:
	
	dc.w $120,6,$122,$4000,$140,$4f50,$142,$9000
	;dc.w $124,3,$126,$1114,$148,$ff58,$14a,$f000
	;dc.w $128,3,$12a,$0000,$150,$2f60,$152,$ff00
	;dc.w $12c,4,$12e,$2c00,$158,$ff68,$15a,$ff00
	;dc.w $130,3,$132,0,$160,$2f70,$162,$ff00
	;dc.w $134,4,$136,0,$168,$ff78,$16a,$ff02
	;dc.w $138,6,$13a,$4000,$170,$3050,$172,$f000
	;dc.w $13c,4,$13e,0,$178,0,$17a,0
copbltpt:
	dc.w $e0,1,$e8,1,$f0,1,$e4,1,$ec,1,$f4,6
	dc.w $e2,0,$ea,0,$f2,0,$e6,0,$ee,0,$f6,0
	dc.w $92,$30,$94,$cc,$10a,144-42,$108,144-42,$104,$52
copcolarea:
	dc.w$182,0,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
	dc.w$190,0,$192,0,$194,0,$196,0,$198,0,$19a,0,$19c,0,$19e,0
	dc.w$1a0,0,$1a2,0,$1a4,0,$1a6,0,$1a8,0,$1aa,0,$1ac,0,$1ae,0
	dc.w$1b0,0,$1b2,0,$1b4,0,$1b6,0,$1b8,0,$1ba,0,$1bc,0,$1be,0
copplayinit:
	dc.w $2c01,$fffe,$100,$2400
	dc.w $1fe,0,$1fe,0,$1fe,0
	dc.w $80,(copsprdbl>>16)&$ffff,$82,copsprdbl&$ffff,$88,0

copendlist:
	;dc.w $104,%100100
	;dc.w $ffe1,-1,$ffe1,-2
	;dc.w $00e1,-1,$00e1,-2
	;dc.w $0301,-2,$100,0
	;dc.w $1001,-2
	;dc.w $96,$40
	;dc.w $9c,%1000000000010000
	dc.w $80,(coplist>>16)&$ffff,$82,coplist&$ffff,$88,0
	dc.l -2



copsprdbl:
copl1:
	dc.w $df,$fffe,$80,(copr1>>16)&$ffff,$82,copr1&$ffff,$88,0
copl2:
	dc.w $df,$fffe,$80,(copr2>>16)&$ffff,$82,copr2&$ffff,$88,0
copl3:
	dc.w $df,$fffe,$80,(copr3>>16)&$ffff,$82,copr3&$ffff,$88,0
copl4:
	dc.w $df,$fffe,$80,(copr4>>16)&$ffff,$82,copr4&$ffff,$88,0
copl5:
	dc.w $80,(copendlist>>16)&$ffff,$82,copendlist&$ffff,$88,0

copr1:
	dc.w $e4,1,$e6,0,$ec,1,$ee,0,$f4,1,$f6,0,$102,$f00
	dc.w $80,(copl2>>16)&$ffff,$82,copl2&$ffff,$88,0
copr2:
	dc.w $e4,6,$e6,$0,$ec,2,$ee,$4020,$f4,2,$f6,0,$102,$c00,$192,$48f
	dc.w $80,(copl3>>16)&$ffff,$82,copl3&$ffff,$88,0
copr3:
	dc.w $e4,6,$e6,$0,$ec,2,$ee,0,$f4,2,$f6,0,$102,$c00,$192,$14e
;dc.w $f001,-1,$180,$fff
	dc.w $80,(copl4>>16)&$ffff,$82,copl4&$ffff,$88,0
copr4:
	dc.w $e4,6,$e6,$0,$ec,2,$ee,0,$f4,2,$f6,0,$102,$c00,$192,$008
	dc.w $80,(copl5>>16)&$ffff,$82,copl5&$ffff,$88,0



;cply2:
;dc.l $a001fffe,$1809999
;dc.w $800003,$82,cmply1,$88,0

;df=cmply1
copcolscor:
;copdispscore:
;copcolscor:
;dc.w $100,$3000
;dc.w $182,$411
;dc.w $184,$211
;dc.w $186,$131
;dc.w $188,$311
;dc.w $18a,$201
;dc.w $18c,$131
;dc.w $18e,$333
	;dc.w$1a0,0,$1a2,0,$1a4,0,$1a6,0,$1a8,0,$1aa,0,$1ac,0,$1ae,0
	;dc.w$1b0,0,$1b2,0,$1b4,0,$1b6,0,$1b8,0,$1ba,0,$1bc,0,$1be,0

	;dc.w $120,4,$122,$8010,$140,$f750,$142,$ff00
;	dc.w $124,4,$126,$8010,$148,$f758,$14a,$ff00
;	dc.w $128,4,$12a,$8010,$150,$f760,$152,$ff00
;	dc.w $12c,4,$12e,$8010,$158,$f768,$15a,$ff00
;	dc.w $130,4,$132,$8010,$160,$f770,$162,$ff00
;	dc.w $134,4,$136,$8010,$168,$f778,$16a,$ff00

	dc.w $104,%100100
	dc.w $ffe1,-2
	dc.w $0301,-2,$100,0
	dc.w $1001,-2
	dc.w $96,$40
	dc.w $9c,%1000000000010000
	dc.w $ffff,$fffe

getkey:
	move.b$bfec01,$73000
	move.b$bfec01,$dff181
	btst#7,$bfe001
	bne.b getkey
illegal


	dcb.w 48*3,%1000000000000001
	dcb.w 48*3,%0100000000000010
	dcb.w 48*3,%0010000000000100
	dcb.w 48*3,%0001000000001000
	dcb.w 48*3,%0000110000110000
	dcb.w 48*3,%0000001111000000
	dcb.w 48*3,%0010000000001000
	dcb.w 48*3,%0100000000100000
	dcb.w 48*3,%0000010000010000
	dcb.w 48*3,%0001000000100010




	Section editor, CODE
;end
	andi#$ff80,plypos
	andi#$ffc0,screenpointer+2

	lea edcoplst,a0
 	lea edcoplist,a1
	;lea$20000,a2
	;lea edsprdat,a3
	move.l#230,d0
edcopwrite:
	;move.l(a3)+,(a2)+
	move.l(a0)+,(a1)+
	dbra d0,edcopwrite
	move.l#edcoplist,$dff080
	move#0,$dff088

	asr screenpointer+2
	asr screenpointer+2
	asr#1,plypos
	asr#1,plypos+2
	lea $7e000,a0
 	lea edcopcolarea,a2
	moveq#31,d0
	move(a0),edcopcoldwn+10
edcolwrite:
	move(a0)+,2(a2)
	;move(a0)+,6(a2)
	;move#$888,66(a2)
	;move#$fff,70(a2)
	addq#4,a2
	dbra d0,edcolwrite

	move.l#edirqvector,$6c
	move#%0000000001000000,$dff09a
	move#%1100000000100000,$dff09a
	;bsr edprtblocks


editmain:
	;cmpi#8,screenrastcnt
	;bcs editmain
	;move screenrastcnt,screenrastcnt+2
	;clr screenrastcnt
	;btst#0,$dff005
	;beq editmain


	cmpi.b#$65,$bfec01
	beq.b edslctblock
eddrawmap:

		lea edpos1,a6
		jsr edsetcurs
		jsr edgetkeys
		jsr eddrwblock
		jsr editprtscreen
		bra.b edcontrun
edslctblock:
		lea edpos2,a6
		jsr edsetcurs
		jsr edslctcurs
		jsr edprtscreen
edcontrun:
	cmpi.b#$4f,$bfec01
	bne.b edtstgogame
	move.l edoldcurs,a0
	move.b edoldcurs+4,(a0)
	jmp  mainendgame
edtstgogame:
	cmpi.b#$53,$bfec01
	bne.b editmain

	asl screenpointer+2
	asl screenpointer+2
	asl#1,plypos
	asl#1,plypos+2
	move.l edoldcurs,a0
	move.b edoldcurs+4,(a0)
	jmp mainstart2

edgetkeys:
	move.b$bfec01,d0
	cmpi#$61,d0
	bne.b edscrollft
	sub#32,screenpointer+2
edscrollft:
	cmpi#$63,d0
	bne.b edscrolrgt
	add#32,screenpointer+2
edscrolrgt:
	cmpi#$5f,d0
	bne.b eddefcopya
	move.l edoldcurs,edcopybuf
	move.l edoldcurs,edcopybuf+8

eddefcopya:
	cmpi#$5d,d0
	bne.b eddefcopyb
	move.l edoldcurs,d2
	sub.l edcopybuf+8,d2
	move d2,d3
	asr#3,d2
	move d2,edcopybuf+4
	andi#7,d3
	move d3,edcopybuf+6

eddefcopyb:
	cmpi#$5b,d0
	bne.b eddefcopyc
	move.l edcopybuf,a0
	move.l edoldcurs,a2
	move.b (a0),edoldcurs+4
	move edcopybuf+4,d0
eddocopya:
	move.l a0,a1
	move.l a2,a3
	move edcopybuf+6,d1
eddocopyb:
	move.b (a1)+,(a3)+
	dbra d1,eddocopyb
	add#8,a0
	add#8,a2
	dbra d0,eddocopya

eddefcopyc:
	cmpi#$59,d0
	bne.b eddefcopyd
	move.l edcopybuf,a0
	move edcopybuf+6,d0
	addq#1,d0
	add d0,a0
	move.l edoldcurs,a2
	move.b -1(a0),edoldcurs+4
	bset#7,edoldcurs+4
	move edcopybuf+4,d0
eddocopyc:
	move.l a0,a1
	move.l a2,a3
	move edcopybuf+6,d1
eddocopyd:
	move.b -(a1),d2
	bchg#7,d2
	move.b d2,(a3)+
	dbra d1,eddocopyd
	add#8,a0
	add#8,a2
	dbra d0,eddocopyc

eddefcopyd:


	rts
edcopybuf:
	dc.l 0,0,0

eddrwblock:
	move.l edoldcurs,a0
	move.b edoldcurs+4,(a0)

	lea landscpeadr,a0
	move screenpointer+2,d0
	asr#3,d0
	andi#$fff8,d0	
	add d0,a0
	move (a6),d5
	move 2(a6),d6
	asr#5,d5
	asr#5,d6
	andi#$f,d5
	;subq#1,d6
	andi#$7,d6
	asl#3,d5
	add d5,a0
	add d6,a0
	move.l a0,edoldcurs
	move.b (a0),d0
	move.b edoldcurs+5,(a0)
	btst#6,$bfe001
	bne.b edrgtmouse
	bclr#7,edoldcurs+5
	move.b edoldcurs+5,d0	
	bra.b edquitdrw
edrgtmouse:
	btst#2,$dff016
	bne.b edquitdrw
	bset#7,edoldcurs+5
	move.b edoldcurs+5,d0
edquitdrw:
	move.b d0,edoldcurs+4
	rts
edoldcurs:
	dc.w 0,0,0
mousepos:
	dc.w 0	
edpos1:
	dc.w 0,0
edpos2:
	dc.w 0,0
edslctcurs:
	move (a6),d5
	move 2(a6),d6
	asr#5,d5
	asr#4,d6
	andi#$f,d5
	;subq#1,d6
	andi#$f,d6
	muls#10,d6
	add d5,d6
	move.b d6,edoldcurs+5
	rts

edsetcurs:
	move mousepos,d0
	move $dff00a,d1
	sub d1,d0
	move d1,mousepos
	move d0,d1
	andi.l#$ff,d0
	add d0,d0
	asr#7,d1
	andi.l#$ff,d1

	sub d0,(a6)
	sub d1,2(a6)
	moveq#0,d1
	move (a6),d5
	move 2(a6),d6
	andi#$01e0,d5
;asr#5,d6
;andi#$0f,d6
	cmpi.b#$65,$bfec01
	beq.b edsetcursmap

	asr#5,d6
	andi.l#$7,d6
	bra.b edsetcursmap2
edsetcursmap:
	asr#4,d6
	andi#$0f,d6
;asr#1,d6
;cmpi#9,d6
;bls edfg1
;sub#9,d6
;sub#9*5,2(a6)

edfg1:
;sub#11,d6
;cmpi#11,d6
;bcc edfg1

;andi#$0f,d6
;
;andi#10,d6
	;andi.l#$07,d6	




edsetcursmap2:
	
	addq#1,d6
	muls#26,d6
	tst.b d6
	cmpi#235,d6
	bls.b edsetcurs256
	bset#1,d1
	bset#2,d1
edsetcurs256:
	asr#1,d5
	add#15,d6
	move.b d6,edcopsprdat+10
	move.b d6,edcopsprdat+10+16
	move.b d6,edcopsprdat+10+32
	move.b d6,edcopsprdat+10+48
	move.b d6,edcopsprdat+10+64
	move.b d6,edcopsprdat+10+80
	move.b d6,edcopsprdat+10+96
	add.b#28,d6
	bcc.b edsprsetbt2
	bset#1,d1
edsprsetbt2:
	move.b d6,edcopsprdat+14
	move.b d6,edcopsprdat+14+16
	subq#4,d6
	move.b d6,edcopsprdat+14+32
	move.b d6,edcopsprdat+14+48
	move.b d6,edcopsprdat+14+64
	move.b d6,edcopsprdat+14+80
	sub#23,d6
	move.b d6,edcopsprdat+14+96


	add#16,d6

	add#$3d,d5
	;asr#1,d5
	move.b d5,edcopsprdat+11
	add#8,d5
	move.b d5,edcopsprdat+11+96
	add#8,d5
	move.b d5,edcopsprdat+11+16
	
	add#5,d5
	move.b d5,edcopsprdat+11+32
	add#6,d5
	move.b d5,edcopsprdat+11+48
	add#6,d5
	move.b d5,edcopsprdat+11+64
	add#6,d5
	move.b d5,edcopsprdat+11+80

	move.l#edsprdat,d0
	move d0,edcopsprdat+6
	swap d0
	move d0,edcopsprdat+2
	move.l#edsprdatii,d0
	move d0,edcopsprdat+6+16
	swap d0
	move d0,edcopsprdat+2+16

	move.b d1,edcopsprdat+15
	move.b d1,edcopsprdat+15+16
	move.b d1,edcopsprdat+15+32
	move.b d1,edcopsprdat+15+48
	move.b d1,edcopsprdat+15+64
	move.b d1,edcopsprdat+15+80
	move.b d1,edcopsprdat+15+96

	moveq#0,d0
	rts
edactualblock:
	dc.w 0,0,0
editprtscreen:

	move screenbas+4,d0
	move d0,edcopbltpt+2
	move d0,edcopbltpt+6
	move d0,edcopbltpt+10
	move d0,edcopbltpt+14
	move d0,edcopbltpt+18
			
	lea landscpeadr,a0
	move screenpointer+2,d0
	asr#3,d0
	andi#$fff8,d0	
	add d0,a0

	move.l#$ffffffff,$dff044
	move #0,$dff042
	move#0,$dff000
	move#%0000100111110000,$dff040

	moveq#127,d0
	moveq#2,d1
	move#%0010000010000010,d2
	move#256-10,d3
	
	move.l screenbas,a5
	lea blockpointer,a6
	move.l a5,a3
	moveq#9,d7
editprtscr:
	lea(a5),a3
	moveq#0,d5
	bsr.w editbltblock
	bsr.w editbltblock
	bsr.w editbltblock
	bsr.w editbltblock
	add#4,a5
	dbra d7,editprtscr
	move.l screenbas,d7
	move.l screenbas+4,screenbas
	move.l d7,screenbas+4
	move.l a3,$dff054
	move#%0000100100000000,$dff040
	move#0,$dff066
	move#%0001100000000000,$dff058

	rts

edprtscreen:
	move.l#0,edblockdum
	move screenbas+4,d0
	move d0,edcopbltpt+2
	move d0,edcopbltpt+6
	move d0,edcopbltpt+10
	move d0,edcopbltpt+14
	move d0,edcopbltpt+18
		
	lea landscpeadr,a0
	move screenpointer+2,d0
	asr#3,d0
	andi#$fff8,d0	
	add d0,a0

	move.l#$ffffffff,$dff044
	move #0,$dff042
	move#0,$dff000
	move#%0000100111110000,$dff040

	moveq#127,d0
	moveq#2,d1
	move#%0010000010000010,d2
	move#256-10,d3
	
	move.l screenbas,a5
	lea blockpointer,a6
	move.l a5,a3
	moveq#9,d7
edprtscr:
	move.b edblockdum+2,edblockdum
	move.b edblockdum+2,edblockdum+1
	add.b#10,edblockdum+1
	lea(a5),a3
	moveq#0,d5
	lea edblockdum,a0
	bsr.b editbltblock 
	add#$1414,edblockdum
	lea edblockdum,a0
	bsr.b editbltblock
	add#$1414,edblockdum
	lea edblockdum,a0
	bsr.b editbltblock
	add#$1414,edblockdum
	lea edblockdum,a0
	bsr.b editbltblock
	add#$1414,edblockdum
	lea edblockdum,a0
	bsr.b editbltblock


	add#4,a5
	add.b#1,edblockdum+2
	dbra d7,edprtscr
	move.l screenbas,d7
	move.l screenbas+4,screenbas
	move.l d7,screenbas+4
	rts
edblockdum:
	dc.w 0,0

editbltblock:
	bsr.w editbltblock2
editbltblock2:
	moveq#0,d5
	move.b(a0),d5
	bmi.b editbltblock3
	asl#2,d5
	move.l(a6,d5),$dff050
	move.l a3,$dff054
	move#36,$dff064
	move#44,$dff066
	move d2,$dff058
	add#26*240,a3
	addq#1,a0
	rts
editbltblock3:
	bclr#7,d5
	asl#2,d5
	move.l(a6,d5),d4
	add.l#25*40*5,d4	
	move.l a3,a4
	moveq#4,d3
	move#-120-120+36,$dff064
	move#192+44,$dff066
editbltblock4:
	move.l d4,$dff050
	move.l a4,$dff054
	move #%0000011010000010,$dff058
	add#48,a4
	add#40,d4
	dbra d3,editbltblock4
	add#26*240,a3
	addq#1,a0
	rts



edirqvector:
	movem.l d0-d7/a0-a6,-(sp)

	;jsr plymanagerirq

	move screenpointer+2,d7
	bpl.b edirqnewscrdir
	tst screenrastcnt
	bne.b edirqnewscrdir
	beq.b edirqnewscrdir
	move#$3,screenpointer+2
	edirqnewscrdir:

	;jsr screenman

	addq#1,screenrastcnt
	move$dff01e,$dff09c
	movem.l (sp)+,d0-d7/a0-a6
	rte
screenbas:
	dc.l$10080,$20080
edscreenpoint:
	dc.l 0,0

edcoplst:
	dc.w $2501,$fffe,$8e,$2970,$90,$29c4,$92,$30,$94,$c8,$100,$1000
edcopsprdat2:
edcopsprdat = edcopsprdat2-edcoplst+edcoplist
	dc.w $120,2,$122,0,$140,$6850,$142,$ff00
	dc.w $124,2,$126,0,$148,$7058,$14a,$ff00
	dc.w $128,1,$12a,$fe00,$150,$3080,$152,$f000
	dc.w $12c,1,$12e,$fe78,$158,$3088,$15a,$f000
	dc.w $130,1,$132,$fef0,$160,$3088,$162,$f000
	dc.w $134,1,$136,$ff68,$168,$3088,$16a,$f000
	dc.w $138,1,$13a,$ffe0,$170,$3088,$172,$f000
	dc.w $13c,1,$13e,$ffe0,$178,$f400,$17a,$f500

edcopbltpt2:
edcopbltpt = edcopbltpt2-edcoplst+edcoplist
	dc.w $e0,0,$e4,0,$e8,0,$ec,0,$f0,0,$f4,0,$f8,0
	dc.w $e2,$80,$e6,$80+48,$ea,$80+96,$ee,$80+144,$f2,$80+192
	
	dc.w $92,$34,$94,$d0,$10a,198,$108,198,$104,$24
edcopcolarea2:
edcopcolarea = edcopcolarea2-edcoplst+edcoplist
	dc.w$180,0,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
	dc.w$190,0,$192,0,$194,0,$196,0,$198,0,$19a,0,$19c,0,$19e,0
	dc.w$1a0,0,$1a2,0,$1a4,0,$1a6,0,$1a8,0,$1aa,0,$1ac,0,$1ae,0
	dc.w$1b0,0,$1b2,0,$1b4,0,$1b6,0,$1b8,0,$1ba,0,$1bc,0,$1be,0
	dc.w $2a01,$fffe,$100,$5000,$102,$ff,$17c,$ffff,$17e,$ffff
	dc.w $e2,128
	dc.w$ffff,$fffe
	dc.w$ffdf,$fffe,$05df,$fffe,$100,$ff00,$180,0
	dc.w$e2,0,$e6,40,$ea,80,$ee,120,$f2,160
	dc.w$e0,6,$e4,6,$e8,6,$ec,6,$f0,6
edcopcoldwn2:
edcopcoldwn = edcopcoldwn2-edcoplst+edcoplist
	dc.w$09df,$fffe,$100,$5800,$180,0
	dc.w $ffff,$fffe



edsprdat2:
edsprdat = edsprdat2-edcoplst+edcoplist
	dc.w$ff00,0,$ff00,0,$f000,0,$f000,0,$f000,0,$f000,0,$f000,0,$f000,0
	dc.w$f000,0,$f000,0
	dc.w$f000,0,$f000,0,$f000,0,$f000,0,$f000,0,$f000,0,$f000,0,$f000,0
	dc.w$f000,0,$f000,0,$f000,0,$f000,0,$f000,0,$f000,0,$f000,0,$f000,0
	dc.w$ff00,0,$ff00,0
edsprdatii2:
edsprdatii = edsprdatii2-edcoplst+edcoplist
	dc.w$ff00,0,$ff00,0,$0f00,0,$0f00,0,$0f00,0,$0f00,0,$0f00,0,$0f00,0
	dc.w$0f00,0,$0f00,0
	dc.w$0f00,0,$0f00,0,$0f00,0,$0f00,0,$0f00,0,$0f00,0,$0f00,0,$0f00,0
	dc.w$0f00,0,$0f00,0,$0f00,0,$0f00,0,$0f00,0,$0f00,0,$0f00,0,$0f00,0
	dc.w$ff00,0,$ff00,0


