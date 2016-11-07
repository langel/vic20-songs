; Vic-20 Player 2 : 4mat/Orb 2007. 
;
; Music data. Test tune is "Megademo: Bumpmap screen"
;
; Compiles with DASM.

rest equ $00
cn1  equ $01
cs1  equ $02
dn1  equ $03
ds1  equ $04
en1  equ $05
fn1  equ $06
fs1  equ $07
gn1  equ $08
gs1  equ $09
an1  equ $0a
as1  equ $0b
bn1  equ $0c
cn2  equ $0d
cs2  equ $0e
dn2  equ $0f
ds2  equ $10
en2  equ $11
fn2  equ $12
fs2  equ $13
gn2  equ $14
gs2  equ $15
an2  equ $16
as2  equ $17
bn2  equ $18
cn3  equ $19
cs3  equ $1a
dn3  equ $1b
ds3  equ $1c
en3  equ $1d
fn3  equ $1e
fs3  equ $1f
gn3  equ $20
gs3  equ $21
an3  equ $22
as3  equ $23
bn3  equ $24
cn4  equ $25
cs4  equ $26
dn4  equ $27
stop_pattern equ $7f
nl1 equ $80
nl2 equ $81
nl3 equ $82
nl4 equ $83
nl5 equ $84
nl6 equ $85
nl7 equ $86
nl8 equ $87
nl9 equ $88
nla equ $89
nlb equ $8a
nlc equ $8b
nld equ $8c
nle equ $8d
nlf equ $8e
nl10 equ $8f
in0 equ $f0
in1 equ $f1
in2 equ $f2
in3 equ $f3
in4 equ $f4
in5 equ $f5
in6 equ $f6
in7 equ $f7
in8 equ $f8
in9 equ $f9
ina equ $fa
inb equ $fb
inc equ $fc
ind equ $fd
ine equ $fe
inf equ $ff
rp1 equ $e0
rp2 equ $e1
rp3 equ $e2
rp4 equ $e3
rp5 equ $e4
rp6 equ $e5
rp7 equ $e6
rp8 equ $e7
rp9 equ $e8
rpa equ $e9
rpb equ $ea
rpc equ $eb
rpd equ $ec
rpe equ $ed
rpf equ $ee
rp10 equ $ef
tr0 equ $f0
tr1 equ $f1
tr2 equ $f2
tr3 equ $f3
tr4 equ $f4
tr5 equ $f5
tr6 equ $f6
tr7 equ $f7
tr8 equ $f8
tr9 equ $f9
tra equ $fa
trb equ $fb
trc equ $fc
trd equ $fd
tre equ $fe
song_end equ $ff
note equ $00
arp1 equ $01
arp2 equ $02
arp3 equ $03
arp4 equ $04
arp5 equ $05
arp6 equ $06
arp7 equ $07
arp8 equ $08
arp9 equ $09
arpa equ $0a
arpb equ $0b
arpc equ $0c
arpd equ $0d
arpe equ $0e
arpf equ $0f
wav equ $10
wav1 equ $11
wav2 equ $12
wav3 equ $13
wav4 equ $14
wav5 equ $15
wav6 equ $16
wav7 equ $17
wav8 equ $18
wav9 equ $19
wava equ $1a
wavb equ $1b
wavc equ $1c
wavd equ $1d
wave equ $1e
wavf equ $1f
loopback1 equ $60
loopback2 equ $61
loopback3 equ $62
loopback4 equ $63
loopback5 equ $64
loopback6 equ $65
loopback7 equ $66
loopback8 equ $67
loopback9 equ $68
loopbacka equ $69
loopbackb equ $6a
loopbackc equ $6b
loopbackd equ $6c
loopbacke equ $6d
loopbackf equ $6e
loopback10 equ $6f
off equ $7f


patttab 
	; blank (used for song startup)
        .byte rest
        .byte stop_pattern 
        
        ; drums (just bdrum and hihat)
        .byte nl2
        .byte in1
        .byte en1
        .byte nl1
        .byte in3
        .byte en1
        .byte en1
        .byte in1
        .byte en1
        .byte nl2
        .byte in3
        .byte en1
        .byte nl1
        .byte en1
        .byte stop_pattern 
        
        ; bass
        .byte nl10
        .byte cn1
        .byte nl8
        .byte cn1
        .byte dn1
        .byte nl10
        .byte ds1
        .byte nl8
        .byte ds1
        .byte fn1
        .byte nl10
        .byte gn1
        .byte nl8
        .byte gn1
        .byte gs1
        .byte nl10
        .byte as1
        .byte nl8
        .byte as1
        .byte bn1
        .byte stop_pattern 
        
        ; chords
        .byte nl10
        .byte in4
        .byte cn2
        .byte nl8
        .byte cn2
        .byte in5
        .byte as1
        .byte nl10
        .byte in6
        .byte as1
        .byte nl8
        .byte as1
        .byte in5
        .byte as1
        .byte nl10
        .byte in6
        .byte as1
        .byte nl8
        .byte as1
        .byte in5
        .byte gs1 
        .byte nl10
        .byte in5
        .byte ds1
        .byte nl8
        .byte ds1
        .byte in6
        .byte dn1
        .byte stop_pattern 
        
        ; intro cowbells
        .byte nl10
        .byte in0
        .byte cn3
        .byte cn3
        .byte cn3
        .byte cn3
        .byte stop_pattern 
        
        ; bass intro
        .byte nl10
        .byte in2
        .byte cn1
        .byte cn1
        .byte cn2
        .byte cn2
        .byte stop_pattern 
        
        ; drums with snare
        .byte nl2
        .byte in1
        .byte en1
        .byte nl1
        .byte in3
        .byte en1
        .byte en1
        .byte in7
        .byte en1
        .byte nl2
        .byte in3
        .byte en1
        .byte nl1
        .byte en1
        .byte stop_pattern 
        
        ; bass outro
        .byte nl10
        .byte in8
        .byte cn1
        .byte stop_pattern 
        


songtab 
	; channel 1 (position : $00)
        .byte $4a
	.byte $11
	.byte trc
	.byte $11
	.byte tr0
	.byte $60
	.byte $4d
	.byte song_end
	
	; channel 2 (position : $08)
        .byte rp8
        .byte $02
        .byte rp10
        .byte $02
        .byte rp10
        .byte $51
        .byte song_end 
        
        ; channel 3 (position : $0f)
        .byte $43
        .byte tr0
        .byte $26
        .byte $26
        .byte tr0
        .byte $43
        .byte trc
        .byte song_end



pattpos .byte $01,$01,$01
songpos .byte $00,$08,$0f
songstart .byte $01,$0c,$11



tempo .byte $03,$04
ticks .byte $03
tempotick .byte $01


; Inst number:    0   1   2   3   4   5   6   7   8
inststart .byte $45,$02,$0c,$17,$1f,$29,$33,$3d,$56
notelen   .byte $2f,$85,$7f,$82,$7f,$7f,$7f,$85,$3f 
volbyte   .byte $f0,$2f,$00,$28,$37,$37,$37,$2f,$0f 
volamount .byte $0f,$03,$00,$01,$02,$02,$02,$03,$20 



insttab 

        ; Channel switched off, repeating on previous frame.
        .byte off
        .byte loopback1

        ; Bass drum, using the noise channel so 2 bytes for each frame tick.
        ; Also you can see I'm setting the pitch of the tone channel with bytes >$80
        .byte $fe
        .byte $ca
        .byte $dd
        .byte $a8
        .byte $a0
        .byte $97
        .byte off
        .byte off
        .byte note
        .byte loopback3

        ; Bass sound, using arpeggios, goes back 7 frames every time it loops. 
        .byte note
        .byte note
        .byte note
        .byte note
        .byte note
        .byte note
        .byte note
        .byte arpc
        .byte arpc
        .byte arpc
        .byte loopback7

        ; The 'hihat' sound, uses noise channel.
        .byte $fe
        .byte $ef
        .byte $f8
        .byte $f5
        .byte $fe
        .byte $ef
        .byte note
        .byte loopback5

        ; Arpeggios, with wave fx.
        .byte wavc
        .byte wavc
        .byte wav7
        .byte arp7
        .byte arp3
        .byte arp3
        .byte note
        .byte wav
        .byte note
        .byte loopback9
        
        .byte wavc
        .byte wavc
        .byte wav7
        .byte arp7
        .byte arp4
        .byte arp4
        .byte note
        .byte wav
        .byte note
        .byte loopback9
        
        .byte wavc
        .byte wavc
        .byte wav9
        .byte arp9
        .byte arp5
        .byte arp5
        .byte note
        .byte wav
        .byte note
        .byte loopback9

        ; Snare drum, using noise channel, ends on the highest noise pitch with the tone
        ; channel switched off. (off)
        .byte $fd
        .byte $ca
        .byte $dd
        .byte $a8
        .byte $fe
        .byte off
        .byte note
        .byte loopback3

        ; Other sounds, using off to turn off the note for an echo effect.
        .byte note
        .byte note
        .byte 235
        .byte 235
        .byte note
        .byte note
        .byte off
        .byte off
        .byte off
        .byte off
        .byte off
        .byte off
        .byte off
        .byte off
        .byte off
        .byte off
        .byte loopback10
	
	.byte arpc
	.byte arpc
	.byte arpc
	.byte arpc
	.byte note
	.byte note
	.byte note
	.byte note
	.byte note
	.byte off
	.byte off
	.byte note
	.byte note
	.byte note
	.byte note
	.byte note
	.byte loopback10
	