import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { UsersGatewayController } from './users.gateway.controller';
import { UsersGatewayService } from './users.gateway.service';

@Module({
  imports: [HttpModule],
  controllers: [UsersGatewayController],
  providers: [UsersGatewayService],
})
export class UsersGatewayModule {}
