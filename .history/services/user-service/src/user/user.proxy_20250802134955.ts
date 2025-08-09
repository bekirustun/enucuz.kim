import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { lastValueFrom } from 'rxjs';
import { AxiosResponse } from 'axios';

@Injectable()
export class UserProxyService {
  private readonly baseUrl = 'http://localhost:3001/users';

  constructor(private readonly httpService: HttpService) {}

  async create(createUserDto: any): Promise<any> {
    try {
      const response: AxiosResponse<any> = await lastValueFrom(
        this.httpService.post(this.baseUrl, createUserDto)
      );
      return response.data;
    } catch (err) {
      throw new HttpException('Kullanıcı oluşturulamadı', HttpStatus.BAD_REQUEST);
    }
  }

  async update(id: number, updateUserDto: any): Promise<any> {
    try {
      const response: AxiosResponse<any> = await lastValueFrom(
        this.httpService.put(`${this.baseUrl}/${id}`, updateUserDto)
      );
      return response.data;
    } catch (err) {
      throw new HttpException('Kullanıcı güncellenemedi', HttpStatus.BAD_REQUEST);
    }
  }

  // Diğer CRUD fonksiyonlarını da aynı şekilde tamamlayabilirsin...
}
