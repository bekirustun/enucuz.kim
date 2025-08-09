import { Injectable, HttpService } from '@nestjs/common';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class UserProxyService {
  private baseUrl = 'http://localhost:3002/users';

  constructor(private readonly httpService: HttpService) {}

  async findAll() {
    const res$ = this.httpService.get(`${this.baseUrl}`);
    const response = await firstValueFrom(res$);
    return response.data;
  }

  async findOne(id: string) {
    const res$ = this.httpService.get(`${this.baseUrl}/${id}`);
    const response = await firstValueFrom(res$);
    return response.data;
  }

  async create(data: any) {
    const res$ = this.httpService.post(`${this.baseUrl}`, data);
    const response = await firstValueFrom(res$);
    return response.data;
  }

  async update(id: string, data: any) {
    const res$ = this.httpService.put(`${this.baseUrl}/${id}`, data);
    const response = await firstValueFrom(res$);
    return response.data;
  }

  async remove(id: string) {
    const res$ = this.httpService.delete(`${this.baseUrl}/${id}`);
    const response = await firstValueFrom(res$);
    return response.data;
  }
}
