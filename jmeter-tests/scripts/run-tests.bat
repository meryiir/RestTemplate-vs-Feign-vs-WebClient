@echo off
REM Script Windows pour exécuter les tests de performance JMeter
REM Usage: run-tests.bat [rest|feign|webclient] [threads] [loops]

set METHOD=%1
if "%METHOD%"=="" set METHOD=rest

set THREADS=%2
if "%THREADS%"=="" set THREADS=10

set LOOPS=%3
if "%LOOPS%"=="" set LOOPS=50

echo =========================================
echo Test de performance: %METHOD%
echo Threads: %THREADS%
echo Loops: %LOOPS%
echo =========================================

REM Vérifier que JMeter est installé
where jmeter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo JMeter n'est pas installé ou n'est pas dans le PATH
    exit /b 1
)

REM Déterminer le fichier JMX
set JMX_FILE=
if "%METHOD%"=="rest" set JMX_FILE=..\test-resttemplate.jmx
if "%METHOD%"=="feign" set JMX_FILE=..\test-feign.jmx
if "%METHOD%"=="webclient" set JMX_FILE=..\test-webclient.jmx

if "%JMX_FILE%"=="" (
    echo Méthode inconnue: %METHOD%
    echo Utilisez: rest, feign, ou webclient
    exit /b 1
)

REM Vérifier que le fichier existe
if not exist "%JMX_FILE%" (
    echo Fichier JMX non trouvé: %JMX_FILE%
    exit /b 1
)

REM Créer le répertoire de résultats
set RESULTS_DIR=..\results
if not exist "%RESULTS_DIR%" mkdir "%RESULTS_DIR%"

REM Nom du fichier de résultats
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set TIMESTAMP=%datetime:~0,8%_%datetime:~8,6%
set RESULT_FILE=%RESULTS_DIR%\%METHOD%_%THREADS%threads_%TIMESTAMP%.jtl
set REPORT_DIR=%RESULTS_DIR%\%METHOD%_%THREADS%threads_%TIMESTAMP%_report

echo Exécution du test...
echo Résultats: %RESULT_FILE%
echo.

REM Exécuter JMeter
jmeter -n -t "%JMX_FILE%" ^
    -JTHREADS=%THREADS% ^
    -JLOOPS=%LOOPS% ^
    -JRAMP_UP=10 ^
    -l "%RESULT_FILE%" ^
    -e -o "%REPORT_DIR%"

echo.
echo =========================================
echo Test terminé!
echo Résultats: %RESULT_FILE%
echo Rapport HTML: %REPORT_DIR%\index.html
echo =========================================
