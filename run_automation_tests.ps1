$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "==> Backend syntax check" -ForegroundColor Cyan
Get-ChildItem -Path (Join-Path $root "apps\api\src") -Recurse -Filter *.js | ForEach-Object {
  node -c $_.FullName | Out-Null
}

Write-Host "==> Backend unit tests" -ForegroundColor Cyan
Push-Location (Join-Path $root "apps\api")
try {
  npm.cmd test
} finally {
  Pop-Location
}

Write-Host "==> Flutter analyze" -ForegroundColor Cyan
Push-Location (Join-Path $root "apps\mobile")
try {
  flutter analyze

  Write-Host "==> Flutter tests" -ForegroundColor Cyan
  flutter test
} finally {
  Pop-Location
}

Write-Host "==> All automation checks passed" -ForegroundColor Green
