import { Module } from '@nestjs/common';
import { UsersGatewayModule } from './users/users.module';

@Module({
  imports: [UsersGatewayModule],
})
export class AppModule {}
