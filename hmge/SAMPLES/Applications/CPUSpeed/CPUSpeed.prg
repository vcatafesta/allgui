/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2005 Grigory Filatov <gfilatov@inbox.ru>
 *
*/
ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'CPU Speed / Real Time Clock Checker'
#define VERSION ' version 1.1'
#define COPYRIGHT ' 2005 Grigory Filatov. All Rights Reserved'

Static cFontName := "Times New Roman", nFontSize := 40
*--------------------------------------------------------*
Procedure Main()
*--------------------------------------------------------*
LOCAL cSpeed := Ltrim( Str( GetCPUSpeed(), 10, 0 ) ) + " MHz"

	SET MULTIPLE OFF

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 392 HEIGHT 148 - IF(IsThemed(), 0, 8) ;
		TITLE cSpeed ;
		ICON 'MAIN' ;
		MAIN NOMAXIMIZE NOSIZE ;
		FONT _GetSysFont() SIZE 8

		@ 5,5 LABEL Label_1a VALUE PROGRAM AUTOSIZE TRANSPARENT FONTCOLOR WHITE
		@ 4,4 LABEL Label_1b VALUE PROGRAM AUTOSIZE TRANSPARENT

		@ 25,11 LABEL Label_2a VALUE cSpeed WIDTH 360 HEIGHT 68 ;
			FONT cFontName SIZE nFontSize BOLD ITALIC ;
			CENTERALIGN TRANSPARENT FONTCOLOR WHITE

		@ 24,10 LABEL Label_2b VALUE cSpeed WIDTH 360 HEIGHT 68 ;
			FONT cFontName SIZE nFontSize BOLD ITALIC ;
			CENTERALIGN TRANSPARENT FONTCOLOR BLACK

		@ Form_1.Height-IF(IsWinNT(), 48, 44),11 LABEL Label_3a VALUE "Copyright " + Chr(169) + COPYRIGHT ;
			WIDTH 360 HEIGHT 16 CENTERALIGN TRANSPARENT FONTCOLOR WHITE

		@ Form_1.Height-IF(IsWinNT(), 49, 45),10 LABEL Label_3b VALUE "Copyright " + Chr(169) + COPYRIGHT ;
			WIDTH 360 HEIGHT 16 CENTERALIGN TRANSPARENT

		@ 0,0 LABEL Label_4 VALUE "" WIDTH 1 HEIGHT 1 // dummy label for proper drawing of label's shadow

		DEFINE TIMER Timer_1 ;
			INTERVAL 2000 ;
			ACTION OnTimer()

		ON KEY ALT+X ACTION ThisWindow.Release

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

RETURN

*--------------------------------------------------------*
Static Procedure OnTimer()
*--------------------------------------------------------*
LOCAL cSpeed := Ltrim( Str( GetCPUSpeed(), 10, 0 ) ) + " MHz"

	Form_1.Title := cSpeed

	if IsControlDefined(Label_2a, Form_1)
		Form_1.Label_2a.Release
		if !IsWinNT()
			@ 25,11 LABEL Label_2a OF Form_1 VALUE cSpeed ;
				WIDTH 360 HEIGHT 68 ;
				FONT cFontName SIZE nFontSize BOLD ITALIC ;
				CENTERALIGN TRANSPARENT FONTCOLOR WHITE
		endif
	endif

	Form_1.Label_2b.Release

	@ 24,10 LABEL Label_2b OF Form_1 VALUE cSpeed ;
		WIDTH 360 HEIGHT 68 ;
		FONT cFontName SIZE nFontSize BOLD ITALIC ;
		CENTERALIGN TRANSPARENT FONTCOLOR BLACK

Return
