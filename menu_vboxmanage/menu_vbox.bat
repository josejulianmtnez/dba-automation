@echo off
chcp 65001 >nul

REM ===========================================================
REM             VirtualBox Manage Menu - Teaching Tool
REM ===========================================================
REM Este programa ha sido creado con fines educativos como una 
REM herramienta de práctica para la gestión de máquinas virtuales 
REM utilizando VirtualBox. Está diseñado para ayudar a los estudiantes 
REM y profesionales a familiarizarse con los comandos de VirtualBox y 
REM para su implementación en procesos de automatización.
REM MTI JERM

REM Buscar la ruta de instalación de VirtualBox y agregarla al PATH
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
echo            VirtualBox Manage Menu
echo ==============================================
echo 1. Crear una nueva máquina virtual
echo 2. Configurar una máquina virtual
echo 3. Crear y adjuntar un disco duro virtual
echo 4. Adjuntar una imagen ISO
echo 5. Iniciar una máquina virtual
echo 6. Apagar una máquina virtual
echo 7. Crear un snapshot
echo 8. Listar snapshots
echo 9. Restaurar un snapshot
echo 10. Eliminar un snapshot
echo 11. Clonar una máquina virtual
echo 12. Desregistrar y eliminar una máquina virtual
echo 13. Listar las máquinas virtuales registradas en VBox
echo 14. Listar las máquinas virtuales en ejecucion
echo 15. Mostrar información detallada de la máquina virtual
echo 16. Cambiar nombre de la máquina virtual
echo 17. Listar discos duros de máquina virtual
echo 18. Exportar máquina virtual
echo 19. Importar máquina virtual
echo 20. Modificar propiedades de una máquina virtual
echo 21. Listar métricas de rendimiento
echo 22. Verificar la versión instalada de VBox
echo 23. Exportar configuración de máquina virtual
echo 24. Hacer backup (clonar una VM con fecha)
echo 25. Listar Adaptadores de red
echo 26. Configurar modo de arranque de la VM
echo 27. Configurar VRAM de una máquina virtual
echo 28. Restaurar Snapshot
echo 29. Reiniciar Maquina Virtual
echo 30. Reanudar Mv
echo 31. Mostrar estado actual de una VM
echo 32. Aumentar disco duro virtual
echo 33. Aumentar memoria de video (VRAM)
echo 34. Mostrar disco duro
echo 35. Clonar disco duro
echo 36. Eliminar máquina vrtual 
echo 37. Ver UUID de una máquina vrtual 
echo 0. Salir
echo ==============================================
set /p choice=Seleccione una opción: 

if %choice%==1 goto crear_vm
if %choice%==2 goto configurar_vm
if %choice%==3 goto crear_disco
if %choice%==4 goto adjuntar_iso
if %choice%==5 goto iniciar_vm
if %choice%==6 goto apagar_vm
if %choice%==7 goto crear_snapshot
if %choice%==8 goto listar_snapshots
if %choice%==9 goto restaurar_snapshot
if %choice%==10 goto eliminar_snapshot
if %choice%==11 goto clonar_vm
if %choice%==12 goto desregistar_vm
if %choice%==13 goto mostrar_vm
if %choice%==14 goto vm_en_ejecucion
if %choice%==15 goto info_vm
if %choice%==16 goto cambiar_nombre_vm
if %choice%==17 goto listar_disco
if %choice%==18 goto exportar_vm
if %choice%==19 goto importar_vm
if %choice%==20 goto runningvms
if %choice%==21 goto Lista_Metricas_Rendimiento
if %choice%==22 goto version_mv
if %choice%==23 goto config_vm
if %choice%==24 goto backup_vm
if %choice%==25 goto listar_adaptadores_red
if %choice%==26 goto configurar_modo_arranque
if %choice%==27 goto configurar_vram
if %choice%==28 goto restaurar_sp
if %choice%==29 goto reiniciar_vm
if %choice%==30 goto reanudar_vm
if "%choice%"=="31" goto estado_vm
if "%choice%"=="32" goto aumentar_disco
if "%choice%"=="33" goto aumentar_vram
if %choice%==34 goto mostrar_disco_info
if %choice%==35 goto clonar_disco
if %choice%==36 goto eliminar_maquina
if %choice%==37 goto ver_uuid


if %choice%==0 goto salir

REM Función para verificar si la VM existe
:vm_exists
VBoxManage showvminfo "%1" >nul 2>&1
if %errorlevel% neq 0 (
    echo La máquina virtual "%1" no existe.
    pause
    goto menu
)
goto :eof

REM Función para verificar y crear el controlador de almacenamiento si no existe
:ensure_storagectl
VBoxManage showvminfo "%1" | findstr /i /c:"SATA Controller" >nul
if %errorlevel% neq 0 (
    echo Creando controlador de almacenamiento...
    VBoxManage storagectl "%1" --name "SATA Controller" --add sata --controller IntelAhci
)
goto :eof

REM Función para verificar si el disco duro ya existe
:hdd_exists
VBoxManage list hdds | findstr /i "%1" >nul
if %errorlevel% equ 0 (
    echo El disco duro virtual "%1" ya existe.
    pause
    goto menu
)
goto :eof

:crear_vm
cls
echo ==============================================
echo          Crear una nueva máquina virtual
echo ==============================================
set /p vmname=Nombre de la nueva VM: 
VBoxManage createvm --name "%vmname%" --register
pause
goto menu

:configurar_vm
cls
echo ==============================================
echo          Configurar una máquina virtual
echo ==============================================
set /p vmname=Nombre de la VM a configurar: 
call :vm_exists "%vmname%"
set /p memory=Cantidad de memoria (MB): 
set /p cpus=Número de CPUs: 
VBoxManage modifyvm "%vmname%" --memory %memory% --cpus %cpus%
pause
goto menu

:crear_disco
cls
echo ==============================================
echo    Crear y adjuntar un disco duro virtual
echo ==============================================
set /p vmname=Nombre de la VM: 
call :vm_exists "%vmname%"
call :ensure_storagectl "%vmname%"
set /p disko=DIRECTORIO de disco duro (incluya la ruta completa y el nombre del archivo, ej. C:\ruta\a\disco.vdi): 
set /p size=Tamaño del disco (en MB): 
call :hdd_exists "%disko%"
VBoxManage createhd --filename "%disko%" --size %size%
VBoxManage storageattach "%vmname%" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "%disko%"
pause
goto menu

:adjuntar_iso
cls
echo ==============================================
echo            Adjuntar una imagen ISO
echo ==============================================
set /p vmname=Nombre de la VM: 
call :vm_exists "%vmname%"
call :ensure_storagectl "%vmname%"
set /p iso=DIRECTORIO de la imagen ISO (incluya la ruta completa y el nombre del archivo, ej. C:\ruta\a\imagen.iso): 
VBoxManage storageattach "%vmname%" --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium "%iso%"
pause
goto menu

:iniciar_vm
cls
echo ==============================================
echo           Iniciar una máquina virtual
echo ==============================================
set /p vmname=Nombre de la VM a iniciar: 
call :vm_exists "%vmname%"
VBoxManage startvm "%vmname%" --type headless
pause
goto menu

:apagar_vm
cls
echo ==============================================
echo           Apagar una máquina virtual
echo ==============================================
set /p vmname=Nombre de la VM a apagar: 
call :vm_exists "%vmname%"
VBoxManage controlvm "%vmname%" poweroff
pause
goto menu

:crear_snapshot
cls
echo ==============================================
echo             Crear un snapshot
echo ==============================================
set /p vmname=Nombre de la VM: 
call :vm_exists "%vmname%"
set /p snapshotname=Nombre del snapshot: 
set /p description=Descripción del snapshot: 
VBoxManage snapshot "%vmname%" take "%snapshotname%" --description "%description%"
pause
goto menu

:listar_snapshots
cls
echo ==============================================
echo           Listar snapshots
echo ==============================================
set /p vmname=Nombre de la VM: 
call :vm_exists "%vmname%"
VBoxManage snapshot "%vmname%" list
pause
goto menu

:restaurar_snapshot
cls
echo ==============================================
echo          Restaurar un snapshot
echo ==============================================
set /p vmname=Nombre de la VM: 
call :vm_exists "%vmname%"
set /p snapshotname=Nombre del snapshot a restaurar: 
VBoxManage snapshot "%vmname%" restore "%snapshotname%"
pause
goto menu

:eliminar_snapshot
cls
echo ==============================================
echo          Eliminar un snapshot
echo ==============================================
set /p vmname=Nombre de la VM: 
call :vm_exists "%vmname%"
set /p snapshotname=Nombre del snapshot a eliminar: 
VBoxManage snapshot "%vmname%" delete "%snapshotname%"
pause
goto menu

:clonar_vm
cls
echo ==============================================
echo           Clonar una máquina virtual
echo ==============================================
set /p vmname=Nombre de la VM a clonar: 
call :vm_exists "%vmname%"
set /p clonename=Nombre de la nueva VM clonada: 
VBoxManage clonevm "%vmname%" --name "%clonename%" --register
pause
goto menu

:desregistar_vm
cls
echo ==============================================
echo           Desregistrar y eliminar una máquina virtual
echo ==============================================
set /p vmname=Nombre de la VM a eliminar: 
call :vm_exists "%vmname%"
VBoxManage unregistervm "%vmname%" --delete
pause
goto menu

:mostrar_vm
cls
echo ==============================================
echo     Listar todas las máquinas virtuales
echo ==============================================
VBoxManage list vms
pause
goto menu

:vm_en_ejecucion
cls
echo ================================================
echo Listar maquinas virtuales en ejecucion
echo ================================================
for /f "delims=" %%A in ('VBoxManage list runningvms') do (
    set "vms_en_ejecucion=1"
    echo Máquina virtual en ejecución: %%A
)
if not defined vms_en_ejecucion (
    echo No hay máquinas virtuales en ejecución.
)
pause
goto menu

:info_vm
cls
echo ==============================================
echo           Mostrar información de la máquinas virtuales
echo ==============================================
set /p vmname=Nombre de la VM a mostrar información: 
call :vm_exists "%vmname%"
VBoxManage showvminfo "%vmname%"
pause
goto menu

:cambiar_nombre_vm
cls
echo ==============================================
echo    CAMBIAR EL NOMBRE DE UNA MAQUINA VIRTUAL
echo ==============================================
set /p vmname=Nombre Actual de la VM: 
call :vm_exists "%vmname%"
set /p nombre_nuevo=Nombre nuevo de tu maquina: 
echo Cerrando maquina virtual si esta encendida 
VBoxManage modifyvm "%vmname%" --name "%nombre_nuevo%"
echo Nombre cambiado exitosamente
pause
goto menu

:listar_disco
cls
echo ==============================================
echo           Listar discos virtuales
echo ============================================== 
VBoxManage list hdds
pause
goto menu

:exportar_vm
cls
echo ==============================================
echo         exportar maquina virtual a archivo OVA
echo ==============================================
set /p vmname=Nombre de la VM a exportar: 
call :vm_exists "%vmname%"
set /p ruta_ova=ruta y nombre del archivo .ova (ej. C:):
VBoxManage export "%vmname%" --output "%ruta_ova%"
echo Maquina exportada correctamente a:%ruta_ova%
pause
goto menu

:importar_vm
cls
echo ==============================================
echo        importar maquina virtual desde un archivo OVA
echo ==============================================
set /p ruta_ova=Ruta del archivo .ova a importar: 
VBoxManage import "%ruta_ova%" 
echo Maquina importada correctamente
pause
goto menu

:runningvms
cls
echo ==============================================
echo           Modificar propiedades de máquina virtual existente
echo ==============================================
set /p vmname=Nombre de la VM: 
call :vm_exists "%vmname%"
set /p sizemodify=Tamaño de memoria nueva: 
set /p countmodify=Cantidad de CPUs a modificar: 
VBoxManage modifyvm "%vmname%" --memory "%sizemodify%" --cpus "%countmodify%"
pause
goto menu

:Lista_Metricas_Rendimiento
cls 
echo ==============================================
echo          Lista de Metricas de Rendimiento de VMs
echo ==============================================
echo.
VBoxManage metrics list
echo.
pause
goto menu

:version_mv
cls
echo ==========================================================
echo      Verificar versión instalada de VirtualBox
echo ==========================================================
VBoxManage --version
pause
goto menu

:config_vm
cls
echo ==========================================================
echo      Exportar la Configuracion de una máquina virtual
echo ==========================================================
set /p vmname=Nombre de la VM: 
set /p salida=Ruta de Salida con terminacion .ova: 
VBoxManage export "%vmname%" --output "%salida%"
pause
goto menu

:backup_vm
cls
echo ==============================================
echo             Backup de una VM (clonar)
echo ==============================================
set /p vmname=Nombre de la VM a respaldar: 
call :vm_exists "%vmname%"

REM Obtener fecha actual en formato YYYYMMDD_HHMMSS
for /f "tokens=2 delims==" %%I in ('"wmic os get localdatetime /value"') do set datetime=%%I
set "fecha=%datetime:~0,4%%datetime:~4,2%%datetime:~6,2%_%datetime:~8,2%%datetime:~10,2%%datetime:~12,2%"

set "backupname=%vmname%_Backup_%fecha%"

echo Realizando backup de la VM "%vmname%" como "%backupname%"...
VBoxManage clonevm "%vmname%" --name "%backupname%" --register

echo.
echo Backup completado exitosamente.
pause
goto menu

:listar_adaptadores_red
cls
echo ==============================================
echo     Adaptadores de red disponibles (Bridged)
echo ==============================================
VBoxManage list bridgedifs
pause
goto menu

:configurar_modo_arranque
cls
echo ==============================================
echo       Configurar modo de arranque de la VM
echo ==============================================
set /p vmname=Nombre de la VM: 
call :vm_exists "%vmname%"

echo Modos de arranque disponibles:
echo 1. Normal (GUI)
echo 2. Headless (sin interfaz gráfica)
echo 3. Detachable (GUI que puede desconectarse)
set /p modo=Seleccione modo de arranque (1-3): 

if "%modo%"=="1" (
    set arranque=gui
) else if "%modo%"=="2" (
    set arranque=headless
) else if "%modo%"=="3" (
    set arranque=separate
) else (
    echo Opción inválida.
    pause
    goto menu
)

echo Iniciando VM "%vmname%" en modo %arranque%...
VBoxManage startvm "%vmname%" --type %arranque%
pause
goto menu

:configurar_vram
cls
echo ==============================================
echo        Configurar VRAM de una máquina virtual
echo ==============================================
set /p vmname=Nombre de la VM a configurar VRAM: 
call :vm_exists "%vmname%"
set /p vram=Cantidad de memoria de video (VRAM) en MB (ejemplo: 16, 32, 64): 
VBoxManage modifyvm "%vmname%" --vram %vram%
echo VRAM configurada a %vram% MB para la VM "%vmname%"
pause
goto menu

:restaurar_sp
cls
echo ==============================================
echo          Restaurar una snapshot
echo ==============================================
set /p vmname=Nombre de la VM: 
call :vm_exists "%vmname%"
set /p snapshotname=Nombre de la máquina a restaurar: 
VBoxManage snapshot "%vmname%" restore "%snapshotname%"
pause
goto menu

:reiniciar_vm
cls
echo ==============================================
echo        Reiniciar una máquina virtual
echo ==============================================
set /p vmname=Nombre de la VM a reiniciar: 
call :vm_exists "%vmname%"
VBoxManage controlvm "%vmname%" reset
pause
goto menu

:reanudar_vm
cls
echo ==============================================
echo         Reanudar una máquina virtual
echo ==============================================
set /p vmname=Nombre de la VM a reanudar: 
call :vm_exists "%vmname%"
VBoxManage controlvm "%vmname%" resume
pause
goto menu

:estado_vm
cls
echo ==============================================
echo        Mostrar estado actual de una VM
echo ==============================================
set /p vmname=Nombre de la VM: 
call :vm_exists "%vmname%"
echo ----------------------------------------------
VBoxManage showvminfo "%vmname%" --machinereadable | findstr /R /C:"VMState=" /C:"memory=" /C:"cpus=" /C:"GuestOS=" /C:"Uptime="
if %errorlevel% equ 0 (
    echo ----------------------------------------------
    echo NOTA: Estado puede ser 'running', 'powered off', etc.
) else (
    echo No se pudo obtener la información de estado de "%vmname%".
)
pause
goto menu

:aumentar_disco
cls
echo ==============================================
echo Redimensionar disco duro virtual
echo ==============================================
set /p vmname=Nombre de la VM:
call :vm_exists "%vmname%"
set /p newsize=Nuevo tamaño del disco (en MB):

REM Obtener automáticamente el disco VDI adjunto al puerto 0 del SATA Controller
set "diskpath="
for /f "tokens=2 delims==" %%i in ('VBoxManage showvminfo "%vmname%" --machinereadable ^| findstr /R /C:"SATA Controller.*0-0.*\.vdi"') do set "diskpath=%%i"

REM Limpiar comillas si las hay
set "diskpath=%diskpath:"=%"

if defined diskpath (
echo Disco actual: %diskpath%
echo Redimensionando a %newsize% MB...
VBoxManage modifyhd "%diskpath%" --resize %newsize%
if %errorlevel% equ 0 (
echo Disco redimensionado exitosamente.
) else (
echo Ocurrió un error al redimensionar el disco.
)
) else (
echo No se encontró un disco duro VDI asociado a "%vmname%".
)
pause
goto menu

:aumentar_vram
cls
echo ==============================================
echo Modificar memoria de video (VRAM)
echo ==============================================
set /p vmname=Nombre de la VM:
call :vm_exists "%vmname%"
set /p vram=Cantidad de VRAM (en MB, ej. 16, 32, 128):

REM Validación básica del valor ingresado
REM Evita valores menores a 1 o mayores a 256
set /a vram_val=%vram%
if %vram_val% lss 1 (
echo ERROR: La VRAM debe ser mayor a 0 MB.
pause
goto menu
)
if %vram_val% gtr 256 (
echo ERROR: La VRAM máxima recomendada es 256 MB.
pause
goto menu
)

VBoxManage modifyvm "%vmname%" --vram %vram%
if %errorlevel% equ 0 (
echo Memoria de video configurada a %vram% MB para "%vmname%".
) else (
echo Ocurrió un error al modificar la VRAM.
)
pause
goto menu 	

:mostrar_disco_info
cls
echo ==============================================
echo    Información del disco duro virtual
echo ==============================================
set /p vmname=Nombre de la VM a configurar: 
call :vm_exists "%vmname%"
call :ensure_storagectl "%vmname%"
set /p disko=DIRECTORIO de disco duro (incluya la ruta completa y el nombre del archivo, ej. C:\ruta\a\disco.vdi): 
call :hdd_exists "%disko%"
VBoxManage showhdinfo "%disko%"
pause
goto menu

:clonar_disco
cls
echo ==============================================
echo    	Clonación del disco duro virtual
echo ==============================================

set /p disko=DIRECTORIO de disco duro a clonar (incluya la ruta completa y el nombre del archivo, ej. C:\ruta\a\disco.vdi): 
call :hdd_exists "%disko%"
set /p disko2=DIRECTORIO de disco duro objetivo (incluya la ruta completa y el nombre del archivo, ej. C:\ruta\a\disco.vdi): 
call :hdd_exists "%disko2%"
VBoxManage clonehd "%disko%" "%disko2%"
pause
goto menu

:eliminar_maquina
cls
echo ==============================================
echo  Eliminar una MV
echo ==============================================
set /p vmname=Nombre de la VM: 
call :vm_exists "%vmname%"
VBoxManage unregistervm --delete %vmname%
pause
goto menu 

:ver_uuid
cls
echo ==============================================
echo        Ver UUID de una máquina virtual
echo ==============================================
set /p vmname=Nombre de la VM: 
VBoxManage showvminfo "%vmname%" | findstr /C:"UUID:"
pause
goto menu

:salir
exit
