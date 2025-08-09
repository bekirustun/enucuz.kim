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
