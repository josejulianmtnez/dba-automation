@echo off
setlocal enabledelayedexpansion

REM Configuración
set PGUSER=postgres
set PGHOST=localhost
set PGPORT=5432
set DEFAULT_DB=mi_financiera_demo

:mainMenu
cls
echo ****************************************
echo *           Exportar Script            *
echo ****************************************
echo 1. Exportar en TXT
echo 2. Exportar en CSV
echo 0. Salir
echo ****************************************
set /p choice="Selecciona una opcion: "

if "%choice%"=="1" call backup_database.bat
if "%choice%"=="2" call restore_database.bat
if "%choice%"=="0" goto :exitProgram
