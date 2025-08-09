# setup-user-service.ps1
$ErrorActionPreference = "Stop"

$Root = "D:\U\S\enucuz.kim"
$Svc  = Join-Path $Root "services\user-service"
$Src  = Join-Path $Svc "src"

Write-Host "==> user-service iskeleti olusturuluyor..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path "$Src\users" | Out-Null

# package.json
@'
{
  "name": "user-service",
  "version": "1.0.0",
  "description": "User microservice for enucuz.kim",
  "private": true,
  "main": "dist/main.js",
  "scripts": {
    "start": "nest start",
    "start:dev": "nest start --watch",
    "dev": "pnpm start:dev",
    "build": "tsc -p tsconfig.build.json"
  },
  "dependencies": {
    "@nestjs/common": "^11.1.5",
    "@nestjs/core": "^11.1.5",
    "@nestjs/platform-express": "^11.1.5",
    "@nestjs/config": "^4.0.2",
    "reflect-metadata": "^0.2.2",
    "rxjs": "^7.8.2"
  },
  "devDependencies": {
    "@nestjs/cli": "^11.0.10",
    "@nestjs/schematics": "^11.0.7",
    "ts-node": "^10.9.2",
    "typescript": "^5.9.2"
  }
}
'@ | Set-Content -Encoding UTF8 -Path "$Svc\package.json"

# tsconfig.json
@'
{
  "compilerOptions": {
    "module": "commonjs",
    "target": "ES2022",
    "moduleResolution": "node",
    "outDir": "dist",
    "rootDir": "src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  },
  "include": ["src"]
}
'@ | Set-Content -Encoding UTF8 -Path "$Svc\tsconfig.json"

# tsconfig.build.json
@'
{
  "extends": "./tsconfig.json",
  "compilerOptions": { "declaration": true, "sourceMap": true }
}
'@ | Set-Content -Encoding UTF8 -Path "$Svc\tsconfig.build.json"

# nest-cli.json
@'
{
  "collection": "@nestjs/schematics",
  "sourceRoot": "src"
}
'@ | Set-Content -Encoding UTF8 -Path "$Svc\nest-cli.json"

# .env.example
@'
PORT=3010
'@ | Set-Content -Encoding UTF8 -Path "$Svc\.env.example"

# src/main.ts
@'
import "reflect-metadata";
import { NestFactory } from "@nestjs/core";
import { AppModule } from "./app.module";

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const port = Number(process.env.PORT) || 3010;
  await app.listen(port);
}
bootstrap();
'@ | Set-Content -Encoding UTF8 -Path "$Src\main.ts"

# src/app.module.ts
@'
import { Module } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import { UsersModule } from "./users/users.module";

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    UsersModule
  ]
})
export class AppModule {}
'@ | Set-Content -Encoding UTF8 -Path "$Src\app.module.ts"

# src/users/users.controller.ts
@'
import { Controller, Get, Param, Post, Body, Put, Delete } from "@nestjs/common";
import { UsersService } from "./users.service";

@Controller("users")
export class UsersController {
  constructor(private readonly users: UsersService) {}

  @Get()
  list() { return this.users.list(); }

  @Get(":id")
  get(@Param("id") id: string) { return this.users.get(id); }

  @Post()
  create(@Body() dto: any) { return this.users.create(dto); }

  @Put(":id")
  update(@Param("id") id: string, @Body() dto: any) { return this.users.update(id, dto); }

  @Delete(":id")
  remove(@Param("id") id: string) { return this.users.remove(id); }
}
'@ | Set-Content -Encoding UTF8 -Path "$Src\users\users.controller.ts"

# src/users/users.service.ts
@'
import { Injectable } from "@nestjs/common";
type User = { id: number; name: string; email?: string };

@Injectable()
export class UsersService {
  private data: User[] = [
    { id: 1, name: "Ali", email: "ali@example.com" },
    { id: 2, name: "Veli", email: "veli@example.com" }
  ];

  list() { return this.data; }
  get(id: string) { return this.data.find(u => u.id === Number(id)) ?? null; }
  create(dto: Partial<User>) {
    const id = (this.data.at(-1)?.id ?? 0) + 1;
    const item = { id, name: dto.name ?? `User ${id}`, email: dto.email };
    this.data.push(item); return item;
  }
  update(id: string, dto: Partial<User>) {
    const idx = this.data.findIndex(u => u.id === Number(id));
    if (idx === -1) return null;
    this.data[idx] = { ...this.data[idx], ...dto, id: Number(id) };
    return this.data[idx];
  }
  remove(id: string) {
    const idx = this.data.findIndex(u => u.id === Number(id));
    if (idx === -1) return { deleted: 0 };
    this.data.splice(idx, 1);
    return { deleted: 1 };
  }
}
'@ | Set-Content -Encoding UTF8 -Path "$Src\users\users.service.ts"

# src/users/users.module.ts
@'
import { Module } from "@nestjs/common";
import { UsersController } from "./users.controller";
import { UsersService } from "./users.service";

@Module({
  controllers: [UsersController],
  providers: [UsersService]
})
export class UsersModule {}
'@ | Set-Content -Encoding UTF8 -Path "$Src\users\users.module.ts"

# test.http
@'
### list
GET http://localhost:3010/users
'@ | Set-Content -Encoding UTF8 -Path "$Svc\test.http"

# Git commit
Set-Location "$Root"
git add "services/user-service"
git commit -m "feat(user-service): initial NestJS service (port 3010)" | Out-Null

Write-Host "==> user-service olusturuldu ve commit'lendi." -ForegroundColor Green
