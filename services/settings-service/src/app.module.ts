import { Module, OnModuleInit } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { FeatureFlag } from "./feature-flag.entity";
import { FeatureFlagsModule } from "./feature-flags.module";
import { ManifestLoader } from "./manifest.loader";
import { HealthController } from "./health.controller";

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: "postgres",
      host: process.env.PG_HOST,
      port: Number(process.env.PG_PORT || 5432),
      username: process.env.PG_USER,
      password: process.env.PG_PASS,
      database: process.env.PG_DB,
      synchronize: true, // dev için
      entities: [FeatureFlag],
    }),
    FeatureFlagsModule,
  ],
  controllers: [HealthController],
  providers: [ManifestLoader],
})
export class AppModule implements OnModuleInit {
  constructor(private readonly loader: ManifestLoader) {}
  async onModuleInit() {
    await this.loader.loadAndSync();
  }
}
