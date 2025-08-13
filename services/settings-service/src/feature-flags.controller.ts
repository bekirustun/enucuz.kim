import { Body, Controller, Get, Post } from "@nestjs/common";
import { FeatureFlagsService } from "./feature-flags.service";
import { FeatureFlagDto } from "./feature-flag.dto";

@Controller("features")
export class FeatureFlagsController {
  constructor(private readonly svc: FeatureFlagsService) {}
  @Get() async getTree() { return this.svc.listTree(); }
  @Post() async save(@Body() body: { features: FeatureFlagDto[] }) {
    return this.svc.upsertMany(body.features || []);
  }
}
