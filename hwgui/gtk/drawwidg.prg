/*
* $Id: drawwidg.prg,v 1.8 2008/03/29 14:50:20 lculik Exp $
* HWGUI - Harbour Linux (GTK) GUI library source code:
* Pens, brushes, fonts, bitmaps, icons handling
* Copyright 2005 Alexander S.Kresin <alex@belacy.belgorod.su>
* www - http://www.geocities.com/alkresin/
*/

#include "hbclass.ch"
#include "windows.ch"
#include "guilib.ch"

#define HS_HORIZONTAL       0       /* ----- */
#define HS_VERTICAL         1       /* ||||| */
#define HS_FDIAGONAL        2       /* \\\\\ */
#define HS_BDIAGONAL        3       /* ///// */
#define HS_CROSS            4       /* +++++ */
#define HS_DIAGCROSS        5       /* xxxxx */

//- HFont

CLASS HFont INHERIT HObject

CLASS VAR aFonts   INIT {}

   DATA handle
   DATA name, width, height ,weight
   DATA charset, italic, Underline, StrikeOut
   DATA nCounter   INIT 1

METHOD Add( fontName, nWidth, nHeight ,fnWeight, fdwCharSet, fdwItalic, fdwUnderline, fdwStrikeOut, nHandle, lLinux )

METHOD Select( oFont )

METHOD Release()

ENDCLASS

METHOD Add( fontName, nWidth, nHeight ,fnWeight, fdwCharSet, fdwItalic, ;
      fdwUnderline, fdwStrikeOut, nHandle, lLinux ) CLASS HFont

   LOCAL i, nlen := Len( ::aFonts )

   nHeight  := Iif( nHeight==Nil,13,Abs(nHeight) )
   IF lLinux == Nil .OR. !lLinux
      nHeight -= 3
   ENDIF
   fnWeight := Iif( fnWeight==Nil,0,fnWeight )
   fdwCharSet := Iif( fdwCharSet==Nil,0,fdwCharSet )
   fdwItalic := Iif( fdwItalic==Nil,0,fdwItalic )
   fdwUnderline := Iif( fdwUnderline==Nil,0,fdwUnderline )
   fdwStrikeOut := Iif( fdwStrikeOut==Nil,0,fdwStrikeOut )

   FOR i := 1 TO nlen
      IF ::aFonts[i]:name == fontName .AND.          ;
            ::aFonts[i]:width == nWidth .AND.           ;
            ::aFonts[i]:height == nHeight .AND.         ;
            ::aFonts[i]:weight == fnWeight .AND.        ;
            ::aFonts[i]:CharSet == fdwCharSet .AND.     ;
            ::aFonts[i]:Italic == fdwItalic .AND.       ;
            ::aFonts[i]:Underline == fdwUnderline .AND. ;
            ::aFonts[i]:StrikeOut == fdwStrikeOut

         ::aFonts[i]:nCounter ++
         IF nHandle != Nil
            DELETEObject( nHandle )
         ENDIF

         RETURN ::aFonts[i]
      ENDIF
   NEXT

   IF nHandle == Nil
      ::handle := CreateFont( fontName, nWidth, nHeight*1024 ,fnWeight, fdwCharSet, fdwItalic, fdwUnderline, fdwStrikeOut )
   ELSE
      ::handle := nHandle
      nHeight := nHeight / 1024
   ENDIF

   ::name      := fontName
   ::width     := nWidth
   ::height    := nHeight
   ::weight    := fnWeight
   ::CharSet   := fdwCharSet
   ::Italic    := fdwItalic
   ::Underline := fdwUnderline
   ::StrikeOut := fdwStrikeOut

   Aadd( ::aFonts,Self )

   RETURN Self

METHOD Select( oFont ) CLASS HFont

   LOCAL af := SelectFont( oFont )

   IF af == Nil

      RETURN NIL
   ENDIF

   RETURN ::Add( af[2],af[3],af[4],af[5],af[6],af[7],af[8],af[9],af[1],.T. )

METHOD Release() CLASS HFont

   LOCAL i, nlen := Len( ::aFonts )

   ::nCounter --
   IF ::nCounter == 0
      #ifdef __XHARBOUR__
      FOR EACH i in ::aFonts
         IF i:handle == ::handle
            DELETEObject( ::handle )
            Adel( ::aFonts,hb_enumindex() )
            Asize( ::aFonts,nlen-1 )
            EXIT
         ENDIF
      NEXT
      #else
      FOR i := 1 TO nlen
         IF ::aFonts[i]:handle == ::handle
            DELETEObject( ::handle )
            Adel( ::aFonts,i )
            Asize( ::aFonts,nlen-1 )
            EXIT
         ENDIF
      NEXT
      #endif
   ENDIF

   RETURN NIL

   //- HPen

CLASS HPen INHERIT HObject

CLASS VAR aPens   INIT {}

   DATA handle
   DATA style, width, color
   DATA nCounter   INIT 1

METHOD Add( nStyle,nWidth,nColor )

METHOD Get( nStyle,nWidth,nColor )

METHOD Release()

ENDCLASS

METHOD Add( nStyle,nWidth,nColor ) CLASS HPen

   LOCAL i

   nStyle := Iif( nStyle == Nil,BS_SOLID,nStyle )
   nWidth := Iif( nWidth == Nil,1,nWidth )
   nColor := Iif( nColor == Nil,Vcolor("000000"),nColor )

   #ifdef __XHARBOUR__
   FOR EACH i in ::aPens
      IF i:style == nStyle .AND. ;
            i:width == nWidth .AND. ;
            i:color == nColor

         i:nCounter ++

         RETURN i
      ENDIF
   NEXT
   #else
   FOR i := 1 TO Len( ::aPens )
      IF ::aPens[i]:style == nStyle .AND. ;
            ::aPens[i]:width == nWidth .AND. ;
            ::aPens[i]:color == nColor

         ::aPens[i]:nCounter ++

         RETURN ::aPens[i]
      ENDIF
   NEXT
   #endif

   ::handle := CreatePen( nStyle,nWidth,nColor )
   ::style  := nStyle
   ::width  := nWidth
   ::color  := nColor
   Aadd( ::aPens, Self )

   RETURN Self

METHOD Get( nStyle,nWidth,nColor ) CLASS HPen

   LOCAL i

   nStyle := Iif( nStyle == Nil,PS_SOLID,nStyle )
   nWidth := Iif( nWidth == Nil,1,nWidth )
   nColor := Iif( nColor == Nil,Vcolor("000000"),nColor )

   #ifdef __XHARBOUR__
   FOR EACH i in ::aPens
      IF i:style == nStyle .AND. ;
            i:width == nWidth .AND. ;
            i:color == nColor

         RETURN i
      ENDIF
   NEXT
   #else
   FOR i := 1 TO Len( ::aPens )
      IF ::aPens[i]:style == nStyle .AND. ;
            ::aPens[i]:width == nWidth .AND. ;
            ::aPens[i]:color == nColor

         RETURN ::aPens[i]
      ENDIF
   NEXT
   #endif

   RETURN NIL

METHOD Release() CLASS HPen

   LOCAL i, nlen := Len( ::aPens )

   ::nCounter --
   IF ::nCounter == 0
      #ifdef __XHARBOUR__
      FOR EACH i  in ::aPens
         IF i:handle == ::handle
            DELETEObject( ::handle )
            Adel( ::aPens,hb_EnumIndex() )
            Asize( ::aPens,nlen-1 )
            EXIT
         ENDIF
      NEXT
      #else
      FOR i := 1 TO nlen
         IF ::aPens[i]:handle == ::handle
            DELETEObject( ::handle )
            Adel( ::aPens,i )
            Asize( ::aPens,nlen-1 )
            EXIT
         ENDIF
      NEXT
      #endif
   ENDIF

   RETURN NIL

   //- HBrush

CLASS HBrush INHERIT HObject

CLASS VAR aBrushes   INIT {}

   DATA handle
   DATA color
   DATA nHatch   INIT 99
   DATA nCounter INIT 1

METHOD Add( nColor )

METHOD Release()

ENDCLASS

METHOD Add( nColor ) CLASS HBrush

   LOCAL i

   #ifdef __XHARBOUR__
   FOR EACH i IN ::aBrushes
      IF i:color == nColor
         i:nCounter ++

         RETURN i
      ENDIF
   NEXT
   #else
   FOR i := 1 TO Len( ::aBrushes )
      IF ::aBrushes[i]:color == nColor
         ::aBrushes[i]:nCounter ++

         RETURN ::aBrushes[i]
      ENDIF
   NEXT
   #endif
   ::handle := CreateSolidBrush( nColor )
   ::color  := nColor
   Aadd( ::aBrushes,Self )

   RETURN Self

METHOD Release() CLASS HBrush

   LOCAL i, nlen := Len( ::aBrushes )

   ::nCounter --
   IF ::nCounter == 0
      #ifdef __XHARBOUR__
      FOR EACH i IN ::aBrushes
         IF i:handle == ::handle
            DELETEObject( ::handle )
            Adel( ::aBrushes,hb_EnumIndex() )
            Asize( ::aBrushes,nlen-1 )
            EXIT
         ENDIF
      NEXT
      #else
      FOR i := 1 TO nlen
         IF ::aBrushes[i]:handle == ::handle
            DELETEObject( ::handle )
            Adel( ::aBrushes,i )
            Asize( ::aBrushes,nlen-1 )
            EXIT
         ENDIF
      NEXT
      #endif
   ENDIF

   RETURN NIL

   //- HBitmap

CLASS HBitmap INHERIT HObject

CLASS VAR aBitmaps   INIT {}

   DATA handle
   DATA name
   DATA nWidth, nHeight
   DATA nCounter   INIT 1

METHOD AddResource( name )

METHOD AddFile( name,HDC )

METHOD AddWindow( oWnd,lFull )

METHOD Release()

ENDCLASS

METHOD AddResource( name ) CLASS HBitmap

   LOCAL lPreDefined := .F., i, aBmpSize

   IF Valtype( name ) == "N"
      name := Ltrim( Str( name ) )
      lPreDefined := .T.
   ENDIF
   #ifdef __XHARBOUR__
   FOR EACH i  IN  ::aBitmaps
      IF i:name == name
         i:nCounter ++

         RETURN i
      ENDIF
   NEXT
   #else
   FOR i := 1 TO Len( ::aBitmaps )
      IF ::aBitmaps[i]:name == name
         ::aBitmaps[i]:nCounter ++

         RETURN ::aBitmaps[i]
      ENDIF
   NEXT
   #endif
   ::handle :=   LoadBitmap( Iif( lPreDefined, Val(name),name ) )
   IF !Empty( ::handle )
      ::name   := name
      aBmpSize  := GetBitmapSize( ::handle )
      ::nWidth  := aBmpSize[1]
      ::nHeight := aBmpSize[2]
      Aadd( ::aBitmaps,Self )
   ELSE

      RETURN NIL
   ENDIF

   RETURN Self

METHOD AddFile( name,HDC ) CLASS HBitmap

   LOCAL i, aBmpSize

   #ifdef __XHARBOUR__
   FOR EACH i IN ::aBitmaps
      IF i:name == name
         i:nCounter ++

         RETURN i
      ENDIF
   NEXT
   #else
   FOR i := 1 TO Len( ::aBitmaps )
      IF ::aBitmaps[i]:name == name
         ::aBitmaps[i]:nCounter ++

         RETURN ::aBitmaps[i]
      ENDIF
   NEXT
   #endif
   ::handle := OpenImage( name )
   IF !Empty( ::handle )
      ::name := name
      aBmpSize  := GetBitmapSize( ::handle )
      ::nWidth  := aBmpSize[1]
      ::nHeight := aBmpSize[2]
      Aadd( ::aBitmaps,Self )
   ELSE

      RETURN NIL
   ENDIF

   RETURN Self

METHOD AddWindow( oWnd,lFull ) CLASS HBitmap

   LOCAL i, aBmpSize

   // ::handle := Window2Bitmap( oWnd:handle,lFull )
   ::name := Ltrim( Str( oWnd:handle ) )
   aBmpSize  := GetBitmapSize( ::handle )
   ::nWidth  := aBmpSize[1]
   ::nHeight := aBmpSize[2]
   Aadd( ::aBitmaps,Self )

   RETURN Self

METHOD Release() CLASS HBitmap

   LOCAL i, nlen := Len( ::aBitmaps )

   ::nCounter --
   IF ::nCounter == 0
      #ifdef __XHARBOUR__
      FOR EACH i IN ::aBitmaps
         IF i:handle == ::handle
            DELETEObject( ::handle )
            Adel( ::aBitmaps,hb_EnumIndex() )
            Asize( ::aBitmaps,nlen-1 )
            EXIT
         ENDIF
      NEXT
      #else
      FOR i := 1 TO nlen
         IF ::aBitmaps[i]:handle == ::handle
            DELETEObject( ::handle )
            Adel( ::aBitmaps,i )
            Asize( ::aBitmaps,nlen-1 )
            EXIT
         ENDIF
      NEXT
      #endif
   ENDIF

   RETURN NIL

   //- HIcon

CLASS HIcon INHERIT HObject

CLASS VAR aIcons   INIT {}

   DATA handle
   DATA name
   DATA nCounter   INIT 1
   DATA nWidth, nHeight

METHOD AddResource( name )

METHOD AddFile( name,HDC )

METHOD Release()

ENDCLASS

METHOD AddResource( name ) CLASS HIcon

   LOCAL lPreDefined := .F., i

   IF Valtype( name ) == "N"
      name := Ltrim( Str( name ) )
      lPreDefined := .T.
   ENDIF
   #ifdef __XHARBOUR__
   FOR EACH i IN ::aIcons
      IF i:name == name
         i:nCounter ++

         RETURN i
      ENDIF
   NEXT
   #else
   FOR i := 1 TO Len( ::aIcons )
      IF ::aIcons[i]:name == name
         ::aIcons[i]:nCounter ++

         RETURN ::aIcons[i]
      ENDIF
   NEXT
   #endif
   // ::handle :=   LoadIcon( Iif( lPreDefined, Val(name),name ) )
   ::name   := name
   Aadd( ::aIcons,Self )

   RETURN Self

METHOD AddFile( name ) CLASS HIcon

   LOCAL i, aBmpSize

   #ifdef __XHARBOUR__
   FOR EACH i IN  ::aIcons
      IF i:name == name
         i:nCounter ++

         RETURN i
      ENDIF
   NEXT
   #else
   FOR i := 1 TO Len( ::aIcons )
      IF ::aIcons[i]:name == name
         ::aIcons[i]:nCounter ++

         RETURN ::aIcons[i]
      ENDIF
   NEXT
   #endif
   //   ::handle := LoadImage( 0, name, IMAGE_ICON, 0, 0, LR_DEFAULTSIZE+LR_LOADFROMFILE )
   //   ::handle := OpenImage( name )
   //   ::name := name
   //   Aadd( ::aIcons,Self )
   Tracelog("name = ",name)
   ::handle := OpenImage( name )
   tracelog("handle = ",::handle)
   IF !Empty( ::handle )
      ::name := name
      aBmpSize  := GetBitmapSize( ::handle )
      ::nWidth  := aBmpSize[1]
      ::nHeight := aBmpSize[2]
      Aadd( ::aIcons,Self )
   ELSE

      RETURN NIL
   ENDIF

   RETURN Self

METHOD Release() CLASS HIcon

   LOCAL i, nlen := Len( ::aIcons )

   ::nCounter --
   IF ::nCounter == 0
      #ifdef __XHARBOUR__
      FOR EACH i IN ::aIcons
         IF i:handle == ::handle
            DELETEObject( ::handle )
            Adel( ::aIcons,hb_EnumIndex() )
            Asize( ::aIcons,nlen-1 )
            EXIT
         ENDIF
      NEXT
      #else
      FOR i := 1 TO nlen
         IF ::aIcons[i]:handle == ::handle
            DELETEObject( ::handle )
            Adel( ::aIcons,i )
            Asize( ::aIcons,nlen-1 )
            EXIT
         ENDIF
      NEXT
      #endif
   ENDIF

   RETURN NIL

   EXIT PROCEDURE CleanDrawWidg
   LOCAL i

   FOR i := 1 TO Len( HPen():aPens )
      DELETEObject( HPen():aPens[i]:handle )
   NEXT
   FOR i := 1 TO Len( HBrush():aBrushes )
      DELETEObject( HBrush():aBrushes[i]:handle )
   NEXT
   FOR i := 1 TO Len( HFont():aFonts )
      DELETEObject( HFont():aFonts[i]:handle )
   NEXT
   FOR i := 1 TO Len( HBitmap():aBitmaps )
      DELETEObject( HBitmap():aBitmaps[i]:handle )
   NEXT
   FOR i := 1 TO Len( HIcon():aIcons )
      // DeleteObject( HIcon():aIcons[i]:handle )
   NEXT

   RETURN

