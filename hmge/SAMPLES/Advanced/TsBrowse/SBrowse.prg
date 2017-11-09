#include "MiniGui.ch"
#include "TSBrowse.ch"

//#define CLR_HBROWN  nRGB( 205, 192, 176 )

FUNCTION SBrwTest()

   LOCAL cTitle := "Customer List", ;
      bSetup := { |oBrw| SetMyBrowser( oBrw ) }

   DbSelectArea( "Employee" )

   SBrowse( "Employee", cTitle, bSetup )

   RETURN NIL

FUNCTION SetMyBrowser( oBrw )

   oBrw:nHeightCell += 5
   oBrw:nHeightHead += 5
   oBrw:nClrFocuFore := CLR_BLACK
   oBrw:nClrFocuBack := COLOR_GRID

   RETURN .T.

