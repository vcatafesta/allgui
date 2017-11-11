@echo off
set path=\hb32fork\bin
hbmk2 flashocx.hbp -rebuild -workdir=obj 
rem -dHB_STACK_MACROS
pause
