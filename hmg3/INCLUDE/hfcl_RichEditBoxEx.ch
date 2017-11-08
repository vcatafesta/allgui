
************************************
*   Extended rich edit file type   *
************************************

#define RICHEDITFILEEX_ANSI      1   // ANSI text file
#define RICHEDITFILEEX_UTF8      2   // UTF-8 text file
#define RICHEDITFILEEX_UTF16LE   3   // UTF-16 LE (little endian) text file
#define RICHEDITFILEEX_RTF       4   // RTF file
#define RICHEDITFILEEX_UTF16BE   5   // UTF-16 BE (big endian) text file

#xtranslate Ex. <w>. <c> . <p:HasNonAsciiChars,HasNonAnsiChars> => GetPropertyEx ( <"w">, <"c"> , <"p"> )
#xtranslate Ex. <w>. <c> . <p:LoadFile,SaveFile> (<arg1>,<arg2>,<arg3>) => DoMethodEx ( <"w">, <"c"> , <"p"> , <arg1> , <arg2>, <arg3> )
#xtranslate Ex. <w>. <c> . <p:LoadFile,SaveFile> (<arg1>,<arg2>) => DoMethodEx ( <"w">, <"c"> , <"p"> , <arg1> , <arg2> )
#xtranslate Ex. <w>. <c> . <p:LoadFile,SaveFile> (<arg1>) => DoMethodEx ( <"w">, <"c"> , <"p"> , <arg1> )
