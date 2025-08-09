import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class UsersGatewayService {
  constructor(private readonly http: HttpService) {}
  private get baseUrl(){ return process.env.USER_SERVICE_URL || 'http://localhost:3010'; }

  health(){ return firstValueFrom(this.http.get(`${this.baseUrl}/api/users/health`)).then(r=>r.data); }
  list(){   return firstValueFrom(this.http.get(`${this.baseUrl}/api/users`)).then(r=>r.data); }
  get(id:number){ return firstValueFrom(this.http.get(`${this.baseUrl}/api/users/${id}`)).then(r=>r.data); }
  create(body:any){ return firstValueFrom(this.http.post(`${this.baseUrl}/api/users`, body)).then(r=>r.data); }
  update(id:number, body:any){ return firstValueFrom(this.http.patch(`${this.baseUrl}/api/users/${id}`, body)).then(r=>r.data); }
  remove(id:number){ return firstValueFrom(this.http.delete(`${this.baseUrl}/api/users/${id}`)).then(r=>r.data); }
}
