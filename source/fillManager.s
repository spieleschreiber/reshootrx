
	INCLUDE blit.i

    ;!!!: Animcode: code called from each frame update. Usually used for bitmap animation, but can do other things too
    ;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter bitmap load adress or use a0 if return to bobblitnext / not animreturn

showBlitWinMarkers	SET	0	; 1 = plot blitwindow markers
lineClipUp			SET		0
lineClipDown		SET		255
lineClipRgt			SET		281
lineClipLft			SET		1
modLine	SET	4*40


fillManager

		;	#MARK: - main controller
		lea polyVars(pc),a6
		move.l mainPlanesPointer+0(pc),a4
		lea	CUSTOM,a5
		clr.l d0
		move.w polyBlitAddr+4(a6),d0
		clr.w d1
		move.l polyBlitAddr(a6),polyBlitAddr+2(a6)
		tst.w d0
		bne .clearBlit
	;MSG03 m2,d4
.clearBlitRet
	tst.l xA1(a6)
	beq .quit	; set to #-1 in Resetcode@px
		;move.l mainPlanesPointer+0(pc),a0
	;move.w frameCount+2,d4

	move.w #255<<4,yMin(a6)
	move.w #1,yMax(a6)
	move.w #420<<4,xMin(a6)
	move.w #1,xMax(a6)		; reset

	move.l polyBlitsize+0(a6),polyBlitsize+2(a6)
	clr.w polyBlitsize(a6)
	bsr	.drawOutlines

	IFNE 1
	move.w xMax(a6),d0
	sub.w xMin(a6),d0
	lsr #8,d0
	add #4,d0	; blitsize width
	ENDIF

	move.w yMax(a6),d1
	sub.w yMin(a6),d1
	asr #4,d1
	bmi .noFill
	add.w #1,d1
	lsl #6,d1
	or.b d0,d1
	move.w d1,polyBlitsize(a6)	; blitsize

	move.w xMin(a6),d0
	lsr #4,d0
	lsr #3,d0
	sub #1,d0
	spl d1
	ext.w d1
	and.w d1,d0
	bclr #0,d0
	move.w d0,xMin(a6)	; x-word-offset address

	move.w yMin(a6),d0
	lsr #4,d0
	sub.b #4,d0	; define y-space above filled area
	scc d7
	and.w d7,d0
	move.w AddressOfYPosTable(pc,d0.w*2),d0	; muls 40*4
	move.w d0,yMin(a6)	; y-height

	tst.w polyBlitAddr(a6)
	beq .avoidFillGlitch
	bsr	.areaFill
.avoidFillGlitch

	clr.l d1
	move.w	xMin(a6),d1
	add.w yMin(a6),d1

.noFill
	IFNE showBlitWinMarkers
		move.l fkThis(a6),a0
		tst.l a0
		beq .skip
		clr.b (a0)
.skip
		move.l mainPlanesPointer+4(pc),a0
		lea mainPlaneWidth*2(a0),a0
		adda.w polyBlitAddr+4(a6),a0
		lea 80(a0),a0
		move.l a0,fkThis(a6)
		move.b #-1,(a0)
	ENDIF
.quit
	move.w d1,polyBlitAddr(a6)
	clr.l xA1(a6)	; make sure that fillManager stops working if object is killed
	clr.l xC1(a6)	; make sure that fillManager stops working if object is killed
	rts


	;	#MARK: - draw lines main
.drawOutlines
		lea polyVars,a1
		move.l	a4,a2
		movem.l xA1(a1),d0/d2
		;MSG01 m2,d0
		move.w d0,d1
		swap d0
		move.w d2,d3
		swap d2
		move.l a2,a0
		bsr	fillDrawLine

		movem.l xB1(a1),d0/d2
		move.w d0,d1
		beq .skipBLine
		swap d0
		move.w d2,d3
		swap d2
		move.l a2,a0
		bsr	fillDrawLine
.skipBLine
		movem.l xC1(a1),d0/d2
		move.w d0,d1
		beq .skipCLine
		swap d0
		move.w d2,d3
		swap d2
		move.l a2,a0
		bsr	fillDrawLine

.skipCLine
		movem.l xD1(a1),d0/d2
		move.w d0,d1
		beq .skipDLine
		swap d0
		move.w d2,d3
		swap d2
		move.l a2,a0
		bsr	fillDrawLine
.skipDLine
		rts


				    ;	#MARK: - clear area blitter 

.clearBlit
		lea (a4,d0.l),a3
		move.w polyBlitsize+4(a6),d2
		beq .zeroBlitQuit
.yAdd	SET 2
.retCheck
		add.w #.yAdd<<6,d2
		lea 40*4*.yAdd(a3),a3
		move.w d2,d4
		andi #%111111,d4
		move #40*4,d3
		lsl #1,d4
		sub.w d4,d3
		WAITBLIT
		move.l	a3,BLTDPT(a5)
		move.b d2,d5
		andi.w #%111111,d5
		lsl #1,d5
		move.w #40,d4
		sub.w d5,d4
		add.w #40*3,d4
		move.w d4,BLTDMOD(a5)

		move	#DEST,BLTCON0(a5)
		clr	BLTCON1(a5)
		move	d2,BLTSIZE(a5)
.zeroBlitQuit
		bra .clearBlitRet
		    ;	#MARK: - fill area blitter
.areaFill
		WAITBLIT
		move.l	a4,d0
	;move.l a0,d0
		;lea mainPlaneWidth*2(a4),a3
		move.l a3,d7
		clr.l d1
		move.w	xMax(a1),d1
		lsr #4,d1
		lsr #3,d1
		add.w #2,d1
		;MSg01 m2,d1
		clr.l d3
		move.w yMax(a1),d3
		;add #1,d3
		lsr #4,d3
		move.w AddressOfYPosTable(pc,d3.w*2),d3	; muls 40*4
		add.w d3,d1

		add.l d1,d0
		add.l d1,d7
		;add.l #2,d0
		;add.l #4*40*20,d0
		move.w polyBlitsize+0(a1),d2
		;MSG01 m2,d2
		tst.w d2
		beq .zero
.xSize	SET 6 ;words	10 = 20
		move.l d0,a0
;		move.l #-1,(a0)+
;		move.l #-1,(a0)+
		move.l	d0,BLTAPT(a5)
		move.l	d0,BLTDPT(a5)
		moveq.l	#-1,d0
		move.l	d0,BLTAFWM(a5)
		;move	d3,BLTAMOD(a5)
		;move	d3,BLTDMOD(a5)

		move.b d2,d5
		andi.w #%111111,d5
		lsl #1,d5
		move.w #40,d4
		sub.w d5,d4
		add.w #40*3,d4
		;MSG02 m2,d4
		move.w d4,BLTDMOD(a5)
		move.w d4,BLTAMOD(a5)

		move	#SRCA+DEST+$F0,BLTCON0(a5)
		move	#BLITREVERSE+FILL_OR,BLTCON1(a5)
		move	d2,BLTSIZE(a5)
.zero
		rts

			;	#MARK: - vars / sin table 


angle_z:	dc.w	0
polyVars
screenSpaceCoords
	RSRESET	0
xA1	rs.w 	1
yA1	rs.w	1
xA2	rs.w 	1
yA2	rs.w	1
xB1	rs.w 	1
yB1	rs.w	1
xB2	rs.w 	1
yB2	rs.w	1
xC1	rs.w 	1
yC1	rs.w	1
xC2	rs.w 	1
yC2	rs.w	1
xD1	rs.w 	1
yD1	rs.w	1
xD2	rs.w 	1
yD2	rs.w	1
yMin	rs.w 1
yMax	rs.w 1
xMin	rs.w 1
xMax	rs.w 1
polyBlitsize		rs.w 3
polyBlitAddr		rs.w 3

	IFNE	showBlitWinMarkers
fkThis				rs.l	1
	ENDIF

ssQ							rs.w 1
		blk.w 	ssQ/2	; space for Blitwindow X- and Y-Min/Max-coords and Blitsize



	    ;	#MARK: - draw single line blitter
	    ; 	CUSTOM	-> a5
	    ;	x1,y1,x2,y2 -> d0,d1,d2,d3
fillDrawLine

		clr.l d5
		cmp	d1,d3		; y2 - y1
		bgt	.is_down
		exg	d0,d2
		exg	d1,d3
.is_down:
		cmpi.w #lineClipUp<<4,d1
		blt .lineClipTop

		cmpi.w #lineClipDown<<4,d3
		bgt .lineClipFloor
.returnClip
		cmpi.w #lineClipRgt<<4,d0
		bgt .lineClipRgtA
		cmpi.w #lineClipRgt<<4,d2
		bgt .lineClipRgtB
.fff
		cmpi.w #lineClipLft<<4,d2
		blt .lineClipLftB
.ggg

	cmp.w yMin(a6),d1
	blt	.YisSmaller
.returnYMin
	cmp.w yMax(a6),d3
	bgt .YisHigher
.returnYMax
	cmp.w xMin(a6),d0
	blt	.XisSmallerD0
.returnXMinD0
	cmp.w xMin(a6),d2
	blt .XisSmallerD2
.returnXMinD2
	cmp.w xMax(a6),d0
	bgt	.XisHigherD0
.returnXMaxD0
	cmp.w xMax(a6),d2
	bgt .XisHigherD2
.returnXMaxD2
		move	d2,d4
		move	d3,d5

		sub	d1,d5		; d5 = dy
		sub	d0,d4		; d4 = dx
	tst.w d4
		bmi	.oct_3_4

		cmp	d5,d4		; dx - dy
		bmi	.oct_2

.oct_1:

		move	d1,d4		; d4 = y1
		move	d3,d7		; d7 = y2

		sub	d1,d3		; d3 = dy

		add	#1<<4,d4
		and	#$fff0,d4	; d4 = ^y1 = floor(y1+1) - first row with pixel lit
		and	#$fff0,d7	; d7 = ^y2 = floor(y2)   - last row with pixel lit

		cmp	d4,d7		; ^y2 - ^y1
		bmi	.done

		move	d4,d6		; d6 = ^y1
		lsr	#4,d6
		mulu	#modLine,d6		; d6 = (^y1 in 16.0)*40
		add.l	d6,a0		; a0 = first byte in row

		sub	d1,d4		; d4 = ^y1 - y1
		sub	d1,d7		; d7 = ^y2 - y1

		sub	d0,d2		; d2 = dx

		move	d4,d6		; d6 = ^y1 - y1
		muls	d2,d6		; d6 = (^y1 - y1)*dx
		divs	d3,d6		; d6 = (^y1 - y1)*dx/dy
		add	d0,d6		; d6 = x1 + (^y1 - y1)*dx/dy
		and	#$fff0,d6	; d6 = ^x1 = floor(x1 + (^y1 - y1)*dx/dy)
		ext.l d6
		muls	d2,d7		; d7 = (^y2 - y1)*dx
		divs	d3,d7		; d7 = (^y2 - y1)*dx/dy
		add	d0,d7		; d7 = x1 + (^y2 - y1)*dx/dy
		and	#$fff0,d7	; d7 = ^x2 = floor(x1 + (^y2 - y1)*dx/dy)

		sub	d6,d7		; d7 = ^dx = ^x2 - ^x1
		lsl	#2,d7
		add	#$42,d7		; d7 = bltsize = (^dx+1)<<6 | 2

		sub	d6,d0		; d0 = x1 - ^x1
		neg	d0		; d0 = ^x1 - x1

		lsr	#4,d6		; d6 = ^x1 in 16.0
		move	d6,d5		; d5 = ^x1 in 16.0

		lsr	#3,d6		; number of bytes into this row
		;and	#$fffe,d6	; align to word - not necessary, the hardware does it automatically
		add.l	d6,a0		; a0 = word containing first pixel

		and	#$f,d5
		ror	#4,d5
		or	#$b4a,d5	; d5 = bltcon0

		add	#2<<4,d0	; d0 = (^x1 - x1) + 2
		muls	d3,d0		; d0 = ((^x1 - x1) + 2)*dy in 24.8

		add	#1<<4,d4	; d4 = (^y1 - y1) + 1
		muls	d2,d4		; d4 = ((^y1 - y1) + 1)*dx in 24.8

		sub.l	d4,d0		; d0 = ((^x1 - x1) + 2)*dy - ((^y1 - y1) + 1)*dx in 24.8

		add.l	#15,d0		; round to ceil
		asr.l	#4,d0		; d0 = ((^x1 - x1) + 2)*dy - ((^y1 - y1) + 1)*dx in 28.4
		sub.l	#1,d0

		add.l	d0,d0
		add	d2,d2
		add	d3,d3

		moveq	#OCTANT1,d6	; d6 = bltcon1
		bra	.wr_regs
.YisSmaller
	move.w d1,yMin(a6)
	bra .returnYMin
.YisHigher
	move.w d3,yMax(a6)
	bra .returnYMax
.XisSmallerD0
	move.w d0,xMin(a6)
	bra .returnXMinD0
.XisSmallerD2
	move.w d2,xMin(a6)
	bra .returnXMinD2
.XisHigherD0
	move.w d0,xMax(a6)
	bra .returnXMaxD0
.XisHigherD2
	move.w d2,xMax(a6)
	bra .returnXMaxD2


.oct_2:

		move	d1,d4		; d4 = y1
		move	d3,d7		; d7 = y2

		sub	d1,d3		; d3 = dy

		add	#1<<4,d4
		and	#$fff0,d4	; d4 = ^y1 = floor(y1+1) - first row with pixel lit
		and	#$fff0,d7	; d7 = ^y2 = floor(y2)   - last row with pixel lit

		sub	d4,d7		; d7 = ^dy = ^y2 - ^y1
		bmi	.done

		lsl	#2,d7
		add	#$42,d7		; d7 = bltsize = (^dy+1)<<6 | 2

		move	d4,d6		; d6 = ^y1
		lsr	#4,d6
		mulu	#modLine,d6		; d6 = (^y1 in 16.0)*40
		add.l	d6,a0		; a0 = first byte in row

		sub	d1,d4		; d4 = ^y1 - y1

		sub	d0,d2		; d2 = dx

		move	d4,d6		; d6 = ^y1 - y1
		muls	d2,d6		; d6 = (^y1 - y1)*dx
		divs	d3,d6		; d6 = (^y1 - y1)*dx/dy
		add	d0,d6		; d6 = x1 + (^y1 - y1)*dx/dy
		and.w	#$fff0,d6	; d6 = ^x1 = floor(x1 + (^y1 - y1)*dx/dy)

		sub	d6,d0		; d0 = x1 - ^x1
		neg	d0		; d0 = ^x1 - x1

		lsr	#4,d6		; d6 = ^x1 in 16.0
		move	d6,d5		; d5 = ^x1 in 16.0

		lsr	#3,d6		; number of bytes into this row
		;and	#$fffe,d6	; align to word - not necessary, the hardware does it automatically
		lea (a0,d6.w),a0		; a0 = word containing first pixel

		and	#$f,d5
		ror	#4,d5
		or	#$b4a,d5	; d5 = bltcon0

		add	#1<<4,d4	; d4 = ^y1 - y1 + 1
		muls	d2,d4		; d4 = (^y1 - y1 + 1)*dx in 24.8

		add	#1<<4,d0	; d0 = ^x1 - x1 + 1
		muls	d3,d0		; d0 = (^x1 - x1 + 1)*dy in 24.8

		sub.l	d0,d4		; d4 = (^y1 - y1 + 1)*dx - (^x1 - x1 + 1)*dy in 24.8
		move.l	d4,d0		; d0 = (^y1 - y1 + 1)*dx - (^x1 - x1 + 1)*dy in 24.8

		add.l	#15,d0		; round to ceil
		asr.l	#4,d0		; d0 = (^y1 - y1 + 1)*dx - (^x1 - x1 + 1)*dy in 24.8

		exg	d2,d3

		add.l	d0,d0
		add	d2,d2
		add	d3,d3

		moveq	#OCTANT2,d6	; d6 = bltcon1
		bra	.wr_regs

.oct_3_4:

		neg	d4		; d4 = abs(dx)
		cmp	d5,d4		; abs(dx) - abs(dy)
		bmi	.oct_3

.oct_4:
		move	d1,d4		; d4 = y1
		move	d3,d7		; d7 = y2

		sub	d1,d3		; d3 = dy

		add	#1<<4,d4
		and	#$fff0,d4	; d4 = ^y1 = floor(y1+1) - first row with pixel lit
		and	#$fff0,d7	; d7 = ^y2 = floor(y2)   - last row with pixel lit

		cmp	d4,d7		; ^y2 - ^y1
		bmi	.done

		move	d4,d6		; d6 = ^y1
		lsr	#4,d6
		mulu	#modLine,d6		; d6 = (^y1 in 16.0)*40
		add.l	d6,a0		; a0 = first byte in row

		sub	d1,d4		; d4 = ^y1 - y1
		sub	d1,d7		; d7 = ^y2 - y1

		sub	d0,d2		; d2 = dx

		move	d4,d6		; d6 = ^y1 - y1
		muls	d2,d6		; d6 = (^y1 - y1)*dx

		ext.l	d3
		sub.l	d3,d6		; make div round to floor
		add.l	#1,d6

		divs	d3,d6		; d6 = (^y1 - y1)*dx/dy
		add	d0,d6		; d6 = x1 + (^y1 - y1)*dx/dy
		and	#$fff0,d6	; d6 = ^x1 = floor(x1 + (^y1 - y1)*dx/dy)
		;ext.l d6
		muls	d2,d7		; d7 = (^y2 - y1)*dx

		sub.l	d3,d7		; make div round to floor
		add.l	#1,d7

		divs	d3,d7		; d7 = (^y2 - y1)*dx/dy
		add	d0,d7		; d7 = x1 + (^y2 - y1)*dx/dy
		and	#$fff0,d7	; d7 = ^x2 = floor(x1 + (^y2 - y1)*dx/dy)

		sub	d6,d7		; d7 = ^dx = ^x2 - ^x1
		neg	d7
		lsl	#2,d7
		add	#$42,d7		; d7 = bltsize = (^dx+1)<<6 | 2

		sub	d6,d0		; d0 = x1 - ^x1
		neg	d0		; d0 = ^x1 - x1

		lsr	#4,d6		; d6 = ^x1 in 16.0
		move	d6,d5		; d5 = ^x1 in 16.0

		lsr	#3,d6		; number of bytes into this row
		;and	#$fffe,d6	; align to word - not necessary, the hardware does it automatically
		lea (a0,d6.w),a0		; a0 = word containing first pixel

		and	#$f,d5
		ror	#4,d5
		or	#$b4a,d5	; d5 = bltcon0

		sub	#1<<4,d0	; d0 = (^x1 - x1) - 1
		muls	d3,d0		; d0 = ((^x1 - x1) + 1)*dy in 24.8

		add	#1<<4,d4	; d4 = (^y1 - y1) + 1
		muls	d2,d4		; d4 = ((^y1 - y1) + 1)*dx in 24.8

		sub.l	d0,d4		; d4 = ((^y1 - y1) + 1)*dx - ((^x1 - x1) - 1)*dy in 24.8
		move.l	d4,d0		; d0 = ((^y1 - y1) + 1)*dx - ((^x1 - x1) - 1)*dy in 24.8

		add.l	#15,d0		; round to ceil
		asr.l	#4,d0		; d0 = ((^y1 - y1) + 1)*dx - ((^x1 - x1) - 1)*dy in 28.4

		neg	d2

		add.l	d0,d0
		add	d2,d2
		add	d3,d3

		moveq	#OCTANT4,d6	; d6 = bltcon1
		bra	.wr_regs

.oct_3:
		move	d1,d4		; d4 = y1
		move	d3,d7		; d7 = y2

		sub	d1,d3		; d3 = dy

		add	#1<<4,d4
		and	#$fff0,d4	; d4 = ^y1 = floor(y1+1) - first row with pixel lit
		and	#$fff0,d7	; d7 = ^y2 = floor(y2)   - last row with pixel lit

		sub	d4,d7		; d7 = ^dy = ^y2 - ^y1
		bmi	.done

		lsl	#2,d7
		add	#$42,d7		; d7 = bltsize = (^dy+1)<<6 | 2

		move	d4,d6		; d6 = ^y1
		lsr	#4,d6
		mulu	#modLine,d6		; d6 = (^y1 in 16.0)*40
		add.l	d6,a0		; a0 = first byte in row

		sub	d1,d4		; d4 = ^y1 - y1

		sub	d0,d2		; d2 = dx

		move	d4,d6		; d6 = ^y1 - y1
		muls	d2,d6		; d6 = (^y1 - y1)*dx

		ext.l	d3
		sub.l	d3,d6		; make div round to floor
		add.l	#1,d6

		divs	d3,d6		; d6 = (^y1 - y1)*dx/dy
		add	d0,d6		; d6 = x1 + (^y1 - y1)*dx/dy
		and	#$fff0,d6	; d6 = ^x1 = floor(x1 + (^y1 - y1)*dx/dy)
;		ext.l d6
		sub	d6,d0		; d0 = x1 - ^x1
		neg	d0		; d0 = ^x1 - x1

		lsr	#4,d6		; d6 = ^x1 in 16.0
		move	d6,d5		; d5 = ^x1 in 16.0

		lsr	#3,d6		; number of bytes into this row
		;and	#$fffe,d6	; align to word - not necessary, the hardware does it automatically
		lea (a0,d6.w),a0		; a0 = word containing first pixel

		and	#$f,d5
		ror	#4,d5
		or	#$b4a,d5	; d5 = bltcon0

		muls	d3,d0		; d0 = (^x1 - x1)*dy in 24.8

		add	#1<<4,d4	; d4 = ^y1 - y1 + 1
		muls	d2,d4		; d4 = (^y1 - y1 + 1)*dx in 24.8

		sub.l	d4,d0		; d0 = (^x1 - x1)*dy - (^y1 - y1 + 1)*dx in 24.8

		add.l	#15,d0		; round to ceil
		asr.l	#4,d0		; d0 = (^x1 - x1)*dy - (^y1 - y1 + 1)*dx in 24.8
		sub.l	#1,d0

		neg	d2
		exg	d2,d3

		add.l	d0,d0
		add	d2,d2
		add	d3,d3

		moveq	#OCTANT3,d6	; d6 = bltcon1
		;bra	.wr_regs

.wr_regs:
		;or	#LINEMODE,d6
		or	#LINEMODE+ONEDOT,d6

		WAITBLIT
		move	d3,BLTBMOD(a5)	; bltbmod = dy

		move.l	d0,BLTAPT(a5)
		smi d0
		andi.b #SIGNFLAG,d0
		or.b d0,d6

		sub	d2,d3		; d3 = dy - dx
		move	d3,BLTAMOD(a5)	; bltamod = dy - dx
		move	#modLine,BLTCMOD(a5)
		move	#modLine,BLTDMOD(a5)

		move	#$8000,BLTADAT(a5)
		move	#$ffff,BLTBDAT(a5)
		moveq.l	#-1,d0
		move.l	d0,BLTAFWM(a5)

		move.l	a0,BLTCPT(a5)
		move.l	a0,BLTDPT(a5)

		move	d5,BLTCON0(a5)
		move	d6,BLTCON1(a5)
		move	d7,BLTSIZE(a5)
.done
		rts

.lineClipRgtA
		sub #lineClipRgt<<4,d0
		sub.w d0,d1
		SAVEREGISTERS
		move #lineClipRgt<<4,d0
		move.w d0,d2
		move #lineClipDown<<4,d3
		bsr fillDrawLine
		RESTOREREGISTERS
		move #lineClipRgt<<4,d0
		bra fillDrawLine

		bra .fff
.lineClipRgtB
	move.w d2,d6
	sub.w #lineClipRgt<<4,d6	;
	sub.w d6,d3

	SAVEREGISTERS
	move #lineClipRgt<<4,d0
	move.w d0,d2
	move #lineClipDown<<4,d1
	bsr fillDrawLine
	RESTOREREGISTERS
	move #lineClipRgt<<4,d2	; static y-position
	bra fillDrawLine



		sub #lineClipRgt<<4,d2
		sub.w d2,d3
		SAVEREGISTERS
		move #lineClipRgt<<4,d0
		move.w d0,d2
		move #lineClipDown<<4,d1
		bsr fillDrawLine
		RESTOREREGISTERS
		move #lineClipRgt<<4,d2
		bra .fff
.lineClipLftB
		move #lineClipLft<<4,d6	;
		sub.w d2,d6
		sub.w d6,d3

		asr #5,d6
		asr #3,d6
		add #90,d6
;		MSG02 m2,d6
;		tst.b d6
;		bpl .sksl
;		move #127,d6
;.sksl
		andi #$7f,d6
		move.b sineTable(pc,d6.w),d6
		lsl #4,d6
		sub.w d6,d3

		SAVEREGISTERS
		move #lineClipLft<<4,d0
		move.w d0,d2
		move #lineClipDown<<4,d1
		;bsr polyLine
		RESTOREREGISTERS
		;lsr #1,d3
		;MSG01 m2,d3
		move #lineClipLft<<4,d2	; static x-position
		bra fillDrawLine

.lineClipTop
		move #lineClipUp<<4,d6	;
		sub d1,d6
		move d0,d5
		sub d2,d5	; xd=x2-x1
		smi d4
		ext.w d4	; if negative -> invert xd
		eor.w d4,d5
		sub d3,d1
		neg d1	yd=y2-y1
		lsr #4,d1
		beq .done
		divu d1,d5	; xd/yd
		muls d5,d6
		lsr #4,d6
		eor.w d4,d6	; if xd negative-> invert x-offset
		sub d6,d0
		move #lineClipUp<<4,d1	; static y-position
.skipDrawTst
		cmp d1,d3
		bgt .returnClip			; 	draw line
		rts						; 	do not draw line
.lineClipFloor
		move d3,d6
		sub #lineClipDown<<4,d6	;

		move d0,d5
		sub d2,d5	; xd=x2-x1
		smi d4
		ext.w d4	; if negative -> invert xd
		eor.w d4,d5
		sub d1,d3	; yd=y2-y1
		lsr #4,d3
		;lsl #4,d5
		beq .done
		divu d3,d5	; xd/yd
		muls d5,d6
		lsr #4,d6
		eor.w d4,d6	; if xd negative-> invert x-offset
		add d6,d2
		move #lineClipDown<<4,d3	; static y-position
		bra .skipDrawTst


	IFNE 1
; table created using this tool https://www.daycounter.com/Calculators/Sine-Generator-Calculator.phtml
;	512 points, 3276 max amplitue, 512 numbers per row 
sin_tab:
	dc.w 16384,16585,16786,16987,17188,17389,17589,17790,17990,18190,18390,18589,18788,18987,19185,19383,19580,19777,19974,20170,20365,20560,20754,20947,21140,21332,21523,21714,21904,22092,22281,22468,22654,22839,23023,23207,23389,23570,23750,23929,24107,24284,24460,24634,24807,24979,25149,25319,25486,25653,25818,25982,26144,26305,26464,26622,26778,26933,27086,27237,27387,27535,27681,27826,27969,28111,28250,28388,28524,28658,28790,28921,29049,29176,29300,29423,29544,29663,29779,29894,30007,30117,30226,30333,30437,30539,30640,30738,30833,30927,31019,31108,31195,31280,31362,31443,31521,31597,31670,31741,31810,31877,31941,32003,32063,32120,32175,32227,32277,32325,32370,32413,32453,32491,32527,32560,32591,32619,32645,32668,32689,32708,32724,32737,32748,32757,32763,32767,32768,32767,32763,32757,32748,32737,32724,32708,32689,32668,32645,32619,32591,32560,32527,32491,32453,32413,32370,32325,32277,32227,32175,32120,32063,32003,31941,31877,31810,31741,31670,31597,31521,31443,31362,31280,31195,31108,31019,30927,30833,30738,30640,30539,30437,30333,30226,30117,30007,29894,29779,29663,29544,29423,29300,29176,29049,28921,28790,28658,28524,28388,28250,28111,27969,27826,27681,27535,27387,27237,27086,26933,26778,26622,26464,26305,26144,25982,25818,25653,25486,25319,25149,24979,24807,24634,24460,24284,24107,23929,23750,23570,23389,23207,23023,22839,22654,22468,22281,22092,21904,21714,21523,21332,21140,20947,20754,20560,20365,20170,19974,19777,19580,19383,19185,18987,18788,18589,18390,18190,17990,17790,17589,17389,17188,16987,16786,16585,16384,16183,15982,15781,15580,15379,15179,14978,14778,14578,14378,14179,13980,13781,13583,13385,13188,12991,12794,12598,12403,12208,12014,11821,11628,11436,11245,11054,10864,10676,10487,10300,10114,9929,9745,9561,9379,9198,9018,8839,8661,8484,8308,8134,7961,7789,7619,7449,7282,7115,6950,6786,6624,6463,6304,6146,5990,5835,5682,5531,5381,5233,5087,4942,4799,4657,4518,4380,4244,4110,3978,3847,3719,3592,3468,3345,3224,3105,2989,2874,2761,2651,2542,2435,2331,2229,2128,2030,1935,1841,1749,1660,1573,1488,1406,1325,1247,1171,1098,1027,958,891,827,765,705,648,593,541,491,443,398,355,315,277,241,208,177,149,123,100,79,60,44,31,20,11,5,1,0,1,5,11,20,31,44,60,79,100,123,149,177,208,241,277,315,355,398,443,491,541,593,648,705,765,827,891,958,1027,1098,1171,1247,1325,1406,1488,1573,1660,1749,1841,1935,2030,2128,2229,2331,2435,2542,2651,2761,2874,2989,3105,3224,3345,3468,3592,3719,3847,3978,4110,4244,4380,4518,4657,4799,4942,5087,5233,5381,5531,5682,5835,5990,6146,6304,6463,6624,6786,6950,7115,7282,7449,7619,7789,7961,8134,8308,8484,8661,8839,9018,9198,9379,9561,9745,9929,10114,10300,10487,10676,10864,11054,11245,11436,11628,11821,12014,12208,12403,12598,12794,12991,13188,13385,13583,13781,13980,14179,14378,14578,14778,14978,15179,15379,15580,15781,15982,16183,16384
	ENDIF

