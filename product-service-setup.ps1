# product-service-setup.ps1
Write-Host "🚀 enucuz.kim - product-service kurulumu başlıyor..." -ForegroundColor Cyan

# Servis adı
$ServiceName = "product"
$BasePath = "services\$ServiceName"

# NestJS CLI yüklü değilse yükle
if (-not (Get-Command nest -ErrorAction SilentlyContinue)) {
    Write-Host "📦 NestJS CLI yükleniyor..." -ForegroundColor Yellow
    npm install -g @nestjs/cli
}

# Klasör oluşturulmuşsa atla
if (-not (Test-Path $BasePath)) {
    Write-Host "📁 Mikroservis klasörü oluşturuluyor: $BasePath" -ForegroundColor Cyan
    nest new $ServiceName -p npm --directory $BasePath --skip-git --skip-install
}

# Gerekli bağımlılıkları kur
Write-Host "📦 Bağımlılıklar yükleniyor..." -ForegroundColor Yellow
cd $BasePath
npm install @nestjs/typeorm typeorm pg class-validator class-transformer @nestjs/config @nestjs/swagger reflect-metadata ts-node-dev

# Geliştirici scriptleri
npm set-script start:dev "ts-node-dev --respawn src/main.ts"

# Klasörleri oluştur
New-Item -ItemType Directory -Force -Path "src/controllers"
New-Item -ItemType Directory -Force -Path "src/services"
New-Item -ItemType Directory -Force -Path "src/dto"
New-Item -ItemType Directory -Force -Path "src/entities"
New-Item -ItemType Directory -Force -Path "src/config"

# Örnek dosyaları oluştur
@"
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(new ValidationPipe({ whitelist: true }));
  await app.listen(3001);
}
bootstrap();
"@ | Out-File -Encoding utf8 src/main.ts

@"
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProductModule } from './services/product.module';

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
    ProductModule,
  ],
})
export class AppModule {}
"@ | Out-File -Encoding utf8 src/app.module.ts

@"
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProductService } from './product.service';
import { ProductController } from '../controllers/product.controller';
import { Product } from '../entities/product.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Product])],
  providers: [ProductService],
  controllers: [ProductController],
})
export class ProductModule {}
"@ | Out-File -Encoding utf8 src/services/product.module.ts

@"
import { Controller, Get, Post, Body } from '@nestjs/common';
import { ProductService } from '../services/product.service';
import { CreateProductDto } from '../dto/create-product.dto';

@Controller('products')
export class ProductController {
  constructor(private readonly productService: ProductService) {}

  @Get()
  getAll() {
    return this.productService.findAll();
  }

  @Post()
  create(@Body() createProductDto: CreateProductDto) {
    return this.productService.create(createProductDto);
  }
}
"@ | Out-File -Encoding utf8 src/controllers/product.controller.ts

@"
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Product } from '../entities/product.entity';
import { CreateProductDto } from '../dto/create-product.dto';

@Injectable()
export class ProductService {
  constructor(
    @InjectRepository(Product)
    private productRepository: Repository<Product>,
  ) {}

  findAll() {
    return this.productRepository.find();
  }

  create(data: CreateProductDto) {
    const product = this.productRepository.create(data);
    return this.productRepository.save(product);
  }
}
"@ | Out-File -Encoding utf8 src/services/product.service.ts

@"
import { IsString, IsNotEmpty, IsUrl, IsNumber } from 'class-validator';

export class CreateProductDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsNumber()
  categoryId: number;

  @IsUrl()
  productUrl: string;
}
"@ | Out-File -Encoding utf8 src/dto/create-product.dto.ts

@"
import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity()
export class Product {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @Column()
  categoryId: number;

  @Column()
  productUrl: string;
}
"@ | Out-File -Encoding utf8 src/entities/product.entity.ts

@"
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_NAME=product_db
"@ | Out-File -Encoding utf8 .env.example

@"
# Product Service
NestJS microservice for managing product data with PostgreSQL and TypeORM.
"@ | Out-File -Encoding utf8 README.md

Write-Host "✅ product-service başarıyla kuruldu. Başlatmak için:" -ForegroundColor Green
Write-Host "👉 cd services\\product" -ForegroundColor Yellow
Write-Host "👉 npm run start:dev" -ForegroundColor Yellow