/* Hello World: Display List Interrupt
**
** COMPILE:
** # Windows
** "c:\Program Files (x86)\MADS\mads.exe" -i:inc\ -o:xex\filename.xex filename.asm
**
** # Linux / OSX
** mads -i:inc/ -o:xex/filename.xex filename.asm
*/

	icl "systemequates.20070530_bkw.inc"		; Don't forget the specify -i:<path to file> at compile time

    org $a800

    mwa #dli VDSLST
    mwa #dl SDLSTL

	lda #$c0        ; Enable DLI
	sta NMIEN
	
	ldy #<vbi       ; Insert own VBI routine
	ldx #>vbi
	lda #6          ; Immediate
	jsr SETVBV

	jmp *			; endless loop (jmp to self)

/*** Vertical Blank Interrupt ***/
vbi
	jmp SYSVBV

/*** Display List Interrupt ***/
dli
	pha
	txa
	pha
	tya
	pha

	ldy bar3
	ldx #$0f

barloop
	lda bar,x
	sta COLPF0
	lda bar2,x
	sta COLPF2
	sty COLPF3
	
	sta WSYNC

	dey
    dey

	dex
	bne barloop

	inc bar3

	lda COLOR0
	sta COLPF0
	lda COLOR1
	sta COLPF1
	lda COLOR2
	sta COLPF2
	lda COLOR3
	sta COLPF3
	lda COLOR4
	sta COLBK

	pla
	tay
	pla
	tax
	pla
	
	rti

bar
	dta $76,$88,$78,$8a,$7a,$8c,$7c,$8e
	dta $7e,$8c,$7c,$8a,$7a,$88,$78,$86

bar2
	dta $84,$86,$88,$8a,$8c,$8e,$0c,$0e
	dta	$0e,$0c,$3e,$3c,$3a,$38,$36,$34

bar3                                ; 'GTIA Bar' (from 0 to ff)
	dta 0

line1
        ; 123456789|123456789|
	dta d'   .:. mads .:.     '*
line2
    dta d'   HELLO  WORLD     '     ; * Adds 128 to chars between '', so becomes inverse

; Display List
dl	dta DL_BLANK8, DL_BLANK8, DL_BLANK8
	dta DL_BLANK1 | DL_DLI
	dta DL_GR1 | DL_LMS | DL_DLI, a(line1)
	dta DL_GR2 | DL_LMS | DL_DLI, a(line2)
	dta DL_GR1 | DL_LMS, a(line1)
	dta DL_JVB, a(dl)