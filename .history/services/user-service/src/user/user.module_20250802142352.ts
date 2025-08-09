import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { TypeOrmModule } from '@nestjs/typeorm';

import { UserController } from './user.controller';
import { UserService } from './user.service';
import { UserProxyService } from './user.proxy';
import { User } from './user.entity'; // ← Doğru yol!

@Module({
  imports: [
    HttpModule,                      // HttpService için GEREKLİ!
    TypeOrmModule.forFeature([User]) // User entity DB işlemleri için
  ],
  controllers: [
    UserController
  ],
  providers: [
    UserService,
    UserProxyService
  ],
  exports: [
    UserService,
    UserProxyService
  ],
})
export class UserModule {}
