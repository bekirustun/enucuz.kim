import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';

import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UserController } from './user/user.controller';
import { UserProxyService } from './user/user.proxy';

// ✅ EKLENDİ
import { HealthModule } from './health/health.module';

@Module({
  imports: [HttpModule, HealthModule], // ✅ burada kalsın
  controllers: [AppController, UserController],
  providers: [AppService, UserProxyService],
})
export class AppModule {}
