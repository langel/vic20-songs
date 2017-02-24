; functions for handling 8bit hex display on screen


clear_hex:
; $034f = screen placement
	lda #$20
	ldx $034f
	sta $1e00,x
	inx
	sta $1e00,x
	rts
	

; DISPLAY BINARY
display_binary:
; $034e = value to display
; $034f = screen placement
	lda $034e
	ldy #$08
	ldx $034f
display_binary_loop:
	lda #$80
	bit $034e
	beq display_binary_bit_unset
display_binary_bit_set:
; I WANT THE BALL
	lda #81
	jmp display_binary_chr_print
display_binary_bit_unset:
; EMPTY SPACE
	lda #$20
display_binary_chr_print:
	sta $1e00,x
	dey
	tya
	cmp #$00
	bne display_binary_loop_again
	rts
display_binary_loop_again:
	inx
	asl $034e
	jmp display_binary_loop



; DISPLAY HEX
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
	sta $1e00,x
; handle second character
	lda $034e
	and #%00001111
	tax
	lda hex_characters,x
	ldx $034f
	inx
	sta $1e00,x
	rts
	

hex_characters:
	byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$01,$02,$03,$04,$05,$06
	

