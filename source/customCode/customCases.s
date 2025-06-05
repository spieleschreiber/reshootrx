
bobCodeCases
; pointers to object individual code entry adress and anim struct. Code entry adress gets filled within init code. anim table pointer usually 0 or filled in runtime using getAnimAdress [pointer to var store, name of anim]
; struct:   1.l -> code entry name
;           2.l -> code entry adress
;           3.l -> pointer to anim table entry.

c_noCode
noCode


	dc.b    "c_noCode"
	dc.l    c_noCode,0

	dc.b    "emtyAnim"
	dc.l    noCode
emtyAnimAnimPointer
	dc.l    0

	dc.b	"testAnim"
	dc.l	noCode
testAnimAnimPointer
	dc.l	0

	dc.b    "exitKill"
	dc.l    exitKill
	dc.l    0

	dc.b    "cExplSml"
	dc.l    noCode
cExplSmlAnimPointer
	dc.l    0
	
	dc.b    "cExplMed"
	dc.l    noCode
cExplMedAnimPointer
	dc.l    0
	
	dc.b    "cExplLrg"
	dc.l    noCode
cExplLrgAnimPointer
	dc.l    0

	dc.b    "finlExpl"
	dc.l    noCode
finlExplAnimPointer
	dc.l    0

	dc.b    "waveBnus"
	dc.l    noCode
waveBnusAnimPointer
	dc.l    0

	dc.b    "chainBns"
	dc.l    noCode
chainBnsAnimPointer
	dc.l    0

	dc.b    "tutSpdUp"
	dc.l    noCode
tutSpdUpAnimPointer
	dc.l    0

	dc.b    "tutPwrUp"
	dc.l    noCode
tutPwrUpAnimPointer
	dc.l    0

	dc.b    "addTutPw"
	dc.l    addTutPw	; add tutorial PowerUp Icon
	dc.l    0

	dc.b    "addTutSp"
	dc.l    addTutSp	; add tutorial SpeedUp Icon
	dc.l    0


;#MARK: Pointers Debris
    dc.b    "debrisA2"
    dc.l    c_noCode
debrisA2AnimPointer
    dc.l    0

    dc.b    "debrisA3"
    dc.l    c_noCode
debrisA3AnimPointer
    dc.l    0

    dc.b    "debrisA4"
    dc.l    c_noCode
debrisA4AnimPointer
    dc.l    0

;#MARK: Pointers Player Bullets
cPlyShtA
    dc.b    "cPlyShtA"
    dc.l    noCode
cPlyShtAAnimPointer
    dc.l    0

    dc.b    "cPlyShtB"
    dc.l    noCode
cPlyShtBAnimPointer
    dc.l    0

	dc.b	"cPlyShtC"
	dc.l	noCode
cPlyShtCAnimPointer
	dc.l	0

	dc.b	"cPlyShtD"
	dc.l	noCode
cPlyShtDAnimPointer
	dc.l	0

	dc.b	"cPlyShAX"
	dc.l	noCode
cPlyShAXAnimPointer
	dc.l	0

	dc.b	"cPlyShBX"
	dc.l	noCode
cPlyShBXAnimPointer
	dc.l	0

	dc.b	"cPlyShCX"
	dc.l	noCode
cPlyShCXAnimPointer
	dc.l	0

	dc.b	"cPlyShDX"
	dc.l	noCode
cPlyShDXAnimPointer
	dc.l	0

;#MARK: Pointers Bullets
	dc.b    "homeShot"
homeShotPointer    
	dc.l    homeShot
	dc.l    0

	dc.b 	"bascShot"
	dc.l 	noCode
bascShotAnimPointer
    dc.l    0

	dc.b    "homeSht2"	; shoot only every 2nd object in chained objects
	dc.l    homeSht2
	dc.l    0

	dc.b    "homeSht4"
	dc.l    homeSht4
	dc.l    0

	IFNE 1
	dc.b    "homeHard"	; bullet only on hard diff
	dc.l    homeHard
	dc.l    0

	dc.b    "homeHrd2"
	dc.l    homeHrd2
	dc.l    0

	dc.b    "homeHrd4"
	dc.l    homeHrd4
	dc.l    0
	ENDIF

	dc.b	"stSpHead"
	dc.l	stSpHead
	dc.l	0

	dc.b	"stSpiral"
	dc.l	stSpiral
	dc.l	0

	dc.b	"stHarder"
	dc.l	stSpiralHard
	dc.l	0

	dc.b	"stSpiRst"
	dc.l	stReset
	dc.l	0

	dc.b	"circLsrA"
	dc.l    noCode
circLsrAAnimPointer
	dc.l    0

	dc.b 	"biggShot"
	dc.l 	biggShot
biggShotAnimPointer
    dc.l    0

	dc.b 	"lasrShot"
	dc.l 	lasrShot
lasrShotAnimPointer
    dc.l    0


;#MARK: Pointers Dialogue
    dc.b    "pictHero"
    dc.l    noCode
pictHeroAnimPointer
    dc.l    0
    dc.b    "pictBoss"
    dc.l    noCode
pictBossAnimPointer
    dc.l    0

;#MARK: Weapon Destruction Copper Controller
    dc.b    "weapDstr"
    dc.l    noCode
weapDstrAnimPointer
    dc.l    0

    dc.b    "weapUpgr"
    dc.l    noCode
weapUpgrAnimPointer
    dc.l    0

    dc.b    "spedUpgr"
    dc.l    noCode
spedUpgrAnimPointer
    dc.l    0

;#MARK: Postkill Quick Respawn Sprite
    dc.b    "instSpwn"
    dc.l    noCode
instSpwnAnimPointer
    dc.l    0

;#MARK: Pause Message Sprite
    dc.b    "pauseMsg"
    dc.l    noCode
pauseMsgAnimPointer
    dc.l    0

;#MARK: Meteor Shower
    dc.b    "metEmitr"	; emitter 
    dc.l    noCode
metEmitrAnimPointer
    dc.l	0
    
    dc.b    "meteoMed"	; anim pointer
    dc.l    noCode
meteoMedAnimPointer
    dc.l    0


;#MARK: Pointers Object Special Destruction
	dc.b 	"destroyA"
destroyBase	; label needs to be set infront of first destroy Entry 
 	dc.l 	dstrEvnt
	dc.l	0
	dc.b 	"destroyB"
	dc.l 	dstrEvnt
	dc.l	0
	dc.b 	"destroyC"	; launch homeshot post-death
	dc.l 	dstrEvnt
	dc.l	0
	dc.b 	"destroyD"	; force small explosion
	dc.l 	dstrEvnt
	dc.l	0
	dc.b 	"destroyE"	; force medium explosion
	dc.l 	dstrEvnt
	dc.l	0
	dc.b 	"destroyF"	; force large explosion
	dc.l 	dstrEvnt
	dc.l	0
	dc.b 	"destroyG"	; force large explosion
	dc.l 	dstrEvnt
	dc.l	0
	dc.b 	"destroyH"	; launch extra post-death
	dc.l 	dstrEvnt
	dc.l	0
	dc.b 	"destroyI"	; set global trigger2, large explosion
	dc.l 	dstrEvnt
	dc.l	0
	dc.b 	"destroyJ"	; kill attached bullet emitter, boss 3 snake
	dc.l 	dstrEvnt
	dc.l	0
	dc.b 	"destroyK"	; quit loop and exit object, mid boss stage 4
	dc.l 	dstrEvnt
	dc.l	0
	dc.b 	"destroyL"	; quit loop and exit object, mid boss stage 4
	dc.l 	dstrEvnt
	dc.l	0

;#MARK: Pointers Escalation
	dc.b    "initEscl"
	dc.l    initEscl
	dc.l    0
    dc.b    "muscEscl"
    dc.l    muscEscl
    dc.l    0
	dc.b    "exitEscl"
    dc.l    exitEscl
    dc.l    0

;#MARK: Pointers StealthObject
    dc.b    "stealthA"
    dc.l    noCode
stealthAAnimPointer
    dc.l    0
    dc.b    "stealthB"
    dc.l    noCode
stealthBAnimPointer
    dc.l    0
    dc.b    "stealthC"
    dc.l    noCode
stealthCAnimPointer
    dc.l    0
    dc.b    "stealthD"
    dc.l    noCode
stealthDAnimPointer
    dc.l    0


;#MARK: Pointers Tentacle
	dc.b	"tentInit"	; 	""
	dc.l	tentInit,0

	dc.b	"tentTube"
	dc.l	noCode
tentTubeAnimPointer
	dc.l	0

	dc.b    "tentHead"	; ATTN: 3 tentheads need to be kept in this succession as for tentinit code to work / allow choice of 3 head alternatives
	dc.l    noCode
tentHeadAnimPointer
	dc.l    0

	dc.b    "tentHedB"
	dc.l    noCode
tentHedBAnimPointer
	dc.l    0

	dc.b    "tentHedC"
	dc.l    noCode
tentHedCAnimPointer
	dc.l    0

;#MARK: Pointers spiderAttachment
	dc.b    "shelRgtA"	; keep order, needed for correct init
	dc.l    noCode
shelRgtAAnimPointer
	dc.l	0

	dc.b    "shelRgtB"	; keep order, needed for correct init
	dc.l    noCode
shelRgtBAnimPointer
	dc.l	0
	
	dc.b    "shelLftA"	; anim pointer
	dc.l    noCode
shelLftAAnimPointer
	dc.l	0

	dc.b    "shelLftB"	; anim pointer
	dc.l    noCode
shelLftBAnimPointer
	dc.l	0

;#MARK: Pointers Boss Enemies
	dc.b 	"bossEast"
	dc.l 	noCode
bossEastAnimPointer
	dc.l	0

	dc.b 	"bossWest"
	dc.l 	noCode
bossWestAnimPointer
	dc.l	0

	dc.b 	"bossCntr"
	dc.l 	noCode
bossCntrAnimPointer
	dc.l	0

	dc.b 	"bossFinl"
	dc.l 	noCode
bossFinlAnimPointer
	dc.l	0


	; animPointers used to init stage1, stage2 of 3-staged battles
	dc.b 	"bossStgB"
	dc.l 	noCode
bossStgBAnimPointer
	dc.l	0

	dc.b 	"bossStgC"
	dc.l 	noCode
bossStgCAnimPointer
	dc.l	0

	dc.b 	"bossInit"
	dc.l 	bossInit
	dc.l	0


	dc.b 	"addChild"	; add "code addChild" to animlist to add x childs objects
	dc.l 	addChild
	dc.l    0

	dc.b 	"setTrigs"	; add "code setTrigs" to animlist to initialise animTriggers prior to using them
	dc.l 	setTrigs
	dc.l    0

	dc.b 	"clrTrigs"	; add "code setTrigs" to animlist to initialise animTriggers prior to using them
	dc.l 	clrTrigs
	dc.l    0

	dc.b 	"setHitPt"	; add "code setHitPt" to animlist to apply high hitpoints to object
	dc.l 	setHitPt
	dc.l    0

	dc.b 	"setHitPB"	; add "code setHitPB" to animlist to apply high hitpoints to object
	dc.l 	setHitPB
	dc.l    0

	dc.b 	"playfx01"	; add "code playfx01" to animlist to play spawn-sound
	dc.l 	playSpwn
	dc.l    0

	dc.b 	"mechVMsl" ;add "code mechVMsl" to animlist to launch separate object
	dc.l 	mechVMsl
	dc.l    0

	dc.b 	"mechVinL"
	dc.l 	noCode
mechVinLAnimPointer
	dc.l    0
	dc.b 	"mechVinX"
	dc.l 	noCode
mechVinXAnimPointer
	dc.l    0
	dc.b 	"mechVinR"
	dc.l 	noCode
mechVinRAnimPointer
	dc.l    0
	dc.b 	"mechVinM"	; large sized mechVien missile object
	dc.l 	noCode
mechVinMAnimPointer
	dc.l    0
	dc.b 	"mechMedM"	; medium sized mechVien missile object
	dc.l 	noCode
mechMedMAnimPointer
	dc.l    0


	dc.b 	"mechMedL"
	dc.l 	noCode
mechMedLAnimPointer
	dc.l    0
	dc.b 	"mechMedX"
	dc.l 	noCode
mechMedXAnimPointer
	dc.l    0
	dc.b 	"mechMedR"
	dc.l 	noCode
mechMedRAnimPointer
	dc.l    0

	dc.b 	"spwnXplL"	; spawn explosion at objects position
	dc.l 	spwnXplL
	dc.l    0

	dc.b 	"spwnXplS"
	dc.l 	spwnXplS
	dc.l    0

	dc.b 	"sunErptL"
	dc.l 	noCode
sunErptLAnimPointer
	dc.l    0

	dc.b 	"sunErptR"
	dc.l 	noCode
sunErptRAnimPointer
	dc.l    0

	dc.b 	"riglBody"
	dc.l 	noCode
riglBodyAnimPointer
	dc.l    0
	dc.b 	"riglWest"
	dc.l 	noCode
riglWestAnimPointer
	dc.l    0
	dc.b 	"riglAnch"
	dc.l 	noCode
riglAnchAnimPointer
	dc.l    0
	dc.b 	"riglEast"
	dc.l 	noCode
riglEastAnimPointer
	dc.l    0

	dc.b 	"bullEmit"
	dc.l 	noCode
bullEmitAnimPointer
	dc.l    0

	dc.b 	"serpBody"
	dc.l 	noCode
serpBodyAnimPointer
	dc.l    0


	dc.b    "spdrAdda"	; anim pointer
	dc.l    spiderAddAttach,0



;#MARK: Pointer Initialize Debris Object
	dc.b 	"debrsObj"
	dc.l 	noCode
debrsObjAnimPointer
	dc.l	0



;#MARK: Pointers Enemy Bullets Hit Wall
	dc.b 	"bascShtX"
	dc.l 	noCode
bascShtXAnimPointer
	dc.l	0




;#MARK: add tentBase as child
	dc.b	"tentBase"
	dc.l	noCode
tentBaseAnimPointer
	dc.l    0



;#MARK: launch and control hunter missile

	dc.b    "mislExpl"
	dc.l    mislExpl
	dc.l    0

	dc.b    "huntMisl"
	dc.l    noCode
huntMislAnimPointer
    dc.l    0

;#MARK: launch and control beeshive

	dc.b    "beesHive"
	dc.l    noCode
beesHiveAnimPointer
    dc.l    0


	IFNE 0

	dc.b 	"eyesShot"
	dc.l 	noCode
eyesShotAnimPointer
	dc.l    0





	dc.b    "wallInit"
	dc.l    wallInit	;
	dc.l    0

	dc.b    "wallBrke"
	dc.l    noCode
wallBrkeAnimPointer
	dc.l    0

    dc.b    "mislExpl"
    dc.l    mislExpl
mislExplAnimPointer
    dc.l    0

	dc.b    "homeMisl"	; keep homeMisl&mislB together, needed in launch code
	dc.l    noCode
homeMislAnimPointer
    dc.l    0
    dc.b    "homMislB"
    dc.l    noCode
homMislBAnimPointer
    dc.l    0
    dc.b    "hmMslBos"
    dc.l    noCode
hmMslBosAnimPointer
    dc.l    0

    dc.b    "mislInit"
    dc.l    mislInit
    dc.l    0
    dc.b    "mislBoss"
    dc.l    mislBoss
    dc.l    0

    dc.b    "mothTurA"
    dc.l    noCode
mothTurAAnimPointer
    dc.l    0
    dc.b    "mothTuA2"
    dc.l    noCode
mothTuA2AnimPointer
    dc.l    0

    dc.b    "mothTurC"
    dc.l    noCode
mothTurCAnimPointer
    dc.l    0
    dc.b    "mothTuC2"
    dc.l    noCode
mothTuC2AnimPointer
    dc.l    0
    dc.b    "mothChld"
    dc.l    mothChld
mothChldAnimPointer
    dc.l    0
    dc.b    "mothTuBs"
    dc.l    noCode
mothTuBsAnimPointer
    dc.l    0

    

;#MARK: Pointers Scroll Control
	dc.b 	"scrolSlo"
	dc.l	scrolSlo
	dc.l	0

	dc.b 	"scrolMed"
	dc.l	scrolMed
	dc.l	0

	dc.b 	"scrolFst"
	dc.l	scrolFst
	dc.l	0

	dc.b 	"scrolRes"
	dc.l	scrolRes
	dc.l	0


;#MARK: Pointers L3 Midboss

	dc.b 	"l3brInit"
	dc.l	l3brInit
	dc.l	0
	
	dc.b 	"l3brEyUp"
	dc.l	noCode
l3brEyUpAnimPointer
	dc.l	0
	dc.b 	"l3brEyDn"
	dc.l	noCode
l3brEyDnAnimPointer
	dc.l	0
	dc.b 	"l3brHead"
	dc.l	noCode
l3brHeadAnimPointer
	dc.l	0
	dc.b 	"l3brHelm"
	dc.l	noCode
l3brHelmAnimPointer
	dc.l	0
	dc.b 	"l3brTeth"
	dc.l	noCode
l3brTethAnimPointer
	dc.l	0
	dc.b    "l3brAdTa"
	dc.l    l3brAdTa
	dc.l    0
	dc.b    "l3brTail"
	dc.l    noCode
l3brTailAnimPointer
	dc.l    0
	dc.b    "l3brTaiA"
	dc.l    noCode
l3brTaiAAnimPointer
	dc.l    0


	IFNE	0
;#MARK: Pointers Asteroid
	dc.b    "astrTenc"
	dc.l    astrTenc
	dc.l    0


	dc.b 	"astrSmlT"
	dc.l 	noCode
astrSmlTAnimPointer
	dc.l 	0

	dc.b 	"astrKilA"
	dc.l 	astrAni96
astrKilAAnimPointer
	dc.l 	0

	dc.b 	"astrKilB"
	dc.l 	astrAni96
astrKilBAnimPointer
	dc.l 	0

	dc.b 	"astrKilC"
	dc.l 	astrAni96
astrKilCAnimPointer
	dc.l 	0
	ENDIF
	


	



;#MARK: Pointers Sun Boss

	; anim pointers

	dc.b	"donutBsA"
	dc.l	noCode
donutBsAAnimPointer
	dc.l    0

	dc.b	"donutBsB"
	dc.l	noCode
donutBsBAnimPointer
	dc.l    0

	dc.b	"eyeRoidB"
	dc.l	noCode
eyeRoidBAnimPointer
	dc.l	0

	IFNE 0
;#MARK: Pointers L2 / L4 Sky Boss / Wasp
	; code inits
	dc.b	"l2bsInit"
	dc.l	l2bsInit,0

	dc.b	"l2WsInit"
	dc.l	l2WsInit,0

    dc.b    "waspIntA"
    dc.l    waspIntA,0

    dc.b    "waspIntB"
    dc.l    waspIntB,0

    dc.b    "waspIntC"
    dc.l    waspIntC,0

	dc.b 	"l4bsShtA"
	dc.l	l4bsShtA,0

	dc.b	"waspMain"
	dc.l	noCode
waspMainAnimPointer
	dc.l    0

	dc.b    "waspChdA"
	dc.l    noCode
waspChdAAnimPointer
	dc.l    0

	dc.b    "waspChA2"; ATTN: keep position of waspCha? in relation to waspChdA, needed in waspIntA boss init code
	dc.l    noCode
	dc.l    0

	dc.b    "waspChA3"
	dc.l    noCode
	dc.l    0

    dc.b    "waspChdB"
    dc.l    noCode
waspChdBAnimPointer
    dc.l    0

    dc.b    "waspStg1"
    dc.l    noCode
waspStg1AnimPointer
    dc.l    0

	dc.b    "waspVuln"
	dc.l    waspVuln
	dc.l    0
    dc.b    "waspUnvu"
    dc.l    waspUnvu
    dc.l    0
	
	dc.b    "isHitble"
	dc.l    isHitble
	dc.l    0
    dc.b    "notHitbl"
    dc.l    notHitbl
    dc.l    0
	dc.b    "waspSht1"
	dc.l    waspSht1
	dc.l    0
	dc.b    "waspSht2"
	dc.l    waspSht2
	dc.l    0
	ENDIF


	dc.b    "shotPtrn"
	dc.l    shotPtrn
	dc.l    0

	dc.b    "brickEye"
	dc.l    noCode
brickEyeAnimPointer
	dc.l    0

	dc.b    "brickDsc"
	dc.l    noCode
brickDscAnimPointer
	dc.l    0


    dc.b    "boulders"
    dc.l    noCode
bouldersAnimPointer
    dc.l    0

    dc.b    "drwOnTop"
    dc.l     drwOnTop
    dc.l    0

    dc.b    "showCont"
    dc.l    noCode
showContAnimPointer
    dc.l    0

    
	ENDIF
bobCodeCasesEnd
