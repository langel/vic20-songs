
hex_characters:
	byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$01,$02,$03,$04,$05,$06

hex_display: subroutine
	; temp01 = value to display
	; temp02 = screen position low byte
	; temp03 = screen position high byte
	lda wtf
	sta SCREEN_RAM+100
	ldy #$00
	lda temp01
	lsr
	lsr
	lsr
	lsr
	tax
	lda hex_characters,x
	sta (temp02),y
	sta SCREEN_RAM+96
	iny
	lda temp01
	and #%00001111
	tax
	lda hex_characters,x
	sta (temp02),y
	sta SCREEN_RAM+97
	rts
