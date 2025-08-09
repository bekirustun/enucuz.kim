# check-monorepo-health.ps1
# Proje AI Ready Dosya/Dizin Sağlık Kontrolü (Sadece raporlar)

$apps = @("web", "admin")
$basePath = "$PSScriptRoot\apps"
$checks = @(
    "package.json",
    "postcss.config.js",
    "tailwind.config.ts",
    "styles\globals.css",
    "pages\_app.tsx"
)

foreach ($app in $apps) {
    $appPath = Join-Path $basePath $app
    Write-Host "`n------ $app APP SAĞLIK TARAMASI ------`n" -ForegroundColor Cyan

    foreach ($check in $checks) {
        $targetPath = Join-Path $appPath $check
        if (Test-Path $targetPath) {
            Write-Host "✅ $check mevcut." -ForegroundColor Green
        } else {
            Write-Host "❌ $check EKSİK!" -ForegroundColor Red
        }
    }

    # Ekstra: _document.tsx (isteğe bağlı)
    $documentPath = Join-Path $appPath "pages\_document.tsx"
    if (Test-Path $documentPath) {
        Write-Host "✅ pages/_document.tsx mevcut." -ForegroundColor Green
    } else {
        Write-Host "⚠️  pages/_document.tsx isteğe bağlı, yok." -ForegroundColor Yellow
    }
}

Write-Host "`n🔍 Tarama tamamlandı. Eksik dosya varsa yukarıda kırmızı olarak görürsün." -ForegroundColor Cyan
