@echo off
set path=\hb32fork\bin
SET HB_COMPILER=mingw
hbmk2 @hwguix.hbp -jobs=%NUMBER_OF_PROCESSORS% -rebuild
pause