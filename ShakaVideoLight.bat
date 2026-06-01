@echo off
set "TARGET=%~1"
if "%TARGET%"=="" set "TARGET=%cd%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0ShakaVideoLight.ps1" -Target "%TARGET%"
pause