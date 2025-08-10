import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from './user.entity';
import { UserController } from './user.controller';
import { UserService } from './user.service';
import { UserProxyService } from './user.proxy';

@Module({
  imports: [HttpModule, TypeOrmModule.forFeature([User])],
  controllers: [UserController],
  providers: [UserService, UserProxyService],
  exports: [UserService, UserProxyService],
})
export class UserModule {}
