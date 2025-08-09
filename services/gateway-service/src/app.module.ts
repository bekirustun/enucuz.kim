import { Module } from '@nestjs/common';
import { UsersGatewayModule } from './users/users.gateway.module';

@Module({
  imports: [UsersGatewayModule],
})
export class AppModule {}

