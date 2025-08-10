# ==========================
# setup-user-pagination.ps1
# Esma ❤️ Bekir
# ==========================

$ErrorActionPreference = "Stop"

# Yol ayarları
$BaseDir = "D:\U\S\enucuz.kim\services\user-service\src\user"
$DtoDir  = Join-Path $BaseDir "dto"
$EntDir  = Join-Path $BaseDir "entities"
$Backup  = "D:\U\S\enucuz.kim\services\user-service\_backup_{0}" -f (Get-Date -Format "yyyyMMdd_HHmmss")

Write-Host "== Yedekleme başlıyor ==" -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $Backup | Out-Null

Copy-Item (Join-Path $BaseDir "user.controller.ts") $Backup -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $BaseDir "user.service.ts")    $Backup -Force -ErrorAction SilentlyContinue
if (Test-Path $DtoDir) { Copy-Item $DtoDir (Join-Path $Backup "dto") -Recurse -Force }

Write-Host "Yedekleme tamamlandı: $Backup" -ForegroundColor Green

# Eski çoğul klasörü temizle
$PluralDir = "D:\U\S\enucuz.kim\services\user-service\src\users"
if (Test-Path $PluralDir) {
    Remove-Item $PluralDir -Recurse -Force
    Write-Host "Eski 'src\\users' klasörü silindi." -ForegroundColor Yellow
}

# Mevcut dosyaları sil
Remove-Item (Join-Path $BaseDir "user.controller.ts") -Force -ErrorAction SilentlyContinue
Remove-Item (Join-Path $BaseDir "user.service.ts")    -Force -ErrorAction SilentlyContinue

# DTO klasörü garantiye al
New-Item -ItemType Directory -Force -Path $DtoDir | Out-Null

# 1) list-users.dto.ts oluştur
@"
import { Type } from 'class-transformer';
import { IsIn, IsInt, IsOptional, IsString, Min } from 'class-validator';

export class ListUsersDto {
  @Type(() => Number)
  @IsInt() @Min(1)
  @IsOptional()
  page?: number = 1;

  @Type(() => Number)
  @IsInt() @Min(1)
  @IsOptional()
  pageSize?: number = 10;

  @IsOptional() @IsIn(['id','name','email','role','createdAt','updatedAt'])
  sortBy?: 'id'|'name'|'email'|'role'|'createdAt'|'updatedAt' = 'createdAt';

  @IsOptional() @IsIn(['asc','desc'])
  order?: 'asc'|'desc' = 'desc';

  @IsOptional() @IsString()
  q?: string;

  @IsOptional() @IsString()
  role?: string;
}
"@ | Set-Content (Join-Path $DtoDir "list-users.dto.ts") -Encoding UTF8

# 2) user.service.ts oluştur
@"
import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { ListUsersDto } from './dto/list-users.dto';
import { User } from './entities/user.entity';

type Order = 'asc' | 'desc';

@Injectable()
export class UserService {
  private seq = 2;
  private readonly users = new Map<number, User>([
    [1, { id: 1, name: 'Ada Lovelace', email: 'ada@example.com',  role: 'admin', createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() }],
    [2, { id: 2, name: 'Alan Turing',  email: 'alan@example.com', role: 'user',  createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() }],
  ]);

  health() {
    return { ok: true, service: 'user-service', ts: new Date().toISOString() };
  }

  findAll(): User[] {
    const { items } = this.list({ page: 1, pageSize: 1000, sortBy: 'createdAt', order: 'desc' });
    return items;
  }

  list(query: ListUsersDto) {
    const page     = query.page     ?? 1;
    const pageSize = query.pageSize ?? 10;
    const sortBy   = query.sortBy   ?? 'createdAt';
    const order    = ((query.order ?? 'desc').toLowerCase() as Order);
    const q        = (query.q ?? '').toLowerCase().trim();
    const role     = query.role?.trim();

    let arr = Array.from(this.users.values());

    if (role) arr = arr.filter(u => (u.role ?? '').toLowerCase() === role.toLowerCase());
    if (q) {
      arr = arr.filter(u =>
        (u.name  ?? '').toLowerCase().includes(q) ||
        (u.email ?? '').toLowerCase().includes(q)
      );
    }

    const norm = (v: any) => (v == null ? '' : typeof v === 'number' ? v : String(v).toLowerCase());
    arr.sort((a, b) => {
      const av: any = (a as any)[sortBy];
      const bv: any = (b as any)[sortBy];
      if (av === bv) return 0;
      const na = norm(av), nb = norm(bv);
      return na < nb ? -1 : 1;
    });
    if (order === 'desc') arr.reverse();

    const total = arr.length;
    const totalPages = Math.max(1, Math.ceil(total / pageSize));
    const start = (page - 1) * pageSize;
    const items = arr.slice(start, start + pageSize);

    return { page, pageSize, total, totalPages, sortBy, order, items };
  }

  findOne(id: number): User {
    const u = this.users.get(id);
    if (!u) throw new NotFoundException(\`User \${id} not found\`);
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
    if (!ok) throw new NotFoundException(\`User \${id} not found\`);
    return { deleted: true };
  }
}
"@ | Set-Content (Join-Path $BaseDir "user.service.ts") -Encoding UTF8

# 3) user.controller.ts oluştur
@"
import { 
  Controller, Get, Post, Body, Param, Delete, Put, Patch,
  HttpException, HttpStatus, Query, UsePipes, ValidationPipe
} from '@nestjs/common';
import { UserService } from './user.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { ListUsersDto } from './dto/list-users.dto';

@Controller('api/users')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Get('health')
  health() {
    return this.userService.health();
  }

  @Post()
  async create(@Body() createUserDto: CreateUserDto) {
    try {
      return await this.userService.create(createUserDto);
    } catch (err) {
      throw new HttpException(err.message, HttpStatus.BAD_REQUEST);
    }
  }

  @Get()
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  async findAll(@Query() query: ListUsersDto) {
    try {
      return await this.userService.list(query);
    } catch (err) {
      throw new HttpException(err.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    try {
      return await this.userService.findOne(+id);
    } catch {
      throw new HttpException('Kullanıcı bulunamadı', HttpStatus.NOT_FOUND);
    }
  }

  @Put(':id')
  async updatePut(@Param('id') id: string, @Body() dto: UpdateUserDto) {
    try {
      return await this.userService.update(+id, dto);
    } catch (err) {
      throw new HttpException(err.message, HttpStatus.BAD_REQUEST);
    }
  }

  @Patch(':id')
  async updatePatch(@Param('id') id: string, @Body() dto: UpdateUserDto) {
    try {
      return await this.userService.update(+id, dto);
    } catch (err) {
      throw new HttpException(err.message, HttpStatus.BAD_REQUEST);
    }
  }

  @Delete(':id')
  async remove(@Param('id') id: string) {
    try {
      return await this.userService.remove(+id);
    } catch {
      throw new HttpException('Kullanıcı silinemedi', HttpStatus.BAD_REQUEST);
    }
  }
}
"@ | Set-Content (Join-Path $BaseDir "user.controller.ts") -Encoding UTF8

Write-Host "== Tüm dosyalar güncellendi. Artık user-service ve gateway'i yeniden başlatabilirsin. ==" -ForegroundColor Green
