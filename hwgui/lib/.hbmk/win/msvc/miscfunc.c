/*
 * Harbour 3.2.0dev (r1310312321)
 * Microsoft Visual C 16.0.40219 (32-bit)
 * Generated C source from "contrib\misc\miscfunc.prg"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( ADDMETHOD );
HB_FUNC_EXTERN( VALTYPE );
HB_FUNC_EXTERN( EMPTY );
HB_FUNC_EXTERN( __OBJHASMSG );
HB_FUNC_EXTERN( __OBJADDMETHOD );
HB_FUNC( ADDPROPERTY );
HB_FUNC_EXTERN( __OBJHASDATA );
HB_FUNC_EXTERN( __OBJADDDATA );
HB_FUNC( REMOVEPROPERTY );
HB_FUNC_EXTERN( __OBJDELDATA );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_MISCFUNC )
{ "ADDMETHOD", {HB_FS_PUBLIC | HB_FS_FIRST | HB_FS_LOCAL}, {HB_FUNCNAME( ADDMETHOD )}, NULL },
{ "VALTYPE", {HB_FS_PUBLIC}, {HB_FUNCNAME( VALTYPE )}, NULL },
{ "EMPTY", {HB_FS_PUBLIC}, {HB_FUNCNAME( EMPTY )}, NULL },
{ "__OBJHASMSG", {HB_FS_PUBLIC}, {HB_FUNCNAME( __OBJHASMSG )}, NULL },
{ "__OBJADDMETHOD", {HB_FS_PUBLIC}, {HB_FUNCNAME( __OBJADDMETHOD )}, NULL },
{ "ADDPROPERTY", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( ADDPROPERTY )}, NULL },
{ "__OBJHASDATA", {HB_FS_PUBLIC}, {HB_FUNCNAME( __OBJHASDATA )}, NULL },
{ "__OBJADDDATA", {HB_FS_PUBLIC}, {HB_FUNCNAME( __OBJADDDATA )}, NULL },
{ "EVAL", {HB_FS_PUBLIC | HB_FS_MESSAGE}, {NULL}, NULL },
{ "REMOVEPROPERTY", {HB_FS_PUBLIC | HB_FS_LOCAL}, {HB_FUNCNAME( REMOVEPROPERTY )}, NULL },
{ "__OBJDELDATA", {HB_FS_PUBLIC}, {HB_FUNCNAME( __OBJDELDATA )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_MISCFUNC, "contrib\\misc\\miscfunc.prg", 0x0, 0x0003 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_MISCFUNC
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_MISCFUNC )
   #include "hbiniseg.h"
#endif

HB_FUNC( ADDMETHOD )
{
	static const HB_BYTE pcode[] =
	{
		13,0,3,36,7,0,176,1,0,95,1,12,1,106,
		2,79,0,5,28,45,176,2,0,95,2,12,1,31,
		36,36,8,0,176,3,0,95,1,95,2,12,2,31,
		16,36,9,0,176,4,0,95,1,95,2,95,3,20,
		3,36,11,0,120,110,7,36,13,0,9,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( ADDPROPERTY )
{
	static const HB_BYTE pcode[] =
	{
		13,0,3,36,17,0,176,1,0,95,1,12,1,106,
		2,79,0,5,29,129,0,176,2,0,95,2,12,1,
		31,119,36,18,0,176,6,0,95,1,95,2,12,2,
		31,27,36,19,0,176,2,0,176,7,0,95,1,95,
		2,12,2,12,1,28,8,36,20,0,9,110,7,36,
		23,0,176,2,0,95,3,12,1,31,62,36,24,0,
		176,1,0,95,3,12,1,106,2,66,0,5,28,27,
		36,25,0,106,2,95,0,95,2,72,46,95,1,48,
		8,0,95,3,112,0,112,1,73,25,20,36,27,0,
		106,2,95,0,95,2,72,46,95,1,95,3,112,1,
		73,36,30,0,120,110,7,36,32,0,9,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( REMOVEPROPERTY )
{
	static const HB_BYTE pcode[] =
	{
		13,0,2,36,37,0,176,1,0,95,1,12,1,106,
		2,79,0,5,28,40,176,2,0,95,2,12,1,31,
		31,176,6,0,95,1,95,2,12,2,28,20,36,38,
		0,176,2,0,176,10,0,95,1,95,2,12,2,20,
		1,7,36,40,0,9,110,7
	};

	hb_vmExecute( pcode, symbols );
}
