	processor 6502

	ORG 4097
		

KEYBOARD_BITS equ $80
RASTER_LINE equ $81
RASTER_MAX equ $82
CURSOR_X equ $83
CURSOR_COLUMNS equ #$0a
CURSOR_Y equ $84
CURSOR_ROWS equ #$08
CURSOR_POSITION equ $85
KEY_REPEAT_COUNTER equ $86
KEY_LAST_PRESSED equ $87
PATTERN_START_LOCATION equ #$1a
COLOR_BLACK equ #$00
COLOR_WHITE equ #$01
COLOR_RAM equ $9600
SCREEN_WIDTH equ #$16
BLANK_CHARACTER equ #$20 ; #$80 is @


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
	lda #BLANK_CHARACTER
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

; clear pattern data
	ldx #$00
	stx CURSOR_X
	stx CURSOR_Y
clearing_pattern_ram:
	txa
	sta $00,x
	inx
	cpx #$28
	bne clearing_pattern_ram

; set initial raster line 
	lda #$60
	sta RASTER_LINE

; set initial cursor position
	lda #COLOR_WHITE
	ldx #PATTERN_START_LOCATION
	sta COLOR_RAM,x
	stx CURSOR_POSITION

; jump to main
	jmp MAIN




; RASTER
raster_wait:
; hex 17 is off screen on NTSC
	lda RASTER_LINE
	cmp $9004
	bne raster_wait
	rts


; DISPLAY HEX
display_hex:
; $034e = value to display
; $034f = screen placement
; handle first character
	pha
	txa
	pha
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
	pla
	tax
	pla
	rts

hex_characters:
	byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$01,$02,$03,$04,$05,$06

CURSOR_X_TABLE:
	byte #$00,#$01,#$03,#$04,#$06,#$07,#$09,#$0a,#$0c,#$0d
CURSOR_Y_TABLE:
	byte #$1a,#$30,#$46,#$5c,#$72,#$88,#$9e,#$b4


; DISPLAY_PATTERN_DATA
display_data:
	ldx #$00
	ldy #PATTERN_START_LOCATION
pattern_data_loop:
	; display sqa1
	lda $00,x
	sta $034e
	sty $034f
	jsr display_hex
	inx
	iny
	iny
	iny
	; display sqa2
	lda $00,x
	sta $034e
	sty $034f
	jsr display_hex
	inx
	iny
	iny
	iny
	; display sqa3
	lda $00,x
	sta $034e
	sty $034f
	jsr display_hex
	inx
	iny
	iny
	iny
	; display nuzz
	lda $00,x
	sta $034e
	sty $034f
	jsr display_hex
	inx
	iny
	iny
	iny
	; display volume
	lda $00,x
	sta $034e
	sty $034f
	jsr display_hex
	inx
	tya
	clc
	adc #$0a
	tay
	cpx #$28
	bcc pattern_data_loop
; display cursor position
	lda #SCREEN_WIDTH
	sta $034f
	lda CURSOR_POSITION
	sta $034e
	jsr display_hex
; update visible cursor
	lda #COLOR_BLACK
	ldx CURSOR_POSITION
	sta COLOR_RAM,x
	ldx CURSOR_Y
	lda CURSOR_Y_TABLE,x
	ldx CURSOR_X
	clc
	adc CURSOR_X_TABLE,x
	sta CURSOR_POSITION
	tax
	lda #COLOR_WHITE
	sta COLOR_RAM,x
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
	rts


; MOVE THE SCREEN
keyboard_act:
; check if new key
	lda KEYBOARD_BITS
	cmp KEY_LAST_PRESSED
	bne keyboard_act_fresh_key
	; countdown until key repeat frame
	dec KEY_REPEAT_COUNTER
	lda #$00
	cmp KEY_REPEAT_COUNTER
	beq keyboard_act_fresh_key
	rts
keyboard_act_fresh_key:
	sta KEY_LAST_PRESSED
	lda #$07
	sta KEY_REPEAT_COUNTER
; check for RESTORE-UP key
	lda KEYBOARD_BITS
	and #$1a
	cmp #$1a
	bne act_dont_move_raster_up
	dec RASTER_LINE
	;jmp raster_make_valid
	rts
act_dont_move_raster_up:
; check for RESTORE-DOWN key
	lda KEYBOARD_BITS
	and #$18
	cmp #$18
	bne act_dont_move_raster_down
	inc RASTER_LINE
	;jmp raster_make_valid
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
; NAVIGATE PATTERN ARROWS
; check for SHIFTS
	lda KEYBOARD_BITS
	and #$02
	cmp #$02
	bne act_move_shift_off
; check for up
	lda KEYBOARD_BITS
	and #$08
	cmp #$08
	bne act_dont_move_up
	; move cursor up
	dec CURSOR_Y
	lda #$ff
	cmp CURSOR_Y
	bne act_dont_reset_cursor_y_up
	lda #CURSOR_ROWS
	sta CURSOR_Y
	dec CURSOR_Y
act_dont_reset_cursor_y_up:
	rts
act_dont_move_up:
; check for left
	lda KEYBOARD_BITS
	and #$04
	cmp #$04
	bne act_dont_move_left
	; move cursor left
	dec CURSOR_X
	lda #$ff
	cmp CURSOR_X
	bne act_dont_reset_cursor_x_left
	lda #CURSOR_COLUMNS
	sta CURSOR_X
	dec CURSOR_X
act_dont_reset_cursor_x_left:
	rts
act_dont_move_left:
act_move_shift_off:
; check for right
	lda KEYBOARD_BITS
	and #$04
	cmp #$04
	bne act_dont_move_right
	inc CURSOR_X
	lda CURSOR_X
	cmp #CURSOR_COLUMNS
	bne act_dont_reset_cursor_x_right
	lda #$00
	sta CURSOR_X
act_dont_reset_cursor_x_right:
	rts
act_dont_move_right:
; check for down
	lda KEYBOARD_BITS
	and #$08
	cmp #$08
	bne act_dont_move_down
	inc CURSOR_Y
	lda CURSOR_Y
	cmp #CURSOR_ROWS
	bne act_dont_reset_cursor_y_down
	lda #$00
	sta CURSOR_Y
act_dont_reset_cursor_y_down:
	rts
act_dont_move_down:
act_dont_move_screen:
	rts




MAIN:
	lda #$28
	sta 36879
	jsr raster_wait
	lda #$29
	sta 36879
	jsr keyboard_read
	jsr keyboard_act
	jsr display_data
	jmp MAIN;


