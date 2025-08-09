import { Body, Controller, Delete, Get, Param, ParseIntPipe, Patch, Post } from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Controller('api/users')
export class UsersController {
  constructor(private readonly users: UsersService) {}

  @Get('health')
  health() { return this.users.health(); }

  @Get()
  list() { return this.users.findAll(); }

  @Get(':id')
  get(@Param('id', ParseIntPipe) id: number) { return this.users.findOne(id); }

  @Post()
  create(@Body() dto: CreateUserDto) { return this.users.create(dto); }

  @Patch(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateUserDto) { return this.users.update(id, dto); }

  @Delete(':id')
  delete(@Param('id', ParseIntPipe) id: number) { return this.users.remove(id); }
}
