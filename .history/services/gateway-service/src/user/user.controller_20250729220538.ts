import { Controller, Get, Post, Body, Param, Put, Delete } from '@nestjs/common';
import { UserProxyService } from './user.proxy';

@Controller('users')
export class UserController {
  constructor(private readonly userProxy: UserProxyService) {}

  @Get()
  findAll() {
    return this.userProxy.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.userProxy.findOne(id);
  }

  @Post()
  create(@Body() data: any) {
    return this.userProxy.create(data);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() data: any) {
    return this.userProxy.update(id, data);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.userProxy.remove(id);
  }
}
