; Simple sourcecode that moves four 64 pixels wide sprites on the screen.
; AGA only.
;
; Save a 128x111 frame as attached sprites with controlwords (binary) to the
; file 'sprite64.raw'.

	include	init.i

main
	move.l	sinepointer,a0		; insert new y coordinate
	cmp.l	#eof_sine,a0
	bne.s	no_wrap
	move.l	#sine,a0
no_wrap	moveq	#0,d0
	move.w	(a0)+,d0
	move.l	a0,sinepointer

	andi.w	#$ff00,sprite+(111+2)*8*2*0
	andi.w	#$fffe,sprite+8+(111+2)*8*2*0
	andi.w	#$ff00,sprite+(111+2)*8*2*1
	andi.w	#$fffe,sprite+8+(111+2)*8*2*1
	andi.w	#$ff00,sprite+(111+2)*8*2*2
	andi.w	#$fffe,sprite+8+(111+2)*8*2*2
	andi.w	#$ff00,sprite+(111+2)*8*2*3
	andi.w	#$fffe,sprite+8+(111+2)*8*2*3

	move.w	d0,d1
	andi.w	#$1,d1

	or.w	d1,sprite+8+(111+2)*8*2*0
	or.w	d1,sprite+8+(111+2)*8*2*1
	or.w	d1,sprite+8+(111+2)*8*2*2
	or.w	d1,sprite+8+(111+2)*8*2*3

	lsr.w	#1,d0
	or.w	d0,sprite+(111+2)*8*2*0
	or.w	d0,sprite+(111+2)*8*2*1
	add.w	#32,d0
	or.w	d0,sprite+(111+2)*8*2*2
	or.w	d0,sprite+(111+2)*8*2*3
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

	move.w	#100*256+100,sprite+(111+2)*8*2*0	; spr0pos
	move.w	#211*256,sprite+8+(111+2)*8*2*0		; spr0ctl

	move.w	#100*256+100,sprite+(111+2)*8*2*1	; spr1pos
	move.w	#211*256+128,sprite+8+(111+2)*8*2*1	; spr1ctl

	move.w	#100*256+132,sprite+(111+2)*8*2*2	; spr2pos
	move.w	#211*256,sprite+8+(111+2)*8*2*2		; spr2ctl

	move.w	#100*256+132,sprite+(111+2)*8*2*3	; spr3pos
	move.w	#211*256+128,sprite+8+(111+2)*8*2*3	; spr3ctl

	move.l	#sprite,d0		; insert spritepointers for our
	lea	sprp,a0			; four sprites
	moveq	#4-1,d1
inslup	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#8,a0
	add.l	#(111+2)*8*2,d0
	dbra	d1,inslup

	move.l	#copper,d0		; move other spritepointers to a
	lea	emptspr,a0		; place where the sprites won't show
	moveq	#4-1,d1
sprlup	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#8,a0
	dbra	d1,sprlup	
	rts
;***
	Section	copper,DATA_C
copper
	dc.w	$0180,$0fff,$0182,$0fff

	; sprite colors
	dc.w	$01a0,$0fff,$01a2,$0324,$01a4,$0254,$01a6,$0952
	dc.w	$01a8,$0651,$01aa,$0478,$01ac,$0932,$01ae,$0952
	dc.w	$01b0,$0a55,$01b2,$0c62,$01b4,$0e77,$01b6,$097c
	dc.w	$01b8,$0c78,$01ba,$0997,$01bc,$0fff,$01be,$0321

	dc.w	$010c,$0011 
	dc.w	$008e,$2c81
	dc.w	$0100,$1200
	dc.w	$0104,$0224 
	dc.w	$0106,$0c40 
	dc.w	$0090,$2cc1 
	dc.w	$0092,$0038 
	dc.w	$0094,$00d8
	dc.w	$0102,$0000 
	dc.w	$0108,$fff8
	dc.w	$010a,$fff8 

bplp	dc.w	$00e0,$0000,$00e2,$0000

sprp	dc.w	$0120,$0000,$0122,$0000
	dc.w	$0124,$0000,$0126,$0000
	dc.w	$0128,$0000,$012a,$0000
	dc.w	$012c,$0000,$012e,$0000

emptspr	dc.w	$0130,$0000,$0132,$0000
	dc.w	$0134,$0000,$0136,$0000
	dc.w	$0138,$0000,$013a,$0000
	dc.w	$013a,$0000,$013e,$0000

	dc.w	$01e4,$2100
	dc.w	$01fc,$000f
	dc.w	$ffff,$fffe

;***
	Section	empty,BSS_C
	
empty	ds.b	320/8*256

;***
	Section sprite,DATA_C

sprite		incbin	sprite64.raw		; insert 4 64x111 sprites here

;***
	Section	sinetable,DATA

sine
	dc.l	$0105010e,$01180122,$012b0134,$013e0147,$01500158,$01610169
	dc.l	$01710179,$01800187,$018e0194,$019a019f,$01a501a9,$01ae01b2
	dc.l	$01b501b8,$01bb01bd,$01be01bf,$01c001c0,$01c001bf,$01bd01bc
	dc.l	$01b901b7,$01b301b0,$01ac01a7,$01a2019d,$01970191,$018a0183
	dc.l	$017c0175,$016d0165,$015c0154,$014b0142,$01390130,$0126011d
	dc.l	$0113010a,$010000f6,$00ed00e3,$00da00d0,$00c700be,$00b500ac
	dc.l	$00a4009b,$0093008b,$0084007d,$0076006f,$00690063,$005e0059
	dc.l	$00540050,$004d0049,$00470044,$00430041,$00400040,$00400041
	dc.l	$00420043,$00450048,$004b004e,$00520057,$005b0061,$0066006c
	dc.l	$00720079,$00800087,$008f0097,$009f00a8,$00b000b9,$00c200cc
	dc.l	$00d500de,$00e800f2,$00fb0105,$010e0118,$0122012b,$0134013e
	dc.l	$01470150,$01580161,$01690171,$01790180,$0187018e,$0194019a
	dc.l	$019f01a5,$01a901ae,$01b201b5,$01b801bb,$01bd01be,$01bf01c0
	dc.l	$01c001c0,$01bf01bd,$01bc01b9,$01b701b3,$01b001ac,$01a701a2
	dc.l	$019d0197,$0191018a,$0183017c,$0175016d,$0165015c,$0154014b
	dc.l	$01420139,$01300126,$011d0113,$010a0100,$00f600ed,$00e300da
	dc.l	$00d000c7,$00be00b5,$00ac00a4,$009b0093,$008b0084,$007d0076
	dc.l	$006f0069,$0063005e,$00590054,$0050004d,$00490047,$00440043
	dc.l	$00410040,$00400040,$00410042,$00430045,$0048004b,$004e0052
	dc.l	$0057005b,$00610066,$006c0072,$00790080,$0087008f,$0097009f
	dc.l	$00a800b0,$00b900c2,$00cc00d5,$00de00e8,$00F200FB
eof_sine

sinepointer	dc.l	sine
