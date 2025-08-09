# scripts/run-gateway-dev.ps1
Write-Host ">> Gateway dev runner (otomatik boş port bulma)" -ForegroundColor Cyan
$svc = "services\gateway-service"
$src = Join-Path $svc "src"
$main = Join-Path $src "main.ts"
$envFile = Join-Path $svc ".env"

# Boş port bulma fonksiyonu
function Get-FreePort {
    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, 0)
    $listener.Start()
    $port = $listener.LocalEndpoint.Port
    $listener.Stop()
    return $port
}

# .env dosyası ve port ayarı
$freePort = Get-FreePort
if (-not (Test-Path $envFile) -or -not (Select-String -Path $envFile -Pattern "^PORT=" -Quiet)) {
    Write-Host ">> PORT ayarı ekleniyor (.env -> $freePort)" -ForegroundColor Yellow
    "PORT=$freePort" | Set-Content -Encoding UTF8 $envFile
} else {
    # Varsa güncelle
    (Get-Content $envFile) -replace "^PORT=.*", "PORT=$freePort" | Set-Content -Encoding UTF8 $envFile
    Write-Host ">> PORT .env içinde $freePort olarak güncellendi" -ForegroundColor Yellow
}

# main.ts kontrol/güncelleme
if (!(Test-Path $main) -or -not (Select-String -Path $main -Pattern "process\.env\.PORT" -Quiet)) {
    Write-Host ">> main.ts içine dinamik PORT ekleniyor" -ForegroundColor Yellow
    # Eski 3000 değerini kaldır
    (Get-Content $main) -replace "3000", "process.env.PORT ? Number(process.env.PORT) : 3005" |
        Set-Content -Encoding UTF8 $main
}

# package.json dev script garanti
$pkgFile = Join-Path $svc "package.json"
$pkg = Get-Content $pkgFile -Raw | ConvertFrom-Json
if (-not $pkg.scripts) { $pkg | Add-Member -MemberType NoteProperty -Name scripts -Value @{} }
$pkg.scripts.dev = "ts-node-dev --respawn --transpile-only src/main.ts"
$pkg | ConvertTo-Json -Depth 12 | Set-Content -Encoding UTF8 $pkgFile

Push-Location $svc
Write-Host ">> CWD: $(Get-Location)" -ForegroundColor DarkCyan
Write-Host ">> PORT: $freePort" -ForegroundColor DarkCyan
Write-Host ">> pnpm install (local)" -ForegroundColor Yellow
pnpm install

Write-Host ">> pnpm run dev" -ForegroundColor Green
pnpm run dev
Pop-Location
