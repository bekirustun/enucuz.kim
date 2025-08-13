import "reflect-metadata";
import * as dotenv from "dotenv";
dotenv.config();
import { NestFactory } from "@nestjs/core";
import { AppModule } from "./app.module";

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.setGlobalPrefix("api/admin/settings");
  const port = process.env.PORT ? Number(process.env.PORT) : 3006;
  await app.listen(port);
  console.log(`[settings-service] listening on http://localhost:${port}`);
}
bootstrap();
