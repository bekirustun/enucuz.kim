import { Injectable, NotFoundException } from '@nestjs/common';
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

  async create(createUserDto: CreateUserDto) {
    const user = this.userRepository.create(createUserDto);
    return await this.userRepository.save(user);
  }

  async findAll() {
    return await this.userRepository.find();
  }

  async findOne(id: number) {
    const user = await this.userRepository.findOneBy({ id });
    if (!user) {
      throw new NotFoundException(`Kullanıcı bulunamadı (id: ${id})`);
    }
    return user;
  }

  async update(id: number, updateUserDto: UpdateUserDto) {
    const result = await this.userRepository.update(id, updateUserDto);
    if (result.affected === 0) {
      throw new NotFoundException(`Kullanıcı güncellenemedi (id: ${id})`);
    }
    return this.findOne(id);
  }

  async remove(id: number) {
    const result = await this.userRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`Kullanıcı silinemedi (id: ${id})`);
    }
    return { deleted: true };
  }

  // ---- AI destekli örnek (opsiyonel, ileride kullanılabilir) ----
  // async generateUserDescription(name: string): Promise<string> {
  //   // AI ile açıklama üretmek için burada entegrasyon yapılır
  //   return `AI tarafından oluşturuldu: ${name} kullanıcısı için örnek açıklama.`;
  // }
}
