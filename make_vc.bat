@echo off
if "%1" == "clean" goto CLEAN
if "%1" == "CLEAN" goto CLEAN

if not exist lib md lib
if not exist lib\vc md lib\vc
if not exist obj md obj
if not exist obj\vc md obj\vc

:BUILD

   nmake /Fmakefile.vc %1 %2 %3 > make_vc.log
   if errorlevel 1 goto BUILD_ERR

:BUILD_OK

   goto EXIT

:BUILD_ERR

   notepad make_vc.log
   goto EXIT

:CLEAN
   del lib\vc\*.lib
   del lib\vc\*.bak
   del obj\vc\*.obj
   del obj\vc\*.c
   del make_vc.log

   goto EXIT

:EXIT

