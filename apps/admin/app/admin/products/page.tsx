"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import { Table, Input, Button, Space, Tag, Typography } from "antd";

const { Title } = Typography;

type Product = {
  id: number;
  name: string;
  sku: string;
  price: number;
  status: "active" | "draft" | "archived";
};

export default function ProductsPage() {
  const [q, setQ] = useState("");
  const data = useMemo<Product[]>(
    () => [
      { id: 1, name: "Örnek Ürün A", sku: "SKU-A1", price: 1299, status: "active" },
      { id: 2, name: "Örnek Ürün B", sku: "SKU-B2", price: 899, status: "draft"  },
      { id: 3, name: "Örnek Ürün C", sku: "SKU-C3", price: 1999, status: "archived" },
    ].filter(p =>
      [p.name, p.sku].join(" ").toLowerCase().includes(q.toLowerCase())
    ),
    [q]
  );

  return (
    <div style={{ padding: 20 }}>
      <Space style={{ width: "100%", justifyContent: "space-between", marginBottom: 16 }}>
        <Title level={3} style={{ margin: 0 }}>Ürünler</Title>
        <Space>
          <Input.Search
            placeholder="Ürün adı/SKU ara…"
            allowClear
            onSearch={setQ}
            onChange={(e)=>setQ(e.target.value)}
            style={{ width: 280 }}
          />
          <Link href="/admin/products/new">
            <Button type="primary">Yeni Ürün</Button>
          </Link>
        </Space>
      </Space>

      <Table
        rowKey="id"
        dataSource={data}
        pagination={{ pageSize: 10 }}
        columns={[
          { title: "ID", dataIndex: "id", width: 80 },
          {
            title: "Ürün",
            key: "name",
            render: (_, r) => (
              <Space direction="vertical" size={0}>
                <Link href={`/admin/products/${r.id}`} style={{ fontWeight: 600 }}>{r.name}</Link>
                <span style={{ color: "#888" }}>{r.sku}</span>
              </Space>
            )
          },
          { title: "Fiyat (₺)", dataIndex: "price", width: 140, render: (v:number)=>v.toLocaleString("tr-TR") },
          {
            title: "Durum",
            dataIndex: "status",
            width: 140,
            render: (s:Product["status"]) => {
              const map = { active: "green", draft: "orange", archived: "red" } as const;
              return <Tag color={map[s]}>{s}</Tag>;
            }
          },
          {
            title: "İşlemler",
            key: "actions",
            width: 160,
            render: (_, r) => (
              <Space>
                <Link href={`/admin/products/${r.id}`}><Button size="small">Düzenle</Button></Link>
                <Button size="small" danger>Sil</Button>
              </Space>
            )
          },
        ]}
      />
    </div>
  );
}
