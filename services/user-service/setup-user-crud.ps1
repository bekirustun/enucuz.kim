Write-Host "🚀 user CRUD kurulumu başlatılıyor..."

# Klasörleri oluştur
$basePath = "src/user"
New-Item -ItemType Directory -Force -Path "$basePath/dto" | Out-Null

# Entity
@"
import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity()
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @Column({ unique: true })
  email: string;

  @Column()
  password: string;
}
"@ | Set-Content -Encoding UTF8 "$basePath/user.entity.ts"

# DTO - create
@"
export class CreateUserDto {
  name: string;
  email: string;
  password: string;
}
"@ | Set-Content -Encoding UTF8 "$basePath/dto/create-user.dto.ts"

# DTO - update
@"
import { PartialType } from '@nestjs/mapped-types';
import { CreateUserDto } from './create-user.dto';

export class UpdateUserDto extends PartialType(CreateUserDto) {}
"@ | Set-Content -Encoding UTF8 "$basePath/dto/update-user.dto.ts"

# Service
@"
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './user.entity';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  create(createUserDto: CreateUserDto) {
    const user = this.userRepository.create(createUserDto);
    return this.userRepository.save(user);
  }

  findAll() {
    return this.userRepository.find();
  }

  findOne(id: number) {
    return this.userRepository.findOneBy({ id });
  }

  update(id: number, updateUserDto: UpdateUserDto) {
    return this.userRepository.update(id, updateUserDto);
  }

  remove(id: number) {
    return this.userRepository.delete(id);
  }
}
"@ | Set-Content -Encoding UTF8 "$basePath/user.service.ts"

# Controller
@"
import { Controller, Get, Post, Body, Param, Delete, Put } from '@nestjs/common';
import { UserService } from './user.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Controller('users')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Post()
  create(@Body() createUserDto: CreateUserDto) {
    return this.userService.create(createUserDto);
  }

  @Get()
  findAll() {
    return this.userService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.userService.findOne(+id);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() updateUserDto: UpdateUserDto) {
    return this.userService.update(+id, updateUserDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.userService.remove(+id);
  }
}
"@ | Set-Content -Encoding UTF8 "$basePath/user.controller.ts"

# Module dosyasını oluştur
@"
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from './user.entity';
import { UserService } from './user.service';
import { UserController } from './user.controller';

@Module({
  imports: [TypeOrmModule.forFeature([User])],
  controllers: [UserController],
  providers: [UserService],
})
export class UserModule {}
"@ | Set-Content -Encoding UTF8 "$basePath/user.module.ts"

Write-Host "✅ user CRUD yapısı başarıyla oluşturuldu."
Write-Host "⚠️  app.module.ts dosyasına şu satırı eklemeyi unutma:"
Write-Host "`n    import { UserModule } from './user/user.module';"
Write-Host "    imports: [..., UserModule]"

