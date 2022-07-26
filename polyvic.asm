
	processor 6502

	ORG 4097

	byte	$0b,$10,$04,$00,$9e,$34,$31,$31,$30,0,0,0,0 ; 10 SYS4109



pu1		EQM	$900a
pu2		EQM	$900b
pu3		EQM	$900c
noi		EQM	$900d
vol		EQM	$900e

wtf		EQM	$0340
hex_display_value		EQM	$034e
hex_display_pos		EQM	$034f
pu1_beat_counter		EQM	$0350
pu2_beat_counter		EQM	$0351
pu3_beat_counter		EQM	$0352
noi_sweep_counter		EQM	$0353

	; disable and acknowledge interrupts	
	lda #$7f
	sta $912e     
	sta $912d
	sta $911e 
  
	


init_sound:
	lda #$00
	sta pu1
	sta pu2
	sta pu3
	sta noi
	lda #$0f
	sta vol

	jsr init_song


; =====			MAIN
program_loop:

raster_one:
	lda #$1a
	cmp $9004
	bne raster_one


	lda #$08
	sta 36879

	jsr play_routine
	inc wtf
	; display wtf
	lda wtf
	sta hex_display_value
	lda #22
	sta hex_display_pos
	jsr hex_display
	lda #57
	sta hex_display_pos
	jsr hex_display

	lda #$26
	sta 36879

	jmp program_loop
	
	


init_song: subroutine
	lda #$00
	sta pu1_beat_counter
	sta pu2_beat_counter
	sta pu3_beat_counter
	lda #$80
	sta noi_sweep_counter
	rts



pu1_beat_pattern: ; 3
	byte $a0,$a0,$7f,$7f
	byte $a0,$a0,$7f,$7f,$7f,$7f,$7f,$7f
	byte $00

pu2_beat_pattern: ; 5
	byte $a0,$a0,$7f,$7f,$7f,$7f
	byte $7f,$7f,$7f,$7f
	byte $00

pu3_beat_pattern: ; 7
	byte $a0,$a0,$7f,$7f,$7f,$7f
	byte $a0,$a0,$7f,$7f,$7f,$7f
	byte $7f,$7f,$00



play_routine: subroutine

; PU1
	lda wtf
	and #$03
	bne .dont_pu1
	ldx pu1_beat_counter
	lda pu1_beat_pattern,x
	bne .dont_reset_pu1_counter
	ldx #$00
	stx pu1_beat_counter
	lda pu1_beat_pattern,x
.dont_reset_pu1_counter
	sta pu1
	inc pu1_beat_counter
.dont_pu1

; PU2
	lda wtf
	and #$03
	bne .dont_pu2
	ldx pu2_beat_counter
	lda pu2_beat_pattern,x
	bne .dont_reset_pu2_counter
	ldx #$00
	stx pu2_beat_counter
	lda pu2_beat_pattern,x
.dont_reset_pu2_counter
	sta pu2
	inc pu2_beat_counter
.dont_pu2

; PU3
	lda wtf
	and #$03
	bne .dont_pu3
	ldx pu3_beat_counter
	lda pu3_beat_pattern,x
	bne .dont_reset_pu3_counter
	ldx #$00
	stx pu3_beat_counter
	lda pu3_beat_pattern,x
.dont_reset_pu3_counter
	sta pu3
	inc pu3_beat_counter
.dont_pu3

; NOI
; hat?
	lda wtf
	and #$07
	beq .hat
	inc noi_sweep_counter
	lda wtf
	and #$01
	bne .no_noi
	lda noi_sweep_counter
	sta noi
	rts
.no_noi:
	lda #$00
	sta noi
	rts
.hat
	lda #$fa
	sta noi
.no_hat
	rts



hex_display:
; $034e = value to display
; $034f = screen placement
; handle first character
	lda hex_display_value
	ldx hex_display_pos
	lsr
	lsr
	lsr
	lsr
	tay
	lda hex_characters,y
	sta 8100,x
; handle second character
	lda $034e
	and #%00001111
	tay
	lda hex_characters,y
	inx
	sta 8100,x
	rts
	
hex_characters:
	byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$01,$02,$03,$04,$05,$06
