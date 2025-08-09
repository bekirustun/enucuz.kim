import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { lastValueFrom } from 'rxjs';
import { AxiosResponse } from 'axios';

@Injectable()
export class UserProxyService {
  private readonly baseUrl = 'http://localhost:3003/users'; // user-service veya başka mikroservisin adresi

  constructor(private readonly httpService: HttpService) {}

  async findAll(): Promise<any> {
    try {
      const response: AxiosResponse<any> = await lastValueFrom(
        this.httpService.get(this.baseUrl)
      );
      return response.data;
    } catch (err) {
      throw new HttpException('Kullanıcılar getirilemedi', HttpStatus.BAD_GATEWAY);
    }
  }

  async findOne(id: number): Promise<any> {
    try {
      const response: AxiosResponse<any> = await lastValueFrom(
        this.httpService.get(`${this.baseUrl}/${id}`)
      );
      return response.data;
    } catch (err) {
      throw new HttpException('Kullanıcı bulunamadı', HttpStatus.NOT_FOUND);
    }
  }

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
        this.httpSe
