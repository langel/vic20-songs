		processor 6502

		ORG 4097
		
	byte	$0b,$10,$04,$00,$9e,$34,$31,$31,$30,0,0,0,0 ; 10 SYS4109
	
; disable and acknowledge interrupts	
	lda #$7f
	sta $912e     
	sta $912d
  sta $911e 
  
	
	
; setup character map
	ldy #0
load_char_page_1:
	lda $8000,y
	sta $1800,y
	iny
	clc
	cpy #$0
	bne load_char_page_1
	ldy #0
load_char_page_2:
	lda $8100,y
	sta $1900,y
	iny
	clc
	cpy #$0
	bne load_char_page_2
	ldx #0
load_bit_page_1:
	lda smlurlm_bitmap_page_1,x
	sta $1a00,x
	inx
	clc
	cpx #$0
	bne load_bit_page_1
	ldx #$0
load_bit_page_2:
	lda smlurlm_bitmap_page_2,x
	sta $1b00,x
	inx
	clc
	cpx #$0
	bne load_bit_page_2
	
	lda #%11111110
	sta $9005
	
	

; clear screen
	ldy #0
clearing_screen:
	lda #$20
	sta $1e00,y
	sta $1f00,y
	lda #$0
	sta $9600,y
	lda #$2
	sta $9700,y
	iny
	clc
	cpy #$00
; RUN
	bne clearing_screen
	
	
; draw SMLURLM
	ldx #0
	ldy #63
drawing_smlurlm_line1:
	iny
	tya
	sta 7753,x
	clc
	inx
	cmp #73
	bne drawing_smlurlm_line1
	ldx #0
drawing_smlurlm_line2:
	iny
	tya
	sta 7775,x
	clc
	inx
	cmp #83
	bne drawing_smlurlm_line2
	ldx #0
drawing_smlurlm_line3:
	iny
	tya
	sta 7797,x
	clc
	inx
	cmp #93
	bne drawing_smlurlm_line3
	ldx #0
drawing_smlurlm_line4:
	iny
	tya
	sta 7819,x
	clc
	inx
	cmp #103
	bne drawing_smlurlm_line4
	ldx #0
drawing_smlurlm_line5:
	iny
	tya
	sta 7841,x
	clc
	inx
	cmp #113
	bne drawing_smlurlm_line5
	ldx #0
drawing_smlurlm_line6:
	iny
	tya
	sta 7863,x
	clc
	inx
	cmp #123
	bne drawing_smlurlm_line6
	

; start fun with colors and stash it in the datasette ram
	lda #$08
	sta 36879
	sta $033d
	
; set voice value OR modifiers
	lda #$00
	sta $0340
	lda #$40
	sta $0341
	lda #$c0
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
; check if next raster beam is hit
wait_for_next_beam:
	clc
	cpx $9004
	bpl wait_for_next_beam
	inx
; check if zero point raster beam is hit
	clc
	lda #$3f
	cmp $9004
	bpl raster_zero



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
	lda #$1a
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
; cycle through bg colors
	clc
	lda #17
	adc $033d
	cmp #144
	bne colors_no_reset16 
	lda #$08
colors_no_reset16:
	sta 36879
	sta $033d
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
	

smlurlm_bitmap_page_1:
  byte #%00000011
  byte #%00000111
  byte #%00001111
  byte #%00011000
  byte #%00110000
  byte #%01110000
  byte #%01100000
  byte #%11100000

  byte #%11100000
  byte #%11111000
  byte #%11111100
  byte #%00111110
  byte #%00001110
  byte #%00000110
  byte #%00000100
  byte #%00000000

  byte #%00000000
  byte #%00000000
  byte #%00000000
  byte #%01100000
  byte #%11100001
  byte #%11100011
  byte #%11100111
  byte #%11101111

  byte #%00000000
  byte #%00011000
  byte #%00111000
  byte #%11110000
  byte #%11110000
  byte #%11100001
  byte #%11100011
  byte #%11100011

  byte #%00000000
  byte #%00000000
  byte #%01110001
  byte #%11110000
  byte #%11110000
  byte #%11100000
  byte #%11100000
  byte #%11000000

  byte #%00000000
  byte #%00000000
  byte #%11111111
  byte #%11111110
  byte #%11111000
  byte #%01110000
  byte #%01110000
  byte #%01110000

  byte #%00000000
  byte #%00000001
  byte #%11100001
  byte #%11111000
  byte #%00111100
  byte #%00011110
  byte #%00001110
  byte #%00000110

  byte #%00110000
  byte #%00011000
  byte #%11001110
  byte #%11100111
  byte #%01100011
  byte #%01100011
  byte #%01110011
  byte #%00110011

  byte #%00000011
  byte #%00000011
  byte #%00000011
  byte #%00000011
  byte #%11000011
  byte #%11100011
  byte #%11110011
  byte #%01111011

  byte #%00000000
  byte #%10000000
  byte #%10000000
  byte #%11000000
  byte #%11100000
  byte #%11100000
  byte #%11110000
  byte #%11110000

  byte #%11100000
  byte #%11100000
  byte #%11100000
  byte #%11100000
  byte #%11110000
  byte #%01111000
  byte #%00111000
  byte #%00011100

  byte #%00000001
  byte #%00000001
  byte #%00000011
  byte #%00000011
  byte #%00000011
  byte #%00000111
  byte #%00000110
  byte #%00000110

  byte #%11111111
  byte #%11111110
  byte #%11111100
  byte #%11111000
  byte #%00111000
  byte #%00110000
  byte #%00110000
  byte #%00100000

  byte #%11100111
  byte #%11100111
  byte #%11100111
  byte #%11000111
  byte #%11001110
  byte #%11001110
  byte #%11001110
  byte #%11001110

  byte #%11000000
  byte #%10000000
  byte #%10000000
  byte #%00000000
  byte #%00000000
  byte #%00000000
  byte #%00000000
  byte #%00000000

  byte #%00111000
  byte #%00111100
  byte #%00111100
  byte #%00111110
  byte #%00011110
  byte #%00011110
  byte #%00011110
  byte #%00011111

  byte #%00000110
  byte #%00000110
  byte #%00000110
  byte #%00000110
  byte #%00000110
  byte #%00000110
  byte #%00001110
  byte #%00001100

  byte #%00110011
  byte #%00110011
  byte #%00110011
  byte #%00110011
  byte #%00110011
  byte #%00111001
  byte #%00111001
  byte #%00011001

  byte #%00111111
  byte #%10111111
  byte #%10011111
  byte #%10001111
  byte #%10001111
  byte #%10001111
  byte #%10000111
  byte #%10000011

  byte #%11111000
  byte #%01111000
  byte #%00111100
  byte #%00111110
  byte #%00111110
  byte #%00111110
  byte #%00111110
  byte #%00011110

  byte #%00011100
  byte #%00001110
  byte #%00000111
  byte #%00000011
  byte #%00000001
  byte #%00000000
  byte #%00000000
  byte #%00000000

  byte #%00000110
  byte #%00000110
  byte #%00000110
  byte #%10000110
  byte #%10000110
  byte #%11000110
  byte #%01000110
  byte #%01100110

  byte #%00100000
  byte #%00000000
  byte #%00000000
  byte #%00000000
  byte #%00000000
  byte #%00000000
  byte #%00000000
  byte #%00000001

  byte #%11001110
  byte #%11001100
  byte #%11001100
  byte #%11001100
  byte #%11001100
  byte #%11001100
  byte #%11001100
  byte #%11001100

  byte #%00000000
  byte #%00000000
  byte #%00000000
  byte #%00000000
  byte #%01000000
  byte #%11100000
  byte #%11110000
  byte #%11110000

  byte #%00001111
  byte #%00001111
  byte #%10001111
  byte #%10001111
  byte #%10001111
  byte #%11001111
  byte #%11000111
  byte #%01100111

  byte #%00011100
  byte #%00011000
  byte #%00111000
  byte #%11111100
  byte #%10011110
  byte #%00001111
  byte #%00000111
  byte #%00000011

  byte #%00011001
  byte #%00011001
  byte #%00011001
  byte #%00010000
  byte #%00010000
  byte #%00010000
  byte #%10010000
  byte #%10010000

  byte #%10000011
  byte #%10000011
  byte #%10000001
  byte #%10000001
  byte #%10000000
  byte #%10000000
  byte #%10000000
  byte #%10000000

  byte #%00011100
  byte #%00011000
  byte #%00011000
  byte #%00010000
  byte #%00010000
  byte #%00011000
  byte #%00001000
  byte #%00001000

  byte #%01111000
  byte #%11111100
  byte #%11111100
  byte #%11111100
  byte #%11111100
  byte #%01111100
  byte #%01111000
  byte #%01111000

  byte #%00100110
  byte #%00110110
  byte #%00110110
  byte #%00010110
  byte #%00010110
  byte #%00010110
  byte #%00010110
  byte #%00010100
  
smlurlm_bitmap_page_2:
  byte #%00000001
  byte #%00000001
  byte #%00000001
  byte #%00000001
  byte #%00000001
  byte #%00000001
  byte #%00000001
  byte #%00000001

  byte #%11001001
  byte #%11001001
  byte #%11001001
  byte #%11001001
  byte #%10001001
  byte #%00001001
  byte #%00001001
  byte #%00010001

  byte #%11110000
  byte #%11110000
  byte #%11000000
  byte #%11000000
  byte #%11000000
  byte #%11000000
  byte #%10000000
  byte #%10000000

  byte #%01100111
  byte #%01110111
  byte #%00110011
  byte #%00110011
  byte #%00110011
  byte #%00110011
  byte #%00110011
  byte #%00110011

  byte #%00000011
  byte #%00000011
  byte #%10000011
  byte #%10000011
  byte #%00000011
  byte #%00000011
  byte #%00000001
  byte #%00000001

  byte #%10010000
  byte #%10010000
  byte #%10010000
  byte #%10010000
  byte #%10010000
  byte #%10010000
  byte #%10010000
  byte #%10010000

  byte #%10000000
  byte #%10000000
  byte #%10000000
  byte #%10000000
  byte #%10000000
  byte #%10000000
  byte #%10000000
  byte #%10000000

  byte #%00001000
  byte #%00001000
  byte #%00001000
  byte #%00001000
  byte #%00001000
  byte #%00001000
  byte #%00001000
  byte #%00001000

  byte #%01110000
  byte #%01100000
  byte #%01100000
  byte #%01100000
  byte #%01100000
  byte #%01100000
  byte #%01100000
  byte #%01100000

  byte #%00010100
  byte #%00010100
  byte #%00110100
  byte #%00110100
  byte #%00110100
  byte #%01110100
  byte #%01100100
  byte #%01100100

  byte #%00000001
  byte #%00000001
  byte #%00000001
  byte #%00000001
  byte #%00000001
  byte #%00000001
  byte #%00000001
  byte #%00000001

  byte #%00010001
  byte #%00010001
  byte #%00010001
  byte #%00010001
  byte #%00010001
  byte #%00010001
  byte #%00010001
  byte #%00010001

  byte #%10000000
  byte #%10000000
  byte #%10000000
  byte #%10000000
  byte #%10000000
  byte #%10000000
  byte #%11000000
  byte #%11000000

  byte #%00110001
  byte #%00110001
  byte #%00110001
  byte #%00111001
  byte #%00111001
  byte #%00111001
  byte #%00111001
  byte #%00111001

  byte #%00000001
  byte #%00000001
  byte #%00000001
  byte #%00000001
  byte #%00000001
  byte #%00000001
  byte #%00000001
  byte #%00000001

  byte #%10010000
  byte #%10010000
  byte #%10010000
  byte #%10010000
  byte #%10010000
  byte #%00010000
  byte #%00010000
  byte #%00010000

  byte #%10000000
  byte #%10000000
  byte #%10000000
  byte #%10000000
  byte #%10000000
  byte #%10000000
  byte #%10000000
  byte #%10000000

  byte #%00001000
  byte #%00001000
  byte #%00001000
  byte #%00001000
  byte #%00001000
  byte #%00001000
  byte #%00001000
  byte #%00001000

  byte #%01100000
  byte #%01110000
  byte #%01110000
  byte #%01110001
  byte #%01110111
  byte #%00111111
  byte #%00111110
  byte #%00000000

  byte #%01100100
  byte #%11100100
  byte #%11100100
  byte #%11000100
  byte #%10000100
  byte #%10000100
  byte #%00000000
  byte #%00000000

  byte #%00000001
  byte #%00000001
  byte #%00000001
  byte #%00000001
  byte #%00000001
  byte #%00000001
  byte #%00000000
  byte #%00000000

  byte #%00010001
  byte #%00010001
  byte #%00010001
  byte #%00010000
  byte #%00010000
  byte #%00010000
  byte #%00000000
  byte #%00000000

  byte #%11000000
  byte #%11100000
  byte #%11100000
  byte #%11110111
  byte #%01111111
  byte #%00111111
  byte #%00000000
  byte #%00000000

  byte #%00111001
  byte #%01101001
  byte #%11101001
  byte #%11001001
  byte #%11001001
  byte #%00001000
  byte #%00000000
  byte #%00000000

  byte #%00000001
  byte #%00000001
  byte #%00000001
  byte #%00000001
  byte #%00000000
  byte #%00000000
  byte #%00000000
  byte #%00000000

  byte #%00010000
  byte #%00010000
  byte #%00010000
  byte #%00010000
  byte #%00010000
  byte #%00000000
  byte #%00000000
  byte #%00000000

  byte #%10000000
  byte #%10000000
  byte #%10000000
  byte #%10000000
  byte #%10000000
  byte #%00000000
  byte #%00000000
  byte #%00000000

  byte #%00001000
  byte #%00001000
  byte #%00001000
  byte #%00001000
  byte #%00001000
  byte #%00001000
  byte #%00001000
  byte #%00000000
