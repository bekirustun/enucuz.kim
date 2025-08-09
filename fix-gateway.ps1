param(
    [switch]$ScaffoldIfMissing # Bulunamazsa boş NestJS iskeleti oluştursun mu?
)

$ProjectRoot = "D:\U\S\enucuz.kim"
$InsidePath  = "$ProjectRoot\services\gateway-service"

Write-Host "=== Gateway Service Düzeltme Başlıyor ===" -ForegroundColor Cyan

# 1) Proje içinde zaten var mı?
if (Test-Path -LiteralPath "$InsidePath") {
    Write-Host "Zaten doğru konumda: $InsidePath" -ForegroundColor Green

    # Klasör boşsa Git'e girmesi için .gitkeep ekleyelim
    $hasFiles = Get-ChildItem -LiteralPath "$InsidePath" -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { -not $_.PSIsContainer }
    if (-not $hasFiles) {
        New-Item -ItemType File -Path "$InsidePath\.gitkeep" -Force | Out-Null
        Write-Host ".gitkeep eklendi (klasör boştu)." -ForegroundColor Yellow
    }

    Set-Location "$ProjectRoot"
    git add "services/gateway-service"
    git commit -m "chore(gateway): gateway-service doğru konumda; .gitkeep/ilk içerik eklendi" 2>$null
    Write-Host "Git commit (varsa değişiklikler) tamamlandı." -ForegroundColor Green
    Write-Host "=== İşlem Bitti ===" -ForegroundColor Cyan
    return
}

# 2) Proje içinde yoksa, diskte ara
Write-Host "Proje içinde bulunamadı, disk genelinde taranıyor..." -ForegroundColor Yellow
$SearchRoot = "D:\U\S"
$Found = Get-ChildItem -Path "$SearchRoot" -Directory -Filter "gateway-service" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

if ($Found) {
    Write-Host "Bulundu: $($Found.FullName)" -ForegroundColor Green

    # services klasörü yoksa oluştur
    if (-not (Test-Path -LiteralPath "$ProjectRoot\services")) {
        New-Item -ItemType Directory -Path "$ProjectRoot\services" | Out-Null
        Write-Host "services klasörü oluşturuldu." -ForegroundColor Green
    }

    Move-Item -LiteralPath "$($Found.FullName)" -Destination "$InsidePath" -Force
    Write-Host "Taşındı → $InsidePath" -ForegroundColor Green

    Set-Location "$ProjectRoot"
    git add "services/gateway-service"
    git commit -m "chore(gateway): gateway-service doğru konuma taşındı" 2>$null
    Write-Host "Git commit tamamlandı." -ForegroundColor Green
    Write-Host "=== İşlem Bitti ===" -ForegroundColor Cyan
    return
}

# 3) Hiç bulunamadıysa, iskelet oluşturma seçeneği
if ($ScaffoldIfMissing) {
    Write-Host "Klasör bulunamadı; iskelet oluşturuluyor..." -ForegroundColor Yellow

    New-Item -ItemType Directory -Path "$InsidePath\src" -Force | Out-Null

@'
{
  "name": "gateway-service",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "start": "node dist/main.js",
    "build": "tsc",
    "start:dev": "ts-node-dev --respawn src/main.ts"
  },
  "dependencies": {
    "@nestjs/common": "^11.1.5",
    "@nestjs/core": "^11.1.5",
    "@nestjs/platform-express": "^11.1.5",
    "reflect-metadata": "^0.2.2",
    "rxjs": "^7.8.2"
  },
  "devDependencies": {
    "ts-node-dev": "^2.0.0",
    "typescript": "^5.5.4"
  }
}
'@ | Set-Content -LiteralPath "$InsidePath\package.json" -Encoding UTF8

@'
import "reflect-metadata";
import { NestFactory } from "@nestjs/core";
import { Module, Controller, Get } from "@nestjs/common";

@Controller()
class HealthController {
  @Get("/health")
  ok() { return { status: "ok", service: "gateway" }; }
}

@Module({ controllers: [HealthController] })
class AppModule {}

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(3005);
  // console.log("Gateway running on http://localhost:3005");
}
bootstrap();
'@ | Set-Content -LiteralPath "$InsidePath\src\main.ts" -Encoding UTF8

@'
{
  "compilerOptions": {
    "module": "commonjs",
    "target": "ES2022",
    "moduleResolution": "node",
    "outDir": "dist",
    "rootDir": "src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  },
  "include": ["src"]
}
'@ | Set-Content -LiteralPath "$InsidePath\tsconfig.json" -Encoding UTF8

    Set-Location "$ProjectRoot"
    git add "services/gateway-service"
    git commit -m "feat(gateway): gateway-service iskeleti olusturuldu" 2>$null
    Write-Host "İskelet oluşturuldu ve commit’lendi." -ForegroundColor Green
    Write-Host "=== İşlem Bitti ===" -ForegroundColor Cyan
} else {
    Write-Host "gateway-service bulunamadı. İstersen '-ScaffoldIfMissing' ile iskelet oluşturayım." -ForegroundColor Red
    Write-Host "Kullanım: & '.\fix-gateway.ps1' -ScaffoldIfMissing"
}
