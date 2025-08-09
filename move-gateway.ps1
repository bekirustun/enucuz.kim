# ===========================
# Gateway Service Klasörünü Taşıma Scripti
# ===========================

$ProjectRoot = "D:\U\S\enucuz.kim"
$GatewaySrc = "D:\U\S\gateway-service"
$GatewayDst = "$ProjectRoot\services\gateway-service"

Write-Host "=== Gateway Service Taşıma İşlemi Başlıyor ===" -ForegroundColor Cyan

# 1. Kaynak klasör var mı kontrol et
if (Test-Path $GatewaySrc) {
    # 2. services klasörü yoksa oluştur
    if (-not (Test-Path "$ProjectRoot\services")) {
        New-Item -ItemType Directory -Path "$ProjectRoot\services" | Out-Null
        Write-Host "services klasörü oluşturuldu." -ForegroundColor Green
    }

    # 3. Gateway klasörünü taşı
    Move-Item -Path $GatewaySrc -Destination $GatewayDst -Force
    Write-Host "gateway-service klasörü services içine taşındı." -ForegroundColor Green

    # 4. Git işlemleri
    Set-Location $ProjectRoot
    git add .
    git commit -m "gateway-service klasörü doğru konuma taşındı"
    Write-Host "Git commit işlemi tamamlandı." -ForegroundColor Green
} else {
    Write-Host "gateway-service klasörü belirtilen yerde bulunamadı!" -ForegroundColor Red
}

Write-Host "=== İşlem Tamamlandı ===" -ForegroundColor Cyan
