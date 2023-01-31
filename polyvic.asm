
	include "lib/vicdefs.asm"

	seg.u ZEROPAGE
	org $0000

wtf     byte
temp00  byte
temp01  byte
temp02  byte
temp03 byte

pu1_beat_counter		byte
pu2_beat_counter		byte
pu3_beat_counter		byte
noi_sweep_counter		byte


	VIC_HEADER
	VIC_INIT_TAKEOVER

	lda #COL_WHITE
	jsr screen_set_color
	lda #CHR_SPACE
	jsr screen_set_char

	; init more stuff
	lda #$00
	sta wtf
	sta VOICE_0
	sta VOICE_1
	sta VOICE_2
	sta VOICE_3
	lda #$0f
	sta VOLUME

	jsr init_song


; =====			MAIN
main_loop: subroutine

raster_one:
	lda #$1a
	cmp RASTER
	bne raster_one

	; bg color work time
	lda #$08
	sta SCR_COL

	jsr play_routine
	inc wtf

	; display wtf
	lda wtf
	ldy #$15
.wtf_loop
	sta SCREEN_RAM,y
	dey
	bpl .wtf_loop
	ldy wtf
	sta SCREEN_RAM,y
	sta SCREEN_RAM+$100,y
	dey
	lda #CHR_SPACE
	sta SCREEN_RAM,y
	sta SCREEN_RAM+$100,y

	lda wtf
	sta temp01
	lda #<SCREEN_RAM+48
	sta temp02
	lda #>SCREEN_RAM
	sta temp03
	jsr hex_display

.v0display
	lda #<SCREEN_RAM+55
	sta temp02
	lda #>SCREEN_RAM+1
	sta temp03
	lda VOICE_0
	bpl .v0clear
	sta temp01
	jsr hex_display
	bne .v0done
.v0clear
	jsr hex_clear
.v0done

.v1display
	lda #<SCREEN_RAM+60
	sta temp02
	lda #>SCREEN_RAM+1
	sta temp03
	lda VOICE_1
	bpl .v1clear
	sta temp01
	jsr hex_display
	bne .v1done
.v1clear
	jsr hex_clear
.v1done

.v2display
	lda #<SCREEN_RAM+65
	sta temp02
	lda #>SCREEN_RAM+1
	sta temp03
	lda VOICE_2
	bpl .v2clear
	sta temp01
	jsr hex_display
	bne .v2done
.v2clear
	jsr hex_clear
.v2done

.v3display
	lda #<SCREEN_RAM+70
	sta temp02
	lda #>SCREEN_RAM+1
	sta temp03
	lda VOICE_3
	bpl .v3clear
	sta temp01
	jsr hex_display
	bne .v3done
.v3clear
	jsr hex_clear
.v3done


	; bg color work done
	lda #$26
	sta SCR_COL

	jmp main_loop
	
	


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
	sta VOICE_0
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
	sta VOICE_1
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
	sta VOICE_2
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
	sta VOICE_3
	rts
.no_noi:
	lda #$00
	sta VOICE_3
	rts
.hat
	lda #$fa
	sta VOICE_3
.no_hat
	rts


; helper functions
	include "lib/hex_display.asm"
	include "lib/screen_set.asm"

