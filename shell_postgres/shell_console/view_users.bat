@echo off
setlocal enabledelayedexpansion

REM ===========================================================
REM        Script para ver tablas y privilegios en PostgreSQL
REM ===========================================================

REM Configuración por defecto
set PGHOST=localhost
set PGPORT=5432
set DEFAULT_DB=mi_financiera_demo
set DEFAULT_USER=postgres


:mainMenu
cls
echo *******************************
echo *  Ver privilegios de tablas  *
echo *******************************


set /p PGUSER="Ingresa el nombre de usuario de PostgreSQL [por defecto: %DEFAULT_USER%]: "
if "%PGUSER%"=="" set PGUSER=%DEFAULT_USER%

set /p DATABASE="Ingresa el nombre de la base de datos [por defecto: %DEFAULT_DB%]: "
if "%DATABASE%"=="" set DATABASE=%DEFAULT_DB%


echo.
echo Listando tablas disponibles en la base de datos %DATABASE%...
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %DATABASE% -t -c "SELECT tablename FROM pg_tables WHERE schemaname='public';" > temp_tables.txt

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
    goto :mainMenu
)


echo.
set /p tablechoice="Selecciona la tabla por número para ver sus privilegios: "
set "TABLE=!table%tablechoice%!"


if not "!TABLE!"=="" (
    echo.
    echo ================================================
    echo Privilegios sobre la tabla !TABLE! en %DATABASE%
    echo ================================================
    psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %DATABASE% -c "\z !TABLE!"
    echo.
) else (
    echo No se seleccionó ninguna tabla.
)

pause
endlocal
exit /b
