#include <hmg.ch>
REQUEST HB_GT_WIN_DEFAULT

FUNCTION Main

   LOAD WINDOW Main
   Main.Center
   Main.Activate

   RETURN

FUNCTION _Connect()

   LOCAL c_STR_Con := "net:"

   c_STR_Con := c_STR_con + AllTrim(Main.Text_1.Value) + ":" ;
      + AllTrim(Main.Text_3.Value) + ":" ;
      + AllTrim(Main.Text_2.Value)

   IF NETIO_CONNECT("127.0.0.1","2941")
      DBUseArea(.t.,,c_STR_Con,AllTrim(Main.Text_2.Value))
      EDIT EXTENDED
   ENDIF

   RETURN NIL
