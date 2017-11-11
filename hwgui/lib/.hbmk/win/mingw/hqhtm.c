/* C source generated by Harbour */

#include "hbvmpub.h"
#include "hbinit.h"

HB_FUNC( HQHTM );
HB_FUNC_EXTERN( __CLSLOCKDEF );
HB_FUNC_EXTERN( HBCLASS );
HB_FUNC_EXTERN( HCONTROL );
HB_FUNC_STATIC( HQHTM_NEW );
HB_FUNC_STATIC( HQHTM_ACTIVATE );
HB_FUNC_STATIC( HQHTM_REDEFINE );
HB_FUNC_STATIC( HQHTM_INIT );
HB_FUNC_STATIC( HQHTM_NOTIFY );
HB_FUNC_EXTERN( __CLSUNLOCKDEF );
HB_FUNC_EXTERN( __OBJHASMSG );
HB_FUNC_EXTERN( HWG_BITOR );
HB_FUNC_EXTERN( CREATEQHTM );
HB_FUNC_EXTERN( QHTM_INIT );
HB_FUNC_EXTERN( EMPTY );
HB_FUNC_EXTERN( HWG_SETWINDOWTEXT );
HB_FUNC_EXTERN( QHTM_LOADFILE );
HB_FUNC_EXTERN( QHTM_LOADRES );
HB_FUNC_EXTERN( QHTM_FORMCALLBACK );
HB_FUNC_EXTERN( QHTM_GETNOTIFY );
HB_FUNC_EXTERN( FILE );
HB_FUNC_EXTERN( HWG_MSGSTOP );
HB_FUNC_EXTERN( QHTM_SETRETURNVALUE );
HB_FUNC( QHTMFORMPROC );
HB_FUNC_EXTERN( HWG_FINDSELF );
HB_FUNC( HQHTMBUTTON );
HB_FUNC_EXTERN( HBUTTON );
HB_FUNC_STATIC( HQHTMBUTTON_NEW );
HB_FUNC_STATIC( HQHTMBUTTON_REDEFINE );
HB_FUNC_STATIC( HQHTMBUTTON_INIT );
HB_FUNC_EXTERN( HWG_SETCTRLFONT );
HB_FUNC_EXTERN( HWG_GETSTOCKOBJECT );
HB_FUNC_EXTERN( QHTM_SETHTMLBUTTON );
HB_FUNC_EXIT( FREEQHTM );
HB_FUNC_EXTERN( QHTM_END );
HB_FUNC_INITSTATICS();

HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_HQHTM )
{ "HQHTM", { HB_FS_PUBLIC | HB_FS_FIRST | HB_FS_LOCAL }, { HB_FUNCNAME( HQHTM ) }, NULL },
{ "__CLSLOCKDEF", { HB_FS_PUBLIC }, { HB_FUNCNAME( __CLSLOCKDEF ) }, NULL },
{ "NEW", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "HBCLASS", { HB_FS_PUBLIC }, { HB_FUNCNAME( HBCLASS ) }, NULL },
{ "HCONTROL", { HB_FS_PUBLIC }, { HB_FUNCNAME( HCONTROL ) }, NULL },
{ "ADDMULTIDATA", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "ADDMETHOD", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "HQHTM_NEW", { HB_FS_STATIC | HB_FS_LOCAL }, { HB_FUNCNAME( HQHTM_NEW ) }, NULL },
{ "HQHTM_ACTIVATE", { HB_FS_STATIC | HB_FS_LOCAL }, { HB_FUNCNAME( HQHTM_ACTIVATE ) }, NULL },
{ "HQHTM_REDEFINE", { HB_FS_STATIC | HB_FS_LOCAL }, { HB_FUNCNAME( HQHTM_REDEFINE ) }, NULL },
{ "HQHTM_INIT", { HB_FS_STATIC | HB_FS_LOCAL }, { HB_FUNCNAME( HQHTM_INIT ) }, NULL },
{ "HQHTM_NOTIFY", { HB_FS_STATIC | HB_FS_LOCAL }, { HB_FUNCNAME( HQHTM_NOTIFY ) }, NULL },
{ "CREATE", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "__CLSUNLOCKDEF", { HB_FS_PUBLIC }, { HB_FUNCNAME( __CLSUNLOCKDEF ) }, NULL },
{ "INSTANCE", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "__OBJHASMSG", { HB_FS_PUBLIC }, { HB_FUNCNAME( __OBJHASMSG ) }, NULL },
{ "INITCLASS", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "_OPARENT", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "ODEFAULTPARENT", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "_ID", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "NEWID", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "_STYLE", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "HWG_BITOR", { HB_FS_PUBLIC }, { HB_FUNCNAME( HWG_BITOR ) }, NULL },
{ "_NLEFT", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "_NTOP", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "_NWIDTH", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "_NHEIGHT", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "_BINIT", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "_BSIZE", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "_BLINK", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "_BSUBMIT", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "_CTEXT", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "_FILENAME", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "_RESNAME", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "ADDCONTROL", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "OPARENT", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "ACTIVATE", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "HANDLE", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "_HANDLE", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "CREATEQHTM", { HB_FS_PUBLIC }, { HB_FUNCNAME( CREATEQHTM ) }, NULL },
{ "ID", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "STYLE", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "NLEFT", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "NTOP", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "NWIDTH", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "NHEIGHT", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "INIT", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "QHTM_INIT", { HB_FS_PUBLIC }, { HB_FUNCNAME( QHTM_INIT ) }, NULL },
{ "LINIT", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "SUPER", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "EMPTY", { HB_FS_PUBLIC }, { HB_FUNCNAME( EMPTY ) }, NULL },
{ "CTEXT", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "HWG_SETWINDOWTEXT", { HB_FS_PUBLIC }, { HB_FUNCNAME( HWG_SETWINDOWTEXT ) }, NULL },
{ "FILENAME", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "QHTM_LOADFILE", { HB_FS_PUBLIC }, { HB_FUNCNAME( QHTM_LOADFILE ) }, NULL },
{ "RESNAME", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "QHTM_LOADRES", { HB_FS_PUBLIC }, { HB_FUNCNAME( QHTM_LOADRES ) }, NULL },
{ "QHTM_FORMCALLBACK", { HB_FS_PUBLIC }, { HB_FUNCNAME( QHTM_FORMCALLBACK ) }, NULL },
{ "QHTM_GETNOTIFY", { HB_FS_PUBLIC }, { HB_FUNCNAME( QHTM_GETNOTIFY ) }, NULL },
{ "BLINK", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "EVAL", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "FILE", { HB_FS_PUBLIC }, { HB_FUNCNAME( FILE ) }, NULL },
{ "HWG_MSGSTOP", { HB_FS_PUBLIC }, { HB_FUNCNAME( HWG_MSGSTOP ) }, NULL },
{ "QHTM_SETRETURNVALUE", { HB_FS_PUBLIC }, { HB_FUNCNAME( QHTM_SETRETURNVALUE ) }, NULL },
{ "QHTMFORMPROC", { HB_FS_PUBLIC | HB_FS_LOCAL }, { HB_FUNCNAME( QHTMFORMPROC ) }, NULL },
{ "HWG_FINDSELF", { HB_FS_PUBLIC }, { HB_FUNCNAME( HWG_FINDSELF ) }, NULL },
{ "BSUBMIT", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "HQHTMBUTTON", { HB_FS_PUBLIC | HB_FS_LOCAL }, { HB_FUNCNAME( HQHTMBUTTON ) }, NULL },
{ "HBUTTON", { HB_FS_PUBLIC }, { HB_FUNCNAME( HBUTTON ) }, NULL },
{ "ADDMULTICLSDATA", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "HQHTMBUTTON_NEW", { HB_FS_STATIC | HB_FS_LOCAL }, { HB_FUNCNAME( HQHTMBUTTON_NEW ) }, NULL },
{ "HQHTMBUTTON_REDEFINE", { HB_FS_STATIC | HB_FS_LOCAL }, { HB_FUNCNAME( HQHTMBUTTON_REDEFINE ) }, NULL },
{ "HQHTMBUTTON_INIT", { HB_FS_STATIC | HB_FS_LOCAL }, { HB_FUNCNAME( HQHTMBUTTON_INIT ) }, NULL },
{ "_CHTML", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "REDEFINE", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "OFONT", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "HWG_SETCTRLFONT", { HB_FS_PUBLIC }, { HB_FUNCNAME( HWG_SETCTRLFONT ) }, NULL },
{ "HWG_GETSTOCKOBJECT", { HB_FS_PUBLIC }, { HB_FUNCNAME( HWG_GETSTOCKOBJECT ) }, NULL },
{ "CHTML", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "QHTM_SETHTMLBUTTON", { HB_FS_PUBLIC }, { HB_FUNCNAME( QHTM_SETHTMLBUTTON ) }, NULL },
{ "FREEQHTM$", { HB_FS_EXIT | HB_FS_LOCAL }, { HB_EXIT_FUNCNAME( FREEQHTM ) }, NULL },
{ "QHTM_END", { HB_FS_PUBLIC }, { HB_FUNCNAME( QHTM_END ) }, NULL },
{ "(_INITSTATICS00002)", { HB_FS_INITEXIT | HB_FS_LOCAL }, { hb_INITSTATICS }, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_HQHTM, "", 0x0, 0x0003 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_HQHTM
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_HQHTM )
   #include "hbiniseg.h"
#endif

HB_FUNC( HQHTM )
{
	static const HB_BYTE pcode[] =
	{
		149,3,0,116,82,0,36,15,0,103,1,0,100,8,29,223,1,176,1,
		0,104,1,0,12,1,29,212,1,166,150,1,0,122,80,1,48,2,0,
		176,3,0,12,0,106,6,72,81,104,116,109,0,108,4,4,1,0,108,
		0,112,3,80,2,36,17,0,48,5,0,95,2,100,106,22,81,72,84,
		77,95,87,105,110,100,111,119,95,67,108,97,115,115,95,48,48,49,0,
		95,1,121,72,121,72,121,72,106,9,119,105,110,99,108,97,115,115,0,
		4,1,0,9,112,5,73,36,18,0,48,5,0,95,2,100,106,1,0,
		95,1,121,72,121,72,121,72,106,6,99,84,101,120,116,0,4,1,0,
		9,112,5,73,36,19,0,48,5,0,95,2,100,106,1,0,95,1,121,
		72,121,72,121,72,106,9,102,105,108,101,110,97,109,101,0,4,1,0,
		9,112,5,73,36,20,0,48,5,0,95,2,100,106,1,0,95,1,121,
		72,121,72,121,72,106,8,114,101,115,110,97,109,101,0,4,1,0,9,
		112,5,73,36,21,0,48,5,0,95,2,100,100,95,1,121,72,121,72,
		121,72,106,6,98,76,105,110,107,0,106,8,98,83,117,98,109,105,116,
		0,4,2,0,9,112,5,73,36,24,0,48,6,0,95,2,106,4,78,
		101,119,0,108,7,95,1,121,72,121,72,121,72,112,3,73,36,25,0,
		48,6,0,95,2,106,9,65,99,116,105,118,97,116,101,0,108,8,95,
		1,121,72,121,72,121,72,112,3,73,36,26,0,48,6,0,95,2,106,
		9,82,101,100,101,102,105,110,101,0,108,9,95,1,121,72,121,72,121,
		72,112,3,73,36,27,0,48,6,0,95,2,106,5,73,110,105,116,0,
		108,10,95,1,121,72,121,72,121,72,112,3,73,36,28,0,48,6,0,
		95,2,106,7,78,111,116,105,102,121,0,108,11,95,1,121,72,121,72,
		121,72,112,3,73,36,30,0,48,12,0,95,2,112,0,73,167,14,0,
		0,176,13,0,104,1,0,95,2,20,2,168,48,14,0,95,2,112,0,
		80,3,176,15,0,95,3,106,10,73,110,105,116,67,108,97,115,115,0,
		12,2,28,12,48,16,0,95,3,164,146,1,0,73,95,3,110,7,48,
		14,0,103,1,0,112,0,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( HQHTM_NEW )
{
	static const HB_BYTE pcode[] =
	{
		13,0,14,36,37,0,48,17,0,102,95,1,100,8,28,10,48,18,0,
		102,112,0,25,4,95,1,112,1,73,36,38,0,48,19,0,102,95,2,
		100,8,28,10,48,20,0,102,112,0,25,4,95,2,112,1,73,36,39,
		0,48,21,0,102,176,22,0,95,3,100,8,28,5,121,25,4,95,3,
		97,0,0,0,80,12,2,112,1,73,36,40,0,48,23,0,102,95,4,
		112,1,73,36,41,0,48,24,0,102,95,5,112,1,73,36,42,0,48,
		25,0,102,95,6,112,1,73,36,43,0,48,26,0,102,95,7,112,1,
		73,36,44,0,48,27,0,102,95,9,112,1,73,36,45,0,48,28,0,
		102,95,10,112,1,73,36,46,0,48,29,0,102,95,11,112,1,73,36,
		47,0,48,30,0,102,95,12,112,1,73,36,48,0,95,8,100,69,28,
		16,36,49,0,48,31,0,102,95,8,112,1,73,25,46,36,50,0,95,
		13,100,69,28,16,36,51,0,48,32,0,102,95,13,112,1,73,25,23,
		36,52,0,95,14,100,69,28,14,36,53,0,48,33,0,102,95,14,112,
		1,73,36,56,0,48,34,0,48,35,0,102,112,0,102,112,1,73,36,
		57,0,48,36,0,102,112,0,73,36,59,0,102,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( HQHTM_ACTIVATE )
{
	static const HB_BYTE pcode[] =
	{
		36,62,0,48,37,0,48,35,0,102,112,0,112,0,121,69,28,76,36,
		64,0,48,38,0,102,176,39,0,48,37,0,48,35,0,102,112,0,112,
		0,48,40,0,102,112,0,48,41,0,102,112,0,48,42,0,102,112,0,
		48,43,0,102,112,0,48,44,0,102,112,0,48,45,0,102,112,0,12,
		7,112,1,73,36,65,0,48,46,0,102,112,0,73,25,10,36,67,0,
		176,47,0,20,0,36,69,0,100,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( HQHTM_REDEFINE )
{
	static const HB_BYTE pcode[] =
	{
		13,0,9,36,73,0,48,17,0,102,95,1,100,8,28,10,48,18,0,
		102,112,0,25,4,95,1,112,1,73,36,74,0,48,19,0,102,95,2,
		112,1,73,36,75,0,48,21,0,102,48,23,0,102,48,24,0,102,48,
		25,0,102,48,26,0,102,121,112,1,112,1,112,1,112,1,112,1,73,
		36,76,0,48,27,0,102,95,4,112,1,73,36,77,0,48,28,0,102,
		95,5,112,1,73,36,78,0,48,29,0,102,95,6,112,1,73,36,79,
		0,48,30,0,102,95,7,112,1,73,36,80,0,95,3,100,69,28,16,
		36,81,0,48,31,0,102,95,3,112,1,73,25,46,36,82,0,95,8,
		100,69,28,16,36,83,0,48,32,0,102,95,8,112,1,73,25,23,36,
		84,0,95,9,100,69,28,14,36,85,0,48,33,0,102,95,9,112,1,
		73,36,88,0,48,34,0,48,35,0,102,112,0,102,112,1,73,36,89,
		0,176,47,0,20,0,36,91,0,102,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( HQHTM_INIT )
{
	static const HB_BYTE pcode[] =
	{
		36,95,0,48,48,0,102,112,0,32,144,0,36,96,0,48,46,0,48,
		49,0,102,112,0,112,0,73,36,97,0,176,50,0,48,51,0,102,112,
		0,12,1,31,24,36,98,0,176,52,0,48,37,0,102,112,0,48,51,
		0,102,112,0,20,2,25,76,36,99,0,176,50,0,48,53,0,102,112,
		0,12,1,31,24,36,100,0,176,54,0,48,37,0,102,112,0,48,53,
		0,102,112,0,20,2,25,38,36,101,0,176,50,0,48,55,0,102,112,
		0,12,1,31,22,36,102,0,176,56,0,48,37,0,102,112,0,48,55,
		0,102,112,0,20,2,36,104,0,176,57,0,48,37,0,102,112,0,20,
		1,36,107,0,100,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( HQHTM_NOTIFY )
{
	static const HB_BYTE pcode[] =
	{
		13,1,1,36,110,0,176,58,0,95,1,12,1,80,2,36,112,0,48,
		59,0,102,112,0,100,8,31,18,48,60,0,48,59,0,102,112,0,102,
		95,2,112,2,31,81,36,113,0,106,6,116,112,58,47,47,0,95,2,
		24,28,8,36,114,0,121,110,7,36,116,0,176,61,0,95,2,12,1,
		28,20,36,117,0,176,54,0,48,37,0,102,112,0,95,2,20,2,25,
		29,36,119,0,176,62,0,95,2,106,15,70,105,108,101,32,110,111,116,
		32,102,111,117,110,100,0,20,2,36,123,0,176,63,0,95,1,9,20,
		2,36,124,0,121,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( QHTMFORMPROC )
{
	static const HB_BYTE pcode[] =
	{
		13,1,5,36,127,0,176,65,0,95,1,12,1,80,6,36,129,0,95,
		6,100,69,28,42,36,130,0,48,66,0,95,6,112,0,100,69,28,28,
		36,131,0,48,60,0,48,66,0,95,6,112,0,95,6,95,2,95,3,
		95,4,95,5,112,5,73,36,135,0,121,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( HQHTMBUTTON )
{
	static const HB_BYTE pcode[] =
	{
		149,3,0,116,82,0,36,139,0,103,2,0,100,8,29,34,1,176,1,
		0,104,2,0,12,1,29,23,1,166,217,0,0,122,80,1,48,2,0,
		176,3,0,12,0,106,12,72,81,104,116,109,66,117,116,116,111,110,0,
		108,68,4,1,0,108,67,112,3,80,2,36,141,0,48,69,0,95,2,
		100,106,7,66,85,84,84,79,78,0,95,1,121,72,121,72,121,72,121,
		72,106,9,119,105,110,99,108,97,115,115,0,4,1,0,9,112,5,73,
		36,142,0,48,5,0,95,2,100,100,95,1,121,72,121,72,121,72,106,
		6,99,72,116,109,108,0,4,1,0,9,112,5,73,36,144,0,48,6,
		0,95,2,106,4,78,101,119,0,108,70,95,1,121,72,121,72,121,72,
		112,3,73,36,145,0,48,6,0,95,2,106,9,82,101,100,101,102,105,
		110,101,0,108,71,95,1,121,72,121,72,121,72,112,3,73,36,146,0,
		48,6,0,95,2,106,5,73,110,105,116,0,108,72,95,1,121,72,121,
		72,121,72,112,3,73,36,148,0,48,12,0,95,2,112,0,73,167,14,
		0,0,176,13,0,104,2,0,95,2,20,2,168,48,14,0,95,2,112,
		0,80,3,176,15,0,95,3,106,10,73,110,105,116,67,108,97,115,115,
		0,12,2,28,12,48,16,0,95,3,164,146,1,0,73,95,3,110,7,
		48,14,0,103,2,0,112,0,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( HQHTMBUTTON_NEW )
{
	static const HB_BYTE pcode[] =
	{
		13,0,13,36,153,0,48,73,0,102,95,8,112,1,73,36,155,0,48,
		2,0,48,49,0,102,112,0,95,1,95,2,95,3,95,4,95,5,95,
		6,95,7,106,1,0,100,95,10,95,11,100,95,12,95,13,112,14,73,
		36,158,0,102,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( HQHTMBUTTON_REDEFINE )
{
	static const HB_BYTE pcode[] =
	{
		13,0,8,36,162,0,48,73,0,102,95,3,112,1,73,36,163,0,48,
		74,0,48,49,0,102,112,0,95,1,95,2,100,95,5,95,6,100,95,
		7,95,8,112,8,73,36,166,0,102,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( HQHTMBUTTON_INIT )
{
	static const HB_BYTE pcode[] =
	{
		36,170,0,48,46,0,48,49,0,102,112,0,112,0,73,36,171,0,48,
		75,0,102,112,0,100,8,28,49,48,75,0,48,35,0,102,112,0,112,
		0,100,8,28,34,36,172,0,176,76,0,48,37,0,48,35,0,102,112,
		0,112,0,48,40,0,102,112,0,176,77,0,92,13,12,1,20,3,36,
		174,0,176,52,0,48,37,0,102,112,0,48,78,0,102,112,0,20,2,
		36,175,0,176,79,0,48,37,0,102,112,0,20,1,36,177,0,100,110,
		7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_EXIT( FREEQHTM )
{
	static const HB_BYTE pcode[] =
	{
		36,180,0,176,81,0,20,0,36,181,0,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_INITSTATICS()
{
	static const HB_BYTE pcode[] =
	{
		117,82,0,2,0,7
	};

	hb_vmExecute( pcode, symbols );
}