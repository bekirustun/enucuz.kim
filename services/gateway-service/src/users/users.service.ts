import { Injectable, InternalServerErrorException } from '@nestjs/common';
import axios, { AxiosInstance } from 'axios';

@Injectable()
export class UsersGatewayService {
  private base: string;
  private prefix: string;
  private http: AxiosInstance;

  constructor() {
    this.base = process.env.USER_SERVICE_URL || 'http://localhost:3002';
    this.prefix = process.env.GLOBAL_PREFIX || 'api';
    this.http = axios.create({ timeout: 5000 });
    // eslint-disable-next-line no-console
    console.log('[gateway] USER_SERVICE_URL=', this.base);
  }

  async health() {
    try {
      const { data } = await this.http.get(`${this.base}/${this.prefix}/users/health`);
      return data;
    } catch (err: any) {
      const msg = err?.response?.data ?? err?.message ?? 'unknown';
      throw new InternalServerErrorException({
        upstream: `${this.base}/${this.prefix}/users/health`,
        error: msg,
      });
    }
  }

  async list() {
    try {
      const { data } = await this.http.get(`${this.base}/${this.prefix}/users`);
      return data;
    } catch (err: any) {
      const msg = err?.response?.data ?? err?.message ?? 'unknown';
      throw new InternalServerErrorException({
        upstream: `${this.base}/${this.prefix}/users`,
        error: msg,
      });
    }
  }
}

