;
;   copMacro.s
;
;
;   Created by Richard Löwenstein on 20.01.20.
;
;
;   {

CMOVE		Macro
		  dc.w		\1&$1fe,\2
		Endm
CMOVEL		Macro
		  dc.w		\1&$1fe,\2
          dc.w      (\1+2)&$1fe,\3
		Endm

CMOVELC		Macro
		  dc.w		\1&$1fe,0
          dc.w      (\1+2)&$1fe,0
		Endm
CWAIT		Macro
		  dc.w		\1!1
          ;dc.w -2
		  dc.w		-2	; Comp.-Enable-Mask
		Endm
CNOOP   MACRO
    CMOVE NOOP,0
        ENDM
CEND        Macro
		  dc.w		$ffff,$fffe
		Endm
	
