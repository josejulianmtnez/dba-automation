@echo off
setlocal enabledelayedexpansion

REM Configuración
set PGUSER=postgres
set PGHOST=localhost
set PGPORT=5432
set DEFAULT_DB=mi_financiera_demo
set EXPORT_DIR=C:\PostgresExports

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
echo 3. Exportar en JSON
echo 4. Exportar en XML
echo 0. Salir
echo ****************************************
set /p choice="Selecciona una opcion: "

if "%choice%"=="3" goto export_json
if "%choice%"=="4" goto export_xml
if "%choice%"=="0" goto exitProgram
goto mainMenu

:select_database
cls
echo Bases de datos disponibles:
set countdb=0
for /f "tokens=1 delims=|" %%a in ('psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -lqt') do (
    set /a countdb+=1
    set "db!countdb!=%%a"
    echo !countdb!. %%a
)
if %countdb%==0 (
    echo No hay bases de datos disponibles.
    pause
    goto mainMenu
)

echo.
set /p dbchoice="Selecciona la base de datos por número [por defecto: %DEFAULT_DB%]: "

if "%dbchoice%"=="" (
    set dbname=%DEFAULT_DB%
) else (
    if %dbchoice% GTR %countdb% (
        echo Opcion invalida.
        pause
        goto select_database
    ) else (
        set "dbname=!db%dbchoice%!"
    )
)
echo Base de datos seleccionada: %dbname%
goto :eof

:export_json
cls
echo **********************
echo *   Exportar JSON    *
echo **********************
echo.

call :select_database

echo.
echo Listando tablas disponibles en la base de datos %dbname%...
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %dbname% -t -c "SELECT tablename FROM pg_tables WHERE schemaname='public';" > temp_tables.txt

set count=0
for /f "usebackq tokens=* delims=" %%a in ("temp_tables.txt") do (
    set "tableName=%%a"
    for /f "tokens=* delims= " %%b in ("!tableName!") do (
        if not "%%b"=="" (
            set /a count+=1
            echo !count!. %%b
            set "table!count!=%%b"
        )
    )
)
del temp_tables.txt

if %count%==0 (
    echo No hay tablas disponibles.
    pause
    goto mainMenu
)

echo.
set /p tablechoice="Selecciona la tabla a exportar por número: "
set "TABLE=!table%tablechoice%!"

if "!TABLE!"=="" (
    echo Tabla inválida.
    pause
    goto mainMenu
)

REM Crear directorio si no existe
if not exist "%EXPORT_DIR%" (
    mkdir "%EXPORT_DIR%"
)

REM Definir ruta del archivo de salida
set "EXPORT_FILE=%EXPORT_DIR%\!TABLE!_export_%EXPORT_DATE%.json"

REM Exportar a archivo JSON
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %dbname% -t -c "SELECT json_agg(row_to_json(t)) FROM (SELECT * FROM !TABLE!) t" > "!EXPORT_FILE!"

echo.
echo JSON exportado correctamente en: !EXPORT_FILE!
echo.
pause
goto mainMenu

:export_xml
cls
echo **********************
echo *   Exportar XML     *
echo **********************
echo.

call :select_database

echo.
echo Listando tablas disponibles en la base de datos %dbname%...
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %dbname% -t -c "SELECT tablename FROM pg_tables WHERE schemaname='public';" > temp_tables.txt

set count=0
for /f "usebackq tokens=* delims=" %%a in ("temp_tables.txt") do (
    set "tableName=%%a"
    for /f "tokens=* delims= " %%b in ("!tableName!") do (
        if not "%%b"=="" (
            set /a count+=1
            echo !count!. %%b
            set "table!count!=%%b"
        )
    )
)
del temp_tables.txt

if %count%==0 (
    echo No hay tablas disponibles.
    pause
    goto mainMenu
)

echo.
set /p tablechoice="Selecciona la tabla a exportar por número: "
set "TABLE=!table%tablechoice%!"

if "!TABLE!"=="" (
    echo Tabla inválida.
    pause
    goto mainMenu
)

REM Crear directorio si no existe
if not exist "%EXPORT_DIR%" (
    mkdir "%EXPORT_DIR%"
)

REM Definir archivo de salida
set "EXPORT_FILE=%EXPORT_DIR%\!TABLE!_export_%EXPORT_DATE%.xml"

REM Encabezado XML
echo ^<?xml version="1.0" encoding="UTF-8"?^> > "!EXPORT_FILE!"

REM Exportar a XML
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %dbname% -q -A -t -c "SELECT COALESCE(xmlelement(name rows, xmlagg(xmlelement(name row, xmlforest(t.*)))), xmlelement(name rows)) FROM (SELECT * FROM !TABLE!) t;" >> "!EXPORT_FILE!"

echo.
echo XML exportado correctamente en: !EXPORT_FILE!
echo.
pause
goto mainMenu

:exitProgram
echo Saliendo del programa...
endlocal
exit /b
