"use client";
import AdminShell from "@/components/layout/AdminShell";
import { Card, Switch, Space, Typography } from "antd";

export default function SettingsPage() {
  return (
    <AdminShell>
      <Space direction="vertical" size="large" style={{ width: "100%" }}>
        <Card title="Genel Ayarlar" bordered>
          <Space align="center">
            <Typography.Text>Dark tema</Typography.Text>
            <Switch />
          </Space>
        </Card>
        <Card title="Kullanıcı Yönetimi" bordered>
          Yakında: roller, izinler, SSO...
        </Card>
      </Space>
    </AdminShell>
  );
}
