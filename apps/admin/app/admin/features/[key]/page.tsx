"use client";

import { useEffect, useState } from "react";
import { useParams } from "next/navigation";
import { Card, Space, Typography, Switch, message } from "antd";

type Flag = {
  id: number;
  key: string;
  name: string;
  enabled: boolean;
  parentKey?: string | null;
  meta?: any | null;
};

export default function FeatureDetailPage() {
  const params = useParams() as { key: string };
  const keyParam = decodeURIComponent(params.key || "");
  const [flag, setFlag] = useState<Flag | null>(null);
  const [saving, setSaving] = useState(false);

  const load = async () => {
    try {
      const res = await fetch("/api/feature-flags", { cache: "no-store" });
      const data = await res.json();
      const list = (data?.[0]?.subFeatures ?? []) as Flag[];
      const f = list.find(x => x.key === keyParam) ?? null;
      setFlag(f);
    } catch {}
  };

  const toggle = async (checked: boolean) => {
    if (!flag) return;
    setSaving(true);
    const prev = flag.enabled;
    setFlag({ ...flag, enabled: checked });
    try {
      const r = await fetch("/api/feature-flags", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ key: flag.key, enabled: checked }),
      });
      const j = await r.json();
      if (!j?.ok) throw new Error("post-failed");
      message.success(`${flag.name} ${checked ? "açıldı" : "kapandı"}`);
    } catch {
      setFlag({ ...flag, enabled: prev });
      message.error("Değişiklik kaydedilemedi");
    } finally {
      setSaving(false);
    }
  };

  useEffect(() => { load(); }, [keyParam]);

  if (!flag) {
    return <Typography.Text>Özellik bulunamadı: {keyParam}</Typography.Text>;
  }

  return (
    <Card title={flag.name}>
      <Space direction="vertical" size="large" style={{ width: "100%" }}>
        <Typography.Text type="secondary">Anahtar: {flag.key}</Typography.Text>
        <Space align="center">
          <Typography.Text>Durum:</Typography.Text>
          <Switch checked={flag.enabled} onChange={toggle} disabled={saving} />
        </Space>
      </Space>
    </Card>
  );
}