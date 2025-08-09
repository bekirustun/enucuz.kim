# Monorepo kökü
$ProjectRoot = "D:\U\S\enucuz.kim"
Set-Location $ProjectRoot

Write-Host "=== Submodule/İç Git Temizliği Başlıyor ===" -ForegroundColor Cyan

function Remove-Submodule {
    param([string]$Path)
    $GitModules = Join-Path $ProjectRoot ".gitmodules"
    $GitModuleDir = Join-Path $ProjectRoot (".git\modules\" + ($Path -replace '/','\'))

    # .gitmodules'tan kaldır
    if (Test-Path -LiteralPath $GitModules) {
        $gm = Get-Content -LiteralPath $GitModules -Raw
        if ($gm -match "(?ms)^\s*\[submodule `"$Path`"\]") {
            Write-Host ".gitmodules → $Path bölümü kaldırılıyor..." -ForegroundColor Yellow
            git config -f ".gitmodules" --remove-section ("submodule."+ $Path) 2>$null
            # Boş kaldıysa sil, değilse stage et
            $content = (Get-Content -LiteralPath $GitModules) -join "`n"
            if ($content.Trim().Length -eq 0) {
                Remove-Item -LiteralPath $GitModules -Force -ErrorAction SilentlyContinue
            } else {
                git add ".gitmodules" | Out-Null
            }
        }
    }

    # .git/config içinden kaldır
    git config --get-regexp ("^submodule\."+[regex]::Escape($Path)) 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host ".git/config → $Path bölümü kaldırılıyor..." -ForegroundColor Yellow
        git config --remove-section ("submodule."+ $Path) 2>$null
    }

    # Index'te submodule olarak varsa cache'ten çıkar
    git ls-files -s | Select-String " $Path$" | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Index → $Path gitlink kaldırılıyor..." -ForegroundColor Yellow
        git rm --cached -f -- "$Path" 2>$null | Out-Null
    }

    # .git/modules/... artıklarını sil
    if (Test-Path -LiteralPath $GitModuleDir) {
        Write-Host ".git/modules temizleniyor: $GitModuleDir" -ForegroundColor Yellow
        Remove-Item -LiteralPath $GitModuleDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 1) gateway-service içindeki yerel .git hâlâ varsa temizle
$InnerGit = Join-Path $ProjectRoot "services\gateway-service\.git"
if (Test-Path -LiteralPath $InnerGit) {
    Write-Host "services/gateway-service iç .git kaldırılıyor..." -ForegroundColor Yellow
    Remove-Item -LiteralPath $InnerGit -Recurse -Force -ErrorAction SilentlyContinue
}

# 2) Submodule kayıtlarını sök (hem gateway-service hem de yanlış enucuz.kim/)
Remove-Submodule "services/gateway-service"
Remove-Submodule "enucuz.kim"

# 3) Kök içindeki "enucuz.kim" klasörü var mı? (D:\U\S\enucuz.kim\enucuz.kim)
$Nested = Join-Path $ProjectRoot "enucuz.kim"
if (Test-Path -LiteralPath $Nested) {
    $ans = Read-Host "İçte 'enucuz.kim\' klasörü var. İçeriğini köke taşımak ister misin? (Y/N)"
    if ($ans -match '^[Yy]') {
        Write-Host "İçerik taşınıyor..." -ForegroundColor Yellow
        Get-ChildItem -LiteralPath $Nested -Force | ForEach-Object {
            if ($_.Name -ne ".git") {
                Move-Item -LiteralPath $_.FullName -Destination $ProjectRoot -Force
            }
        }
        # Klasör boşaldıysa sil
        Remove-Item -LiteralPath $Nested -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "İçerik taşındı ve iç klasör kaldırıldı." -ForegroundColor Green
    } else {
        Write-Host "İç klasör olduğu gibi bırakıldı." -ForegroundColor Yellow
    }
}

# 4) .gitignore'a .history kuralı eklimi?
$GitIgnore = Join-Path $ProjectRoot ".gitignore"
if (Test-Path -LiteralPath $GitIgnore) {
    $gi = Get-Content -LiteralPath $GitIgnore -Raw
    if ($gi -notmatch "(?m)^\s*\.history/?\s*$") {
        Add-Content -LiteralPath $GitIgnore -Value "`r`n# VSCode Local History`r`n.history/`r`n"
        Write-Host ".gitignore → .history/ eklendi." -ForegroundColor Yellow
    }
}

# 5) Her şeyi normal dosya gibi ekle ve commit et
git add -A
git commit -m "chore(repo): submodule izleri temizlendi; klasorler normal hale getirildi" 2>$null

Write-Host "=== Temizlik bitti. 'git status' ile durumu kontrol edebilirsin. ===" -ForegroundColor Cyan
