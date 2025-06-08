
	org $80000
	load $80000
t:
	move#-1,$dff02e
	move#%0100000000000000,$dff09a
	move#%1000011111110000,$dff096


	move.l 4,a6
	jsr -150(a6)
	move.l d0,savessp	;Supervisor-mode an
	move.l $6c,savessp+4
;jmp $f800d0
;reset
;jmp$f80250
move.l#coplist,$dff080
move#0,$dff088



mainendgame:
;tst.b $bfe001
;bmi mainendgame

	move#0,$dff02e
	move#$8040,$dff096
	lea intuition(pc),a1
	moveq#0,d0
	move.l 4,a6
	jsr -552(a6)


	move.l 38(a0),$dff080
	move#0,$dff088
	move.l a0,a1
	jsr -414(a6)		;Betr.system-Copperliste an
	move#$8040,$dff096


	move.l savessp,d0
	move.l 4,a6
	jsr -156(a6)		;supervisor-modus aus
	move#$8040,$dff096


	move.l savessp+4,$6c
	move#%1000001111110000,$dff096
	move#%1100000000100000,$dff09a
	illegal
savessp:
	dc.l 0,0
intuition:
	dc.b "graphics.library",0
even
coplist:
dc.w $3001,$fffe
dc.w $100,$2200
dc.w $e0,0,$e2,0,$e4,0,$e6,0,$e8,0,$ea,0,$ec,0,$ee,0
dc.w $180,$777,$182,$4444
;dc.w $1c0,%0000000011111111
;dc.w $1c8,$260

;dc.w $1dc,%0010001110100000
dc.w $ffff,$fffe

end









