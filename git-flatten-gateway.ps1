# Monorepo kökü
$ProjectRoot = "D:\U\S\enucuz.kim"
$GatewayPath = Join-Path $ProjectRoot "services\gateway-service"

Write-Host "=== gateway-service git izlerini temizleme baslıyor ===" -ForegroundColor Cyan
Set-Location "$ProjectRoot"

# 1) İçte .git klasörü veya .git dosyası var mı? Varsa sil
$InnerGitDir  = Join-Path $GatewayPath ".git"
if (Test-Path -LiteralPath $InnerGitDir) {
  try {
    # Bazı durumlarda .git bir dosya (gitdir: ... ) olabilir
    $attr = Get-Item -LiteralPath $InnerGitDir
    if ($attr.PSIsContainer) {
      Remove-Item -LiteralPath $InnerGitDir -Recurse -Force -ErrorAction SilentlyContinue
    } else {
      Remove-Item -LiteralPath $InnerGitDir -Force -ErrorAction SilentlyContinue
    }
    Write-Host "İçteki .git temizlendi." -ForegroundColor Green
  } catch {
    Write-Host "İç .git kaldırılamadı: $($_.Exception.Message)" -ForegroundColor Red
  }
}

# 2) .gitmodules içinde kayıt var mı? Varsa kaldır
$GitModules = Join-Path $ProjectRoot ".gitmodules"
if (Test-Path -LiteralPath $GitModules) {
  $gm = Get-Content -LiteralPath $GitModules -Raw
  if ($gm -match "submodule.*services/gateway-service") {
    Write-Host ".gitmodules kaydı bulundu, kaldırılıyor..." -ForegroundColor Yellow
    git rm --cached "services/gateway-service" 2>$null | Out-Null
    git config -f ".gitmodules" --remove-section "submodule.services/gateway-service" 2>$null
    # Boş kalırsa dosyayı sil; değilse değişikliği stage et
    if ((Get-Content -LiteralPath $GitModules | Where-Object { $_.Trim() -ne "" }).Count -eq 0) {
      Remove-Item -LiteralPath $GitModules -Force
    } else {
      git add ".gitmodules" | Out-Null
    }
    # .git/modules altındaki artıkları da sil
    $InnerModuleStore = Join-Path $ProjectRoot ".git\modules\services\gateway-service"
    if (Test-Path -LiteralPath $InnerModuleStore) {
      Remove-Item -LiteralPath $InnerModuleStore -Recurse -Force -ErrorAction SilentlyContinue
    }
  }
}

# 3) VSCode Local History dosyalarını izleme dışına almak için .gitignore güncelle
$GitIgnore = Join-Path $ProjectRoot ".gitignore"
$NeedHistoryIgnore = $true
if (Test-Path -LiteralPath $GitIgnore) {
  $gi = Get-Content -LiteralPath $GitIgnore
  if ($gi -match "^\s*\.history/?\s*$") { $NeedHistoryIgnore = $false }
}
if ($NeedHistoryIgnore) {
  Add-Content -LiteralPath $GitIgnore -Value "`r`n# VSCode Local History`r`n.history/`r`n"
  Write-Host ".gitignore → .history/ kuralı eklendi." -ForegroundColor Yellow
}

# 4) Klasörü normal dosya olarak ekle ve commit yap
git add -A
git commit -m "chore(gateway): nested git temizlendi; gateway-service monorepo klasörü olarak eklendi" 2>$null

Write-Host "=== Temizlik ve commit tamamlandı ===" -ForegroundColor Cyan
