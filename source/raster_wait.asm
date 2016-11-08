
; wait for raster beam to reset

raster_wait:
	clc
; hex 17 is off screen on NTSC
	lda #17
	cmp $9004
	bpl raster_wait
