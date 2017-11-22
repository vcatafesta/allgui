/*

NUMBERS.PRG   Numeric and math functions

*/
#include "default.ch"

FUNCTION Crop(nMin, nValue, nMax)

   /*
   "Crops" a value to make sure it falls between the minimum and maximum
   values.  Used primarily because I'm always reversing the functions min()
   and max() and messing things up.  Works on dates too.

   Either nMin or nMax may be omitted.
   */
   LOCAL nRet := nValue

   IF nMin <> NIL
      nRet := max(nMin, nRet)
   ENDIF

   IF nMax <> NIL
      nRet := min(nMax, nRet)
   ENDIF

   Return(nRet)

FUNCTION CtoN(c, lBigEndian)

   /*
   Converts a character binary representation of a number into a positive
   integer numeric.  Works on any length string, but two- or four- byte
   strings would be most common.

   By default, the string is processed in little-endian format (with the least
   significant digit first).  Setting lBigEndian to true will reverse this.

   See also: NtoC()

   Similar Clipper functions: BIN2I(), BIN2L(), BIN2W()
   */
   LOCAL n := 0, nMod := 1
   LOCAL x, nFrom := 1, nTo := len(c), nStep := 1

   DEFAULT lBigEndian := .F.

   IF lBigEndian
      nFrom := nTo
      nTo   := 1
      nStep := -1
   ENDIF

   FOR x := nFrom to nTo step nStep
      n += asc(substr(c, x, 1)) * nMod
      nMod *= 256
   NEXT

   Return(n)

FUNCTION Factorial(n)

   /*

   Returns the factorial (n!) of an integer.
   */
   LOCAL f := n
   LOCAL x, y := n - 1

   FOR x := y to 2 step -1
      f *= x
   NEXT

   Return(f)

FUNCTION HtoN(cHex)

   /*
   Converts a two-character hex string to a number from 0-255.

   Example: HtoN("FF") -> 255
   */
   LOCAL cDigits := "0123456789ABCDEF"
   LOCAL n

   n := max(at(substr(cHex, 1, 1), cDigits) - 1, 0) * 16

   n += max(at(substr(cHex, 2, 1), cDigits) - 1, 0)

   Return(n)

FUNCTION NtoC(nValue, nLen, lBigEndian)

   /*
   Converts a positive integer into a binary character string.

   nLen determines the length of the resulting string and defaults to 2.

   By default, the string is created in little-endian format (with the least
   significant digit first).  Setting lBigEndian to true will reverse this.

   See also: CtoN()

   Similar Clipper functions: I2BIN(), L2BIN()
   */
   LOCAL nMod, x, c
   LOCAL cRet := ""

   DEFAULT nLen := 2, ;
      lBigEndian := .F.

   nMod := 256 ^ (nLen - 1) // x ^ 0 = 1

   FOR x := 1 to nLen
      c := chr(int(nValue / nMod))
      IF lBigEndian
         cRet += c
      ELSE
         cRet := c + cRet
      ENDIF
      nValue %= nMod
      nMod /= 256
   NEXT

   Return(cRet)

FUNCTION NtoH(n)

   /*
   Converts a numeric byte value (0-255) into a 2-character hex string.

   Example: NtoH(255) -> "FF"
   */
   LOCAL cDigits := "0123456789ABCDEF"
   LOCAL cHex := substr(cDigits, int((n % 256) / 16) + 1, 1) + ;
      substr(cDigits, (n % 16) + 1, 1)

   Return(cHex)

FUNCTION XFix(x, nDec)

   /*
   "Fixes" a number with the correct number of decimal places.
   First, it is turned into a string with (nDec + 1) decimal places.  The
   extra decimal is truncated and the val() of that string is returned.

   nDec defaults to 2.
   */
   LOCAL cNum

   DEFAULT nDec := 2

   cNum := ltrim(str(x, 15, nDec + 1))

   cNum := left(cNum, len(cNum) - iif(nDec > 0, 1, 2))

   Return(val(cNum))

FUNCTION XRound(x, nDec)

   /*
   A replacement for round() that apparently really works.
   Originally by Richard Fagen and retrieved from the CIS Clipper forum.

   nDec defaults to 2 decimal places.
   */
   LOCAL nExp, nMod := iif(x < 0, -.50001, .50001)

   DEFAULT nDec := 2  // Default to 2 decimal places

   nExp := 10 ^ nDec
   x := int(x * nExp + nMod) / nExp

   // Give x the proper number of decimal places upon returning:

   Return(XFix(x, nDec))

