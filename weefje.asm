
/* TRY-OUT WEEFJE
**
** Code:
**  The Gatekeeper (7-4-93)
** ATMAS II to MADS Conversion:
**  Senor Rossie (14-7-2017)
**
** COMPILE:
** # Windows
** "c:\Program Files (x86)\MADS\mads.exe" -i:inc\ -o:xex\filename.xex filename.asm
**
** # Linux / OSX
** mads -i:inc/ -o:xex/filename.xex filename.asm
*/

	icl "systemequates.20070530_bkw.inc"		; Don't forget the specify -i:<path to file> at compile time

	org $A800

	lda #0
	sta NMIEN
	sta IRQEN

	lda #$FE
	sta PORTB

	mwa #nmi $FFFA

	lda #$22
	sta dma
	lda #$20
	sta chr

	mwa #dl dlp
    mwa #dli dlip

	lda #$C0
	sta NMIEN

endless
	jmp endless

nmi
	bit NMIST
	bpl itsavbi

	jmp (dlip)

itsavbi
	pha
	txa
	pha
	tya
	pha

	ldy #8

copcol
	lda cols,y
	sta COLPM0,y
	dey
	bpl copcol

	lda dma
	sta DMACTL

	lda chr
	sta CHBASE

	lda DLP
	sta DLISTL
	lda DLP+1
	sta DLISTH

	jsr vbi

	pla
	tay
	pla
	tax
	pla
	rti

vbi
	rts

dli
	pha
	txa
	pha
	tya
	pha

	lda #0
	sta cnt

	sta WSYNC

loop
	ldx cnt
	ldy posi,x

	lda lala,x
	cmp #2
	bne nunu

	lda #0
	sta lala,x

	inc posi,x
	lda posi,x
	and #$7F
	sta posi,x

nunu
	inc lala,x

	ldx #8

loep
	lda tabje,y
	sta WSYNC
	sta COLBK
	iny
	dex
	bpl loep

	inc cnt
	lda cnt
	cmp #$0A
	bne loop

	lda #0
	sta COLBK

	pla
	tay
	pla
	tax
	pla
	rti

dl
	dta DL_DLI, DL_JVB, a(dl)

posi
	dta	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14

lala
	dta 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

tabje
	dta $00,$02,$04,$06,$08,$0A,$0C,$0E
	dta $0E,$0C,$0A,$08,$06,$04,$02,$00

	dta $60,$62,$64,$66,$68,$6A,$6C,$6E
	dta $6E,$6C,$6A,$68,$66,$64,$62,$60

	dta $C0,$C2,$C4,$C6,$C8,$CA,$CC,$CE
	dta $CE,$CC,$CA,$C8,$C6,$C4,$C2,$C0

	dta $30,$32,$34,$36,$38,$3A,$3C,$3E
	dta $3E,$3C,$3A,$38,$36,$34,$32,$30

	dta $E0,$E2,$E4,$E6,$E8,$EA,$EC,$EE
	dta $EE,$EC,$EA,$E8,$E6,$E4,$E2,$E0

	dta $70,$72,$74,$76,$78,$7A,$7C,$7E
	dta $7E,$7C,$7A,$78,$76,$74,$72,$70

	dta $20,$22,$24,$26,$28,$2A,$2C,$2E
	dta $2E,$2C,$2A,$28,$26,$24,$22,$20

	dta $A0,$A2,$A4,$A6,$A8,$AA,$AC,$AE
	dta $AE,$AC,$AA,$A8,$A6,$A4,$A2,$A0

	dta $00,$02,$04,$06,$08,$0A,$0C,$0E
	dta $0E,$0C,$0A,$08,$06,$04,$02,$00

dlp
	dta a(dlip)
dlip
	dta a(cols)
cols
	dta 0,0,0,0,0,0,0,0
	dta 0,0

.var	.byte	cnt=0, dma=0, chr=0
