import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { lastValueFrom } from 'rxjs';

@Injectable()
export class UserProxyService {
  private readonly baseUrl = 'http://localhost:3001/users';

  constructor(private readonly httpService: HttpService) {}

  async findAll() {
    const response = await lastValueFrom(
      this.httpService.get(`${this.baseUrl}`)
    );
    return response.data;
  }

  async findOne(id: string) {
    const response = await lastValueFrom(
      this.httpService.get(`${this.baseUrl}/${id}`)
    );
    return response.data;
  }

  async create(data: any) {
    const response = await lastValueFrom(
      this.httpService.post(this.baseUrl, data)
    );
    return response.data;
  }

  async update(id: string, data: any) {
    const response = await lastValueFrom(
      this.httpService.put(`${this.baseUrl}/${id}`, data)
    );
    return response.data;
  }

  async remove(id: string) {
    const response = await lastValueFrom(
      this.httpService.delete(`${this.baseUrl}/${id}`)
    );
    return response.data;
  }
}
