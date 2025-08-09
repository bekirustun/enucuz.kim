# scripts/enrich-orders-users.ps1
# Admin App Router: (panel)/orders ve (panel)/users sayfalarını
# pagination + sort + filter + CRUD modallarıyla oluşturur/günceller.

$ErrorActionPreference = "Stop"
Write-Host "`n==== Orders & Users enrich başlıyor ====" -ForegroundColor Cyan

# Repo kökü
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$PanelDir = Join-Path $RepoRoot "apps\admin\app\`(panel`)"

# Klasörleri hazırla
$OrdersDir = Join-Path $PanelDir "orders"
$UsersDir  = Join-Path $PanelDir "users"
New-Item -ItemType Directory -Force -Path $OrdersDir | Out-Null
New-Item -ItemType Directory -Force -Path $UsersDir  | Out-Null

# ---------- ORDERS ----------
$OrdersPage = Join-Path $OrdersDir "page.tsx"

if (Test-Path $OrdersPage) {
  $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
  Copy-Item $OrdersPage "$OrdersPage.$stamp.bak" -Force
  Write-Host "Orders yedeklendi: $OrdersPage.$stamp.bak" -ForegroundColor Yellow
}

$OrdersContent = @'
'use client';

import { Table, Tag, Button, Space, Modal, Form, Input, InputNumber, Select, Popconfirm, message } from "antd";
import type { TableProps } from "antd";
import { PlusOutlined } from "@ant-design/icons";
import { useMemo, useState } from "react";

type Order = {
  key: string;
  orderNo: string;
  user: string;
  total: number;
  status: "paid" | "pending" | "cancelled";
};

const initialData: Order[] = [
  { key: "o1", orderNo: "EC-1001", user: "Ali Yılmaz",  total: 1299, status: "paid" },
  { key: "o2", orderNo: "EC-1002", user: "Ayşe Kaya",   total: 799,  status: "pending" },
  { key: "o3", orderNo: "EC-1003", user: "Mehmet Demir", total: 2499, status: "cancelled" },
];

export default function OrdersPage() {
  const [data, setData] = useState<Order[]>(initialData);
  const [page, setPage] = useState({ current: 1, pageSize: 10 });
  const [sorter, setSorter] = useState<{ field?: string; order?: "ascend" | "descend" }>({});
  const [statusFilter, setStatusFilter] = useState<("paid"|"pending"|"cancelled")[]>([]);
  const [search, setSearch] = useState("");
  const [modalOpen, setModalOpen] = useState(false);
  const [editing, setEditing] = useState<Order | null>(null);
  const [form] = Form.useForm<Order>();

  const filtered = useMemo(() => {
    let arr = data.filter(d =>
      d.orderNo.toLowerCase().includes(search.toLowerCase()) ||
      d.user.toLowerCase().includes(search.toLowerCase())
    );
    if (statusFilter.length) {
      arr = arr.filter(d => statusFilter.includes(d.status));
    }
    if (sorter.field === "orderNo") {
      arr = [...arr].sort((a,b) =>
        sorter.order === "ascend" ? a.orderNo.localeCompare(b.orderNo) : b.orderNo.localeCompare(a.orderNo)
      );
    }
    if (sorter.field === "user") {
      arr = [...arr].sort((a,b) =>
        sorter.order === "ascend" ? a.user.localeCompare(b.user) : b.user.localeCompare(a.user)
      );
    }
    if (sorter.field === "total") {
      arr = [...arr].sort((a,b) =>
        sorter.order === "ascend" ? a.total - b.total : b.total - a.total
      );
    }
    return arr;
  }, [data, search, sorter, statusFilter]);

  const columns: TableProps<Order>["columns"] = [
    { title: "Sipariş No", dataIndex: "orderNo", sorter: true, sortOrder: sorter.field==="orderNo"? sorter.order : undefined },
    { title: "Kullanıcı",  dataIndex: "user",    sorter: true, sortOrder: sorter.field==="user"   ? sorter.order : undefined },
    { title: "Tutar (₺)",  dataIndex: "total",   sorter: true, sortOrder: sorter.field==="total"  ? sorter.order : undefined, align: "right",
      render: (v:number)=> v.toLocaleString("tr-TR") },
    { title: "Durum",      dataIndex: "status",  filters: [
        { text: "paid", value: "paid" },
        { text: "pending", value: "pending" },
        { text: "cancelled", value: "cancelled" },
      ],
      onFilter: (value, record) => record.status === value,
      render: (v)=> <Tag color={v==="paid" ? "green" : v==="pending" ? "gold" : "red"}>{v}</Tag>
    },
    { title: "Aksiyon", key: "action", render: (_, rec) => (
        <Space>
          <Button onClick={()=>onEdit(rec)}>Düzenle</Button>
          <Popconfirm title="Silinsin mi?" okText="Evet" cancelText="Vazgeç" onConfirm={()=>onDelete(rec.key)}>
            <Button danger>Sil</Button>
          </Popconfirm>
        </Space>
      )
    }
  ];

  const onTableChange: TableProps<Order>["onChange"] = (pagination, filters, sort) => {
    setPage({ current: pagination.current ?? 1, pageSize: pagination.pageSize ?? 10 });
    if (!Array.isArray(sort)) {
      setSorter({ field: (sort.field as string) ?? undefined, order: sort.order ?? undefined });
    }
    const s = (filters?.status ?? []) as ("paid"|"pending"|"cancelled")[];
    setStatusFilter(s.filter(Boolean));
  };

  const onCreate = () => { setEditing(null); form.resetFields(); setModalOpen(true); };
  const onEdit = (rec: Order) => { setEditing(rec); form.setFieldsValue(rec); setModalOpen(true); };
  const onDelete = (key: string) => { setData(p => p.filter(x => x.key !== key)); message.success("Sipariş silindi"); };

  const onModalOk = async () => {
    const values = await form.validateFields();
    if (editing) {
      setData(prev => prev.map(x => x.key === editing.key ? { ...editing, ...values } : x));
      message.success("Sipariş güncellendi");
    } else {
      const key = "o" + Date.now();
      const orderNo = values.orderNo?.trim() || ("EC-" + Math.floor(1000 + Math.random()*9000));
      setData(prev => [{ key, ...values, orderNo }, ...prev]);
      message.success("Sipariş eklendi");
    }
    setModalOpen(false);
  };

  return (
    <Space direction="vertical" size="large" style={{ width: "100%" }}>
      <Space style={{ justifyContent: "space-between", width: "100%" }}>
        <h2 style={{ margin: 0 }}>Siparişler</h2>
        <Space>
          <Input.Search placeholder="Sipariş no / kullanıcı ara" allowClear onSearch={setSearch} style={{ width: 320 }} />
          <Select
            mode="multiple"
            allowClear
            placeholder="Durum"
            style={{ width: 240 }}
            value={statusFilter}
            onChange={(v)=>setStatusFilter(v as any)}
            options={[
              { value: "paid", label: "paid" },
              { value: "pending", label: "pending" },
              { value: "cancelled", label: "cancelled" },
            ]}
          />
          <Button type="primary" icon={<PlusOutlined />} onClick={onCreate}>Yeni Sipariş</Button>
        </Space>
      </Space>

      <Table<Order>
        rowKey="key"
        dataSource={filtered}
        columns={columns}
        pagination={{ ...page, total: filtered.length, showSizeChanger: true }}
        onChange={onTableChange}
      />

      <Modal
        title={editing ? "Sipariş Düzenle" : "Yeni Sipariş"}
        open={modalOpen}
        onOk={onModalOk}
        onCancel={()=>setModalOpen(false)}
        destroyOnClose
      >
        <Form form={form} layout="vertical" preserve={false}>
          <Form.Item name="orderNo" label="Sipariş No">
            <Input placeholder="Boş bırakılırsa otomatik oluşturulur" />
          </Form.Item>
          <Form.Item name="user" label="Kullanıcı" rules={[{ required: true, message: "Gerekli" }]}>
            <Input />
          </Form.Item>
          <Form.Item name="total" label="Tutar (₺)" rules={[{ required: true }]}>
            <InputNumber min={0} style={{ width: "100%" }} />
          </Form.Item>
          <Form.Item name="status" label="Durum" initialValue="pending">
            <Select
              options={[
                { value: "paid", label: "paid" },
                { value: "pending", label: "pending" },
                { value: "cancelled", label: "cancelled" },
              ]}
            />
          </Form.Item>
        </Form>
      </Modal>
    </Space>
  );
}
'@

$OrdersContent | Out-File -LiteralPath $OrdersPage -Encoding utf8
Write-Host "Orders page yazıldı: $OrdersPage" -ForegroundColor Green

# ---------- USERS ----------
$UsersPage = Join-Path $UsersDir "page.tsx"

if (Test-Path $UsersPage) {
  $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
  Copy-Item $UsersPage "$UsersPage.$stamp.bak" -Force
  Write-Host "Users yedeklendi: $UsersPage.$stamp.bak" -ForegroundColor Yellow
}

$UsersContent = @'
'use client';

import { Table, Tag, Button, Space, Modal, Form, Input, Select, Popconfirm, message } from "antd";
import type { TableProps } from "antd";
import { PlusOutlined } from "@ant-design/icons";
import { useMemo, useState } from "react";

type User = {
  key: string;
  name: string;
  email: string;
  role: "admin" | "editor" | "viewer";
};

const initialData: User[] = [
  { key: "u1", name: "Ali Yılmaz",  email: "ali@example.com",  role: "admin" },
  { key: "u2", name: "Ayşe Kaya",   email: "ayse@example.com", role: "editor" },
  { key: "u3", name: "Mehmet Demir", email: "mehmet@example.com", role: "viewer" },
];

export default function UsersPage() {
  const [data, setData] = useState<User[]>(initialData);
  const [page, setPage]   = useState({ current: 1, pageSize: 10 });
  const [sorter, setSorter] = useState<{ field?: string; order?: "ascend" | "descend" }>({});
  const [roleFilter, setRoleFilter] = useState<("admin"|"editor"|"viewer")[]>([]);
  const [search, setSearch] = useState("");
  const [modalOpen, setModalOpen] = useState(false);
  const [editing, setEditing] = useState<User | null>(null);
  const [form] = Form.useForm<User>();

  const filtered = useMemo(() => {
    let arr = data.filter(d =>
      d.name.toLowerCase().includes(search.toLowerCase()) ||
      d.email.toLowerCase().includes(search.toLowerCase())
    );
    if (roleFilter.length) {
      arr = arr.filter(d => roleFilter.includes(d.role));
    }
    if (sorter.field === "name") {
      arr = [...arr].sort((a,b) =>
        sorter.order === "ascend" ? a.name.localeCompare(b.name) : b.name.localeCompare(a.name)
      );
    }
    if (sorter.field === "email") {
      arr = [...arr].sort((a,b) =>
        sorter.order === "ascend" ? a.email.localeCompare(b.email) : b.email.localeCompare(a.email)
      );
    }
    return arr;
  }, [data, search, sorter, roleFilter]);

  const columns: TableProps<User>["columns"] = [
    { title: "Ad Soyad", dataIndex: "name", sorter: true, sortOrder: sorter.field==="name"? sorter.order : undefined },
    { title: "E-posta",  dataIndex: "email", sorter: true, sortOrder: sorter.field==="email"? sorter.order : undefined },
    { title: "Rol",      dataIndex: "role",
      filters: [
        { text: "admin", value: "admin" },
        { text: "editor", value: "editor" },
        { text: "viewer", value: "viewer" },
      ],
      onFilter: (value, record) => record.role === value,
      render: (v)=> <Tag color={v==="admin" ? "geekblue" : v==="editor" ? "purple" : "default"}>{v}</Tag>
    },
    { title: "Aksiyon", key: "action", render: (_, rec) => (
        <Space>
          <Button onClick={()=>onEdit(rec)}>Düzenle</Button>
          <Popconfirm title="Silinsin mi?" okText="Evet" cancelText="Vazgeç" onConfirm={()=>onDelete(rec.key)}>
            <Button danger>Sil</Button>
          </Popconfirm>
        </Space>
      )
    }
  ];

  const onTableChange: TableProps<User>["onChange"] = (pagination, filters, sort) => {
    setPage({ current: pagination.current ?? 1, pageSize: pagination.pageSize ?? 10 });
    if (!Array.isArray(sort)) {
      setSorter({ field: (sort.field as string) ?? undefined, order: sort.order ?? undefined });
    }
    const r = (filters?.role ?? []) as ("admin"|"editor"|"viewer")[];
    setRoleFilter(r.filter(Boolean));
  };

  const onCreate = () => { setEditing(null); form.resetFields(); setModalOpen(true); };
  const onEdit = (rec: User) => { setEditing(rec); form.setFieldsValue(rec); setModalOpen(true); };
  const onDelete = (key: string) => { setData(p => p.filter(x => x.key !== key)); message.success("Kullanıcı silindi"); };

  const onModalOk = async () => {
    const values = await form.validateFields();
    if (editing) {
      setData(prev => prev.map(x => x.key === editing.key ? { ...editing, ...values } : x));
      message.success("Kullanıcı güncellendi");
    } else {
      const key = "u" + Date.now();
      setData(prev => [{ key, ...values }, ...prev]);
      message.success("Kullanıcı eklendi");
    }
    setModalOpen(false);
  };

  return (
    <Space direction="vertical" size="large" style={{ width: "100%" }}>
      <Space style={{ justifyContent: "space-between", width: "100%" }}>
        <h2 style={{ margin: 0 }}>Kullanıcılar</h2>
        <Space>
          <Input.Search placeholder="İsim/e-posta ara" allowClear onSearch={setSearch} style={{ width: 320 }} />
          <Select
            mode="multiple"
            allowClear
            placeholder="Rol"
            style={{ width: 240 }}
            value={roleFilter}
            onChange={(v)=>setRoleFilter(v as any)}
            options={[
              { value: "admin", label: "admin" },
              { value: "editor", label: "editor" },
              { value: "viewer", label: "viewer" },
            ]}
          />
          <Button type="primary" icon={<PlusOutlined />} onClick={onCreate}>Yeni Kullanıcı</Button>
        </Space>
      </Space>

      <Table<User>
        rowKey="key"
        dataSource={filtered}
        columns={columns}
        pagination={{ ...page, total: filtered.length, showSizeChanger: true }}
        onChange={onTableChange}
      />

      <Modal
        title={editing ? "Kullanıcı Düzenle" : "Yeni Kullanıcı"}
        open={modalOpen}
        onOk={onModalOk}
        onCancel={()=>setModalOpen(false)}
        destroyOnClose
      >
        <Form form={form} layout="vertical" preserve={false}>
          <Form.Item name="name" label="Ad Soyad" rules={[{ required: true, message: "Gerekli" }]}>
            <Input />
          </Form.Item>
          <Form.Item name="email" label="E-posta" rules={[{ required: true, type: "email", message: "Geçerli e-posta girin" }]}>
            <Input />
          </Form.Item>
          <Form.Item name="role" label="Rol" initialValue="viewer">
            <Select options={[
              { value: "admin", label: "admin" },
              { value: "editor", label: "editor" },
              { value: "viewer", label: "viewer" },
            ]}/>
          </Form.Item>
        </Form>
      </Modal>
    </Space>
  );
}
'@

$UsersContent | Out-File -LiteralPath $UsersPage -Encoding utf8
Write-Host "Users page yazıldı: $UsersPage" -ForegroundColor Green

Write-Host "`n==== Bitti! ====" -ForegroundColor Green
Write-Host "Routes: /orders ve /users hazır (panel shell altında)."
