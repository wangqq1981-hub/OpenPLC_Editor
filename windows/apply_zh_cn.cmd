@echo off
setlocal EnableExtensions

REM Apply Simplified Chinese UI overrides onto an installed OpenPLC Editor.
REM Run this from the OpenPLC Editor install folder, OR pass that folder as %%1.
REM Example:
REM   apply_zh_cn.cmd
REM   apply_zh_cn.cmd "C:\Users\you\OpenPLC_Editor"

set "SCRIPT_DIR=%~dp0"
set "TARGET=%~1"
if "%TARGET%"=="" set "TARGET=%CD%"

if not exist "%TARGET%\editor\Beremiz.py" (
  echo ERROR: OpenPLC Editor not found in:
  echo   %TARGET%
  echo.
  echo Expected to find: editor\Beremiz.py
  echo Install official OpenPLC Editor first, then run this script again.
  exit /b 1
)

if not exist "%SCRIPT_DIR%i18n\zh_CN\LC_MESSAGES\Beremiz.mo" (
  echo ERROR: Package files missing next to this script.
  exit /b 1
)

echo Applying zh_CN UI package to:
echo   %TARGET%
echo.

if not exist "%TARGET%\editor\i18n\" mkdir "%TARGET%\editor\i18n"
if not exist "%TARGET%\editor\locale\zh_CN\LC_MESSAGES\" mkdir "%TARGET%\editor\locale\zh_CN\LC_MESSAGES"

copy /Y "%SCRIPT_DIR%i18n\zh_CN\Beremiz_zh_CN.po" "%TARGET%\editor\i18n\Beremiz_zh_CN.po" >nul
copy /Y "%SCRIPT_DIR%i18n\zh_CN\LC_MESSAGES\Beremiz.mo" "%TARGET%\editor\locale\zh_CN\LC_MESSAGES\Beremiz.mo" >nul
copy /Y "%SCRIPT_DIR%editor_overrides\BeremizIDE.py" "%TARGET%\editor\BeremizIDE.py" >nul
copy /Y "%SCRIPT_DIR%editor_overrides\IDEFrame.py" "%TARGET%\editor\IDEFrame.py" >nul

echo Done.
echo.
echo Next steps:
echo   1. Set Windows display language to Chinese ^(Simplified^), or use a zh-CN locale.
echo   2. Restart OpenPLC Editor.
echo   3. Confirm File menu shows "教程与示例" and no "Check for updates...".
exit /b 0
