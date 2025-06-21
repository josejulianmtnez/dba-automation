@echo off
setlocal enabledelayedexpansion

REM Configuración
set DEFAULT_USER=postgres
set PGHOST=localhost
set PGPORT=5432
set DEFAULT_DB=mi_financiera_demo
set EXPORT_DIR=C:\exports

REM Obtener la fecha y hora en formato AAAAMMDD_HHMM
for /f "tokens=2 delims==" %%i in ('"wmic os get localdatetime /value"') do set datetime=%%i
set "EXPORT_DATE=%datetime:~0,4%%datetime:~4,2%%datetime:~6,2%_%datetime:~8,2%%datetime:~10,2%"

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

if "%choice%"=="1" goto export_txt
if "%choice%"=="2" goto expot_csv
if "%choice%"=="0" goto :exitProgram

:export_txt
cls
echo ****************************************
echo *           Exportar TXT               *
echo ****************************************
echo Listando bases de datos disponibles...
echo.
psql -U %DEFAULT_USER% -h %PGHOST% -p %PGPORT% -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;" > temp_dbs.txt
set count=0
for /f "usebackq tokens=* delims=" %%a in ("temp_dbs.txt") do (
    set "dbName=%%a"
    for /f "tokens=* delims= " %%b in ("!dbName!") do (
        if not "%%b"=="" (
            set /a count+=1
            echo !count!. %%b
            set "db!count!=%%b"
        )
    )
)
del temp_dbs.txt
if %count%==0 (
    echo No hay bases de datos disponibles.
    pause
    goto :mainMenu
)
set /p dbchoice="Selecciona una base de datos: "
set "DATABASE=!db%dbchoice%!"
echo.

echo Listando tablas disponibles en la base de datos %DATABASE%...
psql -U %DEFAULT_USER% -h %PGHOST% -p %PGPORT% -d !DATABASE! -t -c "SELECT tablename FROM pg_tables WHERE schemaname='public';" > temp_tables.txt

set count=0
for /f "usebackq tokens=* delims=" %%a in ("temp_tables.txt") do (
    set "tableName=%%a"
    for /f "tokens=* delims= " %%b in ("!tableName!") do (
        if not "%%b"=="" (
            set /a count+=1
            echo !count!. %%b
            set "table!count!=public.%%b"
        )
    )
)
del temp_tables.txt
if %count%==0 (
    echo No hay tablas disponibles.
    pause
    goto :mainMenu
)
set /p tablechoice="Selecciona la tabla a exportar: "
set "TABLE=!table%tablechoice%!"

REM Crear directorio si no existe
if not exist "%EXPORT_DIR%" (
    mkdir "%EXPORT_DIR%"
)

set "EXPORT_FILE=%EXPORT_DIR%\!DATABASE!_export_%EXPORT_DATE%.txt"


psql -U %DEFAULT_USER% -d !DATABASE! -c "COPY %TABLE% TO STDOUT WITH (FORMAT CSV, HEADER true, DELIMITER ',')" > %EXPORT_FILE%

pause
goto :mainMenu

:exitPrograme
echo Saliendo del programa...
endlocal
exit /b
