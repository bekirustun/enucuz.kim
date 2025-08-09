import { PartialType } from '@nestjs/mapped-types';
import { CreateUserDto } from './create-user.dto';

/**
 * UpdateUserDto
 * - CreateUserDto’nun tüm alanlarını otomatik olarak opsiyonel hale getirir.
 * - Geliştirilmeye ve yeni alanlar eklemeye açıktır.
 */
export class UpdateUserDto extends PartialType(CreateUserDto) {
  // Ekstra alan eklemek istersen buraya yazabilirsin.
  // Örneğin:
  // @IsOptional()
  // @IsString()
  // profilePhotoUrl?: string;
}
