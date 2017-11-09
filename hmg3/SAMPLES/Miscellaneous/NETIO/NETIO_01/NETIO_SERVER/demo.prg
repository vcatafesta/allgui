REQUEST HB_GT_WIN_DEFAULT

FUNCTION main()

   LOCAL pListenSocket

   pListenSocket := netio_mtserver()

   IF empty( pListenSocket )
      ? "Cannot start server."
   ELSE
      WAIT "Press any key to stop NETIO server."
      netio_serverstop( pListenSocket )
      pListenSocket := NIL
   ENDIF

   RETURN

