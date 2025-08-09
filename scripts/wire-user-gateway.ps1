<# =====================================================================
  wire-user-gateway.ps1
  Amaç:
    - user-service ve gateway-service için .env güncelle
    - Gerekli klasörleri güvenle oluştur (LiteralPath hatası olmadan)
    - gateway-service içinde users modülü (controller/service/module) üret
    - pnpm install çalıştır
    - Servisleri ayrı pencerelerde dev modda başlat
  Notlar:
    - Tüm yollar çift tırnak içinde
    - PowerShell 7+ uyumlu
    - Write-Host ile net durum çıktıları
===================================================================== #>

[CmdletBinding()]
param(
  [string]$RepoRoot = (Get-Location).Path,
  [int]$UserPortPreferred = 3002,
  [int]$GatewayPortPreferred = 3005
)

# ------------------ Yardımcı Fonksiyonlar ------------------

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "✔ $msg"  -ForegroundColor Green }
function Write-Err($msg)  { Write-Host "✖ $msg"  -ForegroundColor Red }

function New-DirSafe {
  param([Parameter(Mandatory)][string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    [void][System.IO.Directory]::CreateDirectory($Path)
  }
}

function Is-PortFree {
  param([int]$Port)
  try {
    $listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback, $Port)
    $listener.Start()
    $listener.Stop()
    return $true
  } catch {
    return $false
  }
}

function Find-FreePort {
  param([int]$StartPort, [int]$MaxTries = 100)
  $p = $StartPort
  for ($i = 0; $i -lt $MaxTries; $i++) {
    if (Is-PortFree -Port $p) { return $p }
    $p++
  }
  throw "Uygun boş port bulunamadı. Başlangıç: $StartPort"
}

function Set-EnvVar {
  param(
    [Parameter(Mandatory)][string]$EnvFile,
    [Parameter(Mandatory)][string]$Key,
    [Parameter(Mandatory)][string]$Value
  )
  if (-not (Test-Path -LiteralPath $EnvFile)) {
    New-DirSafe (Split-Path -LiteralPath $EnvFile -Parent)
    Set-Content -LiteralPath $EnvFile -Value "" -Encoding UTF8
  }

  $content = Get-Content -LiteralPath $EnvFile -Raw
  $pattern = "^(?m)$([Regex]::Escape($Key))=.*$"

  if ($content -match $pattern) {
    $newContent = [Regex]::Replace($content, $pattern, "$Key=$Value")
  } else {
    if ($content.Length -gt 0 -and -not $content.EndsWith("`n")) { $content += "`r`n" }
    $newContent = $content + "$Key=$Value`r`n"
  }
  Set-Content -LiteralPath $EnvFile -Value $newContent -Encoding UTF8
}

function Replace-InFile {
  param(
    [Parameter(Mandatory)][string]$File,
    [Parameter(Mandatory)][string]$Pattern,
    [Parameter(Mandatory)][string]$Replacement
  )
  if (-not (Test-Path -LiteralPath $File)) { return $false }
  $raw = Get-Content -LiteralPath $File -Raw
  $new = [Regex]::Replace($raw, $Pattern, $Replacement, [System.Text.RegularExpressions.RegexOptions]::Singleline)
  if ($new -ne $raw) {
    Set-Content -LiteralPath $File -Value $new -Encoding UTF8
    return $true
  }
  return $false
}

function Run-PnpmInstall {
  param([Parameter(Mandatory)][string]$WorkDir)
  Push-Location $WorkDir
  try {
    pnpm install
  } finally {
    Pop-Location
  }
}

function Start-DevWindow {
  param(
    [Parameter(Mandatory)][string]$WorkDir,
    [Parameter(Mandatory)][string]$Title
  )
  $cmd = "pnpm run dev"
  Start-Process pwsh -ArgumentList @("-NoExit","-Command","cd `"$WorkDir`"; `$Host.UI.RawUI.WindowTitle = `"$Title`"; $cmd")
}

# ------------------ Yol Tanımları ------------------

$UserServiceDir   = Join-Path $RepoRoot "services\user-service"
$GatewayServiceDir= Join-Path $RepoRoot "services\gateway-service"

$UserEnvFile      = Join-Path $UserServiceDir ".env"
$GatewayEnvFile   = Join-Path $GatewayServiceDir ".env"

$GwSrcDir         = Join-Path $GatewayServiceDir "src"
$GwUsersDir       = Join-Path $GwSrcDir "users"
$GwUsersModule    = Join-Path $GwUsersDir "users.module.ts"
$GwUsersService   = Join-Path $GwUsersDir "users.service.ts"
$GwUsersCtrl      = Join-Path $GwUsersDir "users.controller.ts"
$GwAppModule      = Join-Path $GwSrcDir "app.module.ts"
$GwMainTs         = Join-Path $GwSrcDir "main.ts"

# ------------------ Başla ------------------

Write-Step "user-service kurulumu başlıyor"

# Portları belirle
$UserPort = if (Is-PortFree -Port $UserPortPreferred) { $UserPortPreferred } else { Find-FreePort -StartPort ($UserPortPreferred+1) }
Write-Ok "User Service Port: $UserPort"

New-DirSafe $UserServiceDir
Set-EnvVar -EnvFile $UserEnvFile -Key "PORT" -Value "$UserPort"
Write-Ok ".env güncellendi: $UserEnvFile"

# Kullanıcı servisi URL'si (Gateway için)
$UserServiceUrl = "http://localhost:$UserPort"

Write-Step "user-service pnpm install"
Run-PnpmInstall -WorkDir $UserServiceDir
Write-Ok "user-service bağımlılıkları kuruldu"

# ------------------ Gateway ------------------

Write-Step "gateway-service entegrasyonu başlıyor"

$GatewayPort = if (Is-PortFree -Port $GatewayPortPreferred) { $GatewayPortPreferred } else { Find-FreePort -StartPort ($GatewayPortPreferred+1) }
Write-Ok "Gateway Port: $GatewayPort"

New-DirSafe $GatewayServiceDir
Set-EnvVar -EnvFile $GatewayEnvFile -Key "PORT" -Value "$GatewayPort"
Set-EnvVar -EnvFile $GatewayEnvFile -Key "USER_SERVICE_URL" -Value $UserServiceUrl
Write-Ok ".env güncellendi: $GatewayEnvFile"

# Klasörleri güvenle oluştur (LiteralPath kullanmadan)
New-DirSafe $GwSrcDir
New-DirSafe $GwUsersDir
Write-Ok "Gateway users klasörü hazır: $GwUsersDir"

# Users module dosyalarını üret
$usersModuleTs = @"
import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';

@Module({
  imports: [HttpModule],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
"@

$usersServiceTs = @"
import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class UsersService {
  constructor(private readonly http: HttpService) {}

  private get baseUrl(): string {
    return process.env.USER_SERVICE_URL || 'http://localhost:3002';
  }

  async health() {
    const url = \`\${this.baseUrl}/api/users/health\`;
    const { data } = await firstValueFrom(this.http.get(url));
    return data;
  }

  async list() {
    const url = \`\${this.baseUrl}/api/users\`;
    const { data } = await firstValueFrom(this.http.get(url));
    return data;
  }
}
"@

$usersControllerTs = @"
import { Controller, Get } from '@nestjs/common';
import { UsersService } from './users.service';

@Controller('api/users')
export class UsersController {
  constructor(private readonly users: UsersService) {}

  @Get('health')
  health() {
    return this.users.health();
  }

  @Get()
  list() {
    return this.users.list();
  }
}
"@

Set-Content -LiteralPath $GwUsersModule -Value $usersModuleTs -Encoding UTF8
Set-Content -LiteralPath $GwUsersService -Value $usersServiceTs -Encoding UTF8
Set-Content -LiteralPath $GwUsersCtrl   -Value $usersControllerTs -Encoding UTF8
Write-Ok "users.module.ts / users.service.ts / users.controller.ts yazıldı"

# app.module.ts içine UsersModule ekle (varsa dokunma)
if (Test-Path -LiteralPath $GwAppModule) {
  $raw = Get-Content -LiteralPath $GwAppModule -Raw

  if ($raw -notmatch "from './users/users.module'") {
    $raw = "import { UsersModule } from './users/users.module';`r`n" + $raw
  }

  # @Module({... imports: [...] ...}) içine UsersModule ekle
  if ($raw -match "@Module\(\s*\{(.|\s)*?\}\s*\)") {
    # imports: [...] var mı?
    if ($raw -match "imports\s*:\s*\[([^\]]*)\]") {
      $raw = [Regex]::Replace($raw, "imports\s*:\s*\[([^\]]*)\]", {
        param($m)
        $inside = $m.Groups[1].Value.Trim()
        if ($inside -notmatch "(^|,)\s*UsersModule(\s|,|$)") {
          if ([string]::IsNullOrWhiteSpace($inside)) { $inside = "UsersModule" } else { $inside += ", UsersModule" }
        }
        "imports: [$inside]"
      }, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    } else {
      # imports yoksa ekleyelim
      $raw = [Regex]::Replace($raw, "@Module\(\s*\{", "@Module({`r`n  imports: [UsersModule],", [System.Text.RegularExpressions.RegexOptions]::Singleline)
    }
  }

  Set-Content -LiteralPath $GwAppModule -Value $raw -Encoding UTF8
  Write-Ok "app.module.ts içine UsersModule eklendi/korundu"
} else {
  Write-Err "app.module.ts bulunamadı: $GwAppModule (manuel import gerekebilir)"
}

# main.ts yoksa basit bir bootstrap yaz
if (-not (Test-Path -LiteralPath $GwMainTs)) {
  $mainTs = @"
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const port = process.env.PORT ? parseInt(process.env.PORT, 10) : 3005;
  await app.listen(port);
  console.log(\`Gateway running on http://localhost:\${port}\`);
}
bootstrap();
"@
  Set-Content -LiteralPath $GwMainTs -Value $mainTs -Encoding UTF8
  Write-Ok "main.ts oluşturuldu"
}

Write-Step "gateway-service pnpm install"
Run-PnpmInstall -WorkDir $GatewayServiceDir
Write-Ok "gateway-service bağımlılıkları kuruldu"

# ------------------ Servisleri başlat ------------------

Write-Step "servisler başlatılıyor (ayrı pencerelerde)"
Start-DevWindow -WorkDir $UserServiceDir    -Title "user-service :$UserPort"
Start-DevWindow -WorkDir $GatewayServiceDir -Title "gateway-service :$GatewayPort"

Write-Ok ("User Service: http://localhost:{0}/api/users/health" -f $UserPort)
Write-Ok ("Gateway:      http://localhost:{0}/api/users/health" -f $GatewayPort)

Write-Host ""
Write-Host "Test için:" -ForegroundColor Yellow
Write-Host ("  iwr http://localhost:{0}/api/users/health | Select-Object -ExpandProperty Content" -f $UserPort)
Write-Host ("  iwr http://localhost:{0}/api/users/health | Select-Object -ExpandProperty Content" -f $GatewayPort)
Write-Host ""
