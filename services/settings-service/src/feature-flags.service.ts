import { Injectable } from "@nestjs/common";
import { InjectDataSource } from "@nestjs/typeorm";
import { DataSource } from "typeorm";
import { FeatureFlag } from "./feature-flag.entity";
import { FeatureFlagDto } from "./feature-flag.dto";

@Injectable()
export class FeatureFlagsService {
  constructor(@InjectDataSource() private readonly ds: DataSource) {}

  async listTree() {
    const repo = this.ds.getRepository(FeatureFlag);
    const rows = await repo.find({ order: { key: "ASC" } });
    const byKey = new Map(rows.map(r => [r.key, { ...r, subFeatures: [] as any[] }]));
    const roots: any[] = [];
    for (const r of byKey.values()) {
      if (r.parentKey) byKey.get(r.parentKey)?.subFeatures.push(r);
      else roots.push(r);
    }
    return roots;
  }

  async upsertMany(items: FeatureFlagDto[]) {
    const repo = this.ds.getRepository(FeatureFlag);
    for (const f of items) {
      const existing = await repo.findOne({ where: { key: f.key } });
      if (existing) await repo.update({ id: existing.id }, { ...existing, ...f });
      else await repo.insert(repo.create({ ...f }));
    }
    return { ok: true, count: items.length };
  }
}
