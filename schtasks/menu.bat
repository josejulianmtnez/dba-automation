REM ==============================================
REM NOTA:
REM - Procuren trajar limpio, ordenado e identado.
REM - Creen una rama nueva para su tarea.
REM - Prueben que su código si les genere la tarea
REM   correctamente y que al ejecutar la tarea se
REM   realice lo que se espera dentro de la VM 
REM   antes de hacer su pull request.
REM - Sí tienen dudas sobre cómo hacer algo saquen
REM   Discord.
REM - El bat con los comandos de VBoxManage está
REM   en la carpeta menu_vboxmanage.
REM ==============================================

@echo off
chcp 65001 >nul

for /f "tokens=2,* delims= " %%i in ('reg query "HKLM\SOFTWARE\Oracle\VirtualBox" /v InstallDir 2^>nul') do set "VBOX_INSTALL_PATH=%%j"
if "%VBOX_INSTALL_PATH%"=="" (
    echo VirtualBox no está instalado o no se pudo encontrar la ruta de instalación.
    pause
    exit /b 1
)
set "PATH=%PATH%;%VBOX_INSTALL_PATH%"

:menu
cls
echo ==============================================
echo        Menú de Programación de Tareas
echo ==============================================
echo 1. Programar Tarea de Snapshot de una VM
echo 2. Eliminar Tarea Snapshot de una VM
echo 3. Programar Backup de una VM
echo 4. Eliminar Tarea Backup de una VM
echo 5. Eliminar una Tarea Programada
echo 0. Salir
set /p choice=Seleccione una opción:

if %choice%==1 goto create_snapshot
if %choice%==2 goto delete_snapshot
if %choice%==3 goto create_backup
if %choice%==4 goto delete_backup
if %choice%==5 goto delete_task
if %choice%==0 goto salir

goto menu

:create_snapshot
    cls
    echo ==============================================
    echo Información del Snapshot a Crear Periodicamente
    echo ==============================================
    set /p vmName=Nombre de la VM a realizar el snapshot:
    set /p snapshotName=Nombre del snapshot:
    set /p description=Descripción del snapshot:
    echo.
    echo ==============================================
    echo        Información de la Tarea a Programar
    echo ==============================================
    set /p taskName=Nombre de la tarea:
    set /p taskTime=Hora de ejecución (HH:MM 24hrs):
    set /p taskPath=Ruta donde se generará el script (Ejemplo: C:\Ruta\al\generate_snapshot.bat):
    echo Periodo de ejecución de la tarea
    echo 1. Diario
    echo 2. Semanal
    echo 3. Mensual
    set /p taskPeriod=Seleccione una opción:

    mkdir "%taskPath%\.." 2>nul

    echo @echo off > "%taskPath%"
    echo chcp 65001 ^>nul >> "%taskPath%"
    echo. >> "%taskPath%"

    echo for /f "tokens=2,* delims= " %%%%i in ('reg query "HKLM\SOFTWARE\Oracle\VirtualBox" /v InstallDir 2^^^>nul') do set "VBOX_INSTALL_PATH=%%%%j" >> "%taskPath%"
    echo if "%%VBOX_INSTALL_PATH%%"=="" ( >> "%taskPath%"
    echo     echo VirtualBox no está instalado o no se pudo encontrar la ruta de instalación. >> "%taskPath%"
    echo     pause >> "%taskPath%"
    echo     exit /b 1 >> "%taskPath%"
    echo ) >> "%taskPath%"
    echo set "PATH=%%PATH%%;%%VBOX_INSTALL_PATH%%" >> "%taskPath%"
    echo. >> "%taskPath%"

    echo VBoxManage showvminfo "%%~1" ^>nul 2^>^&1 >> "%taskPath%"
    echo if errorlevel 1 ( >> "%taskPath%"
    echo     echo La m^áquina virtual "%%~1" no existe. >> "%taskPath%"
    echo     pause >> "%taskPath%"
    echo     exit /b 1 >> "%taskPath%"
    echo ) >> "%taskPath%"
    echo. >> "%taskPath%"

    echo echo Creando snapshot "%%~2" para la VM "%%~1"... >> "%taskPath%"
    echo VBoxManage snapshot "%%~1" take "%%~2" --description "%%~3" >> "%taskPath%"
    echo if errorlevel 1 ( >> "%taskPath%"
    echo     echo Error al crear el snapshot. >> "%taskPath%"
    echo     pause >> "%taskPath%"
    echo     exit /b 1 >> "%taskPath%"
    echo ) >> "%taskPath%"
    echo. >> "%taskPath%"
    echo echo Snapshot creado exitosamente. >> "%taskPath%"

    set "scheduleType=DAILY"
    if "%taskPeriod%"=="2" set "scheduleType=WEEKLY"
    if "%taskPeriod%"=="3" set "scheduleType=MONTHLY"

    schtasks /create /tn "%taskName%" /tr "\"%taskPath%\" \"%vmName%\" \"%snapshotName%\" \"%description%\"" /sc %scheduleType% /st %taskTime% /f
    echo.
    echo Tarea programada correctamente.
    pause
    goto menu

:delete_snapshot
    cls
    echo ==============================================
    echo Información del Snapshot a Eliminar Periodicamente
    echo ==============================================
    set /p vmName=Nombre de la VM a eliminar el snapshot:
    echo.
    echo Lista de snapshots disponibles:
    VBoxManage snapshot "%vmName%" list
    echo.
    set /p snapshotName=Nombre del snapshot:
    echo.
    echo ==============================================
    echo        Información de la Tarea a Programar
    echo ==============================================
    set /p taskName=Nombre de la tarea:
    set /p taskTime=Hora de ejecución (HH:MM 24hrs):
    set /p taskPath=Ruta donde se generará el script (Ejemplo: C:\Ruta\al\delete_snapshot.bat):
    echo Periodo de ejecución de la tarea
    echo 1. Diario
    echo 2. Semanal
    echo 3. Mensual
    set /p taskPeriod=Seleccione una opción:

    mkdir "%taskPath%\.." 2>nul

    echo @echo off > "%taskPath%"
    echo chcp 65001 ^>nul >> "%taskPath%"
    echo. >> "%taskPath%"

    echo for /f "tokens=2,* delims= " %%%%i in ('reg query "HKLM\SOFTWARE\Oracle\VirtualBox" /v InstallDir 2^^^>nul') do set "VBOX_INSTALL_PATH=%%%%j" >> "%taskPath%"
    echo if "%%VBOX_INSTALL_PATH%%"=="" ( >> "%taskPath%"
    echo     echo VirtualBox no está instalado o no se pudo encontrar la ruta de instalación. >> "%taskPath%"
    echo     pause >> "%taskPath%"
    echo     exit /b 1 >> "%taskPath%"
    echo ) >> "%taskPath%"
    echo set "PATH=%%PATH%%;%%VBOX_INSTALL_PATH%%" >> "%taskPath%"
    echo. >> "%taskPath%"

    echo VBoxManage showvminfo "%%~1" ^>nul 2^>^&1 >> "%taskPath%"
    echo if errorlevel 1 ( >> "%taskPath%"
    echo     echo La m^áquina virtual "%%~1" no existe. >> "%taskPath%"
    echo     pause >> "%taskPath%"
    echo     exit /b 1 >> "%taskPath%"
    echo ) >> "%taskPath%"
    echo. >> "%taskPath%"

    echo echo Eliminado snapshot "%%~2" para la VM "%%~1"... >> "%taskPath%"
    echo VBoxManage snapshot "%%~1" delete "%%~2" >> "%taskPath%"
    echo if errorlevel 1 ( >> "%taskPath%"
    echo     echo Error al eliminar el snapshot. >> "%taskPath%"
    echo     pause >> "%taskPath%"
    echo     exit /b 1 >> "%taskPath%"
    echo ) >> "%taskPath%"
    echo. >> "%taskPath%"
    echo echo Snapshot eliminado exitosamente. >> "%taskPath%"

    set "scheduleType=DAILY"
    if "%taskPeriod%"=="2" set "scheduleType=WEEKLY"
    if "%taskPeriod%"=="3" set "scheduleType=MONTHLY"

    schtasks /create /tn "%taskName%" /tr "\"%taskPath%\" \"%vmName%\" \"%snapshotName%\" \"%description%\"" /sc %scheduleType% /st %taskTime% /f
    echo.
    echo Tarea programada correctamente.
    pause
    goto menu

:create_backup
    cls
    echo ==============================================
    echo    Programar Backup Periódico de una VM
    echo ==============================================
    set /p vmName=Nombre de la VM a respaldar:
    set /p backupPath=Ruta donde se almacenará el backup (Ejemplo: C:\Ruta\backups):
    echo.
    echo ==============================================
    echo        Información de la Tarea a Programar
    echo ==============================================
    set /p taskName=Nombre de la tarea:
    set /p taskTime=Hora de ejecución (HH:MM 24hrs):
    set /p taskPath=Ruta donde se generará el script (Ejemplo: C:\Ruta\al\create_backup.bat):
    echo Periodo de ejecución de la tarea
    echo 1. Diario
    echo 2. Semanal
    echo 3. Mensual
    set /p taskPeriod=Seleccione una opción:

    mkdir "%taskPath%\.." 2>nul

    echo @echo off > "%taskPath%"
    echo chcp 65001 ^>nul >> "%taskPath%"
    echo. >> "%taskPath%"

    echo for /f "tokens=2,* delims= " %%%%i in ('reg query "HKLM\SOFTWARE\Oracle\VirtualBox" /v InstallDir 2^^^>nul') do set "VBOX_INSTALL_PATH=%%%%j" >> "%taskPath%"
    echo if "%%VBOX_INSTALL_PATH%%"=="" ( >> "%taskPath%"
    echo     echo VirtualBox no está instalado o no se pudo encontrar la ruta de instalación. >> "%taskPath%"
    echo     pause >> "%taskPath%"
    echo     exit /b 1 >> "%taskPath%"
    echo ) >> "%taskPath%"
    echo set "PATH=%%PATH%%;%%VBOX_INSTALL_PATH%%" >> "%taskPath%"
    echo. >> "%taskPath%"

    echo VBoxManage showvminfo "%%~1" ^>nul 2^>^&1 >> "%taskPath%"
    echo if errorlevel 1 ( >> "%taskPath%"
    echo     echo La m^áquina virtual "%%~1" no existe. >> "%taskPath%"
    echo     pause >> "%taskPath%"
    echo     exit /b 1 >> "%taskPath%"
    echo ) >> "%taskPath%"
    echo. >> "%taskPath%"

    echo REM Obtener fecha actual en formato YYYYMMDD_HHMMSS >> "%taskPath%"
    echo for /f "tokens=2 delims==" %%%%I in ('"wmic os get localdatetime /value"') do set datetime=%%%%I >> "%taskPath%"
    echo set "fecha=%%datetime:~0,4%%%%datetime:~4,2%%%%datetime:~6,2%%_%%datetime:~8,2%%%%datetime:~10,2%%%%datetime:~12,2%%" >> "%taskPath%"
    echo set "backupname=%%~1_Backup_%%fecha%%" >> "%taskPath%"
    echo. >> "%taskPath%"

    echo echo Realizando backup de la VM "%%~1" como "%%backupname%%"... >> "%taskPath%"
    echo VBoxManage clonevm "%%~1" --name "%%backupname%%" --basefolder "%%~2" --register >> "%taskPath%"
    echo if errorlevel 1 ( >> "%taskPath%"
    echo     echo Error al crear el backup. >> "%taskPath%"
    echo     pause >> "%taskPath%"
    echo     exit /b 1 >> "%taskPath%"
    echo ) >> "%taskPath%"
    echo. >> "%taskPath%"
    echo echo Backup creado exitosamente. >> "%taskPath%"

    set "scheduleType=DAILY"
    if "%taskPeriod%"=="2" set "scheduleType=WEEKLY"
    if "%taskPeriod%"=="3" set "scheduleType=MONTHLY"

    schtasks /create /tn "%taskName%" /tr "\"%taskPath%\" \"%vmName%\" \"%backupPath%\"" /sc %scheduleType% /st %taskTime% /f
    echo.
    echo Tarea programada correctamente.
    pause
    goto menu

:delete_backup
    cls
    echo ==============================================
    echo   Eliminar Backup Periódico de una VM
    echo ==============================================
    echo Lista de máquinas virtuales:
    VBoxManage list vms
    echo.
    set /p backupName= Escriba el nombre exacto de la VM del backup a eliminar:
    echo.
    echo ==============================================
    echo        Información de la Tarea a Programar
    echo ==============================================
    set /p taskName=Nombre de la tarea:
    set /p taskTime=Hora de ejecución (HH:MM 24hrs):
    set /p taskPath=Ruta donde se generará el script (Ejemplo: C:\Ruta\al\delete_backup.bat):
    echo Periodo de ejecución de la tarea
    echo 1. Diario
    echo 2. Semanal
    echo 3. Mensual
    set /p taskPeriod=Seleccione una opción:

    mkdir "%taskPath%\.." 2>nul

    echo @echo off > "%taskPath%"
    echo chcp 65001 ^>nul >> "%taskPath%"
    echo. >> "%taskPath%"

    echo for /f "tokens=2,* delims= " %%%%i in ('reg query "HKLM\SOFTWARE\Oracle\VirtualBox" /v InstallDir 2^^^>nul') do set "VBOX_INSTALL_PATH=%%%%j" >> "%taskPath%"
    echo if "%%VBOX_INSTALL_PATH%%"=="" ( >> "%taskPath%"
    echo     echo VirtualBox no está instalado o no se pudo encontrar la ruta de instalación. >> "%taskPath%"
    echo     pause >> "%taskPath%"
    echo     exit /b 1 >> "%taskPath%"
    echo ) >> "%taskPath%"
    echo set "PATH=%%PATH%%;%%VBOX_INSTALL_PATH%%" >> "%taskPath%"
    echo. >> "%taskPath%"

    echo VBoxManage showvminfo "%%~1" ^>nul 2^>^&1 >> "%taskPath%"
    echo if errorlevel 1 ( >> "%taskPath%"
    echo     echo La m^áquina virtual "%%~1" no existe. >> "%taskPath%"
    echo     pause >> "%taskPath%"
    echo     exit /b 1 >> "%taskPath%"
    echo ) >> "%taskPath%"
    echo. >> "%taskPath%"

    echo echo Eliminando backup "%%~1"... >> "%taskPath%"
    echo VBoxManage unregistervm "%%~1" --delete >> "%taskPath%"
    echo if errorlevel 1 ( >> "%taskPath%"
    echo     echo Error al eliminar el backup. >> "%taskPath%"
    echo     pause >> "%taskPath%"
    echo     exit /b 1 >> "%taskPath%"
    echo ) >> "%taskPath%"
    echo. >> "%taskPath%"
    echo echo Backup eliminado exitosamente. >> "%taskPath%"

    set "scheduleType=DAILY"
    if "%taskPeriod%"=="2" set "scheduleType=WEEKLY"
    if "%taskPeriod%"=="3" set "scheduleType=MONTHLY"

    schtasks /create /tn "%taskName%" /tr "\"%taskPath%\" \"%backupName%\"" /sc %scheduleType% /st %taskTime% /f
    echo.
    echo Tarea programada correctamente.
    pause
    goto menu

:delete_task
    cls
    echo ==============================================
    echo         Eliminar Tarea Programada
    echo ==============================================
    echo.
    set /p taskName=Escribe el nombre EXACTO de la tarea a eliminar:
    echo.
    echo ¿Estás seguro que deseas eliminar la tarea "%taskName%"? (S/N)
    set /p confirm=

    if /i "%confirm%"=="S" (
        schtasks /delete /tn "%taskName%" /f
        if %errorlevel%==0 (
            echo.
            echo Tarea "%taskName%" eliminada correctamente.
        ) else (
            echo.
            echo No se pudo eliminar la tarea. Asegúrate de que el nombre es correcto.
        )
    ) else (
        echo.
        echo Operación cancelada.
    )
    pause
    goto menu

:salir
    exit
