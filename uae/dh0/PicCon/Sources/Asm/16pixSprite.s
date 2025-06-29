; Simple sourcecode that moves a 16x16 sprite on the screen.
;
; Save a 16x16 unattached sprite with controlwords (binary) to the file
; 'sprite16.raw'.

	include	init.i

main
	move.l	sinepointer,a0		; insert new y coordinate
	cmp.l	#eof_sine,a0
	bne.s	no_wrap
	move.l	#sine,a0
no_wrap	moveq	#0,d0
	move.b	(a0)+,d0
	add.w	#30,d0
	move.l	a0,sinepointer
	lsl.w	#8,d0
	move.w	d0,sprite
	add.w	#16*256,d0
	move.w	d0,sprite+2

	move.w	xposition,d0
	cmp.w	#100,d0
	bne.s	no_reset
	move.w	#450,d0
no_reset
	sub.w	#1,d0
	move.w	d0,xposition
	move.w	d0,d1
	lsr.w	#1,d1
	or.w	d1,sprite		; x position
	andi.w	#1,d0
	or.w	d0,sprite+2

	move.l	#255,d0
	rts
;***
init
	move.l	#empty,d0
	lea	bplp,a0
	move.w	d0,6(a0)		; insert BPLPTR LOW
	swap	d0
	move.w	d0,2(a0)		; insert BPLPTR HIGH

	move.w  #DMA_SETCLR!DMA_SPRITE!DMA_RASTER!DMA_COPPER!DMA_MASTER,dmacon+$dff000

	move.w	#100*256+100,sprite
	move.w	#116*256,sprite+2

	move.l	#sprite,d0
	lea	sprp,a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	move.l	#copper,d0
	lea	emptspr,a0
	moveq	#7-1,d1
emptlup	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#8,a0
	dbra	d1,emptlup
	rts
;***
	Section	copper,DATA_C
copper
	dc.w	$0180,$0553,$0182,$0553
	dc.w	$01a2,$0ff0,$01a4,$0000,$01a6,$0f00	; sprite colors

	dc.w	$010c,$0011 
	dc.w	$008e,$2c81
	dc.w	$0100,$1200
	dc.w	$0104,$0224 
	dc.w	$0106,$0c40 
	dc.w	$0090,$2cc1 
	dc.w	$0092,$0038 
	dc.w	$0094,$00d0
	dc.w	$0102,$0000 
	dc.w	$0108,$0000
	dc.w	$010a,$0000 

bplp	dc.w	$00e0,$0000,$00e2,$0000

sprp	dc.w	$0120,$0000,$0122,$0000

emptspr	dc.w	$0124,$0000,$0126,$0000
	dc.w	$0128,$0000,$012a,$0000
	dc.w	$012c,$0000,$012e,$0000
	dc.w	$0130,$0000,$0132,$0000
	dc.w	$0134,$0000,$0136,$0000
	dc.w	$0138,$0000,$013a,$0000
	dc.w	$013c,$0000,$013e,$0000

	dc.w	$01fc,$0000
	dc.w	$ffff,$fffe

;***
	Section	empty,BSS_C
	
empty	ds.l	320/8*256

;***
	Section sprite,DATA_C

sprite	incbin	sprite16.raw

;***
	Section	sinetable,DATA

sine
	dc.l	$6567696b,$6d6f7173,$7576787a,$7c7e8082,$84858789,$8b8c8e90
	dc.l	$91939496,$98999a9c,$9d9fa0a1,$a2a4a5a6,$a7a8a9aa,$abacadae
	dc.l	$aeafb0b0,$b1b1b2b2,$b3b3b3b4,$b4b4b4b4,$b4b4b4b4,$b4b3b3b3
	dc.l	$b2b2b1b1,$b0b0afae,$aeadacab,$aaa9a8a7,$a6a5a4a2,$a1a09f9d
	dc.l	$9c9a9998,$96949391,$908e8c8b,$89878584,$82807e7c,$7a787675
	dc.l	$73716f6d,$6b696765,$63615f5d,$5b595755,$5352504e,$4c4a4846
	dc.l	$4443413f,$3d3c3a38,$37353432,$302f2e2c,$2b292827,$26242322
	dc.l	$21201f1e,$1d1c1b1a,$1a191818,$17171616,$15151514,$14141414
	dc.l	$14141414,$14151515,$16161717,$1818191a,$1a1b1c1d,$1e1f2021
	dc.l	$22232426,$2728292b,$2c2e2f30,$32343537,$383a3c3d,$3f414344
	dc.l	$46484a4c,$4e505253,$5557595b,$5d5f6163
eof_sine

sinepointer	dc.l	sine
xposition	dc.w	450
