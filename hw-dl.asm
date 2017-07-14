/* Hello World: Display List
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

    mwa #dl SDLSTL

	jmp *			; endless loop (jmp to self)

text
	dta d'.:. MADS .:.'*,d'  Hello World   ',d'.:. MADS .:.'*	; * Adds 128 to chars between '', so becomes inverse

; Display List
dl
    dta DL_BLANK8,DL_BLANK8,DL_BLANK8
    dta DL_GR0 | DL_LMS ,a(text)
    dta DL_JVB,a(dl)
