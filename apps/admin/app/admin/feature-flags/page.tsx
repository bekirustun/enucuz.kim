"use client";

import { useEffect, useMemo, useState } from "react";
import { Table, Switch, message, Typography, Input, Button, Modal, Form, Select } from "antd";

type Flag = {
  id: number;
  key: string;
  name: string;
  enabled: boolean;
  parentKey?: string | null;
  subFeatures?: Flag[];
};

export default function Page() {
  const [rows, setRows] = useState<Flag[]>([]);
  const [loading, setLoading] = useState(false);
  const [pending, setPending] = useState<Record<string, boolean>>({});
  const [q, setQ] = useState("");

  // add modal
  const [open, setOpen] = useState(false);
  const [saving, setSaving] = useState(false);
  const [form] = Form.useForm();

  const fetchFlags = async () => {
    setLoading(true);
    try {
      const res = await fetch("/api/feature-flags", { cache: "no-store" });
      const data: any[] = await res.json();
      const flat = (data?.[0]?.subFeatures ?? []) as Flag[];
      setRows(flat);
    } catch (e) {
      console.error(e);
      message.error("Feature flags yüklenemedi");
    } finally {
      setLoading(false);
    }
  };

  const setPendingKey = (k: string, v: boolean) =>
    setPending((p) => ({ ...p, [k]: v }));

  const toggleFlag = async (record: Flag, checked: boolean) => {
    const k = record.key;
    // optimistic UI
    setPendingKey(k, true);
    setRows((rs) => rs.map((r) => (r.key === k ? { ...r, enabled: checked } : r)));

    try {
      const res = await fetch("/api/feature-flags", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ key: k, enabled: checked }),
      });
      const json = await res.json();
      if (!json?.ok) throw new Error("Sunucu işlemi reddetti");
      message.success(`${record.name} ${checked ? "açıldı" : "kapandı"}`);
      fetchFlags();
    } catch (e) {
      console.error(e);
      message.error("Değişiklik kaydedilemedi");
      setRows((rs) => rs.map((r) => (r.key === k ? { ...r, enabled: !checked } : r)));
    } finally {
      setPendingKey(k, false);
    }
  };

  useEffect(() => { fetchFlags(); }, []);

  const filtered = useMemo(() => {
    const s = q.trim().toLowerCase();
    if (!s) return rows;
    return rows.filter(r =>
      r.key.toLowerCase().includes(s) || r.name.toLowerCase().includes(s)
    );
  }, [rows, q]);

  const columns = useMemo(() => [
    { title: "Anahtar", dataIndex: "key", key: "key", width: 280 },
    { title: "Özellik", dataIndex: "name", key: "name" },
    {
      title: "Durum",
      dataIndex: "enabled",
      key: "enabled",
      width: 160,
      render: (_: any, rec: Flag) => (
        <Switch
          checked={rec.enabled}
          disabled={!!pending[rec.key] || loading}
          onChange={(v) => toggleFlag(rec, v)}
        />
      ),
    },
  ], [pending, loading]);

  // parent seçenekleri (en azından root 'products' + mevcut satırlar)
  const parentOptions = useMemo(() => {
    const set = new Set<string>();
    set.add("products");
    rows.forEach(r => set.add(r.parentKey || "products"));
    return Array.from(set).map(k => ({ label: k, value: k }));
  }, [rows]);

  const onCreate = async () => {
    try {
      const values = await form.validateFields();
      setSaving(true);
      const payload = {
        key: values.key.trim(),
        name: values.name.trim(),
        parentKey: values.parentKey || null,
        enabled: !!values.enabled,
      };
      const res = await fetch("/api/feature-flags", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });
      const json = await res.json();
      if (!json?.ok) throw new Error("Sunucu işlemi reddetti");

      message.success("Özellik kaydedildi");
      setOpen(false);
      form.resetFields();
      fetchFlags();
    } catch (e:any) {
      if (e?.errorFields) return; // validation
      console.error(e);
      message.error("Kayıt başarısız");
    } finally {
      setSaving(false);
    }
  };

  return (
    <div style={{ padding: 20 }}>
      <Typography.Title level={3} style={{ marginBottom: 16 }}>
        Feature Flags
      </Typography.Title>

      <div style={{ display: "flex", gap: 12, alignItems: "center", marginBottom: 12 }}>
        <Input
          value={q}
          onChange={(e) => setQ(e.target.value)}
          placeholder="Ara: anahtar veya isim"
          allowClear
          style={{ maxWidth: 420 }}
        />
        <Button type="primary" onClick={() => setOpen(true)}>
          Yeni Özellik
        </Button>
      </div>

      <Table
        rowKey="key"
        loading={loading}
        dataSource={filtered}
        columns={columns}
        pagination={false}
      />

      <Modal
        title="Yeni Özellik"
        open={open}
        onCancel={() => { if (!saving) { setOpen(false); form.resetFields(); } }}
        onOk={onCreate}
        confirmLoading={saving}
        okText="Kaydet"
        cancelText="Vazgeç"
      >
        <Form form={form} layout="vertical">
          <Form.Item
            label="Anahtar (ör. products.xyz)"
            name="key"
            rules={[
              { required: true, message: "Anahtar zorunlu" },
              { pattern: /^[-a-zA-Z0-9_.]+$/, message: "Sadece harf, rakam, ., _ ve -" },
            ]}
          >
            <Input placeholder="products.new_feature" />
          </Form.Item>

          <Form.Item
            label="İsim"
            name="name"
            rules={[{ required: true, message: "İsim zorunlu" }]}
          >
            <Input placeholder="Özellik adı" />
          </Form.Item>

          <Form.Item label="Üst Özellik (parentKey)" name="parentKey" initialValue="products">
            <Select
              options={[{ label: "(Yok)", value: "" }, ...parentOptions]}
              showSearch
              allowClear
              placeholder="Seçiniz"
            />
          </Form.Item>

          <Form.Item label="Durum" name="enabled" valuePropName="checked" initialValue={true}>
            <Switch />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
}
