@echo off
if "%1" == "clean" goto CLEAN
if "%1" == "CLEAN" goto CLEAN

if not exist lib md lib
if not exist lib\win md lib\win
if not exist lib\win\clang64 md lib\win\clang64
if not exist obj md obj
if not exist obj\cl64 md obj\cl64

:BUILD

   mingw32-make.exe -f makefile.clang64
   if errorlevel 1 goto BUILD_ERR

:BUILD_OK

   goto EXIT

:BUILD_ERR

   goto EXIT

:CLEAN
   del lib\win\clang64\*.a
   del lib\win\clang64\*.bak
   del obj\*.o
   del obj\*.c

   goto EXIT

:EXIT
