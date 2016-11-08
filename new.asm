	processor 6502

	ORG 4097
		

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
	lda #$2
	sta $9700,y
	iny
	clc
	cpy #$00
	bne clearing_screen
