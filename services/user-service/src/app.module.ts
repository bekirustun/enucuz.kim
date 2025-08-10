import { Module } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import { TypeOrmModule } from "@nestjs/typeorm";
import { UserModule } from "./user/user.module";
import { User } from "./user/user.entity";

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRoot({
      type: "postgres",
      host: process.env.DB_HOST || "localhost",
      port: +(process.env.DB_PORT || 5432),
      database: process.env.DB_NAME || "enucuzkim",
      username: process.env.DB_USER || "postgres",
      password: process.env.DB_PASS || "postgres",
      entities: [User],
      synchronize: true, // DEV için; PROD’da migration kullan
      // logging: true,
    }),
    UserModule,
  ],
})
export class AppModule {}
