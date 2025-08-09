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
