	; 
	;	SCREEN SETUP R&D
	;
	;	shows values for the following --
	;	x,y position of inner screen
	;	x,y size of inner screen
	;	y position of raster beam
	;


	processor 6502

	ORG 4097
		

KEYBOARD_BITS equ $80
RASTER_LINE equ $81
RASTER_MAX equ $82


; 10 SYS4109
	byte	$0b,$10,$04,$00,$9e,$34,$31,$31,$30,0,0,0,0
	

; disable and acknowledge interrupts	
	lda #$7f
	sta $912e     
	sta $912d
	sta $911e 
; no interrupts for sho!
	sei
; no decimal mode!
	cld


; clear screen
	ldy #0
clearing_screen:
	lda #$20
	sta $1e00,y
	sta $1f00,y
	lda #$0
	sta $9600,y
	lda #$0
	sta $9700,y
	iny
	clc
	cpy #$00
	bne clearing_screen

; set initial raster line 
	lda #$10
	sta RASTER_LINE
	jsr raster_set_max

; jump to main
	jmp MAIN




; RASTER
raster_wait:
; hex 17 is off screen on NTSC
	lda RASTER_LINE
	cmp $9004
	bne raster_wait
	rts

raster_set_max:
; restart raster beam
	clc
	lda #$01
	cmp $9004
	bne raster_set_max
raster_set_max_wait_for_zero:
	tay
; raster beam at 0
	lda $9004
	cmp #$00
	bne raster_set_max_wait_for_zero
; max raster stored in Y
	sty RASTER_MAX
	rts

raster_make_valid:
	lda RASTER_MAX
	cmp RASTER_LINE
	bcc raster_fix_raster_line
	rts
raster_fix_raster_line:
	lda RASTER_MAX
	sta RASTER_LINE
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
	stx $900f
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



; DISPLAY DATA
display_data:
	lda #$78
	sta $900f
	; raster position
	lda #$2e
	sta $034f
	lda RASTER_LINE
	sta $034e
	jsr display_hex
	; raster max
	lda #$31
	sta $034f
	lda RASTER_MAX
	sta $034e
	jsr display_hex
	; screen position x
	lda #$34
	sta $034f
	lda $9000
	sta $034e
	jsr display_hex
	; screen position y
	lda #$37
	sta $034f
	lda $9001
	sta $034e
	jsr display_hex
	; screen width
	lda #$3a
	sta $034f
	lda $9002
	sta $034e
	jsr display_hex
	; screen height
	lda #$3d
	sta $034f
	lda $9003
	sta $034e
	jsr display_hex
	; return to sender!!
	rts


; KEYBOARD
keyboard_read:
	; reset keybaord bits
	lda #$00
	sta KEYBOARD_BITS
	; check commodore key
	lda #$df
	sta $9120
	lda $9121
	and #$01
	cmp #$01
	beq keyboard_no_commodore_key
	lda KEYBOARD_BITS
	ora #$01
	sta KEYBOARD_BITS
keyboard_no_commodore_key:
	; check left shift key
	lda #$f7
	sta $9120
	lda $9121
	and #$02
	cmp #$02
	beq keyboard_no_left_shift_key
	lda KEYBOARD_BITS
	ora #$02
	sta KEYBOARD_BITS	
keyboard_no_left_shift_key:
	; check right shift key
	lda #$ef
	sta $9120
	lda $9121
	and #$40
	cmp #$40
	beq keyboard_no_right_shift_key
	lda KEYBOARD_BITS 
	ora #$02
	sta KEYBOARD_BITS
keyboard_no_right_shift_key:
	; check right key
	lda #$fb
	sta $9120
	lda $9121
	and #$80
	cmp #$80
	beq keyboard_no_right_key
	lda KEYBOARD_BITS
	ora #$04
	sta KEYBOARD_BITS
keyboard_no_right_key:
	; check down key
	lda #$f7
	sta $9120
	lda $9121
	and #$80
	cmp #$80
	beq keyboard_no_down_key
	lda KEYBOARD_BITS
	ora #$08
	sta KEYBOARD_BITS
keyboard_no_down_key:
	; check restore key
	lda #$fb
	sta $9120
	lda $9121
	and #$01
	cmp #$01
	beq keyboard_no_restore_key
	lda KEYBOARD_BITS
	ora #$10
	sta KEYBOARD_BITS
keyboard_no_restore_key:
	; show keyboard bits
	lda KEYBOARD_BITS
	sta $034e
	lda #$00
	sta $034f
	jsr display_binary
	rts


; MOVE THE SCREEN
keyboard_act:
; check for RESTORE-UP key
	lda KEYBOARD_BITS
	and #$1a
	cmp #$1a
	bne act_dont_move_raster_up
	dec RASTER_LINE
	jmp raster_make_valid
	rts
act_dont_move_raster_up:
; check for RESTORE-DOWN key
	lda KEYBOARD_BITS
	and #$18
	cmp #$18
	bne act_dont_move_raster_down
	inc RASTER_LINE
	jmp raster_make_valid
	rts
act_dont_move_raster_down:
; check for COMMODORE key
	lda KEYBOARD_BITS
	and #$01
	cmp #$01
	bne act_dont_adjust_screen
; check for shifts
	lda KEYBOARD_BITS
	and #$02
	cmp #$02
	bne act_adjust_shift_off
; check for c-up
	lda KEYBOARD_BITS
	and #$08
	cmp #$08
	bne act_dont_adjust_up
	; move screen up
	dec $9003
	dec $9003
	rts
act_dont_adjust_up:
; check for c-left
	lda KEYBOARD_BITS
	and #$04
	cmp #$04
	bne act_dont_adjust_left
	; move screen left
	dec $9002
	rts
act_dont_adjust_left:
act_adjust_shift_off:
; check for c-right
	lda KEYBOARD_BITS
	and #$04
	cmp #$04
	bne act_dont_adjust_right
	inc $9002
	rts
act_dont_adjust_right:
; check for c-down
	lda KEYBOARD_BITS
	and #$08
	cmp #$08
	bne act_dont_adjust_down
	inc $9003
	inc $9003
	rts
act_dont_adjust_down:
	rts
act_dont_adjust_screen:
; check for SHIFTS
	lda KEYBOARD_BITS
	and #$02
	cmp #$02
	bne act_move_shift_off
; check for c-up
	lda KEYBOARD_BITS
	and #$08
	cmp #$08
	bne act_dont_move_up
	; move screen up
	dec $9001
	rts
act_dont_move_up:
; check for c-left
	lda KEYBOARD_BITS
	and #$04
	cmp #$04
	bne act_dont_move_left
	; move screen left
	dec $9000
	rts
act_dont_move_left:
act_move_shift_off:
; check for c-right
	lda KEYBOARD_BITS
	and #$04
	cmp #$04
	bne act_dont_move_right
	inc $9000
	lda #$d0
	eor $9000
	rts
act_dont_move_right:
; check for c-down
	lda KEYBOARD_BITS
	and #$08
	cmp #$08
	bne act_dont_move_down
	inc $9001
	rts
act_dont_move_down:
act_dont_move_screen:
	rts




MAIN:
	lda #41
	sta 36879
	jsr raster_wait
	lda #75
	sta 36879
	jsr keyboard_read
	jsr keyboard_act
	jsr display_data
	jmp MAIN;


