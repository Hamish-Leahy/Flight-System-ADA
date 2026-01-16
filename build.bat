@echo off
REM Build script for Ada Flight Control System (Windows)

echo Building Ada Flight Control System...
echo.

REM Build main program
echo Building main program...
gprbuild -P ada_project.gpr

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Build successful!
    echo Run with: bin\main.exe
) else (
    echo.
    echo Build failed!
    exit /b 1
)
