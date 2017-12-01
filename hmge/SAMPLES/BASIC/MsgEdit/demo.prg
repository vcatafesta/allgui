/*
* MiniGUI MsgEdit, MsgDate, MsgCopy, MsgMove, MsgDelete, MsgPostIt,
* MsgDesktop, MsgOptions, MsgLogo, MsgToolTip Demo
* (c) 2007-2011 Grigory Filatov
* Functions MsgEdit(), MsgDate(), MsgCopy(), MsgMove(), MsgDelete(),
* MsgPostIt(), MsgDesktop(), MsgOptions(), MsgLogo(), MsgToolTip() for Xailer
* Author: Bingen Ugaldebere
* Final revision: 07/11/2006
*/

#include "minigui.ch"
#include "shell32.ch"

//#define _INPUTMASK_

#define BM_WIDTH     1
#define BM_HEIGHT    2

PROCEDURE Main

   SET DATE FORMAT "dd-MM-yyyy" // the month mask in uppercase is important for DATEPICKER's format

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 640 ;
         HEIGHT 480 ;
         TITLE 'MsgEdit Demo' ;
         ICON "demo.ico" ;
         MAIN ;
         NOMAXIMIZE NOSIZE

      @ 30, 90 FRAME Frame_1 ;
         CAPTION '' ;
         WIDTH  220 ;
         HEIGHT 265

      @ 50 ,100 BUTTON Button_1 ;
         CAPTION "Edit for Text" ;
         ACTION Click_1() ;
         WIDTH 200 ;
         HEIGHT 30

      @ 100 ,100 BUTTON Button_2 ;
         CAPTION "Edit for Password" ;
         ACTION Click_2() ;
         WIDTH 200 ;
         HEIGHT 30

      @ 150 ,100 BUTTON Button_3 ;
         CAPTION "Edit for Date" ;
         ACTION Click_3() ;
         WIDTH 200 ;
         HEIGHT 30

      @ 200 ,100 BUTTON Button_4 ;
         CAPTION "Edit for Numeric" ;
         ACTION Click_4() ;
         WIDTH 200 ;
         HEIGHT 30

      @ 250 ,100 BUTTON Button_5 ;
         CAPTION "Edit for Logical" ;
         ACTION Click_5() ;
         WIDTH 200 ;
         HEIGHT 30

      @ 30, 390 FRAME Frame_2 ;
         CAPTION '' ;
         WIDTH  120 ;
         HEIGHT 365

      @ 50 ,400 BUTTON Button_6 ;
         CAPTION "MsgDate" ;
         ACTION Click_6() ;
         WIDTH 100 ;
         HEIGHT 30

      @ 100 ,400 BUTTON Button_7 ;
         CAPTION "MsgCopy" ;
         ACTION Click_7() ;
         WIDTH 100 ;
         HEIGHT 30

      @ 150 ,400 BUTTON Button_8 ;
         CAPTION "MsgMove" ;
         ACTION Click_8() ;
         WIDTH 100 ;
         HEIGHT 30

      @ 200 ,400 BUTTON Button_9 ;
         CAPTION "MsgDelete" ;
         ACTION Click_9() ;
         WIDTH 100 ;
         HEIGHT 30

      @ 250 ,400 BUTTON Button_10 ;
         CAPTION "MsgPostIt" ;
         ACTION Click_10() ;
         WIDTH 100 ;
         HEIGHT 30

      @ 300 ,400 BUTTON Button_11 ;
         CAPTION "MsgDesktop" ;
         ACTION Click_11() ;
         WIDTH 100 ;
         HEIGHT 30

      @ 350 ,400 BUTTON Button_12 ;
         CAPTION "MsgOptions" ;
         ACTION Click_12() ;
         WIDTH 100 ;
         HEIGHT 30

      @ 330, 90 FRAME Frame_3 ;
         CAPTION '' ;
         WIDTH  220 ;
         HEIGHT 65

      @ 350 ,100 BUTTON Button_13 ;
         CAPTION "MsgLogo" ;
         ACTION Click_13() ;
         WIDTH 95 ;
         HEIGHT 30

      @ 350 ,205 BUTTON Button_14 ;
         CAPTION "MsgToolTip" ;
         ACTION Click_14() ;
         WIDTH 95 ;
         HEIGHT 30
   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN

#define MsgInfo( c ) MsgInfo( c, , , .f. )

PROCEDURE Click_1

   LOCAL cNombre:="Bingen Ugaldebere                       "

   IF MsgEdit("Teclee su nombre o confirme el actual", "Ejemplo de MsgEdit", @cNombre, "Users.Bmp")
      MsgInfo("El nombre tecleado es "+Trim(cNombre))
   ELSE
      MsgInfo("Ha salido cancelando la ventana")
   ENDIF

   RETURN

PROCEDURE Click_2

   LOCAL cPassword:=Space(5)

   IF MsgEdit("Teclee la contraseña", , @cPassword, "Gear.Bmp",.T.,.T.)
      MsgInfo("La contraseña tecleada es "+cPassword)
   ELSE
      MsgInfo("Ha salido cancelando la ventana")
   ENDIF

   RETURN

PROCEDURE Click_3

   LOCAL dFecha:=Date(), uFecha:={Date(),Date()-1,Date()+1}

   IF MsgEdit("Teclee la fecha deseada", , @dFecha, "Gear.Bmp")
      MsgInfo("La Fecha es "+ToString(dFecha))
   ELSE
      MsgInfo("Ha salido cancelando la ventana")
   ENDIF

   // Date with limites
   IF MsgEdit("Teclee la fecha deseada entre ayer y mañana, ambos inclusive", , @uFecha, "Gear.Bmp")
      MsgInfo("La Fecha es "+ToString(uFecha))
   ELSE
      MsgInfo("Ha salido cancelando la ventana")
   ENDIF

   RETURN

PROCEDURE Click_4

   LOCAL nValor:=123.45, uValor:={0,1,1000}

#ifdef _INPUTMASK_
   LOCAL cPict1:="9,999.99", cPict2:="9,999"

#else
   LOCAL cPict1:="@E 9,999.99", cPict2:="@E 9,999"

#endif

   IF MsgEdit("Teclee el importe deseado", , @nValor, "Gear.Bmp",,,cPict1)
      MsgInfo("El importe es "+ToString(nValor))
   ELSE
      MsgInfo("Ha salido cancelando la ventana")
   ENDIF

   // Value with limites
   IF MsgEdit("Teclee el importe deseado de 1 a 1000", , @uValor, "Gear.Bmp",,,cPict2)
      MsgInfo("El valor tecleado es "+ToString(uValor))
   ELSE
      MsgInfo("Ha salido cancelando la ventana")
   ENDIF

   RETURN

PROCEDURE Click_5

   LOCAL lLogico:=.F.

   IF MsgEdit("Esta seguro de esto", , @lLogico, "Gear.Bmp")
      MsgInfo("Pues va a ser que "+If(lLogico,"Si","No"))
   ELSE
      MsgInfo("Ha salido cancelando la ventana")
   ENDIF

   RETURN

PROCEDURE Click_6

   LOCAL dIni:=Date(), dFin:=Date()+30

   IF MsgDate(,"Establezca fechas de consulta",@dIni,@dFin,,,"Gear.Bmp")
      MsgInfo("El intervalo es de "+Alltrim(Str(dFin-dIni))+" días")
   ELSE
      MsgInfo("Ha salido cancelando la ventana")
   ENDIF

   RETURN

PROCEDURE Click_7

   IF MsgCopy("*.*", GetStartupFolder()+"\Copia")
      MsgInfo("Se han copia los archivos de la carpeta a la carpeta \Copia creada dentro de la carpeta del programa")
   ELSE
      MsgInfo("Error. No se ha podido llevar a cabo la operación de copiado")
   ENDIF

   RETURN

PROCEDURE Click_8

   IF MsgMove("Prueba.Doc", GetStartupFolder()+"\Documentación\Prueba.Doc")
      MsgInfo("Se ha movido el documento Prueba.Doc a la carpeta \Documentación que ha sido creada")
   ELSE
      MsgInfo("Error. No se ha podido llevar a cabo la operación de mover archivos")
   ENDIF

   RETURN

PROCEDURE Click_9

   IF MsgDelete(GetStartupFolder()+"\Documentación\*.*",,,.F.)
      MsgInfo("Se ha borrado el contenido de la carpeta \Documentación")
   ELSE
      MsgInfo("Error. No se ha podido llevar a cabo la operación de borrado")
   ENDIF

   RETURN

PROCEDURE Click_10

   MsgPostIt(space(590)+"Cita con el cliente."+CRLF+CRLF+;
      "Llevar un prototipo válido del programa, si es posible, para "+;
      "que parezca que esta muy elaborado y de esta manera el cliente "+;
      "no se mosquee por el tiempo que llevamos sin ir a verle.",,,.F.)

   MsgPostIt(space(330)+"Cita con el cliente."+CRLF+CRLF+;
      "Este mensaje lleva una imagen que es opcional a la izquierda y por lo "+;
      "tanto el texto sale algo desplazado a la derecha."+CRLF+CRLF+;
      "Además incluye parpadeo para llamar más la atención del usuario",,"Users.Bmp",,{128, 255, 216} )

   RETURN

PROCEDURE Click_11

   MsgDesktop(space(250)+"Mensaje sobre el escritorio."+CRLF+CRLF+;
      "Este mensaje se muestra fuera del form de la aplicación sobre el escritorio "+;
      "así que permanece incluso si el form de la aplicación ha sido cerrada "+;
      "ya que en realidad pertenece al escritorio."+CRLF+CRLF+;
      "En realidad es un form al mismo nivel que el form principal de la aplicación "+;
      "de forma que la aplicación global no se cierra hasta que se cierren "+;
      "todos los formularios.",,"Users.Bmp")

   RETURN

PROCEDURE Click_12

   LOCAL nOption:=0

   nOption:=MsgOptions(, , "Users.Bmp" , {"&Imprimir","&Mandar a la porra","&Enviar por email","&Destruir"}, 2, 20 )

   MsgInfo("Ha seleccionado la opción "+Alltrim(Str(nOption)) )

   RETURN

PROCEDURE Click_13

   MsgLogo("..\SPLASHDEMO\Demo.Bmp")
   MsgLogo("Splash.jpg", 6, .T.)

   RETURN

#define COLOR_INFOBK     24

PROCEDURE Click_14

   LOCAL ControlName:=This.Name, ParentName:=ThisWindow.Name
   LOCAL nIdx:=GetControlIndex( ControlName, ParentName )
   LOCAL nColor:=GetSysColor( COLOR_INFOBK )
   LOCAL aColor:={GetRed( nColor ), GetGreen( nColor ), GetBlue( nColor )}

   MsgToolTip(nIdx, "Prueba de tooltip"+CRLF+"Multilinea", "Titulo", aColor)

   RETURN

STATIC FUNCTION ToString( xValue )

   LOCAL cType := ValType( xValue )
   LOCAL cValue := "", nDecimals := Set( _SET_DECIMALS)

   DO CASE
   CASE cType $  "CM";  cValue := xValue
   CASE cType == "N" ;  nDecimals := iif( xValue == int(xValue), 0, nDecimals) ; cValue := LTrim( Str( xValue, 20, nDecimals ) )
   CASE cType == "D" ;  cValue := DToC( xValue )
   CASE cType == "L" ;  cValue := IIf( xValue, "T", "F" )
   CASE cType == "A" ;  cValue := AToC( xValue )
   CASE cType $  "UE";  cValue := "NIL"
   CASE cType == "B" ;  cValue := "{|| ... }"
   CASE cType == "O" ;  cValue := "{" + xValue:className + "}"
   ENDCASE

   RETURN cValue

   /*
   * MsgEdit([cText], [cTitle], uVar, [cImage], [lPassWord], [lNoCancel], [cPicture])
   */

FUNCTION MsgEdit(cText, cTitle, uVar, cImage, lPassWord, lNoCancel, cPicture)

   LOCAL uLimitInf, uLimitSup, aImgInfo, cDateFormat := Set(_SET_DATEFORMAT)

   DEFAULT cText     To "Introduzca un valor"
   DEFAULT cTitle    To _HMG_MESSAGE [5]
   DEFAULT cImage    To ""
   DEFAULT lPassWord To .F.
   DEFAULT lNoCancel To .F.
#ifdef _INPUTMASK_
   DEFAULT cPicture  To "999,999.99"
#else
   DEFAULT cPicture  To "@E 999,999.99"
#endif

   IF Valtype(uVar)="A"
      Asize(uVar,3)
      uLimitInf:=uVar[2]
      uLimitSup:=uVar[3]
      uVar:=uVar[1]
   ENDIF

   DEFINE WINDOW _EditForm ;
         AT 0,0               ;
         WIDTH 320            ;
         HEIGHT 150           ;
         TITLE cTitle         ;
         ICON "demo.ico"      ;
         MODAL                ;
         NOSIZE               ;
         FONT 'MS Sans Serif' ;
         SIZE 9

      ON KEY ESCAPE ACTION ( _HMG_DialogCancelled := .T. , _EditForm.Release )

      IF lPassWord
         @ 10, 10 LABEL _Label VALUE cText WIDTH 295 TRANSPARENT
         @ 40, 10 TEXTBOX _TextBox VALUE '' WIDTH 295 HEIGHT 25 PASSWORD ;
            ON ENTER _EditForm._Ok.OnClick
      ELSE
         DO CASE
         CASE ValType(uVar)=="C"
            @ 10, 10 LABEL _Label VALUE cText WIDTH 295 TRANSPARENT
            @ 40, 10 TEXTBOX _TextBox VALUE uVar WIDTH 295 HEIGHT 25 MAXLENGTH Len(uVar) ;
               ON ENTER _EditForm._Ok.OnClick

         CASE ValType(uVar)=="N"
            @ 10, 10 LABEL _Label VALUE cText WIDTH 295 TRANSPARENT
#ifdef _INPUTMASK_
            @ 40,105 TEXTBOX _TextBox VALUE uVar WIDTH 120 HEIGHT 25 NUMERIC INPUTMASK cPicture ;
               ON ENTER _EditForm._Ok.OnClick
#else
            @ 40,105 GETBOX _TextBox VALUE uVar WIDTH 120 HEIGHT 25 PICTURE cPicture
            ON KEY RETURN ACTION _EditForm._Ok.OnClick
#endif
         CASE ValType(uVar)=="D"
            IF Len(cText) < 40
               cText := CRLF+cText
            ENDIF
            @ 17, 30 LABEL _Label VALUE cText WIDTH 140 HEIGHT 45 TRANSPARENT
            @ 25,170 DATEPICKER _TextBox VALUE uVar WIDTH 95 HEIGHT 25 DATEFORMAT cDateFormat ;
               ON ENTER _EditForm._Ok.OnClick

         CASE ValType(uVar)=="L"
            @ 35, 15 CHECKBOX _TextBox CAPTION " "+cText VALUE uVar WIDTH 260 HEIGHT 25 TRANSPARENT
            ON KEY RETURN ACTION _EditForm._Ok.OnClick

         OTHERWISE
            MsgInfo("No se puede editar un valor de tipo "+Valtype(uVar))
         ENDCASE
      ENDIF

      IF !Empty(cImage)
         aImgInfo := BmpSize(cImage)
         IF !Empty(aImgInfo [BM_WIDTH])
            @ 70, 10 IMAGE _Image PICTURE (cImage) WIDTH aImgInfo [BM_WIDTH] HEIGHT aImgInfo [BM_HEIGHT]
         ENDIF
      ENDIF

      IF lNoCancel
         @ 80,120 BUTTON _Ok CAPTION "&"+_HMG_MESSAGE [6] WIDTH 80 HEIGHT 25 DEFAULT ;
            ACTION If(ValType(uVar)<>"L", ;
            ( If(MsgEditValid(_EditForm._TextBox.Value, uLimitInf, uLimitSup),;
            (_HMG_DialogCancelled := .F. , uVar := _EditForm._TextBox.Value , _EditForm.Release),;
            _EditForm._TextBox.SetFocus) ),;
            (_HMG_DialogCancelled := .F. , uVar := _EditForm._TextBox.Value , _EditForm.Release))
      ELSE
         @ 80, 60 BUTTON _Ok CAPTION "&"+_HMG_MESSAGE [6] WIDTH 80 HEIGHT 25 DEFAULT ;
            ACTION If(ValType(uVar)<>"L", ;
            ( If(MsgEditValid(_EditForm._TextBox.Value, uLimitInf, uLimitSup),;
            (_HMG_DialogCancelled := .F. , _EditForm._Ok.SetFocus, uVar := _EditForm._TextBox.Value , _EditForm.Release),;
            _EditForm._TextBox.SetFocus) ),;
            (_HMG_DialogCancelled := .F. , uVar := _EditForm._TextBox.Value , _EditForm.Release))

         @ 80,180 BUTTON _Cancel CAPTION "&"+_HMG_MESSAGE [7] WIDTH 80 HEIGHT 25 ;
            ACTION ( _HMG_DialogCancelled := .T. , _EditForm.Release )
      ENDIF

   END WINDOW

   CENTER WINDOW _EditForm

   ACTIVATE WINDOW _EditForm

   RETURN !(_HMG_DialogCancelled)

STATIC FUNCTION MsgEditValid(uValue, uLimitInf, uLimitSup)

   IF uLimitInf==Nil .And. uLimitSup==Nil

      RETURN .T.
   ENDIF

   IF uLimitInf<>Nil .And. uValue<uLimitInf
      MsgInfo("El límite inferior es "+ToString( uLimitInf ),"Valor incorrecto")

      RETURN .F.
   ENDIF

   IF uLimitSup<>Nil .And. uValue>uLimitSup
      MsgInfo("El límite superior es "+ToString( uLimitSup ),"Valor incorrecto")

      RETURN .F.
   ENDIF

   RETURN .T.

   /*
   * MsgDate([cText], [cTitle], @uVarIni, @uVarFin, [cTextIni], [cTextFin], [cImage], [lNoCancel])
   */

FUNCTION MsgDate(cText, cTitle, uVarIni, uVarFin, cTextIni, cTextFin, cImage, lNoCancel)

   LOCAL cDateFormat := Set(_SET_DATEFORMAT), aImgInfo

   /*
   Default cText     To "Limites of dates"
   Default cTitle    To "Introduce dates"
   Default cTextIni  To "FROM ........................"
   Default cTextFin  To "T0 .........................."
   */
   DEFAULT cText     To "Límites de fechas"
   DEFAULT cTitle    To "Introduzca fechas"
   DEFAULT cTextIni  To "DESDE ......................."
   DEFAULT cTextFin  To "HASTA ......................."
   DEFAULT lNoCancel To .F.

   DEFINE WINDOW _DateForm ;
         AT 0,0               ;
         WIDTH 320            ;
         HEIGHT 175           ;
         TITLE cTitle         ;
         ICON "demo.ico"      ;
         MODAL                ;
         NOSIZE               ;
         FONT 'MS Sans Serif' ;
         SIZE 9

      ON KEY ESCAPE ACTION ( _HMG_DialogCancelled := .T. , _DateForm.Release )

      @ 10, 10 LABEL _Label VALUE cText WIDTH 295 HEIGHT 35 TRANSPARENT

      @ 43, 10 LABEL _LabelIni VALUE cTextIni WIDTH 155 HEIGHT 25 TRANSPARENT
      @ 73, 10 LABEL _LabelFin VALUE cTextFin WIDTH 155 HEIGHT 25 TRANSPARENT

      @ 40,170 DATEPICKER _TextBox_1 VALUE uVarIni WIDTH 90 HEIGHT 25 DATEFORMAT cDateFormat ;
         ON ENTER _DateForm._Ok.OnClick

      @ 70,170 DATEPICKER _TextBox_2 VALUE uVarFin WIDTH 90 HEIGHT 25 DATEFORMAT cDateFormat ;
         ON ENTER _DateForm._Ok.OnClick

      IF !Empty(cImage)
         aImgInfo := BmpSize(cImage)
         IF !Empty(aImgInfo [BM_WIDTH])
            @ 100, 10 IMAGE _Image PICTURE (cImage) WIDTH aImgInfo [BM_WIDTH] HEIGHT aImgInfo [BM_HEIGHT]
         ENDIF
      ENDIF

      IF lNoCancel
         @ 110,120 BUTTON _Ok CAPTION "&"+_HMG_MESSAGE [6] WIDTH 80 HEIGHT 25 DEFAULT ;
            ACTION ( _HMG_DialogCancelled := .F. , ;
            uVarIni := Min( _DateForm._TextBox_1.Value , _DateForm._TextBox_2.Value ) , ;
            uVarFin := Max( _DateForm._TextBox_1.Value , _DateForm._TextBox_2.Value ) , _DateForm.Release )
      ELSE
         @ 110, 60 BUTTON _Ok CAPTION "&"+_HMG_MESSAGE [6] WIDTH 80 HEIGHT 25 DEFAULT ;
            ACTION ( _HMG_DialogCancelled := .F. , ;
            uVarIni := Min( _DateForm._TextBox_1.Value , _DateForm._TextBox_2.Value ) , ;
            uVarFin := Max( _DateForm._TextBox_1.Value , _DateForm._TextBox_2.Value ) , _DateForm.Release )

         @ 110,180 BUTTON _Cancel CAPTION "&"+_HMG_MESSAGE [7] WIDTH 80 HEIGHT 25 ;
            ACTION ( _HMG_DialogCancelled := .T. , _DateForm.Release )
      ENDIF

   END WINDOW

   CENTER WINDOW _DateForm

   ACTIVATE WINDOW _DateForm

   RETURN !(_HMG_DialogCancelled)

   /*
   * MsgCopy([acOrigName], [acDestName], [cTitle], [lFilesOnly], [lDeleteIfExist], [lAlarm])
   */

FUNCTION MsgCopy(acOrigName, acDestName, cTitle, lFilesOnly, lOkToAll, lAlarm )

   LOCAL aFrom:={}, aTo:={}, lResult:=.F., nFlag:=0

   DEFAULT cTitle          To ""
   DEFAULT acOrigName      To ""
   DEFAULT acDestName      To ""
   DEFAULT lFilesOnly      To .T.
   DEFAULT lOkToAll        To .T.
   DEFAULT lAlarm          To .F.

   //Cargar los Array
   IF ValType(acOrigName)="C"
      Aadd(aFrom,acOrigName)
   ELSEIF ValType(acOrigName)="A"
      aFrom:=acOrigName
   ENDIF
   IF ValType(acDestName)="C"
      Aadd(aTo,acDestName)
   ELSEIF ValType(acDestName)="A"
      aTo:=acDestName
   ENDIF

   IF lFilesOnly
      nFlag+=FOF_FILESONLY
   ENDIF
   IF lOkToAll
      nFlag+=FOF_NOCONFIRMATION
      nFlag+=FOF_NOCONFIRMMKDIR
   ENDIF
   IF lAlarm
      nFlag+=FOF_NOERRORUI
   ENDIF

   lResult:=( ShellFiles( , aFrom, aTo, FO_COPY, nFlag ) == 0 )

   RETURN lResult

   /*
   * MsgMove([acOrigName], [acDestName], [cTitle], [lFilesOnly], [lDeleteIfExist], [lAlarm])
   */

FUNCTION MsgMove(acOrigName, acDestName, cTitle, lFilesOnly, lOkToAll, lAlarm )

   LOCAL aFrom:={}, aTo:={}, lResult:=.F., nFlag:=0

   DEFAULT cTitle          To ""
   DEFAULT acOrigName      To ""
   DEFAULT acDestName      To ""
   DEFAULT lFilesOnly      To .T.
   DEFAULT lOkToAll        To .T.
   DEFAULT lAlarm          To .F.

   //Cargar los Array
   IF ValType(acOrigName)="C"
      Aadd(aFrom,acOrigName)
   ELSEIF ValType(acOrigName)="A"
      aFrom:=acOrigName
   ENDIF
   IF ValType(acDestName)="C"
      Aadd(aTo,acDestName)
   ELSEIF ValType(acDestName)="A"
      aTo:=acDestName
   ENDIF

   IF lFilesOnly
      nFlag+=FOF_FILESONLY
   ENDIF
   IF lOkToAll
      nFlag+=FOF_NOCONFIRMATION
      nFlag+=FOF_NOCONFIRMMKDIR
   ENDIF
   IF lAlarm
      nFlag+=FOF_NOERRORUI
   ENDIF

   lResult:=( ShellFiles( , aFrom, aTo, FO_MOVE, nFlag ) == 0 )

   RETURN lResult

   /*
   * MsgDelete([acOrigName], [cTitle], [lFilesOnly], [lDeleteIfExist], [lAlarm])
   */

FUNCTION MsgDelete(acOrigName, cTitle, lFilesOnly, lOkToAll, lAlarm )

   LOCAL aFrom:={}, lResult:=.F., nFlag:=0

   DEFAULT cTitle          To ""
   DEFAULT acOrigName      To ""
   DEFAULT lFilesOnly      To .T.
   DEFAULT lOkToAll        To .T.
   DEFAULT lAlarm          To .F.

   //Cargar los Array
   IF ValType(acOrigName)="C"
      Aadd(aFrom,acOrigName)
   ELSEIF ValType(acOrigName)="A"
      aFrom:=acOrigName
   ENDIF

   IF lFilesOnly
      nFlag+=FOF_FILESONLY
   ENDIF
   IF lOkToAll
      nFlag+=FOF_NOCONFIRMATION
   ENDIF
   IF lAlarm
      nFlag+=FOF_NOERRORUI
   ENDIF

   lResult:=( ShellFiles( , aFrom, , , nFlag ) == 0 )

   RETURN lResult

   /*
   * MsgOptions([cText], [cTitle], [cImage], aOptions, [nDefaultOption], [nSeconds])
   */

FUNCTION MsgOptions(cText, cTitle, cImage, aOptions, nDefaultOption, nSeconds )

   LOCAL nItem:=0, nBtnWidth:=0, aBtn:=Array(Len(aOptions)), aImgInfo
   LOCAL nBtnPosX:=10, nBtnPosY:=85, cOption:=""

   DEFAULT cText           To "Seleccione una opción..."
   DEFAULT cTitle          To UPPER(_HMG_BRWLangError [10])+"!"
   DEFAULT cImage          To ""
   DEFAULT nDefaultOption  To 1
   DEFAULT nSeconds        To 0

   DEFINE FONT _Font_Options FONTNAME "MS Sans Serif" SIZE 9

   //Calcular anchura máxima de un botón para igualarlos todos
   FOR nItem:=1 To Len(aOptions)
      aOptions[nItem]:=Alltrim(aOptions[nItem])
      nBtnWidth:=Max( GetTextWidth(, aOptions[nItem], GetFontHandle("_Font_Options")), nBtnWidth )
   NEXT
   nBtnWidth+=5

   DEFINE WINDOW _Options  ;
         AT 0,0               ;
         WIDTH (Len(aOptions)*(10+nBtnWidth))+15 ;
         HEIGHT 155           ;
         TITLE cTitle         ;
         ICON "demo.ico"      ;
         MODAL                ;
         NOSIZE               ;
         ON RELEASE IF( IsControlDefined( Timer_1, _Options ), _Options.Timer_1.Release, )

      ON KEY ESCAPE ACTION _Options.Release

      IF !Empty(cImage)
         aImgInfo := BmpSize(cImage)
         IF !Empty(aImgInfo [BM_WIDTH])
            @ 20, 10 IMAGE _Image PICTURE (cImage) WIDTH aImgInfo [BM_WIDTH] HEIGHT aImgInfo [BM_HEIGHT]
            @ 40, 55 LABEL _Label VALUE cText WIDTH (Len(aOptions)*(10+nBtnWidth))-50 HEIGHT 30 ;
               TRANSPARENT CENTERALIGN FONT "_Font_Options"
         ENDIF
      ELSE
         @ 40, 10 LABEL _Label VALUE cText WIDTH (Len(aOptions)*(10+nBtnWidth))-10 HEIGHT 30 ;
            TRANSPARENT CENTERALIGN FONT "_Font_Options"
      ENDIF

      FOR nItem:=1 To Len(aOptions)
         aBtn[nItem]:="_Btn_"+Ltrim(Str(nItem))
         cOption:=aBtn[nItem]
         @ nBtnPosY, nBtnPosX BUTTON &cOption CAPTION aOptions[nItem] WIDTH nBtnWidth HEIGHT 25 FONT "_Font_Options" ;
            ACTION ( cOption:=GetProperty("_Options", This.Name, "Caption"), _Options.Release )
         nBtnPosX+=nBtnWidth+10
      NEXT

      DoMethod("_Options", aBtn[nDefaultOption], "SetFocus")

      IF nSeconds>0
         DEFINE TIMER Timer_1 Interval nSeconds*1000  ;
            ACTION ( cOption:=aOptions[nDefaultOption], _Options.Release )
      ENDIF

   END WINDOW

   CENTER WINDOW _Options

   ACTIVATE WINDOW _Options

   RELEASE FONT _Font_Options

   RETURN Ascan(aOptions,Alltrim(cOption))

   /*
   * MsgLogo(cImage, [nSeconds])
   */

FUNCTION MsgLogo( cImage, nSeconds, lRound )

   LOCAL aImgInfo:=GetImageSize(cImage), width, height

   DEFAULT nSeconds To 5, lRound To .F.

   IF .Not. IsWindowDefined( _Logo )
      IF .Not. Empty( aImgInfo [BM_WIDTH] )

         width := aImgInfo [BM_WIDTH] + GetBorderWidth()
         height:= aImgInfo [BM_HEIGHT] + GetBorderHeight()

         DEFINE WINDOW _Logo   ;
               AT 0,0             ;
               WIDTH width        ;
               HEIGHT height      ;
               CHILD TOPMOST      ;
               NOCAPTION          ;
               ON SIZE (_Logo.Width:=width, _Logo.Height:=height ) ;
               ON MOUSECLICK _Logo.Release

            @ 0, 0 IMAGE _Image PICTURE (cImage) WIDTH aImgInfo [BM_WIDTH] HEIGHT aImgInfo [BM_HEIGHT]

            DEFINE TIMER Timer_1 INTERVAL nSeconds*1000 ACTION _Logo.Release

         END WINDOW

         IF lRound
            SET REGION OF _Logo ROUNDRECT 68,68,width,height
         ENDIF

         CENTER WINDOW _Logo

         ACTIVATE WINDOW _Logo

      ELSE
         MsgInfo("No se ha podido llevar a cabo la operación", "Error")
      ENDIF
   ENDIF

   RETURN NIL

STATIC FUNCTION GetImageSize( cImagePath )

   LOCAL aRetArr

   IF Upper( Right( cImagePath, 4 ) ) == ".BMP"

      aRetArr := BmpSize( cImagePath )

   ELSE

      aRetArr := hb_GetImageSize( cImagePath )

   ENDIF

   RETURN aRetArr

   /*
   * MsgDesktop([cText], [cTitle], [cImage], [lFlash])
   */

FUNCTION MsgDesktop(cText, cTitle, cImage, lFlash)

   LOCAL aImgInfo

   DEFAULT cText     To ""
   DEFAULT cTitle    To UPPER(_HMG_BRWLangError [10])+"!"
   DEFAULT cImage    To ""
   DEFAULT lFlash    To .T.

   IF .Not. IsWindowDefined( _Desktop )

      DEFINE WINDOW _Desktop   ;
            AT 0,0                ;
            WIDTH 330             ;
            HEIGHT 290            ;
            TITLE cTitle          ;
            ICON "demo.ico"       ;
            NOMAXIMIZE NOMINIMIZE ;
            NOSIZE                ;
            ON RELEASE IF( IsControlDefined( Timer_1, _Desktop ), _Desktop.Timer_1.Release, ) ;
            FONT 'MS Sans Serif'  ;
            SIZE 9

         ON KEY ESCAPE ACTION _Desktop.Release

         IF !Empty(cImage)
            aImgInfo := BmpSize(cImage)
            IF !Empty(aImgInfo [BM_WIDTH])
               @ 5, 10 IMAGE _Image PICTURE (cImage) WIDTH aImgInfo [BM_WIDTH] HEIGHT aImgInfo [BM_HEIGHT]
               @ 20, 55 LABEL _Label VALUE cText WIDTH 250 HEIGHT 250 TRANSPARENT
            ENDIF
         ELSE
            @ 20, 10 LABEL _Label VALUE cText WIDTH 295 HEIGHT 250 TRANSPARENT
         ENDIF

         IF lFlash
            DEFINE TIMER Timer_1 INTERVAL 500 ACTION FlashWindow( GetFormHandle('_Desktop') )
         ENDIF

      END WINDOW

      CENTER WINDOW _Desktop

      ACTIVATE WINDOW _Desktop

   ENDIF

   RETURN NIL

   /*
   * MsgPostIt([cText], [cTitle], [cImage], [lFlash], [aColor])
   */

FUNCTION MsgPostit(cText, cTitle, cImage, lFlash, aColor)

   LOCAL aImgInfo

   DEFAULT cText     To ""
   DEFAULT cTitle    To UPPER(_HMG_BRWLangError [10])+"!"
   DEFAULT cImage    To ""
   DEFAULT lFlash    To .T.
   DEFAULT aColor    To YELLOW

   DEFINE WINDOW _Postit   ;
         AT 0,0               ;
         WIDTH 320            ;
         HEIGHT 280           ;
         TITLE cTitle         ;
         ICON "demo.ico"      ;
         MODAL                ;
         NOSIZE               ;
         BACKCOLOR aColor     ;
         ON RELEASE IF( IsControlDefined( Timer_1, _Postit ), _Postit.Timer_1.Release, ) ;
         FONT 'MS Sans Serif' ;
         SIZE 9

      IF !Empty(cImage)
         aImgInfo := BmpSize(cImage)
         IF !Empty(aImgInfo [BM_WIDTH])
            @ 5, 10 IMAGE _Image PICTURE (cImage) WIDTH aImgInfo [BM_WIDTH] HEIGHT aImgInfo [BM_HEIGHT]
            @ 20, 55 LABEL _Label VALUE cText WIDTH 250 HEIGHT 250 TRANSPARENT
         ENDIF
      ELSE
         @ 20, 10 LABEL _Label VALUE cText WIDTH 295 HEIGHT 250 TRANSPARENT
      ENDIF

      IF lFlash
         DEFINE TIMER Timer_1 INTERVAL 500 ACTION FlashWindow( GetFormHandle('_Postit') )
      ENDIF

   END WINDOW

   CENTER WINDOW _Postit

   ACTIVATE WINDOW _Postit

   RETURN NIL

STATIC PROCEDURE FlashWindow( hWnd )

   STATIC   nStatus := 0
   IF IsWindowVisible( hWnd )
      FlashWnd( hWnd, (nStatus := IF( nStatus == 1, 0, 1 )) )
   ENDIF

   RETURN

   DECLARE DLL_TYPE_LONG FlashWindow( DLL_TYPE_LONG hWnd, DLL_TYPE_LONG nInvert ) ;
      IN USER32.DLL ;
      ALIAS FlashWnd

   /*
   * MsgToolTip(nSender, cText, [cTitle], [aColor])
   */

FUNCTION MsgToolTip(nSender, cText, cTitle, aColor)

   LOCAL FontHandle, FormIndex, FormName, ControlName
   LOCAL nWidth, nHeight:=14*1.2, n:=1, nSeconds:=3, nLines:=1

   DEFAULT cText  To ""
   DEFAULT cTitle To ""
   DEFAULT aColor To YELLOW

   cText          :=Alltrim(cText)
   cTitle         :=Alltrim(cTitle)

   FormIndex := ascan ( _HMG_aFormHandles , _HMG_aControlParentHandles[nSender] )
   FormName := _HMG_aFormNames [ FormIndex ]
   ControlName := _HMG_aControlNames [ nSender ]

   DEFINE FONT _Font_ToolTip FONTNAME "MS Sans Serif" SIZE 9
   FontHandle:=GetFontHandle("_Font_ToolTip")

   //Calcular tamaño respecto al fuente
   FOR n:=1 to Mlcount(cText)
      nWidth:=Max( GetTextWidth(, Alltrim( Memoline(cText,n) ), FontHandle), GetTextWidth(, cTitle, FontHandle) )+60
   NEXT
   nWidth:=If( nWidth>=GetDesktopWidth(), GetProperty(FormName, "Width")-60, nWidth )
   nLines:=MlCount(cText)+If(Len(cTitle)>0,1,0)

   DEFINE WINDOW _ToolTip       ;
         AT GetProperty(FormName, "Row")+GetProperty(FormName, ControlName, "Row")+(GetProperty(FormName, ControlName, "Height")*2)-5, ;
         GetProperty(FormName, "Col")+GetProperty(FormName, ControlName, "Col")+(GetProperty(FormName, ControlName, "Width")/2) ;
         WIDTH nWidth+60           ;
         HEIGHT nHeight*(nLines+1) ;
         MODAL                     ;
         NOCAPTION                 ;
         BACKCOLOR aColor          ;
         ON MOUSECLICK _ToolTip.Release

      IF Len(cTitle)>0
         @ 0,5 LABEL _Title VALUE cTitle WIDTH nWidth HEIGHT nHeight ;
            TRANSPARENT FONT "_Font_ToolTip" ACTION _ToolTip.Release
         @ nHeight+.5,30 LABEL _Label VALUE cText WIDTH nWidth HEIGHT nHeight*(nLines-1) ;
            TRANSPARENT CENTERALIGN FONT "_Font_ToolTip" ACTION _ToolTip.Release
      ELSE
         @ nHeight/2,30 LABEL _Label VALUE cText WIDTH nWidth HEIGHT nHeight*nLines ;
            TRANSPARENT CENTERALIGN FONT "_Font_ToolTip" ACTION _ToolTip.Release
      ENDIF

      DEFINE TIMER Timer_1 INTERVAL nSeconds*1000 ACTION _ToolTip.Release

   END WINDOW

   ACTIVATE WINDOW _ToolTip

   RELEASE FONT _Font_ToolTip

   RETURN NIL
