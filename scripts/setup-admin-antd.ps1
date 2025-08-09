# scripts/setup-admin-antd.ps1
# Tek komutla admin'i App Router + AntD'ye dönüştürür,
# (panel) shell ve Products/Orders/Users modüllerini pagination/sort/CRUD modallarıyla kurar.

$ErrorActionPreference = "Stop"
Write-Host "`n==== Admin AntD Kurulum (tam otomatik) basliyor ====" -ForegroundColor Cyan

# --------- Yol & kontroller ---------
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Admin    = Join-Path $RepoRoot "apps\admin"
if (-not (Test-Path $Admin)) { throw "Admin klasörü yok: $Admin" }
Write-Host "Repo:  $RepoRoot"
Write-Host "Admin: $Admin"

# pnpm & node kontrol
function Test-Cmd($name){ $p = (Get-Command $name -ErrorAction SilentlyContinue); return $null -ne $p }
if (-not (Test-Cmd "pnpm")) { throw "pnpm bulunamadı. Önce pnpm kur: npm i -g pnpm" }
if (-not (Test-Cmd "node")) { throw "Node.js bulunamadı. Node 20+ önerilir." }

# --------- pages -> yedekle ve kaldır ---------
$Pages = Join-Path $Admin "pages"
if (Test-Path $Pages) {
  $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
  $Backup = Join-Path $Admin "_pages_legacy_admin_$stamp"
  Write-Host "pages/ bulundu. Yedekleniyor: $Backup" -ForegroundColor Yellow
  Move-Item -Force -Path $Pages -Destination $Backup
}

# --------- app yapısı & layout (AntD provider) ---------
$AppDir = Join-Path $Admin "app"
New-Item -ItemType Directory -Force -Path $AppDir | Out-Null

$Layout = Join-Path $AppDir "layout.tsx"
if (Test-Path $Layout) {
  Copy-Item -LiteralPath $Layout -Destination "$Layout.bak" -Force
  Write-Host "layout.tsx yedeklendi: layout.tsx.bak" -ForegroundColor Yellow
}
@'
'use client';

import 'antd/dist/reset.css';
import { ConfigProvider, App as AntApp } from 'antd';
import React from 'react';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="tr">
      <body>
        <ConfigProvider>
          <AntApp>{children}</AntApp>
        </ConfigProvider>
      </body>
    </html>
  );
}
'@ | Out-File -LiteralPath $Layout -Encoding utf8
Write-Host "layout.tsx yazildi."

# --------- root page -> /products'a yönlendirme ---------
$RootPage = Join-Path $AppDir "page.tsx"
@'
'use client';
import { useEffect } from "react";
import { useRouter } from "next/navigation";
export default function Home() {
  const r = useRouter();
  useEffect(() => { r.replace("/products"); }, [r]);
  return null;
}
'@ | Out-File -LiteralPath $RootPage -Encoding utf8
Write-Host "app/page.tsx yazildi (auto-redirect -> /products)."

# --------- (panel) shell + modül klasörleri ---------
$PanelDir = Join-Path $AppDir "(panel)"
New-Item -ItemType Directory -Force -Path $PanelDir | Out-Null
foreach ($m in @("products","orders","users")) {
  New-Item -ItemType Directory -Force -Path (Join-Path $PanelDir $m) | Out-Null
}

# (panel)/layout.tsx
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
  const { token: { colorBgContainer, borderRadiusLG } } = theme.useToken();

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
          <div style={{ padding: 16, background: colorBgContainer, borderRadius: borderRadiusLG }}>
            {children}
          </div>
        </Content>
      </Layout>
    </Layout>
  );
}
'@ | Out-File -LiteralPath (Join-Path $PanelDir "layout.tsx") -Encoding utf8
Write-Host "(panel)/layout.tsx yazildi."

# --------- PRODUCTS (pagination/sort + CRUD modallari) ---------
$ProductsPage = Join-Path $PanelDir "products\page.tsx"
@'
'use client';
import { Table, Button, Space, Tag, Modal, Form, Input, InputNumber, Select, Popconfirm, message } from "antd";
import { PlusOutlined } from "@ant-design/icons";
import { useMemo, useState } from "react";
import type { TableProps } from "antd";

type Product = { key: string; name: string; price: number; status: "active" | "draft" };

const initialData: Product[] = [
  { key: "1", name: "iPhone 15", price: 45999, status: "active" },
  { key: "2", name: "Galaxy S24", price: 38999, status: "draft" },
  { key: "3", name: "Pixel 8",  price: 32999, status: "active" },
];

export default function ProductsPage() {
  const [data, setData] = useState<Product[]>(initialData);
  const [page, setPage] = useState({ current: 1, pageSize: 10 });
  const [sorter, setSorter] = useState<{ field?: string; order?: "ascend" | "descend" }>({});
  const [search, setSearch] = useState("");
  const [modalOpen, setModalOpen] = useState(false);
  const [editing, setEditing] = useState<Product | null>(null);
  const [form] = Form.useForm<Product>();

  const filtered = useMemo(() => {
    let arr = data.filter(d => d.name.toLowerCase().includes(search.toLowerCase()));
    if (sorter.field === "name") {
      arr = [...arr].sort((a, b) => sorter.order === "ascend" ? a.name.localeCompare(b.name) : b.name.localeCompare(a.name));
    }
    if (sorter.field === "price") {
      arr = [...arr].sort((a, b) => sorter.order === "ascend" ? a.price - b.price : b.price - a.price);
    }
    return arr;
  }, [data, search, sorter]);

  const columns: TableProps<Product>["columns"] = [
    { title: "Ürün", dataIndex: "name", sorter: true, sortOrder: sorter.field==="name"? sorter.order:undefined, render: v => <strong>{v}</strong> },
    { title: "Fiyat (₺)", dataIndex: "price", sorter: true, sortOrder: sorter.field==="price"? sorter.order:undefined, align:"right", render: (v)=> v.toLocaleString("tr-TR") },
    { title: "Durum", dataIndex: "status",
      filters:[{text:"active",value:"active"},{text:"draft",value:"draft"}],
      onFilter:(value, record)=>record.status===value,
      render:(v)=> <Tag color={v==="active"?"green":"orange"}>{v}</Tag> },
    { title:"Aksiyon", key:"action", render:(_,rec)=>(
      <Space>
        <Button onClick={()=>onEdit(rec)}>Düzenle</Button>
        <Popconfirm title="Silinsin mi?" okText="Evet" cancelText="Vazgeç" onConfirm={()=>onDelete(rec.key)}>
          <Button danger>Sil</Button>
        </Popconfirm>
      </Space>
    )},
  ];

  const onTableChange: TableProps<Product>["onChange"] = (pagination,_filters,sort)=>{
    setPage({ current: pagination.current ?? 1, pageSize: pagination.pageSize ?? 10 });
    if (!Array.isArray(sort)) setSorter({ field: (sort.field as string) ?? undefined, order: sort.order ?? undefined });
  };

  const onCreate = () => { setEditing(null); form.resetFields(); setModalOpen(true); };
  const onEdit = (rec: Product) => { setEditing(rec); form.setFieldsValue(rec); setModalOpen(true); };
  const onDelete = (key:string)=>{ setData(p=>p.filter(x=>x.key!==key)); message.success("Ürün silindi"); };

  const onModalOk = async ()=>{
    const values = await form.validateFields();
    if (editing) {
      setData(prev => prev.map(x => x.key === editing.key ? { ...editing, ...values } : x));
      message.success("Ürün güncellendi");
    } else {
      const key = Date.now().toString();
      setData(prev => [{ key, ...values }, ...prev]);
      message.success("Ürün eklendi");
    }
    setModalOpen(false);
  };

  return (
    <Space direction="vertical" size="large" style={{ width:"100%" }}>
      <Space style={{ justifyContent:"space-between", width:"100%" }}>
        <h2 style={{ margin:0 }}>Ürünler</h2>
        <Space>
          <Input.Search placeholder="Ürün ara" allowClear onSearch={setSearch} style={{ width:300 }}/>
          <Button type="primary" icon={<PlusOutlined />} onClick={onCreate}>Yeni Ürün</Button>
        </Space>
      </Space>

      <Table<Product>
        rowKey="key"
        dataSource={filtered}
        columns={columns}
        pagination={{ ...page, total: filtered.length, showSizeChanger:true }}
        onChange={onTableChange}
      />

      <Modal title={editing ? "Ürün Düzenle" : "Yeni Ürün"} open={modalOpen} onOk={onModalOk} onCancel={()=>setModalOpen(false)} destroyOnClose>
        <Form form={form} layout="vertical" preserve={false}>
          <Form.Item name="name" label="Ürün Adı" rules={[{ required:true, message:"Gerekli" }]}><Input/></Form.Item>
          <Form.Item name="price" label="Fiyat (₺)" rules={[{ required:true }]}><InputNumber min={0} style={{ width:"100%" }}/></Form.Item>
          <Form.Item name="status" label="Durum" initialValue="active">
            <Select options={[{value:"active",label:"active"},{value:"draft",label:"draft"}]}/>
          </Form.Item>
        </Form>
      </Modal>
    </Space>
  );
}
'@ | Out-File -LiteralPath $ProductsPage -Encoding utf8
Write-Host "Products sayfasi yazildi."

# --------- ORDERS ---------
$OrdersPage = Join-Path $PanelDir "orders\page.tsx"
@'
'use client';
import { Table, Tag, Button, Space, Modal, Form, Input, InputNumber, Select, Popconfirm, message } from "antd";
import type { TableProps } from "antd";
import { PlusOutlined } from "@ant-design/icons";
import { useMemo, useState } from "react";

type Order = { key:string; orderNo:string; user:string; total:number; status:"paid"|"pending"|"cancelled" };

const initialData: Order[] = [
  { key:"o1", orderNo:"EC-1001", user:"Ali Yılmaz", total:1299, status:"paid" },
  { key:"o2", orderNo:"EC-1002", user:"Ayşe Kaya",  total: 799, status:"pending" },
  { key:"o3", orderNo:"EC-1003", user:"Mehmet Demir", total:2499, status:"cancelled" },
];

export default function OrdersPage(){
  const [data,setData] = useState<Order[]>(initialData);
  const [page,setPage] = useState({ current:1, pageSize:10 });
  const [sorter,setSorter] = useState<{ field?: string; order?: "ascend" | "descend" }>({});
  const [statusFilter,setStatusFilter] = useState<("paid"|"pending"|"cancelled")[]>([]);
  const [search,setSearch] = useState("");
  const [modalOpen,setModalOpen] = useState(false);
  const [editing,setEditing] = useState<Order|null>(null);
  const [form] = Form.useForm<Order>();

  const filtered = useMemo(()=>{
    let arr = data.filter(d => d.orderNo.toLowerCase().includes(search.toLowerCase()) || d.user.toLowerCase().includes(search.toLowerCase()));
    if (statusFilter.length) arr = arr.filter(d => statusFilter.includes(d.status));
    if (sorter.field==="orderNo") arr = [...arr].sort((a,b)=> sorter.order==="ascend" ? a.orderNo.localeCompare(b.orderNo) : b.orderNo.localeCompare(a.orderNo));
    if (sorter.field==="user")    arr = [...arr].sort((a,b)=> sorter.order==="ascend" ? a.user.localeCompare(b.user) : b.user.localeCompare(a.user));
    if (sorter.field==="total")   arr = [...arr].sort((a,b)=> sorter.order==="ascend" ? a.total-b.total : b.total-a.total);
    return arr;
  },[data,search,sorter,statusFilter]);

  const columns: TableProps<Order>["columns"] = [
    { title:"Sipariş No", dataIndex:"orderNo", sorter:true, sortOrder: sorter.field==="orderNo"?sorter.order:undefined },
    { title:"Kullanıcı",  dataIndex:"user",    sorter:true, sortOrder: sorter.field==="user"   ?sorter.order:undefined },
    { title:"Tutar (₺)",  dataIndex:"total",   sorter:true, sortOrder: sorter.field==="total"  ?sorter.order:undefined, align:"right", render:(v:number)=> v.toLocaleString("tr-TR") },
    { title:"Durum",      dataIndex:"status",
      filters:[{text:"paid",value:"paid"},{text:"pending",value:"pending"},{text:"cancelled",value:"cancelled"}],
      onFilter:(val,rec)=> rec.status===val,
      render:(v)=> <Tag color={v==="paid"?"green": v==="pending"?"gold":"red"}>{v}</Tag>
    },
    { title:"Aksiyon", key:"action", render:(_,rec)=>(
      <Space>
        <Button onClick={()=>onEdit(rec)}>Düzenle</Button>
        <Popconfirm title="Silinsin mi?" okText="Evet" cancelText="Vazgeç" onConfirm={()=>onDelete(rec.key)}>
          <Button danger>Sil</Button>
        </Popconfirm>
      </Space>
    )},
  ];

  const onTableChange: TableProps<Order>["onChange"] = (pagination,filters,sort)=>{
    setPage({ current: pagination.current ?? 1, pageSize: pagination.pageSize ?? 10 });
    if (!Array.isArray(sort)) setSorter({ field: (sort.field as string) ?? undefined, order: sort.order ?? undefined });
    const s = (filters?.status ?? []) as ("paid"|"pending"|"cancelled")[];
    setStatusFilter(s.filter(Boolean));
  };

  const onCreate = ()=>{ setEditing(null); form.resetFields(); setModalOpen(true); };
  const onEdit = (rec:Order)=>{ setEditing(rec); form.setFieldsValue(rec); setModalOpen(true); };
  const onDelete = (key:string)=>{ setData(p=>p.filter(x=>x.key!==key)); message.success("Sipariş silindi"); };

  const onModalOk = async ()=>{
    const values = await form.validateFields();
    if (editing) {
      setData(prev=> prev.map(x=> x.key===editing.key ? { ...editing, ...values } : x));
      message.success("Sipariş güncellendi");
    } else {
      const key = "o"+Date.now();
      const orderNo = values.orderNo?.trim() || ("EC-" + Math.floor(1000 + Math.random()*9000));
      setData(prev=> [{ key, ...values, orderNo }, ...prev]);
      message.success("Sipariş eklendi");
    }
    setModalOpen(false);
  };

  return (
    <Space direction="vertical" size="large" style={{ width:"100%" }}>
      <Space style={{ justifyContent:"space-between", width:"100%" }}>
        <h2 style={{ margin:0 }}>Siparişler</h2>
        <Space>
          <Input.Search placeholder="Sipariş no / kullanıcı ara" allowClear onSearch={setSearch} style={{ width:320 }}/>
          <Select mode="multiple" allowClear placeholder="Durum" style={{ width:240 }} value={statusFilter}
            onChange={(v)=>setStatusFilter(v as any)}
            options={[{value:"paid",label:"paid"},{value:"pending",label:"pending"},{value:"cancelled",label:"cancelled"}]} />
          <Button type="primary" icon={<PlusOutlined />} onClick={onCreate}>Yeni Sipariş</Button>
        </Space>
      </Space>

      <Table<Order>
        rowKey="key"
        dataSource={filtered}
        columns={columns}
        pagination={{ ...page, total: filtered.length, showSizeChanger:true }}
        onChange={onTableChange}
      />

      <Modal title={editing ? "Sipariş Düzenle" : "Yeni Sipariş"} open={modalOpen} onOk={onModalOk} onCancel={()=>setModalOpen(false)} destroyOnClose>
        <Form form={form} layout="vertical" preserve={false}>
          <Form.Item name="orderNo" label="Sipariş No"><Input placeholder="Boş bırakırsan otomatik oluşturulur"/></Form.Item>
          <Form.Item name="user" label="Kullanıcı" rules={[{ required:true, message:"Gerekli" }]}><Input/></Form.Item>
          <Form.Item name="total" label="Tutar (₺)" rules={[{ required:true }]}><InputNumber min={0} style={{ width:"100%" }}/></Form.Item>
          <Form.Item name="status" label="Durum" initialValue="pending">
            <Select options={[{value:"paid",label:"paid"},{value:"pending",label:"pending"},{value:"cancelled",label:"cancelled"}]}/>
          </Form.Item>
        </Form>
      </Modal>
    </Space>
  );
}
'@ | Out-File -LiteralPath $OrdersPage -Encoding utf8
Write-Host "Orders sayfasi yazildi."

# --------- USERS ---------
$UsersPage = Join-Path $PanelDir "users\page.tsx"
@'
'use client';
import { Table, Tag, Button, Space, Modal, Form, Input, Select, Popconfirm, message } from "antd";
import type { TableProps } from "antd";
import { PlusOutlined } from "@ant-design/icons";
import { useMemo, useState } from "react";

type User = { key:string; name:string; email:string; role:"admin"|"editor"|"viewer" };

const initialData: User[] = [
  { key:"u1", name:"Ali Yılmaz",    email:"ali@example.com",    role:"admin" },
  { key:"u2", name:"Ayşe Kaya",     email:"ayse@example.com",   role:"editor" },
  { key:"u3", name:"Mehmet Demir",  email:"mehmet@example.com", role:"viewer" },
];

export default function UsersPage(){
  const [data,setData] = useState<User[]>(initialData);
  const [page,setPage] = useState({ current:1, pageSize:10 });
  const [sorter,setSorter] = useState<{ field?: string; order?: "ascend" | "descend" }>({});
  const [roleFilter,setRoleFilter] = useState<("admin"|"editor"|"viewer")[]>([]);
  const [search,setSearch] = useState("");
  const [modalOpen,setModalOpen] = useState(false);
  const [editing,setEditing] = useState<User|null>(null);
  const [form] = Form.useForm<User>();

  const filtered = useMemo(()=>{
    let arr = data.filter(d => d.name.toLowerCase().includes(search.toLowerCase()) || d.email.toLowerCase().includes(search.toLowerCase()));
    if (roleFilter.length) arr = arr.filter(d => roleFilter.includes(d.role));
    if (sorter.field==="name")  arr = [...arr].sort((a,b)=> sorter.order==="ascend" ? a.name.localeCompare(b.name) : b.name.localeCompare(a.name));
    if (sorter.field==="email") arr = [...arr].sort((a,b)=> sorter.order==="ascend" ? a.email.localeCompare(b.email) : b.email.localeCompare(a.email));
    return arr;
  },[data,search,sorter,roleFilter]);

  const columns: TableProps<User>["columns"] = [
    { title:"Ad Soyad", dataIndex:"name", sorter:true,  sortOrder: sorter.field==="name"? sorter.order:undefined },
    { title:"E-posta",  dataIndex:"email", sorter:true, sortOrder: sorter.field==="email"? sorter.order:undefined },
    { title:"Rol",      dataIndex:"role",
      filters:[{text:"admin",value:"admin"},{text:"editor",value:"editor"},{text:"viewer",value:"viewer"}],
      onFilter:(val,rec)=> rec.role===val,
      render:(v)=> <Tag color={v==="admin"?"geekblue": v==="editor"?"purple":"default"}>{v}</Tag>
    },
    { title:"Aksiyon", key:"action", render:(_,rec)=>(
      <Space>
        <Button onClick={()=>onEdit(rec)}>Düzenle</Button>
        <Popconfirm title="Silinsin mi?" okText="Evet" cancelText="Vazgeç" onConfirm={()=>onDelete(rec.key)}>
          <Button danger>Sil</Button>
        </Popconfirm>
      </Space>
    )},
  ];

  const onTableChange: TableProps<User>["onChange"] = (pagination,filters,sort)=>{
    setPage({ current: pagination.current ?? 1, pageSize: pagination.pageSize ?? 10 });
    if (!Array.isArray(sort)) setSorter({ field: (sort.field as string) ?? undefined, order: sort.order ?? undefined });
    const r = (filters?.role ?? []) as ("admin"|"editor"|"viewer")[];
    setRoleFilter(r.filter(Boolean));
  };

  const onCreate = ()=>{ setEditing(null); form.resetFields(); setModalOpen(true); };
  const onEdit = (rec:User)=>{ setEditing(rec); form.setFieldsValue(rec); setModalOpen(true); };
  const onDelete = (key:string)=>{ setData(p=>p.filter(x=>x.key!==key)); message.success("Kullanıcı silindi"); };

  const onModalOk = async ()=>{
    const values = await form.validateFields();
    if (editing) {
      setData(prev=> prev.map(x=> x.key===editing.key ? { ...editing, ...values } : x));
      message.success("Kullanıcı güncellendi");
    } else {
      const key = "u"+Date.now();
      setData(prev=> [{ key, ...values }, ...prev]);
      message.success("Kullanıcı eklendi");
    }
    setModalOpen(false);
  };

  return (
    <Space direction="vertical" size="large" style={{ width:"100%" }}>
      <Space style={{ justifyContent:"space-between", width:"100%" }}>
        <h2 style={{ margin:0 }}>Kullanıcılar</h2>
        <Space>
          <Input.Search placeholder="İsim/e-posta ara" allowClear onSearch={setSearch} style={{ width:320 }}/>
          <Select mode="multiple" allowClear placeholder="Rol" style={{ width:240 }} value={roleFilter}
            onChange={(v)=>setRoleFilter(v as any)}
            options={[{value:"admin",label:"admin"},{value:"editor",label:"editor"},{value:"viewer",label:"viewer"}]} />
          <Button type="primary" icon={<PlusOutlined />} onClick={onCreate}>Yeni Kullanıcı</Button>
        </Space>
      </Space>

      <Table<User>
        rowKey="key"
        dataSource={filtered}
        columns={columns}
        pagination={{ ...page, total: filtered.length, showSizeChanger:true }}
        onChange={onTableChange}
      />

      <Modal title={editing ? "Kullanıcı Düzenle" : "Yeni Kullanıcı"} open={modalOpen} onOk={onModalOk} onCancel={()=>setModalOpen(false)} destroyOnClose>
        <Form form={form} layout="vertical" preserve={false}>
          <Form.Item name="name"  label="Ad Soyad" rules={[{ required:true, message:"Gerekli" }]}><Input/></Form.Item>
          <Form.Item name="email" label="E-posta"  rules={[{ required:true, type:"email", message:"Geçerli e-posta girin" }]}><Input/></Form.Item>
          <Form.Item name="role"  label="Rol"     initialValue="viewer">
            <Select options={[{value:"admin",label:"admin"},{value:"editor",label:"editor"},{value:"viewer",label:"viewer"}]} />
          </Form.Item>
        </Form>
      </Modal>
    </Space>
  );
}
'@ | Out-File -LiteralPath $UsersPage -Encoding utf8
Write-Host "Users sayfasi yazildi."

# --------- next.config.js (swcMinify yok, dev=memory cache) ---------
$NextCfg = Join-Path $Admin "next.config.js"
if (Test-Path $NextCfg) { Copy-Item -LiteralPath $NextCfg -Destination "$NextCfg.bak" -Force; Write-Host "next.config.js yedeklendi." -ForegroundColor Yellow }
@'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  webpack: (config) => {
    if (process.env.NODE_ENV === "development") {
      config.cache = { type: "memory" }; // Windows dosya kilidi sorunlarını azaltır
    }
    return config;
  },
};
module.exports = nextConfig;
'@ | Out-File -LiteralPath $NextCfg -Encoding utf8
Write-Host "next.config.js yazildi (swcMinify yok, dev=memory cache)."

# --------- Paketler ---------
Write-Host "Paketler yükleniyor: antd, @ant-design/icons" -ForegroundColor Yellow
pnpm -C $Admin add antd @ant-design/icons | Out-Host

Write-Host "`n==== Tamam! Admin AntD kurulumu bitti. ====" -ForegroundColor Green
Write-Host "Calistirma: pnpm --filter `"enucuzkim-admin`" dev" -ForegroundColor Cyan
Write-Host "Rotalar: /products /orders /users" -ForegroundColor Cyan

