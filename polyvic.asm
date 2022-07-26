
	processor 6502

	ORG 4097

	byte	$0b,$10,$04,$00,$9e,$34,$31,$31,$30,0,0,0,0 ; 10 SYS4109

	; disable and acknowledge interrupts	
	lda #$7f
	sta $912e     
	sta $912d
	sta $911e 
  
	
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
	bne clearing_screen


	
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
	;jsr play_routine
	;jsr display_ram
	;jsr modifier_pulse
	jmp raster_zero
	
	
raster_one:
	clc
	lda #$1a
	cmp $9004
	bne raster_one_loop
	rts
raster_one_loop:
	jmp raster_one
	
	
