		processor 6502

		ORG 4097
		
	byte	$0b,$10,$04,$00,$9e,$34,$31,$31,$30,0,0,0,0 ; 10 SYS4109


pattern_pos equ $033c
drum_pos equ $033d
drum_pos_ticks equ $033e
drum_pos_length equ #7
macro_type equ $0340
macro_pos equ $0341
bass_stor equ $0342
alto_stor equ $0343
sopr_stor equ $0344
nois_stor equ $0345
bass equ $900a
alto equ $900b
sopr equ $900c
nois equ $900d
vol equ $900e
	
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
	lda #$02
	sta $9600,y
	sta $9700,y
	iny
	clc
	cpy #$00
; RUN
	bne clearing_screen
	
; init volume
	lda #$0f
	sta vol

;	init song ram
	lda #$00
	ldy #0
clearing_tape_ram:
	sta pattern_pos,y
	iny
	clc
	cpy #$bf ; 191 bytes in tape buffer
	bne clearing_tape_ram


;	wait for raster beam to return home
;	this is the base tempo
raster_zero:
	clc
	lda #$20
	cmp $9004
	bne raster_zero

program_loop:
	lda #$08
	sta 36879
	jsr play_routine
	lda #$00
	sta 36879
	jmp raster_zero
	
	
play_routine:

; apply pattern data
	ldy pattern_pos
	lda pattern_data,y
	cmp #$2
	bne skip_pattern_reset
	ldy #0
	sty pattern_pos
skip_pattern_reset
; process bass
	lda pattern_data,y
	cmp #$1
	bne skip_bass_stor
	lda bass_stor
skip_bass_stor
	sta bass
	sta bass_stor
	iny
; process alto
	lda pattern_data,y
	cmp #$1
	bne skip_alto_stor
	lda alto_stor
skip_alto_stor
	sta alto
	sta alto_stor
	iny
; process sopr
	lda pattern_data,y
	cmp #$1
	bne skip_sopr_stor
	lda sopr_stor
skip_sopr_stor
	sta sopr	
	sta sopr_stor
	iny
; process nois
	lda pattern_data,y
	cmp #$1
	bne skip_nois_stor
	lda nois_stor
skip_nois_stor
	sta nois
	sta nois_stor
	iny
	sty pattern_pos


	jmp skip_drum_macro

	
; apply drum/macro data
; check tick count
	lda drum_pos_ticks
	cmp #0
	beq drum_pattern_next_pos
	jmp skip_pattern_pos
drum_pattern_next_pos:
	ldy drum_pos
	lda drum_pattern,y
	cmp #$ff
	bne skip_drum_pattern_reset
	ldy #0
	sty drum_pos
skip_drum_pattern_reset:
	lda drum_pattern,y
	sta macro_type
	lda #0
	sta macro_pos
skip_pattern_pos:
	inc drum_pos_ticks
	lda drum_pos_ticks
	cmp drum_pos_length
	bne skip_next_pos
	lda #0
	sta drum_pos_ticks
	inc drum_pos
skip_next_pos:
; check for macro
	ldy macro_type
	cpy #0
	beq skip_drum_macro
	
; apply macro data
	ldy macro_pos
	jsr load_macro_byte_y
	cmp #$2
	bne skip_macro_end
	ldy #0
	sty macro_pos
	sty macro_type
	jmp skip_drum_macro
skip_macro_end
; process bass
	ldy macro_pos
	jsr load_macro_byte_y
	cmp #$3
	bne skip_bass_macro
	jsr load_macro_byte_y
	sta bass
skip_bass_macro
	iny
; process alto
	jsr load_macro_byte_y
	cmp #3
	bne skip_alto_macro
	jsr load_macro_byte_y
	sta alto
skip_alto_macro
	iny
; process sopr
	jsr load_macro_byte_y
	cmp #$3
	bne skip_sopr_macro
	jsr load_macro_byte_y
	sta sopr	
skip_sopr_macro
	iny
; process nois
	jsr load_macro_byte_y
	cmp #$3
	bne skip_nois_macro
	jsr load_macro_byte_y
	sta nois
skip_nois_macro
	iny
	sty macro_pos

skip_drum_macro:


; $034e = value to display
; $034f = screen placement
	lda macro_type
	sta $034e
	jsr display_hex
	rts




pattern_data:
	byte 225,203,163,$0
	byte $1,$1,$1,$0
	byte $1,$1,$1,$0
   byte $1,$1,$1,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte 225,203,163,$0
	byte $1,$1,$1,$0
	byte $1,$1,$1,$0
   byte $1,$1,$1,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte 225,203,163,$0
	byte $1,$1,$1,$0
	byte $1,$1,$1,$0
   byte $1,$1,$1,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $0,$0,$0,$0
	byte $2

drum_pattern:
	byte 1,3,2,3
	byte $ff

load_macro_byte_y:
	lda macro_type
	clc
	cmp #1
	bne skip_kick_load
	jsr load_kick_data
	rts
skip_kick_load
	lda macro_type
	clc
	cmp #2
	bne skip_snar_load
	jsr load_snar_data
	rts
skip_snar_load
	jsr load_hat_data
	rts

; kick drum
load_kick_data:
	lda kick_pattern,y
	rts
kick_pattern:
	byte 225,$3,$3,$3
	byte 135,$3,$3,$3
	byte 129,$3,$3,$3
	byte 225,$3,$3,$3
	byte 135,$3,$3,$3
	byte 129,$3,$3,$3
	byte $2

; snar_drum
load_snar_data:
	lda snar_pattern,y
	rts
snar_pattern:
	byte $3,$3,$3,200
	byte $3,$3,$3,180
	byte $3,$3,$3,140
	byte $3,$3,$3,200
	byte $3,$3,$3,180
	byte $3,$3,$3,140
	byte $2

; hat
load_hat_data:
	lda hat_pattern,y
	rts
hat_pattern:
	byte $3,$3,$3,250
	byte $3,$3,$3,250
	byte $3,$3,$3,250
	byte $3,$3,$3,250
	byte $3,$3,$3,250
	byte $2



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
	byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$01,$02,$03,$04,$05,$0
