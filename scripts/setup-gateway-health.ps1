# setup-gateway-health.ps1
$Root = "D:\U\S\enucuz.kim\services\gateway-service"
$Src  = Join-Path $Root "src"
$HealthDir = Join-Path $Src "health"

Write-Host "==> /health endpoint kurulumu başlıyor..." -ForegroundColor Cyan

if (-not (Test-Path $HealthDir)) {
  New-Item -ItemType Directory -Path $HealthDir | Out-Null
}

@'
import { Controller, Get } from "@nestjs/common";

@Controller()
export class HealthController {
  @Get("/health")
  health() {
    return { status: "ok", service: "gateway", uptime: process.uptime() };
  }
}
'@ | Set-Content -Encoding UTF8 -Path (Join-Path $HealthDir "health.controller.ts")

@'
import { Module } from "@nestjs/common";
import { HealthController } from "./health.controller";

@Module({
  controllers: [HealthController],
})
export class HealthModule {}
'@ | Set-Content -Encoding UTF8 -Path (Join-Path $HealthDir "health.module.ts")

# AppModule içine HealthModule import et
$appModule = Join-Path $Src "app.module.ts"
if (Test-Path $appModule) {
  $content = Get-Content -Raw -Encoding UTF8 $appModule

  if ($content -notmatch "HealthModule") {
    $content = $content -replace '(@nestjs/common";\r?\n)', "`$1import { HealthModule } from './health/health.module';`r`n"
    $content = $content -replace '(@Module\(\{\s*imports:\s*\[)([\s\S]*?)(\])', '$1$2, HealthModule$3'
    Set-Content -Encoding UTF8 -Path $appModule -Value $content
    Write-Host "AppModule → HealthModule eklendi." -ForegroundColor Green
  } else {
    Write-Host "AppModule zaten HealthModule içeriyor." -ForegroundColor Yellow
  }
} else {
  Write-Host "Uyarı: src/app.module.ts bulunamadı. Elle eklemeniz gerekebilir." -ForegroundColor Yellow
}

# test.http
@'
### Health check
GET http://localhost:3005/health
'@ | Set-Content -Encoding UTF8 -Path (Join-Path $Root "test.http")

Write-Host "Git'e ekleniyor..." -ForegroundColor Cyan
Set-Location "D:\U\S\enucuz.kim"
git add "services/gateway-service/src/health" "services/gateway-service/test.http" "services/gateway-service/src/app.module.ts"
git commit -m "feat(gateway): add /health endpoint" | Out-Null

Write-Host "==> Kurulum bitti. Çalıştırma adımlarını uygula." -ForegroundColor Cyan
