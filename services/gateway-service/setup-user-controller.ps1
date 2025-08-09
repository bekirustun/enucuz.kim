# setup-user-controller.ps1
$userDir = "D:\Ustunnet\sitelerim\enucuz.kim\services\gateway-service\src\user"

# Klasör yoksa oluştur
New-Item -ItemType Directory -Force -Path "$userDir" | Out-Null

# controller dosyasını oluştur
$userController = @"
import { Controller, Get, Post, Body, Param, Put, Delete } from '@nestjs/common';
import { UserProxyService } from './user.proxy';

@Controller('users')
export class UserController {
  constructor(private readonly userService: UserProxyService) {}

  @Get()
  findAll() {
    return this.userService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.userService.findOne(id);
  }

  @Post()
  create(@Body() data: any) {
    return this.userService.create(data);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() data: any) {
    return this.userService.update(id, data);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.userService.remove(id);
  }
}
"@

$userController | Out-File -Encoding UTF8 "$userDir\user.controller.ts"

Write-Host "✅ 'user.controller.ts' dosyası başarıyla oluşturuldu." -ForegroundColor Green
Write-Host "🧠 Unutma: 'user.module.ts' içinde bu controller'ı da 'controllers' dizisine ekle!" -ForegroundColor Yellow
