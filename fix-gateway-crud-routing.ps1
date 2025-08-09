# fix-gateway-crud-routing.ps1
param(
  [string]$RepoRoot = "D:\U\S\enucuz.kim"
)
$ErrorActionPreference = "Stop"
function Ok($m){ Write-Host "✔ $m" -f Green }
function Info($m){ Write-Host ">> $m" -f Cyan }

$AppModule = Join-Path $RepoRoot "services\gateway-service\src\app.module.ts"
if (!(Test-Path $AppModule)) { throw "Bulunamadı: $AppModule" }

$txt = Get-Content $AppModule -Raw

# Import satırını 'users.gateway.module' dosyasına sabitle
$txt = $txt -replace "from\s+'\.\/users\/users\.module';", "from './users/users.gateway.module';"
$txt = $txt -replace "from\s+\"\.\/users\/users\.module\";", "from \"./users/users.gateway.module\";"

# Eğer UsersGatewayModule import'u hiç yoksa ekle
if ($txt -notmatch "UsersGatewayModule") {
  if ($txt -match "from '@nestjs\/common';") {
    $txt = $txt -replace "from '@nestjs\/common';","from '@nestjs/common';`r`nimport { UsersGatewayModule } from './users/users.gateway.module';"
  } else {
    $txt = "import { UsersGatewayModule } from './users/users.gateway.module';`r`n" + $txt
  }
}

# imports: [] içine UsersGatewayModule’ü ekle
if ($txt -match "imports:\s*\[([^\]]*)\]") {
  $inside = $matches[1]
  if ($inside -notmatch "UsersGatewayModule") {
    $txt = $txt -replace "imports:\s*\[([^\]]*)\]", ("imports: [" + $inside.Trim() + ( $inside.Trim() -ne "" ? ", " : "" ) + "UsersGatewayModule]")
  }
} else {
  $txt = $txt -replace "@Module\(\{","@Module({`r`n  imports: [UsersGatewayModule],"
}

$txt | Set-Content $AppModule -Encoding UTF8
Ok "app.module.ts -> UsersGatewayModule importu doğrulandı."

# Controller içeriğini de garanti altına al (CRUD var)
$Ctrl = Join-Path $RepoRoot "services\gateway-service\src\users\users.gateway.controller.ts"
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
'@ | Set-Content $Ctrl -Encoding UTF8
Ok "users.gateway.controller.ts (CRUD) garanti altına alındı."

# Module içeriğini de sabitle
$Mod = Join-Path $RepoRoot "services\gateway-service\src\users\users.gateway.module.ts"
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
'@ | Set-Content $Mod -Encoding UTF8
Ok "users.gateway.module.ts doğrulandı."
