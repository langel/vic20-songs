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
	sta	$033D
; zero out doRasterPattern
	sta	$033E
	sta	$033f
	
; zero out song position
	ldx	#$00
	lda	#$00
initSongPositionRAM
	sta	$03a0,x
	inx
	cpx	#$60
	bne	initSongPositionRAM

; set song speed
	lda	#6
	sta	$039e
; zero out song speed counter
	sta	$039f
	
; inverse character set
	lda	#%11110001
	sta	$9005
;	
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

mainLoop
; press any key to exit
;	jsr	$73
; part of IRQ which is disabled
	lda	$CB
	cmp	#$40
	bne	exit
	jsr	doRasterPattern
	jsr	goMusicLoop
	jmp	mainLoop	
	
	
; example delete?
waitForRaster
	lda	$9004
	clc
	cmp	#$00
	bne	waitForRaster
	rts
	

	
	
;	-------------------------------------	
;	RASTER PATTERN LOOP
;	-------------------------------------
	
doRasterPattern
; X = rasterPattern offset
; Y = raster beam position
; wait for 27th row of rasterbeam
	inc	$033F
	lda	$033f
	sta	$033e
waitRasterBeam28
	lda	$28			; wait for 28th row of rasterbeam
	cmp	$9004			; rasterbeam address
	bcs	waitRasterBeam28
	tay
;	lda	#136
;	sta	$900F
;	rts
; load raster offset
loopRasterPattern
	inc	$033E
	ldx	$033E
	lda	rasterPattern,X
	cmp	#0
	bne	skipRasterPatternReset
	sta	$033E			; A should be 0, reset record
	ldx	$033E
	lda	rasterPattern,X
skipRasterPatternReset
	sta	$900F
	iny
	tya				; move raster position to A
	cmp	#$80			; stop RASTERing at this scanline
	bne	waitRasterBeamPositionTest
	lda	#0
	sta	$033E
	inc	$033F
	lda	$033F
	cmp	#22
	bne	skipRasterBeamOffsetReset
	lda	#0
	sta	$033F
skipRasterBeamOffsetReset
	rts
waitRasterBeamPositionTest
	cmp	$9004
	bne	waitRasterBeamPositionTest
	jmp	loopRasterPattern
	
exit	rts
	
	
	
;	-------------------------------------	
;	MUSIC LOOP
;	-------------------------------------

goMusicLoop
	
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
; load next row
; apply to channels
	
; BASS CHANNEL RUNTIME
	; checking song position
beginSongCheck
	ldx	$03a2
	lda	CHANNEL_BASS,x
	sta	$1e00,x
	inx
	ldy	CHANNEL_BASS,x
	cmp	#255
	bne	skipEndSongCheck
	cpy	#255
	bne	skipEndSongCheck
	lda	#0
	sta	$03a2
	jmp	beginSongCheck
skipEndSongCheck
	sta	$40
	sty	$41
	; checking pattern position
	ldy	$03a1
	lda	($40),y
	cmp	#0
	bne	skipEndPatternCheck
	inc	$03a2			; move song position forward
	inc	$03a2			; by a word
	lda	#0
	sta	$03a1			; reset pattern counter
	jmp	beginSongCheck
skipEndPatternCheck
	sta	$900a
	sta	$1e10
	inc	$03a1

	
; ALTO
	ldx	$03b0
	lda	CHANNEL_ALTO,x
	cmp	#255
	bne	skipAltoEnd
	ldx	#0
	lda	CHANNEL_ALTO
skipAltoEnd
	sta	$900b
	inx
	stx	$03b0

; SOPRANO
	ldx	$03c0
	lda	CHANNEL_SOPRANO,x
	cmp	#255
	bne	skipSopEnd
	ldx	#0
	lda	CHANNEL_SOPRANO
skipSopEnd
	sta	$900c
	inx
	stx	$03c0
	
; NOISE
	ldx	$03d0
	lda	CHANNEL_NOISE,x
	cmp	#255
	bne	skipNoiseEnd
	ldx	#0
	lda	CHANNEL_NOISE
skipNoiseEnd
	sta	$900d
	inx
	stx	$03d0

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
	byte	195, 196, 197, 198, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	byte	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	byte	255
	
CHANNEL_SOPRANO
;	byte	0
;	byte	255
	byte 	240, 0, 0, 0, 0, 0, 255
	
CHANNEL_NOISE
;	byte	0
	byte	135, 132, 0, 0
	byte	240, 0, 135, 132
	byte	180, 190, 0, 0
	byte	240, 0, 135, 132
	byte	255
	
CHANNEL_VOLUME
	byte	15, 8, 10, 8, 13, 8, 10, 8, 255
	
;	--------------------------
;	PATTERNS
;	--------------------------

pattern00
;	word	bassline, bassline, bassline, bassline2
	word	endPattern
	
;	--------------------------
;	RIFFS AND MACROS
;	--------------------------

bassline
	byte	135, 135, 135, 135, 127, 127, 135, 135
	byte	135, 135, 127, 127, 147, 147, 127, 127
	byte	0
bassline2
	byte	135, 135, 135, 135, 127, 127, 135, 135
	byte	195, 135, 127, 127, 203, 147, 147, 127
	byte	0

	
;	---------
;	DATA HOLD
;	---------
artist
	text	'        B KNOX'
	byte	0
songtitle
	text	'     VIC TO BRRRN'
	byte	0
	
endPattern
	byte	255,255
	
	
rasterPattern
	byte	136, 136, 136, 40, 136, 152, 152, 40, 152, 152, 120
	byte	120, 152, 152, 40, 152, 152, 136, 40, 136, 136, 136
	byte	0
	
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