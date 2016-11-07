		processor 6502

		ORG 4097
		
	byte	$0b,$10,$04,$00,$9e,$34,$31,$31,$30,0,0,0,0 ; 10 SYS4109
	
; disable and acknowledge interrupts	
	lda #$7f
	sta $912e     
	sta $912d
  sta $911e 

; star fun with colors and stash it in the datasette ram
	lda #$08
	sta 36879
	sta $033d
	
; set voice value OR modifiers
	lda #$20
	sta $0340
	lda #$60
	sta $0341
	lda #$b0
	sta $0342
	
; init volume
	lda #$0f
	sta 36878
	
; starter seeds
	ldx #96
	ldy #192
	stx $0350
	sty $0351
	stx $0352
	sty $0353
	
view_chars:
	lda #$
	
	
raster_zero:
	clc
	lda #$60
	cmp $9004
	bne raster_zero


program_loop:
	lda #$08
	sta 36879
	jsr play_routine
	jsr display_ram
	jsr raster_one
	jsr colors
	jmp raster_zero
	
	
raster_one:
	clc
	lda #$7f
	cmp $9004
	bne raster_one_loop
	rts
raster_one_loop:
	jmp raster_one
	
	
	
play_routine:

; toggle volume
	lda #$06
	clc
	cmp 36878
	bne sound_toggle_stash
	lda #$04
sound_toggle_stash:
	sta 36878
	
; update voice data
	lda $0350
	ora $0341
	tax
	stx $900a
	inx
	stx $0350
	lda $0351
	ora $0341
	sta $900b
	ldx $0351
	dex
	stx $0351
	lda $0352
	ora $0340
	sta $900c
	tax
	inx
	stx $0352
	lda $0353
	ora $0342
	tax
	sta $900d
	ldx $0353
	dex
	stx $0353
	
	rts
	
	
update_voice_bit_modifiers:
	inc $0340
	inc $0341
	inc $0341
	dec $0342
	rts
	
	
colors:
	inc $033c
	lda $033c
	clc
	cmp #32
	beq colors_change
	clc
	lda $033c
	cmp #16
	lda $033d
	sta 36879
	rts
colors_change:
	jsr update_voice_bit_modifiers
	lda #$00
	sta $033c
	clc
	lda #17
	adc $033d
	cmp #144
	bne colors_no_reset 
	lda #$08
colors_no_reset:
	sta 36879
	sta $033d
	rts
	
	
display_ram:
; display voice data
	lda $900a
	sta $034e
	lda #23
	sta $034f
	jsr display_hex
	lda $900b
	sta $034e
	lda #27
	sta $034f
	jsr display_hex
	lda $900c
	sta $034e
	lda #31
	sta $034f
	jsr display_hex
	lda $900d
	sta $034e
	lda #35
	sta $034f
	jsr display_hex
; display voice bit modifier data
	lda $0341
	sta $034e
	lda #45
	sta $034f
	jsr display_hex
	lda $0341
	sta $034e
	lda #49
	sta $034f
	jsr display_hex
	lda $0340
	sta $034e
	lda #53
	sta $034f
	jsr display_hex
	lda $0342
	sta $034e
	lda #57
	sta $034f
	jsr display_hex
;display offsetters
	lda $0350
	sta $034e
	lda #67
	sta $034f
	jsr display_hex
	lda $0351
	sta $034e
	lda #71
	sta $034f
	jsr display_hex
	lda $0352
	sta $034e
	lda #75
	sta $034f
	jsr display_hex
	lda $0353
	sta $034e
	lda #79
	sta $034f
	jsr display_hex

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