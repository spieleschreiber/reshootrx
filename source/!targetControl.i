;//
;//  targetControl.s
;//  px
;//
;//  Created by Richard Löwenstein on 19.08.19.
;//  Copyright © 2019 spieleschreiber. All rights reserved.
;//


;           *******************
;           *** assemble values
;           *******************

;Check values for RELEASE CANDID∑TE: DEBUG=0, RELEASE=1, RASTERLINE=0, PLAYERCOLL=0, DIFF=0, COMPATIBILITY=2

DEVBUILD			SET		1
RELEASETEST			SET		0
RELEASECANDIDATE	SET		0

SHOWframeCount	=	1
SHOWFRAMERATE	=	1
SHOWGLOBALFLAGS	=	0

    IFNE DEVBUILD

SCORE_OVERRIDE	=	0; 1403030;	set to >0 to simulate score entry. Will be +1
HIGHSCORE_OVERRIDE	=	$00000;	set to >0 to simulate highscore entry
HISCORETABLEDEFAULT	=	1; 1=restore default highscore table at game init. ATTN: Overwrites stored highscore-table in case of highscore entry!
OBJECTSCORETEST	=	0	; if true, single hits and wave will not score=+1, score=+50, therefore facilitate checking true object scores


DEMOBUILD	SET			0	; -> 0 full game, 1 demo version

	IFEQ DEMOBUILD
						; *** Full Game Settings ***

INITWITH 	SET	 		00	;  20=intro, 30=title. 00 -> Initlevel defined in levelGetter.s
SHOWOBJECTNO	SET		1
PLAYERCOLL		SET		0;       -> 1 = player is hitable
DIFF_OVERRIDE	SET		0;         -> 1 = start with lower difficulty, 2 = start with higher dif
ALERTHANDLING	SET		1	  ; 1->show alerts onscreen
SHELLHANDLING	SET		1	; 1-> send msg to shell. ATTN: Emu only!
SHELLMEMORY		SET		0	; 1-> send mem allocs to shell


	ELSE
						; *** Demo-Settings ***

INITWITH 		SET	20	;;  20=intro, 30=title, 00 -> Initlevel
SHOWOBJECTNO	SET	0
PLAYERCOLL		SET	1
DIFF_OVERRIDE	SET	0
ALERTHANDLING	SET	0
SHELLHANDLING	SET	1
SHELLMEMORY		SET	0

	ENDIF

						; *** Shared Settings ***

AUDIOSFXONLY		SET		0	; set both true to kill audio entirely
AUDIOMUSICONLY	SET		0
DEBUG=0; -> 1 -> activate a number of checks and counters for debugging
DEBUGSPRITEPOSMEM	=	0	; display spritePosMem numbers, needs DEBUG=1
DEBUGSPRITEDMAMEM	=	0	; display spriteDMAMem numbers, needs DEBUG=1
SANITYCHECK			SET		0	; check and display object numbers, based on scanning object lists not object counters
FASTINTRO		SET		0
SHOWRASTERBARS=0;     -> 1 = show bordercolor -> check runtime. ATTN: Copperlist MUST be compiled to validate modification
MENTALKILLER	=	0	; if true, every player bullet hit triggers imminent destruction
PLAYERAUTOFIRE	=	0
FASTBLITUNCOVER	=	0		-> 1 = show A/D-only blits white boxed
DISABLEOPAQUEATTRIB=1	;	1=opaque attrib activates cookie blit enabled. Does not work fully; only with objects placed on top of empty space
BLITNORESTOREENABLED	=	0; feels unefficient to add extra code for static objects without proper background restore, as overhead steals CPU time from every moving object. May be worth it with more animations goign on in background

PLAYERSPRITEDITHERED	=	0	; set to 1 to get collissions triggered but not pendalized. NOTICE: Sprite is dithered. Mainly for testing collission box. ATTN Reduces player accel!
SHOWTRANSITION	=	1
USEXMLFILE	=	1	;	1 = read mapdata from xml-file 0= read mapdata from File "map?"
WRITElaunchTable	=	USEXMLFILE	; 1 = read xml-data and write resulting launchTable to disk	
WRITEMAPFILE	=	USEXMLFILE 	; 1 = read xml-data and write resulting mapfile to disk
WRITECOLORFILE	= 1	; 1=setup colortable and write full 256/12bit-table to file  "color" in levdefs	0=fetch "color"-file and setup full 256-colortable

	ELSE
	IFNE RELEASETEST

	; Values for releasetest. CHANGE WITH CAUTION!

SCORE_OVERRIDE	SET		0
HIGHSCORE_OVERRIDE	SET	0
HISCORETABLEDEFAULT	SET	0
OBJECTSCORETEST	SET		0
DEMOBUILD		SET		0
INITWITH 		SET 	20
AUDIOSFXONLY		SET		0
AUDIOMUSICONLY	SET		0
SHOWOBJECTNO	SET		0
PLAYERCOLL		SET				1
DIFF_OVERRIDE	SET		0
ALERTHANDLING	SET		0
SHELLHANDLING	SET		0
SHELLMEMORY		SET		0
DEBUG			SET		0
DEBUGSPRITEPOSMEM	SET	0
DEBUGSPRITEDMAMEM	SET	0
SANITYCHECK		SET		0
FASTINTRO		SET		0
MENTALKILLER	SET				0
PLAYERAUTOFIRE	SET		0
FASTBLITUNCOVER	SET		0
DISABLEOPAQUEATTRIB	SET	1
SHOWRASTERBARS	SET		0
DISABLEOPAQUEATTRIB	SET	1
BLITNORESTOREENABLED	SET	0
PLAYERSPRITEDITHERED SET	0
SHOWTRANSITION	SET		1
USEXMLFILE		SET		0
WRITElaunchTable	SET	0
WRITEMAPFILE	SET		0
WRITECOLORFILE	SET		0

		ELSE

	; Static values for releasecandidate. NEVER CHANGE!

SCORE_OVERRIDE	SET		0
HIGHSCORE_OVERRIDE	SET	0
HISCORETABLEDEFAULT	SET	0
OBJECTSCORETEST	SET		0
DEMOBUILD		SET		0
INITWITH 		SET 	20
AUDIOSFXONLY		SET		0
AUDIOMUSICONLY	SET		0
SHOWOBJECTNO	SET		0
PLAYERCOLL		SET		1
DIFF_OVERRIDE	SET		0
ALERTHANDLING	SET		0
SHELLHANDLING	SET		0
SHELLMEMORY		SET		0
DEBUG			SET		0
DEBUGSPRITEPOSMEM	SET	0
DEBUGSPRITEDMAMEM	SET	0
SANITYCHECK		SET		0
FASTINTRO		SET		0
MENTALKILLER	SET		0
PLAYERAUTOFIRE	SET		0
FASTBLITUNCOVER	SET		0
DISABLEOPAQUEATTRIB	SET	1
SHOWRASTERBARS	SET		0
DISABLEOPAQUEATTRIB	SET	1
BLITNORESTOREENABLED	SET	0
PLAYERSPRITEDITHERED SET	0
SHOWTRANSITION	SET		1
USEXMLFILE		SET		0
WRITElaunchTable	SET	0
WRITEMAPFILE	SET		0
WRITECOLORFILE	SET		0
		ENDIF
	ENDIF
