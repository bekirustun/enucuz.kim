import { Module } from '@nestjs/common';
import { UsersGatewayModule } from './users/users.gateway.module';

@Module({
  imports: [ SettingsModule, UsersGatewayModule],
})
export class AppModule {}


