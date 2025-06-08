;//
;//  coplist.s
;//
;//
;//  Created by Richard Löwenstein on 22.06.15.
;//
;//

    SECTION coplist, DATA_C


coplist:
    cwait $0201

copSpriteDMA
    cmovelc $120,0
    cmovelc $124,0
    cmovelc $128,0
    cmovelc $12c,0
    cmovelc $130,0
    cmovelc $134,0
    cmovelc $138,0
    cmovelc $13c,0
    
    cwait $1c01
    dc.w $1fc,%0000000000001011  ;SHires-Sprites,

copPicGeom
    cmove $92,0
    cmove $94,0
    cmove $8e,0
    cmove $90,0
copBPLPTmain:
    cmovelc $e0     ;2 Register schreiben und mit 0 füllen
    cmovelc $e4
    cmovelc $e8
    cmovelc $ec
    cmovelc $f0
    cmovelc $f4
    cmovelc $f8
    cmovelc $fc


copBPL2MOD  cmove $10a,0
copBPL1MOD  cmove $108,0
copBPLCON0  cmove $100,0
copBPLCON1  cmove $102,0
copBPLCON2  cmove $104,%0000000
    cmove $1fe,0
    cend
  ;  dc.w $e001, $fffe

; Achtung: Sprung innert Copperlist mti $88,0, Ende einer Copperliste mit dc.w $ffff, $fffe

	dc.w $80
copsprInitHW:
    dc.w    0,$82
copsprInitLW:
    dc.w    0, $88,0


copendlist:

    dc.w $ffdf,$fffe, $2001,$fffe

;	dc.w $ffe1,-1,$ffe1,-2
;    dc.w $00e1,-1,$00e1,-2
;	dc.w $0301,-2,$100,0
;	dc.w $1001,-2
;    dc.w $ffff, $fffe
;	dc.w $9c,%1000000000010000


	dc.w    $80
copreturnHW:
    dc.w    0,$82
copreturnLW:
    dc.w    0
	dc.w $ffff, $fffe



copsprdbl:
copl1:
	dc.w    $f0df,$ff00,$80
copl1HW:
    dc.w    0,$82
copl1LW:
    dc.w    0,$88,0

copl2:
	dc.w    $f1df,$ff00,$80
copl2HW:
    dc.w    0,$82
copl2LW:
    dc.w    0,$88,0

copl3:
	dc.w    $f2df,$FF00,$80
copl3HW:
    dc.w    0,$82
copl3LW:
    dc.w    0,$88,0

copl4:
	dc.w    $f3df,$ff00,$80
copl4HW:
    dc.w    0,$82
copl4LW:
    dc.w    0,$88,0

copl5:
	dc.w    $f4df,$ff00,$80
copl5HW:
    dc.w    0,$82
copl5LW:
    dc.w    0,$88,0


copr1:
	dc.w    $e4,1,$e6,0,$ec,1,$ee,0,$f4,1,$f6,0,$102
copr1SCR:
    dc.w $f00
    dc.w $180,$777
	dc.w    $80
copr1HW:
    dc.w    0,$82
copr1LW:
    dc.w    0,$88,0

copr2:
	dc.w    $e4,6,$e6,$0,$ec,2,$ee,$4020,$f4,2,$f6,0,$102
copr2SCR:
    dc.w $c00,$192,$48f
    dc.w $180,$999
    	dc.w    $80
copr2HW:
    dc.w    0,$82
copr2LW:
    dc.w    0,$88,0

copr3:
	dc.w    $e4,6,$e6,$0,$ec,2,$ee,0,$f4,2,$f6,0,$102
copr3SCR:
    dc.w $c00,$192,$14e
	dc.w $180,$aaa
    dc.w    $80
copr3HW:
    dc.w    0,$82
copr3LW:
    dc.w    0,$88,0

copr4:
	dc.w    $e4,6,$e6,$0,$ec,2,$ee,0,$f4,2,$f6,0,$102
copr4SCR:
    dc.w $c00,$192,$008
    dc.w $180,$bbb
	dc.w    $80
copr4HW:
    dc.w    0,$82
copr4LW:
    dc.w    0,$88,0



;cply2:
;dc.l $a001fffe,$1809999
;dc.w $800003,$82,cmply1,$88,0

;df=cmply1
copcolscor:
;copdispscore:
;copcolscor:
;dc.w $100,$3000
;dc.w $182,$411
;dc.w $184,$211
;dc.w $186,$131
;dc.w $188,$311
;dc.w $18a,$201
;dc.w $18c,$131
;dc.w $18e,$333
	;dc.w$1a0,0,$1a2,0,$1a4,0,$1a6,0,$1a8,0,$1aa,0,$1ac,0,$1ae,0
	;dc.w$1b0,0,$1b2,0,$1b4,0,$1b6,0,$1b8,0,$1ba,0,$1bc,0,$1be,0

	;dc.w $120,4,$122,$8010,$140,$f750,$142,$ff00
;	dc.w $124,4,$126,$8010,$148,$f758,$14a,$ff00
;	dc.w $128,4,$12a,$8010,$150,$f760,$152,$ff00
;	dc.w $12c,4,$12e,$8010,$158,$f768,$15a,$ff00
;	dc.w $130,4,$132,$8010,$160,$f770,$162,$ff00
;	dc.w $134,4,$136,$8010,$168,$f778,$16a,$ff00

	;dc.w $ffe1,-2
	;dc.w $0301,-2,$100,0
	;dc.w $1001,-2

;	dc.w $9c,%1000000000010000
	dc.w $ffff,$fffe