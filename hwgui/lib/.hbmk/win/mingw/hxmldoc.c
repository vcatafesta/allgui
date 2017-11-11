/* C source generated by Harbour */

#include "hbvmpub.h"
#include "hbinit.h"

HB_FUNC( HXMLNODE );
HB_FUNC_EXTERN( __CLSLOCKDEF );
HB_FUNC_EXTERN( HBCLASS );
HB_FUNC_EXTERN( HBOBJECT );
HB_FUNC_STATIC( HXMLNODE_NEW );
HB_FUNC_STATIC( HXMLNODE_ADD );
HB_FUNC_STATIC( HXMLNODE_GETATTRIBUTE );
HB_FUNC_STATIC( HXMLNODE_SETATTRIBUTE );
HB_FUNC_STATIC( HXMLNODE_DELATTRIBUTE );
HB_FUNC_STATIC( HXMLNODE_SAVE );
HB_FUNC_STATIC( HXMLNODE_FIND );
HB_FUNC_EXTERN( __CLSUNLOCKDEF );
HB_FUNC_EXTERN( __OBJHASMSG );
HB_FUNC_EXTERN( AADD );
HB_FUNC_EXTERN( ASCAN );
HB_FUNC_EXTERN( ADEL );
HB_FUNC_EXTERN( ASIZE );
HB_FUNC_EXTERN( LEN );
HB_FUNC_EXTERN( SPACE );
HB_FUNC_EXTERN( __MVEXIST );
HB_FUNC_EXTERN( __MVPRIVATE );
HB_FUNC_EXTERN( __MVPUT );
HB_FUNC_EXTERN( HBXML_TRANSFORM );
HB_FUNC_EXTERN( EMPTY );
HB_FUNC_EXTERN( VALTYPE );
HB_FUNC_EXTERN( FWRITE );
HB_FUNC( HXMLDOC );
HB_FUNC_STATIC( HXMLDOC_NEW );
HB_FUNC_STATIC( HXMLDOC_READ );
HB_FUNC_STATIC( HXMLDOC_SAVE );
HB_FUNC_EXTERN( FOPEN );
HB_FUNC_EXTERN( HBXML_GETDOC );
HB_FUNC_EXTERN( FCLOSE );
HB_FUNC_EXTERN( FCREATE );
HB_FUNC_INITSTATICS();

HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_HXMLDOC )
{ "HXMLNODE", { HB_FS_PUBLIC | HB_FS_FIRST | HB_FS_LOCAL }, { HB_FUNCNAME( HXMLNODE ) }, NULL },
{ "__CLSLOCKDEF", { HB_FS_PUBLIC }, { HB_FUNCNAME( __CLSLOCKDEF ) }, NULL },
{ "NEW", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "HBCLASS", { HB_FS_PUBLIC }, { HB_FUNCNAME( HBCLASS ) }, NULL },
{ "HBOBJECT", { HB_FS_PUBLIC }, { HB_FUNCNAME( HBOBJECT ) }, NULL },
{ "ADDMULTICLSDATA", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "ADDMULTIDATA", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "ADDMETHOD", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "HXMLNODE_NEW", { HB_FS_STATIC | HB_FS_LOCAL }, { HB_FUNCNAME( HXMLNODE_NEW ) }, NULL },
{ "HXMLNODE_ADD", { HB_FS_STATIC | HB_FS_LOCAL }, { HB_FUNCNAME( HXMLNODE_ADD ) }, NULL },
{ "HXMLNODE_GETATTRIBUTE", { HB_FS_STATIC | HB_FS_LOCAL }, { HB_FUNCNAME( HXMLNODE_GETATTRIBUTE ) }, NULL },
{ "HXMLNODE_SETATTRIBUTE", { HB_FS_STATIC | HB_FS_LOCAL }, { HB_FUNCNAME( HXMLNODE_SETATTRIBUTE ) }, NULL },
{ "HXMLNODE_DELATTRIBUTE", { HB_FS_STATIC | HB_FS_LOCAL }, { HB_FUNCNAME( HXMLNODE_DELATTRIBUTE ) }, NULL },
{ "HXMLNODE_SAVE", { HB_FS_STATIC | HB_FS_LOCAL }, { HB_FUNCNAME( HXMLNODE_SAVE ) }, NULL },
{ "HXMLNODE_FIND", { HB_FS_STATIC | HB_FS_LOCAL }, { HB_FUNCNAME( HXMLNODE_FIND ) }, NULL },
{ "CREATE", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "__CLSUNLOCKDEF", { HB_FS_PUBLIC }, { HB_FUNCNAME( __CLSUNLOCKDEF ) }, NULL },
{ "INSTANCE", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "__OBJHASMSG", { HB_FS_PUBLIC }, { HB_FUNCNAME( __OBJHASMSG ) }, NULL },
{ "INITCLASS", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "_TITLE", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "_AATTR", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "_TYPE", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "ADD", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "AADD", { HB_FS_PUBLIC }, { HB_FUNCNAME( AADD ) }, NULL },
{ "AITEMS", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "ASCAN", { HB_FS_PUBLIC }, { HB_FUNCNAME( ASCAN ) }, NULL },
{ "AATTR", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "ADEL", { HB_FS_PUBLIC }, { HB_FUNCNAME( ADEL ) }, NULL },
{ "ASIZE", { HB_FS_PUBLIC }, { HB_FUNCNAME( ASIZE ) }, NULL },
{ "LEN", { HB_FS_PUBLIC }, { HB_FUNCNAME( LEN ) }, NULL },
{ "SPACE", { HB_FS_PUBLIC }, { HB_FUNCNAME( SPACE ) }, NULL },
{ "__MVEXIST", { HB_FS_PUBLIC }, { HB_FUNCNAME( __MVEXIST ) }, NULL },
{ "__MVPRIVATE", { HB_FS_PUBLIC }, { HB_FUNCNAME( __MVPRIVATE ) }, NULL },
{ "__MVPUT", { HB_FS_PUBLIC }, { HB_FUNCNAME( __MVPUT ) }, NULL },
{ "HXML_NEWLINE", { HB_FS_PUBLIC | HB_FS_MEMVAR }, { NULL }, NULL },
{ "TYPE", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "TITLE", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "HBXML_TRANSFORM", { HB_FS_PUBLIC }, { HB_FUNCNAME( HBXML_TRANSFORM ) }, NULL },
{ "EMPTY", { HB_FS_PUBLIC }, { HB_FUNCNAME( EMPTY ) }, NULL },
{ "VALTYPE", { HB_FS_PUBLIC }, { HB_FUNCNAME( VALTYPE ) }, NULL },
{ "FWRITE", { HB_FS_PUBLIC }, { HB_FUNCNAME( FWRITE ) }, NULL },
{ "SAVE", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "EVAL", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "HXMLDOC", { HB_FS_PUBLIC | HB_FS_LOCAL }, { HB_FUNCNAME( HXMLDOC ) }, NULL },
{ "HXMLDOC_NEW", { HB_FS_STATIC | HB_FS_LOCAL }, { HB_FUNCNAME( HXMLDOC_NEW ) }, NULL },
{ "HXMLDOC_READ", { HB_FS_STATIC | HB_FS_LOCAL }, { HB_FUNCNAME( HXMLDOC_READ ) }, NULL },
{ "ADDINLINE", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "READ", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "HXMLDOC_SAVE", { HB_FS_STATIC | HB_FS_LOCAL }, { HB_FUNCNAME( HXMLDOC_SAVE ) }, NULL },
{ "FOPEN", { HB_FS_PUBLIC }, { HB_FUNCNAME( FOPEN ) }, NULL },
{ "_NLASTERR", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "HBXML_GETDOC", { HB_FS_PUBLIC }, { HB_FUNCNAME( HBXML_GETDOC ) }, NULL },
{ "FCLOSE", { HB_FS_PUBLIC }, { HB_FUNCNAME( FCLOSE ) }, NULL },
{ "NLASTERR", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "FCREATE", { HB_FS_PUBLIC }, { HB_FUNCNAME( FCREATE ) }, NULL },
{ "GETATTRIBUTE", { HB_FS_PUBLIC | HB_FS_MESSAGE }, { NULL }, NULL },
{ "(_INITSTATICS00002)", { HB_FS_INITEXIT | HB_FS_LOCAL }, { hb_INITSTATICS }, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_HXMLDOC, "", 0x0, 0x0003 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_HXMLDOC
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_HXMLDOC )
   #include "hbiniseg.h"
#endif

HB_FUNC( HXMLNODE )
{
	static const HB_BYTE pcode[] =
	{
		149,3,0,116,57,0,36,20,0,103,1,0,100,8,29,35,2,176,1,
		0,104,1,0,12,1,29,24,2,166,218,1,0,122,80,1,48,2,0,
		176,3,0,12,0,106,9,72,88,77,76,78,111,100,101,0,108,4,4,
		1,0,108,0,112,3,80,2,36,22,0,48,5,0,95,2,100,100,95,
		1,121,72,92,32,72,121,72,121,72,106,9,110,76,97,115,116,69,114,
		114,0,4,1,0,9,112,5,73,36,23,0,48,6,0,95,2,100,100,
		95,1,121,72,121,72,121,72,106,6,116,105,116,108,101,0,4,1,0,
		9,112,5,73,36,24,0,48,6,0,95,2,100,100,95,1,121,72,121,
		72,121,72,106,5,116,121,112,101,0,4,1,0,9,112,5,73,36,25,
		0,48,6,0,95,2,100,4,0,0,95,1,121,72,121,72,121,72,106,
		7,97,73,116,101,109,115,0,4,1,0,9,112,5,73,36,26,0,48,
		6,0,95,2,100,4,0,0,95,1,121,72,121,72,121,72,106,6,97,
		65,116,116,114,0,4,1,0,9,112,5,73,36,27,0,48,6,0,95,
		2,100,100,95,1,121,72,121,72,121,72,106,6,99,97,114,103,111,0,
		4,1,0,9,112,5,73,36,29,0,48,7,0,95,2,106,4,78,101,
		119,0,108,8,95,1,121,72,121,72,121,72,112,3,73,36,30,0,48,
		7,0,95,2,106,4,65,100,100,0,108,9,95,1,121,72,121,72,121,
		72,112,3,73,36,31,0,48,7,0,95,2,106,13,71,101,116,65,116,
		116,114,105,98,117,116,101,0,108,10,95,1,121,72,121,72,121,72,112,
		3,73,36,32,0,48,7,0,95,2,106,13,83,101,116,65,116,116,114,
		105,98,117,116,101,0,108,11,95,1,121,72,121,72,121,72,112,3,73,
		36,33,0,48,7,0,95,2,106,13,68,101,108,65,116,116,114,105,98,
		117,116,101,0,108,12,95,1,121,72,121,72,121,72,112,3,73,36,34,
		0,48,7,0,95,2,106,5,83,97,118,101,0,108,13,95,1,121,72,
		121,72,121,72,112,3,73,36,35,0,48,7,0,95,2,106,5,70,105,
		110,100,0,108,14,95,1,121,72,121,72,121,72,112,3,73,36,36,0,
		48,15,0,95,2,112,0,73,167,14,0,0,176,16,0,104,1,0,95,
		2,20,2,168,48,17,0,95,2,112,0,80,3,176,18,0,95,3,106,
		10,73,110,105,116,67,108,97,115,115,0,12,2,28,12,48,19,0,95,
		3,164,146,1,0,73,95,3,110,7,48,17,0,103,1,0,112,0,110,
		7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( HXMLNODE_NEW )
{
	static const HB_BYTE pcode[] =
	{
		13,0,4,36,40,0,95,1,100,69,28,11,48,20,0,102,95,1,112,
		1,73,36,41,0,95,3,100,69,28,11,48,21,0,102,95,3,112,1,
		73,36,42,0,48,22,0,102,95,2,100,69,28,6,95,2,25,3,121,
		112,1,73,36,43,0,95,4,100,69,28,14,36,44,0,48,23,0,102,
		95,4,112,1,73,36,46,0,102,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( HXMLNODE_ADD )
{
	static const HB_BYTE pcode[] =
	{
		13,0,1,36,50,0,176,24,0,48,25,0,102,112,0,95,1,20,2,
		36,51,0,95,1,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( HXMLNODE_GETATTRIBUTE )
{
	static const HB_BYTE pcode[] =
	{
		13,1,1,36,54,0,176,26,0,48,27,0,102,112,0,89,17,0,1,
		0,1,0,1,0,95,1,122,1,95,255,8,6,12,2,80,2,36,56,
		0,95,2,121,8,28,5,100,25,14,48,27,0,102,112,0,95,2,1,
		92,2,1,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( HXMLNODE_SETATTRIBUTE )
{
	static const HB_BYTE pcode[] =
	{
		13,1,2,36,59,0,176,26,0,48,27,0,102,112,0,89,17,0,1,
		0,1,0,1,0,95,1,122,1,95,255,8,6,12,2,80,3,36,61,
		0,95,3,121,8,28,25,36,62,0,176,24,0,48,27,0,102,112,0,
		95,1,95,2,4,2,0,20,2,25,19,36,64,0,95,2,48,27,0,
		102,112,0,95,3,1,92,2,2,36,67,0,120,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( HXMLNODE_DELATTRIBUTE )
{
	static const HB_BYTE pcode[] =
	{
		13,1,1,36,70,0,176,26,0,48,27,0,102,112,0,89,17,0,1,
		0,1,0,1,0,95,1,122,1,95,255,8,6,12,2,80,2,36,72,
		0,95,2,121,69,28,45,36,73,0,176,28,0,48,27,0,102,112,0,
		95,2,20,2,36,74,0,176,29,0,48,27,0,102,112,0,176,30,0,
		48,27,0,102,112,0,12,1,122,49,20,2,36,76,0,120,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( HXMLNODE_SAVE )
{
	static const HB_BYTE pcode[] =
	{
		13,3,2,36,79,0,176,31,0,95,2,92,2,65,12,1,106,2,60,
		0,72,80,4,36,81,0,176,32,0,106,13,72,88,77,76,95,78,69,
		87,76,73,78,69,0,12,1,31,49,36,82,0,176,33,0,106,13,72,
		88,77,76,95,78,69,87,76,73,78,69,0,20,1,36,83,0,176,34,
		0,106,13,72,88,77,76,95,78,69,87,76,73,78,69,0,120,20,2,
		36,85,0,98,35,0,80,5,36,86,0,48,36,0,102,112,0,92,2,
		8,28,17,36,87,0,96,4,0,106,4,33,45,45,0,135,25,83,36,
		88,0,48,36,0,102,112,0,92,3,8,28,22,36,89,0,96,4,0,
		106,9,33,91,67,68,65,84,65,91,0,135,25,49,36,90,0,48,36,
		0,102,112,0,92,4,8,28,22,36,91,0,96,4,0,106,2,63,0,
		48,37,0,102,112,0,72,135,25,15,36,93,0,96,4,0,48,37,0,
		102,112,0,135,36,95,0,48,36,0,102,112,0,121,8,31,12,48,36,
		0,102,112,0,122,8,28,83,36,96,0,122,165,80,3,25,60,36,97,
		0,96,4,0,106,2,32,0,48,27,0,102,112,0,95,3,1,122,1,
		72,106,3,61,34,0,72,176,38,0,48,27,0,102,112,0,95,3,1,
		92,2,1,12,1,72,106,2,34,0,72,135,36,96,0,175,3,0,176,
		30,0,48,27,0,102,112,0,12,1,15,28,186,36,100,0,48,36,0,
		102,112,0,92,4,8,28,25,36,101,0,96,4,0,106,4,63,62,10,
		0,135,36,102,0,120,81,35,0,26,173,0,36,103,0,48,36,0,102,
		112,0,122,8,28,25,36,104,0,96,4,0,106,4,47,62,10,0,135,
		36,105,0,120,81,35,0,26,137,0,36,106,0,48,36,0,102,112,0,
		121,8,28,123,36,107,0,96,4,0,106,2,62,0,135,36,109,0,176,
		39,0,48,25,0,102,112,0,12,1,31,63,176,30,0,48,25,0,102,
		112,0,12,1,122,8,28,60,176,40,0,48,25,0,102,112,0,122,1,
		12,1,106,2,67,0,8,28,40,176,30,0,48,25,0,102,112,0,122,
		1,12,1,176,30,0,95,4,12,1,72,92,80,35,28,14,36,110,0,
		9,165,81,35,0,80,5,25,23,36,112,0,96,4,0,106,2,10,0,
		135,36,113,0,120,165,81,35,0,80,5,36,116,0,95,1,121,16,28,
		14,36,117,0,176,41,0,95,1,95,4,20,2,36,120,0,122,165,80,
		3,26,254,0,36,121,0,176,40,0,48,25,0,102,112,0,95,3,1,
		12,1,106,2,67,0,8,29,196,0,36,122,0,95,1,121,16,28,95,
		36,123,0,48,36,0,102,112,0,92,3,8,31,13,48,36,0,102,112,
		0,92,2,8,28,23,36,124,0,176,41,0,95,1,48,25,0,102,112,
		0,95,3,1,20,2,25,26,36,126,0,176,41,0,95,1,176,38,0,
		48,25,0,102,112,0,95,3,1,12,1,20,2,36,128,0,95,5,28,
		100,36,129,0,176,41,0,95,1,106,2,10,0,20,2,25,84,36,132,
		0,48,36,0,102,112,0,92,3,8,31,13,48,36,0,102,112,0,92,
		2,8,28,20,36,133,0,96,4,0,48,25,0,102,112,0,95,3,1,
		135,25,23,36,135,0,96,4,0,176,38,0,48,25,0,102,112,0,95,
		3,1,12,1,135,36,137,0,95,5,28,13,36,138,0,96,4,0,106,
		2,10,0,135,36,141,0,9,81,35,0,25,29,36,143,0,96,4,0,
		48,42,0,48,25,0,102,112,0,95,3,1,95,1,95,2,122,72,112,
		2,135,36,120,0,175,3,0,176,30,0,48,25,0,102,112,0,12,1,
		15,29,249,254,36,146,0,120,81,35,0,36,147,0,95,1,121,16,29,
		140,0,36,148,0,48,36,0,102,112,0,121,8,28,57,36,149,0,176,
		41,0,95,1,95,5,28,14,176,31,0,95,2,92,2,65,12,1,25,
		5,106,1,0,106,3,60,47,0,72,48,37,0,102,112,0,72,106,2,
		62,0,72,106,2,10,0,72,20,2,26,201,0,36,150,0,48,36,0,
		102,112,0,92,3,8,28,22,36,151,0,176,41,0,95,1,106,5,93,
		93,62,10,0,20,2,26,167,0,36,152,0,48,36,0,102,112,0,92,
		2,8,29,152,0,36,153,0,176,41,0,95,1,106,5,45,45,62,10,
		0,20,2,26,132,0,36,156,0,48,36,0,102,112,0,121,8,28,53,
		36,157,0,96,4,0,95,5,28,14,176,31,0,95,2,92,2,65,12,
		1,25,5,106,1,0,106,3,60,47,0,72,48,37,0,102,112,0,72,
		106,2,62,0,72,106,2,10,0,72,135,25,60,36,158,0,48,36,0,
		102,112,0,92,3,8,28,18,36,159,0,96,4,0,106,5,93,93,62,
		10,0,135,25,30,36,160,0,48,36,0,102,112,0,92,2,8,28,16,
		36,161,0,96,4,0,106,5,45,45,62,10,0,135,36,163,0,95,4,
		110,7,36,165,0,106,1,0,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( HXMLNODE_FIND )
{
	static const HB_BYTE pcode[] =
	{
		13,1,3,36,170,0,95,2,100,8,28,8,36,171,0,122,80,2,36,
		174,0,176,26,0,48,25,0,102,112,0,89,36,0,1,0,1,0,1,
		0,176,40,0,95,1,12,1,106,2,67,0,69,21,28,13,73,48,37,
		0,95,1,112,0,95,255,8,6,95,2,12,3,80,4,36,175,0,95,
		4,121,8,31,61,36,178,0,95,4,80,2,36,179,0,95,3,100,8,
		31,20,48,43,0,95,3,48,25,0,102,112,0,95,4,1,112,1,28,
		16,36,180,0,48,25,0,102,112,0,95,4,1,110,7,36,182,0,174,
		2,0,36,184,0,25,136,36,187,0,100,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC( HXMLDOC )
{
	static const HB_BYTE pcode[] =
	{
		149,3,0,116,57,0,36,195,0,103,2,0,100,8,29,45,1,176,1,
		0,104,2,0,12,1,29,34,1,166,228,0,0,122,80,1,48,2,0,
		176,3,0,12,0,106,8,72,88,77,76,68,111,99,0,108,0,4,1,
		0,108,44,112,3,80,2,36,197,0,48,7,0,95,2,106,4,78,101,
		119,0,108,45,95,1,121,72,121,72,121,72,112,3,73,36,198,0,48,
		7,0,95,2,106,5,82,101,97,100,0,108,46,95,1,121,72,121,72,
		121,72,112,3,73,36,199,0,48,47,0,95,2,106,11,82,101,97,100,
		83,116,114,105,110,103,0,89,18,0,2,0,0,0,48,48,0,95,1,
		100,95,2,112,2,6,95,1,121,72,121,72,121,72,112,3,73,36,200,
		0,48,7,0,95,2,106,5,83,97,118,101,0,108,49,95,1,121,72,
		121,72,121,72,112,3,73,36,201,0,48,47,0,95,2,106,12,83,97,
		118,101,50,83,116,114,105,110,103,0,89,15,0,1,0,0,0,48,42,
		0,95,1,112,0,6,95,1,121,72,121,72,121,72,112,3,73,36,202,
		0,48,15,0,95,2,112,0,73,167,14,0,0,176,16,0,104,2,0,
		95,2,20,2,168,48,17,0,95,2,112,0,80,3,176,18,0,95,3,
		106,10,73,110,105,116,67,108,97,115,115,0,12,2,28,12,48,19,0,
		95,3,164,146,1,0,73,95,3,110,7,48,17,0,103,2,0,112,0,
		110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( HXMLDOC_NEW )
{
	static const HB_BYTE pcode[] =
	{
		13,0,1,36,206,0,95,1,100,69,28,65,36,207,0,176,24,0,48,
		27,0,102,112,0,106,8,118,101,114,115,105,111,110,0,106,4,49,46,
		48,0,4,2,0,20,2,36,208,0,176,24,0,48,27,0,102,112,0,
		106,9,101,110,99,111,100,105,110,103,0,95,1,4,2,0,20,2,36,
		211,0,102,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( HXMLDOC_READ )
{
	static const HB_BYTE pcode[] =
	{
		13,1,2,36,216,0,95,1,100,69,28,66,36,217,0,176,50,0,95,
		1,121,12,2,80,3,36,218,0,48,51,0,102,121,112,1,73,36,219,
		0,95,3,92,255,69,28,67,36,220,0,48,51,0,102,176,52,0,102,
		95,3,12,2,112,1,73,36,221,0,176,53,0,95,3,20,1,25,37,
		36,223,0,95,2,100,69,28,22,36,224,0,48,51,0,102,176,52,0,
		102,95,2,12,2,112,1,73,25,8,36,226,0,100,110,7,36,228,0,
		48,54,0,102,112,0,121,8,28,5,102,25,3,100,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_STATIC( HXMLDOC_SAVE )
{
	static const HB_BYTE pcode[] =
	{
		13,4,2,36,231,0,92,254,80,3,36,234,0,95,1,100,69,28,14,
		36,235,0,176,55,0,95,1,12,1,80,3,36,237,0,95,3,92,255,
		69,29,221,0,36,238,0,95,2,100,8,31,6,95,2,31,118,36,239,
		0,48,56,0,102,106,9,101,110,99,111,100,105,110,103,0,112,1,165,
		80,4,100,8,28,15,36,240,0,106,6,85,84,70,45,56,0,80,4,
		36,242,0,106,31,60,63,120,109,108,32,118,101,114,115,105,111,110,61,
		34,49,46,48,34,32,101,110,99,111,100,105,110,103,61,34,0,95,4,
		72,106,4,34,63,62,0,72,106,2,10,0,72,80,6,36,243,0,95,
		1,100,69,28,24,36,244,0,176,41,0,95,3,95,6,20,2,25,10,
		36,247,0,106,1,0,80,6,36,249,0,122,165,80,5,25,32,36,250,
		0,96,6,0,48,42,0,48,25,0,102,112,0,95,5,1,95,3,121,
		112,2,135,36,249,0,175,5,0,176,30,0,48,25,0,102,112,0,12,
		1,15,28,214,36,252,0,95,1,100,69,28,14,36,253,0,176,53,0,
		95,3,20,1,25,9,36,255,0,95,6,110,7,36,2,1,120,110,7
	};

	hb_vmExecute( pcode, symbols );
}

HB_FUNC_INITSTATICS()
{
	static const HB_BYTE pcode[] =
	{
		117,57,0,2,0,7
	};

	hb_vmExecute( pcode, symbols );
}