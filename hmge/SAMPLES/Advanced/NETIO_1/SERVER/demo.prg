
PROCEDURE main( nPort, cIfAddr, cRootDir, xRPC, ... )

   LOCAL pListenSocket

   pListenSocket := netio_mtserver( nPort, cIfAddr, cRootDir, xRPC, ... )

   IF empty( pListenSocket )
      ? "Cannot start server."
   ELSE
      WAIT "Press any key to stop NETIO server."
      netio_serverstop( pListenSocket )
      pListenSocket := NIL
   ENDIF

   RETURN

