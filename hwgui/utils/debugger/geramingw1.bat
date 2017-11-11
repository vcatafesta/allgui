@echo off
set path=\hb32fork\bin
SET HB_COMPILER=mingw

hbmk2 hwgdebug.hbp -jobs=%NUMBER_OF_PROCESSORS% -rebuild

pause