; a couple modulus subroutines



; MODULUS :: hausdorff edition
; https://gist.github.com/hausdorff/5993556
;
; modulus, returns in register A

modulus_hausdorff_start:
	LDA $00  ; memory addr A
	SEC
modulus_hausdorff_loop:	
	SBC $01  ; memory addr B
	BCS modulus_hausdorff_loop
	ADC $01
	rts


; MODULUS :: hertzdevil edition
;
; which puts $00 % $01 into A and destroys $00
; "it is slightly faster on average
; of course if $01 is large enough you may even unroll that original loop"

modulus_hertzdevil_start:
	lda #$00
	ldy #8
modulus_hertzdevil_loop:
	asl $00
	rol
	cmp $01
	bcc modulus_hertzdevil_skip
	sbc $01
modulus_hertzdevil_skip:
	dey
	bne modulus_hertzdevil_loop
	rts
