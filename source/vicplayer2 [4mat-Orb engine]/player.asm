; Vic-20 Player 2 : 4mat/Orb 2007. 
;
; Frontend for testing songs.
;
; Compiles with DASM.

dnote = $a0
instrument = dnote + $03 
instrloc = instrument + $03 
instrlen = instrloc + $03 
tempopat = instrlen + $03 
temponot = tempopat + $03 
transsng = temponot + $03 
delaysng = transsng + $03 
temptrans = delaysng + $03 
tempvol = temptrans+$03
voldelay = tempvol+$01
volwait = voldelay+$01
temp = volwait+$01 
tempvol2 = temp+$01

	processor 6502
	
	org	$1001
	.byte	$0b,$10,$04,$00,$9e,$34,$31,$31,$30,0,0,0,0

	org	$100e
	
	sei

	lda #$10
	sta $900f

	lda #$2e
	sta $9003

	lda #$ff
	sta $9005

	ldx #$00
	stx $83
disp1
	lda $8800,x
	sta $1c00,x
	rol
	ora $1c00,x
	sta $1c00,x

	lda $8900,x
	sta $1d00,x
	rol
	ora $1d00,x
	sta $1d00,x

	lda #$00
	sta $9600,x
	sta $9700,x
	lda character1,x 
	sta $1e00,x
	lda character2,x
	sta $1f00,x
	inx
	bne disp1

	ldx #$00
	stx $71
	lda #$02
	sta $70
disp2
	lda tablehi,x
	clc
	adc #$78
	sta plotcol+$02
	lda tablelo,x
	sbc #$06
	cmp tablelo,x
	sta plotcol+$01
	bcc colplot
	dec plotcol+$02

colplot 
	lda #$02
	ldy #$04
plotcol 
	sta $9600,y
	dey
	bpl plotcol


	dec $70
	lda $70
	bpl nocolc

	lda #$02
	sta $70
	inc $71
	lda $71
	and #$01
	sta $71
	tay
	lda coltab,y
	sta colplot+$01
nocolc
	inx
	cpx #$24
	bne disp2

	clc
	lda #>end-1
	sbc #$16
	jsr gethex
	lda $80
	sta $1fe0
	lda $81
	sta $1fe1

	lda #<end-1
	jsr gethex
	lda $80
	sta $1fe2
	lda $81
	sta $1fe3

	jsr playinit
	
rastz 
	ldy #$50
rastz2 
	cpy $9004
	bne rastz2
	inc $900f
	jsr playit
	dec $900f

	clc
	lda $9004
	sbc #$48
	sta $82
	cmp $83
	bcc notmore

	sta $83

notmore

	lda $82
	jsr gethex
	lda $80
	sta $1fd4
	lda $81
	sta $1fd5

	lda $83
	jsr gethex
	lda $80
	sta $1fd7
	lda $81
	sta $1fd8

	clc
	ldx #$00
tryit

	lda tablehi,x
	sta plot+$02
	sta plot2+$02
	lda tablelo,x
	sta plot+$01
	adc #$01
	sta plot2+$01

	cpx #$1d
	bcc realdata

	lda pattpos-$1e,x
	jmp readhex

realdata 
	lda dnote,x
readhex 
	jsr gethex
	lda $80
plot 
	sta $1e00
	lda $81
plot2 
	sta $1e16
	inx
	cpx #$24
	bne tryit
	jmp rastz

gethex 
	pha

	and #$0f
	tay
	lda hexchars,y
	sta $81

	pla
	lsr
	lsr
	lsr
	lsr
	tay
	lda hexchars,y
	sta $80
	rts


coltab .byte $02,$06

hexchars .byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$01,$02,$03,$04,$05,$06

tablehi .byte $1e,$1e,$1e,$1e,$1e,$1e,$1e,$1e,$1e,$1e,$1e,$1f,$1f,$1f,$1f,$1f,$1f,$1f
        .byte $1e,$1e,$1e,$1e,$1e,$1e,$1e,$1e,$1e,$1e,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f

tablelo .byte $1e,$34,$4a,$60,$76,$8c,$a2,$b8,$ce,$e4,$fa,$10,$26,$3c,$52,$68,$7e,$94
        .byte $2a,$40,$56,$6c,$82,$98,$ae,$c4,$da,$f0,$06,$1c,$32,$48,$5e,$74,$8a,$a0

character1

      .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
      .byte $20,$0e,$0f,$14,$05,$31,$20,$24,$20,$20,$20,$20,$20,$14,$12,$01,$0e,$31,$20,$24,$20,$20
      .byte $20,$0e,$0f,$14,$05,$32,$20,$24,$20,$20,$20,$20,$20,$14,$12,$01,$0e,$32,$20,$24,$20,$20
      .byte $20,$0e,$0f,$14,$05,$33,$20,$24,$20,$20,$20,$20,$20,$14,$12,$01,$0e,$33,$20,$24,$20,$20     
      .byte $20,$09,$0e,$13,$14,$31,$20,$24,$20,$20,$20,$20,$20,$04,$05,$0c,$19,$31,$20,$24,$20,$20
      .byte $20,$09,$0e,$13,$14,$32,$20,$24,$20,$20,$20,$20,$20,$04,$05,$0c,$19,$32,$20,$24,$20,$20
      .byte $20,$09,$0e,$13,$14,$33,$20,$24,$20,$20,$20,$20,$20,$04,$05,$0c,$19,$33,$20,$24,$20,$20
      .byte $20,$09,$0c,$0f,$03,$31,$20,$24,$20,$20,$20,$20,$20,$14,$14,$12,$0e,$31,$20,$24,$20,$20
      .byte $20,$09,$0c,$0f,$03,$32,$20,$24,$20,$20,$20,$20,$20,$14,$14,$12,$0e,$32,$20,$24,$20,$20
      .byte $20,$09,$0c,$0f,$03,$33,$20,$24,$20,$20,$20,$20,$20,$14,$14,$12,$0e,$33,$20,$24,$20,$20
      .byte $20,$09,$0c,$05,$0e,$31,$20,$24,$20,$20,$20,$20,$20,$16,$0f,$0c,$04,$03,$20,$24,$20,$20
      .byte $20,$09,$0c,$05,$0e,$32,$20,$24,$20,$20,$20,$20,$20,$16
                  
      
character2

      .byte $0f,$0c,$04,$0c,$20,$24,$20,$20,$20,$09,$0c,$05,$0e,$33,$20,$24,$20,$20,$20,$20,$20,$16 
      .byte $0f,$0c,$17,$14,$20,$24,$20,$20,$20,$14,$0d,$10,$10,$31,$20,$24,$20,$20,$20,$20,$20,$10
      .byte $01,$14,$0e,$31,$20,$24,$20,$20,$20,$14,$0d,$10,$10,$32,$20,$24,$20,$20,$20,$20,$20,$10
      .byte $01,$14,$0e,$32,$20,$24,$20,$20,$20,$14,$0d,$10,$10,$33,$20,$24,$20,$20,$20,$20,$20,$10
      .byte $01,$14,$0e,$33,$20,$24,$20,$20,$20,$14,$0d,$10,$0e,$31,$20,$24,$20,$20,$20,$20,$20,$13
      .byte $0f,$0e,$07,$31,$20,$24,$20,$20,$20,$14,$0d,$10,$0e,$32,$20,$24,$20,$20,$20,$20,$20,$13
      .byte $0f,$0e,$07,$32,$20,$24,$20,$20,$20,$14,$0d,$10,$0e,$33,$20,$24,$20,$20,$20,$20,$20,$13
      .byte $0f,$0e,$07,$33,$20,$24,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
      .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$2a,$20,$16,$09,$03,$20,$10,$0c,$01,$19
      .byte $20,$09,$09,$20,$2a,$20,$20,$20,$14,$09,$0d,$05,$20,$24,$20,$20,$2f,$20,$20,$20,$13,$09
      .byte $1a,$05,$20,$24,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
      .byte $20,$20,$20,$20,$20,$20,$20,$20
      
	include "driver.asm"

end
