import { Body, Controller, Delete, Get, Param, ParseIntPipe, Patch, Post } from '@nestjs/common';
import { UsersGatewayService } from './users.gateway.service';

@Controller('users')
export class UsersGatewayController {
  constructor(private readonly svc: UsersGatewayService) {}

  @Get('health') health(){ return this.svc.health(); }
  @Get() list(){ return this.svc.list(); }
  @Get(':id') get(@Param('id', ParseIntPipe) id:number){ return this.svc.get(id); }

  @Post() create(@Body() body:any){ return this.svc.create(body); }
  @Patch(':id') update(@Param('id', ParseIntPipe) id:number, @Body() body:any){ return this.svc.update(id, body); }
  @Delete(':id') remove(@Param('id', ParseIntPipe) id:number){ return this.svc.remove(id); }
}

