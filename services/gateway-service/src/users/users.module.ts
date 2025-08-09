import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { UsersGatewayService } from './users.service';
import { UsersGatewayController } from './users.controller';

@Module({
  imports: [HttpModule],
  providers: [UsersGatewayService],
  controllers: [UsersGatewayController],
})
export class UsersGatewayModule {}
