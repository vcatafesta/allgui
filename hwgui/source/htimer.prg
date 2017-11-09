/*
* $Id: htimer.prg,v 1.6 2008/09/26 15:17:26 mlacecilia Exp $
* HWGUI - Harbour Win32 GUI library source code:
* HTimer class
* Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
* www - http://www.geocities.com/alkresin/
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "common.ch"

#define  TIMER_FIRST_ID   33900

CLASS HTimer INHERIT HObject

CLASS VAR aTimers   INIT {}

   DATA id
   DATA value
   DATA oParent
   DATA bAction

   DATA   xName        HIDDEN
   ACCESS Name         INLINE ::xName
   ASSIGN Name(cName)  INLINE ::xName := cName, ;
      __objAddData(::oParent, cName),;
      ::oParent:&(cName) := self

   DATA   xInterval    HIDDEN
   ACCESS Interval     INLINE ::xInterval
   ASSIGN Interval(x)  INLINE ::xInterval := x, ;
      IIF( ::xInterval == 0, ;
      ::End(), ;
      SetTimer( ::oParent:handle, ::id, ::xInterval ))

METHOD New( oParent,id,value,bAction )

METHOD End()

ENDCLASS

METHOD New( oParent,nId,value,bAction ) CLASS HTimer

   ::oParent := Iif( oParent==Nil, HWindow():GetMain(), oParent )
   IF nId != nil
      IF  Ascan( ::aTimers,{|o|o:id == nId} ) != 0
         MsgStop("Error: attempt to createtimer with duplicated id")
         QUIT
      ENDIF
   ELSE
      nId := TIMER_FIRST_ID
      DO WHILE Ascan( ::aTimers,{|o|o:id == nId} ) !=  0
         nId++
      ENDDO
   ENDIF
   ::id      := nId
   ::value   := value
   ::bAction := bAction
   IF ::value > 0
      SetTimer( oParent:handle, ::id, ::value )
   ENDIF
   Aadd( ::aTimers,Self )

   RETURN Self

METHOD End() CLASS HTimer

   LOCAL i

   KillTimer( ::oParent:handle, ::id )
   i := Ascan( ::aTimers,{|o| o:id == ::id} )
   IF i != 0
      Adel( ::aTimers, i )
      Asize( ::aTimers, Len( ::aTimers ) - 1 )
   ENDIF

   RETURN NIL

FUNCTION TimerProc( hWnd, idTimer, time )

   LOCAL i := Ascan( HTimer():aTimers,{|o| o:id == idTimer} )

   HB_SYMBOL_UNUSED(hWnd)

   IF i != 0
      Eval( HTimer():aTimers[i]:bAction, time )
   ENDIF

   RETURN NIL

   EXIT PROCEDURE CleanTimers
   LOCAL oTimer, i

   FOR i := 1 TO Len( HTimer():aTimers )
      oTimer := HTimer():aTimers[i]
      KillTimer( oTimer:oParent:handle, oTimer:id )
   NEXT

   RETURN

