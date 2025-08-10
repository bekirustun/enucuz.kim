import { Type } from 'class-transformer';
import { IsIn, IsInt, IsOptional, IsString, Min } from 'class-validator';

export class ListUsersDto {
  @Type(() => Number)
  @IsInt() @Min(1)
  @IsOptional()
  page?: number = 1;

  @Type(() => Number)
  @IsInt() @Min(1)
  @IsOptional()
  pageSize?: number = 10;

  @IsOptional() @IsIn(['id','name','email','role','createdAt','updatedAt'])
  sortBy?: 'id'|'name'|'email'|'role'|'createdAt'|'updatedAt' = 'createdAt';

  @IsOptional() @IsIn(['asc','desc'])
  order?: 'asc'|'desc' = 'desc';

  @IsOptional() @IsString()
  q?: string;

  @IsOptional() @IsString()
  role?: string;
}
