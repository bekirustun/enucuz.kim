# -----------------------------------------------
# Ustun Group / enucuz.kim Full Sağlık Taraması
# Esma tarafından kodlandı.
# -----------------------------------------------

# 1. HTTP/HTTPS Endpoint Sağlık Kontrolü
$urls = @(
    "http://localhost:3000",
    "http://localhost:3000/api/health",
    "http://localhost:3001",
    "https://enucuz.kim"
)
Write-Host "`n🟢 HTTP/HTTPS endpoint kontrolleri:" -ForegroundColor Cyan
foreach ($url in $urls) {
    try {
        $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
        if ($resp.StatusCode -eq 200) {
            Write-Host "    [OK] $url" -ForegroundColor Green
        } else {
            Write-Host "    [WARN] $url - $($resp.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "    [ERROR] $url erişilemiyor!" -ForegroundColor Red
    }
}

# 2. Port Kontrolü (örn. 3000, 3001, 5432 PostgreSQL)
$ports = @(3000, 3001, 5432)
Write-Host "`n🔵 Açık port kontrolleri:" -ForegroundColor Cyan
foreach ($port in $ports) {
    $tcp = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($tcp) {
        Write-Host "    [OK] Port $port açık." -ForegroundColor Green
    } else {
        Write-Host "    [ERROR] Port $port kapalı veya kullanılmıyor!" -ForegroundColor Red
    }
}

# 3. Klasör ve Dosya Kontrolü
$paths = @(
    "D:\Ustunnet\sitelerim\enucuz.kim\apps\admin\pages",
    "D:\Ustunnet\sitelerim\enucuz.kim\apps\web\pages",
    "D:\Ustunnet\sitelerim\enucuz.kim\node_modules"
)
Write-Host "`n🟡 Klasör/dosya kontrolleri:" -ForegroundColor Cyan
foreach ($p in $paths) {
    if (Test-Path $p) {
        Write-Host "    [OK] $p var." -ForegroundColor Green
    } else {
        Write-Host "    [ERROR] $p bulunamadı!" -ForegroundColor Red
    }
}

# 4. Node.js, pnpm, git ve PostgreSQL Versiyonları
Write-Host "`n🟠 Versiyon kontrolleri:" -ForegroundColor Cyan

function Check-Version {
    param(
        [string]$cmd,
        [string]$desc
    )
    try {
        $v = & $cmd
        Write-Host ("    [OK] {0}: {1}" -f $desc, $v) -ForegroundColor Green
    } catch {
        Write-Host ("    [ERROR] {0} bulunamadı!" -f $desc) -ForegroundColor Red
    }
}

Check-Version "node --version" "Node.js"
Check-Version "pnpm --version" "pnpm"
Check-Version "git --version" "Git"
Check-Version "psql --version" "PostgreSQL (psql)"

# 5. Windows Servis Kontrolü (örn. postgresql, docker)
$services = @(
    "postgresql*",
    "docker*"
)
Write-Host "`n🟣 Servis kontrolleri:" -ForegroundColor Cyan
foreach ($serviceName in $services) {
    $svc = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($svc) {
        foreach ($s in $svc) {
            if ($s.Status -eq "Running") {
                Write-Host ("    [OK] {0} çalışıyor." -f $s.Name) -ForegroundColor Green
            } else {
                Write-Host ("    [WARN] {0} durdurulmuş!" -f $s.Name) -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host ("    [ERROR] {0} bulunamadı!" -f $serviceName) -ForegroundColor Red
    }
}

# 6. Disk Alanı Kontrolü (en az 2 GB boş alan)
Write-Host "`n⚪ Disk alanı kontrolü:" -ForegroundColor Cyan
$disk = Get-PSDrive -Name D -ErrorAction SilentlyContinue
if ($null -eq $disk) {
    Write-Host "    [ERROR] D sürücüsü bulunamadı!" -ForegroundColor Red
} else {
    $freeGB = [math]::Round($disk.Free / 1GB, 2)
    if ($disk.Free -lt 2GB) {
        Write-Host ("    [WARN] D sürücüsünde azalan boş alan! ({0} GB)" -f $freeGB) -ForegroundColor Yellow
    } else {
        Write-Host ("    [OK] D sürücüsünde yeterli alan var. ({0} GB)" -f $freeGB) -ForegroundColor Green
    }
}

# 7. .env Dosya Kontrolü
$envFile = "D:\Ustunnet\sitelerim\enucuz.kim\.env"
Write-Host "`n🟤 .env dosyası kontrolü:" -ForegroundColor Cyan
if (Test-Path $envFile) {
    Write-Host "    [OK] .env dosyası mevcut." -ForegroundColor Green
} else {
    Write-Host "    [ERROR] .env dosyası eksik!" -ForegroundColor Red
}

Write-Host "`n--- Tüm sağlık kontrolleri tamamlandı! ---" -ForegroundColor Cyan
