
#include "windows.ch"
#include "guilib.ch"

REQUEST HTIMER
REQUEST DBCREATE
REQUEST DBUSEAREA
REQUEST DBCREATEINDEX
REQUEST DBSEEK

FUNCTION Main

   LOCAL oForm := HFormTmpl():Read( "example.xml" )

   oForm:ShowMain()

   RETURN NIL

