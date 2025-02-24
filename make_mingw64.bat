@echo off
if "%1" == "clean" goto CLEAN
if "%1" == "CLEAN" goto CLEAN

if not exist lib md lib
if not exist lib\win md lib\win
if not exist lib\win\mingw64 md lib\win\mingw64
if not exist obj md obj
if not exist obj\gcc64 md obj\gcc64

:BUILD

   mingw32-make.exe -f makefile.mingw64
   if errorlevel 1 goto BUILD_ERR

:BUILD_OK

   goto EXIT

:BUILD_ERR

   goto EXIT

:CLEAN
   del lib\win\mingw64\*.a
   del lib\win\mingw64\*.bak
   del obj\gcc64\*.o
   del obj\gcc64\*.c

   goto EXIT

:EXIT
