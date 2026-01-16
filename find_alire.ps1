# Script to find and configure Alire on Windows

Write-Host "=== Finding Alire Installation ===" -ForegroundColor Cyan
Write-Host ""

# Common Alire installation locations
$searchPaths = @(
    "$env:USERPROFILE\.local\bin\alr.exe",
    "$env:LOCALAPPDATA\alire\bin\alr.exe",
    "$env:APPDATA\alire\bin\alr.exe",
    "C:\alire\bin\alr.exe",
    "$env:USERPROFILE\alire\bin\alr.exe",
    "$env:USERPROFILE\AppData\Local\alire\bin\alr.exe"
)

$found = $false
$alirePath = $null

foreach ($path in $searchPaths) {
    if (Test-Path $path) {
        Write-Host "[OK] Found Alire at: $path" -ForegroundColor Green
        $alirePath = Split-Path $path -Parent
        $found = $true
        break
    }
}

if (-not $found) {
    Write-Host "[X] Alire not found in common locations" -ForegroundColor Red
    Write-Host ""
    Write-Host "Trying to search in user directory..." -ForegroundColor Yellow
    
    # Try searching in user directory
    $userSearch = Get-ChildItem -Path "$env:USERPROFILE" -Recurse -Filter "alr.exe" -ErrorAction SilentlyContinue -Depth 4 | Select-Object -First 1
    if ($userSearch) {
        Write-Host "[OK] Found Alire at: $($userSearch.FullName)" -ForegroundColor Green
        $alirePath = Split-Path $userSearch.FullName -Parent
        $found = $true
    }
}

Write-Host ""

if ($found) {
    Write-Host "=== Alire Location ===" -ForegroundColor Cyan
    Write-Host "Directory: $alirePath" -ForegroundColor White
    Write-Host ""
    
    # Test if it works
    Write-Host "Testing Alire..." -ForegroundColor Yellow
    & "$alirePath\alr.exe" version
    
    Write-Host ""
    Write-Host "=== Adding to PATH for this session ===" -ForegroundColor Cyan
    $env:PATH = "$alirePath;$env:PATH"
    Write-Host "Added to PATH: $alirePath" -ForegroundColor Green
    Write-Host ""
    Write-Host "Testing 'alr' command..." -ForegroundColor Yellow
    alr version
    
    Write-Host ""
    Write-Host "=== To make this permanent ===" -ForegroundColor Cyan
    Write-Host "Run this command (as Administrator if needed):" -ForegroundColor Yellow
    Write-Host "[Environment]::SetEnvironmentVariable('Path', `$env:Path + ';$alirePath', 'User')" -ForegroundColor White
    Write-Host ""
    Write-Host "Or manually add to PATH:" -ForegroundColor Yellow
    Write-Host "1. Win+X -> System -> Advanced system settings" -ForegroundColor White
    Write-Host "2. Environment Variables -> System/User Path -> Edit" -ForegroundColor White
    Write-Host "3. Add: $alirePath" -ForegroundColor White
    Write-Host ""
    Write-Host "After adding to PATH, restart PowerShell!" -ForegroundColor Yellow
    
} else {
    Write-Host "=== Alire Not Found ===" -ForegroundColor Red
    Write-Host ""
    Write-Host "If you just installed Alire:" -ForegroundColor Yellow
    Write-Host "1. Close and reopen PowerShell" -ForegroundColor White
    Write-Host "2. Run this script again: .\find_alire.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "If Alire is not installed:" -ForegroundColor Yellow
    Write-Host "Visit: https://alire.ada.dev/getting-started/" -ForegroundColor White
    Write-Host "Or install via: cargo install alr" -ForegroundColor White
}
