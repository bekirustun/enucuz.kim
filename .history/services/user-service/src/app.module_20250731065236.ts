import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserModule } from './user/user.module';

import { AppController } from './app.controller';
import { UserController } from './user/user.controller';
import { AppService } from './app.service';
import { UserProxyService } from './user/user.proxy';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRoot({
      // ...TypeORM config burada olacak...
    }),
    UserModule,
  ],
  controllers: [AppController, UserController],
  providers: [AppService, UserProxyService],
})
export class AppModule {}
