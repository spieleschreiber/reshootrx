
	
	;	#MARK: Invader explosions
expl_lrg
	move.b objectListCnt(a2),d6
	lsl #1,d6
	not d6
	andi #$7<<3,d6
	lea (a0,d6.w),a0
	bra animReturn
expl_med
    move.b objectListCnt(a2),d6
    not d6
	andi #$7<<2,d6
	lea (a0,d6.w),a0
    bra animReturn
expl_sml
    move.b objectListCnt(a2),d6
    lsr #1,d6
    not d6
	andi #$7<<1,d6
	lea (a0,d6.w),a0
    bra animReturn
