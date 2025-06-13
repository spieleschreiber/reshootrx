
	cnop 4,0

animCases
    dc.b    "non_Anim"
    dc.l    non_Anim,0
    dc.b    "emptyObj"
    dc.l    emptyObj,0
    dc.b    "emptyKil"
    dc.l    emptyKil,0

    dc.b    "alrtText"
    dc.l    hybridSprite,0
    dc.b    "alrtSoth"
    dc.l    hybridSprite,0
    dc.b    "alrtNrth"
    dc.l    hybridSprite,0
    dc.b    "alrtEast"
    dc.l    hybridSprite,0
    dc.b    "alrtWest"
    dc.l    hybridSprite,0


	dc.b    "debris_2"
	dc.l    debris,0
	dc.b    "debris_3"
	dc.l    debris,0
	dc.b    "debris_4"
	dc.l    debris,0
	dc.b 	"debrsCtl"
	dc.l 	debrsCtl,0
	dc.b 	"debrsObj"	; spawns debris after explosion
	dc.l 	debrsObj,0

	dc.b    "expl_lrg"
	dc.l    expl_lrg,0
	dc.b    "expl_sml"
	dc.l    expl_sml,0
	dc.b    "expl_med"
	dc.l    expl_med,0

	dc.b    "meteoCtr"
	dc.l    meteoCtr,0
	dc.b    "meteoMed"
	dc.l    meteoMed,0

	dc.b    "circLsrA"
	dc.l    circLsrA,0

    dc.b    "bullEmit"
    dc.l    bullEmit,0

	dc.b    "serpBody"
	dc.l    serpBody,0
	dc.b    "serpHead"
	dc.l    serpBody,0


	; bulletCage formerly known as eyeRoid
	dc.b    "bultCage"
	dc.l    bultCage,0

	;
	dc.b    "rotators"
	dc.l    basic2w16frame30fps,0

; 	MechViens
	dc.b    "riglBody"
	dc.l    riglBody,0
	dc.b    "riglEast"
	dc.l    riglEast,0
	dc.b    "riglWest"
	dc.l    riglWest,0
	dc.b    "riglAnch"
	dc.l    emptyObj,0
	dc.b    "mechMedC"
	dc.l    mechMedC,0
	dc.b    "mechVinC"
	dc.l    mechVinC,0
;	dc.b    "mechVinL"
;	dc.l	non_Anim,0	; non-animated object do not need extra code
;	dc.b    "mechVinR"
;	dc.l	non_Anim,0
	dc.b    "mechVinX"
	dc.l	mechVinX,0
	dc.b    "mechVinM"
	dc.l	basic1w2frame60fps,0
	dc.b    "mechMedM"
	dc.l	basic1w2frame60fps,0

	dc.b    "mechMdMB"
	dc.l	basic1w8frame30fps,0
	dc.b    "mechMedE"
	dc.l	basic3w2frames5fps,0

	; rotating circular wave type
	dc.b    "spinners"
	dc.l    spinners,0
	dc.b    "crabSpin"
	dc.l    spinners,0

	; big crab-like with two arms
	dc.b    "crabAtak"
	dc.l    crabAtak,0

	IFNE 1
	; triceratops
	dc.b 	"tricerL0"
	dc.l	tricrMng,0
	dc.b    "tricerR0"
	dc.l	tricrMng,0

	dc.b    "tricerRA"; object needed to trigger mirroring process -
	dc.l	tricrMng,0
	dc.b    "tricerR1"
	dc.l	tricrMng,0
	dc.b    "tricerR2"
	dc.l	tricrMng,0
	dc.b    "tricerR3"
	dc.l	tricrMng,0
	ENDIF

	; spinning circular wave type
	dc.b    "krak1615"
	dc.l    krakenSmall,0
	dc.b    "krakAmob"
	dc.l    krakenAmoeb,0
	dc.b    "krakSpik"
	dc.l    krakenSpiker,0

	; invade, shoot, evade
	dc.b    "tilterUP"
	dc.l    tilterXX,0
	dc.b	"tilterDW"
	dc.l    tilterXX,0
	dc.b    "tilterFV"
	dc.l    tilterFV,0

	; bossControllers
	dc.b    "bossCtrl"
	dc.l    bossCtrl,0

	dc.b 	"sunErpR1"
	dc.l 	sunAnIdl,0
	dc.b 	"sunErpL1"
	dc.l 	sunAnIdl,0

	dc.b 	"sunErpL0"	; object needed to trigger mirroring process
	dc.l 	sunErupt,0
	dc.b 	"sunErpL2"
	dc.l 	sunErupt,0
	dc.b 	"sunErpL3"
	dc.l 	sunErupt,0
	dc.b 	"sunErpL4"
	dc.l 	sunErupt,0
	dc.b 	"sunErpL5"
	dc.l 	sunErupt,0
	dc.b 	"sunErpL6"
	dc.l 	sunErupt,0
	dc.b 	"sunErpL7"
	dc.l 	sunErupt,0
	dc.b 	"sunErpL8"
	dc.l 	sunErupt,0

	dc.b 	"stealthy"
	dc.l 	stealthy,0
	dc.b 	"stealthz"
	dc.l 	stealthz,0

	dc.b 	"shelLftA"
	dc.l 	shellAnim,0
	dc.b 	"shelLftB"
	dc.l 	shellAnim,0
	dc.b 	"shelRgtA"
	dc.l 	shellAnim,0
	dc.b 	"shelRgtB"
	dc.l 	shellAnim,0
	dc.b 	"shelHubL"
	dc.l 	spiderControl,0
	dc.b 	"shelHubR"
	dc.l 	spiderControl,0

	dc.b 	"beeshive"
	dc.l 	beeshive,0
	dc.b 	"spikMine"	; same behaviour as beehive, just modified visuals
	dc.l 	beeshive,0

	dc.b 	"brickMed"
	dc.l 	brickMed,0
	dc.b 	"brikBMed"
	dc.l 	brickMed,0
	dc.b 	"brikLeft"
	dc.l 	brickMed,0
	dc.b 	"brikCntr"
	dc.l 	brickMed,0
	dc.b 	"brikRite"
	dc.l 	brickMed,0
	dc.b 	"brickBig"
	dc.l 	brickMed,0

	dc.b 	"huntMisl"
	dc.l 	huntMisl,0
	dc.b 	"doblClaw"
	dc.l 	doblClaw,0


    dc.b    "tentHead"
    dc.l    tentHead,0
    dc.b    "tentHedB"
    dc.l    tentHead,0
    dc.b    "tentHedC"
    dc.l    tentHead,0
    dc.b    "tentTube"
    dc.l    tentTube,0
    dc.b    "tentBase"
    dc.l    tentBase,0
    dc.b    "tentBasB"
    dc.l    tentBase,0

    dc.b    "weapupgr"
    dc.l    weapupgr,0
    dc.b    "spedupgr"
    dc.l    spedUpgr,0
    dc.b    "weapdstr"
    dc.l    weapdstr,0

	dc.b	"tileAniA"
	dc.l	tileAnim,0
	dc.b	"tileAniB"
	dc.l	tileAnim,0
	dc.b	"tileAniC"
	dc.l	tileAnim,0


	dc.b	"vfxCntrl"
	dc.l	vfxController,0

	dc.b    "scrlCtrl"
	dc.l    scrlCtrl,0

    dc.b    "dialgBad"
    dc.l    dialogue,0
    dc.b    "dialgHro"
    dc.l    dialogue,0

	dc.b    "esclThis"
	dc.l    esclThis,0
    dc.b    "esclQuit"
    dc.l    esclQuit,0

	dc.b 	"exitStge"
	dc.l	exitStage,0

	IFNE 0
	
	; boss jmp table

	dc.b    "wormSptA"
    dc.l    wormSptA,0
	dc.b    "wormSptC"
    dc.l    wormSptC,0
	dc.b    "wormSptB"
    dc.l    wormSptB,0
	dc.b    "wormSptD"
    dc.l    wormSptD,0

	dc.b    "goldOrbA"
    dc.l    goldOrbA,0
	dc.b    "goldOrbB"
    dc.l    goldOrbB,0

	dc.b    "astBlock"
    dc.l    astBlock,0

	dc.b    "astrSmlA"
    dc.l    astrAnim,0
	dc.b    "astrSmAT"
    dc.l    astrAnim,0
	dc.b    "astrSmAS"
    dc.l    astrAniB,0
	dc.b    "astrSmlB"
    dc.l    astrAnim,0
	
	dc.b    "bigRocka"
    dc.l    bigRocka,0
	
	dc.b    "astrMedB"
    dc.l    astrAnim,0
	dc.b    "astrMedC"
    dc.l    astrAnim,0
	dc.b    "astrBigA"
    dc.l    astrAni96,0
	dc.b    "astrBigB"
    dc.l    astrAni96,0
    dc.b    "huntMisl"
    dc.l    huntMisl,0
    dc.b    "pentagon"
    dc.l    pentagon,0
	dc.b 	"eyeRoidB"
	dc.l 	eyesRoid,0
	dc.b 	"eyesRoid"
	dc.l 	eyesRoid,0

	dc.b    "wallblck"
	dc.l    wallblck,0
	dc.b    "wallCtrl"
	dc.l    wallCtrl,0



	dc.b    "brickDsc"
	dc.l    tilterXX,0
    dc.b    "sphPod16"
    dc.l    sphPod16,0
    dc.b    "sphPod32"
    dc.l    sphPod16,0


    dc.b    "boneWing"
    dc.l    boneWing,0

	dc.b    "brickMed"
	dc.l    brickMed,0
	
	dc.b    "boulders"
	dc.l    boulders,0
	
    dc.b    "jelyFish"
    dc.l    jelyFish,0

	dc.b    "mothMain"
    dc.l    mothMain,0


	dc.b    "mothMain"
    dc.l    mothMain,0
	dc.b    "mothMaiB"
    dc.l    mothMain,0
    dc.b    "mothTurA"
    dc.l    mothTurAC,0
    dc.b    "mothTurC"
    dc.l    mothTurAC,0
    dc.b    "mothTurB"
    dc.l    mothTurB,0
    dc.b    "brikTurB"
    dc.l    mothTurB,0


	dc.b	"tileAniA"
	dc.l	tileAnim,0
	dc.b	"tileAniB"
	dc.l	tileAnim,0
	dc.b	"tileAniC"
	dc.l	tileAnim,0

	ENDIF
    



animCasesEnd
