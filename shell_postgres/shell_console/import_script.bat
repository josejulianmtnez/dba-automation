@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set DEFAULT_USER=postgres
set PGHOST=localhost
set PGPORT=5432
set IMPORT_DIR=C:\exports

:startMenu
cls
echo *********************************************
echo *         Importar archivo a PostgreSQL     *
echo *********************************************
echo 1. Importar archivo CSV
echo 2. Importar archivo TXT
echo 0. Salir
echo *********************************************
set /p fileType="Selecciona una opción: "

if "%fileType%"=="1" goto import_csv
if "%fileType%"=="2" goto import_txt
if "%fileType%"=="0" exit /b
echo Opción inválida.
pause
goto startMenu

:import_csv
cls
echo *********************************************
echo *          Importar CSV a PostgreSQL        *
echo *********************************************
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
    goto startMenu
)

set /p dbchoice="Selecciona una base de datos por número: "
set "DATABASE=!db%dbchoice%!"

if "!DATABASE!"=="" (
    echo Opción inválida.
    pause
    goto startMenu
)

echo.
echo Listando tablas de la base de datos: !DATABASE! ...
psql -U %DEFAULT_USER% -h %PGHOST% -p %PGPORT% -d !DATABASE! -t -c "SELECT tablename FROM pg_tables WHERE schemaname='public';" > temp_tables.txt

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
    goto startMenu
)

set /p tablechoice="Selecciona una tabla por número: "
set "TABLE=!table%tablechoice%!"

if "!TABLE!"=="" (
    echo Opción inválida.
    pause
    goto startMenu
)

echo.
echo Listando archivos CSV en %IMPORT_DIR%...
echo.
dir /b /a:-d "%IMPORT_DIR%\*.csv" > temp_csvfiles.txt

set count=0
for /f "usebackq delims=" %%f in ("temp_csvfiles.txt") do (
    set /a count+=1
    echo !count!. %%f
    set "file!count!=%%f"
)

if %count%==0 (
    echo No se encontraron archivos CSV en %IMPORT_DIR%.
    pause
    goto startMenu
)

:select_csvfile
echo.
set /p filechoice="Selecciona el número del archivo CSV a importar: "
if "%filechoice%"=="" (
    echo Opción inválida.
    goto select_csvfile
)
for /f "delims=0123456789" %%x in ("%filechoice%") do (
    echo Opción inválida.
    goto select_csvfile
)
if %filechoice% lss 1 (
    echo Opción inválida.
    goto select_csvfile
)
if %filechoice% gtr %count% (
    echo Opción inválida.
    goto select_csvfile
)

set "csvfile=%IMPORT_DIR%\!file%filechoice%!"

if not exist "!csvfile!" (
    echo El archivo seleccionado no existe.
    pause
    goto startMenu
)
del temp_csvfiles.txt

echo.
echo Archivo seleccionado: !csvfile!

echo Importando archivo CSV en la tabla: !TABLE! de la base de datos: !DATABASE!
psql -U %DEFAULT_USER% -h %PGHOST% -p %PGPORT% -d !DATABASE! -c "\COPY public.!TABLE! FROM '!csvfile!' DELIMITER ',' CSV HEADER;"

if %ERRORLEVEL%==0 (
    echo Importación completada exitosamente.
) else (
    echo Error al importar el archivo CSV.
)

pause
goto startMenu

:import_txt
cls
echo *********************************************
echo *         Importar archivo TXT a PostgreSQL *
echo *********************************************
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
    goto startMenu
)

set /p dbchoice="Selecciona una base de datos por número: "
set "DATABASE=!db%dbchoice%!"

if "!DATABASE!"=="" (
    echo Opción inválida.
    pause
    goto startMenu
)

echo.
echo Listando tablas de la base de datos: !DATABASE! ...
psql -U %DEFAULT_USER% -h %PGHOST% -p %PGPORT% -d !DATABASE! -t -c "SELECT tablename FROM pg_tables WHERE schemaname='public';" > temp_tables.txt

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
    goto startMenu
)

set /p tablechoice="Selecciona una tabla por número: "
set "TABLE=!table%tablechoice%!"

if "!TABLE!"=="" (
    echo Opción inválida.
    pause
    goto startMenu
)

echo.
echo Listando archivos TXT en %IMPORT_DIR%...
echo.
dir /b /a:-d "%IMPORT_DIR%\*.txt" > temp_txtfiles.txt

set count=0
for /f "usebackq delims=" %%f in ("temp_txtfiles.txt") do (
    set /a count+=1
    echo !count!. %%f
    set "file!count!=%%f"
)

if %count%==0 (
    echo No se encontraron archivos TXT en %IMPORT_DIR%.
    pause
    goto startMenu
)

:select_txtfile
echo.
set /p filechoice="Selecciona el número del archivo TXT a importar: "
if "%filechoice%"=="" (
    echo Opción inválida.
    goto select_txtfile
)

for /f "delims=0123456789" %%x in ("%filechoice%") do (
    echo Opción inválida.
    goto select_txtfile
)

if %filechoice% lss 1 (
    echo Opción inválida.
    goto select_txtfile
)

if %filechoice% gtr %count% (
    echo Opción inválida.
    goto select_txtfile
)

set "txtfile=%IMPORT_DIR%\!file%filechoice%!"

if not exist "!txtfile!" (
    echo El archivo seleccionado no existe.
    pause
    goto startMenu
)
del temp_txtfiles.txt

set delimiter=E'\t'
echo Importando archivo TXT en la tabla: !TABLE! de la base de datos: !DATABASE!
psql -U %DEFAULT_USER% -h %PGHOST% -p %PGPORT% -d !DATABASE! -c "\COPY public.!TABLE! FROM '!txtfile!' DELIMITER !delimiter!;"

if %ERRORLEVEL%==0 (
    echo Importación completada exitosamente.
) else (
    echo Error al importar el archivo TXT.
)

pause
goto startMenu
