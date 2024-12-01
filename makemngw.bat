@echo off
if "%1" == "clean" goto CLEAN
if "%1" == "CLEAN" goto CLEAN

if not exist lib md lib
if not exist lib\gcc md lib\gcc
if not exist obj md obj
if not exist obj\gcc md obj\gcc

:BUILD

   rem set path=c:\softools\mingw\bin
   mingw32-make.exe -f makefile.gcc
   if errorlevel 1 goto BUILD_ERR

:BUILD_OK

   goto EXIT

:BUILD_ERR

   goto EXIT

:CLEAN
   del lib\gcc\*.a
   del lib\gcc\*.bak
   del obj\gcc\*.o
   del obj\gcc\*.c

   goto EXIT

:EXIT
