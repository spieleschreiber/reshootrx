game = $1000
startorg = $c60000
gameorg = startorg+$300

editor  = $c3c000
edcoplist = $30000
			; *** Tabellen - Adressen
landscapeadr = $1c000
landscpeadr = $c37000
blockadr = $50040
blockshdw = $8000

blockshdw2 = $12000

spradr = $5c840
sa = spradr
sprshdw = $c800


bobanimtab = $7f000
bobpostab = $f800

banimtab = $d000
blockpointer = $e000
blockpointer2 = $e200
scr2muls = $e400
bobcuttab = $e600
wavecount = $7e680
			; *** Festwerte
	banxpos=256
	banypos=banxpos*2
	banaccl=banxpos*3
	bancnt=banxpos*4
	banhit=banxpos*5
	banwav=banxpos*6
	
	dispstop=$f6





	org startorg
	load startorg
t:
	move#-1,$dff02e
	move#%0100000000000000,$dff09a
	move#%1000011111110000,$dff096

	move.l 4,a6
	jsr -150(a6)
	move.l d0,savessp	;Supervisor-mode an
	move.l $6c,savessp+4

	lea$0,a0
	lea$c40000,a1
	move.l#$1fffc/4,d0
saveintuition:
	move.l(a0)+,(a1)+
	dbra d0,saveintuition

	lea gameorg,a0
	lea game,a1
	move.l#$3ff8/4,d0
saveintuition2:
	move.l(a0)+,(a1)+
	dbra d0,saveintuition2
	jmp mainstart2

mainendgame:
	move#0,$dff02e
	move#$8040,$dff096
	lea intuition(pc),a1
	moveq#0,d0
	move.l 4,a6
	jsr -552(a6)
	move.l 38(a0),$dff080
	move.l a0,a1
	jsr -414(a6)		;Betr.system-Copperliste an
	move#$8040,$dff096

	lea $c40000,a0
	lea $0,a1
	move.l #$1fffc/4,d0
writeintuition:
	move.l (a0)+,(a1)+
	dbcs d0,writeintuition
	move#$8040,$dff096

	move.l savessp,d0
	move.l 4,a6
	jsr -156(a6)		;supervisor-modus aus
	move#$8040,$dff096


	move.l savessp+4,$6c
	move#%1000001111110000,$dff096
	move#%1100000000100000,$dff09a
	illegal
savessp:
	dc.l 0,0
intuition:
	dc.b "graphics.library",0

	org game+$2000
	load gameorg+$2000

progbase:
banimtabor:			;x-pos, y-pos, animnum, anz.wiederhol
				;abst.wiederhol, $80 = wdhstart jeweils
				;an alter xpos., hitstaerke
;dc.w 3,$0025,$2140,0
;dc.w 3,$0026,$520,0
;dc.w 20*8+3,$0027,$520,0
;dc.w 40*8+3,$0028,$520,0
dc.w 3,$5009,$518,0


;dc.l $ffffffffff
	dc.w 3*8+3,$101f,$518,$00


	dc.w 15*8+3,$d01e,$518,$00
	dc.w 35*8+3,$101d,$1309,$00
	dc.w 35*8+3,$d01c,$1309,$00
	dc.w 60*8+3,$201b,$0710,1
	dc.w 70*8+3,$cc1b,$0710,1
	dc.w 80*8+3,$501b,$0710,1
	dc.w 90*8+3,$901b,$0710,1
	dc.w 120*8+3,$0026,$520,5
	dc.w 140*8+3,$0027,$520,5
	dc.w 160*8+3,$0028,$520,5
	dc.w 190*8+3,$0025,$460,5


	dc.w 260*8+3,$0020,$1508,$80
	dc.w 261*8+3,$af21,$0d08,0
	dc.w 300*8+3,$6522,$0d0b,2
	dc.w 326*8+3,$4b20,$0806,0
	dc.w 342*8+3,$3823,$170e,0
	dc.w 393*8+3,$6821,$1006,0
	dc.w 408*8+3,$c024,$1408,0
	dc.l $ffffffff

banim0:					;Standardschuss
	dc.b $50,0,$1,1,  0,0,$1d,1,$80,$80
banim1:					
	dc.b $20,-$10,1,1, 2,-1,$24,1, $80,$80
banim2:
	dc.b $20,$10,1,1, 2,1,$20,1, $80,4,$80
banim3:
	dc.b $30,-$40,1,1, 0,$11,$40,1, $80,$80
banim4:
	dc.b 0,0,1,3, 0,0,1,4, 0,0,1,5, 0,0,1,6, $80,$80
banim5:
	dc.b 0,0,2,7, 0,0,2,8, 0,0,2,9, 0,0,2,10, 0,0,2,11
	dc.b 0,0,2,12,0,0,2,13,0,0,2,14, $80,$80
banim6:
	dc.b 0,-2,10,15, 0,2,24,15, $80,6,$80,$80

;0,0,1,15, $80,6
banim7:
	dc.b 0,0,2,16, 0,0,2,17, 0,0,2,18, 0,0,2,19, 0,0,2,20
	dc.b 0,0,2,21,0,0,2,22,0,0,2,23, $80,$80
banim8:
	dc.b 0,0,2,24, 0,0,2,25, 0,0,2,26, 0,0,2,27, $80,$80
banim9:
	dc.b -4,0,1,2, 0,0,$7f,2, $80,$1f,$1e,$80
banima:

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
	dc.b $f0,0,1,25, 0,0,$78,25, $80,$80
banim1c:
	dc.b -19,-18,1,2, 0,0,40,2, 0,1,80,2, $80,$80
banim1d:
	dc.b -19,18,1,2, 0,0,40,2, 0,-1,80,2, $80,$80
banim1e:
	dc.b -14,-14,1,2, 0,0,40,2, 0,1,80,2, $80,$80
banim1f:
	dc.b -14,14,1,2, 0,0,40,2, 0,-1,80,2, $80,$80
banim20:
	dc.b $ff,5,1,0, $ff,0,$1f,0, $ff,0,$24,0, $80,$80
banim21:
	dc.b $ff,-5,1,0, $ff,0,$1f,0, $ff,0,$24,2, $80,$80
banim22:
	dc.b $ff,0,$24,24, $ff,0,$10,24, 40,-20,1,24, -1,0,40,24, $80,$80
banim23:
	dc.b $f0,0,1,24, 0,0,$78,24, $80,$80
banim24:
	dc.b -40,0,1,24, 1,-1,$10,24, 0,-2,$28,24, $80,$80
banim25:
	dc.b 0,0,60,26, 1,8,1,26, 0,0,120,26, -1,0,2,27
	dc.b -2,0,34,28, $80,$80
banim26:
	dc.b 0,0,60,26, -8,95,1,26, -1,-2,70,26, $80,$80
banim27:
	dc.b 0,0,60,26, -8,90,1,26, -1,-2,70,26, $80,$80
banim28:
	dc.b 0,0,60,26, -8,76,1,26, -1,-2,80,26, $80,$80
banim29:
banim2a:
banim2b:
banim2c:
banim2d:
banim2e:
banim2f:

even

banimadrtab:
	dc.l banim0,banim1,banim2,banim3,banim4,banim5,banim6,banim7
	dc.l banim8,banim9,banima,banimb,banimc,banimd,banime,banimf
	dc.l banim10,banim11,banim12,banim13,banim14,banim15,banim16,banim17
	dc.l banim18,banim19,banim1a,banim1b,banim1c,banim1d,banim1e,banim1f
	dc.l banim20,banim21,banim22,banim23,banim24,banim25,banim26,banim27
	dc.l banim28,banim29,banim2a,banim2b,banim2c,banim2d,banim2e,banim2f
banimchar:	
		; bits 0-2 = animspeed
		; bit3 = $08 = schuss
		; bit4 = $10 = explosion, no colldect.
		; bit5 = $20 = icon, colldect auf ply
		; bit6 = $40 = explos, no colldect, 1 bpl
		; bit7 = $80 = bckgnd n. verknuepfen

	dc.l 4*200+$5c850,$0f0e0300
	dc.l 0*230+$5c840,$0f038800
	dc.l 4*200+$5c850,$0f0e8300
	dc.l 26*200+$5c860,$0f0f1000
	dc.l 26*200+$5c862,$0f0f1000
;5
	dc.l 26*200+$5c864,$0f0f1000
	dc.l 26*200+$5c866,$0f0f1000
	dc.l 26*200+$5c840,$1f1f1000
	dc.l 26*200+$5c844,$1f1f1000
	dc.l 26*200+$5c848,$1f1f1000
;10
	dc.l 26*200+$5c84c,$1f1f1000
	dc.l 26*200+$5c850,$1f1f1000
	dc.l 26*200+$5c854,$1f1f1000
	dc.l 26*200+$5c858,$1f1f1000
	dc.l 26*200+$5c85c,$1f1f1000
;15
	dc.l 4*200+$5c840,$10152000
	dc.l 26*200+$5c840,$1f1f5000
	dc.l 26*200+$5c844,$1f1f5000
	dc.l 26*200+$5c848,$1f1f5000
	dc.l 26*200+$5c84c,$1f1f5000
;20
	dc.l 26*200+$5c850,$1f1f5000
	dc.l 26*200+$5c854,$1f1f5000
	dc.l 26*200+$5c858,$1f1f5000
	dc.l 26*200+$5c85c,$1f1f5000
	dc.l 3*200+$5c840,$1f160600
;25
	dc.l 3*200+$5c840,$1f168600
	dc.l 130*200+sa,$5f508000
	dc.l 130*200+sa+$c,$5f578000
	dc.l 130*200+sa+$18,$5f5f8000



	dc.l $3b408,$0f040000,$3b408,$0f030000,$3b408,$0f010000




	org game
	load gameorg


mainstart2:
;end
	move.l#irq2,$6c
	move#%0000000001100000,$dff09a
	move#%1100000000010000,$dff09a	; Copper-IRQ an

	;move#%0000000000100000,$dff1dc

	move.l#coplist,$dff080
	move#0,$dff088
	lea scr2muls,a0
	move#255,d0
	moveq#0,d1
setmulstab:
	move d1,(a0)+
	add#5*46,d1
	dbra d0,setmulstab

	lea bobcuttab,a0
	moveq#127,d0
	moveq#0,d1
setmulstab2:
	move d1,(a0)+
	add#5*40,d1
	dbra d0,setmulstab2

	lea bobanimtab,a1
	move.l#$17c/4,d0
setmovcnt3:
	clr.l(a1)+
	dbcs d0,setmovcnt3	;bobpostabelle loeschen
	lea $50000,a0
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
	lea blockpointer2,a2
	lea blockadr,a1
	lea blockadr-blockshdw2,a3
wrtblockpointer1:
	moveq#9,d1
wrtblockpointer:
	move.l a1,(a0)+
	move.l a3,(a2)+
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
	move#$b0,d7
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
	andi#$f,d6
	bne.b sprplxskip

	;tst d5
	;bne kl4 
	add#$1,d7
	;sub.b#$1,d7
	;bpl kl4
;sub#2,a6
	;move#$ffff,d5

kl4:
	;add#1,d7
	move d7,d6
	move#$1b6,(a0)+
	move d6,(a0)+

	move#$1b4,(a0)+
	sub#1,d6

	move d6,(a0)+
	move#$1b2,(a0)+
	move d6,d5
	andi#$0f,d5
	
cmpi#$0a,d5
ble.b sprplxskp3

move d6,d5
andi#$ff0,d5
or#$0a,d5
;move#$0c,d5
move d5,d6
;move#$fff,d6
sprplxskp3:
	add#5,d6
	
	move d6,(a0)+
sprplxskip:
	addq#1,d3
	dbra d0,kl1
	moveq#60,d0
	lea copcolscor,a1
kl2:
	move.l(a1)+,(a0)+
	dbra d0,kl2



	jsr mainprtscreen


	move#120,plycoll

	move.l#0,objcount
	move#0,objcount+4
	move.l#$ffffffff,bobpostab
	move.l#$ffffffff,bobpostab+512

	btst#1,$dff00d
	beq.b rastwait
	jmp editor
rastwait:			;***Hauptprogramm/Schleife***
;bra maintstend

;move screenrastcnt,d0
rastw2:

	move screenrastcnt,d0
;cmpi#2,d0
;bne rastw2
	beq.b rastw2

;cmp screenrastcnt,d0
;beq rastw2
	;cmpi#8,screenrastcnt
	;bcs rastwait
	move screenrastcnt,screenrastcnt+2
	clr screenrastcnt
	add#1,screenrastcnt+4

		bsr scren2

		bsr bobmanager

		bsr plymanager	

		bsr.w collmanager

	jsr bcksprctrl
	cmpi.b#$55,$bfec01
	bne.b maintstend
	cmpi#$279,editor
	bne.b maintstend
		move#0,$dff02e
		jmp editor

maintstend:
	cmpi.b#$4f,$bfec01
	bne.b rastwait
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
	addq#1,screenrastcnt
	addq#1,screenrastcnt+4
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
	add#$8000,d0
	move d0,(a0)
	add#$348,d0
	move d0,(a1)


	rts
bcksprcnt:
	dc.w 0

scren2:

	lea landscapeadr-16,a0
	lea scr2base,a2
	lea screenpointer,a3
copscbltpt:
	lea $80,a4
	lea copbltpt,a5
	lea blockpointer,a6
	moveq#46,d6

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
	move d1,38(a5)
	add d6,d1
	move d1,42(a5)
	swap d1
	move d1,2(a5)
	move d1,6(a5)
	move d1,10(a5)
	move d1,14(a5)
	move d1,18(a5)


	moveq#15,d6		; x-soft-scroll 
	sub d0,d6
	andi#$0f,d6
	move d6,d7
	asl#4,d7
	or d6,d7
	move d7,copplayinit+10

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

	move.l#$24002a,d2
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
	move#226,$dff066
	moveq#4,d4
screenblock:
	movem.l d0/d1,$dff050
	move#%0000011010000010,$58(a3)
	add#46,d1
	add#40,d0
	dbra d4,screenblock

	move#42,$dff064
	move#42,$dff066
	move.l d3,$40(a3)
	bset#16,d7
	bset#17,d7
	movem.l d6/d7,$50(a3)
	move#%0010000010000010,$58(a3)
	rts
scr2add:
	dc.w 44,$175c+44,$175c*2+44,$175c*3+44,$175c*4+42
	dc.w $175c*5+42,$175c*6+42,$175c*7+42
scr2base:
	dc.l$10080,$20080
screenpointer:
	dc.w 0,0,0,0	;1.word = scrollrichtung 2.word = y-scroll-cnt
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
	move plypos,d5
	move plypos+2,d6
	sub#28*8,d5
	sub#38*8,d6
	moveq#0,d4
	moveq#0,d7
	jsr bobaniminit
	move.b#2,banhit(a4)
	move.b#4,plyshot+1
shot2:
	tst.b plyshot+2
	bpl.b shot3
	move plypos,d5
	move plypos+2,d6
	sub#28*8,d5
	sub#38*8,d6
	moveq#1,d4
	moveq#0,d7
	jsr bobaniminit
	move.b#2,banhit(a4)
	move plypos,d5
	move plypos+2,d6
	sub#28*8,d5
	sub#38*8,d6
	moveq#2,d4
	moveq#0,d7
	jsr bobaniminit
	move.b#2,banhit(a4)
	move.b#15,plyshot+2
shot3:
	tst.b plyshot+3
	bpl.b shot4
	move plypos,d5
	move plypos+2,d6
	sub#28*8,d6
	moveq#3,d4
	moveq#0,d7
	;jsr bobaniminit
	move.b#15,plyshot+3
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
	dc.w $1e8,$378,0,4,0,0,0
plycnt:
	dc.w 0,0
plyweap:
	dc.w 0,0,8*10,8*20,8*40,8*80,8*40,8*20,8*10


plyshot:
	dc.w 0,0
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
	moveq#23,d3
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
	moveq#23,d3
	sub (a4),d3
	andi#%11111,d3
	add d3,d3
	add#184,d3
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

	move.l (a4),a0
move.b 6(a4),d0
andi#%111,d0
add d0,d0
move screenrastcnt+4,d6
asr#2,d6
andi d0,d6
add d6,a0

	
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
	moveq#0,d4
	move.b 4(a4),d4
	add#15,d4
	asr#4,d4
	addq#1,d4

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
	bmi.w bobfindloop
	addq#1,d1
	add d5,d5
	add(a1,d5),a0
	moveq#0,d5
	bra.b bobwascut

bobcutdwn:
	move d5,d7
	add d1,d7
	cmpi#dispstop-45,d7
	bls.b bobwascut
	sub#dispstop-45,d7
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


	tst.b 230(a1)
	bne.b col
	tst.b 231(a1)
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
		addq#8,d5
		addq#6,d5
		asl#3,d5
		cmpi d5,d2
		bcc.w bobcol2

		sub banypos(a3),d3	; bobcol yposdetect
		moveq#0,d5
		move.b 5(a1,d4),d5
		addq#3,d3
		asl#3,d5
		add d3,d5
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
			moveq#5,d4
			bsr.w bobaniminitold
			moveq#6,d4
			move.l a3,a2
			bsr.w bobaniminitold
			move.b#8,banhit(a2)
			bra.w bobcolbckgnd
bobcolseticn:				; Explosion Gegner
			move#0,(a2)
			subq#1,objcount
			moveq#5,d4
			move.l a3,a2
			bsr.w bobaniminitold
			bra.w bobcolbckgnd
bobcoldsticn:				; Icon zerstoert
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
	moveq#4,d4
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
add#4*46,d5
	move.l d5,a1
	bset#0,d5
	move.l d5,(a3)+
	move.l a0,d6
	add.l#sprshdw,a0
move.l a0,d6
	movem.l d5/d6/a0/a1,$48(a6)
	moveq#23,d6
	sub.b d4,d6
	andi#%11111,d6
	;move d6,d5
	;add#184,d6
	add d6,d6
	move d6,d5
	add#184,d6
	move d6,$60(a6)
	move d6,$66(a6)
	subq#6,d5
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
	add.l#sprshdw,a0
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
	add.l#sprshdw,a0
	movem.l d5/d6/a0/a1,$48(a6)

bobsetoffset:
	moveq#23,d6
	sub.b d4,d6
	andi#%11111,d6
	add d6,d6
	move d6,$60(a6)
	move d6,$66(a6)
	subq#6,d6
	move d6,$62(a6)
	move d6,$64(a6)

	move d1,d6
	add d6,d6
	add d6,d6
	add d1,d6
	asl#6,d6
	or d6,d4
	move d4,(a3)+
	move d4,$58(a6)

bobfindloop:
	dbra d3,boblitloop

particlectrl:
	move#$ffff,(a3)+
	rts

objcount:
	dc.w 0,0,0

enemanager:
	move.l animbuffer,a0
enemgetseq:
	move screenpointer+2,d0
	move d0,d5
	asr#3,d0
	cmpi (a0),d0
	bcs.b enemquit
	sub.b#1,6(a0)
	bpl.b enemnxtseq
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
	move.b 7(a0),d4
	bclr#7,d4
	move.b (a1,d4),banhit(a4)
	move.l a0,d6
	sub#banimtab,d6
	lsr#3,d6
	move.b d6,banwav+1(a4)

	bra.b enemnxtseq
enemendseq:
	add#8,animbuffer+2
enemnxtseq:
	add#8,a0
	bra.b enemgetseq
enemhitab:
	dc.b 0,2,4,6,8,32,64,$80



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
m2:


	lea spradr,a0
	lea spradr+sprshdw,a1

	move#255,d0
xwrtblockpointer1:
	moveq#9,d1
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
	add#$a0-40,a0
	add#$a0-40,a1
	dbra d0,xwrtblockpointer1
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
	move#42,$dff066
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
	move#226,$dff066
	move #%0000011010000010,$dff058
	add#46,a5
	add#40,d4
	dbra d3,maininitbltblock4


maininitbltblock3:
	bsr.w mainwaitblit
	move#42,$dff064
	move#42,$dff066
	move.l a3,a5
	add.l#$10000,a5
	movem.l a3/a5,$dff050
	move d2,$dff058

	bsr.w mainwaitblit
	add.l#$10000,a5
	movem.l a3/a5,$dff050
	move d2,$dff058
	add#26*230,a4
	addq#1,a0
	rts
	org $3c000
	load $3c000
coplist:
	dc.w $1c01,$fffe,$8e,$3280,$90,$1b8,$92,$30,$94,$c8

copsprdat:
	dc.w $120,6,$122,$0000,$140,$ff50,$142,$f000
	dc.w $124,6,$126,$1114,$148,$ff58,$14a,$f000
	dc.w $128,4,$12a,$2c00,$150,$ff60,$152,$ff00
	dc.w $12c,4,$12e,$2c00,$158,$ff68,$15a,$ff00
	dc.w $130,4,$132,0,$160,$ff70,$162,$ff02
	dc.w $134,4,$136,0,$168,$ff78,$16a,$ff02
	dc.w $138,6,$13a,0,$170,0,$172,0
	dc.w $13c,4,$13e,0,$178,0,$17a,0
copbltpt:
	dc.w $e0,0,$e4,0,$e8,0,$ec,0,$f0,0,$f4,6
	dc.w $e2,0,$e6,40,$ea,80,$ee,120,$f2,160,$f6,$2000
	dc.w $92,$30,$94,$cc,$10a,230-42,$108,230-42,$104,$12
copcolarea:
	dc.w$180,0,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
	dc.w$190,0,$192,0,$194,0,$196,0,$198,0,$19a,0,$19c,0,$19e,0
	dc.w$1a0,0,$1a2,0,$1a4,0,$1a6,0,$1a8,0,$1aa,0,$1ac,0,$1ae,0
	dc.w$1b0,0,$1b2,0,$1b4,0,$1b6,0,$1b8,0,$1ba,0,$1bc,0,$1be,0
copplayinit:
	dc.w $2201,$fffe,$100,$5000,$102,0
c:
copsprdbl:
	blk.l $2200,0


copcolscor:
;copdispscore:
;copcolscor:
dc.w $100,$3000
dc.w $182,$411
dc.w $184,$211
dc.w $186,$131
dc.w $188,$311
dc.w $18a,$201
dc.w $18c,$131
dc.w $18e,$333
	dc.w$1a0,0,$1a2,0,$1a4,0,$1a6,0,$1a8,0,$1aa,0,$1ac,0,$1ae,0
	dc.w$1b0,0,$1b2,0,$1b4,0,$1b6,0,$1b8,0,$1ba,0,$1bc,0,$1be,0

	;dc.w $120,4,$122,$8010,$140,$f750,$142,$ff00
	dc.w $124,4,$126,$8010,$148,$f758,$14a,$ff00
	dc.w $128,4,$12a,$8010,$150,$f760,$152,$ff00
	dc.w $12c,4,$12e,$8010,$158,$f768,$15a,$ff00
	dc.w $130,4,$132,$8010,$160,$f770,$162,$ff00
	dc.w $134,4,$136,$8010,$168,$f778,$16a,$ff00
dc.w $104,%100100
;dc.w $e0,5,$e4,5,$e2,0,$e6,40,$100,$2000,$102,0
dc.w $ffe1,-2
dc.w $0301,-2,$100,0
dc.w $1001,-2
dc.w $96,$40
dc.w $9c,%1000000000010000
;dc.w $1e,%1000000000010000
;dc.w $180,$ffff
;dc.w $9a,%1000000000010000
;dc.w $100,0,$102,0,$e0,5,$e4,5,$e2,0,$e6,30,$100,$2000
	dc.w $ffff,$fffe

getkey:
	move.b$bfec01,$73000
	move.b$bfec01,$dff181
	btst#7,$bfe001
	bne.b getkey
illegal


	org editor
	load editor

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
	lea $50000,a0
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


