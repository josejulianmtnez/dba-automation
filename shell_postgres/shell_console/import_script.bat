@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set DEFAULT_USER=postgres
set PGHOST=localhost
set PGPORT=5432

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
set /p csvfile="Ingresa la ruta completa del archivo CSV a importar (C:\exports\8ids1_public_users_export_20250622_2245.csv): "

if not exist "!csvfile!" (
    echo El archivo especificado no existe.
    pause
    goto startMenu
)

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
set /p txtfile="Ingresa la ruta completa del archivo TXT a importar (ej. C:\exports\datos.txt): "

if not exist "!txtfile!" (
    echo El archivo especificado no existe.
    pause
    goto startMenu
)


set delimiter=E'\t'

echo Importando archivo TXT en la tabla: !TABLE! de la base de datos: !DATABASE!
psql -U %DEFAULT_USER% -h %PGHOST% -p %PGPORT% -d !DATABASE! -c "\COPY public.!TABLE! FROM '!txtfile!' DELIMITER !delimiter! CSV HEADER;"

if %ERRORLEVEL%==0 (
    echo Importación completada exitosamente.
) else (
    echo Error al importar el archivo TXT.
)

pause
goto startMenu

