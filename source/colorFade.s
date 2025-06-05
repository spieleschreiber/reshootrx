;//
;//  colorFade.s
;//  px
;//
;//  Created by Richard Löwenstein on 29.04.20.
;//  Copyright © 2020 spieleschreiber. All rights reserved.
;//	Original code from a/b at EAB http://eab.abime.net/showthread.php?t=86561&page=3

; function to interpolate between two Amiga OCS/ECS 12-bit RGB values over 0 to 15 steps ( i chose this, as there are 0 to 15 steps to interpolate a colour from $000 to $fff)

;Inputs:
;d0.w = Colour 1 (12bit RGB)
;d1.w = Colour 2 (12bit RGB)
;d2.b = Step value (0-15)

;Output:
;d0.w = Final Interpolated Colour (12bit RGB)
	even
; call buildColFadeTable first to build fadetable


 	
buildColFadeTable
	lea	(colFadeTable,pc),a0
	moveq	#-15,d7
.LoopColor
	moveq	#0,d6
.LoopScale
	move.w	d7,d0
	muls.w	d6,d0
	divs.w	#15,d0
	move.b	d0,(a0)+
;	clr.b	(a0)+
 asl.b	#4,d0
 move.b d0,(a0)+
	addq.w	#1,d6
	cmp.w	#16,d6
	bne.b	.LoopScale
	addq.w	#1,d7
	cmp.w	#16,d7
	bne.b	.LoopColor
	rts

colorInterpolate
	move.w	d3,-(a7)		; 8
	move.w	d4,-(a7)		; 8
	move.w	#$0f0,d3		; 8
	add.w	d3,d2			; 4
	add.w	d2,d2			; 4

	move.w	d3,d4			; 4
	and.w	d0,d3			; 4
	and.w	d1,d4			; 4
	sub.w	d3,d4			; 4
	add.w	d4,d4			; 4
	add.w	d2,d4			; 4
 	add.b	(colFadeTable+1,pc,d4.w),d0	; 14

	move.w	#$00f,d3		; 8
	move.w	d3,d4			; 4
	and.w	d0,d3			; 4
	and.w	d1,d4			; 4
	sub.w	d3,d4			; 4
	asl.w	#4+1,d4			; 6+2*5=16
	add.w	d2,d4			; 4
	add.b	(colFadeTable,pc,d4.w),d0	; 14

	move.w	d0,d3			; 4
	clr.b	d3			; 4
	clr.b	d1			; 4
	sub.w	d3,d1			; 4
	asr.w	#8-(4+1),d1		; 6+2*3=12
	add.w	d2,d1			; 4
 	move.w	(colFadeTable,pc,d1.w),d1	; 14
 	clr.b	d1			; 4
 	add.w	d1,d0			; 4

	move.w	(a7)+,d4		; 8
	move.w	(a7)+,d3		; 8
	rts				; 16

colFadeTable	DS.W	31*16		; [-15..15]x[0..15]
