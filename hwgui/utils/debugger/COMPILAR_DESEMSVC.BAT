@echo off
set path=d:\hbmsvc32\bin;d:\hbmsvc32\comp\msvc\bin
set include=d:\hbmsvc32\comp\msvc\include
set lib=d:\hbmsvc32\comp\msvc\lib
set hb_compiler=msvc
hbmk2 debug.hbp -dVERSAO_DESENVOLVIMENTO -jobs=%NUMBER_OF_PROCESSORS% -rebuild
pause