@echo off
chcp 65001 >nul

set /p taskName=Nombre de la tarea: 
set /p taskPath=Script a ejecutar (Ejemplo: 'C:\Ruta\al\generate_snapshot.bat'): 
set /p taskTime=Hora de en que se ejecutará la tarea (formato HH:MM 24hrs):
echo Periodo de ejecución de la tarea
echo 1. Diario
echo 2. Semanal
echo 3. Mensual
set /p choice=Seleccione una opción: 

if %choice%==1 goto daily
if %choice%==2 goto weekly
if %choice%==3 goto monthly

:daily

cls
echo ==============================================
echo             Crear un snapshot
echo ==============================================
set /p vmname=Nombre de la VM: 
set /p snapshotname=Nombre del snapshot: 
set /p description=Descripción del snapshot: 

call: C:\Ruta\al\generate_snapshot.bat "%vname%" "%snapshotname%" "%description%"

schtasks /create /tn "'%taskName%'" /tr "'%taskPath%'" /sc daily /st %taskTime%
pause
goto:eof

:weekly
schtasks /create /tn "'%taskName%'" /tr "'%taskPath%'" /sc weekly /st %taskTime%
pause
	

:monthly
schtasks /create /tn "'%taskName%'" /tr "'%taskPath%'" /sc monthly /st %taskTime%
pause

