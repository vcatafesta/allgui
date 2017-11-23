#include "hmg.ch"

DECLARE window Main

MEMVAR aRecordSet

FUNCTION main_grid_1_onquerydata

   This.QueryData := aRecordSet [This.QueryRowIndex] [This.QueryColIndex]

   RETURN NIL
