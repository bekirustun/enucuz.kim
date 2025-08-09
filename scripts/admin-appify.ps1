# scripts/admin-appify.ps1
# Admin'i App Router'a taşı, AntD Provider ekle, antd-demo'yu app yapısına aktar
# Çalıştırma: & ".\scripts\admin-appify.ps1"

$ErrorActionPreference = "Stop"
Write-Host "`n==== Admin Appify (App Router + AntD) Basliyor ====" -ForegroundColor Cyan

# Repo kökü = bu scriptin bir üst klasörü
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$AdminPath = Join-Path $RepoRoot "apps\admin"
if (-not (Test-Path $AdminPath)) {
  throw "Admin klasörü bulunamadı: $AdminPath"
}
Write-Host "Repo kökü: $RepoRoot"
Write-Host "Admin:     $AdminPath"

# 1) pages klasörünü yedekleyip kaldır
$PagesPath = Join-Path $AdminPath "pages"
if (Test-Path $PagesPath) {
  $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
  $BackupDir = Join-Path $AdminPath "_pages_legacy_admin_$stamp"
  Write-Host "pages/ bulundu. Yedek alınıyor -> $BackupDir" -ForegroundColor Yellow
  Move-Item -Force -Path $PagesPath -Destination $BackupDir
} else {
  Write-Host "pages/ klasörü bulunamadı, atlanıyor."
}

# 2) app yapısı garanti
$AppDir = Join-Path $AdminPath "app"
$AntdDemoDir = Join-Path $AppDir "antd-demo"
New-Item -ItemType Directory -Force -Path $AppDir      | Out-Null
New-Item -ItemType Directory -Force -Path $AntdDemoDir | Out-Null

# 3) layout.tsx (AntD Provider + reset.css)
$LayoutPath = Join-Path $AppDir "layout.tsx"
$layoutContent = @'
'use client';

import 'antd/dist/reset.css';
import { ConfigProvider, App as AntApp } from 'antd';
import React from 'react';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="tr">
      <body>
        <ConfigProvider>
          <AntApp>
            {children}
          </AntApp>
        </ConfigProvider>
      </body>
    </html>
  );
}
'@
if (Test-Path $LayoutPath) {
  Copy-Item $LayoutPath "$LayoutPath.bak" -Force
  Write-Host "Mevcut layout.tsx yedeklendi: layout.tsx.bak"
}
$layoutContent | Set-Content $LayoutPath -Encoding UTF8
Write-Host "layout.tsx yazıldı."

# 4) Ana sayfa app/page.tsx (varsa dokunma, yoksa oluştur)
$IndexPath = Join-Path $AppDir "page.tsx"
if (-not (Test-Path $IndexPath)) {
  @'
export default function Home() {
  return (
    <div style={{ padding: 40 }}>
      <h1>Admin Paneli</h1>
      <p>Enucuz.kim yönetim paneline hoş geldiniz!</p>
      <p>Yönetim ve analiz burada başlar.</p>
    </div>
  );
}
'@ | Set-Content $IndexPath -Encoding UTF8
  Write-Host "page.tsx oluşturuldu."
} else {
  Write-Host "page.tsx zaten var, atlanıyor."
}

# 5) antd-demo sayfasını app/antd-demo/page.tsx olarak yaz
$AntdDemoPage = Join-Path $AntdDemoDir "page.tsx"
@'
'use client';

import { Button, Card, Table, Tag, Space, Input } from "antd";
import { PlusOutlined, SearchOutlined } from "@ant-design/icons";

const data = [
  { key: "1", name: "iPhone 15", price: 45999, status: "active" },
  { key: "2", name: "Galaxy S24", price: 38999, status: "draft" },
];

export default function AntdDemo() {
  return (
    <Space direction="vertical" size="large" style={{ width: "100%", padding: 24 }}>
      <Card title="Hızlı Aksiyonlar" extra={<Button type="primary" icon={<PlusOutlined />}>Yeni Ürün</Button>}>
        <Space>
          <Input placeholder="Ürün ara" prefix={<SearchOutlined />} style={{ width: 280 }} />
          <Button>Filtreler</Button>
        </Space>
      </Card>

      <Card title="Ürün Listesi">
        <Table
          dataSource={data}
          pagination={false}
          columns={[
            { title: "Ürün", dataIndex: "name" },
            { title: "Fiyat (₺)", dataIndex: "price" },
            {
              title: "Durum",
              dataIndex: "status",
              render: (v) => <Tag color={v === "active" ? "green" : "orange"}>{v}</Tag>,
            },
          ]}
        />
      </Card>
    </Space>
  );
}
'@ | Set-Content $AntdDemoPage -Encoding UTF8
Write-Host "/antd-demo sayfası yazıldı."

# 6) next.config.js (swcMinify kaldır, dev'de memory cache)
$NextCfgPath = Join-Path $AdminPath "next.config.js"
$nextCfg = @'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  webpack: (config) => {
    if (process.env.NODE_ENV === "development") {
      config.cache = { type: "memory" };
    }
    return config;
  },
};

module.exports = nextConfig;
'@
if (Test-Path $NextCfgPath) {
  Copy-Item $NextCfgPath "$NextCfgPath.bak" -Force
  Write-Host "next.config.js yedeklendi: next.config.js.bak"
}
$nextCfg | Set-Content $NextCfgPath -Encoding UTF8
Write-Host "next.config.js güncellendi (swcMinify yok, dev=memory cache)."

# 7) Paketler (antd + icons)
Write-Host "Gerekli paketler yükleniyor (antd, @ant-design/icons)..." -ForegroundColor Yellow
Push-Location $RepoRoot
pnpm -C "$AdminPath" add antd @ant-design/icons | Out-Host
Pop-Location

Write-Host "`n==== Tamam! Admin artık App Router + AntD ile hazır. ====" -ForegroundColor Green
Write-Host "Calistirma:"
Write-Host '  pnpm --filter "enucuzkim-admin" dev' -ForegroundColor Cyan
Write-Host "Sonra tarayıcıdan: /antd-demo" -ForegroundColor Cyan