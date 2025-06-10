; Simple sourcecode that shows a 5 bitplanes 320x256 picture.
;
; Save a 320x256 32 colors picture as raw bitplanes (binary) to the file
; '5plpic.raw', and it's palette as a binary 4 bit copperlist to the file
; '5plpic.pal'.

	include	init.i

main	moveq	#0,d0
	rts				; return to CLI

;***
init
	move.l	#pic,d0
	lea	bplp,a0
	moveq	#5-1,d1
lup2	move.w	d0,6(a0)		; insert BPLPTR LOW
	swap	d0
	move.w	d0,2(a0)		; insert BPLPTR HIGH
	swap	d0
	add.l	#10240,d0		; (320/8)*256 = 10240
	addq	#8,a0
	dbra	d1,lup2
	rts
;***
	Section	copper,DATA_C
copper
	incbin	5plpic.pal		; insert the picture's
					; 4 bits palette copperlist here
	dc.w	$010c,$0011 
	dc.w	$008e,$2c81
	dc.w	$0100,$5200
	dc.w	$0104,$0224 
	dc.w	$0106,$0c40 
	dc.w	$0090,$2cc1 
	dc.w	$0092,$0038 
	dc.w	$0094,$00d0
	dc.w	$0102,$0000 
	dc.w	$0108,$0000
	dc.w	$010a,$0000 

bplp	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000
	dc.w	$00f0,$0000,$00f2,$0000 

	dc.w	$01fc,$0000
	dc.w	$ffff,$fffe

;***
	Section	picture,DATA_C
	
pic	incbin	5plpic.raw		; insert path to 5 planes 320x256
					; picture here
