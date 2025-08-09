import * as dotenv from 'dotenv';
dotenv.config();

import 'reflect-metadata';

import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
await app.listen(process.env.PORT || 3005);
}
bootstrap();
