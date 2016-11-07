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
	lda	#5
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
	lda	#$20
	sta	$1e00	; screen RAM
	sta	$1f00	; screen RAM
	ldx	#0
loopScreenBlacking
	inx
	lda	#0
	sta	$9600,x	; color RAM
	sta	$9700,x	; color RAM
	lda	#$20
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
doArtist
	lda	artist,x
	cmp	#0
	beq	doArtistEnd
	sta	$1e00,x
	inx
	jmp	doArtist
doArtistEnd
	
	ldx	#0
	ldy	#66
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
	
	jsr	GO_METERS

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
	lda	#$19	; wait for Xth row of rasterbeam
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
	word	bassline
	word	bassline
	word	bassline
	word	bassline2
	byte	255, 255
	
CHANNEL_ALTO
	word	doot
	word	whip
	word	whip
	word	whip
	word	doot
	word	whip
	word	mute
	word	kick
	word	hat
	word	snare
	word	hat
	word	whip
	byte	255, 255
	
CHANNEL_SOPRANO
	word	whip
	word	doot
	word	doot
	word	doot
	word	whip
	word	mute
	byte	255, 255
	
CHANNEL_NOISE
	word	kick
	word	hat
	word	snare
	word	hat
	word	kick
	word	hat
	word	snare
	word	hat
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

kick
	byte	190, 130, 0
snare
	byte	240, 242, 0
hat
	byte	250, 127, 0
	
bassline
	byte	135, 135, 135, 135, 127, 127, 135, 135
	byte	135, 135, 127, 127, 147, 147, 127, 127
	byte	0
bassline2
	byte	135, 135, 135, 135, 127, 127, 135, 135
	byte	195, 135, 127, 127, 203, 147, 147, 127
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


	
	

	
;	---------
;	DATA HOLD
;	---------
artist
	text	'        B.KNOX'
	byte	0
songtitle
	text	'     VIC TO BRRRN'
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