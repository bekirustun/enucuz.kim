# PowerShell Script: setup-user-service.ps1
Write-Host "🚀 user-service kurulumu başlatılıyor..." -ForegroundColor Cyan

# 1. Klasöre git
Set-Location "D:\Ustunnet\sitelerim\enucuz.kim\services"

# 2. NestJS ile proje oluştur
npx @nestjs/cli new user-service --package-manager npm --skip-git -y
Set-Location "user-service"

# 3. PostgreSQL ve Config için gerekli paketleri kur
npm install --save @nestjs/typeorm typeorm pg @nestjs/config

# 4. .env dosyasını oluştur
@"
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=ZB23672367fb?
DB_NAME=enucuzkim
"@ | Out-File -Encoding UTF8 ".env"

# 5. app.module.ts içerik değiştirme (örnek yapı)
$appModulePath = "src\app.module.ts"
$appModuleCode = @"
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST,
      port: Number(process.env.DB_PORT),
      username: process.env.DB_USERNAME,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      entities: [__dirname + '/**/*.entity{.ts,.js}'],
      synchronize: true,
    }),
  ],
})
export class AppModule {}
"@
Set-Content -Path $appModulePath -Value $appModuleCode -Encoding UTF8

# 6. User modülü, servis ve kontrolcü oluştur
npx nest g module user
npx nest g service user
npx nest g controller user

Write-Host "✅ user-service başarıyla kuruldu ve yapılandırıldı." -ForegroundColor Green
