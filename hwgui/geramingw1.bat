@echo off
@setlocal
set path=\hb32fork\bin
SET HB_COMPILER=clang
hbmk2 @hwgui.hbp       -jobs=%NUMBER_OF_PROCESSORS% -rebuild
hbmk2 @procmisc.hbp    -jobs=%NUMBER_OF_PROCESSORS% -rebuild
hbmk2 @hbxml.hbp       -jobs=%NUMBER_OF_PROCESSORS% -rebuild
hbmk2 @hwg_contrib.hbp -jobs=%NUMBER_OF_PROCESSORS% -rebuild
rem hbmk2 @hwgdebug.hbp    -jobs=%NUMBER_OF_PROCESSORS% -rebuild
hbmk2 @hbactivex.hbp   -jobs=%NUMBER_OF_PROCESSORS% -rebuild
rem hbmk2 @hwguidyn.hbp    -jobs=%NUMBER_OF_PROCESSORS% -rebuild
pause