		processor 6502

		ORG 4097
		
	byte	$0b,$10,$04,$00,$9e,$34,$31,$31,$30,0,0,0,0 ; 10 SYS4109
	
; disable and acknowledge interrupts	
	lda #$7f
	sta $912e     
	sta $912d
  sta $911e 
  
; clear screen
	lda #$20
	ldy #0
	clc
clearing_screen:
	sta $1E00,y
	iny
	cpy #$ff
; RUN
	bne clearing_screen

; start fun with colors and stash it in the datasette ram
	lda #$08
	sta 36879
	sta $033d
	
; set voice value OR modifiers
	lda #$90
	sta $0340
	lda #$70
	sta $0341
	lda #$30
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
	
	
	
raster_zero:

; do raster tricks?!?!
; cycle through bg colors
	clc
	lda #17
	adc $900f
	cmp #144
	bne raster_colors_no_reset 
	lda #$08
raster_colors_no_reset:
	sta $900f
	ldx $9004
	inx
; check if next raster beam is hit
wait_for_next_beam:
	clc
	cpx $9004
	bpl wait_for_next_beam
; check if zero point raster beam is hit

	clc
	lda #$60
	cmp $9004
	bne raster_zero



program_loop:
	lda #$08
	sta 36879
	jsr raster_one
	jsr play_routine
	jsr display_ram
	jsr modifier_pulse
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
	lda #$0d
	clc
	cmp 36878
	bne sound_toggle_stash
	lda #$09
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
	
	
	
modifier_pulse:
	inc $033c
	lda $033c
	clc
	cmp #32
	beq step_32_updates
	clc
	lda $033c
	cmp #16
	lda $033d
	sta 36879
	rts
	
step_32_updates:
; update_voice_bit_modifiers
	inc $0340
	inc $0341
	inc $0341
	dec $0342
; cycle through bg colors
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

voice0_begin:
	lda #23
	sta $034f
	lda $900a
	clc
	cmp #$80
	bpl voice0_display_hex
	jsr clear_hex
	jmp voice1_begin
voice0_display_hex:
	sta $034e
	jsr display_hex
	
voice1_begin:
	lda #27
	sta $034f
	lda $900b
	clc
	cmp #$80
	bpl voice2_display_hex
	jsr clear_hex
	jmp voice3_begin
voice2_display_hex:
	sta $034e
	jsr display_hex
	
voice3_begin:
	lda #31
	sta $034f
	lda $900c
	clc
	cmp #$80
	bpl voice3_display_hex
	jsr clear_hex
	jmp voice4_begin
voice3_display_hex:
	sta $034e
	jsr display_hex
	
voice4_begin:
	lda #35
	sta $034f
	lda $900d
	clc
	cmp #$80
	bpl voice4_display_hex
	jsr clear_hex
	jmp voices_display_done
voice4_display_hex:
	sta $034e
	jsr display_hex

voices_display_done:
	
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