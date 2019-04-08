@echo off

echo ------------------------------------------------------------
echo Testing install on clean os
echo ------------------------------------------------------------
cmd /c %APPVEYOR_BUILD_FOLDER%\install.bat
if %errorlevel% neq 0 exit /b 3

echo ------------------------------------------------------------
echo Testing uninstall (first copy sys file to system directory)
echo ------------------------------------------------------------
copy %APPVEYOR_BUILD_FOLDER%\pl2303eol\driver\ser2pl64.sys C:\Windows\System32\drivers >nul 2>&1
if %errorlevel% neq 0 exit /b 3

cmd /c %APPVEYOR_BUILD_FOLDER%\install.bat
if %errorlevel% neq 0 exit /b 3
exit /b 0
