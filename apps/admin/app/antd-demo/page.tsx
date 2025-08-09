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
