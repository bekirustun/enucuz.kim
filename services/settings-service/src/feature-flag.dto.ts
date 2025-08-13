import { IsBoolean, IsOptional, IsString, MaxLength } from "class-validator";
export class FeatureFlagDto {
  @IsString() @MaxLength(160) key!: string;
  @IsString() @MaxLength(160) name!: string;
  @IsBoolean() enabled!: boolean;
  @IsOptional() @IsString() @MaxLength(160) parentKey?: string | null;
  @IsOptional() meta?: Record<string, any>;
}
