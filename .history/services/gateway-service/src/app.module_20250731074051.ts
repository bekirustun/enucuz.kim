import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UserController } from './user/user.controller';
import { UserProxyService } from './user/user.proxy';

@Module({
  imports: [],
  controllers: [AppController, UserController],
  providers: [AppService, UserProxyService],
})
export class AppModule {}
