; 10 SYS (4112)
*=$1000
	BYTE	$00, $0E, $08, $0A, $00, $9E, $20, $28
	BYTE	$34, $31, $31, $32, $29, $00, $00, $00

; casette buffer used throughout
; $033c - $03fb

		
;	PROGRAM INIT
;	------------

	lda	#$00
; zero out borderCheck
	sta	$033d
; zero out doRasterPattern
	sta	$033e
	sta	$033f
	
; zero out song position
	ldx	#$00
	lda	#$00
initSongPositionRAM
	sta	$03a0,x
	inx
	cpx	#$50
	bne	initSongPositionRAM

; set song speed
	lda	#2
	sta	$039e
; zero out song speed counter
	lda	#0
	sta	$039f
	
; inverse character set
	lda	#%11110001
	sta	$9005
	
; fill screen with black	
	lda	#0
	sta	$9600	; color RAM
	sta	$9700	; color RAM
	lda	#102
	sta	$1e00	; screen RAM
	sta	$1f00	; screen RAM
	ldx	#0
loopScreenBlacking
	inx
	lda	#0
	sta	$9600,x	; color RAM
	sta	$9700,x	; color RAM
	lda	#102
	sta	$1e00,x	; screen RAM
	sta	$1f00,x	; screen RAM
	cpx	#$ff
	bne	loopScreenBlacking

	
	
; disable IRQ and NMI
  	lda 	#$7f
  	sta 	$912e 
  	sta 	$912d
  	sta 	$911e   

	
	ldx	#0
	ldy	#135
doArtist
	lda	artist,x
	cmp	#0
	beq	doArtistEnd
	sta	$1e00,y
	inx
	iny
	jmp	doArtist
doArtistEnd
	
	ldx	#0
	ldy	#223
doSongTitle
	lda	songTitle,x
	cmp	#0
	beq	doSongTitleEnd
	sta	$1e00,y
	inx
	iny
	jmp	doSongTitle
doSongTitleEnd
	
	
	
	
;	-------------------------------------	
;	MAIN LOOP
;	-------------------------------------

MAIN_LOOP
; press any key to exit
;	jsr	$73
; part of IRQ which is disabled
;	lda	$CB
;	cmp	#$40
;	bne	exit
;	jsr	doRasterPattern

	jsr	GO_MUSIC_LOOP
	
;	jsr	GO_METERS

	jsr	DO_RASTER_EFFECT
	
	jmp	MAIN_LOOP
	

	
	
;	-------------------------------------	
;	RASTER PATTERN LOOP
;	-------------------------------------
	
DO_RASTER_EFFECT
; X = rasterPattern offset
; Y = raster beam position
; $033f = pattern offset frame position
; $033e = pattern offset drawing position
	inc	$033f
	inc	$033f
	ldx	$033f
	stx	$033e
	lda	RASTER_PATTERN,x
	cmp	#0
	bne	waitRasterHome
	sta	$033f
waitRasterHome
	lda	$9003			; bit 7 holds 9th bit of raster position
	and	#128
	cmp	#128
	beq	waitRasterHome
	lda	#$18	; wait for Xth row of rasterbeam
waitRasterPassTopBorder
	cmp	$9004			; rasterbeam address
	bne	waitRasterPassTopBorder
	tay				; store raster position in Y

loopRasterPattern
	ldx	$033e
	lda	RASTER_PATTERN,x
	cmp	#0
	bne	skipRasterPatternReset
	sta	$033e			; A should be 0, reset record
	lda	RASTER_PATTERN
skipRasterPatternReset
	cpy	#$81			; stop RASTERing at this scanline
	bne	skipRasterEnd
	rts
skipRasterEnd
	inc	$033e
	iny
waitRasterNextLine
	cpy	$9004
	bne	waitRasterNextLine
	sta	$900f			; border + bg setting
	jmp	loopRasterPattern

RASTER_PATTERN
	byte	136, 136, 136, 40, 40, 136, 152, 152, 136, 152, 152, 152, 152, 120
	byte	120, 152, 152, 152, 152, 136, 152, 152, 136, 40, 40, 136, 136, 136
	byte	0
	

	
;	-------------------------------------
;	DRAW THEM METERS
;	-------------------------------------

GO_METERS
	lda	$039f	; songspeed counter
	cmp	#0
	beq	DRAW_METERS
	lda	$039e	; songspeed
	ror
	cmp	$039f
	beq	DO_METERS_2	; alt meters halfway through 
	rts
DO_METERS_1
	jmp	DRAW_METERS
DO_METERS_2
	jmp	DRAW_METERS
	
DRAW_METERS
	
	ldx	#0	; clear meter space
	lda	#$20
clearMeterSpace
	sta	$1f00,x
	inx
	cpx	#$ff
	bne	clearMeterSpace
	

GO_METERS
	lda	$039f	; songspeed counter
	cmp	#0
	beq	DRAW_METERS
	lda	$039e	; songspeed
	ror
	cmp	$039f
	beq	DO_METERS_2	; alt meters halfway through 
	rts
DO_METERS_1
	jmp	DRAW_METERS
DO_METERS_2
	jmp	DRAW_METERS
	
DRAW_METERS
	
	ldx	#0	; clear meter space
	lda	#$20
clearMeterSpace
	sta	$1f00,x
	inx
	cpx	#$ff
	bne	clearMeterSpace
	
	lda	#$0a
	sta	$48		; which voice
	lda	#9
	sta	$49		; colum offset
METER_DRAW_COLUM
	ldx	$48
	lda	$9000,x
	and	#128
	cmp	#128
	bne	METER_END_DRAW_COLUM
	lda	$900e
	ror		; meter height is half of volume
	ror
	ror
	ror
	tay			; countdown with Y
	
	ldx	$49		; load colum offset into X
METER_DRAW_COLUM_ROW
	lda	#102
	sta	$1f00,x
	inx
	sta	$1f00,x
	inx
	sta	$1f00,x
	inx
	sta	$1f00,x
	dey
	cpy	#0
	beq	METER_END_DRAW_COLUM
	txa
	adc	#18
	tax
	jmp	METER_DRAW_COLUM_ROW
METER_END_DRAW_COLUM
	inc	$48
	lda	$48
	cmp	#$0b
	beq	END_METER_DRAW
	lda	$49
	adc	#7
	stx	$49
	jmp	METER_DRAW_COLUM
END_METER_DRAW
	rts
	
noMETER
	inc	$48
	lda	$49
	adc	#5
	sta	$49
		
endMETER
	inx
	cpx	#20
	bcc	METER_DRAW_COLUM_ROW
	txa
	adc	#22
	inc	$48
	dey
	cpy	#0
	bne	METER_DRAW_COLUM
	rts
	
	
;	-------------------------------------	
;	MUSIC LOOP
;	-------------------------------------

GO_MUSIC_LOOP
	
; EFFECTS GOGOGOGOOO
; check for enabled effects
; do stuff to channels
	
; SPEED COUNTER CHECK
; counts frames based on speed setting
; before moving to next pattern row
	lda	$039e
	cmp	$039f
	beq	skipSpeedCounterCheck
	inc	$039f
	rts
	
skipSpeedCounterCheck
	lda	#0
	sta	$039f	; reset speed counter


; PATTERN CYCLE

	jsr SET_PATTERN_BASS
	jsr	DO_NEXT_MACRO
	jsr SET_PATTERN_ALTO
	jsr	DO_NEXT_MACRO
	jsr SET_PATTERN_SOPRANO
	jsr	DO_NEXT_MACRO
	jsr SET_PATTERN_NOISE
	jsr	DO_NEXT_MACRO

	; get channel data 5th byte
;	ldx $03f1
; 	lda $0305,x



; VOLUME
	ldx	$03e0
	lda	CHANNEL_VOLUME,x
	cmp	#255
	bne	skipVolEnd
	ldx	#0
	lda	CHANNEL_VOLUME
skipVolEnd
	sta	$900e
	inx
	stx	$03e0


; GO HOME	
	rts
	
	
SET_PATTERN_BASS
	lda	#$0a
	sta	$03f0
	lda	#$a0
	sta	$03f1
	ldx 	$03a2
	lda 	CHANNEL_BASS,x
	inx
	ldy 	CHANNEL_BASS,x
	cmp 	#255
	bne 	notBassEndSong
	cpy 	#255
	bne 	notBassEndSong
	lda 	#0
	sta 	$03a2
	jmp 	SET_PATTERN_BASS
notBassEndSong
	sta	$40				; set current pattern
	sty	$41
	rts
	

SET_PATTERN_ALTO
	lda	#$0b
	sta	$03f0
	lda	#$b0
	sta	$03f1
	ldx 	$03b2
	lda 	CHANNEL_ALTO,x
	inx
	ldy 	CHANNEL_ALTO,x
	cmp 	#255
	bne 	notAltoEndSong
	cpy 	#255
	bne 	notAltoEndSong
	lda 	#0
	sta 	$03b2
	jmp 	SET_PATTERN_ALTO
notAltoEndSong
	sta	$40				; set current pattern
	sty	$41
	rts


SET_PATTERN_SOPRANO
	lda	#$0c
	sta	$03f0
	lda	#$c0
	sta	$03f1
	ldx 	$03c2
	lda 	CHANNEL_SOPRANO,x
	inx
	ldy 	CHANNEL_SOPRANO,x
	cmp 	#255
	bne 	notSopranoEndSong
	cpy 	#255
	bne 	notSopranoEndSong
	lda 	#0
	sta 	$03c2
	jmp 	SET_PATTERN_SOPRANO
notSopranoEndSong
	sta	$40				; set current pattern
	sty	$41
	rts
	


SET_PATTERN_NOISE
	lda	#$0d
	sta	$03f0
	lda	#$d0
	sta	$03f1
	ldx 	$03d2
	lda 	CHANNEL_NOISE,x
	inx
	ldy 	CHANNEL_NOISE,x
	cmp 	#255
	bne 	notNoiseEndSong
	cpy 	#255
	bne 	notNoiseEndSong
	lda 	#0
	sta 	$03d2
	jmp 	SET_PATTERN_NOISE
notNoiseEndSong
	sta	$40				; set current pattern
	sty	$41
	rts

DO_NEXT_MACRO
	ldx	$03f1			; 1 byte riffmacro buffer at $03x3
	lda	$0303,x
	ldx	$03f0
	sta	$9000,x		; play buffer value

	ldx 	$03f1			; riffmacro position
	lda 	$0300,x
	tay
	lda	($40),y
	cmp 	#0			; if riffmacro val != 0 skip reset
	bne	riffmacroNotEnd
	lda	#0
	sta	$0300,x		; reset riffmacro position
	lda	$0302,x		; load song position
	tay
	iny				; increase song position by a word
	iny
	tya	
	sta	$0302,x		; save song position
	jmp	DO_NEXT_MACRO
riffmacroNotEnd
	sta	$0303,x		; set buffer value for next frame
	iny				; increase riffmacro position
	tya
	ldx	$03f1
	sta	$0300,x		; save riffmacro position
	rts
	

;	---------
;	DATA HOLD
;	---------
	
CHANNEL_BASS
	word	measureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word	dnb
	word	measureMute
	word	openHoles
	word	openHoles
	word	dnBass	; start break jam
	word 	dnBass
	word 	dnBass
	word 	dnBass
	word 	dnBass
	word 	dnBass
	word 	dnBass
	word 	dnBass
	word 	dnBass
	word 	dnBass
	word 	dnBass
	word	dnBass
	word	dnBass		; 13
	word	dnBass
	word	dnBass
	word	dnb2
	
	word	transBass ; start of trans
	
	word	extraKik	; start of half time
	word	extraKik
	word	extraKik
	word	extraKik
	word	extraKik	; start of accompy
	word	extraKik
	word	extraKik
	word	extraKik
	word	extraKik	
	word	extraKik
	word	extraKik
	word	extraKik
	
	word	dnBass		; 13 back to
	word	dnBass
	word	dnBass
	word	dnb2
	word 	openArps
	word	measureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word 	openArps
	word	halfArps
	word	measureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word 	measureMute
	word 	measureMute
	word 	measureMute
	byte	255, 255
	
CHANNEL_ALTO
	word	measureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word	dnBass
	word	dnBass
	word	dnBass
	word	openHoles
	word	dnBass
	word	dnBass
	word	dnBass
	word	dnb2
	word	dnBass
	word	dnBass
	word	dnb2
	word	openHoles
	word	dnBass	; start break jam
	word	measureMute
	word	dnBass
	word	measureMute
	word	tinkytak
	word	dnBass
	word	dnBass
	word	dnBass
	word	dnBass
	word	tinkytik
	word	dnBass	; 13
	word	dnBass
	word	measureMute
	word	dnBass
	
	word	transHarm	; start of trans
	
	word	bassline2	; start of half time
	word	bassline2
	word	bassline2
	word	bassline
	word	bassline2	; start of accompy
	word	bassline2
	word	bassline2
	word	bassline2
	word	bassline2accompy2
	word	bassline2
	word	bassline2
	
	
	word	dnBass	; 13 back too
	word	dnBass
	word	measureMute
	word	dnBass
	word	measureMute
	word 	openArps
	word	measureMute
	word	measureMute
	word	measureMute
	word 	openArps
	word	halfArps
	word	qmeasureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word 	measureMute
	word 	measureMute
	word 	measureMute
	
	byte	255, 255
	
CHANNEL_SOPRANO
	word	measureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word	dnb
	word	openHoles
	word	openHoles
	word 	openArps
	word	measureMute	; start break jam
	word	measureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word	measureMute
	word 	tinkytak	; double lengthed
	word	tinkytik
	word	tinkytik
	word	dnBass	; 13
	word	measureMute
	word	measureMute
	word	dnBass
	
	word	measureMute	; start trans
	word	measureMute
	word	measureMute
	word	measureMute
	
	word	bassline	; start of half time
	word	bassline2
	word	bassline2
	word	bassline
	word	accompy1	; start of accompy
	word	accompy1
	word	accompy2
	word	accompy1
	
	word	dnBass	; 13 back too
	word	measureMute
	word	measureMute
	word	dnBass
	word	measureMute
	word	measureMute
	word 	openArps
	word	measureMute
	word	measureMute
	word 	openArps
	word	measureMute
	word	measureMute
	word 	measureMute
	word 	measureMute
	word 	measureMute
	byte	255, 255
	
CHANNEL_NOISE
	word	dnb
	word	dnb
	word	dnb
	word	dnb2
	word	dnb
	word	dnb
	word	dnb2
	word	openHoles
	word	dnb
	word	dnb
	word	dnb
	word	dnb2
	word	dnb
	word	dnb
	word	dnb2
	word	openHoles
	word	dnb	; start break jam
	word	dnb
	word	dnb
	word	dnb
	word	dnb
	word	dnb
	word	dnb
	word	dnb
	word	dnb2
	word	dnb
	word	dnb
	word	dnb2
	word	dnBass	; 13
	word	dnb
	word	dnb
	word	dnb
	
	word	kikStop	; start of trans
	word	transdnb
	word	kikStop
	
	word	extraKikSnar	; start of half time
	word	extraKikSnar
	word	extraKikSnar
	word	extraKikSnar
	word	extraKikSnar	; start of accompy
	word	extraKikSnar
	word	extraKikSnar
	word	extraKikSnar
	word	extraKikSnar
	word	extraKikSnar
	word	extraKikSnar
	word	extraKikSnar
	
	word	dnBass	; 13  back to
	word	dnb
	word	dnb
	word	dnb
	word	kikstop
	word 	measureMute
	word	kikstop
	word 	openArps
	word 	halfArps
	word	kikstop
	word 	measureMute
	word 	measureMute
	word 	measureMute
	word 	measureMute
	word 	measureMute
	word 	measureMute
	byte	255,255
	
CHANNEL_VOLUME
	byte	15, 8, 10, 8, 13, 8, 10, 8, 255
	
;	--------------------------
;	PATTERNS
;	--------------------------
;	not in use yet
;	currently runs  SONG ORDER -> RIFF/MACROs
;	instead of desired	SONG ORDER -> PATTERNS -> RIFF/MACROs

pattern00
;	word	bassline, bassline, bassline, bassline2
	word	endPattern
	
;	--------------------------
;	RIFFS AND MACROS
;	--------------------------

transBass
	byte	220,220,220,127,127,127,227,227,227,127,127,127,232,232,232,127
	byte	127,127,237,237,237,127,127,127,220,218,216,214,214,127,214,127
	byte	220,220,220,127,127,127,227,227,227,127,127,127,232,232,232,127
	byte	127,127,237,237,237,127,127,127,214,127,214,127,214,127,214,127
	byte	220,220,220,220,127,127,227,227,227,200,127,127,232,232,232,232
	byte	127,127,237,237,237,237,127,127,214,127,214,127,214,127,214,127
	byte	220,220,220,220,220,127,227,227,227,200,200,127,232,232,232,232
	byte	232,232,237,237,237,237,237,237,214,214,173,175,179,185,192,198
	byte	0
transHarm
	byte	224,127,127,224,127,127,232,127,127,232,127,127,237,127,127,237
	byte	127,127,240,127,127,240,192,127,192,127,127,127,192,127,192,127
	byte	224,127,127,224,127,127,232,127,127,232,127,127,237,127,127,237
	byte	127,240,240,127,240,240,192,127,192,127,127,127,192,127,192,127
	byte	224,224,224,224,224,224,232,127,127,232,127,127,237,127,127,237
	byte	127,127,240,127,127,240,192,127,192,127,127,127,192,127,192,127
	byte	224,127,127,224,127,127,232,127,127,232,127,127,237,127,127,237
	byte	127,127,240,127,127,240,192,191,189,188,184,179,172,161,148,129
	byte	0
kikStop
	byte	150,135,128,127,127,127,127,127,127,127,127,127,127,127,127,127
	byte	127,127,127,127,127,127,127,127,127,127,127,127,250,127,250,127
	byte	0
transdnb
	byte	150,135,128,127,250,127,127,127,250,127,127,127,250,127,127,127
	byte	248,210,238,127,250,127,127,127,250,127,127,127,250,127,127,127
	byte	150,135,128,127,250,127,127,127,250,127,127,127,250,127,127,127
	byte	248,210,238,127,250,127,127,127,250,127,127,127,250,127,127,127
	byte	0
whip
	byte	195, 196, 197, 198, 127, 127, 127, 127
	byte	127, 127, 127, 127, 127, 127, 127, 127
	byte	127, 127
	byte	0
	
doot
	byte	240, 127, 127, 127, 127, 127
	byte 	0

mute
	byte	127
	byte	0
	
qMeasureMute
	byte	127,127,127,127,127,127,127,127
	byte	0

measureMute
	byte	127, 127, 127, 127, 127, 127, 127, 127
	byte	127, 127, 127, 127, 127, 127, 127, 127
	byte	127, 127, 127, 127, 127, 127, 127, 127
	byte	127, 127, 127, 127, 127, 127, 127, 127
	byte	0
	
tinkytak
	byte	240,239,127,127,127,127,240,239
	byte	127,127,127,239,240,239,127,127
	byte	127,127,240,239,127,127,127,127
	byte	240,239,127,127,127,239,240,239
	byte	127,127,127,127,240,239,127,127
	byte	127,127,240,239,127,127,127,241
	byte	240,239,127,237,236,127,234,233
	byte	127,231,230,127,228,227,226,225
	byte	0
tinkytik
	byte	195,190,189,190,191,190,127,127
	byte	195,190,189,191,193,196,201,127
	byte	190,190,190,127,127,225,127,127
	byte	190,190,192,127,127,232,127,127
	byte	190,191,192,127,127,232,127,225
	byte	190,192,194,127,127,127,190,195
	byte	205,127,127,127,190,127,190,127
	byte	190,189,190,191,190,127,190,127
	byte	0
	
dnb
	byte	150, 135, 128, 127, 255, 127, 250, 127
	byte	248, 210, 238, 127, 255, 127, 250, 127
	byte	250, 127, 250, 127, 150, 135, 128, 127
	byte	248, 210, 238, 178, 255, 127, 250, 127
	byte	0
dnb2
	byte	150, 135, 128, 127, 255, 127, 250, 127
	byte	248, 210, 238, 127, 255, 127, 250, 127
	byte	250, 127, 250, 127, 250, 127, 250, 127
	byte	255, 127, 250, 127, 250, 127, 250, 127
	byte	0
		
dnBass
	byte	215, 215, 215, 127, 127, 127, 127, 127
	byte	221, 223, 227, 227, 127, 127, 127, 127
	byte	127, 127, 127, 127, 215, 215, 215, 127
	byte	221, 223, 227, 227, 127, 127, 127, 127
	byte	0

openHoles
	byte	195, 195, 195, 127, 195, 195, 195, 127
	byte	201, 201, 201, 201, 201, 201, 201, 127
	byte	207, 207, 207, 207, 207, 207, 207, 207
	byte	212, 127, 212, 212, 212, 127, 212, 127
	byte	0
openArps
	byte	195,207,215,195,207,215,195,207
	byte	201,212,219,201,212,219,201,212
	byte	207,215,223,207,215,223,207,215
	byte	207,215,223,207,215,223,207,215
	byte	0
halfArps
	byte	195,207,215,195,207,215,195,207
	byte	201,212,219,201,212,219,201,212
	byte	0
	
bassline
	byte	181,181,181,181,127,127,127,127,181,181,181,181,127,127,127,127
	byte	200,200,200,200,185,185,185,185,127,127,127,127,173,173,173,173
	byte	127,127,127,127,173,173,173,173,127,127,127,127,173,173,173,173
	byte	200,200,200,200,200,200,200,127,181,181,181,181,181,181,127,127
	byte	0
bassline2
	byte	181,181,181,181,127,127,127,127,181,181,181,181,127,127,127,127
	byte	200,200,200,200,185,185,185,185,127,127,127,127,173,173,173,173
	byte	127,127,127,127,173,173,173,173,127,127,127,127,173,173,173,173
	byte	200,200,200,200,200,200,200,127,232,232,232,232,232,232,127,127
	byte	0
bassline2accompy2
	byte	181,181,181,181,127,127,127,127,181,181,181,181,127,127,127,127
	byte	200,200,200,200,185,185,185,185,127,127,127,127,173,173,173,173
	byte	127,127,127,127,173,173,173,173,127,127,127,127,173,173,173,173
	byte	200,200,200,200,200,200,200,127,232,232,232,232,232,232,127,127
	byte	200,200,199,200,201,200,127,127,127,127,127,127,192,192,191,192
	byte	193,192,127,127,127,127,127,127,189,189,188,189,190,189,127,127
	byte	127,127,127,127,185,185,184,185,186,185,127,127,127,127,127,127
	byte	181,181,180,181,182,180,127,127,181,182,183,185,188,192,197,209
	byte	0
accompy1
	byte	203,203,203,203,203,203,203,203,203,203,203,203,203,203,127,127
	byte	127,127,127,127,127,127,127,127,218,218,219,218,218,219,218,218
	byte	219,218,127,127,127,127,127,127,127,127,127,173,173,127,127,127
	byte	234,214,173,234,214,173,234,214,173,234,214,173,234,214,173,214
	byte	203,203,203,203,203,203,203,203,203,203,203,203,203,203,127,127
	byte	127,127,127,127,127,127,127,127,218,218,219,218,218,219,218,218
	byte	219,218,127,127,127,127,127,234,214,173,234,214,173,234,214,173
	byte	234,214,173,234,214,173,234,214,173,234,214,173,234,214,173,214
	byte	0
accompy2
	byte	145,200,227,200,145,200,227,200,145,200,227,226,225,224,223,222
	byte	151,203,229,203,151,203,229,203,151,203,229,228,227,226,225,224
	byte	158,206,231,205,158,206,231,206,158,158,206,231,230,229,228,227
	byte	161,211,232,211,161,211,232,211,161,211,232,232,231,230,229,228
	byte	200,200,199,200,201,200,127,127,127,127,127,127,192,192,191,192
	byte	193,192,127,127,127,127,127,127,189,189,188,189,190,189,127,127
	byte	127,127,127,127,185,185,184,185,186,185,127,127,127,127,127,127
	byte	181,181,180,181,182,180,127,127,181,182,183,185,188,192,197,209
	byte	0

extraKik
	byte	200,150,140,135,130,128,1,1
	byte	200,150,140,135,130,128,1,1
	byte	200,150,140,135,130,128,1,1
	byte	200,150,140,135,130,128,1,1
	byte	200,150,140,135,130,128,1,1
	byte	200,150,140,135,130,128,1,1
	byte	200,150,140,135,130,128,1,1
	byte	200,150,140,135,130,128,1,1
	byte	0
	

extraKikSnar
	byte	200,150,140,135,130,128,1,1
	byte	200,150,140,135,130,128,1,1
	byte	248,210,238,215,230,223,1,1
	byte	200,150,140,135,130,128,1,1
	byte	200,150,140,135,130,128,1,1
	byte	200,150,140,135,130,128,1,1
	byte	248,210,238,215,230,223,1,1
	byte	200,150,140,135,130,128,1,1
	byte	0
	
;	---------
;	DATA HOLD
;	---------
artist
;	text	'        B.KNOX'
	byte	32,2,45,11,14,15,24,32
	byte	0
songtitle
	text	' VIC TO BRRRN '
	byte	0
	
endPattern
	byte	255,255
	
	
rest	= 127
C_1	= 135
C#1	= 143
D_1	= 147
D#1	= 151
E_1	= 159
F_1	= 163
F#1	= 167
G_1	= 175
G#1	= 179
A_1	= 183
A#1	= 187
B_1	= 191
C_2	= 195
C#2	= 199
D_2	= 201
D#2	= 203
E_2	= 207
F_2	= 209
F#2	= 212
G_2	= 215
G#2	= 217
A_2	= 219
A#2	= 221
B_2	= 223
C_3	= 225
C#3	= 227
D_3	= 228
D#3	= 229
E_3	= 231
F_3	= 232
F#3	= 233
G_3	= 235
G#3	= 236
A_3	= 237
A#3	= 238
B_3	= 239
C_4	= 240
C#4	= 241