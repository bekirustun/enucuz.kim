import { Module } from "@nestjs/common";
import { HttpModule } from "@nestjs/axios";
import { SettingsService } from "./settings.service";
import { SettingsController } from "./settings.controller";

@Module({
  imports: [HttpModule],
  controllers: [SettingsController],
  providers: [SettingsService],
})
export class SettingsModule {}
