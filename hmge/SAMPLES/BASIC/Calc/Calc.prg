//===========================================================================//
// Program......: Calculator
// Programmer...: Marcos Antonio Gambeta
// Created at...: 13/01/2004 11:00:00
// Updated at...: 14/01/2004 00:10:47
//===========================================================================//
// This program is an adaptation of an example that follows
// Visual Basic 5. The original program can be found (for those who have the
// VB5) in the folder: C:\Program Files\DevStudio\VB\samples\PGuide\calc.
// If you improve or expand the capabilities of this calculator, be sure to
// send a copy to the author's original adaptation. In this case, I. :-)
//===========================================================================//
// Last UpDate at : 09/02/2010
// Updated by     : Paulo Sérgio Durço (Vanguarda) - Americana - SP - Brasil
// vanguarda.one@gmail.com
//===========================================================================//
// Added new functions: Memory value now avaliable. Now, you can put entry value from
// keyboard. HotKey for operations like "+" "-" "/" "*" and for manager memory.
// Added function that move the result of expression on ClipBoard of windows, when
// the calc is closed.
//===========================================================================//
//Follow the HotKeys
// C or c = CancelEntry_Click()
// R or r = Cancel_CLick()
// W or w = CancelMemo_Click()
// S or s = ReadMemo_Click()
// M or m = SMemo_Click()
// A or a = AddMemo_Click()
// ESC to Close
//===========================================================================//

#include "minigui.ch"

//===========================================================================//
// Statics variables
//===========================================================================//

STATIC nOp1,nOp2         // Store the values entered
STATIC lDecimalFlag      // Indicates whether there is already a decimal point in value
STATIC nNumOps           // Number of values entered
STATIC cLastInput        // Store the last key pressed
STATIC cOpFlag           // Indicates the pending operation
STATIC nMemo := 0        // Memory Calculator

//===========================================================================//
// Form main
//===========================================================================//

FUNCTION ShowCalc( nInput, lRetu_ClipBoard )

   DEFAULT lRetu_ClipBoard := .t.

   DEFINE WINDOW Calc ;
         AT 0,0 WIDTH 260 HEIGHT 228 ;
         TITLE "Calculator" ;
         ICON "Calc.ico" ;
         CHILD ;
         NOSIZE NOMAXIMIZE ;
         FONT "Arial" SIZE 10 ;
         ON INIT Form_Load(nInput) ;
         ON RELEASE nOp1 := Val(Alltrim(Calc.ReadOut.Value))

      // visor
      @ 007,027 TEXTBOX ReadOut  VALUE "0." WIDTH 220 HEIGHT 25 BACKCOLOR WHITE RIGHTALIGN NOTABSTOP
      @ 007,009 TEXTBOX ReadFunc VALUE " "  WIDTH 18  HEIGHT 25 READONLY RIGHTALIGN NOTABSTOP
      @ 040,121 TEXTBOX ReadHide VALUE " "  WIDTH 16  HEIGHT 25 NOTABSTOP ON CHANGE EvalKeys() ON ENTER Operator_Click("=") INVISIBLE
      // 7 8 9 C CE MC
      @ 040,008 BUTTONEX btnN7  CAPTION "7"  ACTION Number_Click(7)     WIDTH 32 HEIGHT 32 FONTCOLOR BLUE
      @ 040,048 BUTTONEX btnN8  CAPTION "8"  ACTION Number_Click(8)     WIDTH 32 HEIGHT 32 FONTCOLOR BLUE
      @ 040,088 BUTTONEX btnN9  CAPTION "9"  ACTION Number_Click(9)     WIDTH 32 HEIGHT 32 FONTCOLOR BLUE
      @ 040,136 BUTTONEX btnC   CAPTION "C"  ACTION Cancel_Click()      WIDTH 32 HEIGHT 32 FONTCOLOR RED
      @ 040,176 BUTTONEX btnCE  CAPTION "CE" ACTION CancelEntry_Click() WIDTH 32 HEIGHT 32 FONTCOLOR RED
      @ 040,216 BUTTONEX btnMC  CAPTION "MC" ACTION CancelMemo_Click()  WIDTH 32 HEIGHT 32 FONTCOLOR RED
      // 4 5 6 + - MR
      @ 080,008 BUTTONEX btnN4  CAPTION "4"  ACTION Number_Click(4)     WIDTH 32 HEIGHT 32 FONTCOLOR BLUE
      @ 080,048 BUTTONEX btnN5  CAPTION "5"  ACTION Number_Click(5)     WIDTH 32 HEIGHT 32 FONTCOLOR BLUE
      @ 080,088 BUTTONEX btnN6  CAPTION "6"  ACTION Number_Click(6)     WIDTH 32 HEIGHT 32 FONTCOLOR BLUE
      @ 080,136 BUTTONEX btnOA  CAPTION "+"  ACTION Operator_Click("+") WIDTH 32 HEIGHT 32 FONTCOLOR RED
      @ 080,176 BUTTONEX btnOS  CAPTION "-"  ACTION Operator_Click("-") WIDTH 32 HEIGHT 32 FONTCOLOR RED
      @ 080,216 BUTTONEX btnMR  CAPTION "MR" ACTION ReadMemo_Click()    WIDTH 32 HEIGHT 32 FONTCOLOR RED
      // 1 2 3 X / MS
      @ 120,008 BUTTONEX btnN1  CAPTION "1"  ACTION Number_Click(1)     WIDTH 32 HEIGHT 32 FONTCOLOR BLUE
      @ 120,048 BUTTONEX btnN2  CAPTION "2"  ACTION Number_Click(2)     WIDTH 32 HEIGHT 32 FONTCOLOR BLUE
      @ 120,088 BUTTONEX btnN3  CAPTION "3"  ACTION Number_Click(3)     WIDTH 32 HEIGHT 32 FONTCOLOR BLUE
      @ 120,136 BUTTONEX btnOM  CAPTION "*"  ACTION Operator_Click("*") WIDTH 32 HEIGHT 32 FONTCOLOR RED
      @ 120,176 BUTTONEX btnOD  CAPTION "/"  ACTION Operator_Click("/") WIDTH 32 HEIGHT 32 FONTCOLOR RED
      @ 120,216 BUTTONEX btnMS  CAPTION "MS" ACTION SMemo_Click()       WIDTH 32 HEIGHT 32 FONTCOLOR RED
      // 0 . = % M+
      @ 160,008 BUTTONEX btnN0  CAPTION "0"  ACTION Number_Click(0)     WIDTH 72 HEIGHT 32 FONTCOLOR BLUE
      @ 160,088 BUTTONEX btnDot CAPTION "."  ACTION Decimal_Click()     WIDTH 32 HEIGHT 32 FONTCOLOR BLUE
      @ 160,136 BUTTONEX btnOI  CAPTION "="  ACTION Operator_Click("=") WIDTH 32 HEIGHT 32 FONTCOLOR RED
      @ 160,176 BUTTONEX btnOP  CAPTION "%"  ACTION Percent_Click()     WIDTH 32 HEIGHT 32 FONTCOLOR BLUE
      @ 160,216 BUTTONEX btnMP  CAPTION "M+" ACTION AddMemo_Click()     WIDTH 32 HEIGHT 32 FONTCOLOR RED

      ON KEY ESCAPE ACTION Calc.Release

   END WINDOW

   _ExtDisableControl ( "ReadOut", "Calc" )

   Calc.Center
   Calc.Activate

   IF lRetu_ClipBoard
      System.Clipboard := Ltrim(Str(nOp1))
   ENDIF

   RETURN nOp1

   // The initialization routine of the form.
   // Set the initial values of variables.

STATIC FUNCTION Form_Load(nInput)

   lDecimalFlag := .f.
   nNumOps := 0
   cLastInput := "NONE"
   cOpFlag := " "
   Calc.Readout.Value := "0."
   nOp1 := 0
   nOp2 := 0

   IF Valtype(nInput) == "N"
      System.ClipBoard := nInput
      nMemo := nInput
      ReadMemo_Click()
      nMemo := 0
   ELSE
      Calc.ReadHide.SetFocus()
   ENDIF

   RETURN NIL

   // Event 'click' of button "C" (CANCEL)
   // Reset text control ReadOut and clean the variables

STATIC FUNCTION Cancel_Click()

   Form_Load()

   RETURN NIL

   // Event 'click' of button "CE" (CANCEL ENTRY)
   // Cancel value on ReadOut (TextBox)

STATIC FUNCTION CancelEntry_Click()

   Calc.Readout.Value := "0."
   lDecimalFlag := .f.
   cLastInput := "CE"
   Calc.ReadHide.SetFocus()

   RETURN NIL

   // Event 'click' of button "." (DECIMAL POINT)
   // If the last button pressed, was an operator, show on ReadOut (TextBox)
   // the value "0.". Case not, add a decimal point into ReadOut

STATIC FUNCTION Decimal_Click()

   IF cLastInput = "NEG"
      Calc.Readout.Value := "-0."
   ELSEIF cLastInput <> "NUMS"
      Calc.Readout.Value := "0."
   ENDIF
   lDecimalFlag := .t.
   cLastInput := "NUMS"
   Calc.ReadHide.SetFocus()

   RETURN NIL

   // Event 'click' for the buttons of 0 to 9 (NUMBERS KEYS)
   // Add the new number into ReadOut (TextBox)

STATIC FUNCTION Number_Click( nIndex )

   IF cLastInput <> "NUMS"
      Calc.Readout.Value := "."
      lDecimalFlag := .f.
   ENDIF
   IF lDecimalFlag
      Calc.Readout.Value := Calc.Readout.Value + Str(nIndex,1)
   ELSE
      Calc.Readout.Value := Left(Calc.Readout.Value,At(".",Calc.Readout.Value)-1)+Str(nIndex,1)+"."
   ENDIF
   IF cLastInput = "NEG"
      Calc.Readout.Value := "-" + Calc.Readout.Value
   ENDIF
   cLastInput := "NUMS"
   Calc.ReadHide.SetFocus()

   RETURN NIL

   // Event 'click' for the button "%" (PERCENT KEY)
   // Calculate and show, the percentual of first value

STATIC FUNCTION Percent_Click()

   nOp2 := nOp1 * Val(Calc.Readout.Value)/100
   Calc.Readout.Value := AllTrim(Str(nOp2))
   Calc.ReadFunc.Value := "%"
   cLastInput := "OPS"
   nNumOps ++
   lDecimalFlag := .t.
   Calc.ReadHide.SetFocus()

   RETURN NIL

   // Event 'click' for the keys "+-x/=" (OPERATOR KEYS)
   // If the last button pressed was a number, or part this.
   // Increment the nNumOps. If a operand be present, define nOp1.
   // If two operand are presenteso, define nOp1 like the result of the
   // operation from nOp1 and current value and show the results

STATIC FUNCTION Operator_Click( cIndex )

   LOCAL cTempReadout

   cTempReadout := Calc.Readout.Value

   Calc.ReadFunc.Value := cIndex

   IF cLastInput = "NUMS"
      nNumOps ++
   ENDIF
   DO CASE
   CASE nNumOps = 0
      IF cIndex = "-" .And. cLastInput <> "NEG"
         Calc.Readout.Value := "-" + Calc.Readout.Value
         cLastInput := "NEG"
      ENDIF
   CASE nNumOps = 1
      nOp1 := Val( Calc.Readout.Value )
      IF cIndex = "-" .And. cLastInput <> "NUMS" .And. cOpFlag <> "="
         Calc.Readout.Value := "-"
         cLastInput := "NEG"
      ENDIF
   CASE nNumOps = 2
      nOp2 := Val(cTempReadout)
      DO CASE
      CASE cOpFlag = "+"
         nOp1 := nOp1 + nOp2
      CASE cOpFlag = "-"
         nOp1 := nOp1 - nOp2
      CASE cOpFlag = "*"
         nOp1 := nOp1 * nOp2
      CASE cOpFlag = "/"
         IF nOp2 = 0
            MsgInfo("Division by 0 (zero) not allowed.","Calc")
         ELSE
            nOp1 := nOp1 / nOp2
         ENDIF
      CASE cOpFlag = "="
         nOp1 := nOp2
      ENDCASE
      Calc.Readout.Value := LTrim(Str(nOp1))
      nNumOps := 1
   ENDCASE
   IF cLastInput <> "NEG"
      cLastInput := "OPS"
      cOpFlag := cIndex
   ENDIF
   Calc.ReadHide.SetFocus()

   RETURN NIL

   // This function clean the variable used for add value into memory

STATIC FUNCTION CancelMemo_Click

   nMemo := 0
   SetProperty("Calc","btnMS","FontBold",.F.)
   Calc.ReadHide.SetFocus()

   RETURN NIL

   // This function show in ReadOut (TextBox) the value in memory (nMemo)

STATIC FUNCTION ReadMemo_Click

   LOCAL i, nLen

   IF !Empty(nMemo)
      Calc.Readout.Value := ""
      nLen := Len(Ltrim(Str(nMemo)))
      FOR i := 1 to nLen
         IF SubStr(Ltrim(Str(nMemo)),i,1) # "."
            Number_Click(Val(SubStr(Ltrim(Str(nMemo)),i,1)))
         ELSE
            IF nLen # i
               Decimal_Click()
               IF Right(Calc.Readout.Value,1) # "."
                  Calc.Readout.Value := Calc.Readout.Value + "."
               ENDIF
            ENDIF
         ENDIF
      NEXT i
   ENDIF
   Calc.ReadHide.SetFocus()

   RETURN NIL

   // This function, move to memory (nMemo) the value of ReadOut (TxtBox)

STATIC FUNCTION SMemo_Click

   IF !Empty(Calc.Readout.Value) .and. Val(Calc.Readout.Value) > 0
      nMemo := Val(Calc.Readout.value)
      SetProperty("Calc","btnMS","FontBold",.T.)
      Calc.ReadHide.SetFocus()
   ENDIF

   RETURN NIL

   // This function add the value from ReadOut (TextBox) into memory

STATIC FUNCTION AddMemo_Click

   IF !Empty(Calc.Readout.Value) .and. Val(Calc.Readout.Value) > 0
      nMemo := nMemo + Val(Calc.Readout.Value)
      SetProperty("Calc","btnMS","FontBold",.T.)
   ENDIF
   Calc.ReadHide.SetFocus()

   RETURN NIL

   // This function evaluates the keys you type, to perform the functions of
   // Calculator keyboard

STATIC FUNCTION EvalKeys()

   LOCAL c_Keys

   IF !Empty(Calc.ReadHide.Value)
      c_Keys := Alltrim(Calc.ReadHide.Value)
      DO CASE
      CASE c_Keys == "0" .or. IsDigit(c_Keys)
         Number_Click(Val(c_Keys))
      CASE c_Keys == "/"
         Operator_Click("/")
      CASE c_Keys == "*"
         Operator_Click("*")
      CASE c_Keys == "-"
         Operator_Click("-")
      CASE c_Keys == "+"
         Operator_Click("+")
      CASE c_Keys == "."
         Decimal_Click()
      CASE c_Keys == "C" .or. c_Keys == "c"
         CancelEntry_Click()
      CASE c_Keys == "R" .or. c_Keys == "r"
         Cancel_Click()
      CASE c_Keys == "W" .or. c_Keys == "w"
         CancelMemo_Click()
      CASE c_Keys == "S" .or. c_Keys == "s"
         ReadMemo_Click()
      CASE c_Keys == "M" .or. c_Keys == "m"
         SMemo_Click()
      CASE c_Keys == "A" .or. c_Keys == "a"
         AddMemo_Click()
      END CASE
      Calc.ReadHide.Value := ""
   ENDIF

   RETURN NIL
   //===========================================================================//

