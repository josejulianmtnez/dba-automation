@echo off
setlocal enabledelayedexpansion

REM Configuración
set PGHOST=localhost
set PGPORT=5432
set BACKUP_DIR=C:\Postgrebk
set DEFAULT_DB=mi_financiera_demo

:menu
cls
echo **************************
echo *   Modificar Permisos   *
echo **************************
echo.
echo 1. Modificar permisos en PostgreSQL a un usuario
echo 0. Volver al menu principal
echo.
set /p option=Seleccione una opcion: 

if "%option%"=="1" goto permisos_postgres
if "%option%"=="0" exit /b
goto menu

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

REM Mostrar usuarios reales (roles con login)
echo.
echo Usuarios disponibles en la base de datos %dbname%:
psql -U postgres -d %dbname% -t -A -c "SELECT rolname FROM pg_roles WHERE rolcanlogin = true;" > temp_users.txt

for /f %%u in (temp_users.txt) do (
    echo     %%u
)
del temp_users.txt

echo.
set /p user=Ingrese el nombre del usuario al que asignará permisos: 

REM Mostrar lista de permisos numerados
echo.
echo ===== Permisos disponibles =====
echo 1. SELECT       - Leer datos de tablas
echo 2. INSERT       - Insertar datos en tablas
echo 3. UPDATE       - Modificar datos en tablas
echo 4. DELETE       - Eliminar datos de tablas
echo 5. TRUNCATE     - Truncar tablas
echo 6. REFERENCES   - Crear claves foráneas
echo 7. TRIGGER      - Crear triggers
echo 8. USAGE        - Usar un esquema
echo 9. CREATE       - Crear objetos en un esquema
echo 10. CONNECT     - Conectarse a la base de datos
echo 11. TEMP        - Crear tablas temporales
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
set "perm_8=USAGE"
set "perm_9=CREATE"
set "perm_10=CONNECT"
set "perm_11=TEMP"

REM Si selecciona 0, todos los permisos
if "%permisos_nums%"=="0" (
    set permisos=SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER, USAGE, CREATE, CONNECT, TEMP
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

REM Seleccionar tabla o todas
echo.
set /p tabla=Ingrese la tabla destino (o * para todas): 

if "%tabla%"=="*" (
    set tabla_comando=ALL TABLES IN SCHEMA public
) else (
    set tabla_comando=TABLE %tabla%
)

REM Aplicar permisos
echo.
echo Otorgando permisos [%permisos%] sobre %tabla_comando% a %user%...
psql -U postgres -d %dbname% -c "GRANT %permisos% ON %tabla_comando% TO %user%;"

echo.
echo Permisos aplicados correctamente al usuario %user%.
pause
goto menu
