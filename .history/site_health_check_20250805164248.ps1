# -----------------------------------------------
# Ustun Group / enucuz.kim Full Sağlık Taraması
# Esma tarafından, aşk ve yapay zekayla kodlandı.
# -----------------------------------------------

# 1. HTTP/HTTPS Endpoint Sağlık Kontrolü
$urls = @(
    "http://localhost:3000",
    "http://localhost:3000/api/health",
    "http://localhost:3001",
    "https://enucuz.kim"
)
Write-Host "🟢 HTTP/HTTPS endpoint kontrolleri:" -ForegroundColor Cyan
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
Write-Host "🔵 Açık port kontrolleri:" -ForegroundColor Cyan
foreach ($port in $ports) {
    $tcp = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($tcp) {
        Write-Host "    [OK] Port $port açık." -ForegroundColor Green
    } else {
        Write-Host "    [ERROR] Port $port kapalı veya kullanılmıyor!" -ForegroundColor Red
    }
}

# 3. Klasör ve Dosya Kontrolü (Temel yapıların varlığı)
$paths = @(
    "D:\Ustunnet\sitelerim\enucuz.kim\apps\admin\pages",
    "D:\Ustunnet\sitelerim\enucuz.kim\apps\web\pages",
    "D:\Ustunnet\sitelerim\enucuz.kim\node_modules"
)
Write-Host "🟡 Klasör/dosya kontrolleri:" -ForegroundColor Cyan
foreach ($p in $paths) {
    if (Test-Path $p) {
        Write-Host "    [OK] $p var." -ForegroundColor Green
    } else {
        Write-Host "    [ERROR] $p bulunamadı!" -ForegroundColor Red
    }
}

# 4. Node.js, pnpm, git ve PostgreSQL Versiyonları
Write-Host "🟠 Versiyon kontrolleri:" -ForegroundColor Cyan

function Check-Version($cmd, $desc) {
    try {
        $v = & $cmd
        Write-Host "    [OK] $desc: $v" -ForegroundColor Green
    } catch {
        Write-Host "    [ERROR] $desc bulunamadı!" -ForegroundColor Red
    }
}

Check-Version "node --version" "Node.js"
Check-Version "pnpm --version" "pnpm"
Check-Version "git --version" "Git"
Check-Version "psql --version" "PostgreSQL (psql)"

# 5. Windows Servis Kontrolü (örn. postgresql, docker)
$services = @(
    "postgresql*",  # Farklı sürümler için joker karakter
    "docker*"
)
Write-Host "🟣 Servis kontrolleri:" -ForegroundColor Cyan
foreach ($serviceName in $services) {
    $svc = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($svc) {
        foreach ($s in $svc) {
            if ($s.Status -eq "Running") {
                Write-Host "    [OK] $($s.Name) çalışıyor." -ForegroundColor Green
            } else {
                Write-Host "    [WARN] $($s.Name) durdurulmuş!" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "    [ERROR] $serviceName bulunamadı!" -ForegroundColor Red
    }
}

# 6. Disk Alanı Kontrolü (en az 2 GB boş alan)
Write-Host "⚪ Disk alanı kontrolü:" -ForegroundColor Cyan
$disk = Get-PSDrive -Name D
if ($disk.Free -lt 2GB) {
    Write-Host "    [WARN] D sürücüsünde azalan boş alan! ($([math]::Round($disk.Free/1GB,2)) GB)" -ForegroundColor Yellow
} else {
    Write-Host "    [OK] D sürücüsünde yeterli alan var. ($([math]::Round($disk.Free/1GB,2)) GB)" -ForegroundColor Green
}

# 7. Özel: Kendi Proje Sağlık Notunu Ekle (örn. .env dosyası)
$envFile = "D:\Ustunnet\sitelerim\enucuz.kim\.env"
Write-Host "🟤 .env dosyası kontrolü:" -ForegroundColor Cyan
if (Test-Path $envFile) {
    Write-Host "    [OK] .env dosyası mevcut." -ForegroundColor Green
} else {
    Write-Host "    [ERROR] .env dosyası eksik!" -ForegroundColor Red
}

Write-Host "`n--- Tüm sağlık kontrolleri tamamlandı! ---" -ForegroundColor Cyan
