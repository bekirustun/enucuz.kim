import { Controller, Get, Post, Body } from "@nestjs/common";
import { SettingsService } from "./settings.service";

@Controller("api/admin/settings")
export class SettingsController {
  constructor(private readonly svc: SettingsService) {}

  @Get("health")
  health() { return this.svc.health(); }

  @Get("features")
  list() { return this.svc.features(); }

  @Post("features")
  save(@Body() body: { features: any[] }) { return this.svc.saveFeatures(body); }
}
