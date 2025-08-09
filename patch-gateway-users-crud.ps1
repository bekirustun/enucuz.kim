# patch-gateway-users-crud.ps1
param(
  [string]$RepoRoot = "D:\U\S\enucuz.kim"
)

$ErrorActionPreference = "Stop"
function Ok($m){ Write-Host "✔ $m" -f Green }
function Info($m){ Write-Host ">> $m" -f Cyan }

$Dir = Join-Path $RepoRoot "services\gateway-service\src\users"
$Controller = Join-Path $Dir "users.gateway.controller.ts"
$Service    = Join-Path $Dir "users.gateway.service.ts"
$Module     = Join-Path $RepoRoot "services\gateway-service\src\users\users.gateway.module.ts"

if (!(Test-Path $Dir)) { New-Item -ItemType Directory -Force -Path $Dir | Out-Null }

# Service
@'
import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class UsersGatewayService {
  constructor(private readonly http: HttpService) {}

  private get baseUrl(): string {
    return process.env.USER_SERVICE_URL || 'http://localhost:3010';
  }

  health() {
    const url = `${this.baseUrl}/api/users/health`;
    return firstValueFrom(this.http.get(url)).then(r => r.data);
  }

  list() {
    const url = `${this.baseUrl}/api/users`;
    return firstValueFrom(this.http.get(url)).then(r => r.data);
  }

  get(id: number) {
    const url = `${this.baseUrl}/api/users/${id}`;
    return firstValueFrom(this.http.get(url)).then(r => r.data);
  }

  create(body: any) {
    const url = `${this.baseUrl}/api/users`;
    return firstValueFrom(this.http.post(url, body)).then(r => r.data);
  }

  update(id: number, body: any) {
    const url = `${this.baseUrl}/api/users/${id}`;
    return firstValueFrom(this.http.patch(url, body)).then(r => r.data);
  }

  remove(id: number) {
    const url = `${this.baseUrl}/api/users/${id}`;
    return firstValueFrom(this.http.delete(url)).then(r => r.data);
  }
}
'@ | Set-Content -Encoding UTF8 -Path $Service
Ok "users.gateway.service.ts yazıldı/yenilendi."

# Controller
@'
import { Body, Controller, Delete, Get, Param, ParseIntPipe, Patch, Post } from '@nestjs/common';
import { UsersGatewayService } from './users.gateway.service';

@Controller('api/users')
export class UsersGatewayController {
  constructor(private readonly svc: UsersGatewayService) {}

  @Get('health') health() { return this.svc.health(); }
  @Get() list() { return this.svc.list(); }
  @Get(':id') get(@Param('id', ParseIntPipe) id: number) { return this.svc.get(id); }

  @Post() create(@Body() body: any) { return this.svc.create(body); }
  @Patch(':id') update(@Param('id', ParseIntPipe) id: number, @Body() body: any) { return this.svc.update(id, body); }
  @Delete(':id') remove(@Param('id', ParseIntPipe) id: number) { return this.svc.remove(id); }
}
'@ | Set-Content -Encoding UTF8 -Path $Controller
Ok "users.gateway.controller.ts yazıldı/yenilendi."

# Module (HttpModule + provider/controller kayıtları emin olsun)
if (Test-Path $Module) {
  $m = Get-Content $Module -Raw
} else {
  $m = ""
}
if ($m -notmatch "HttpModule") {
  $m = @'
import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { UsersGatewayController } from './users.gateway.controller';
import { UsersGatewayService } from './users.gateway.service';

@Module({
  imports: [HttpModule],
  controllers: [UsersGatewayController],
  providers: [UsersGatewayService],
})
export class UsersGatewayModule {}
'@
}
$m | Set-Content -Encoding UTF8 -Path $Module
Ok "users.gateway.module.ts doğrulandı/güncellendi."

Write-Host "`n✔ Patch tamam. Gateway'i yeniden başlatın:" -f Green
Write-Host '  cd "D:\U\S\enucuz.kim\services\gateway-service"; pnpm run dev' -f Yellow
