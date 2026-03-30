REM SET QUERYDEBUG=S
REM SET QUERYDEBUGCOUNTER=S

SET PATH=D:\devel\msvc_2022_32\bin;d:\devel\xharbour_msvc_2022_32\bin;%PATH%
SET INCLUDE=%INCLUDE%;d:\devel\xharbour_msvc_2022_32\include;D:\devel\msvc_2022_32\include;D:\devel\msvc_2022_32\include\ucrt;D:\devel\msvc_2022_32\include;D:\devel\msvc_2022_32\include\sdk
SET LIB=%LIB%;D:\devel\msvc_2022_32\lib;d:\devel\xharbour_msvc_2022_32\lib;D:\devel\msvc_2022_32\lib\SDK
SET HB_WITH_PGSQL=D:\pg10_32bits\include
SET HB_COMPILER=msvc
SET HB_CPU=x86
SET HB_BUILD_NAME=develop
%SystemRoot%\system32\cmd.exe
