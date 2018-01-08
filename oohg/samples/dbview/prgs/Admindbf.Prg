/*
* $Id: Admindbf.Prg $
*/
/*
* MINIGUI - Harbour Win32 GUI library
* Copyright 2002-2012 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
* Program to view DBF files using standard Browse control
* Miguel Angel Juárez A. - 2009-2012 MigSoft <mig2soft/at/yahoo.com>
* Includes the code of Grigory Filatov <gfilatov@inbox.ru>
* and Rathinagiri <srathinagiri@gmail.com>
*/

#include 'oohg.ch'
#include "dbuvar.ch"

PROCEDURE AdministraDBF( nReg )

   PUBLIC aName := {}, aCtrol := {}, nOpt := 1 , nReg1:=nReg, aTxtBx := {}

   IF !Empty( Alias() )

      nAlto := CalcHeight()

      DEFINE WINDOW Win_2                                ;
            AT 0,0                                         ;
            WIDTH 685                                      ;
            HEIGHT 570                                     ;
            TITLE PROGRAM+VERSION+' - Record View #'+Alltrim(Str(RecNo()));
            ICON "MAIN1"                                   ;
            MODAL                                          ;
            FONT 'ARIAL' SIZE 9                            ;
            NOSIZE                                         ;
            NOMAXIMIZE                                     ;
            ON INIT ( DesactivarEdicion(), Actualizar2(), iif(Nuevo,Nuevo(),) ) ;
            ON RELEASE CerrarTablas()

         AbrirTablas()

         DEFINE SPLITBOX
            MyToolBar()
         END SPLITBOX

         @ 32,8 FRAME FRAME_51 WIDTH 657 HEIGHT 460

         DEFINE WINDOW Win_1                          ;
               at 40,10                                 ;
               WIDTH 650                                ;
               HEIGHT 450                               ;
               VIRTUAL height MAX(nAlto-70,451)         ;
               INTERNAL                                 ;
               nocaption                                ;
               FONT "ms sans serif" size 9              ;
               focused

            CreaControles()

         END WINDOW

         @ 500,450 BUTTON ACEPTAR  CAPTION 'O&K'     PICTURE "guardar1" ACTION AceptarEdicion()
         @ 500,550 BUTTON CANCELAR CAPTION 'Ca&ncel' PICTURE "salir1"   ACTION CancelarEdicion()

      END WINDOW

      CENTER WINDOW Win_2
      ACTIVATE WINDOW Win_2

   ENDIF

   RETURN

FUNCTION CalcHeight()

   nAlto1 := 140

   FOR n := 1 to Fcount()
      IF ValType(&(Fieldname(n)))=='M'
         nAlto1 := nAlto1 + 58
      ENDIF
   NEXT

   nAlto1 := nAlto1 + ( FCount() * 30 )

   Return(nAlto1)

PROCEDURE CreaControles()

   LOCAL nFil:=10, nCol:=180; nLong:=400

   @ nFil,10 FRAME FRAME_1 WIDTH 620 HEIGHT MAX(nAlto - 90, 138)

   aLabel := {}  ; aCtrol := {} ; aName := {} ; aTxtBx := {}

   aDBstru  := DBstruct()

   FOR n := 1 to FCount()

      aadd( aLabel , "label_" + alltrim( str(n) ) )
      aadd( aCtrol , "Control_" + alltrim( str(n) ) )
      aadd( aName  , Fieldname(n) )
      nLongTot := aDBstru[n,3] ; nLongDec := aDBstru[n,4]
      @ nFil+(n*30),20 LABEL &(aLabel[n]) VALUE aName[n]+" ("+alltrim(str(nLongTot,6,0))+")" WIDTH nCol - 30

      IF ValType(&(aName[n]))=='L'
         @ nFil+(n*30) ,nCol CHECKBOX   &(aCtrol[n]) caption "Yes" value &(aName[n])
         Aadd( aTxtBx, .F. )
      ELSEIF ValType(&(aName[n]))=='D'
         @ nFil+(n*30) ,nCol DATEPICKER &(aCtrol[n]) value &(aName[n]) UpDown SHOWNONE
         Aadd( aTxtBx, .F. )
      ELSEIF ValType(&(aName[n]))=='N'
         cInpMsk  := iif( nLongDec > 0, REPLICATE( "9", nLongTot - nLongDec -1 ) + "." + REPLICATE( "9", nLongDec ), REPLICATE( "9", nLongTot - nLongDec ) )
         nWidthF  := Min( iif(len(str(&(aName[n])))*10<40,40,len(str(&(aName[n])))*10),nLong )
         @ nFil+(n*30) ,nCol TEXTBOX &(aCtrol[n]) WIDTH nWidthF VALUE &(aName[n]) NUMERIC INPUTMASK cInpMsk RIGHTALIGN
         Aadd( aTxtBx, .T. )
      ELSEIF ValType(&(aName[n]))=='C'
         @ nFil+(n*30) ,nCol TEXTBOX    &(aCtrol[n]) value &(aName[n]) width Min( iif(len(&(aName[n]))*10<40,40,len(&(aName[n]))*10),nLong )
         Aadd( aTxtBx, .T. )
      ELSEIF ValType(&(aName[n]))=='M'
         @ nFil+(n*30) ,nCol EDITBOX    &(aCtrol[n]) value &(aName[n]) width nLong height 81
         nFil := nFil + 58
         Aadd( aTxtBx, .F. )
      ENDIF

   NEXT

   RETURN

PROCEDURE MyToolbar()

   DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 16,16 FONT "Arial" SIZE 9 FLAT

      BUTTON PRIMERO TOOLTIP '&First' PICTURE 'first1'   ;
         ACTION ( dBGoTop() ,Actualizar2() )

      BUTTON ANTERIOR TOOLTIP '&Previous' PICTURE 'previous1'   ;
         ACTION ( dBSkip ( -1 ),Actualizar2() )

      BUTTON SIGUIENTE TOOLTIP '&Next' PICTURE 'next1'   ;
         ACTION ( dBSkip (1) , if ( Eof() , DbGoBottom() , Nil ) ,Actualizar2() )

      BUTTON ULTIMO TOOLTIP '&Last' PICTURE 'last1'   ;
         ACTION ( dBGoBottom (),Actualizar2()  )  SEPARATOR

      BUTTON BUSCAR TOOLTIP '&Find' PICTURE 'find1'   ;
         ACTION Buscando()

      BUTTON Nuevo TOOLTIP '&New' PICTURE 'new1'   ;
         ACTION ( Nuevo := .T. , Nuevo() )

      BUTTON EDITAR TOOLTIP '&Edit' PICTURE 'format1'   ;
         ACTION iif( LastRec()>0,  If ( BloquearRegistro() , ActivarEdicion() , Nil ) , )

      BUTTON ELIMINAR TOOLTIP 'E&rase' PICTURE 'erase1'   ;
         ACTION Eliminar()

      BUTTON IMPRIMIR TOOLTIP '&Print'PICTURE 'print1' ;
         ACTION Imprimir()

      BUTTON CERRAR TOOLTIP '&Close' PICTURE 'down1' ;
         ACTION Win_2.release

   END TOOLBAR

   RETURN

PROCEDURE Buscando()

   IF !Empty( Alias() )

      nAlto := CalcHeight()

      DEFINE WINDOW Win_Busca2                           ;
            AT 0,0                                         ;
            WIDTH 685                                      ;
            HEIGHT 550                                     ;
            TITLE PROGRAM+VERSION+' - Record Find'         ;
            ICON "MAIN1"                                   ;
            MODAL                                          ;
            NOSIZE                                         ;
            NOMAXIMIZE                                     ;
            FONT 'ARIAL' SIZE 9

         DEFINE WINDOW Win_Busca1                    ;
               WIDTH 650                                ;
               HEIGHT 450                               ;
               VIRTUAL height MAX(nAlto-70,451)         ;
               INTERNAL                                 ;
               nocaption                                ;
               FONT "ms sans serif" size 9              ;
               focused

            CreaControles()
            Nuevo2()

         END WINDOW

         @ 470,420 BUTTON ACEPTAR  CAPTION 'O&K'     PICTURE "guardar1" ACTION AceptaBuscar()
         @ 470,530 BUTTON CANCELAR CAPTION 'Ca&ncel' PICTURE "salir1"   ACTION CancelaBuscar()

      END WINDOW

      CENTER WINDOW Win_Busca2
      ACTIVATE WINDOW Win_Busca2

   ENDIF

   RETURN

PROCEDURE AbrirTablas

   Go nReg1

   RETURN

PROCEDURE CerrarTablas

   RETURN

PROCEDURE DesactivarEdicion

   FOR n := 1 to FCount()
      IF aTxtBx[n] == .T.
         Win_1.&(aCtrol[n]).ReadOnly := .T.
      ELSE
         Win_1.&(aCtrol[n]).Enabled := .F.
      ENDIF
   NEXT

   Win_2.Aceptar.Enabled      := .F.
   Win_2.Cancelar.Enabled      := .F.
   Win_2.ToolBar_1.Enabled      := .T.

   RETURN

PROCEDURE ActivarEdicion

   FOR n := 1 to FCount()
      IF aTxtBx[n] == .T.
         Win_1.&(aCtrol[n]).ReadOnly := .F.
      ELSE
         Win_1.&(aCtrol[n]).Enabled := .T.
      ENDIF
   NEXT

   Win_2.Aceptar.Enabled      := .T.
   Win_2.Cancelar.Enabled      := .T.
   Win_2.ToolBar_1.Enabled      := .F.

   Win_1.&(aCtrol[1]).SetFocus

   RETURN

PROCEDURE CancelarEdicion()

   DesactivarEdicion()
   Actualizar2()

   ( Alias() )->( dbUnlock() )

   Nuevo := .F.

   RETURN

PROCEDURE AceptarEdicion()

   DesactivarEdicion()

   IF Nuevo == .T.
      (Alias())->(DbAppend())
      Nuevo := .F.
   ENDIF

   FOR n := 1 to FCount()
      (Alias())->&(aName[n]) := Win_1.&(aCtrol[n]).Value
   NEXT

   UNLOCK

   RETURN

PROCEDURE CancelaBuscar()

   Win_Busca2.Release

   RETURN

PROCEDURE AceptaBuscar()

   FOR n := 1 to FCount()
      IF !Empty( Win_Busca1.&(aCtrol[n]).Value ) .and. IsControlDefined ( &(aCtrol[n]), Win_Busca1 )
         cNomb := FieldName(n)
         IF ValType( &(cNomb) )=="C" .OR. ValType( &(cNomb) )=="M"
            Busca := Upper(Win_Busca1.&(aCtrol[n]).Value)
            LOCATE for Upper( &( cNomb ) ) = ( Busca )
         ELSE
            Busca := Win_Busca1.&(aCtrol[n]).Value
            LOCATE for &( cNomb ) = ( Busca )
         ENDIF
         IF Found()
            nRegBus := (Alias())->(Recno())
            Go nRegBus
            Actualizar2()
         ELSE
            MsgExclamation( 'No records for your query!', PROGRAM )
         ENDIF
      ENDIF
   NEXT
   Win_Busca2.Release

   RETURN

PROCEDURE Nuevo()

   FOR n := 1 to FCount()
      aadd( aCtrol , "Control_" + alltrim( str(n) ) )
      aadd( aName  , Fieldname(n) )

      IF ValType(&(aName[n]))=='L'
         Win_1.&(aCtrol[n]).value := .F.
      ELSEIF ValType(&(aName[n]))=='D'
         Win_1.&(aCtrol[n]).value := ctod("  /  /  ")
      ELSEIF ValType(&(aName[n]))=='N'
         Win_1.&(aCtrol[n]).value := 0
      ELSEIF ValType(&(aName[n]))=='C'
         Win_1.&(aCtrol[n]).value := ''
      ELSEIF ValType(&(aName[n]))=='M'
         Win_1.&(aCtrol[n]).value := ''
      ENDIF
   NEXT

   ActivarEdicion()

   RETURN

PROCEDURE Nuevo2()

   FOR n := 1 to FCount()
      aadd( aCtrol , "Control_" + alltrim( str(n) ) )
      aadd( aName  , Fieldname(n) )

      IF ValType(&(aName[n]))=='L'
         Win_Busca1.&(aCtrol[n]).value := .F.
      ELSEIF ValType(&(aName[n]))=='D'
         Win_Busca1.&(aCtrol[n]).value := ctod("  /  /  ")
      ELSEIF ValType(&(aName[n]))=='N'
         Win_Busca1.&(aCtrol[n]).value := 0
      ELSEIF ValType(&(aName[n]))=='C'
         Win_Busca1.&(aCtrol[n]).value := ''
      ELSEIF ValType(&(aName[n]))=='M'
         Win_Busca1.&(aCtrol[n]).value := ''
      ENDIF
   NEXT

   RETURN

PROCEDURE Actualizar2()

   Win_2.TITLE := PROGRAM+VERSION+' - Record View #'+Alltrim(Str(RecNo()))

   FOR n := 1 to FCount()
      Win_1.&(aCtrol[n]).Value := (Alias())->&(aName[n])
   NEXT

   RETURN

FUNCTION BloquearRegistro()

   LOCAL RetVal

   IF (Alias())->(RLock())
      RetVal := .t.
   ELSE
      MsgExclamation ('This record is edited by another user. Retry Later')
      RetVal := .f.
   ENDIF

   RETURN RetVal

PROCEDURE Eliminar

   IF MsgYesNo ( 'Are you sure?',PROGRAM)
      IF BloquearRegistro()
         (Alias())->(dbdelete())
         (Alias())->(dbgotop())
         Actualizar2()
      ENDIF
   ENDIF

   RETURN

PROCEDURE Imprimir()

   PrintList()

   /*
   Local aHdr := aClone(aNomb)
   Local aLen := aClone(aLong)
   Local aHdr1, aTot, aFmt

   If !Empty( cbase )

   aeval(aLen, {|e,i| aLen[i] := e/9})
   adel(aLen, 1)
   asize(aLen, len(aLen)-1)
   adel(aHdr, 1)
   asize(aHdr, len(aHdr)-1)
   adel(aHdr, len(aHdr))
   asize(aHdr, len(aHdr)-1)
   asize(aLen, len(aLen)-1)
   aHdr1 := array(len(aHdr))
   aTot  := array(len(aHdr))
   aFmt  := array(len(aHdr))
   afill(aHdr1, '')
   afill(aTot, .f.)
   afill(aFmt, '')

   set deleted on

   ( cBase )->( dbgotop() )

   DO REPORT ;
   TITLE    cBase + ' Database List' ;
   HEADERS  aHdr1, aHdr              ;
   FIELDS   aHdr                     ;
   WIDTHS   aLen                     ;
   TOTALS   aTot                     ;
   NFORMATS aFmt                     ;
   WORKAREA &cBase                   ;
   LPP 60                            ;
   CPL 120                           ;
   LMARGIN  5                        ;
   PAPERSIZE DMPAPER_LETTER          ;
   PREVIEW

   set deleted off

   Endif
   */

   RETURN
