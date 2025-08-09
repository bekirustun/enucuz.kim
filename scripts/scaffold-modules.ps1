# scripts/scaffold-modules.ps1
# Admin: products / orders / users modüllerini kurar (App Router + AntD Shell)
# Web: antd-provider ve bir örnek "search-demo" sayfası ekler
# Çalıştırma: & ".\scripts\scaffold-modules.ps1"

$ErrorActionPreference = "Stop"
Write-Host "`n==== Yönetim Modülleri + Web AntD Scaffold Başlıyor ====" -ForegroundColor Cyan

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Admin   = Join-Path $RepoRoot "apps\admin"
$Web     = Join-Path $RepoRoot "apps\web"

if (-not (Test-Path $Admin)) { throw "Admin bulunamadı: $Admin" }
if (-not (Test-Path $Web))   { throw "Web bulunamadı:   $Web" }

Write-Host "Repo:   $RepoRoot"
Write-Host "Admin:  $Admin"
Write-Host "Web:    $Web"

# ========== ADMIN ==========
$PanelGroup = Join-Path $Admin "app\(panel)"
New-Item -ItemType Directory -Force -Path $PanelGroup | Out-Null
foreach ($m in @("products","orders","users")) {
  New-Item -ItemType Directory -Force -Path (Join-Path $PanelGroup $m) | Out-Null
}

# (panel)/layout.tsx — AntD Shell (Sider + Header)
@'
'use client';
import React, { useMemo } from "react";
import Link from "next/link";
import { Layout, Menu, theme } from "antd";
import { AppstoreOutlined, ShoppingCartOutlined, UserOutlined } from "@ant-design/icons";
const { Header, Sider, Content } = Layout;

const items = [
  { key: "/products", icon: <AppstoreOutlined />, label: <Link href="/products">Ürünler</Link> },
  { key: "/orders",   icon: <ShoppingCartOutlined />, label: <Link href="/orders">Siparişler</Link> },
  { key: "/users",    icon: <UserOutlined />, label: <Link href="/users">Kullanıcılar</Link> },
];

export default function PanelLayout({ children }: { children: React.ReactNode }) {
  const {
    token: { colorBgContainer, borderRadiusLG },
  } = theme.useToken();

  // aktif menü (client)
  const selected = useMemo(() => {
    if (typeof window === "undefined") return ["/products"];
    const path = window.location.pathname;
    const hit = items.find(i => path.startsWith(i.key));
    return [hit?.key ?? "/products"];
  }, []);

  return (
    <Layout style={{ minHeight: "100vh" }}>
      <Sider breakpoint="lg" collapsedWidth={64}>
        <div style={{ color: "white", padding: 16, fontWeight: 600 }}>Admin</div>
        <Menu theme="dark" mode="inline" items={items} selectedKeys={selected} />
      </Sider>
      <Layout>
        <Header style={{ background: colorBgContainer, padding: "0 16px" }}>
          <div style={{ fontWeight: 600 }}>Enucuz.kim Yönetim</div>
        </Header>
        <Content style={{ margin: 16 }}>
          <div style={{ padding: 16, background: colorBgContainer, borderRadius: borderRadiusLG }}>{children}</div>
        </Content>
      </Layout>
    </Layout>
  );
}
'@ | Set-Content (Join-Path $PanelGroup "layout.tsx")

# PRODUCTS
@'
'use client';
import { Table, Button, Space, Tag } from "antd";
import { PlusOutlined } from "@ant-design/icons";

const data = [
  { key: "1", name: "iPhone 15", price: 45999, status: "active" },
  { key: "2", name: "Galaxy S24", price: 38999, status: "draft" },
];

export default function ProductsPage() {
  return (
    <Space direction="vertical" size="large" style={{ width: "100%" }}>
      <Space style={{ justifyContent: "space-between", width: "100%" }}>
        <h2 style={{ margin: 0 }}>Ürünler</h2>
        <Button type="primary" icon={<PlusOutlined />}>Yeni Ürün</Button>
      </Space>
      <Table dataSource={data} pagination={{ pageSize: 10 }} columns={[
        { title: "Ürün", dataIndex: "name" },
        { title: "Fiyat (₺)", dataIndex: "price" },
        { title: "Durum", dataIndex: "status", render: (v) => <Tag color={v === "active" ? "green" : "orange"}>{v}</Tag> },
        { title: "Aksiyon", render: () => <Space><Button>Güncelle</Button><Button danger>Sil</Button></Space> }
      ]}/>
    </Space>
  );
}
'@ | Set-Content (Join-Path $PanelGroup "products\page.tsx")

# ORDERS
@'
'use client';
import { Table, Tag } from "antd";

const data = [
  { key: "o1", orderNo: "EC-1001", user: "Ali Yılmaz", total: 1299, status: "paid" },
  { key: "o2", orderNo: "EC-1002", user: "Ayşe Kaya", total: 799, status: "pending" },
];

export default function OrdersPage() {
  return (
    <>
      <h2>Siparişler</h2>
      <Table dataSource={data} pagination={{ pageSize: 10 }} columns={[
        { title: "Sipariş No", dataIndex: "orderNo" },
        { title: "Kullanıcı", dataIndex: "user" },
        { title: "Tutar (₺)", dataIndex: "total" },
        { title: "Durum", dataIndex: "status", render: (v) => <Tag color={v === "paid" ? "green" : "gold"}>{v}</Tag> },
      ]}/>
    </>
  );
}
'@ | Set-Content (Join-Path $PanelGroup "orders\page.tsx")

# USERS
@'
'use client';
import { Table, Tag } from "antd";

const data = [
  { key: "u1", name: "Ali Yılmaz", email: "ali@example.com", role: "admin" },
  { key: "u2", name: "Ayşe Kaya", email: "ayse@example.com", role: "editor" },
];

export default function UsersPage() {
  return (
    <>
      <h2>Kullanıcılar</h2>
      <Table dataSource={data} pagination={{ pageSize: 10 }} columns={[
        { title: "Ad Soyad", dataIndex: "name" },
        { title: "E-posta", dataIndex: "email" },
        { title: "Rol", dataIndex: "role", render: (v) => <Tag color={v === "admin" ? "geekblue" : "purple"}>{v}</Tag> },
      ]}/>
    </>
  );
}
'@ | Set-Content (Join-Path $PanelGroup "users\page.tsx")

# index -> products'a yönlendirme (opsiyonel)
@'
'use client';
import { useEffect } from "react";
import { useRouter } from "next/navigation";
export default function Home() {
  const r = useRouter();
  useEffect(() => { r.replace("/products"); }, [r]);
  return null;
}
'@ | Set-Content (Join-Path $Admin "app\page.tsx")

# Paketler (admin)
Write-Host "Admin paket kontrolü: antd + icons" -ForegroundColor Yellow
pnpm -C $Admin add antd @ant-design/icons | Out-Host

# ========== WEB ==========
# AntdProvider garanti
$AntdProvider = Join-Path $Web "app\AntdProvider.tsx"
if (-not (Test-Path (Split-Path $AntdProvider))) {
  New-Item -ItemType Directory -Force -Path (Split-Path $AntdProvider) | Out-Null
}
@'
"use client";
import React from "react";
import { ConfigProvider, App as AntApp } from "antd";
import { StyleProvider } from "@ant-design/cssinjs";
export default function AntdProvider({ children }: { children: React.ReactNode }) {
  return (
    <StyleProvider hashPriority="high">
      <ConfigProvider>
        <AntApp>{children}</AntApp>
      </ConfigProvider>
    </StyleProvider>
  );
}
'@ | Set-Content $AntdProvider

# web layout.tsx içine provider (varsa yedekle)
$WebLayout = Join-Path $Web "app\layout.tsx"
if (Test-Path $WebLayout) { Copy-Item $WebLayout "$WebLayout.bak" -Force }
@'
import type { Metadata } from "next";
import AntdProvider from "./AntdProvider";
export const metadata: Metadata = { title: "Enucuz.kim", description: "Web" };
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="tr">
      <body>
        <AntdProvider>{children}</AntdProvider>
      </body>
    </html>
  );
}
'@ | Set-Content $WebLayout

# web: search-demo
$SearchDemoDir = Join-Path $Web "app\search-demo"
New-Item -ItemType Directory -Force -Path $SearchDemoDir | Out-Null
@'
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
'@ | Set-Content (Join-Path $SearchDemoDir "page.tsx")

# Paketler (web)
Write-Host "Web paket kontrolü: antd + icons + cssinjs" -ForegroundColor Yellow
pnpm -C $Web add antd @ant-design/icons @ant-design/cssinjs | Out-Host

Write-Host "`n==== Bitti! ====" -ForegroundColor Green
Write-Host "Admin modülleri: /products /orders /users  (ortak shell: (panel)/layout.tsx)"
Write-Host "Web demo:        /search-demo"