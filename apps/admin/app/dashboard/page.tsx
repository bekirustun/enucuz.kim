"use client";
import AdminShell from "@/components/layout/AdminShell";
import { Card } from "antd";

export default function DashboardPage() {
  return (
    <AdminShell>
      <Card title="Dashboard" bordered>
        Hoş geldin! Burası yönetici özet alanı. KPI ve widget'lar için hazır.
      </Card>
    </AdminShell>
  );
}
