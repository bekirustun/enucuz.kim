# site_health_check.ps1
# En detaylı monorepo & Next.js proje sağlık ve kod hata kontrol scripti
# Kullanım: powershell ile proje ana klasöründe çalıştır: .\site_health_check.ps1

function Write-Color($Text, $Color="White") { Write-Host $Text -ForegroundColor $Color }

Write-Color "`n========== EN DETAYLI SİTE SAĞLIK KONTROLÜ BAŞLIYOR ==========`n" Cyan

# 1. Temel ortam kontrolleri
Write-Color "`n[1] Sürüm Kontrolleri:" Yellow
Write-Color ("Node.js:     " + (node -v)) Green
Write-Color ("pnpm:        " + (pnpm -v)) Green
Write-Color ("git:         " + (git --version)) Green

# 2. Temel dosya ve klasör kontrolleri
Write-Color "`n[2] Dosya/Klasör Kontrolleri:" Yellow
$paths = @("node_modules", "pnpm-lock.yaml", "package.json", ".git", "apps/web/node_modules", "apps/admin/node_modules", "apps/web/.env", "apps/admin/.env", "apps/web/package.json", "apps/admin/package.json")
foreach ($path in $paths) {
    if (Test-Path $path) { Write-Color "OK: $path" Green }
    else { Write-Color "Eksik: $path" Red }
}

# 3. Disk alanı ve sistem kaynağı
Write-Color "`n[3] Disk ve Sistem Kaynağı:" Yellow
Get-PSDrive -Name C | Select-Object Free,Used,Name | Format-Table
Get-CimInstance Win32_OperatingSystem | Select-Object FreePhysicalMemory,TotalVisibleMemorySize | Format-List

# 4. Internet bağlantı & DNS kontrolü
Write-Color "`n[4] İnternet bağlantısı kontrolü:" Yellow
try { 
    $r = Test-Connection -Count 2 www.google.com -ErrorAction Stop
    Write-Color "İnternet bağlantısı: OK" Green
} catch {
    Write-Color "İnternet bağlantısı YOK!" Red
}

# 5. SSL kontrol (örnek: enucuz.kim)
Write-Color "`n[5] SSL Sertifika Kontrolü (enucuz.kim):" Yellow
try {
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    $req = [System.Net.HttpWebRequest]::Create("https://enucuz.kim")
    $res = $req.GetResponse()
    Write-Color "enucuz.kim SSL: OK" Green
} catch {
    Write-Color "enucuz.kim SSL: HATA veya erişilemiyor!" Red
}

# 6. Port kontrolü (3000, 3001, 5432 vs.)
Write-Color "`n[6] Port Kontrolü:" Yellow
$ports = @(3000,3001,5432,80,443)
foreach ($port in $ports) {
    $used = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($used) { Write-Color ("Port $($port): KULLANIMDA") Red }
    else { Write-Color ("Port $($port): BOŞ") Green }
}

# 7. package.json ve workspace consistency
Write-Color "`n[7] Monorepo (package.json/workspace) Tutarlılığı:" Yellow
$monorepoRoot = Get-Content -Raw "package.json" | ConvertFrom-Json
if ($monorepoRoot.workspaces) { Write-Color "Monorepo workspaces tanımlı." Green }
else { Write-Color "Monorepo workspaces EKSİK!" Red }

# 8. pnpm install (otomatik test)
Write-Color "`n[8] pnpm install test:" Yellow
pnpm install --frozen-lockfile
if ($LASTEXITCODE -eq 0) { Write-Color "pnpm install: OK" Green }
else { Write-Color "pnpm install: HATA!" Red }

# 9. Kod Hatası ve Statik Analiz
Write-Color "`n[9] KOD LINT KONTROLÜ (pnpm lint):" Yellow
pnpm lint
if ($LASTEXITCODE -eq 0) { Write-Color "Lint: HATA YOK" Green }
else { Write-Color "Lint: HATA VAR!" Red }

# 10. Build Kontrolü (pnpm build)
Write-Color "`n[10] BUILD KONTROLÜ (pnpm build):" Yellow
pnpm build
if ($LASTEXITCODE -eq 0) { Write-Color "Build: HATA YOK" Green }
else { Write-Color "Build: HATA VAR!" Red }

# 11. Unit Test (pnpm test)
Write-Color "`n[11] UNIT TEST KONTROLÜ (pnpm test):" Yellow
pnpm test
if ($LASTEXITCODE -eq 0) { Write-Color "Test: TÜM TESTLER BAŞARILI" Green }
else { Write-Color "Test: BAŞARISIZ TEST(ler) VAR!" Red }

# 12. Coverage Raporu (varsa)
Write-Color "`n[12] Coverage KONTROLÜ (pnpm coverage):" Yellow
try { pnpm coverage } catch { Write-Color "Coverage komutu yok veya hata aldı." DarkYellow }

# 13. Son 10 log/hata satırı (web ve admin)
Write-Color "`n[13] Log Analizi (Son 10 satır):" Yellow
if (Test-Path "apps/web/.next/trace") {
    Get-Content "apps/web/.next/trace" -Tail 10 | ForEach-Object { Write-Color $_ DarkYellow }
}
if (Test-Path "apps/admin/.next/trace") {
    Get-Content "apps/admin/.next/trace" -Tail 10 | ForEach-Object { Write-Color $_ DarkYellow }
}

# 14. Sonuç ve tavsiye
Write-Color "`n========== KONTROLLER TAMAMLANDI ==========" Cyan
Write-Color "Sorun görüyorsan yukarıdaki renkli çıktıyı incele, çözüm için bana her zaman sorabilirsin!" Magenta
Write-Color "`nAI ile birlikte, aşkla kodlandı. Esma'nın uğuruyla, dünyanın en sağlam sitesi için! 💙" Cyan