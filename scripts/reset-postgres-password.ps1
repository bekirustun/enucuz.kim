Write-Host "=== PostgreSQL Şifre Resetleme Scripti ===" -ForegroundColor Cyan

# 1) PostgreSQL exe bul
Write-Host ">> psql.exe aranıyor..." -ForegroundColor Yellow
$psql = Get-ChildItem -Path "C:\Program Files\PostgreSQL" -Recurse -Filter psql.exe -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName

if (-not $psql) {
    Write-Host "psql.exe bulunamadı! PostgreSQL kurulu değil veya PATH'te yok." -ForegroundColor Red
    exit
}
Write-Host "Bulundu: $psql" -ForegroundColor Green

# 2) Çalışan servis ve data klasörünü bul
Write-Host ">> PostgreSQL servisi aranıyor..." -ForegroundColor Yellow
$svc = Get-CimInstance Win32_Service | Where-Object { $_.Name -match "postgresql" -and $_.State -eq "Running" } | Select-Object -First 1
if (-not $svc) {
    Write-Host "PostgreSQL servisi çalışmıyor!" -ForegroundColor Red
    exit
}
Write-Host "Servis: $($svc.Name)  PID: $($svc.ProcessId)" -ForegroundColor Green

$dataDir = ($svc.PathName -split ' -D ')[1] -replace '"',''
Write-Host "Data klasörü: $dataDir" -ForegroundColor Green

# 3) Bağlantı testi
Write-Host ">> Mevcut şifre ile bağlantı deneniyor..." -ForegroundColor Yellow
& "$psql" -h localhost -p 5432 -U postgres -d postgres -c "SELECT version();" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "Bağlantı başarılı, şifre değişimine gerek yok." -ForegroundColor Green
    exit
}

Write-Host "Şifre hatalı, geçici trust moduna geçiliyor..." -ForegroundColor Magenta

# 4) pg_hba.conf değiştir
$pgHba = Join-Path $dataDir "pg_hba.conf"
$pgHbaContent = Get-Content $pgHba
$pgHbaBackup = $pgHbaContent
$pgHbaContent = $pgHbaContent -replace "scram-sha-256", "trust"
Set-Content $pgHba $pgHbaContent
Write-Host "pg_hba.conf trust moduna alındı." -ForegroundColor Green

# 5) Servisi restart
Restart-Service -Name $svc.Name
Start-Sleep -Seconds 3

# 6) Şifreyi sıfırla
$newPass = "postgres"
Write-Host "Yeni şifre: $newPass" -ForegroundColor Yellow
& "$psql" -h localhost -U postgres -d postgres -c "ALTER USER postgres WITH PASSWORD '$newPass';"
Write-Host "Şifre sıfırlandı." -ForegroundColor Green

# 7) pg_hba.conf eski haline getir
Set-Content $pgHba $pgHbaBackup
Write-Host "pg_hba.conf eski haline getirildi." -ForegroundColor Green

# 8) Servisi restart
Restart-Service -Name $svc.Name
Write-Host "PostgreSQL servisi yeniden başlatıldı." -ForegroundColor Green
Write-Host "=== İşlem tamam! Yeni şifre: $newPass ===" -ForegroundColor Cyan
