# scripts/fix-gateway-dev.ps1
Write-Host ">> gateway-service dev fix" -ForegroundColor Cyan
$svc = "services\gateway-service"
$src = Join-Path $svc "src"
New-Item -ItemType Directory -Force -Path $src | Out-Null

# main.ts / app.module.ts / health.controller.ts garanti
$main = Join-Path $src "main.ts"
if (!(Test-Path $main)) {
@"
import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(process.env.PORT ? Number(process.env.PORT) : 3005);
}
bootstrap();
"@ | Set-Content -Encoding UTF8 $main
}

$appmod = Join-Path $src "app.module.ts"
if (!(Test-Path $appmod)) {
@"
import { Module } from '@nestjs/common';
import { HealthController } from './health.controller';
@Module({ controllers: [HealthController] })
export class AppModule {}
"@ | Set-Content -Encoding UTF8 $appmod
}

$health = Join-Path $src "health.controller.ts"
if (!(Test-Path $health)) {
@"
import { Controller, Get } from '@nestjs/common';
@Controller()
export class HealthController {
  @Get('health') health() { return { status: 'ok' }; }
}
"@ | Set-Content -Encoding UTF8 $health
}

# package.json'da dev script garanti
$pkgFile = Join-Path $svc "package.json"
$pkg = Get-Content $pkgFile -Raw | ConvertFrom-Json
if (-not $pkg.scripts) { $pkg | Add-Member -MemberType NoteProperty -Name scripts -Value @{} }
$pkg.scripts.dev = "ts-node-dev --respawn --transpileOnly ./src/main.ts"
$pkg | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 $pkgFile

Write-Host ">> pnpm install (senkron)" -ForegroundColor Yellow
pnpm install

Write-Host ">> start gateway-service" -ForegroundColor Green
pnpm --filter "gateway-service" dev
