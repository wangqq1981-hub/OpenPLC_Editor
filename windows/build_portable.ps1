# Build a portable OpenPLC Editor folder for Windows (zh_CN fork).
# Run on Windows (GitHub Actions windows-latest or a local Windows machine).
param(
    [string]$OutDir = "dist/OpenPLC_Editor",
    [string]$PythonVersion = "3.9.13"
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $Root

Write-Host "==> Building portable OpenPLC Editor from $Root"

# Ensure submodules exist
if (-not (Test-Path "editor/Beremiz.py")) {
    git submodule update --init --recursive
}

# Apply zh_CN overlays + menu patch (Git Bash / WSL-less fallback in PowerShell)
Write-Host "==> Applying zh_CN overrides"
New-Item -ItemType Directory -Force -Path "editor/i18n" | Out-Null
New-Item -ItemType Directory -Force -Path "editor/locale/zh_CN/LC_MESSAGES" | Out-Null
Copy-Item "i18n/zh_CN/Beremiz_zh_CN.po" "editor/i18n/Beremiz_zh_CN.po" -Force
Copy-Item "i18n/zh_CN/LC_MESSAGES/Beremiz.mo" "editor/locale/zh_CN/LC_MESSAGES/Beremiz.mo" -Force

if (Select-String -Path "editor/BeremizIDE.py" -Pattern "Check for updates" -Quiet) {
    if (Get-Command patch -ErrorAction SilentlyContinue) {
        Get-Content "patches/0001-remove-check-for-updates.patch" | patch -p1 --forward
    } else {
        Copy-Item "windows/editor_overrides/BeremizIDE.py" "editor/BeremizIDE.py" -Force
        Copy-Item "windows/editor_overrides/IDEFrame.py" "editor/IDEFrame.py" -Force
    }
}

if (Test-Path $OutDir) { Remove-Item -Recurse -Force $OutDir }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
New-Item -ItemType Directory -Force -Path "$OutDir/python" | Out-Null
New-Item -ItemType Directory -Force -Path "$OutDir/matiec" | Out-Null

# Embeddable CPython
$PyZip = Join-Path $env:TEMP "python-$PythonVersion-embed-amd64.zip"
$PyUrl = "https://www.python.org/ftp/python/$PythonVersion/python-$PythonVersion-embed-amd64.zip"
Write-Host "==> Downloading embeddable Python $PythonVersion"
Invoke-WebRequest -Uri $PyUrl -OutFile $PyZip
Expand-Archive -Path $PyZip -DestinationPath "$OutDir/python" -Force

# Enable site-packages in embeddable Python
$Pth = Get-ChildItem "$OutDir/python/python*._pth" | Select-Object -First 1
(Get-Content $Pth.FullName) `
    -replace '#import site', 'import site' `
    | Set-Content $Pth.FullName
Add-Content $Pth.FullName "Lib\site-packages"

# Install pip into embeddable Python
$GetPip = Join-Path $env:TEMP "get-pip.py"
Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile $GetPip
& "$OutDir/python/python.exe" $GetPip --no-warn-script-location

$Py = "$OutDir/python/python.exe"
Write-Host "==> Installing Python dependencies"
& $Py -m pip install --upgrade pip wheel setuptools
# Match Linux install.sh runtime set + wxPython Windows wheel
& $Py -m pip install `
    "wxPython==4.2.1" `
    "jinja2" `
    "lxml==4.9.2" `
    "future" `
    "matplotlib" `
    "zeroconf" `
    "pyserial" `
    "pypubsub" `
    "Pyro5" `
    "attrdict3"

Write-Host "==> Copying editor and matiec"
robocopy "editor" "$OutDir/editor" /E /XD .git __pycache__ tests doc .github /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy editor failed: $LASTEXITCODE" }

robocopy "matiec/lib" "$OutDir/matiec/lib" /E /XD .git __pycache__ /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy matiec/lib failed: $LASTEXITCODE" }

Copy-Item "revision" "$OutDir/revision" -Force
Copy-Item "LICENSE" "$OutDir/LICENSE" -Force -ErrorAction SilentlyContinue

# Launcher matching official style
$Bat = @"
@echo off
cd /d "%~dp0"
set "LANG=zh_CN.UTF-8"
set "LC_ALL=zh_CN.UTF-8"
set "LANGUAGE=zh_CN"
echo Starting OpenPLC Editor (zh_CN)...
".\python\pythonw.exe" ".\editor\Beremiz.py"
if errorlevel 1 (
  echo.
  echo Failed to start. Trying console mode for error output...
  ".\python\python.exe" ".\editor\Beremiz.py"
  pause
)
"@
Set-Content -Path "$OutDir/OpenPLC Editor.bat" -Value $Bat -Encoding ASCII

$Readme = @"
OpenPLC Editor - Portable Windows build (zh_CN)
================================================

This is a community portable build from fork wangqq1981-hub/OpenPLC_Editor
with completed Simplified Chinese UI and without File > Check for updates.

How to run
----------
1. Extract this folder anywhere (path without non-ASCII characters preferred).
2. Double-click "OpenPLC Editor.bat".
3. For Chinese UI, set Windows display language to 中文(简体).

Notes
-----
- Arduino board cores are downloaded on first compile for that board.
- Full PLC native toolchain (mingw) from the official Autonomy package is
  not fully redistributed here. UI editing works; some compile targets may
  need the official mingw folder copied into this directory as mingw\bin.
"@
Set-Content -Path "$OutDir/README.txt" -Value $Readme -Encoding UTF8

Write-Host "==> Portable folder ready: $OutDir"
Get-ChildItem $OutDir | Format-Table Name, Mode
