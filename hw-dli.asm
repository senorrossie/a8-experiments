/* Hello World: Display List Interrupt
**
** COMPILE:
** # Windows
** "c:\Program Files (x86)\MADS\mads.exe" -i:inc\ -o:xex\filename.xex filename.asm
**
** # Linux / OSX
** mads -i:inc/ -o:xex/filename.xex filename.asm
** - Cartridge image
** mads -d:CARTRIDGE=true -i:inc/ -o:xex/filename.rom filename.asm
**
*/

; If you don't want to specify the labels at compile time, uncomment the ones below
;.def CARTRIDGE			; Create an 8k cartridge image

.ifdef CARTRIDGE
	opt h-
.endif

	icl "systemequates.20070530_bkw.inc"		; Don't forget the specify -i:<path to file> at compile time

.ifdef CARTRIDGE
	org $A000

	opt f+
.else
	org $A800
.endif

.ifdef CARTRIDGE
CART_CMD_ROOT_DIR = $4
wait_for_cart = $620

.proc	reset_routine
	mva #3 BOOTQ
	lda #CART_CMD_ROOT_DIR ; tell the mcu we've done a reset
	jsr wait_for_cart
	rts
.endp

.proc cartinit
	rts
.endp ; proc init
	
	;Cartridge start
	;RAM, graphics 0 and IOCB no for the editor (E:) are ready
.proc cartstart
	mva #$8F COLOR1
	mva #$82 COLOR2
	
	mva #3 BOOTQ ; patch reset - from mapping the atari (revised) appendix 11
	mwa #reset_routine CASINI
.endp
.endif

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
	dta d'   .:. mads .:.     '*	; * Adds 128 to chars between '', so becomes inverse
line2
    dta d'   HELLO  WORLD     '

; Display List
dl	dta DL_BLANK8, DL_BLANK8, DL_BLANK8
	dta DL_BLANK1 | DL_DLI
	dta DL_GR1 | DL_LMS | DL_DLI, a(line1)
	dta DL_GR2 | DL_LMS | DL_DLI, a(line2)
	dta DL_GR1 | DL_LMS, a(line1)
	dta DL_JVB, a(dl)

.ifdef CARTRIDGE
	.align $BFFA, $FF
	.word cartstart     ; $BFFA - Run vector
	.byte $00           ; $BFFC - 00 = Cart inserted
	.byte $04           ; $BFFD - Diag (hi bit set), disk boot enable (bit 0 set)
	.word cartinit      ; $BFFE - Init
.endif