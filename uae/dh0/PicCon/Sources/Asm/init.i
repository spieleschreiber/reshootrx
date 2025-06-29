	include	includes.i
;------
start
	movem.l	d0-d7/a0-a6,-(a7)
	move.l	SysBase,a6
	lea	gfxname,a1
	jsr	OpenLibrary(a6)
	move.l	d0,gfxbase
	tst.l	d0
	bne.s	gfxbaseOK
	rts

gfxbaseOK
	move.l	#copper,$dff080
	move.w	#$0,$dff088

	move.w	#$20,$dff1dc
	move.w	#$0,$dff106

	lea     $dff000,a0
	move.w  intenar(a0),intbits
	move.w  dmaconr(a0),dmabits
	move.w  #$7fff,intena(a0)
	move.w  #$7fff,dmacon(a0)

	move.w  #DMA_SETCLR!DMA_COPPER!DMA_RASTER!DMA_MASTER,dmacon(a0)

	jsr	init

	moveq	#0,d0
mainloop
	btst	#$2,$dff016
	beq.s	freeze

	bsr	waitline
	bsr	waitnotline
	jsr	main

freeze	btst	#$6,$bfe001
	bne.s	mainloop

restore_all:
	move.l	gfxbase,a6
	move.l	38(a6),$dff080
	move.w	#0,$dff088
	move.l	SysBase,a6
	move.l	gfxbase,a1
	jsr	CloseLibrary(a6)

	or.w    #$8000,intbits
	or.w    #$8000,dmabits
	lea     $dff000,a0
	move.w  #$7fff,intena(a0)
	move.w  #$7fff,dmacon(a0)

	move.w  dmabits,dmacon(a0)
	move.w  intbits,intena(a0)
	movem.l	(a7)+,d0-d7/a0-a6
	rts
;------------------------------------------------------------------------------
waitline:
	move.l	$dff004,d1
	and.l	#$0001ff00,d1
	lsr.l	#8,d1
	cmp.w	d0,d1
	bne.s 	waitline
	rts
;------------------------------------------------------------------------------
waitnotline:
	move.l	$dff004,d1
	and.l	#$0001ff00,d1
	lsr.l	#8,d1
	cmp.w	d0,d1
	beq.s 	waitnotline
	rts
;------------------------------------------------------------------------------
intbits:	dc.w	0
dmabits:	dc.w	0
gfxbase:	dc.l	0
gfxname:	dc.b	'graphics.library',0
	even
;------------------------------------------------------------------------------
