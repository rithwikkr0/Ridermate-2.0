#!/usr/bin/env pwsh
# RiderMate 2.0 - Build helper: auto-increments versionCode + injects BUILD_COMMIT
# Usage: pwsh scripts/build_with_commit.ps1 [-mode debug|apk|release]
param([string]$mode = "debug")
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Push-Location "$PSScriptRoot\.."

# 1. Git commit hash
$commit = (git rev-parse --short HEAD 2>&1)
if ($LASTEXITCODE -ne 0) { $commit = "unknown" }
$commit = $commit.Trim()
Write-Host "Build Commit: $commit" -ForegroundColor Cyan

# 2. Epoch-based monotonic versionCode (minutes since 2025-01-01)
$epoch = [DateTimeOffset]::new(2025,1,1,0,0,0,[TimeSpan]::Zero).ToUnixTimeSeconds()
$versionCode = [long]([DateTimeOffset]::UtcNow.ToUnixTimeSeconds() - $epoch)
Write-Host "VersionCode:  $versionCode" -ForegroundColor Cyan

# 3. Parse versionName from pubspec
$raw = (Get-Content pubspec.yaml | Select-String "^version:").ToString()
$versionName = ($raw -replace "version:\s*","").Trim().Split("+")[0]
Write-Host "VersionName:  $versionName" -ForegroundColor Cyan

# 4. Update pubspec.yaml with new build number
(Get-Content pubspec.yaml -Raw) -replace "(?m)^version:.*", "version: $versionName+$versionCode" | Set-Content pubspec.yaml -Encoding UTF8
Write-Host "Updated pubspec.yaml -> version: $versionName+$versionCode" -ForegroundColor Green

# 5. Build
$defines = @(
    "--dart-define=BUILD_COMMIT=$commit",
    "--dart-define=BUILD_VERSION=$versionName",
    "--dart-define=BUILD_NUMBER=$versionCode"
)
switch ($mode) {
    "debug"   { flutter build apk --debug @defines; $out = "build\app\outputs\flutter-apk\app-debug.apk" }
    "apk"     { flutter build apk @defines; $out = "build\app\outputs\flutter-apk\app-release.apk" }
    "release" { flutter build appbundle @defines; $out = "build\app\outputs\bundle\release\app-release.aab" }
    default   { Write-Error "Unknown mode: $mode"; Pop-Location; exit 1 }
}

# 6. Report
if (Test-Path $out) {
    $f = Get-Item $out
    Write-Host ""
    Write-Host "BUILD SUCCESSFUL" -ForegroundColor Green
    Write-Host "  Path:    $($f.FullName)"
    Write-Host "  Size:    $([math]::Round($f.Length/1KB,0)) KB"
    Write-Host "  Time:    $($f.LastWriteTime)"
    Write-Host "  Commit:  $commit"
    Write-Host "  Build#:  $versionCode"
    Write-Host ""
    Write-Host "In-app identifier (Settings > About RiderMate):" -ForegroundColor Yellow
    Write-Host "  v$versionName build $versionCode ($commit)" -ForegroundColor Yellow
} else {
    Write-Error "Artifact not found: $out"
    Pop-Location; exit 1
}
Pop-Location
