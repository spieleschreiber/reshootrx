
crabAtak
	move.w objectListY(a2),d6
	add.w viewPosition+viewPositionPointer(pc),d6
	lsr #1,d6
	andi #$3<<3,d6
	lea (a0,d6.w),a0
    bra animReturn
