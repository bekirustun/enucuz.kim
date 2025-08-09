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
