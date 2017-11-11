@echo off
@setlocal
set path=\hb32fork\bin
rem set hb_compiler=clang
hbmk2 @hwguix.hbp -jobs -rebuild
pause