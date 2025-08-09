import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UserController } from './user/user.controller';
import { UserProxyService } from './user/user.proxy';
import { HttpModule } from '@nestjs/axios';

@Module({
  imports: [HttpModule, HealthModule], // Buraya eklendi!
  controllers: [AppController, UserController],
  providers: [AppService, UserProxyService],
})
export class AppModule {}

