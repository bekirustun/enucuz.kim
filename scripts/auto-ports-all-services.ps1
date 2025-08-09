# scripts/auto-ports-all-services.ps1
Write-Host "==== Auto Port & Main.ts Fix for All Services ====" -ForegroundColor Cyan

$root = Get-Location
$servicesDir = Join-Path $root "services"

if (!(Test-Path $servicesDir)) {
  Write-Host "services/ klasörü bulunamadı: $servicesDir" -ForegroundColor Red
  exit 1
}

# Helper: find free TCP port
function Get-FreePort {
  $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, 0)
  $listener.Start()
  $port = $listener.LocalEndpoint.Port
  $listener.Stop()
  return $port
}

$serviceFolders = Get-ChildItem -Path $servicesDir -Directory | Where-Object { $_.Name -like "*-service" }

if (-not $serviceFolders) {
  Write-Host "services/ altında *-service klasörü bulunamadı." -ForegroundColor Yellow
  exit 0
}

foreach ($svc in $serviceFolders) {
  $svcName = $svc.Name
  $svcPath = $svc.FullName
  $src = Join-Path $svcPath "src"
  $main = Join-Path $src "main.ts"
  $pkgFile = Join-Path $svcPath "package.json"
  $envFile = Join-Path $svcPath ".env"

  Write-Host "`n--- [$svcName] işleniyor ---" -ForegroundColor Green

  if (!(Test-Path $main)) {
    Write-Host ">> $svcName: src/main.ts bulunamadı, atlanıyor." -ForegroundColor DarkYellow
    continue
  }

  # 1) Ensure dotenv import + config at top of main.ts (non-destructive)
  $mainText = Get-Content $main -Raw

  if ($mainText -notmatch "dotenv") {
    $dotenvHeader = "import * as dotenv from 'dotenv';`r`ndotenv.config();`r`n"
    # inject after first import if possible
    if ($mainText -match "import\s") {
      $mainText = $mainText -replace "(import[^\n]*\n)", "$0$dotenvHeader"
    } else:
      $mainText = $dotenvHeader + $mainText
    # write back after adding dotenv
    Set-Content -Path $main -Encoding UTF8 -Value $mainText
    $mainText = Get-Content $main -Raw
    Write-Host ">> $svcName: dotenv import/config eklendi." -ForegroundColor Yellow
  }

  # 2) Replace any hardcoded listen(<number>) with env-based
  $pattern = "await\s*app\.listen\s*\(\s*\d+\s*\)"
  $replacement = "await app.listen(process.env.PORT ? Number(process.env.PORT) : 3005)"
  if ($mainText -match $pattern) {
    $mainText = [regex]::Replace($mainText, $pattern, $replacement)
    Set-Content -Path $main -Encoding UTF8 -Value $mainText
    Write-Host ">> $svcName: app.listen(<num>) -> env tabanlı porta çevrildi." -ForegroundColor Yellow
  } elseif ($mainText -notmatch "process\.env\.PORT") {
    # no explicit listen number, still enforce an env-based await app.listen near bootstrap
    $mainText = $mainText -replace "await\s+app\.listen\((.*?)\)", $replacement
    Set-Content -Path $main -Encoding UTF8 -Value $mainText
    Write-Host ">> $svcName: app.listen env tabanlı hale zorlandı." -ForegroundColor Yellow
  } else {
    Write-Host ">> $svcName: app.listen zaten env tabanlı." -ForegroundColor DarkGray
  }

  # 3) Ensure package.json has dev script and ts-node-dev dependency
  if (Test-Path $pkgFile) {
    try {
      $pkg = Get-Content $pkgFile -Raw | ConvertFrom-Json
      if (-not $pkg.scripts) { $pkg | Add-Member -MemberType NoteProperty -Name scripts -Value @{} }
      $pkg.scripts.dev = "ts-node-dev --respawn --transpile-only src/main.ts"
      $json = $pkg | ConvertTo-Json -Depth 20
      Set-Content -Path $pkgFile -Encoding UTF8 -Value $json
      Write-Host ">> $svcName: package.json dev script garanti." -ForegroundColor DarkGray
    } catch {
      Write-Host ">> $svcName: package.json okunamadı/düzeltilemedi." -ForegroundColor Red
    }
  }

  # 4) Assign a free port to .env for this service
  $port = Get-FreePort
  "PORT=$port" | Set-Content -Encoding UTF8 $envFile
  Write-Host ">> $svcName: .env -> PORT=$port" -ForegroundColor Yellow
}

Write-Host "`n==== Tamamlandı. Her servis için .env PORT atandı ve main.ts düzeltildi. ====" -ForegroundColor Cyan
Write-Host "Her servisi tek tek çalıştır:  pnpm --filter \"<service-name>\" dev"
