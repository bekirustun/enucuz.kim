import { Injectable } from "@nestjs/common";
import { HttpService } from "@nestjs/axios";
import { firstValueFrom } from "rxjs";

@Injectable()
export class SettingsService {
  constructor(private readonly http: HttpService) {}

  private get base() {
    return process.env.SETTINGS_SERVICE_URL || "http://localhost:3006";
  }

  async health() {
    const { data } = await firstValueFrom(this.http.get(`${this.base}/api/admin/settings/health`));
    return data;
  }

  async features() {
    const { data } = await firstValueFrom(this.http.get(`${this.base}/api/admin/settings/features`));
    return data;
  }

  async saveFeatures(payload: { features: any[] }) {
    const { data } = await firstValueFrom(this.http.post(`${this.base}/api/admin/settings/features`, payload));
    return data;
  }
}
