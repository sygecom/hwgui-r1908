@echo off
if "%1" == "clean" goto CLEAN
if "%1" == "CLEAN" goto CLEAN

if not exist lib md lib
if not exist lib\win md lib\win
if not exist lib\win\clang md lib\win\clang
if not exist obj md obj
if not exist obj\cl md obj\cl

:BUILD

   mingw32-make.exe -f makefile.clang > make_clang.log
   if errorlevel 1 goto BUILD_ERR

:BUILD_OK

   goto EXIT

:BUILD_ERR

   notepad make_clang.log
   goto EXIT

:CLEAN
   del lib\win\clang\*.a
   del lib\win\clang\*.bak
   del obj\*.o
   del obj\*.c
   del make_clang.log

   goto EXIT

:EXIT
