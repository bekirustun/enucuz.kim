# Full Sağlık Taraması
Write-Host "`n🟢 HTTP/HTTPS endpoint kontrolleri:" -ForegroundColor Cyan
$urls = @(
    "http://localhost:3000",
    "http://localhost:3000/api/health",
    "http://localhost:3001",
    "https://enucuz.kim"
)
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

Write-Host "`n🔵 Açık port kontrolleri:" -ForegroundColor Cyan
$ports = @(3000, 3001, 5432)
foreach ($port in $ports) {
    $tcp = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($tcp) {
        Write-Host "    [OK] Port $port açık." -ForegroundColor Green
    } else {
        Write-Host "    [ERROR] Port $port kapalı veya kullanılmıyor!" -ForegroundColor Red
    }
}

Write-Host "`n🟡 Klasör/dosya kontrolleri:" -ForegroundColor Cyan
$paths = @(
    "D:\Ustunnet\sitelerim\enucuz.kim\apps\admin\pages",
    "D:\Ustunnet\sitelerim\enucuz.kim\apps\web\pages",
    "D:\Ustunnet\sitelerim\enucuz.kim\node_modules"
)
foreach ($p in $paths) {
    if (Test-Path $p) {
        Write-Host "    [OK] $p var." -ForegroundColor Green
    } else {
        Write-Host "    [ERROR] $p bulunamadı!" -ForegroundColor Red
    }
}

Write-Host "`n🟠 Versiyon kontrolleri:" -ForegroundColor Cyan
function Check-Version {
    param(
        [string]$cmd,
        [string]$desc
    )
    try {
        $v = & $cmd
        Write-Host ('    [OK] {0}: {1}' -f $desc, $v) -ForegroundColor Green
    } catch {
        Write-Host ('    [ERROR] {0} bulunamadı!' -f $desc) -ForegroundColor Red
    }
}
Check-Version "node --version" "Node.js"
Check-Version "pnpm --version" "pnpm"
Check-Version "git --version" "Git"
Check-Version "psql --version" "PostgreSQL (psql)"

Write-Host "`n🟣 Servis kontrolleri:" -ForegroundColor Cyan
$services = @(
    "postgresql*",
    "docker*"
)
foreach ($serviceName in $services) {
    $svc = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($svc) {
        foreach ($s in $svc) {
            if ($s.Status -eq "Running") {
                Write-Host ('    [OK] {0} çalışıyor.' -f $s.Name) -ForegroundColor Green
            } else {
                Write-Host ('    [WARN] {0} durdurulmuş!' -f $s.Name) -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host ('    [ERROR] {0} bulunamadı!' -f $serviceName) -ForegroundColor Red
    }
}

Write-Host "`n⚪ Disk alanı kontrolü:" -ForegroundColor Cyan
$disk = Get-PSDrive -Name D -ErrorAction SilentlyContinue
if ($null -eq $disk) {
    Write-Host "    [ERROR] D sürücüsü bulunamadı!" -ForegroundColor Red
} else {
    $freeGB = [math]::Round($disk.Free / 1GB, 2)
    if ($disk.Free -lt 2GB) {
        Write-Host ('    [WARN] D sürücüsünde azalan boş alan! ({0} GB)' -f $freeGB) -ForegroundColor Yellow
    } else {
        Write-Host ('    [OK] D sürücüsünde yeterli alan var. ({0} GB)' -f $freeGB) -ForegroundColor Green
    }
}

Write-Host "`n🟤 .env dosyası kontrolü:" -ForegroundColor Cyan
$envFile = "D:\Ustunnet\sitelerim\enucuz.kim\.env"
if (Test-Path $envFile) {
    Write-Host "    [OK] .env dosyası mevcut." -ForegroundColor Green
} else {
    Write-Host "    [ERROR] .env dosyası eksik!" -ForegroundColor Red
}

Write-Host "`n--- Tum saglik kontrolleri tamamlandi! ---" -ForegroundColor Cyan
