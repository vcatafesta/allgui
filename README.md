# allgui
test allgui

HMG3, HMGE, HWGUI, OOHG

HBMK2 works on XHarbour !!!
Download HBMK2 and add -xhb to command line

1) Setup Harbour/XHarbour and your C compiler

SET HB_INSTALL_PREFIX=c:\harbour
SET PATH=%PATH%;c:\harbour\bin
SET PATH=%PATH%;c:\harbour\comp\mingw
SET HB_COMPILER=mingw

2) On harbour/bin create file HBMK.HBC

libs=c:\allgui\hmg3.hbc
libs=c:\allgui\hmge.hbc
libs=c:\allgui\hwgui.hbc
libs=c:\allgui\oohg.hbc

3) Create Libraries, all or each one

cd \allgui
hbmk2 all.hbp

or

cd \allgui\hmg3
hbmk2 hmg3all.hbp
cd \allgui\hmge
hbmk2 hmgeall.hbp
cd \allgui\hwgui
hbmk2 hwguiall.hbp
cd \allgui\oohg
hbmk2 oohgall.hbp

4) To compile samples, use default or add needed libraries

cd \allgui\hmge\samples\basic
hbmk2 test.hbp hmge.hbc

cd \allgui\hwgui\samples
hbmk2 test.hbp hwgui.hbc

cd \allgui\oohg\samples
hbmk2 test.hbp oohg.hbc

if needed, add additional libraries/parameters:  -w0 -es0 -lxhb and others
