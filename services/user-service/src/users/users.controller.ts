import { Controller, Get, Param, Post, Body, Put, Delete } from "@nestjs/common";
import { UsersService } from "./users.service";

@Controller("users")
export class UsersController {
  constructor(private readonly users: UsersService) {}

  @Get()
  list() { return this.users.list(); }

  @Get(":id")
  get(@Param("id") id: string) { return this.users.get(id); }

  @Post()
  create(@Body() dto: any) { return this.users.create(dto); }

  @Put(":id")
  update(@Param("id") id: string, @Body() dto: any) { return this.users.update(id, dto); }

  @Delete(":id")
  remove(@Param("id") id: string) { return this.users.remove(id); }
}
