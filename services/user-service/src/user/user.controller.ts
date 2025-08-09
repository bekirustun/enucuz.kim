import { 
  Controller, Get, Post, Body, Param, Delete, Put, HttpException, HttpStatus 
} from '@nestjs/common';
import { UserService } from './user.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

// (İsteğe bağlı) Swagger için importlar
// import { ApiTags, ApiOperation } from '@nestjs/swagger';

@Controller('users')
// @ApiTags('users') // Swagger için açabilirsin
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Post()
  // @ApiOperation({ summary: 'Yeni kullanıcı oluşturur' })
  async create(@Body() createUserDto: CreateUserDto) {
    try {
      return await this.userService.create(createUserDto);
    } catch (err) {
      throw new HttpException(err.message, HttpStatus.BAD_REQUEST);
    }
  }

  @Get()
  // @ApiOperation({ summary: 'Tüm kullanıcıları listeler' })
  async findAll() {
    try {
      return await this.userService.findAll();
    } catch (err) {
      throw new HttpException(err.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  @Get(':id')
  // @ApiOperation({ summary: 'Belirli kullanıcıyı bulur' })
  async findOne(@Param('id') id: string) {
    try {
      return await this.userService.findOne(+id);
    } catch (err) {
      throw new HttpException('Kullanıcı bulunamadı', HttpStatus.NOT_FOUND);
    }
  }

  @Put(':id')
  // @ApiOperation({ summary: 'Kullanıcıyı günceller' })
  async update(
    @Param('id') id: string, 
    @Body() updateUserDto: UpdateUserDto
  ) {
    try {
      return await this.userService.update(+id, updateUserDto);
    } catch (err) {
      throw new HttpException(err.message, HttpStatus.BAD_REQUEST);
    }
  }

  @Delete(':id')
  // @ApiOperation({ summary: 'Kullanıcıyı siler' })
  async remove(@Param('id') id: string) {
    try {
      return await this.userService.remove(+id);
    } catch (err) {
      throw new HttpException('Kullanıcı silinemedi', HttpStatus.BAD_REQUEST);
    }
  }

  // ---- AI destekli örnek endpoint (isteğe bağlı) ----
  @Post('generate-description')
  async generateDescription(@Body('name') name: string) {
    // AI servisiyle entegrasyon burada yapılır
    // Şu anlık mock
    return { description: `AI ile oluşturuldu: ${name} için otomatik açıklama.` };
  }
}
