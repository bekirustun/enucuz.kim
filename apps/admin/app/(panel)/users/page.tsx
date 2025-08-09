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
