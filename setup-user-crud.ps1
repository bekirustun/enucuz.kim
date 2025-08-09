# setup-user-crud.ps1
# enucuz.kim -> services/user-service için Users CRUD modülü kurulum scripti
# Çalıştırma:  PowerShell'i Yönetici olarak açın ve repo kökünde:
#   & ".\setup-user-crud.ps1"

param(
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

function Info($msg){ Write-Host ">> $msg" -ForegroundColor Cyan }
function Ok($msg){ Write-Host "✔ $msg" -ForegroundColor Green }
function Warn($msg){ Write-Host "! $msg" -ForegroundColor Yellow }
function Err($msg){ Write-Host "✖ $msg" -ForegroundColor Red }

# Yol değişkenleri (tamamı tırnaklı)
$UserServiceDir = Join-Path -Path $RepoRoot -ChildPath "services\user-service"
$SrcDir         = Join-Path -Path $UserServiceDir -ChildPath "src"
$UsersDir       = Join-Path -Path $SrcDir -ChildPath "users"
$DtoDir         = Join-Path -Path $UsersDir -ChildPath "dto"
$EntitiesDir    = Join-Path -Path $UsersDir -ChildPath "entities"

if (-not (Test-Path -LiteralPath $UserServiceDir)) {
  Err "Klasör bulunamadı: `"$UserServiceDir`". Lütfen repo kökünde çalıştırdığından emin ol."
  exit 1
}

Info "Klasörler oluşturuluyor..."
New-Item -ItemType Directory -Force -Path "$UsersDir"    | Out-Null
New-Item -ItemType Directory -Force -Path "$DtoDir"      | Out-Null
New-Item -ItemType Directory -Force -Path "$EntitiesDir" | Out-Null
Ok "Klasörler hazır."

# ---------- DTO: create ----------
$createDto = @'
import { IsEmail, IsOptional, IsString, MinLength } from 'class-validator';

export class CreateUserDto {
  @IsString()
  @MinLength(2)
  name!: string;

  @IsEmail()
  email!: string;

  @IsOptional()
  @IsString()
  role?: string;
}
'@
Set-Content -LiteralPath (Join-Path $DtoDir "create-user.dto.ts") -Encoding UTF8 -Value $createDto
Ok "create-user.dto.ts yazıldı."

# ---------- DTO: update ----------
$updateDto = @'
import { PartialType } from '@nestjs/mapped-types';
import { CreateUserDto } from './create-user.dto';

export class UpdateUserDto extends PartialType(CreateUserDto) {}
'@
Set-Content -LiteralPath (Join-Path $DtoDir "update-user.dto.ts") -Encoding UTF8 -Value $updateDto
Ok "update-user.dto.ts yazıldı."

# ---------- Entity (opsiyonel / tip amaçlı) ----------
$userEntity = @'
export class User {
  id!: number;
  name!: string;
  email!: string;
  role?: string;
  createdAt!: string;
  updatedAt!: string;
}
'@
Set-Content -LiteralPath (Join-Path $EntitiesDir "user.entity.ts") -Encoding UTF8 -Value $userEntity
Ok "user.entity.ts yazıldı."

# ---------- Service ----------
$serviceTs = @'
import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { User } from './entities/user.entity';

@Injectable()
export class UsersService {
  private seq = 2;
  private readonly users = new Map<number, User>([
    [1, { id: 1, name: 'Ada Lovelace', email: 'ada@example.com', role: 'admin', createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() }],
    [2, { id: 2, name: 'Alan Turing',  email: 'alan@example.com', role: 'user',  createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() }],
  ]);

  health() {
    return { ok: true, service: 'user-service', ts: new Date().toISOString() };
  }

  findAll(): User[] {
    return Array.from(this.users.values());
  }

  findOne(id: number): User {
    const u = this.users.get(id);
    if (!u) throw new NotFoundException(`User ${id} not found`);
    return u;
  }

  create(dto: CreateUserDto): User {
    const id = ++this.seq;
    const now = new Date().toISOString();
    const u: User = { id, createdAt: now, updatedAt: now, ...dto };
    this.users.set(id, u);
    return u;
  }

  update(id: number, dto: UpdateUserDto): User {
    const u = this.findOne(id);
    const merged: User = { ...u, ...dto, updatedAt: new Date().toISOString() };
    this.users.set(id, merged);
    return merged;
  }

  remove(id: number): { deleted: boolean } {
    const ok = this.users.delete(id);
    if (!ok) throw new NotFoundException(`User ${id} not found`);
    return { deleted: true };
  }
}
'@
Set-Content -LiteralPath (Join-Path $UsersDir "users.service.ts") -Encoding UTF8 -Value $serviceTs
Ok "users.service.ts yazıldı."

# ---------- Controller ----------
$controllerTs = @'
import { Body, Controller, Delete, Get, Param, ParseIntPipe, Patch, Post } from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Controller('api/users')
export class UsersController {
  constructor(private readonly users: UsersService) {}

  @Get('health')
  health() { return this.users.health(); }

  @Get()
  list() { return this.users.findAll(); }

  @Get(':id')
  get(@Param('id', ParseIntPipe) id: number) { return this.users.findOne(id); }

  @Post()
  create(@Body() dto: CreateUserDto) { return this.users.create(dto); }

  @Patch(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateUserDto) { return this.users.update(id, dto); }

  @Delete(':id')
  delete(@Param('id', ParseIntPipe) id: number) { return this.users.remove(id); }
}
'@
Set-Content -LiteralPath (Join-Path $UsersDir "users.controller.ts") -Encoding UTF8 -Value $controllerTs
Ok "users.controller.ts yazıldı."

# ---------- Module ----------
$moduleTs = @'
import { Module } from '@nestjs/common';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';

@Module({
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
'@
Set-Content -LiteralPath (Join-Path $UsersDir "users.module.ts") -Encoding UTF8 -Value $moduleTs
Ok "users.module.ts yazıldı."

# ---------- app.module.ts yamalama ----------
$appModulePath = Join-Path $SrcDir "app.module.ts"
if (Test-Path -LiteralPath $appModulePath) {
  $appModule = Get-Content -LiteralPath $appModulePath -Raw -Encoding UTF8

  if ($appModule -notmatch "UsersModule") {
    Info "app.module.ts içine UsersModule ekleniyor..."
    # import ekle
    if ($appModule -match "from '@nestjs/common';") {
      $appModule = $appModule -replace "from '@nestjs/common';", "from '@nestjs/common';`r`nimport { UsersModule } from './users/users.module';"
    } elseif ($appModule -match "^import .*;") {
      $appModule = $appModule -replace "^(import .+;\s*)", "`$1`r`nimport { UsersModule } from './users/users.module';`r`n"
    } else {
      $appModule = "import { UsersModule } from './users/users.module';`r`n" + $appModule
    }
    # imports array’ine ekle
    if ($appModule -match "imports:\s*\[([^\]]*)\]") {
      $appModule = $appModule -replace "imports:\s*\[([^\]]*)\]", { param($m) 
        $inside = $m.Groups[1].Value.Trim()
        if ($inside -eq "") { "imports: [UsersModule]" } 
        elseif ($inside -match "UsersModule") { "imports: [$inside]" } 
        else { "imports: [$inside, UsersModule]" }
      }
    } elseif ($appModule -match "@Module\(\{") {
      $appModule = $appModule -replace "@Module\(\{", "@Module({`r`n  imports: [UsersModule],"
    }
    Set-Content -LiteralPath $appModulePath -Encoding UTF8 -Value $appModule
    Ok "app.module.ts güncellendi."
  } else {
    Warn "app.module.ts zaten UsersModule içeriyor, atlandı."
  }
} else {
  Warn "app.module.ts bulunamadı, UsersModule el ile eklenmeli."
}

# ---------- main.ts yamalama (ValidationPipe + global prefix) ----------
$mainPath = Join-Path $SrcDir "main.ts"
if (Test-Path -LiteralPath $mainPath) {
  $main = Get-Content -LiteralPath $mainPath -Raw -Encoding UTF8
  $changed = $false

  if ($main -notmatch "ValidationPipe") {
    Info "ValidationPipe import ve kullanım ekleniyor..."
    if ($main -match "from '@nestjs/common';") {
      $main = $main -replace "from '@nestjs/common';", "from '@nestjs/common';`r`nimport { ValidationPipe } from '@nestjs/common';"
    } else {
      $main = "import { ValidationPipe } from '@nestjs/common';`r`n" + $main
    }
    $main = $main -replace "app\.listen\(", "app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidUnknownValues: false }));`r`n  app.setGlobalPrefix('');`r`n  app.listen("
    $changed = $true
  }

  if ($changed) {
    Set-Content -LiteralPath $mainPath -Encoding UTF8 -Value $main
    Ok "main.ts güncellendi."
  } else {
    Warn "main.ts yeterli görünüyor, değişiklik yapılmadı."
  }
} else {
  Warn "main.ts bulunamadı."
}

# ---------- package bağımlılıkları ----------
Info "Bağımlılıklar kontrol ediliyor..."
Set-Location -LiteralPath "$UserServiceDir"
# class-validator & mapped-types (Nest v11 ile)
pnpm add class-validator class-transformer @nestjs/mapped-types -w | Out-Null
Ok "Bağımlılıklar yüklendi (workspace)."

# ---------- Derleme / Çalıştırma ----------
Info "User-service geliştirme sunucusu başlatılıyor..."
try {
  pnpm run dev
} catch {
  Warn "Dev başlatılamadı. Manuel başlatabilirsiniz:"
  Write-Host 'PS> cd "D:\U\S\enucuz.kim\services\user-service"; pnpm run dev' -ForegroundColor Yellow
}
