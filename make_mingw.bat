@echo off
if "%1" == "clean" goto CLEAN
if "%1" == "CLEAN" goto CLEAN

if not exist lib md lib
if not exist lib\win md lib\win
if not exist lib\win\mingw md lib\win\mingw
if not exist obj md obj
if not exist obj\gcc md obj\gcc

:BUILD

   rem set path=c:\softools\mingw\bin
   mingw32-make.exe -f makefile.mingw > make_mingw.log
   if errorlevel 1 goto BUILD_ERR

:BUILD_OK

   goto EXIT

:BUILD_ERR

   notepad make_mingw.log
   goto EXIT

:CLEAN
   del lib\win\mingw\*.a
   del lib\win\mingw\*.bak
   del obj\gcc\*.o
   del obj\gcc\*.c
   del make_mingw.log

   goto EXIT

:EXIT
