/*
* .C (PCODE) to .Prg  Harbour Recover Code
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

#include "fileio.ch"

#ifndef __XHARBOUR__
#xtranslate At(<a>,<b>,[<x,...>]) => hb_At(<a>,<b>,<x>)
#endif

FUNCTION decode_c2prg(cFilename)  // *.c file (PCODE)

   LOCAL cStringa:="",aReturn:={}
   LOCAL cNewFilename:=BEFORATNUM(".",cFilename,1)+".dhr"
   LOCAL nHandle:=0,i:=0,k:=0,lMode:=.t.,aFunctionName:={},nMode:=-1
   LOCAL nLen:=0,aMacroCode:={},aFunctionCode:={}
   LOCAL cFuncCode:=""

   IF FILE(cNewFilename)
      DELETE FILE(cNewFilename)
   ENDIF
   IF ((nHandle:=FCREATE(cNewFilename,FC_NORMAL))==-1)
      MsgInfo("File cannot be created !","Exit Procedure")

      RETURN NIL
   ENDIF
   IF !(FCLOSE(nHandle))
      MsgInfo("File cannot be closed !","Exit Procedure")

      RETURN NIL
   ENDIF
   aReturn:=dcp_load_Data(cFilename)
   aReturn:=dcp_split_code(aReturn,cNewFileName)

   RETURN NIL

FUNCTION dcp_load_Data(cFilename)

   LOCAL cStringa:=""
   LOCAL cNewString:="" ,cFuncName:="",nLen:=0
   LOCAL i:=0,aSFuncName:={},aLFuncName:={},aReturn:={},k:=0,j:=0
   LOCAL aCode:={},nResult:=-1, nStart:=0,aParam:={},nEnd:=0,lOneTime:=.T.
   LOCAL nTotalVar:=0,nParam:=0,aVar:={},aWFuncName:={},aGlobalVar:={}

   cStringa:=MEMOREAD(cFileName)
   WHILE .T.
      IF !empty(cStringa)
         IF lOneTime
            nStart:=AT("HB_FUNC(",cStringa)
            nEnd:=AT(")",cStringa,nStart)
            cFuncName:=ALLTRIM(Substr(cStringa, nStart,nEnd-nStart))
            lOneTime:=.F.
         ELSE
            cFuncName:=alltrim(BEFORATNUM(";",cStringa,1))
         ENDIF
         cNewString:=alltrim(AFTERATNUM(";",cStringa,1))
         IF left(cFuncName,8)="HB_FUNC("
            cFuncName:=alltrim(ATREPL("HB_FUNC(",cFuncName,""))
            cFuncName:=alltrim(ATREPL(")",cFuncName,""))
            AADD(aSFuncName,cFuncName)
         ELSEIF left(cFuncName,15)="HB_FUNC_STATIC("
            cFuncName:=alltrim(ATREPL("HB_FUNC_",cFuncName,""))
            cFuncName:=alltrim(ATREPL("(",cFuncName,""))
            cFuncName:=alltrim(ATREPL(")",cFuncName,""))
            AADD(aSFuncName,cFuncName)
         ELSEIF left(cFuncName,15)="HB_FUNC_EXTERN("
            cFuncName:=alltrim(ATREPL("HB_FUNC_EXTERN(",cFuncName,""))
            cFuncName:=alltrim(ATREPL(")",cFuncName,""))
            AADD(aLFuncName,cFuncName)
         ELSEIF left(cFuncName,8)="HB_FUNC_"            // _INITLINES()
            cFuncName:=alltrim(ATREPL("HB_FUNC",cFuncName,""))
            AADD(aSFuncName,cFuncName)
         ENDIF
         cStringa:=cNewString
      ELSE
         EXIT // FINE STRINGA
      ENDIF
   END
   aCode:=dcp_load_array(cFileName)[1]
   nStart:=0
   I:=0
   nLen:=LEN(aCode)  //# of function in original source code
   FOR i= 1 TO nLen
      nResult:=1
      IF aCode[i][nResult]==13  //MUST BE ALWAYS THE FIRST PCODE IF VAR/PAR EXIST
         aadd(aParam,{aCode[i][nResult+1],aCode[i][nResult+2]}) // # of var/param.each source func.
         nTotalVar:=aCode[i][nResult+1]+aCode[i][nResult+2]
         nParam:=aCode[i][nResult+2]
         aVar:=array(nTotalVar) // # of total var+param
         FOR j:=1 to  nTotalVar
            IF j <= nParam
               aVar[j]:="Par"+alltrim(str(j))
            ELSE
               aVar[j]:="Var"+alltrim(str(j))
            ENDIF
         NEXT j
         aadd(aGlobalVar,Avar)
         aVar:={}
      ELSE
         aadd(aParam,{0,0}) // No var/Param
         aadd(aGlobalVar,Avar)
      ENDIF
   NEXT i
   i:=0
   k:=0
   aWFuncName:=ACLONE(aSFuncName)
   FOR i=1 to nLen
      cStringa:=""
      IF aParam[i][2]>0
         FOR k:=1 to aParam[i][2]
            IF  k<>aParam[i][2]
               cStringa:=cStringa+"Par"+alltrim(str(k))+","
            ELSE
               cStringa:=cStringa+"Par"+alltrim(str(k))+")"
            ENDIF
         NEXT k
         IF !empty(aWFuncName[i])
            IF left(aWFuncName[i],6)="STATIC"
               aWFuncName[i]:="Static Function "+alltrim(substr(aWFuncName[i],7,len(aWFuncName)))+"("+cStringa
            ELSE
               aWFuncName[i]:="Function "+aWFuncName[i]+"("+cStringa
            ENDIF
         ENDIF
      ELSE
         IF !empty(aWFuncName[i])
            IF left(aWFuncName[i],6)="STATIC"
               aWFuncName[i]:="Static Function "+alltrim(substr(aWFuncName[i],7,len(aWFuncName)))
            ELSE
               aWFuncName[i]:="Function "+aWFuncName[i]
            ENDIF
         ENDIF
      ENDIF
   NEXT i
   aadd(aReturn,aSFuncName)  // source name function
   aadd(aReturn,aLFuncName)  // function name EXTERN (*.OBJ or *.LIB)
   aadd(aReturn,aWFuncName)  // Formatted String for print HEAD FUNCTION
   aadd(aReturn,aCode)       // array of PCODE for each single function
   aadd(aReturn,aGlobalVar)  // array of var/par for each single function

   RETURN aReturn

FUNCTION dcp_load_array(cFilename)

   LOCAL aCode:={},cStringa:="",nPos:=0
   LOCAL cGlobalString:="",aTemp:={},nStart:=0,cTempString:=""

   cGlobalString:=memoread(cFilename)
   WHILE .t.
      nPos:=AT("pcode[] =",cGlobalString,nStart)
      IF nPos=0 .AND. empty(aCode)
         Msginfo("Not a valid Harbour 'c'pcode source","Trace Message")

         RETURN NIL
      ELSEIF nPos=0 .AND. !empty(aCode)
         EXIT   // End of Array
      ELSE
         nPos:=nPos+10
         cTempString:="pcode[] ="+alltrim(AFTERATNUM("pcode[] =",cGlobalString,2))
         cGlobalString:=alltrim(substr(cGlobalString,nPos,len(cGlobalString)))
         cGlobalString:=alltrim(ATREPL(chr(13),cGlobalString,""))
         cGlobalString:=alltrim(ATREPL(chr(10),cGlobalString,""))
         cGlobalString:=alltrim(ATREPL(chr(9),cGlobalString,""))
         cGlobalString:=alltrim(ATREPL("{",cGlobalString,""))
         cGlobalString:=alltrim(ATREPL("  ",cGlobalString,""))
         cGlobalString:=alltrim(ATREPL(" ",cGlobalString,""))
         cGlobalString:=alltrim(BEFORATNUM("}",cGlobalString,1))
         IF empty(cGlobalString)
            Msginfo("All function were processed !","Trace Message")
            EXIT
         ENDIF
      ENDIF
      IF !empty(cGlobalString)
         AADD(aCode,dcp_str2arr(cGlobalString,","))
      ENDIF
      cGlobalString:=cTempString
      cTempString:=""
   end
   aadd(aTemp,aCode)
   aadd(aTemp,cFilename)

   RETURN (aTemp)

STATIC FUNCTION dcp_str2arr( cList, cDelimiter )

   LOCAL nPos
   LOCAL aList := {}
   LOCAL nlencd:=0
   LOCAL asub

   DO CASE
   CASE VALTYPE(cDelimiter)=='C'
      cDelimiter:=if(cDelimiter==NIL,",",cDelimiter)
      nlencd:=len(cdelimiter)
      DO WHILE ( nPos := AT( cDelimiter, cList )) != 0
         AADD( aList, VAL(SUBSTR( cList, 1, nPos - 1 )))
         cList := SUBSTR( cList, nPos + nlencd )
      ENDDO
      AADD( aList, VAL(cList) )
   CASE VALTYPE(cDelimiter)=='N'
      DO WHILE len((nPos:=left(cList,cDelimiter)))==cDelimiter
         aadd(aList,nPos)
         cList:=substr(cList,cDelimiter+1)
      ENDDO
   CASE VALTYPE(cDelimiter)=='A'
      AEVAL(cDelimiter,{|x| nlencd+=x})
      DO WHILE len((nPos:=left(cList,nlencd)))==nlencd
         asub:={}
         aeval(cDelimiter,{|x| aadd(asub,left(nPos,x)),nPos:=substr(nPos,x+1)})
         aadd(aList,asub)
         cList:=substr(cList,nlencd+1)
      ENDDO
   ENDCASE

   RETURN ( aList )

FUNCTION dcp_split_code(aReturn,cNewFileName)

   LOCAL aGlobalCode:={},aCode:={},aSFuncName:={},aLFuncName:={}
   LOCAL aWFuncName:={},aGlobalVar:={},aTemp:={},aVar:={}
   LOCAL nLen:=0,i:=0,j:=0,aRowCode:={},nResult:=-1,nStart:=0,nLenCode:=0
   LOCAL cStringa:="",nLenRow:=0,nPCode:=0,nNextRow:=0,nJump:=0
   LOCAL aStack:={},nLenVar:=0,lDeclaration:=.T.,nAssignedVar:=0
   LOCAL aGlobalRowCode:={},aForNextStack:={},aSkipCode:={}

   aSFuncName:=aReturn[1]
   aLFuncName:=aReturn[2]
   aWFuncName:=aReturn[3]
   aGlobalCode:=aReturn[4]
   aGlobalVar:=aReturn[5]
   nLen:=LEN(aGlobalCode)
   FOR j=1 to nLen
      aCode:=aGlobalCode[j]
      aVar:=aGlobalVar[j]
      nLenCode:=LEN(aCode)
      nLenVar:=LEN(aVar)
      nLenRow:=dcp_FindLastRow(aCode)
      aRowCode:=array(nLenRow)
      AFILL(aRowCode,NIL)
      aRowCode[1]:=aWFuncName[j]
      WHILE .t.
         IF i<nLenCode
            i:=i+1
            nPcode:=aCode[i]
            DO CASE
            CASE nPcode==51
               // da correggere
               aTemp:=dcp_f51(aCode,i)
               cStringa:=cStringa+aTemp[1]
               nJump:=aTemp[2]
               i:=nJump
            CASE nPcode==36
               //Dovrebbe sTampare stringa a nNextRow
               // e poi cambiare i valori con la nuova lettura
               // azzerando eventualmente cStringa:=""
               // OK FATTO - FUNZIONA ??!!

               aTemp:=dcp_f36(aCode,i,aRowCode,nNextRow,cStringa,lDeclaration)
               nJump:=aTemp[1]
               IF aTemp[2] >= nNextRow
                  nNextRow:=aTemp[2]
               ELSE
                  nNextRow:=nNextRow+1
               ENDIF
               aRowCode:=aTemp[3]
               cStringa:=aTemp[4]
               i:=nJump
               IF (nAssignedVar==nLenVar)
                  lDeclaration:=.F.  //write source if .t. write declaration
               ENDIF

            CASE nPcode==4
               aTemp:=dcp_f4(aCode,i,aStack)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==95
               aTemp:=dcp_f95(aCode,i,aStack,aVar)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==72
               aTemp:=dcp_f72(aCode,i,aStack,aVar)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==101
               aTemp:=dcp_f101(aCode,i,aStack)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==106
               aTemp:=dcp_f106(aCode,i,aStack)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==98
               altd()  // da correggere !!
               aTemp:=dcp_f98(aCode,i,aLFuncName)
               cStringa:=cStringa+aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==165
               aTemp:=dcp_f165(aCode,i,aStack,aVar,aRowCode,nNextRow,lDeclaration,aSkipCode)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               aRowCode:=aTemp[3]
               nNextRow:=aTemp[4]
               aSkipCode:=aTemp[5]
               i:=nJump

            CASE nPcode==93
               altd()   // da correggere
               aTemp:=dcp_f93(aCode,i,cStringa)
               cStringa:=cStringa+aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==92
               aTemp:=dcp_f92(aCode,i,aStack)
               nJump:=aTemp[1]
               aStack:=aTemp[2]
               i:=nJump

            CASE nPcode==97
               aTemp:=dcp_f97(aCode,i,aStack)
               nJump:=aTemp[1]
               aStack:=aTemp[2]
               i:=nJump

            CASE nPcode==13
               nJump:=i+2
               i:=nJump

            CASE nPcode==25
               aTemp:=dcp_f25(aCode,i,aVar,aStack,cStringa,lDeclaration)
               aStack:=aTemp[1]
               cStringa:=cStringa+aTemp[2]
               nJump:=aTemp[3]
               i:=nJump

            CASE nPcode==120
               aTemp:=dcp_f120(aCode,i,aStack)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==9
               aTemp:=dcp_f9(aCode,i,aStack)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==121
               aTemp:=dcp_f121(aCode,i,aStack)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==122
               aTemp:=dcp_f122(aCode,i,aStack)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==80
               aTemp:=dcp_f80(aCode,i,aVar,aStack,cStringa,lDeclaration)
               aStack:=aTemp[1]
               cStringa:=aTemp[2]
               nJump:=aTemp[3]
               nAssignedVar:=aTemp[4]
               i:=nJump

            CASE nPcode==2
               dcp_f2()

            CASE nPcode==175
               aTemp:=dcp_f175(aCode,i,aStack,aVar,aRowCode,nNextRow,aSkipCode)
               aRowCode:=aTemp[1]
               nNextRow:=aTemp[2]
               nJump:=aTemp[3]
               i:=nJump

            CASE nPcode==176
               aTemp:=dcp_f176(aCode,i,aLFuncName)
               cStringa:=cStringa+aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==100
               aTemp:=dcp_f100(aCode,i,aStack)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               i:=nJump

            CASE nPcode==110
               aTemp:=dcp_f110(aCode,i,aStack)
               aStack:=aTemp[1]
               nJump:=aTemp[2]
               cStringa:=aTemp[3]
               i:=nJump

            CASE nPcode==7
               aTemp:=dcp_f7(aRowCode,nNextRow,cStringa,i)
               aRowCode:=aTemp[1]
               nJump:=aTemp[2]
               i:=nJump
            OTHERWISE
               Msginfo("PCODE : "+alltrim(str(aCode[i]))+CRLF+;
                  "Not yet coded","Trace Message")
            ENDCASE
         ELSE
            EXIT   //end of array
         ENDIF
      end
      i:=0
      aGlobalVar[j]:=aVar
      lDeclaration:=.t.
      aadd(aGlobalRowCode,aRowCode)
      aRowCode:={}
      cStringa:=""
   NEXT j
   if(dcp_Write_Code(aGlobalRowCode,cNewFilename))
   DECLARE WINDOW DECOMPILER
   decompiler.RichEdit_2.value:=memoread(cNewFilename) //all was ok
ELSE
   MsgInfo("Error occurs writing file "+cNewFilename+CRLF+;
      "NEED CAREFULLY DEBUGGING !" ,"Trace Message decode_c2prg")
ENDIF

RETURN aReturn

FUNCTION dcp_Write_Code(aGlobalRowCode,cFilename)

   LOCAL nLenFunc:=LEN(aGlobalRowCode),cStringa:="",lMode:=.t.
   LOCAL aRigo:={},nLineToWrite:=0,i:=0,j:=0,nHandle,nError

   FOR i=1 to nLenFunc
      aRigo:=aGlobalRowCode[i]
      nLineToWrite:=LEN(aRigo)
      FOR j=1 to nLineToWrite
         IF empty(aRigo[j])
            cStringa:=cStringa+CRLF
         ELSE
            cStringa:=cStringa+aRigo[j]+CRLF
         ENDIF
      NEXT j
   NEXT i
   IF (nHandle:=Fopen(cFilename,FO_READWRITE))>0  // ok
      fseek(nHandle,0,FS_END)
      nError:=fwrite(nHandle,cStringa)
      IF nError==0
         MsgInfo("String cannot be written in file "+cFilename + " !"+CRLF+;
            "Error # : "+alltrim(str((nError))),"Trace Message")
         lMode:=.f.
      ENDIF
   ELSE
      MsgInfo("File "+cFilename + " cannot be opened !","Trace Message")
      lMode:=.f.
   ENDIF
   IF !(FCLOSE(nHandle))
      MsgInfo("File cannot be closed !","Trace Message")
      lMode:=.f.
   ENDIF

   RETURN lMode

STATIC FUNCTION dcp_FindLastRow(aCode)

   LOCAL nLastRow:=0,nResult:=-1,nLen:=LEN(aCode),nStart:=nLen-15

   WHILE .t.
      IF nStart>1
         nResult:=ASCAN(aCode,36,nStart)
         IF nResult > 0
            nLastRow:=aCode[nResult+1]+aCode[nResult+2]*256
            EXIT
         ELSE
            nResult:=-1
            nStart:=nStart-15
         ENDIF
      ELSE
         Msginfo("No source code found","Trace Message in FindLastRow")
         EXIT
      ENDIF
   end

   RETURN nLastRow

STATIC FUNCTION dcp_CheckVarType(xVar)

   LOCAL cStringa:="",xType:=""

   IF VALTYPE(xVar)="C"
      cStringa:=xVar
      xType:="c"
   ELSEIF VALTYPE(xVar)="N"
      cStringa:=ALLTRIM(STR(xVar))
      xType:="n"
   ELSEIF VALTYPE(xVar)="L"
      IF (xVar, cStringa:=".T.",cStringa:=".F.")
         xType:="l"
      ELSEIF VALTYPE(xVar)="D"
         cStringa:=DTOC(xVar)
         xType:="d"
      ELSEIF VALTYPE(xVar)="A"
         IF (LEN(xVar)==1 .AND. empty(xVar[1]))
            cStringa:="{}"
         ELSE
            cStringa:=xVar[1]
         ENDIF
         xType:="a"
      ENDIF

      RETURN {cStringa,xType}

STATIC FUNCTION dcp_FormatVarType(xVar,lArrayEmpty)

   LOCAL cStringa:=""

   IF VALTYPE(xVar)="C"
      cStringa:=xVar
   ELSEIF VALTYPE(xVar)="N"
      cStringa:=ALLTRIM(STR(xVar))
   ELSEIF VALTYPE(xVar)="L"
      IF (xVar, cStringa:=".T.",cStringa:=".F.")
      ELSEIF VALTYPE(xVar)="D"
         cStringa:=DTOC(xVar)
      ELSEIF VALTYPE(xVar)="A"
         IF (LEN(xVar)==1 .AND. empty(xVar[1]) .AND. lArrayEmpty=.t.)
            cStringa:="{}"
         ELSE
            IF Valtype(xVar[1])="C"
               cStringa:=xVar[1]
            ELSEIF Valtype(xVar[1])="N"
               cStringa:=ALLTRIM(STR(xVar[1]))
            ELSEIF Valtype(xVar[1])="D"
               cStringa:=DTOC(xVar)
            ELSEIF Valtype(xVar[1])="L"
               IF (xVar[1], cStringa:=".T.",cStringa:=".F.")
               ELSEIF Valtype(xVar[1])="A"
                  Msginfo("Nested array - Not yet coded","Trace message FormatVarType")
               ENDIF
            ENDIF
         ENDIF

         RETURN cStringa

STATIC FUNCTION dcp_f4(aCode,nIndex,aStack)

   LOCAL aReturn:={},nElements:=aCode[nIndex+1]+aCode[nIndex+2]*256
   LOCAL i:=0,aTemp:={},cTemp:="}",cStringa:="",nStack:=0,lArrayEmpty:=.T.

   IF nElements>0
      lArrayEmpty:=.F.
      FOR i= 1 to nElements
         aTemp:=dcp_pop_stack(aStack)
         IF i==1
            cTemp:=alltrim(dcp_FormatVarType({aTemp[2]},lArrayEmpty))+cTemp
         ELSEIF i<>nElements
            cTemp:=alltrim(dcp_FormatVarType({aTemp[2]},lArrayEmpty))+","+cTemp
         ELSEIF i==nElements
            cTemp:="{"+alltrim(dcp_FormatVarType({aTemp[2]},lArrayEmpty))+","+cTemp
         ENDIF
         aStack:=aTemp[1]
      NEXT i
   ELSE
      cTemp:=""   // Empty array {}
   ENDIF
   cStringa:=cStringa+cTemp
   aStack:=dcp_push_stack(aStack,{cStringa})
   aadd(aReturn,aStack)
   aadd(aReturn,nIndex+2)

   RETURN aReturn

STATIC FUNCTION dcp_f101(aCode,nIndex,aStack)

   LOCAL aReturn:={},nNumero:=0
   nNumero:=RECOVER_DOUBLE(aCode[nIndex+1],+;
      aCode[nIndex+2],+;
      aCode[nIndex+3],+;
      aCode[nIndex+4],+;
      aCode[nIndex+5],+;
      aCode[nIndex+6],+;
      aCode[nIndex+7],+;
      aCode[nIndex+8],+;
      aCode[nIndex+9],+;
      aCode[nIndex+10])
   aStack:=dcp_push_stack(aStack,nNumero)
   aadd(aReturn,aStack)
   aadd(aReturn,nIndex+10)

   RETURN aReturn

STATIC FUNCTION dcp_f95(aCode,nIndex,aStack,aVar)

   LOCAL aReturn:={},nVar:=aCode[nIndex+1]
   LOCAL cStringa:=aVar[nVar]

   aStack:=dcp_push_stack(aStack,cStringa)
   aadd(aReturn,aStack)
   aadd(aReturn,nIndex+1)

   RETURN aReturn

STATIC FUNCTION dcp_f72(aCode,nIndex,aStack,aVar)

   LOCAL aReturn:={},xString1:="", xString2:="",aTemp:={}

   aTemp:=dcp_pop_stack(aStack)
   xString1:=aTemp[2]
   aTemp:=dcp_pop_stack(aTemp[1])
   xString2:=aTemp[2]
   aStack:={}
   aStack:=dcp_push_stack(aStack,":=")
   aStack:=dcp_push_stack(aStack,xString2)
   aStack:=dcp_push_stack(aStack,"+")
   aStack:=dcp_push_stack(aStack,xString1)
   aadd(aReturn,aStack)
   aadd(aReturn,nIndex)

   RETURN aReturn

STATIC FUNCTION dcp_f175(aCode,nIndex,aStack,aVar,aRowCode,nNextRow,aSkipCode)

   LOCAL aReturn:={},cStringa:="",nRow:=0,aTemp:={},nSkipPcode:=0
   LOCAL nVar:=aCode[nIndex+1]+aCode[nIndex+2]*256
   LOCAL nPrint:=ASCAN(aCode,36,nIndex+1)

   aTemp:=dcp_pop_stack(aSkipCode)
   aSkipCode:=aTemp[1]
   /*
   nSkipStart:=aTemp[2][1]
   nSkipEnd:=aTemp[2][2]
   */
   nSkipPcode:=aTemp[2][2]-aTemp[2][1]
   nRow:=aCode[nPrint+1]+aCode[nPrint+2]*256
   IF nRow<nNextRow
      nRow:=nNextRow
   ENDIF
   cStringa:="NEXT "+ aVar[nVar]
   aRowCode[nNextRow]:=cStringa
   aadd(aReturn,aRowCode)
   aadd(aReturn,nRow)
   aadd(aReturn,nIndex+2+nSkipPcode)

   RETURN aReturn

STATIC FUNCTION dcp_f121(aCode,nIndex,aStack)

   LOCAL aReturn:={},nNumero:=0

   aStack:=dcp_push_stack(aStack,nNumero)
   aadd(aReturn,aStack)
   aadd(aReturn,nIndex)

   RETURN aReturn

STATIC FUNCTION dcp_f122(aCode,nIndex,aStack)

   LOCAL aReturn:={},nNumero:=1

   aStack:=dcp_push_stack(aStack,nNumero)
   aadd(aReturn,aStack)
   aadd(aReturn,nIndex)

   RETURN aReturn

STATIC FUNCTION dcp_f120(aCode,nIndex,aStack)

   LOCAL aReturn:={},lMode:=.T.

   aStack:=dcp_push_stack(aStack,lMode)
   aadd(aReturn,aStack)
   aadd(aReturn,nIndex)

   RETURN aReturn

STATIC FUNCTION dcp_f9(aCode,nIndex,aStack)

   LOCAL aReturn:={},lMode:=.F.

   aStack:=dcp_push_stack(aStack,lMode)
   aadd(aReturn,aStack)
   aadd(aReturn,nIndex)

   RETURN aReturn

STATIC FUNCTION dcp_f25(aCode,nIndex,aVar,aStack,cStringa,lDeclaration)

   LOCAL aReturn:={},nJump:=0,nToNumber:=0, nVar:=0,aTemp:={}

   IF aCode[nIndex-2]==80
      nVar:=aCode[nIndex-1]   // Var Number in FOR  cycle
   ENDIF
   //****Start Code to read and store Second Operand in FOR cycle*********
   nJump:=aCode[nIndex+1]
   IF nJump > 128   // Negative number
      nJump:=(256-aCode[nIndex+1])
   ENDIF
   nToNumber:=aCode[nIndex+nJump+1]
   aStack:=dcp_push_stack(aStack,nToNumber)
   aStack:=dcp_push_stack(aStack,"TO")
   //****End Code to read and store Second Operand in FOR cycle*********
   aTemp:=dcp_f80(aCode,nIndex-2,aVar,aStack,cStringa,lDeclaration)
   aadd(aReturn,aTemp[1])  // aStack
   aadd(aReturn,aTemp[2])  // cNewString
   aadd(aReturn,nIndex+1)  // nIndex
   aadd(aReturn,aTemp[4])  // nVar

   RETURN aReturn

STATIC FUNCTION dcp_f165(aCode,nIndex,aStack,aVar,aRowCode,nNextRow,lDeclaration,aSkipCode)

   LOCAL aReturn:={},cVar:="",nJump:=0,cTemp:="",cStringa:="",nNewIndex:=0
   LOCAL nResult:=-1,nStart:=0,aTemp:={},nReadEnd:=0

   IF aCode[nIndex+1]==80 .AND. aCode[nIndex+3]==25
      nJump:=aCode[nIndex+4]  // jump to end of cycle.
      nReadEnd:=nIndex+4+nJump-1  //read next Pcode 36 to skip code control
      nResult:=ASCAN(aCode,36,nReadEnd)
      IF nResult>0
         AADD(aSkipCode,{nReadEnd,nResult})
      ENDIF
      IF aCode[nReadEnd]==95
         cVar:=aVar[aCode[nIndex+4+nJump]]
      ELSEIF aCode[nReadEnd]==92
         cVar:=alltrim(dcp_FormatVarType({aCode[nReadEnd+1]},.t.))
      ENDIF
      cTemp:=alltrim(dcp_FormatVarType({dcp_pop_stack(aStack)[2]},.t.))
      cStringa:="FOR "+aVar[aCode[nIndex+2]]+"="+cTemp+" TO "+cVar
      nStart:=nIndex-7
      nResult:=ASCAN(aCode,36,nStart)
      aTemp:=dcp_f36(aCode,nResult,aRowCode,nNextRow,cStringa,lDeclaration)
      nNextRow:=aTemp[2]+1
      aRowCode:=aTemp[3]
      cStringa:=aTemp[4]
      nStart:=nResult+1
      nResult:=-1
      nResult:=ASCAN(aCode,36,nStart) // next 36 > code to skip
      nResult:=nResult+2   //-> first code after for/next previous proc.
   ELSE
      Msginfo("dcp_f165->80,<>25 not yet improved function","Trace Message")
   ENDIF
   aStack:={}
   aadd(aReturn,aStack)
   aadd(aReturn,nResult)
   aadd(aReturn,aRowCode)
   aadd(aReturn,nNextRow)
   aadd(aReturn,aSkipCode)

   RETURN aReturn

STATIC FUNCTION dcp_f80(aCode,nIndex,aVar,aStack,cStringa,lDeclaration)

   LOCAL aReturn:={},nVar:=aCode[nIndex+1],aTemp:={},xReturn,aType:={}
   LOCAL cValue:="",xType,cNewString:=cStringa, nLastVar:=LEN(aVar)
   LOCAL aStringa:={}

   // for i =1 to nLen aStack - deve riversare tutto il contenuto dello stack
   // tener conto anche della lDeclaration - Se .t. = dichiarazione variabile
   // se .f. manipolazione variabili nel source
   IF lDeclaration
      aTemp:=dcp_pop_stack(aStack)
      aStack:=aTemp[1]
      xReturn:=aTemp[2]
      aType:=dcp_CheckVarType(xReturn)
      cValue:=aType[1]
      xType:=aType[2]
      IF Empty(cNewString)
         cNewString:=xType+aVar[nVar]+":="+cValue+","
         aVar[nVar]:=xType+aVar[nVar]
      ELSE
         cNewString:=cStringa+xType+aVar[nVar]+":="+cValue+","
         aVar[nVar]:=xType+aVar[nVar]
      ENDIF
   ELSE
      WHILE !empty(aStack)
         aTemp:=dcp_pop_stack(aStack)
         aStack:=aTemp[1]
         xReturn:=aTemp[2]
         aadd(aStringa,dcp_FormatVarType(xReturn,if(Valtype(xReturn)="A",.t.,.f.)))
      end
      cNewString:=dcp_mask_convert(aStringa,aVar,nVar,aCode,nIndex)
   ENDIF
   aadd(aReturn,aStack)
   aadd(aReturn,cNewString)
   aadd(aReturn,nIndex+1)
   aadd(aReturn,nVar)

   RETURN aReturn

STATIC FUNCTION dcp_f51(aCode,nIndex)

   LOCAL aReturn:={},cStringa:=""
   LOCAL i:=nIndex

   WHILE .t.
      i:=i+1
      cStringa:=cStringa+CHR(aCode[i])
      IF aCode[i]==0
         cStringa:=substr(cStringa,1,LEN(cStringa)-1)
         EXIT
      ENDIF
   end
   aadd(aReturn,cStringa)
   aadd(aReturn,i)

   RETURN aReturn

STATIC FUNCTION dcp_f36(aCode,nIndex,aRowCode,nNextRow,cStringa,lDeclaration)

   LOCAL aReturn:={},nJump:=nIndex+2
   LOCAL nRow:=aCode[nIndex+1]+aCode[nIndex+2]*256

   IF (!empty(cStringa) .AND. lDeclaration = .t.)
      cStringa:="Local "+cStringa
   ENDIF
   IF nNextRow==0
      IF (!empty(cStringa) .AND. alltrim(cStringa)<>"Local")
         aRowCode[nRow-1]:=substr(cStringa,1,LEN(cStringa)-1)
      ENDIF
   ELSE
      IF !empty(cStringa) .AND. lDeclaration=.T.
         aRowCode[nNextRow]:=substr(cStringa,1,LEN(cStringa)-1)
      ELSEIF !empty(cStringa) .AND. lDeclaration=.F.
         aRowCode[nNextRow]:=cStringa
      ENDIF
   ENDIF
   cStringa:=""
   aadd(aReturn,nJump)
   aadd(aReturn,nRow)
   aadd(aReturn,aRowCode)
   aadd(aReturn,cStringa)

   RETURN aReturn

STATIC FUNCTION dcp_f106(aCode,nIndex,aStack)

   LOCAL aReturn:={},cStringa:=""
   LOCAL i:=0,nLen:=aCode[nIndex+1]

   FOR i=nIndex+2 to nIndex+nLen+1
      cStringa:=cStringa+CHR(aCode[i])
   NEXT i
   cStringa:=substr(cStringa,1,LEN(cStringa)-1)
   aStack:=dcp_push_stack(aStack,cStringa)
   i:=nIndex+nLen+1
   aadd(aReturn,aStack)
   aadd(aReturn,i)

   RETURN aReturn

STATIC FUNCTION dcp_f98(aCode,nIndex,aLFuncName)

   LOCAL aReturn:={},cStringa:=""
   LOCAL nFunction:=aCode[nIndex+1]+aCode[nIndex+2]*256
   LOCAL i:=nIndex+2

   cStringa:=aLFuncName[nFunction]
   aadd(aReturn,cStringa)
   aadd(aReturn,i)

   RETURN aReturn

STATIC FUNCTION dcp_f93(aCode,nIndex,cStringa)

   LOCAL aReturn:={},nNumero:=0

   nNumero:=aCode[nIndex+1]+aCode[nIndex+2]
   cStringa:=cStringa+"["+alltrim(str(nNumero))+"]"
   aadd(aReturn,cStringa)
   aadd(aReturn,nIndex+2)

   RETURN aReturn

STATIC FUNCTION dcp_f92(aCode,nIndex,aStack)

   LOCAL aReturn:={},nNumero:=0

   nNumero:=aCode[nIndex+1]
   IF nNumero>127
      nNumero:=(256-nNumero)*(-1)  //Negative value
   ENDIF
   aStack:=dcp_push_stack(aStack,nNumero)
   aadd(aReturn,nIndex+1)
   aadd(aReturn,aStack)

   RETURN aReturn

STATIC FUNCTION dcp_f97(aCode,nIndex,aStack)

   LOCAL aReturn:={},nNumero:=0
   nNumero:=HB_MAKELONG (aCode[nIndex+1],+;
      aCode[nIndex+2],+;
      aCode[nIndex+3],+;
      aCode[nIndex+4])
   aStack:=dcp_push_stack(aStack,nNumero)
   aadd(aReturn,nIndex+4)
   aadd(aReturn,aStack)

   RETURN aReturn

STATIC FUNCTION dcp_f2()

   RETURN NIL

STATIC FUNCTION dcp_f100(aCode,nIndex,aStack)

   LOCAL aReturn:={},cReturn:="NIL"

   aStack:=dcp_push_stack(aStack,cReturn)
   aadd(aReturn,aStack)
   aadd(aReturn,nIndex)

   RETURN aReturn

STATIC FUNCTION dcp_f110(aCode,nIndex,aStack)

   LOCAL aReturn:={},cStringa:="Return ",aTemp:={}

   aTemp:=dcp_pop_stack(aStack)
   aStack:=aTemp[1]
   cStringa:=cStringa+aTemp[2]
   aadd(aReturn,aStack)
   aadd(aReturn,nIndex)
   aadd(aReturn,cStringa)

   RETURN aReturn

STATIC FUNCTION dcp_f7(aRowCode,nNextRow,cStringa,nIndex)

   LOCAL aReturn:={}

   aRowCode[nNextRow]:=cStringa
   aadd(aReturn,aRowCode)
   aadd(aReturn,nIndex)

   RETURN aReturn

STATIC FUNCTION dcp_push_stack(aStack,xvariable)

   LOCAL aNewStack:=ACLONE(aStack)

   aadd(aNewStack,xVariable)
   aStack:=ACLONE(aNewStack)

   RETURN aStack

STATIC FUNCTION dcp_pop_stack(aStack)

   LOCAL aNewStack:={},xReturn:=NIL
   LOCAL nLen:=LEN(aStack),i:=0

   IF nLen<>0       // !empty array
      xReturn:=aStack[nLen]
      IF nLen>2
         FOR i= 1 TO nLen-1
            aadd(aNewStack,aStack[i])  //
         NEXT I
      ELSEIF nLen=2
         aadd(aNewStack,aStack[1])
      ELSE
         //Msginfo("function dcp_pop_stack - aStack:={}","Trace Message")
      ENDIF
      //else
      // nLen==0  ????? empty array
   ENDIF

   RETURN {aNewStack,xReturn}

STATIC FUNCTION dcp_toppush_stack(aStack,xvariable)

   LOCAL aTemp:={},nLen:=LEN(aStack)
   LOCAL i:=0

   aadd(aTemp,xVariable)  //xVariable at TOP of stack
   FOR i=1 to nLen
      aadd(aTemp,aStack[i])
   NEXT i
   aStack:=ACLONE(aTemp)

   RETURN aStack

STATIC FUNCTION dcp_f176(aCode,nIndex,aLFuncName)

   LOCAL aReturn:={},nFunction,cStringa

   nFunction:=aCode[nIndex+1]+aCode[nIndex+2]
   cStringa:=aLFuncName[nFunction]
   aadd(aReturn,cStringa)
   aadd(aReturn,nIndex+2)

   RETURN aReturn

STATIC FUNCTION dcp_Mask_convert(aStringa,aVar,nVar,aCode,nIndex)

   LOCAL i:=0,cStringa:="",nLen:=LEN(aStringa),cStartNumber:=""
   LOCAL nPcodeFor:=aCode[nIndex-1]

   IF nPcodeFor==165
      FOR i=1 to  nLen
         DO CASE
         CASE aStringa[i]="FOR"
            cStringa:=aStringa[i]+" "+cStringa
         CASE aStringa[i]="="
            cStringa:=cStringa+aVar[nVar]+aStringa[i]
         CASE aStringa[i]="TO"
            cStringa:=cStringa+" "+aStringa[i]+" "
         OTHERWISE
            cStartNumber:=aStringa[i]
         ENDCASE
      NEXT i
      cStringa:=cStringa+cStartNumber
   ELSE
      FOR i=1 to  nLen
         cStartNumber:=aStringa[i]+cStartNumber
      NEXT i
      cStringa:=aVar[nVar]+cStartNumber
   ENDIF

   RETURN cStringa

#pragma BEGINDUMP
#define _WIN32_IE      0x0500
#define HB_OS_WIN_USED
#define _WIN32_WINNT   0x0400
#define WINVER   0x0400
#include <windows.h>
#include <hbapiitm.h>

HB_FUNC (HB_MAKELONG)
{
  (hb_retnl) HB_MKLONG( hb_parni(1), hb_parni(2), hb_parni(3), hb_parni(4) );
}

HB_FUNC (HB_MAKESHORT)
{
  (hb_retnl) HB_MKSHORT( hb_parni(1), hb_parni(2));
}

#pragma ENDDUMP
