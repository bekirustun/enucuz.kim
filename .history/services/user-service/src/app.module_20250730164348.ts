import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserModule } from './user/user.module';

@Module({
  imports: [
    // .env dosyasını otomatik yükler ve tüm app'te kullanılabilir yapar
    ConfigModule.forRoot({ isGlobal: true }),

    // TypeORM ayarları: Tüm entity'ler otomatik bulunur, ENV odaklı.
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST,
      port: Number(process.env.DB_PORT),
      username: process.env.DB_USERNAME,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      autoLoadEntities: true, // Yeni entity ekleyince otomatik tanır (AI-ready)
      synchronize: process.env.NODE_ENV !== 'production', // Prod'da false olur
      // logging: true, // Geliştirmede açabilirsin
    }),

    // User mikroservis modülü
    UserModule,
  ],
})
export class AppModule {}
