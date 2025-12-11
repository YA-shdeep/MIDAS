# =====================================================
# Clinical Image Labelling Tool - PowerShell Launcher
# XC_labeller.ps1
# =====================================================

# Clear screen for clean output
Clear-Host

# Display header
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Clinical Image Labelling Tool" -ForegroundColor White
Write-Host "  XC/Clinical Photography Annotator" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------
# 1. Find Python Installation
# ---------------------------------------------
Write-Host "[1/4] Checking Python installation..." -ForegroundColor Yellow

$python = $null
$pythonCommands = @("python", "python3", "py")
$pythonFound = $false

foreach ($cmd in $pythonCommands) {
    try {
        $pythonTest = Get-Command $cmd -ErrorAction SilentlyContinue
        if ($pythonTest) {
            $version = & $pythonTest --version 2>&1 | Out-String

            # Check if version is 3.8 or higher
            if ($version -match "Python 3\.([8-9]|1[0-9])") {
                $python = $pythonTest
                $pythonFound = $true
                Write-Host "  ✓ Found: $($version.Trim())" -ForegroundColor Green
                Write-Host "    Location: $($pythonTest.Source)" -ForegroundColor Gray
                break
            }
            elseif ($version -match "Python 3\.") {
                Write-Host "  ⚠ Found: $($version.Trim()) - but version 3.8+ required" -ForegroundColor Yellow
            }
        }
    }
    catch {
        continue
    }
}

if (-not $pythonFound) {
    Write-Host ""
    Write-Host "  ✗ ERROR: Python 3.8+ not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Installation Instructions:" -ForegroundColor Yellow
    Write-Host "  1. Go to: https://www.python.org/downloads/" -ForegroundColor White
    Write-Host "  2. Download Python 3.8 or higher" -ForegroundColor White
    Write-Host "  3. Run the installer" -ForegroundColor White
    Write-Host "  4. ✓ CHECK: 'Add Python to PATH' (IMPORTANT!)" -ForegroundColor Cyan
    Write-Host "  5. Complete the installation" -ForegroundColor White
    Write-Host "  6. Restart this tool" -ForegroundColor White
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# ---------------------------------------------
# 2. Locate Python Script
# ---------------------------------------------
Write-Host ""
Write-Host "[2/4] Locating Python script..." -ForegroundColor Yellow

$scriptPath = Join-Path $PSScriptRoot "XC_labeller.py"

if (-not (Test-Path $scriptPath)) {
    Write-Host "  ✗ ERROR: 'XC_labeller.py' not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Expected location: $scriptPath" -ForegroundColor Yellow
    Write-Host "  Current directory: $PSScriptRoot" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Please ensure the following files are in the same folder:" -ForegroundColor White
    Write-Host "  - START_HERE.bat" -ForegroundColor Gray
    Write-Host "  - XC_labeller.ps1" -ForegroundColor Gray
    Write-Host "  - XC_labeller.py" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host "  ✓ Script found: XC_labeller.py" -ForegroundColor Green
Write-Host "    Location: $scriptPath" -ForegroundColor Gray

# ---------------------------------------------
# 3. Check and Install Dependencies
# ---------------------------------------------
Write-Host ""
Write-Host "[3/4] Checking dependencies..." -ForegroundColor Yellow

$requiredModules = @{
    "PIL" = "Pillow"      # Import name = Package name
    "tkinter" = $null      # tkinter comes with Python
}

$missingModules = @()
$tkinterMissing = $false

foreach ($module in $requiredModules.Keys) {
    Write-Host "  Checking $module..." -ForegroundColor Gray -NoNewline

    $checkResult = & $python.Source -c "import $module" 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Host " ✗ Missing" -ForegroundColor Red
        $missingModules += $module

        if ($module -eq "tkinter") {
            $tkinterMissing = $true
        }
    }
    else {
        Write-Host " ✓ OK" -ForegroundColor Green
    }
}

# Install missing packages (except tkinter)
if ($missingModules.Count -gt 0) {
    Write-Host ""
    Write-Host "  ⚠ Missing dependencies detected" -ForegroundColor Yellow
    Write-Host ""

    foreach ($module in $missingModules) {
        if ($module -eq "tkinter") {
            continue  # Handle tkinter separately
        }

        $packageName = $requiredModules[$module]
        if ($packageName) {
            Write-Host "  Installing $packageName..." -ForegroundColor Cyan

            try {
                $installOutput = & $python.Source -m pip install --user $packageName --quiet 2>&1

                if ($LASTEXITCODE -eq 0) {
                    Write-Host "    ✓ $packageName installed successfully" -ForegroundColor Green
                }
                else {
                    Write-Host "    ✗ Failed to install $packageName" -ForegroundColor Red
                    Write-Host "    Try manually: pip install $packageName" -ForegroundColor Yellow
                }
            }
            catch {
                Write-Host "    ✗ Error installing $packageName" -ForegroundColor Red
                Write-Host "    Error: $_" -ForegroundColor Gray
            }
        }
    }

    # Handle tkinter separately
    if ($tkinterMissing) {
        Write-Host ""
        Write-Host "  ⚠ tkinter is missing!" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  tkinter usually comes with Python but may need reinstallation:" -ForegroundColor White
        Write-Host ""
        Write-Host "  Windows:" -ForegroundColor Cyan
        Write-Host "  1. Go to 'Add or Remove Programs'" -ForegroundColor Gray
        Write-Host "  2. Find Python installation" -ForegroundColor Gray
        Write-Host "  3. Click 'Modify'" -ForegroundColor Gray
        Write-Host "  4. Ensure 'tcl/tk and IDLE' is checked" -ForegroundColor Gray
        Write-Host "  5. Complete the modification" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  The application may not work without tkinter." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Do you want to continue anyway? (Y/N): " -ForegroundColor White -NoNewline

        $response = Read-Host
        if ($response -notmatch '^[Yy]') {
            Write-Host ""
            Write-Host "  Installation cancelled. Please install tkinter and try again." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Press any key to exit..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 1
        }
    }

    Write-Host ""
    Write-Host "  ✓ Dependency check completed" -ForegroundColor Green
}
else {
    Write-Host ""
    Write-Host "  ✓ All dependencies are present" -ForegroundColor Green
}

# ---------------------------------------------
# 4. Launch GUI Application
# ---------------------------------------------
Write-Host ""
Write-Host "[4/4] Launching application..." -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Starting GUI..." -ForegroundColor White
Write-Host "  Please wait for the window to appear" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Small delay for readability
Start-Sleep -Milliseconds 500

# Launch the Python script
try {
    & $python.Source $scriptPath
    $exitCode = $LASTEXITCODE

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan

    if ($exitCode -eq 0) {
        Write-Host "  ✓ Application closed successfully" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Cyan
    }
    else {
        Write-Host "  ⚠ Application exited with code: $exitCode" -ForegroundColor Yellow
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""

        if ($exitCode -eq 1) {
            Write-Host "  Common causes:" -ForegroundColor Yellow
            Write-Host "  - User cancelled the operation" -ForegroundColor Gray
            Write-Host "  - Missing dependencies" -ForegroundColor Gray
            Write-Host "  - File permissions issue" -ForegroundColor Gray
        }
        else {
            Write-Host "  If this was unexpected, check:" -ForegroundColor Yellow
            Write-Host "  - Python installation is complete" -ForegroundColor Gray
            Write-Host "  - All required files are present" -ForegroundColor Gray
            Write-Host "  - You have proper file permissions" -ForegroundColor Gray
        }
    }
}
catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  ✗ ERROR: Failed to run application" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Error details:" -ForegroundColor Yellow
    Write-Host "  $_" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Troubleshooting steps:" -ForegroundColor Yellow
    Write-Host "  1. Verify Python is installed correctly" -ForegroundColor Gray
    Write-Host "  2. Check XC_labeller.py exists and is not corrupted" -ForegroundColor Gray
    Write-Host "  3. Try running manually: python XC_labeller.py" -ForegroundColor Gray
    Write-Host "  4. Check file permissions" -ForegroundColor Gray
    Write-Host ""

    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# ---------------------------------------------
# Exit Message
# ---------------------------------------------
Write-Host ""
Write-Host "Press any key to close this window..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Exit with the same code as the Python script
exit $exitCode
