import 'dotenv/config';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { cors: true });
  const prefix = process.env.GLOBAL_PREFIX || 'api';
  app.setGlobalPrefix(prefix);
  const port = parseInt(process.env.PORT || '3005', 10);
  await app.listen(port);
  // eslint-disable-next-line no-console
  console.log(`[gateway] running on http://localhost:${port}/${prefix}`);
}
bootstrap();

