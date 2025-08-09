import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { cors: true });
  const prefix = process.env.GLOBAL_PREFIX || 'api';
  app.setGlobalPrefix(prefix);
  const port = parseInt(process.env.PORT || '3002', 10);
  await app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidUnknownValues: false }));
  app.setGlobalPrefix('');
  app.listen(port);
  // eslint-disable-next-line no-console
  console.log(`[user-service] running on http://localhost:${port}/${prefix}`);
}
bootstrap();

