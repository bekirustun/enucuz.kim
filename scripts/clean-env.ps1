#requires -Version 5.1
<#
  Monorepo: enucuz.kim
  İşlev: Tüm servislerdeki .env dosyalarını tekilleştirir.
  - Aynı anahtarın tekrarlarını siler, son değeri tutar
  - Boş satırları korur
  - UTF8 olarak yazar
#>

param(
    [string]$RepoRoot = "D:\U\S\enucuz.kim"
)

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "✔ $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "⚠ $msg" -ForegroundColor Yellow }

$envFiles = Get-ChildItem -Path $RepoRoot -Filter ".env" -Recurse -File

if ($envFiles.Count -eq 0) {
    Write-Warn "Hiç .env dosyası bulunamadı."
    exit
}

foreach ($file in $envFiles) {
    Write-Step "Temizleniyor: $($file.FullName)"

    $lines = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction SilentlyContinue -Encoding UTF8 -Force `
        | ForEach-Object { $_ -split "`r?`n" }

    $map = @{}
    foreach ($line in $lines) {
        if ($line -match '^\s*[^#\s]+=') {
            $k,$v = $line -split '=',2
            $map[$k.Trim()] = $v.Trim()
        }
    }

    # Sıra: Önemli anahtarlar üstte
    $order = @('DB_HOST','DB_PORT','DB_NAME','DB_USERNAME','DB_PASSWORD','GLOBAL_PREFIX','PORT',
               'USER_SERVICE_URL','PRODUCT_SERVICE_URL','AFFILIATE_SERVICE_URL')

    $out = @()
    foreach ($k in $order) {
        if ($map.ContainsKey($k)) {
            $out += "$k=$($map[$k])"
            $map.Remove($k)
        }
    }

    # Geri kalanları ekle
    foreach ($k in $map.Keys) {
        $out += "$k=$($map[$k])"
    }

    Set-Content -LiteralPath $file.FullName -Value ($out -join "`r`n") -Encoding UTF8
    Write-Ok "Temizlendi: $($file.FullName)"
}

Write-Host "`nTüm .env dosyaları başarıyla temizlendi." -ForegroundColor Green
