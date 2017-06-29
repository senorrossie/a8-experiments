/* COMPILE:
** # Windows
** "c:\Program Files (x86)\MADS\mads.exe" -i:inc\ -o:xex\filename.xex filename.asm
**
** # Linux / OSX
** mads -i:inc/ -o:xex/filename.xex filename.asm
*/

	icl "systemequates.20070530_bkw.inc"		; Don't forget the specify -i:<path to file> at compile time

	org $5100
pic_pg1
	ins "senor-rossie.dat"
pic_pg2 = $6000

	org $a800
	
// MAIN
init
	mwa #dl SDLSTL

	lda #$18
	sta COLOR0
	lda #$0e
	sta COLOR1
	lda #$24
	sta COLOR2
	lda #$00
	sta COLOR4

endless
	jmp endless
// END: main


/*** Display List ***/
dl
	dta DL_BLANK1
	dta DL_GR15 | DL_LMS, a(pic_pg1)								; $4e, $5100
:95	dta DL_GR15														; Create 95 lines of gr 15 (40 bytes/line)
	dta DL_GR15 | DL_LMS, a(pic_pg2)								; $4e, $6000
:95	dta DL_GR15														; Create 95 lines of gr 15 (40 bytes/line)
	dta DL_BLANK7 | DL_DLI											; $70+$80
	dta DL_JVB, a(dl)												; $51, (dl)

/*************************************/
	ini init
/*************************************/
