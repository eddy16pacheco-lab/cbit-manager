@echo off
REM Lanzador de AdminPyme: arranca el servidor local y abre el navegador.
REM Cerrar esta ventana SI apaga el servidor (es la que lo mantiene corriendo).

cd /d "%~dp0"

echo Iniciando AdminPyme...

REM Abre el navegador un par de segundos despues, en segundo plano,
REM mientras el servidor arranca en esta misma ventana
start "" cmd /c "timeout /t 3 /nobreak > nul && start http://localhost:3000"

node server.js

echo.
echo AdminPyme se detuvo.
pause
