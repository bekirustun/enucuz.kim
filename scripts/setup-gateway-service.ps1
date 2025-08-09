# scripts/setup-gateway-service.ps1
Write-Host "==== Gateway-Service Kurulum Başlıyor ====" -ForegroundColor Cyan

$servicePath = "services\gateway-service"

# 1) Gerekli paketleri kur
Write-Host ">> Eksik bağımlılıklar kuruluyor..." -ForegroundColor Yellow
pnpm --filter "gateway-service" add @nestjs/axios@4.0.1 axios `
    @nestjs/typeorm typeorm pg `
    class-validator class-transformer @nestjs/mapped-types `
    @nestjs/common @nestjs/core @nestjs/platform-express @nestjs/config reflect-metadata rxjs

pnpm --filter "gateway-service" add -D typescript ts-node-dev

# 2) tsconfig.json oluştur/güncelle
Write-Host ">> tsconfig.json güncelleniyor..." -ForegroundColor Yellow
@"
{
  "compilerOptions": {
    "target": "ES2021",
    "module": "CommonJS",
    "moduleResolution": "Node",
    "lib": ["ES2021"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    "useDefineForClassFields": false,
    "strictPropertyInitialization": false,
    "useUnknownInCatchVariables": false,
    "types": ["node"]
  },
  "include": ["src/**/*.ts"],
  "exclude": ["node_modules", "dist", "test", "**/*.spec.ts"]
}
"@ | Set-Content -Encoding UTF8 "$servicePath\tsconfig.json"

# 3) package.json içinde dev script kontrolü
Write-Host ">> package.json dev script ekleniyor..." -ForegroundColor Yellow
$pkgFile = "$servicePath\package.json"
if (Test-Path $pkgFile) {
    $pkg = Get-Content $pkgFile | Out-String | ConvertFrom-Json
    if (-not $pkg.scripts) { $pkg | Add-Member -MemberType NoteProperty -Name scripts -Value @{} }
    $pkg.scripts.dev = "ts-node-dev --respawn --transpileOnly ./src/main.ts"
    $pkg | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 $pkgFile
}

# 4) Ana dosyalar (main, module, controller) yoksa oluştur
Write-Host ">> Ana dosyalar kontrol ediliyor..." -ForegroundColor Yellow
if (-not (Test-Path "$servicePath\src\main.ts")) {
@"
import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(process.env.PORT ? Number(process.env.PORT) : 3005);
}
bootstrap();
"@ | Set-Content -Encoding UTF8 "$servicePath\src\main.ts"
}

if (-not (Test-Path "$servicePath\src\app.module.ts")) {
@"
import { Module } from '@nestjs/common';
import { HealthController } from './health.controller';

@Module({
  controllers: [HealthController],
})
export class AppModule {}
"@ | Set-Content -Encoding UTF8 "$servicePath\src\app.module.ts"
}

if (-not (Test-Path "$servicePath\src\health.controller.ts")) {
@"
import { Controller, Get } from '@nestjs/common';

@Controller()
export class HealthController {
  @Get('health')
  health() {
    return { status: 'ok' };
  }
}
"@ | Set-Content -Encoding UTF8 "$servicePath\src\health.controller.ts"
}

# 5) Kod içi düzeltmeler (DTO/Entity ! ekleme ve catch err fix)
Write-Host ">> Kod içi düzenlemeler yapılıyor..." -ForegroundColor Yellow
Get-ChildItem "$servicePath\src" -Recurse -Include *.ts |
ForEach-Object {
    (Get-Content $_.FullName) |
    ForEach-Object {
        $_ -replace "(\w+): string;", '$1!: string;' `
           -replace "(\w+): number;", '$1!: number;' `
           -replace "(\w+): Date;", '$1!: Date;' `
           -replace "catch\s*\(err\)", 'catch (err: any)'
    } | Set-Content -Encoding UTF8 $_.FullName
}

# 6) Tam kurulum
Write-Host ">> Tüm bağımlılıklar yeniden yükleniyor..." -ForegroundColor Yellow
pnpm install

# 7) Servisi başlat
Write-Host ">> Gateway-Service başlatılıyor..." -ForegroundColor Green
pnpm --filter "gateway-service" dev

Write-Host "==== Kurulum Tamamlandı ====" -ForegroundColor Cyan
