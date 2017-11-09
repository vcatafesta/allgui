/*
* RECOVER_DOUBLE FUNCTION
* recover variable floating value from Harbour Standard C PCODE
* Copyright 2008-2009 Arcangelo Molinaro <arcangelo.molinaro@fastwebnet.it>
* Donated to Public Domain.
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2, or (at your option)
* any later version.
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

FUNCTION RECOVER_DOUBLE(n8,n7,n6,n5,n4,n3,n2,n1,n9,n10)

   // tested only positive .and. negative number
   // Not implemented yet NaN, +/- INFINITE, +/- 0
   // Need to be tested carefully. Surely it's bugged !!
   // Maybe a value error occurs (!=same as originale value)
   // on latest decimal digit (or in other latest position)
   // of recovered string ( Math approx ?? ) !!
   // ***************************************************
   // This is an Evaluation Version of program.
   // Suggestions and recommendations are welcome.

   LOCAL aNumero:={n1,n2,n3,n4,n5,n6,n7,n8},nLen:=LEN(aNumero)
   LOCAL nWidth:=n9+n10+1,nDecimal:=n10,nOriginalValue:=0
   LOCAL cOriginalValue:=str(0,nWidth,nDecimal)
   LOCAL i:=0 ,k:=0,cStringa:="", cSegno:="",cBiased:="", cFractional:=""
   LOCAL cBit:="",nBiased:=0,nTotale:=0,nCount:=0
   LOCAL STable:={},nSet:=0,nBase:=0

   nSet:=SET(_SET_DECIMALS)
   SET decimals to 40
   FOR i= 1 to nLen
      cStringa:=cStringa+DC_DecToBin(aNumero[i])
   NEXT i
   nLen:=len(cStringa)
   i:=0
   FOR i= 1 to nLen
      cBit:=substr(cStringa,i,1)
      DO CASE
      CASE i=1
         iif (cBit=="1",cSegno:="-",cSegno:="+")
      CASE i>1 .AND. i<13
         cBiased:=cBiased+cBit
      CASE i >=13
         cFractional:=cFractional+cBit
      OTHERWISE
         MsgExclamation("Severe error","Exit Program")
      ENDCASE
   NEXT i
   nBase:=DC_BinToDec(cBiased)
   nBiased:=2**(nBase-1023)
   IF cSegno=="-"
      nBiased:=(-1)*nBiased
   ENDIF
   nCount:=LEN(cFractional)
   FOR k= 1 to nCount
      aadd(STable, (1/2**k))
   NEXT k
   i:=0
   FOR i= 1 to nCount
      nTotale:=nTotale+val(substr(cFractional,i,1))*STable[i]
   NEXT i
   nTotale:=nTotale+1
   nOriginalValue:=nTotale*nBiased
   cOriginalValue:=str(nOriginalValue,nWidth,nDecimal)
   SET DECIMALS TO (nSet)

   RETURN (alltrim(cOriginalValue))

STATIC FUNCTION DC_DecToBin(nNumber)

   // We need to check if parameter passed is correct !!
   // Not yet implemented !!

   LOCAL cNewString:='',nLen:=0,i:=0
   LOCAL nTemp:=0

   WHILE(nNumber > 0)
   nTemp:=(nNumber%2)
   cNewString:=SubStr('01',(nTemp+1),1)+cNewString
   nNumber:=Int((nNumber-nTemp)/2)
ENDDO
nLen:=len(cNewString)
IF nLen < 8
   FOR i = (nLen+1) to 8
      cNewString:="0"+cNewString
   NEXT i
ENDIF

RETURN(cNewString)

STATIC FUNCTION DC_BinToDec(cString)

   // We need to check if parameter passed is correct !!
   // Not yet implemented !!
   LOCAL nNumber:=0,nX:=0
   LOCAL cNewString:=AllTrim(cString)
   LOCAL nLen:=Len(cNewString)

   FOR nX:=1 to nLen
      nNumber+=(At(SubStr(cNewString,nX,1),'01')-1)*(2**(nLen-nX))
   NEXT nX

   RETURN(int(nNumber))

