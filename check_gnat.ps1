# Quick script to check if GNAT is installed
# Run with: .\check_gnat.ps1

Write-Host "Checking for GNAT installation..." -ForegroundColor Cyan
Write-Host ""

# Check for gnat command
$gnatFound = $false
try {
    $gnatVersion = gnat --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] GNAT found!" -ForegroundColor Green
        Write-Host $gnatVersion
        $gnatFound = $true
    }
} catch {
    Write-Host "[X] GNAT not found in PATH" -ForegroundColor Red
}

Write-Host ""

# Check for gprbuild
$gprbuildFound = $false
try {
    $gprbuildVersion = gprbuild --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] GPRbuild found!" -ForegroundColor Green
        Write-Host $gprbuildVersion
        $gprbuildFound = $true
    }
} catch {
    Write-Host "[X] GPRbuild not found in PATH" -ForegroundColor Red
}

Write-Host ""

# Check common installation locations
Write-Host "Checking common installation locations..." -ForegroundColor Cyan
$commonPaths = @(
    "C:\GNAT\2021\bin\gnat.exe",
    "C:\GNAT\2022\bin\gnat.exe",
    "C:\GNAT\2023\bin\gnat.exe",
    "C:\GNAT\2024\bin\gnat.exe",
    "C:\Program Files\GNAT\bin\gnat.exe"
)

$foundPath = $false
foreach ($path in $commonPaths) {
    if (Test-Path $path) {
        Write-Host "[OK] Found GNAT at: $path" -ForegroundColor Green
        $foundPath = $true
        $binDir = Split-Path $path
        Write-Host "  Add this to PATH: $binDir" -ForegroundColor Yellow
    }
}

if (-not $foundPath) {
    Write-Host "[X] GNAT not found in common locations" -ForegroundColor Red
}

Write-Host ""

# Summary
if ($gnatFound -and $gprbuildFound) {
    Write-Host "=== Status: READY TO BUILD ===" -ForegroundColor Green
    Write-Host "You can now run: gprbuild -P ada_project.gpr" -ForegroundColor White
} else {
    Write-Host "=== Status: GNAT NOT INSTALLED ===" -ForegroundColor Red
    Write-Host "Please install GNAT from: https://www.adacore.com/download" -ForegroundColor Yellow
    Write-Host "See INSTALL_GUIDE.md for detailed instructions" -ForegroundColor Yellow
}
