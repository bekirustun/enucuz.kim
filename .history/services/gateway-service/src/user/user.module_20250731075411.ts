import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { UserController } from './user.controller';
import { UserProxyService } from './user.proxy';
import { HttpModule } from '@nestjs/axios';


@Module({
  imports: [HttpModule],
  controllers: [UserController],
  providers: [UserProxyService],
})
export class UserModule {}
