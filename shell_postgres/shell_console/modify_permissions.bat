@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM Configuración
set PGHOST=localhost
set PGUSER=postgres
set PGPORT=5432
set DEFAULT_DB=mi_financiera_demo

:permisos_postgres
cls
echo ******************************************
echo *   Modificar Permisos en PostgreSQL    *
echo ******************************************
echo.

REM Listar bases de datos disponibles
echo Bases de datos disponibles:
for /f "tokens=1,* delims=|" %%a in ('psql -U postgres -lqt') do (
    echo     %%a
)

echo.
set /p dbname=Escriba el nombre de la base de datos [por defecto: %DEFAULT_DB%]: 
if "%dbname%"=="" set dbname=%DEFAULT_DB%

echo.
echo Usuarios disponibles en la base de datos %dbname%:
psql -U postgres -d %dbname% -t -A -c "SELECT rolname FROM pg_roles WHERE rolcanlogin = true;" > temp_users.txt

set count=0
for /f %%u in (temp_users.txt) do (
    set /a count+=1
	echo     !count!.%%u
	set "user!count!=%%u"

	
)
del temp_users.txt

if %count%==0 (
    echo No hay usuarios disponibles.
    pause
    goto :permisos_postgres
)


echo.
set /p userchoice="Selecciona la tabla por número para ver sus privilegios: "
set "USER=!user%userchoice%!"

REM Mostrar lista de permisos numerados
echo.
echo ===== Permisos disponibles =====
echo 1. SELECT       - Leer datos de tablas
echo 2. INSERT       - Insertar datos en tablas
echo 3. UPDATE       - Modificar datos en tablas
echo 4. DELETE       - Eliminar datos de tablas
echo 5. TRUNCATE     - Truncar tablas
echo 6. REFERENCES   - Crear claves foraneas
echo 7. TRIGGER      - Crear triggers
echo 0. TODOS LOS PERMISOS
echo ===============================
echo.
set /p permisos_nums=Ingrese el/los permisos a asignar (ej. 1,3,4 o 0 para todos): 

REM Mapeo de permisos
set "perm_1=SELECT"
set "perm_2=INSERT"
set "perm_3=UPDATE"
set "perm_4=DELETE"
set "perm_5=TRUNCATE"
set "perm_6=REFERENCES"
set "perm_7=TRIGGER"

REM Si selecciona 0, son todos los permisos
if "%permisos_nums%"=="0" (
    set permisos=SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
) else (
    set permisos=
    for %%i in (%permisos_nums%) do (
        call set permiso=!perm_%%i!
        if defined permisos (
            set permisos=!permisos!, !permiso!
        ) else (
            set permisos=!permiso!
        )
    )
)

REM Seleccionar tabla
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
    goto :mainMenu
)
echo.
set /p tablechoice="Selecciona la tabla por número para ver sus privilegios: "
set "TABLE=!table%tablechoice%!"

REM Aplicar permisos
echo.
echo Revocando permisos existentes para %user% en !TABLE!...
psql -U postgres -d %dbname% -c "REVOKE ALL ON !TABLE! FROM %user%;"
echo Otorgando permisos [%permisos%] sobre !TABLE! a %user%...
psql -U postgres -d %dbname% -c "GRANT %permisos% ON !TABLE! TO %user%;"

echo.
echo Permisos actualizados correctamente para el usuario %user%.
pause
goto menu
