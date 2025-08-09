# Kullanıcı mikroservisini Gateway'e entegre eder
Write-Host "🚀 Gateway entegrasyonu başlatılıyor..." -ForegroundColor Cyan

# 1. user directory oluştur
$userDir = "services/gateway-service/src/user"
New-Item -ItemType Directory -Force -Path $userDir | Out-Null

# 2. user.proxy.ts oluştur
@"
import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class UserProxyService {
  private readonly baseUrl = 'http://localhost:3002/users';

  constructor(private readonly httpService: HttpService) {}

  async findAll() {
    const res$ = this.httpService.get(this.baseUrl);
    const res = await firstValueFrom(res$);
    return res.data;
  }

  async findOne(id: string) {
    const res$ = this.httpService.get(`${this.baseUrl}/${id}`);
    const res = await firstValueFrom(res$);
    return res.data;
  }

  async create(data: any) {
    const res$ = this.httpService.post(this.baseUrl, data);
    const res = await firstValueFrom(res$);
    return res.data;
  }

  async update(id: string, data: any) {
    const res$ = this.httpService.put(`${this.baseUrl}/${id}`, data);
    const res = await firstValueFrom(res$);
    return res.data;
  }

  async remove(id: string) {
    const res$ = this.httpService.delete(`${this.baseUrl}/${id}`);
    const res = await firstValueFrom(res$);
    return res.data;
  }
}
"@ | Out-File -Encoding UTF8 "$userDir/user.proxy.ts"

# 3. user.controller.ts oluştur
@"
import { Controller, Get, Post, Body, Param, Put, Delete } from '@nestjs/common';
import { UserProxyService } from './user.proxy';

@Controller('users')
export class UserController {
  constructor(private readonly userProxy: UserProxyService) {}

  @Get()
  findAll() {
    return this.userProxy.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.userProxy.findOne(id);
  }

  @Post()
  create(@Body() data: any) {
    return this.userProxy.create(data);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() data: any) {
    return this.userProxy.update(id, data);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.userProxy.remove(id);
  }
}
"@ | Out-File -Encoding UTF8 "$userDir/user.controller.ts"

# 4. user.module.ts oluştur
@"
import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { UserController } from './user.controller';
import { UserProxyService } from './user.proxy';

@Module({
  imports: [HttpModule],
  controllers: [UserController],
  providers: [UserProxyService],
})
export class UserModule {}
"@ | Out-File -Encoding UTF8 "$userDir/user.module.ts"

# Bilgilendirme
Write-Host "✅ Gateway'e user proxy entegre edildi." -ForegroundColor Green
Write-Host "🧩 Aşağıdaki satırı AppModule'de imports alanına eklemeyi unutma:" -ForegroundColor Yellow
Write-Host '    imports: [..., UserModule]' -ForegroundColor Yellow
Write-Host "🧠 Ve gerekli yolu import etmeyi unutma: './user/user.module'" -ForegroundColor Yellow
