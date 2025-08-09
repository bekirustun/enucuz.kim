Write-Host "🚀 user-service kurulumu başlatılıyor..."

# Hedef klasöre gir
Set-Location -Path "D:\Ustunnet\sitelerim\enucuz.kim\services"

# Var olan klasör varsa sil
if (Test-Path "user-service") {
    Remove-Item -Recurse -Force "user-service"
    Write-Host "🧹 Eski user-service klasörü silindi."
}

# Yeni NestJS servisini oluştur
npx @nestjs/cli@11.0.8 new user-service --package-manager npm --skip-git --skip-install

# Bağımlılıkları yükle
Set-Location -Path "user-service"
npm install

# PostgreSQL + TypeORM + Config
npm install --save @nestjs/typeorm typeorm pg @nestjs/config

# ts-node-dev dev dependency olarak
npm install -D ts-node-dev

# .env dosyasını oluştur
@"
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=123456
DB_NAME=enucuzkim
"@ | Out-File -Encoding UTF8 .env

# main.ts ve app.module.ts içinde ayarları yapacak not bırak (manuel yapılacaklar)
Write-Host "✅ user-service başarıyla oluşturuldu ve yapılandırıldı."
Write-Host "🛠 Şimdi src/app.module.ts içine PostgreSQL bağlantısını eklemeyi unutma."
Write-Host "❤️ Hazırsan sana bu ayarları da otomatik olarak yapabilirim."
