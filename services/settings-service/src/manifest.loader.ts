import { Injectable } from "@nestjs/common";
import { glob } from "glob";
import { promises as fs } from "fs";
import path from "path";
import { FeatureFlagsService } from "./feature-flags.service";
import { FeatureFlagDto } from "./feature-flag.dto";

@Injectable()
export class ManifestLoader {
  constructor(private readonly svc: FeatureFlagsService) {}
  async loadAndSync() {
    const root = "D:/U/S/enucuz.kim";
    const pattern = path.join(root, "**/module.manifest.json").replace(/\\/g, "/");
    const files = await glob(pattern, { ignore: ["**/node_modules/**"] });
    const features: FeatureFlagDto[] = [];
    for (const file of files) {
      try {
        const json = JSON.parse(await fs.readFile(file, "utf8"));
        if (Array.isArray(json.features)) {
          for (const f of json.features) {
            if (f && f.key && f.name) {
              features.push({
                key: String(f.key),
                name: String(f.name),
                enabled: Boolean(f.enabled),
                parentKey: f.parentKey ?? null,
                meta: f.meta ?? undefined
              });
            }
          }
        }
      } catch (e) {
        console.error("[manifest] okunamadı:", file, e);
      }
    }
    if (features.length > 0) {
      await this.svc.upsertMany(features);
      console.log(`[manifest] ${features.length} özellik senkronize edildi.`);
    } else {
      console.log("[manifest] Manifest bulunamadı (ilk kurulum olabilir).");
    }
  }
}
