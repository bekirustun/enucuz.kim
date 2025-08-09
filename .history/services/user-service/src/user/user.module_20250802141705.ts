import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { UserProxyService } from './user.proxy';
// Eğer başka servis veya controller varsa buraya ekle:
// import { UserService } from './user.service';
// import { UserController } from './user.controller';

@Module({
  imports: [
    HttpModule, // <--- ÖNEMLİ! HttpService kullanmak için
    // ... varsa başka modüller
  ],
  providers: [
    UserProxyService,
    // UserService, (varsa ekle)
  ],
  // controllers: [UserController], // (varsa ekle)
  exports: [
    UserProxyService,
    // UserService, (varsa ekle)
  ],
})
export class UserModule {}
