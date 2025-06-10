; Very simple sourcecode that shows an 8 bitplanes 320x256 AGA picture.
;
; Save a 320x256 256 colors picture as raw bitplanes (binary) to the file
; '8plpic.raw', and it's palette as a binary 8 bit copperlist to the file
; '8plpic.pal'.

	include	init.i

main	moveq	#0,d0
	rts				; return to CLI

;***
init
	move.l	#pic,d0
	lea	bplp,a0
	moveq	#8-1,d1
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
	incbin	8plpic.pal		; insert the picture's
					; 8 bits palette copperlist here
	dc.w	$010c,$0011 
	dc.w	$008e,$2c81
	dc.w	$0100,$0210
	dc.w	$0104,$0224 
	dc.w	$0106,$0c40 
	dc.w	$0090,$2cc1 
	dc.w	$0092,$0038 
	dc.w	$0094,$00d8 
	dc.w	$0102,$0000 
	dc.w	$0108,$fff8
	dc.w	$010a,$fff8 

bplp	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000
	dc.w	$00f0,$0000,$00f2,$0000 
	dc.w	$00f4,$0000,$00f6,$0000
	dc.w	$00f8,$0000,$00fa,$0000
	dc.w	$00fc,$0000,$00fe,$0000 

	dc.w	$01e4,$2100
	dc.w	$01fc,$0003   
	dc.w	$ffff,$fffe

;***
	Section	picture,DATA_C
	
pic	incbin	8plpic.raw		; insert path to 8 planes 320x256
					; picture here
