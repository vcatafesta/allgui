/*
Created : 2012-06-01
Author : Tsakalidis G. Evangelos <tsakal@otenet.gr>
*/

#include "hbclass.ch"

CREATE CLASS stringBuffer

   DATA aStringBuffer

METHOD New()

METHOD setStr(strIn)

METHOD getStr(sSeparator)

ENDCLASS

METHOD New() CLASS stringBuffer

   ::aStringBuffer := {}

   RETURN SELF

METHOD setStr( strIn ) CLASS stringBuffer

   IF valType( strIn ) != 'U'
      aadd( ::aStringBuffer, strIn )
   ENDIF

   RETURN NIL

METHOD getStr( sSeparator ) CLASS stringBuffer

   DEFAULT sSeparator := ''

   RETURN( aJoin( ::aStringBuffer, sSeparator ) )

STATIC FUNCTION aJoin( aIn, sDelim )

   LOCAL sRet := ''
   LOCAL iLen := len(aIn)

   DO CASE
   CASE iLen == 0
      sRet := ''
   CASE iLen == 1
      sRet := aIn[1]
   OTHERWISE
      aeval( aIn, { |x| sRet += ( x + sDelim ) }, 1, iLen - 1 )
      sRet += aIn[iLen]
   ENDCASE

   RETURN( sRet )
