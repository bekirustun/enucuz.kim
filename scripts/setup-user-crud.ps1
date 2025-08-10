# scripts/setup-user-crud.ps1
# enucuz.kim - user-service CRUD otomasyon scripti
# Notlar:
# - Tüm yollar çift tırnaklıdır.
# - Var olan dosyaları güvenli biçimde yedekler (.bak).
# - Servis ayakta ise otomatik CRUD testleri yapılır (port varsayılan: 3002).
# - İstersen script içinde $Port ve $RepoRoot'u özelleştirebilirsin.

param(
  [string]$RepoRoot = (Resolve-Path ".").Path,
  [int]$Port = 3002
)

function Write-Step($msg, $color="Cyan") {
  Write-Host ("== {0} ==" -f $msg) -ForegroundColor $color
}

function Ensure-Dir($p) {
  if (-not (Test-Path -LiteralPath $p)) {
    New-Item -ItemType Directory -Path $p | Out-Null
  }
}

$ServiceDir  = Join-Path $RepoRoot "services\user-service"
$SrcDir      = Join-Path $ServiceDir "src"
$UserDir     = Join-Path $SrcDir "user"
$MainTsPath  = Join-Path $SrcDir "main.ts"
$ModulePath  = Join-Path $UserDir "user.module.ts"
$CtrlPath    = Join-Path $UserDir "user.controller.ts"
$SvcPath     = Join-Path $UserDir "user.service.ts"
$EntityPath  = Join-Path $UserDir "user.entity.ts"
$DtoDir      = Join-Path $UserDir "dto"
$CreateDto   = Join-Path $DtoDir "create-user.dto.ts"
$UpdateDto   = Join-Path $DtoDir "update-user.dto.ts"

Write-Step "Başlıyor - User CRUD kurulumu"
Write-Host "RepoRoot : $RepoRoot"
Write-Host "Service  : $ServiceDir"

# Klasörler
Ensure-Dir "$ServiceDir"
Ensure-Dir "$SrcDir"
Ensure-Dir "$UserDir"
Ensure-Dir "$DtoDir"

# Yardımcı: güvenli yazım (önce .bak alınır)
function Safe-Write($path, $content) {
  if (Test-Path -LiteralPath $path) {
    Copy-Item -LiteralPath $path -Destination ($path + ".bak") -Force
  }
  $content | Set-Content -LiteralPath $path -Encoding UTF8
}

# === Entity ===
Write-Step "user.entity.ts yazılıyor"
$entityContent = @'
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

export type UserRole = 'admin' | 'editor' | 'user';

@Entity({ name: 'users' })
export class User {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column({ length: 120 })
  name!: string;

  @Column({ unique: true, length: 160 })
  email!: string;

  @Column({ type: 'varchar', length: 20, default: 'user' })
  role!: UserRole;

  @CreateDateColumn({ type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamptz' })
  updatedAt!: Date;
}
'@
Safe-Write "$EntityPath" $entityContent
Write-Host "✓ user.entity.ts" -ForegroundColor Green

# === DTO'lar ===
Write-Step "DTO'lar yazılıyor"
$createDtoContent = @'
import { IsEmail, IsIn, IsOptional, IsString, MaxLength } from 'class-validator';
import { UserRole } from '../user.entity';

export class CreateUserDto {
  @IsString()
  @MaxLength(120)
  name!: string;

  @IsEmail()
  @MaxLength(160)
  email!: string;

  @IsOptional()
  @IsIn(['admin', 'editor', 'user'])
  role?: UserRole;
}
'@
Safe-Write "$CreateDto" $createDtoContent

$updateDtoContent = @'
import { PartialType } from '@nestjs/mapped-types';
import { CreateUserDto } from './create-user.dto';

export class UpdateUserDto extends PartialType(CreateUserDto) {}
'@
Safe-Write "$UpdateDto" $updateDtoContent
Write-Host "✓ create/update DTO'lar" -ForegroundColor Green

# === Service ===
Write-Step "user.service.ts yazılıyor"
$serviceContent = @'
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './user.entity';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User) private readonly repo: Repository<User>,
  ) {}

  async create(dto: CreateUserDto) {
    const user = this.repo.create({ role: 'user', ...dto });
    return this.repo.save(user);
  }

  findAll() {
    return this.repo.find({ order: { id: 'ASC' } });
  }

  async findOne(id: number) {
    const user = await this.repo.findOne({ where: { id } });
    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  async update(id: number, dto: UpdateUserDto) {
    const user = await this.findOne(id);
    Object.assign(user, dto);
    return this.repo.save(user);
  }

  async remove(id: number) {
    const user = await this.findOne(id);
    await this.repo.remove(user);
    return { deleted: true, id };
  }
}
'@
Safe-Write "$SvcPath" $serviceContent
Write-Host "✓ user.service.ts" -ForegroundColor Green

# === Controller ===
Write-Step "user.controller.ts yazılıyor"
$controllerContent = @'
import { Controller, Get, Post, Body, Param, ParseIntPipe, Patch, Delete } from '@nestjs/common';
import { UserService } from './user.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Controller('api/users')
export class UserController {
  constructor(private readonly service: UserService) {}

  @Get('health')
  health() {
    return { ok: true, service: 'user-service', ts: new Date().toISOString() };
  }

  @Get()
  list() {
    return this.service.findAll();
  }

  @Get(':id')
  get(@Param('id', ParseIntPipe) id: number) {
    return this.service.findOne(id);
  }

  @Post()
  create(@Body() dto: CreateUserDto) {
    return this.service.create(dto);
  }

  @Patch(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateUserDto) {
    return this.service.update(id, dto);
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.service.remove(id);
  }
}
'@
Safe-Write "$CtrlPath" $controllerContent
Write-Host "✓ user.controller.ts" -ForegroundColor Green

# === Module ===
Write-Step "user.module.ts yazılıyor"
$moduleContent = @'
import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from './user.entity';
import { UserController } from './user.controller';
import { UserService } from './user.service';
import { UserProxyService } from './user.proxy';

@Module({
  imports: [HttpModule, TypeOrmModule.forFeature([User])],
  controllers: [UserController],
  providers: [UserService, UserProxyService],
  exports: [UserService, UserProxyService],
})
export class UserModule {}
'@
Safe-Write "$ModulePath" $moduleContent
Write-Host "✓ user.module.ts" -ForegroundColor Green

# === main.ts ValidationPipe ekleme ===
Write-Step "main.ts doğrulama boru hattı (ValidationPipe) kontrol/ekleme"
$validationSnippet = @'
import { ValidationPipe } from '@nestjs/common';
'@

if (Test-Path -LiteralPath "$MainTsPath") {
  $mainContent = Get-Content -LiteralPath "$MainTsPath" -Raw
  $needsImport = ($mainContent -notmatch "ValidationPipe")
  $needsUseGlobal = ($mainContent -notmatch "useGlobalPipes")

  if ($needsImport) {
    # import satırlarının başına ValidationPipe importunu ekle
    $mainContent = $mainContent -replace "import\s+\{([^}]*)\}\s+from\s+'@nestjs/common';", {'import { $1, ValidationPipe } from ''@nestjs/common'';'}
    if ($mainContent -notmatch "ValidationPipe") {
      # fallback: en başa ekle
      $mainContent = $validationSnippet + "`r`n" + $mainContent
    }
  }

  if ($needsUseGlobal) {
    # app oluşturulduktan hemen sonra ekle
    $mainContent = $mainContent -replace "(const\s+app\s*=\s*await\s+NestFactory\.create\([^\)]*\);\s*)", '$1app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }));'
  }

  Safe-Write "$MainTsPath" $mainContent
  Write-Host "✓ main.ts güncellendi" -ForegroundColor Green
}
else {
  $mainNew = @'
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }));
  await app.listen(process.env.PORT ?? 3002);
}
bootstrap();
'@
  Safe-Write "$MainTsPath" $mainNew
  Write-Host "✓ main.ts oluşturuldu" -ForegroundColor Green
}

# === Bağımlılık kontrolü (yumuşak) ===
Write-Step "Bağımlılık kontrolü (class-validator, mapped-types, typeorm)"
Push-Location "$ServiceDir"
try {
  # Kurulu değilse ekle (pnpm varsa)
  if (Get-Command pnpm -ErrorAction SilentlyContinue) {
    pnpm add class-validator class-transformer @nestjs/mapped-types -w | Out-Null
    Write-Host "✓ pnpm add tamam" -ForegroundColor Green
  } else {
    Write-Host "pnpm bulunamadı, bağımlılık ekleme atlandı." -ForegroundColor Yellow
  }
} catch {
  Write-Host "Uyarı: pnpm add sırasında sorun: $($_.Exception.Message)" -ForegroundColor Yellow
}
Pop-Location

# === Testler (servis ayaktaysa) ===
$HealthUrl = "http://localhost:$Port/api/users/health"
Write-Step "Sağlık kontrolü ve CRUD testleri (opsiyonel)"
$serviceUp = $false
try {
  $resp = iwr $HealthUrl -TimeoutSec 2 -UseBasicParsing
  if ($resp.StatusCode -ge 200 -and $resp.StatusCode -lt 300) { $serviceUp = $true }
} catch { $serviceUp = $false }

if ($serviceUp) {
  Write-Host "✓ Servis ayakta görünüyor ($HealthUrl)" -ForegroundColor Green

  $Base = "http://localhost:$Port/api/users"

  Write-Host "`n== LIST (ilk) ==" -ForegroundColor Cyan
  iwr "$Base" -UseBasicParsing | % Content

  Write-Host "`n== CREATE ==" -ForegroundColor Cyan
  $createJson = (@{ name="Grace Hopper"; email="grace@example.com"; role="admin" } | ConvertTo-Json)
  $createRes  = iwr "$Base" -Method POST -Body $createJson -ContentType "application/json" -UseBasicParsing | % Content
  $created    = $createRes | ConvertFrom-Json
  $cid        = $created.id
  Write-Host ("Created ID: {0}" -f $cid) -ForegroundColor Green

  Write-Host "`n== READ (by id) ==" -ForegroundColor Cyan
  iwr ("$Base/{0}" -f $cid) -UseBasicParsing | % Content

  Write-Host "`n== UPDATE ==" -ForegroundColor Cyan
  $updJson = (@{ name="Grace B. Hopper"; role="editor" } | ConvertTo-Json)
  iwr ("$Base/{0}" -f $cid) -Method PATCH -Body $updJson -ContentType "application/json" -UseBasicParsing | % Content

  Write-Host "`n== DELETE ==" -ForegroundColor Cyan
  iwr ("$Base/{0}" -f $cid) -Method DELETE -UseBasicParsing | % Content

  Write-Host "`n== LIST (son) ==" -ForegroundColor Cyan
  iwr "$Base" -UseBasicParsing | % Content
} else {
  Write-Host ("Servis şu an ayakta değil: {0}" -f $HealthUrl) -ForegroundColor Yellow
  Write-Host "Örnek çalıştırma:" -ForegroundColor Yellow
  Write-Host ("  cd ""{0}""" -f $ServiceDir)
  Write-Host "  pnpm install"
  Write-Host "  pnpm run dev"
  Write-Host ("  iwr ""{0}"" | % Content" -f $HealthUrl)
}

Write-Step "Bitti" "Green"
