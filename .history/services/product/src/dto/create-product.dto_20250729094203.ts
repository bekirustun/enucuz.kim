import { IsString, IsNotEmpty, IsUrl, IsNumber } from 'class-validator';

export class CreateProductDto {
  @IsString()
  @IsNotEmpty()
  name!: string;

  @IsNumber()
  categoryId!: number;

  @IsUrl()
  productUrl!: string;
}
