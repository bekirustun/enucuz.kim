"use client";
import { Form, Input, InputNumber, Select, Button, Space, Typography, message } from "antd";
import { useRouter } from "next/navigation";

const { Title } = Typography;

export default function ProductEditPage({ params }: { params: { id: string } }) {
  const router = useRouter();
  const [form] = Form.useForm();

  // Mock: sunucudan veri çekiyormuş gibi sahte doldurma
  const preset = { name: "Örnek Ürün " + params.id, sku: "SKU-" + params.id, price: 1499, status: "active" as const };

  const onFinish = async (values:any) => {
    console.log("Update (mock):", params.id, values);
    message.success("Ürün güncellendi (mock)");
    router.push("/admin/products");
  };

  return (
    <div style={{ padding: 20 }}>
      <Space style={{ width:"100%", justifyContent:"space-between", marginBottom:16 }}>
        <Title level={3} style={{ margin:0 }}>Ürün Düzenle #{params.id}</Title>
      </Space>

      <Form form={form} layout="vertical" initialValues={preset} onFinish={onFinish} style={{ maxWidth: 560 }}>
        <Form.Item label="Ürün Adı" name="name" rules={[{ required: true, message: "Zorunlu" }]}><Input /></Form.Item>
        <Form.Item label="SKU" name="sku" rules={[{ required: true, message: "Zorunlu" }]}><Input /></Form.Item>
        <Form.Item label="Fiyat (₺)" name="price" rules={[{ required: true, message: "Zorunlu" }]}><InputNumber min={0} style={{ width:"100%" }} /></Form.Item>
        <Form.Item label="Durum" name="status">
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
          <Button onClick={() => router.back()}>Vazgeç</Button>
        </Space>
      </Form>
    </div>
  );
}
