	processor 6502


;	HANDY INPUT MONITOR

;	let's read some controllers and keyboard!!
;	and we'll even let the kernel do its thing

	ORG 4097
		

; 10 SYS4109
	byte	$0b,$10,$04,$00,$9e,$34,$31,$31,$30,0,0,0,0
	
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
	lda #$2
	sta $9700,y
	iny
	clc
	cpy #$00
	bne clearing_screen

; setup irq wrapper
	;sei
	;lda #<irq_custom
	;sta $0314
	;lda #>irq_custom
	;sta $0315
	;cli

; main loop at bottom
	jsr raster_wait
	jmp main_bitch


; IRQ color splotch
irq_custom:
	lda #42
	sta 36879
	jsr $ffea
	jsr $eb1e
	;jsr $eabf
	lda #76
	sta 36879
	jmp $ff56
	;rti


; RASTER
raster_wait:
	clc
; hex 17 is off screen on NTSC
	lda #17
	cmp $9004
	bne raster_wait
	rts


; HEX
clear_hex:
; $034f = screen placement
	lda #$20
	ldx $034f
	sta $1e00,x
	inx
	sta $1e00,x
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
	

; BINARY
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


; reset keybaord output colums
keyboard_read_reset:
	lda #$00
	sta $9120
	rts

read_display_keys:
	lda $c5
	sta $034e
	lda #$18
	sta $034f
	jsr display_hex
	lda $028d
	sta $034e
	lda #$20
	sta $034f
	jsr display_hex
; reading keybaord MATRIX
; row 0
	jsr keyboard_read_reset
	lda #$44
	sta $034f
	lda #$fe
	sta $034e
	jsr display_hex
	lda $034e
	sta $9120
	lda $9121
	sta $034e
	lda #$47
	sta $034f
	jsr display_hex
	lda #$4a
	sta $034f
	jsr display_binary
; row 1
;	jsr keyboard_read_reset
	jsr keyboard_read_reset
	lda #$5a
	sta $034f
	lda #$fd
	sta $034e
	jsr display_hex
	lda $034e
	sta $9120
	lda $9121
	sta $034e
	lda #$5d
	sta $034f
	jsr display_hex
	lda #$60
	sta $034f
	jsr display_binary
; row 2
;	jsr keyboard_read_reset
	jsr keyboard_read_reset
	lda #$70
	sta $034f
	lda #$fb
	sta $034e
	jsr display_hex
	lda $034e
	sta $9120
	lda $9121
	sta $034e
	lda #$73
	sta $034f
	jsr display_hex
	lda #$76
	sta $034f
	jsr display_binary
; row 3
;	jsr keyboard_read_reset
	jsr keyboard_read_reset
	lda #$86
	sta $034f
	lda #$f7
	sta $034e
	jsr display_hex
	lda $034e
	sta $9120
	lda $9121
	sta $034e
	lda #$89
	sta $034f
	jsr display_hex
	lda #$8c
	sta $034f
	jsr display_binary
; row 4
;	jsr keyboard_read_reset
	jsr keyboard_read_reset
	lda #$9c
	sta $034f
	lda #$ef
	sta $034e
	jsr display_hex
	lda $034e
	sta $9120
	lda $9121
	sta $034e
	lda #$9f
	sta $034f
	jsr display_hex
	lda #$a2
	sta $034f
	jsr display_binary
; row 5
;	jsr keyboard_read_reset
	jsr keyboard_read_reset
	lda #$b2
	sta $034f
	lda #$df
	sta $034e
	jsr display_hex
	lda $034e
	sta $9120
	lda $9121
	sta $034e
	lda #$b5
	sta $034f
	jsr display_hex
	lda #$b8
	sta $034f
	jsr display_binary
; row 6
;	jsr keyboard_read_reset
	jsr keyboard_read_reset
	lda #$c8
	sta $034f
	lda #$bf
	sta $034e
	jsr display_hex
	lda $034e
	sta $9120
	lda $9121
	sta $034e
	lda #$cb
	sta $034f
	jsr display_hex
	lda #$ce
	sta $034f
	jsr display_binary
; row 7
;	jsr keyboard_read_reset
	jsr keyboard_read_reset
	lda #$de
	sta $034f
	lda #$7f
	sta $034e
	jsr display_hex
	lda $034e
	sta $9120
	lda $9121
	sta $034e
	lda #$e1
	sta $034f
	jsr display_hex
	lda #$e4
	sta $034f
	jsr display_binary

	rts


; main loop
main_bitch:
	jsr read_display_keys
	lda #27
	sta 36879
	jsr raster_wait
	lda #175
	sta 36879
	jmp main_bitch;


