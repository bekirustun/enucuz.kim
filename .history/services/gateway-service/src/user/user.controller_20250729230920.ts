import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Put,
  Delete,
} from '@nestjs/common';
import { UserProxyService } from './user.proxy';

@Controller('users')
export class UserController {
  constructor(private readonly userProxyService: UserProxyService) {}

  @Get()
  async findAll() {
    return this.userProxyService.findAll();
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.userProxyService.findOne(id);
  }

  @Post()
  async create(@Body() data: any) {
    return this.userProxyService.create(data);
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() data: any) {
    return this.userProxyService.update(id, data);
  }

  @Delete(':id')
  async remove(@Param('id') id: string) {
    return this.userProxyService.remove(id);
  }
}
