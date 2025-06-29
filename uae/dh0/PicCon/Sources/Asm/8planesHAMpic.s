; Very simple sourcecode that shows a HAM8 320x256 AGA picture.
;
; Save a 320x256 HAM8 picture as raw bitplanes (binary) to the file 'HAM8.RAW',
; and it's palette as a binary 8 bits copperlist to the file 'HAM8.pal'.

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
	incbin	HAM8.pal		; insert the picture's
					; 8 bits palette copperlist here

	DC.B	$01,$0C,$00,$11,$00,$8E,$2C,$81
	DC.B	$01,$00,$0A,$10,$01,$04,$02,$24
	DC.B	$01,$06,$0C,$40,$00,$90,$2C,$C1
	DC.B	$00,$92,$00,$38,$00,$94,$00,$D8
	DC.B	$01,$02,$00,$00,$01,$08,$FF,$F8
	DC.B	$01,$0A,$FF,$F8

bplp	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000
	dc.w	$00f0,$0000,$00f2,$0000 
	dc.w	$00f4,$0000,$00f6,$0000
	dc.w	$00f8,$0000,$00fa,$0000
	dc.w	$00fc,$0000,$00fe,$0000 

	dc.b	$01,$E4,$21,$00
	DC.B	$01,$FC,$00,$03,$FF,$FF,$FF,$FE
;***
	Section	picture,DATA_C
	
pic	incbin	HAM8.RAW		; insert path to 8 planes 320x256
					; picture here
