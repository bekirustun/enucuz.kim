#requires -Version 5.1
<#
  Monorepo: enucuz.kim
  İşlev: user-service PORT'unu gateway-service USER_SERVICE_URL'e senkronlar
#>

param(
    [string]$RepoRoot = "D:\U\S\enucuz.kim"
)

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "✔ $msg" -ForegroundColor Green }
function Write-Err($msg)  { Write-Host "✖ $msg" -ForegroundColor Red }

$userEnvPath = Join-Path $RepoRoot "services\user-service\.env"
$gatewayEnvPath = Join-Path $RepoRoot "services\gateway-service\.env"

if (!(Test-Path -LiteralPath $userEnvPath)) {
    Write-Err "user-service .env bulunamadı: $userEnvPath"
    exit 1
}
if (!(Test-Path -LiteralPath $gatewayEnvPath)) {
    Write-Err "gateway-service .env bulunamadı: $gatewayEnvPath"
    exit 1
}

# User-service PORT'unu oku
$userPort = (Select-String -Path $userEnvPath -Pattern '^PORT=(\d+)$').Matches | Select-Object -Last 1
if (-not $userPort) {
    Write-Err "user-service .env içinde PORT bulunamadı."
    exit 1
}
$userPortValue = $userPort.Groups[1].Value
Write-Ok "user-service PORT: $userPortValue"

# Gateway .env içinde USER_SERVICE_URL güncelle
$gwLines = Get-Content -LiteralPath $gatewayEnvPath -Encoding UTF8
$updated = $false
for ($i = 0; $i -lt $gwLines.Count; $i++) {
    if ($gwLines[$i] -match '^USER_SERVICE_URL=') {
        $gwLines[$i] = "USER_SERVICE_URL=http://localhost:$userPortValue"
        $updated = $true
    }
}
if (-not $updated) {
    $gwLines += "USER_SERVICE_URL=http://localhost:$userPortValue"
}
Set-Content -LiteralPath $gatewayEnvPath -Value $gwLines -Encoding UTF8
Write-Ok "Gateway USER_SERVICE_URL güncellendi."

# Gateway'i yeniden başlat
$gatewayDir = Join-Path $RepoRoot "services\gateway-service"
Write-Step "Gateway yeniden başlatılıyor..."
Stop-Process -Name "node" -Force -ErrorAction SilentlyContinue
Start-Process -FilePath "powershell" -ArgumentList "-NoExit","-Command","cd `"$gatewayDir`"; pnpm run dev"
Write-Ok "Gateway başlatıldı: http://localhost:(Select-String -Path $gatewayEnvPath -Pattern '^PORT=(\d+)$').Matches[0].Groups[1].Value"
