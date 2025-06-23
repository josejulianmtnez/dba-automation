@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ===========================================================
REM             Consola de Respaldos 
REM ===========================================================
REM Este programa ha sido creado con fines educativos como una 
REM herramienta de práctica para la gestión de respaldos y restauración 
REM de bases de datos PostgreSQL. Está diseñado para ayudar a los estudiantes 
REM y profesionales a familiarizarse con los comandos de PostgreSQL y 
REM para su implementación en procesos de automatización. Este shell 
REM está diseñado para mejorarse con nuevas funcionalidades y comandos 
REM adicionales según las necesidades específicas.
REM MTI JERM



:mainMenu
cls
echo ****************************************
echo *   Menu de Respaldo y Restauracion    *
echo ****************************************
echo 1. Respaldar la base de datos
echo 2. Restaurar la base de datos existente
echo 3. Crear nueva base de datos y restaurar respaldo
echo 4. Borrar una base de datos
echo 5. Crear usuario y asignar permisos
echo 6. Modificar permisos de usuario
echo 7. Ver usuarios y sus privilegios
echo 8. Exportar Script
echo 9. Importar Script
echo 0. Salir
echo ****************************************
set /p choice="Selecciona una opcion (1/2/3/4/5/6/7/8/9): "

if "%choice%"=="1" call backup_database.bat
if "%choice%"=="2" call restore_database.bat
if "%choice%"=="3" call create_and_restore_database.bat
if "%choice%"=="4" call delete_database.bat
if "%choice%"=="5" call create_user.bat
if "%choice%"=="6" call modify_permissions.bat
if "%choice%"=="7" call view_users.bat
if "%choice%"=="8" call export_script.bat
if "%choice%"=="9" call import_script.bat
if "%choice%"=="0" goto :exitProgram


pause
goto :mainMenu

:exitProgram
echo Saliendo del programa...
endlocal
exit /b
