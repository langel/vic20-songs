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
	
	lda #$20
	sta $033e
	lda #$60
	sta $033f
	
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
	lda #$68
	cmp $9004
	bne raster_zero

program_loop:
	lda #$08
	sta 36879
	jsr sound_toggle
	jsr play
	jsr raster_one
	jsr colors
	jsr display_x
	jsr display_y
	jmp raster_zero
	
raster_one:
	clc
	lda #$7f
	cmp $9004
	bne raster_one_loop
	rts
raster_one_loop:
	jmp raster_one
	
sound_toggle:
	lda #$06
	clc
	cmp 36878
	bne sound_toggle_stash
	lda #$04
sound_toggle_stash:
	sta 36878
	rts	
	
play:
	lda $0350
	ora $033f
	tax
	stx $900a
	dex
	stx $0350
	lda $0351
	ora $033f
	sta $900b
	tax
	inx
	stx $0351
	lda $0352
	ora $033e
	sta $900c
	tax
	dex
	stx $0352
	lda $0353
	ora $033e
	sta $900d
	inx
	stx $0353
	rts
	
update_y_channel:
	;inc $033f
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
	jsr update_y_channel
	lda $033d
	sta 36879
	rts
colors_change:
; also update x channel modifier
	inc $033e
	inc $033f
	inc $033f
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
	
display_x:
	txa
	pha
	lsr
	lsr
	lsr
	lsr
	tax
	lda hex_characters,x
	sta 8164
	pla
	tax
	pha
	and #%00001111
	tax
	lda hex_characters,x
	sta 8165
	pla
	tax
	rts
	
display_y:
	tya
	pha
	lsr
	lsr
	lsr
	lsr
	tay
	lda hex_characters,y
	sta 8167
	pla
	tay
	pha
	and #%00001111
	tay
	lda hex_characters,y
	sta 8168
	pla
	tay
	rts
	

hex_characters:
	byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$01,$02,$03,$04,$05,$06