# force-gateway-crud.ps1
param([string]$RepoRoot="D:\U\S\enucuz.kim")
$ErrorActionPreference="Stop"
function Ok($m){Write-Host "✔ $m" -f Green}
function Info($m){Write-Host ">> $m" -f Cyan}

$GwRoot = Join-Path $RepoRoot "services\gateway-service\src"
$AppMod = Join-Path $GwRoot  "app.module.ts"
$UsrDir = Join-Path $GwRoot  "users"
$Ctrl   = Join-Path $UsrDir  "users.gateway.controller.ts"
$Svc    = Join-Path $UsrDir  "users.gateway.service.ts"
$Mod    = Join-Path $UsrDir  "users.gateway.module.ts"

if(!(Test-Path $UsrDir)){ New-Item -ItemType Directory -Force -Path $UsrDir | Out-Null }

# Service (tam CRUD proxy)
@'
import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class UsersGatewayService {
  constructor(private readonly http: HttpService) {}
  private get baseUrl(){ return process.env.USER_SERVICE_URL || 'http://localhost:3010'; }

  health(){ return firstValueFrom(this.http.get(`${this.baseUrl}/api/users/health`)).then(r=>r.data); }
  list(){   return firstValueFrom(this.http.get(`${this.baseUrl}/api/users`)).then(r=>r.data); }
  get(id:number){ return firstValueFrom(this.http.get(`${this.baseUrl}/api/users/${id}`)).then(r=>r.data); }
  create(body:any){ return firstValueFrom(this.http.post(`${this.baseUrl}/api/users`, body)).then(r=>r.data); }
  update(id:number, body:any){ return firstValueFrom(this.http.patch(`${this.baseUrl}/api/users/${id}`, body)).then(r=>r.data); }
  remove(id:number){ return firstValueFrom(this.http.delete(`${this.baseUrl}/api/users/${id}`)).then(r=>r.data); }
}
'@ | Set-Content -Encoding UTF8 -Path $Svc
Ok "users.gateway.service.ts yazıldı."

# Controller (CRUD dahil)
@'
import { Body, Controller, Delete, Get, Param, ParseIntPipe, Patch, Post } from '@nestjs/common';
import { UsersGatewayService } from './users.gateway.service';

@Controller('api/users')
export class UsersGatewayController {
  constructor(private readonly svc: UsersGatewayService) {}

  @Get('health') health(){ return this.svc.health(); }
  @Get() list(){ return this.svc.list(); }
  @Get(':id') get(@Param('id', ParseIntPipe) id:number){ return this.svc.get(id); }

  @Post() create(@Body() body:any){ return this.svc.create(body); }
  @Patch(':id') update(@Param('id', ParseIntPipe) id:number, @Body() body:any){ return this.svc.update(id, body); }
  @Delete(':id') remove(@Param('id', ParseIntPipe) id:number){ return this.svc.remove(id); }
}
'@ | Set-Content -Encoding UTF8 -Path $Ctrl
Ok "users.gateway.controller.ts yazıldı."

# Module (HttpModule + kayıtlar)
@'
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
'@ | Set-Content -Encoding UTF8 -Path $Mod
Ok "users.gateway.module.ts yazıldı."

# AppModule import’unu UsersGatewayModule’a sabitle
if(!(Test-Path $AppMod)){ throw "Bulunamadı: $AppMod" }
$txt = Get-Content $AppMod -Raw
$txt = $txt -replace "from\s+['""]\.\/users\/users\.module['""]", "from './users/users.gateway.module'"
if($txt -notmatch "UsersGatewayModule"){
  if($txt -match "from '@nestjs\/common';"){
    $txt = $txt -replace "from '@nestjs\/common';","from '@nestjs/common';`r`nimport { UsersGatewayModule } from './users/users.gateway.module';"
  } else {
    $txt = "import { UsersGatewayModule } from './users/users.gateway.module';`r`n$txt"
  }
}
if($txt -match "imports:\s*\[([^\]]*)\]"){
  $inside = $matches[1].Trim()
  if($inside -notmatch "UsersGatewayModule"){
    $txt = $txt -replace "imports:\s*\[([^\]]*)\]", ("imports: [" + ($inside -ne "" ? "$inside, " : "") + "UsersGatewayModule]")
  }
}else{
  $txt = $txt -replace "@Module\(\{","@Module({`r`n  imports: [UsersGatewayModule],"
}
$txt | Set-Content -Encoding UTF8 -Path $AppMod
Ok "app.module.ts UsersGatewayModule ile güncellendi."

Write-Host "`nHazır. Şimdi gateway'i yeniden başlatın." -f Yellow
