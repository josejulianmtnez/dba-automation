@echo off
setlocal enabledelayedexpansion

REM ===========================================================
REM        Script para ver usuarios y sus privilegios
REM ===========================================================

REM Configuración por defecto
set PGHOST=localhost
set PGPORT=5432
set DEFAULT_DB=mi_financiera_demo
set DEFAULT_USER=postgres

REM Menú principal
:mainMenu
cls
echo ***************************
echo *    Ver usuarios de PostgreSQL    *
echo ***************************

REM 
set /p PGUSER="Ingresa el nombre de usuario de PostgreSQL [por defecto: %DEFAULT_USER%]: "
if "%PGUSER%"=="" set PGUSER=%DEFAULT_USER%

REM 
echo.
echo ============================================
echo   Usuarios y privilegios en PostgreSQL
echo ============================================
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %DEFAULT_DB% -c "\du"

echo.
pause
endlocal
exit /b