import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class UserProxyService {
  private readonly baseUrl = 'http://localhost:3002/users';

  constructor(private readonly httpService: HttpService) {}

  async findAll() {
    const res$ = this.httpService.get(this.baseUrl);
    const res = await firstValueFrom(res$);
    return res.data;
  }

  async findOne(id: string) {
    const res$ = this.httpService.get(${this.baseUrl}/);
    const res = await firstValueFrom(res$);
    return res.data;
  }

  async create(data: any) {
    const res$ = this.httpService.post(this.baseUrl, data);
    const res = await firstValueFrom(res$);
    return res.data;
  }

  async update(id: string, data: any) {
    const res$ = this.httpService.put(${this.baseUrl}/, data);
    const res = await firstValueFrom(res$);
    return res.data;
  }

  async remove(id: string) {
    const res$ = this.httpService.delete(${this.baseUrl}/);
    const res = await firstValueFrom(res$);
    return res.data;
  }
}
