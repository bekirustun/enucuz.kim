import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserController } from './user.controller';
import { UserService } from './user.service';
import { UserProxyService } from './user.proxy';
import { User } from './entities/user.entity'; // Veya './user.entity' senin yapına göre

@Module({
  imports: [
    HttpModule,                     // <-- HttpService için gerekli!
    TypeOrmModule.forFeature([User]) // <-- Entity'i TypeORM'a tanıt
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
