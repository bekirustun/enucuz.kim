import { IsString, IsEmail, MinLength, MaxLength } from 'class-validator';

export class CreateUserDto {
  @IsString({ message: 'İsim alanı zorunlu ve metin olmalı.' })
  @MinLength(2, { message: 'İsim en az 2 karakter olmalı.' })
  @MaxLength(50, { message: 'İsim en fazla 50 karakter olabilir.' })
  name: string;

  @IsEmail({}, { message: 'Geçerli bir e-posta adresi giriniz.' })
  email: string;

  @IsString({ message: 'Şifre alanı zorunlu ve metin olmalı.' })
  @MinLength(6, { message: 'Şifre en az 6 karakter olmalı.' })
  @MaxLength(32, { message: 'Şifre en fazla 32 karakter olabilir.' })
  password: string;
}
