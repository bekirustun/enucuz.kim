import { Controller, Get } from '@nestjs/common';
import { UsersGatewayService } from './users.service';

@Controller('users')
export class UsersGatewayController {
  constructor(private readonly svc: UsersGatewayService) {}

  @Get('health')
  health() {
    return this.svc.health();
  }

  @Get()
  all() {
    return this.svc.list();
  }
}
