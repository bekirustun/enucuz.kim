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
        Write-Host "    [ERROR] Port $port kapalı veya kullanıl
