"use client";
import { Form, Input, InputNumber, Select, Button, Space, Typography, message } from "antd";
import { useRouter } from "next/navigation";
const { Title } = Typography;

export default function ProductNewPage() {
  const [form] = Form.useForm();
  const router = useRouter();

  const onFinish = async (values:any) => {
    console.log("Create (mock):", values);
    message.success("Ürün eklendi (mock)");
    router.push("/admin/products");
  };

  return (
    <div style={{ padding: 20 }}>
      <Space style={{ width:"100%", justifyContent:"space-between", marginBottom:16 }}>
        <Title level={3} style={{ margin:0 }}>Yeni Ürün</Title>
      </Space>

      <Form form={form} layout="vertical" onFinish={onFinish} style={{ maxWidth: 560 }}>
        <Form.Item label="Ürün Adı" name="name" rules={[{ required: true, message: "Zorunlu" }]}>
          <Input placeholder="Örn. AirPods Pro" />
        </Form.Item>
        <Form.Item label="SKU" name="sku" rules={[{ required: true, message: "Zorunlu" }]}>
          <Input placeholder="Örn. AP-PRO-2025" />
        </Form.Item>
        <Form.Item label="Fiyat (₺)" name="price" rules={[{ required: true, message: "Zorunlu" }]}>
          <InputNumber min={0} style={{ width: "100%" }} />
        </Form.Item>
        <Form.Item label="Durum" name="status" initialValue="draft">
          <Select
            options={[
              { value: "active", label: "active" },
              { value: "draft", label: "draft" },
              { value: "archived", label: "archived" },
            ]}
          />
        </Form.Item>
        <Space>
          <Button htmlType="submit" type="primary">Kaydet</Button>
          <Button onClick={() => history.back()}>Vazgeç</Button>
        </Space>
      </Form>
    </div>
  );
}
