
dstrEvnt			; set destruction event
	move.w #destroyBase-bobCodeCases-16,d0
	sub.w d0,d4
	lsr #4,d4	; calc entry number
	move.b d4,objectListDestroy(a6)
	jmp (a5)
