; functions for handling 8bit hex display on screen


clear_hex:
; $034f = screen placement
	lda #$20
	ldx $034f
	sta 8100,x
	inx
	sta 8100,x
	rts
	

display_hex:
; $034e = value to display
; $034f = screen placement
; handle first character
	lda $034e
	lsr
	lsr
	lsr
	lsr
	tax
	lda hex_characters,x
	ldx $034f
	sta 8100,x
; handle second character
	lda $034e
	and #%00001111
	tax
	lda hex_characters,x
	ldx $034f
	inx
	sta 8100,x
	rts
	

hex_characters:
	byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$01,$02,$03,$04,$05,$06
	

