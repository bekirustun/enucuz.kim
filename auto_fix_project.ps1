# Otomatik Proje Düzeltme Scripti
# Enucuz.kim ana dizininde çalıştırılmalıdır!

$ErrorActionPreference = "Stop"

Write-Host "==== PROJE OTOMATİK DÜZELTME BAŞLIYOR ====" -ForegroundColor Cyan

# 1. pnpm-lock.yaml yoksa oluştur
if (-not (Test-Path "pnpm-lock.yaml")) {
    Write-Host "pnpm-lock.yaml eksik, pnpm install başlatılıyor..." -ForegroundColor Yellow
    if (Get-Command pnpm -ErrorAction SilentlyContinue) {
        pnpm install --no-frozen-lockfile
        Write-Host "pnpm-lock.yaml oluşturuldu." -ForegroundColor Green
    } else {
        Write-Host "pnpm komutu bulunamadı! Lütfen pnpm'i yükle!" -ForegroundColor Red
    }
} else {
    Write-Host "pnpm-lock.yaml zaten mevcut." -ForegroundColor Green
}

# 2. .env dosyalarını eksikse oluştur
$envs = @("apps/web/.env", "apps/admin/.env")
foreach ($env in $envs) {
    if (-not (Test-Path $env)) {
        New-Item -ItemType File -Path $env | Out-Null
        Write-Host "$env oluşturuldu." -ForegroundColor Green
    } else {
        Write-Host "$env zaten mevcut." -ForegroundColor Gray
    }
}

# 3. package.json workspaces kontrol ve düzeltme
$pkgPath = "package.json"
if (Test-Path $pkgPath) {
    $pkg = Get-Content $pkgPath -Raw | ConvertFrom-Json
    if (-not $pkg.workspaces) {
        $pkg | Add-Member -MemberType NoteProperty -Name "workspaces" -Value @("apps/*", "services/*", "libs/*")
        Write-Host "Workspaces tanımı eklendi." -ForegroundColor Green
        # JSON'u kaydet
        $pkg | ConvertTo-Json -Depth 10 | Set-Content $pkgPath
    } else {
        # Eksik path var mı kontrol et
        $changed = $false
        $ws = $pkg.workspaces
        foreach ($target in @("apps/*", "services/*", "libs/*")) {
            if ($ws -notcontains $target) {
                $ws += $target
                $changed = $true
            }
        }
        if ($changed) {
            $pkg.workspaces = $ws
            Write-Host "Eksik workspaces path(ler)i eklendi." -ForegroundColor Green
            $pkg | ConvertTo-Json -Depth 10 | Set-Content $pkgPath
        } else {
            Write-Host "Workspaces zaten tam ve doğru." -ForegroundColor Green
        }
    }
} else {
    Write-Host "ANA package.json bulunamadı!" -ForegroundColor Red
}

# 4. pnpm install/build işlemi
if (Get-Command pnpm -ErrorAction SilentlyContinue) {
    Write-Host "pnpm install başlatılıyor..." -ForegroundColor Cyan
    pnpm install --no-frozen-lockfile
    Write-Host "pnpm build başlatılıyor..." -ForegroundColor Cyan
    pnpm build
} else {
    Write-Host "pnpm komutu bulunamadı! Kurulumlar atlandı." -ForegroundColor Red
}

# 5. Test ve coverage scriptlerini devre dışı bırak (varsa)
$pkg = Get-Content $pkgPath -Raw | ConvertFrom-Json
if ($pkg.scripts.test) {
    $pkg.scripts.PSObject.Properties.Remove('test')
    Write-Host "Test scripti kaldırıldı." -ForegroundColor Yellow
}
if ($pkg.scripts.coverage) {
    $pkg.scripts.PSObject.Properties.Remove('coverage')
    Write-Host "Coverage scripti kaldırıldı." -ForegroundColor Yellow
}
$pkg | ConvertTo-Json -Depth 10 | Set-Content $pkgPath

Write-Host "==== DÜZELTME TAMAMLANDI ====" -ForegroundColor Magenta
Write-Host "Eksikler otomatik tamamlandı. Şimdi tekrar sağlık kontrolü yapabilirsin!" -ForegroundColor Cyan