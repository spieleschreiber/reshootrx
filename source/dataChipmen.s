



; - Misc Data -
	cnop		0,8
	blk.l		spriteLineOffset/4
infoPanelScore
	blk.l		spriteScoreHeight*spriteLineOffset/4
	blk.l		spriteLineOffset/4
infoPanelStatus	; save as sprite, 64 pixel wide, 25 pixel high, no ctrl bytes
	INCBIN		incbin/infoPanel.raw
	;blk.l spriteScoreHeight*spriteLineOffset/4	; empty display

; MARK: - Level Data -

	cnop		0,8
titleSprites            ; 6 sprites 64 x 40 pixels. Save as 64 px wide sprites, 40 px high, ctrl words
	INCBIN		incbin/title/logo_letters.raw
titleSpritesOffset	=	(*-titleSprites)/6
titleNumber
	Incbin		incbin/title/logo_number.raw
titleSpritesPalette
	Incbin		incbin/palettes/titleSprites.pal
titleSpieleschreiber
	Incbin		incbin/title/spieleschreiber.raw
titleSpieleschreiberEnd

	cnop		0,8
escalationBitmap
	INCBIN		incbin/escalation.raw

	cnop		0,8
spritePlayerContainer; pixel data 64 px wide, 52 px high, save as 32 pixel wide sprites, no attach, no ctrlword
	Incbin		incbin/player/weaponContainer.raw
	IFNE		PLAYERSPRITEDITHERED
spritePlayerBasic	; save as 32 px high, 64 px wide attached sprite, no ctrl words
	Incbin		incbin/player/shipDith_0a.raw
	Incbin		incbin/player/shipIll_0a.raw
spritePlayerBasicEnd
	Incbin		incbin/player/shipDith_0b.raw			; move left
	Incbin		incbin/player/shipIll_0b.raw
	Incbin		incbin/player/shipDith_0c.raw			; move right
	Incbin		incbin/player/shipIll_0c.raw
	ELSE
spritePlayerBasic	; save as 32 px high, 64 px wide attached sprite, no ctrl words
	Incbin		incbin/player/ship_0a.raw
	Incbin		incbin/player/shipIll_0a.raw
spritePlayerBasicEnd
	Incbin		incbin/player/ship_0b.raw				; move left
	Incbin		incbin/player/shipIll_0b.raw
	Incbin		incbin/player/ship_0c.raw				; move right
	Incbin		incbin/player/shipIll_0c.raw
	ENDIF
infoPanelMultiDisplay	; mirrored version of bitmap in infoPanelMultiply, fading out
	blk.b		infoPanelDidIt-infoPanelMultiply,0
	PRINTV		infoPanelDidIt-infoPanelMultiply

