@echo off
if /I "%1"=="/c" "%~dp0.\makelib.bat" %1 HB32 %2 %3 %4 %5 %6 %7 %8 %9
if /I not "%1"=="/c" "%~dp0.\makelib.bat" HB32 %1 %2 %3 %4 %5 %6 %7 %8 %9
