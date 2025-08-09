import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { TypeOrmModule } from '@nestjs/typeorm';

import { UserController } from './user.controller';
import { UserService } from './user.service';
import { UserProxyService } from './user.proxy';
import { User } from './entities/user.entity'; // Entity yolunu kendi yapına göre düzelt

@Module({
  imports: [
    HttpModule,                      // <-- MUTLAKA burada olacak!
    TypeOrmModule.forFeature([User]) // <-- Entity ile DB işlemleri
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
