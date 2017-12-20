#include <minigui.ch>

PROCEDURE Main

   LOAD WINDOW DEMO As Main
   Main.Center
   Main.Activate

   RETURN

FUNCTION _Connect()

   LOCAL c_STR_Con := "net:"
   LOCAL a_IP := Main.Text_1.Value
   LOCAL c_IP := str(a_IP[1], 3) + "." + hb_ntos(a_IP[2]) + "." + hb_ntos(a_IP[3]) + "." + hb_ntos(a_IP[4])

   c_STR_Con += lTrim(c_IP) + ":" + AllTrim(Main.Text_3.Value) + ":" + AllTrim(Main.Text_2.Value)

   IF NETIO_CONNECT( c_IP, AllTrim(Main.Text_3.Value) )
      DbUseArea( , , c_STR_Con, "Test" )
      INDEX ON field->CODE TO code
      EDIT EXTENDED
      CLOSE
      Ferase('code.ntx')
   ENDIF

   RETURN NIL
