// ...existing code...
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
      autoLoadEntities: true,
      synchronize: process.env.NODE_ENV !== 'production',
    }),
    UserModule,
  ],
  controllers: [AppController], // Sadece bir kez tanımlanmalı
  providers: [AppService],      // Sadece bir kez tanımlanmalı
})
export class AppModule {}
// ...existing code...