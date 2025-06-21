@echo off
setlocal enabledelayedexpansion

set PGHOST=localhost
set PGPORT=5432
set DEFAULT_USER=postgres

:mainMenu
cls
echo ****************************************
echo *       Crear Usuario de PostgreSQL    *
echo ****************************************
set /p PGUSER="Ingresa el nombre de usuario de PostgreSQL [por defecto: %DEFAULT_USER%]: "
if "%PGUSER%"=="" set PGUSER=%DEFAULT_USER%

echo.
set /p NEW_USER="Ingresa el nombre del nuevo usuario: "
set /p NEW_PASSWORD="Ingresa la contraseña para el nuevo usuario: "

echo.
echo Creando usuario %NEW_USER%, Confirme la contraseña de %DEFAULT_USER%...
echo.

psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d postgres -c "CREATE USER %NEW_USER% WITH PASSWORD '%NEW_PASSWORD%';"
if %errorlevel% neq 0 (
    echo Error al crear el usuario %NEW_USER%.
    pause
    goto :mainMenu
)
echo Usuario %NEW_USER% creado exitosamente.

echo.
echo ****************************************
echo *  BD, TABLA Y PERMISOS PARA EL NUEVO USUARIO  *
echo ****************************************
echo Listando bases de datos disponibles, Confirme la contraseña de %DEFAULT_USER%...
echo.
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;" > temp_dbs.txt
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
set /p dbchoice="Selecciona la base de datos a la que se le otorgaran permisos al nuevo usuario: "
set "DATABASE=!db%dbchoice%!"
echo.

echo Listando tablas disponibles en la base de datos %DATABASE%...
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d !DATABASE! -t -c "SELECT tablename FROM pg_tables WHERE schemaname='public';" > temp_tables.txt

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
set /p tablechoice="Selecciona la tabla: "
set "TABLE=!table%tablechoice%!"

echo.
echo Selecciona los permisos a otorgar:
echo 1. ALL PRIVILEGES
echo 2. SELECT
echo 3. INSERT
echo 4. UPDATE
echo 5. DELETE
echo 6. SELECT, INSERT, UPDATE
echo 7. Personalizado

set /p permChoice="Opción: "
if "%permChoice%"=="1" set "PERMISSIONS=ALL PRIVILEGES"
if "%permChoice%"=="2" set "PERMISSIONS=SELECT"
if "%permChoice%"=="3" set "PERMISSIONS=INSERT"
if "%permChoice%"=="4" set "PERMISSIONS=UPDATE"
if "%permChoice%"=="5" set "PERMISSIONS=DELETE"
if "%permChoice%"=="6" set "PERMISSIONS=SELECT, INSERT, UPDATE"
if "%permChoice%"=="7" (
    set /p PERMISSIONS="Ingresa los permisos personalizados separados por coma (ejemplo: SELECT, INSERT, DELETE): "
)

set "TABLE=%TABLE: =%"

echo.
echo Otorgando permisos %PERMISSIONS% al usuario %NEW_USER% en la tabla %TABLE%...
psql -U %PGUSER% -h %PGHOST% -p %PGPORT% -d !DATABASE! -c "GRANT %PERMISSIONS% ON TABLE %TABLE% TO %NEW_USER%;"
if %errorlevel% neq 0 (
    echo Error al otorgar permisos.
    pause
    goto :mainMenu
)

echo.
echo Permisos otorgados exitosamente para el usuario %NEW_USER% sobre %TABLE%.
pause
endlocal
exit /b
