"use client";
import { Card, Input, Select, List } from "antd";
import { useState } from "react";

export default function SearchDemo() {
  const [q, setQ] = useState("iphone");
  const data = ["iPhone 15", "iPhone 14", "Galaxy S24"].filter(x => x.toLowerCase().includes(q.toLowerCase()));
  return (
    <div style={{ padding: 24 }}>
      <Card title="Arama">
        <div style={{ display: "flex", gap: 12 }}>
          <Input placeholder="Ürün ara" value={q} onChange={e => setQ(e.target.value)} style={{ maxWidth: 320 }} />
          <Select defaultValue="popularity" options={[
            { value: "popularity", label: "Popüler" },
            { value: "price_asc", label: "Fiyat Artan" },
            { value: "price_desc", label: "Fiyat Azalan" },
          ]} style={{ width: 180 }} />
        </div>
      </Card>
      <Card title="Sonuçlar" style={{ marginTop: 16 }}>
        <List dataSource={data} renderItem={(item) => <List.Item>{item}</List.Item>} />
      </Card>
    </div>
  );
}
