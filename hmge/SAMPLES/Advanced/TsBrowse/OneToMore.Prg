#include "MiniGui.ch"
#include "TSBrowse.ch"
/*
#define CLR_PINK   RGB( 255, 128, 128)
*/

FUNCTION OneToMore(Invert)

   LOCAL oBrw, oBrw2
   FIELD State,last

   DEFAULT invert to .F.
   DbSelectArea( "Sta" )
   dbgotop()
   DbSelectArea( "Employee" )
   INDEX ON State+Last To StName

   IF ! _IsControlDefined ( "Font_1" , "Main" )
      DEFINE FONT Font_1  FONTNAME "Arial" SIZE 10
      DEFINE FONT Font_2  FONTNAME "Wingdings" SIZE 18
      DEFINE FONT Font_3  FONTNAME "MS Sans Serif" SIZE 12
      DEFINE FONT Font_4  FONTNAME "Arial" SIZE 14 BOLD ITALIC
      DEFINE FONT Font_5  FONTNAME "Arial" SIZE 12 UNDERLINE ITALIC
   ENDIF

   DEFINE WINDOW Form_10 At 40,60 ;
         WIDTH 807 HEIGHT 427 ;
         TITLE if(invert,"More To One Demo","One To More Demo") ;
         ICON "Demo.ico" ;
         CHILD ;

      DEFINE STATUSBAR
         STATUSITEM '' WIDTH 0
         STATUSITEM '' DEFAULT
      END STATUSBAR

      IF Invert  // more to one

         @ 185, 0 TBROWSE oBrw2 ALIAS "sta"  WIDTH 800 HEIGHT 185  ;
            FONT "Font_1" CELL

         oBrw2:LoadFields()
         oBrw2:nWheelLines := 1

         @ 0, 0 TBROWSE oBrw ALIAS "Employee"  WIDTH 800 HEIGHT 185  ;
            FONT "Font_1" ON CHANGE SincroTb(obrw2,invert) CELL
         oBrw:LoadFields()
         oBrw:Exchange(3, 5)
         oBrw:ChangeFont(GetFontHandle( "Font_4" ), 0, 2 )
         oBrw:ChangeFont(GetFontHandle( "Font_1" ), 0, 1 )
         oBrw:ChangeFont(GetFontHandle( "Font_3" ), 3, 1 )
         oBrw:nWheelLines := 1

         FORM_10.OBRW.SETFOCUS

      ELSE  // One to More

         @ 0, 0 TBROWSE oBrw2 ALIAS "sta"  WIDTH 800 HEIGHT 185  ;
            FONT "Font_1" ON CHANGE SincroTb(obrw,invert) ;
            CELL

         oBrw2:LoadFields()
         oBrw2:nWheelLines := 1

         @ 185, 0 TBROWSE oBrw ALIAS "Employee"  WIDTH 800 HEIGHT 185  ;
            FONT "Font_1" CELL
         oBrw:LoadFields()
         oBrw:Exchange(3, 5)
         oBrw:ChangeFont(GetFontHandle( "Font_4" ), 0, 2 )
         oBrw:ChangeFont(GetFontHandle( "Font_1" ), 0, 1 )
         oBrw:ChangeFont(GetFontHandle( "Font_3" ), 3, 1 )
         oBrw:nWheelLines := 1

         FORM_10.OBRW2.SETFOCUS

      ENDIF

   END WINDOW

   ACTIVATE WINDOW Form_10

   RELEASE FONT Font_1
   RELEASE FONT Font_2
   RELEASE FONT Font_3
   RELEASE FONT Font_4
   RELEASE FONT Font_5

   RETURN NIL
   /*
   */

FUNCTION SincroTb(obrw,Invert)

   LOCAL cSelState

   DEFAULT invert to .F.

   IF invert
      cSelState := Employee->state
      oBrw:SetFilter( "State", cSelState )
   ELSE
      cSelState := SubStr(sta->state,1,2)
      oBrw:SetFilter( "State+Last", cSelState )
   ENDIF

   _setitem("statusbar","Form_10",2,cSelState)

   oBrw:cPrefix := cSelState
   IF FieldGet(FieldPos("State")) != cSelState
      oBrw:Enabled(.f.)
   ELSE
      oBrw:Enabled(.T.)
   ENDIF
   oBrw:Refresh( .T. )
   oBrw:lHasChanged := .T.
   oBrw:lNoGrayBar := .T.

   RETURN NIL
