#include "hmg.ch"

DECLARE window Main

MEMVAR cMainTitle

FUNCTION main_disconnect_action

   LOCAL cNetServer   := '127.0.0.1'
   LOCAL nNetPort      := 50000

   netio_disconnect( cNetServer , nNetPort )

   * Delete All Items
   Main.Grid_1.ItemCount := 0

   Main.Query_String.Value   := ''
   Main.Query_Server.Enabled := .F.
   Main.Query_String.Enabled := .F.
   Main.Disconnect.Enabled   := .F.
   Main.Connect.Enabled     := .T.

   SETPROPERTY('Main', 'Title', cMainTitle + ' - Disconnected!')

   RETURN NIL
