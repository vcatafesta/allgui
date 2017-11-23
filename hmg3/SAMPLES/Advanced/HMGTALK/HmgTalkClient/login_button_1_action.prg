#include "hmg.ch"

DECLARE window Login

FUNCTION login_button_1_action

   PUBLIC c_Ip_Server := Login.Text_1.Value
   PUBLIC c_NickName  := Login.Text_2.Value

   IF Empty(Login.Text_1.Value)
      MsgStop("Type the server IP in here...",c_W_Title)

      RETURN NIL
   ENDIF
   IF Empty(Login.Text_2.Value)
      MsgStop("Type your NickName!",c_W_Title)

      RETURN NIL
   ENDIF
   Login.Release
   Start_Conexion()

   RETURN NIL
