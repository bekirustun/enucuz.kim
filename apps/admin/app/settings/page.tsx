"use client";

import { useEffect, useState } from "react";

type Feature = {
  id?: number;
  key: string;
  name: string;
  enabled: boolean;
  parentKey?: string | null;
  meta?: any;
  subFeatures?: Feature[];
};

export default function SettingsPage() {
  const [data, setData] = useState<Feature[] | null>(null);
  const [err, setErr] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      try {
        const res = await fetch("/api/admin/settings/features", { cache: "no-store" });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        setData(await res.json());
      } catch (e:any) { setErr(String(e.message || e)); }
    })();
  }, []);

  if (err) return <div style={{ padding: 20 }}>Hata: {err}</div>;
  if (!data) return <div style={{ padding: 20 }}>Yükleniyor…</div>;

  const render = (items: Feature[]) => (
    <ul style={{ lineHeight: 1.7 }}>
      {items.map(it => (
        <li key={it.key}>
          <strong>{it.name}</strong> <code>({it.key})</code> — {it.enabled ? "✅ açık" : "⛔ kapalı"}
          {it.subFeatures && it.subFeatures.length > 0 ? render(it.subFeatures) : null}
        </li>
      ))}
    </ul>
  );

  return (
    <div style={{ padding: 24 }}>
      <h1>Ayarlar / Özellikler</h1>
      {render(data)}
    </div>
  );
}
