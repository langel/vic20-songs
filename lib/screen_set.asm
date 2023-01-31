
screen_set_char: subroutine
	; a = char id to fill screen char ram
	ldy #$0
.loop
	sta SCREEN_RAM,y
	sta SCREEN_RAM+$100,y
	iny
	bne .loop
	rts


screen_set_color: subroutine
	; a = color id to fill screen color ram
	ldy #$0
.loop
	sta COLOR_RAM,y
	sta COLOR_RAM+$100,y
	iny
	bne .loop
	rts

