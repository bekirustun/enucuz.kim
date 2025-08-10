import { IsEmail, IsIn, IsOptional, IsString, MaxLength } from 'class-validator';
import { UserRole } from '../user.entity';

export class CreateUserDto {
  @IsString()
  @MaxLength(120)
  name!: string;

  @IsEmail()
  @MaxLength(160)
  email!: string;

  @IsOptional()
  @IsIn(['admin', 'editor', 'user'])
  role?: UserRole;
}
