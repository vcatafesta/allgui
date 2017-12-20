
FUNCTION MAIN

   LOCAL cServer := "127.0.0.1"
   LOCAL cPort := "2941"

   NETIO_CONNECT()

   USE ("net:" + cServer + ":" + cPort + ":base\test")

   browse()

   RETURN NIL
