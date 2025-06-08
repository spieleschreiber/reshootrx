
;	#MARK: - SPRITE PARALLAX MANAGER
ParallaxManager        ; handles building of background layer. d0 = no. of map mixed into basic layer. Max. 15 maps
    ; set parallax sprite colors
   ; SAFECOPPER	; take care that copper doesnt change colorreg offset

								move.l				#parallaxSpriteA,d1																																																							; load and prepare parallax sprite data (saved as 64 pixel sprite no ctrl bytes, A = 512 pixels height, B=384 pixels height). filename: parSpritex
								move.l				spriteParallaxBuffer+4(pc),d2
								move.l				#spriteParallaxBufferSize/2,d3
								bsr					createFilePathOnStage
								jsr					loadFile
								tst.l				d0
								beq					errorDisk																																																									;

								move.l				#parallaxSpriteB,d1																																																							; load and prepare parallax sprite data (saved as 64 pixel sprite with ctrl bytes, spriteParallaxHeight-1 = 241). filename: parSpritex
								move.l				spriteParallaxBuffer+8(pc),d2
								move.l				#spriteParallaxBufferSize/2,d3
   	;move.l #100,fd3
								bsr					createFilePathOnStage
								bsr					loadFile
								tst.l				d0
								beq					errorDisk
								rts
