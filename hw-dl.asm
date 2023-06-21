/* Hello World: Display List
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

    mwa #dl SDLSTL

	jmp *			; endless loop (jmp to self)

text
	dta d'.:. MADS .:.'*,d'  Hello World   ',d'.:. MADS .:.'*	; * Adds 128 to chars between '', so becomes inverse

; Display List
dl
    dta DL_BLANK8,DL_BLANK8,DL_BLANK8
    dta DL_GR0 | DL_LMS ,a(text)
    dta DL_JVB,a(dl)

.ifdef CARTRIDGE
	.align $BFFA, $FF
	.word cartstart     ; $BFFA - Run vector
	.byte $00           ; $BFFC - 00 = Cart inserted
	.byte $04           ; $BFFD - Diag (hi bit set), disk boot enable (bit 0 set)
	.word cartinit      ; $BFFE - Init
.endif