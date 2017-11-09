
#include "hmg.ch"

DECLARE window Main

MEMVAR aRecordSet

FUNCTION main_query_server_action

   aRecordset := netio_funcexec( "query_001" , Main.Query_String.Value )

   Main.Grid_1.ItemCount := LEN(aRecordset)

   IF Len( aRecordset ) == 0
      MsgInfo( 'No Records Found!' )
      Main.Query_String.Value := ''
   ENDIF

   RETURN NIL

