
	processor 6502

; Expanded VIC w/ 8k or more
; SCREEN_RAM EQM $1000
; BASIC_RAM  EQM $1200
; COLOR_RAM  EQM $9400

; UnExpanded VIC
BASIC_RAM   EQM  $1000 ; 14 pages
SCREEN_RAM  EQM  $1e00 ;  2 pages
COLOR_RAM   EQM  $9600 ;  2 pages

; Video Interface Chip registers
POS_HOR  EQM  $9000
POS_VER  EQM  $9001
NUM_COL  EQM  $9002
NUM_ROW  EQM  $9003
RASTER   EQM  $9004
CHR_BNK  EQM  $9005
PEN_HOR  EQM  $9006
PEN_VER  EQM  $9007
PADDLEX  EQM  $9008
PADDLEY  EQM  $9009
VOICE_0  EQM  $900a
VOICE_1  EQM  $900b
VOICE_2  EQM  $900c
VOICE_3  EQM  $900d
VOLUME   EQM  $900e
SCR_COL  EQM  $900f

CHR_SPACE   EQM  $20

COL_BLACK   EQM  $0
COL_WHITE   EQM  $1
COL_RED     EQM  $2
COL_CYAN    EQM  $3
COL_PURPLE  EQM  $4
COL_GREEN   EQM  $5
COL_BLUE    EQM  $6
COL_YELLOW  EQM  $7


	MAC VIC_HEADER
	seg Code
	org $1001
	; 10 SYS4109
	byte	$0b,$10,$04,$00,$9e,$34,$31,$31,$30,0,0,0,0
	ENDM
	

	MAC VIC_INIT_TAKEOVER
	; disable and acknowledge interrupts	
	lda #$7f
	sta $912e     
	sta $912d
	sta $911e 
	sei ; no interrupts for sho!
	cld ; no decimal mode!
	ENDM


	MAC REGS_SAVE
	pha
	txa
	pha
	tya
	pha
	ENDM

	MAC REGS_RESTORE
	pla
	tay
	pla
	tax
	pla
	ENDM


