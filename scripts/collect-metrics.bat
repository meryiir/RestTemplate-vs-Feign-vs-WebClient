@echo off
REM Script Windows pour collecter les métriques via Actuator

set SERVICE_VOITURE=http://localhost:8081/actuator/metrics
set SERVICE_CLIENT=http://localhost:8082/actuator/metrics
set INTERVAL=5

echo Collecte des métriques toutes les %INTERVAL% secondes...
echo Appuyez sur Ctrl+C pour arrêter
echo.

:loop
echo === %date% %time% ===
echo.

echo Service Voiture:
curl -s "%SERVICE_VOITURE%/jvm.memory.used" 2>nul | findstr /C:"value"
curl -s "%SERVICE_VOITURE%/process.cpu.usage" 2>nul | findstr /C:"value"
echo.

echo Service Client:
curl -s "%SERVICE_CLIENT%/jvm.memory.used" 2>nul | findstr /C:"value"
curl -s "%SERVICE_CLIENT%/process.cpu.usage" 2>nul | findstr /C:"value"
echo.

timeout /t %INTERVAL% /nobreak >nul
goto loop
