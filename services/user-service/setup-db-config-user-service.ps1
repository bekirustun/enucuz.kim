Write-Host "🛠️ PostgreSQL bağlantı ayarları yapılıyor..." -ForegroundColor Cyan

# .env dosyasını oluştur
$envFile = ".env"
$envContent = @"
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_NAME=enucuzkim
"@
Set-Content -Path $envFile -Value $envContent -Encoding UTF8

# app.module.ts içeriğini güncelle
$appModulePath = "src/app.module.ts"
$appModuleContent = @"
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
Set-Content -Path $appModulePath -Value $appModuleContent -Encoding UTF8

Write-Host "✅ PostgreSQL bağlantı ayarları başarıyla yapıldı." -ForegroundColor Green