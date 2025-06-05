	;May use d0,d4,d5,d6,d7,a1,a3. May manipulate a0 to alter bitmap load adress or use a0 if return to bobblitnext / not animreturn


    ;	#MARK: - Control VFX Layer


    ;trig0 inits vfx scroll pace and direction modification. Exmaples of valid values:
    ;trig1024	do nothing
	;trig1025	fastest southbound
	;trig1027	medium	southbound
	;trig1032	slowest southbound
	;trig1033	stop
	;trig1034	slowest northbound
	;trig1039	fastest northbound


	; speed of scrolling is determined by lifetime of object - as simple as that!
vfxController

	tst.b plyBase+plyWeapUpgrade(pc)
	bmi objectListNextEntry	; player death scene playing, leave scrolling unmodified
	;tst.b objectListTriggers+1(a2)
	;bne .copyVfx
.cont
	lea viewPosition+vfxPositionAdd(pc),a1
	clr.w d7
	move.b objectListTriggers(a2),d7
	bne .getScrollingOffset
	moveq #31-16,d6
	and.b frameCount+3(pc),d6
	bne .quit
	move.b objectListTriggersB(a2),d7
	ext.w d7
	add.w d7,(a1)

.quit
	bra objectListNextEntry
.getScrollingOffset
	move.b objectListTriggers(a2),d7;; desired speed
	move.b .scrollPacing(pc,d7),d7
	ext.w d7
	;MSG01 m2,d7
	move.w (a1),d6	; current speed
	sub.w d6,d7
	smi.b d6
	ext.w d6
	eor.w d6,d7	; make positive
	asr.w #1,d7	; timer
	;MSG02 m2,d7
	move.b d7,objectListLoopCnt(a2)

	andi.b #$fe,d6
	add.b #1,d6
	;MSG01 m2,d6
	move.b d6,objectListTriggersB(a2)
	sf.b objectListTriggers(a2)
	bra objectListNextEntry
.scrollPacing
	dc.b 0,32,16,12,8,5,3,1
	dc.b 0,-1,-3,-5,-8,-12,-16,-32
