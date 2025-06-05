;//
;//  audioManager.s
;//  px
;//
;//  Created by Richard Löwenstein on 14.09.20.
;//  Copyright © 2020 spieleschreiber. All rights reserved.
;//


testModule	=	0	;  set 1 to test module, modify makefile to assemble audioManager ONLY!


fxInitShoot=1
fxInitImpact=2
fxInitExplosionS=3
fxInitExplosionM=4
fxInitExplosionL=5
fxInitEnemshot=6
fxInitAlarm=7
.wait
	IFNE	testModule
	INCLUDE	system/custom.i
	INCLUDE	ptplayer/cia.i
testMod
	add #1,d0
	move d0,$dff180
	;bra testMod
	move.l	a5,-(a7)
	moveq	#0,d0			; default at $0
	move.l	$4.w,a6
	btst	#0,296+1(a6)		; 68010+?
	beq.b	.is68k			; nope.
	lea	.getit(pc),a5
	jsr	-30(a6)			; SuperVisor()
.is68k	move.l	(a7)+,a5

    lea CUSTOM,a6
	sf.b d0
    bsr _mt_install_cia
   
    lea CUSTOM,a6
    sub.l a1,a1	; get samples from mod-file
    sf.b d0
	lea modMain,a0
    bsr _mt_init;(a6=CUSTOM, a0=TrackerModule, a1=Samples, d0=StartPos.b)
	lea	mt_chan1,a4
	st.b	_mt_Enable-mt_chan1(a4)
 	
 	lea CUSTOM,a6
 	move.w #64,d0
 	bsr _mt_mastervol
 	 	
.wait
	btst	#6,$bfe001		;repeat until left mouse button pressed
	bne	.wait
	
    lea CUSTOM,a6
	bsr _mt_end
	
	bsr _mt_remove_cia
	
	clr.w d0
 	rts
.getit
	movec   vbr,a0
	rte				; back to user state code
modMain
	INCBIN /Users/richardlowenstein/Library/CloudStorage/Dropbox/Richard_Office/Gameprojekt/Amiga/Development/PX/stage3/mus
	ENDIF
	INCLUDE ptplayer/ptplayer.asm


; #MARK: - FX load table

; ATTN: Filename needs to end with .wav
fxLoadTable
    ;0
    dc.b    "dropchain.wav",0		; temp sfx
 
    ;1
    dc.b    "shot.wav",0
 
    ;2
    dc.b    "explosion.wav",0
 
    ;3
    dc.b    "hitBck.wav",0

    ;4
    dc.b    "bulletB.wav",0
    
    ;5
    dc.b    "vocEscal.wav",0

    ;6
    dc.b    "vocHigh.wav",0

    ;7
    dc.b    "hitObj.wav",0

    ;8
    dc.b    "vocWeapon.wav",0

    ;9
    dc.b    "vesselHit.wav",0
    
    ;10
    dc.b    "vocMax.wav",0

    ;11
    dc.b    "vocSped.wav",0

    ;12
    dc.b    "dropchain.wav",0

	;13
    dc.b    "achievement.wav",0

	;14
    dc.b    "lighting.wav",0

	;15
    dc.b    "beam.wav",0

	;16
	dc.b    "spawn.wav",0

	even

	dc.w 0
	
   

AudioIsInitiated
    dc.b 0
AudioNoOfSamples
    dc.b 0
AudioRythmFlag
    dc.b 0
AudioRythmFlagBullets
    dc.b 0
AudioRythmFlagAnim
    dc.b    0
AudioRythmAnimOffset
    dc.b    0
fxInit
	dc.b    0

	even

;	#MARK: - SFX TABLE

;   0.w     Offset Sampleperiod (bit15-> add random pitch)
;   2.b     minimal playtime
;   3.b     volume
;   4.w     Pointer to sample (load order)
;   6.b     not used
;   7.b     priority

; Samplerate $50 = original

; sfx-structure
;      0: ptr, 4: len.w, 6: period.w, 8: vol.w, 10: channel.b, 11: priority.b

first
	RSSET	-1
channelBest		rs.b	1
channel0		rs.b	1
channel1		rs.b	1
channel2		rs.b	1
channel3		rs.b	1

	RSSET	1
fxPrioLowest	rs.b	1
fxPrioLow		rs.b	1
fxPrioMed		rs.b	1
fxPrioHigh		rs.b	1
fxPrioHigher	rs.b	1
fxPrioHighest	rs.b	1
fxPrioTop		rs.b	1

	; #MARK:  - SFX DEFINITIONS

musicFullVolume = 56
musicPauseVolume = 5
speechVolume	=	64
periodBase 	= $70
altPitch =	$8000	; or with frequence to alternate pitch a bit
	RSSET 1
	
fxTable
fxSpeech	rs.b	1
_fxSpeech	
	dc.l	1			; pointer ; this is overwritten dynamically
	dc.w	0			; length ""
	dc.w	$110	; frequency
	dc.w	$3f			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioTop	; priority

fxSizeOf	SET *-fxTable	

;	Init SFX with Macro PLAYFX soundname

fxShot	rs.b	1
	dc.l	1			; pointer
	dc.w	0			; length
	dc.w	altPitch|$150	; frequency
	dc.w	15			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioMed	; priority

fxExplSmall	rs.b	1
	dc.l	2			; pointer
	dc.w	0			; length
	dc.w	altPitch|(periodBase*1)	; frequency
	dc.w	$30			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioHigher	; priority

fxExplMed	rs.b	1
	dc.l	2			; pointer
	dc.w	0			; length
	dc.w	altPitch|(50+periodBase*1)	; frequency
	dc.w	$38			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioHigher	; priority

;5  -   explosion big
fxExplBig	rs.b	1
	dc.l	2			; pointer
	dc.w	0			; length
	dc.w	altPitch|(periodBase*3)	; frequency
	dc.w	$40			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioHighest	; priority

;6  -   Enemy shot
fxEnemBullet	rs.b	1
	dc.l	4			; pointer
	dc.w	0			; length
	dc.w	periodBase*4	; frequency
	dc.w	$19			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioMed; priority

;7  -   Escalation
fxEscalation	rs.b	1
	dc.l	5			; pointer
	dc.w	0			; length
	dc.w	$120	; frequency
	dc.w	$40			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioTop	; priority

fxImpactEnem	rs.b	1
	dc.l	7			; pointer
	dc.w	0			; length
	dc.w	periodBase	; frequency
	dc.w	$38			; volume
	dc.b	channel2	; which channel?
	dc.b	fxPrioHigher	; priority

;9  - shot impact on wall
fxImpactWall	rs.b	1
	dc.l	3			; pointer
	dc.w	0			; length
	dc.w	periodBase	; frequency
	dc.w	$18			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioHigh	; priority

;10  - highscore
vocHighscore	rs.b	1
	dc.l	6			; pointer
	dc.w	0			; length
	dc.w	60+periodBase*2	; frequency
	dc.w	$40			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioHighest	; priority

vocWeapon	rs.b	1
	dc.l	8			; pointer
	dc.w	0			; length
	dc.w	periodBase*3	; frequency
	dc.w	speechVolume			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioHighest	; priority

vocMax	rs.b	1
	dc.l	10			; pointer
	dc.w	0			; length
	dc.w	60+periodBase*2	; frequency
	dc.w	speechVolume			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioHighest	; priority

;13  - Vessel Hit
fxLoseWeapon	rs.b	1
	dc.l	9			; pointer
	dc.w	0			; length
	dc.w	200+periodBase	; frequency
	dc.w	$30			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioHighest	; priority
    
fxLoseVessel	rs.b	1
	dc.l	9			; pointer
	dc.w	0			; length
	dc.w	periodBase*4	; frequency
	dc.w	$30			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioHighest	; priority

;15  - Speedup
vocSpeedup	rs.b	1
	dc.l	11			; pointer
	dc.w	0			; length
	dc.w	periodBase*3	; frequency
	dc.w	speechVolume			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioHighest	; priority

;16  -  Achievement
fxAchievement	rs.b	1
	dc.l	13			; pointer
	dc.w	0			; length
	dc.w	periodBase*2	; frequency
	dc.w	40			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioHighest	; priority

;17  -   Enemy shot Big
fxBigBullet	rs.b	1
	dc.l	14		; pointer
	dc.w	0			; length
	dc.w	830	; frequency
	dc.w	$3f			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioHigh; priority

;18  - fxShootSpacey
fxShootSpacey	rs.b	1
	dc.l	3			; pointer
	dc.w	0			; length
	dc.w	periodBase*4	; frequency
	dc.w	$2f			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioMed	; priority

;19  - fxShootMissile
fxShootMissile	rs.b	1
	dc.l	14			; pointer
	dc.w	0			; length
	dc.w	periodBase/1	; frequency
	dc.w	$3f			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioHigher	; priority

;20  - kill chain
fxKillChain	rs.b	1
	dc.l	12			; pointer
	dc.w	0			; length
	dc.w	periodBase*7	; frequency
	dc.w	$30			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioHigher	; priority

;21  - beamIntro
fxBeamIntro	rs.b	1
	dc.l	16			; pointer
	dc.w	0			; length
	dc.w	periodBase*10	; frequency
	dc.w	$3f			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioHigher	; priority

;22  - beamFX
fxBeam	rs.b	1
	dc.l	15			; pointer
	dc.w	0			; length
	dc.w	periodBase*5	; frequency
	dc.w	$3f			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioHigher	; priority

;23  - spawn
fxSpawn	rs.b	1
	dc.l	16			; pointer
	dc.w	0			; length
	dc.w	periodBase*7	; frequency
	dc.w	$2f			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioHigh	; priority

;24  - lighting
fxLighting	rs.b	1
	dc.l	14			; pointer
	dc.w	0			; length
	dc.w	periodBase*4	; frequency
	dc.w	$2f			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioHigh	; priority

;25  - boss 0 entry
fxSpawnBoss0	rs.b	1
	dc.l	16			; pointer
	dc.w	0			; length
	dc.w	periodBase*9	; frequency
	dc.w	$3f			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioHigh	; priority


_fxSpeechHero
fxSpeechHero	rs.b	1
	dc.l	0			; pointer ; this is overwritten dynamically
	dc.w	0			; length ""
	dc.w	$1d9	; frequency
	dc.w	$3f			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioTop	; priority

_fxSpeechBaddie
fxSpeechBaddie	rs.b	1
	dc.l	0			; pointer ; this is overwritten dynamically
	dc.w	0			; length ""
	dc.w	$1d0	; frequency
	dc.w	$3f			; volume
	dc.b	channelBest	; which channel?
	dc.b	fxPrioTop	; priority


last
	dc.l 0,0; eof fxtable
	even
