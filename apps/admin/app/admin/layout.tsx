"use client";

import "antd/dist/reset.css";
import React, { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Layout, Menu, Button, Space, Typography } from "antd";
import {
  AppstoreOutlined,
  DashboardOutlined,
  FlagOutlined,
  MenuFoldOutlined,
  MenuUnfoldOutlined,
} from "@ant-design/icons";

const { Header, Sider, Content } = Layout;

type Flag = {
  id: number;
  key: string;
  name: string;
  enabled: boolean;
  parentKey?: string | null;
  meta?: any | null;
  subFeatures?: Flag[];
};

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname() || "/admin";
  const [collapsed, setCollapsed] = useState(false);
  const [roots, setRoots] = useState<Flag[]>([]);

  // Dinamik menü verisi
  useEffect(() => {
    (async () => {
      try {
        const res = await fetch("/api/feature-flags", { cache: "no-store" });
        const data: Flag[] = await res.json();
        setRoots(Array.isArray(data) ? data : []);
      } catch {
        setRoots([]);
      }
    })();
  }, []);

  // Dinamik menü öğeleri
  const dynamicMenus = useMemo(() => {
    const items: any[] = [];
    for (const root of roots) {
      const children = (root.subFeatures ?? [])
        .filter(sf => sf.enabled && (sf?.meta?.menu !== false))
        .map(sf => {
          const href = `/admin/features/${encodeURIComponent(sf.key)}`;
          return { key: href, label: <Link href={href}>{sf.name}</Link> };
        });
      if (children.length > 0) {
        items.push({
          key: `sec:${root.key}`,
          icon: <AppstoreOutlined />,
          label: root.name,
          children,
        });
      }
    }
    return items;
  }, [roots]);

  // Statik menüler
  const staticMenus = useMemo(() => ([
    { key: "/admin", label: <Link href="/admin">Dashboard</Link>, icon: <DashboardOutlined /> },
    { key: "/admin/feature-flags", label: <Link href="/admin/feature-flags">Feature Flags</Link>, icon: <FlagOutlined /> },
  ]), []);

  const menuItems = useMemo(() => [...staticMenus, ...dynamicMenus], [staticMenus, dynamicMenus]);

  // Seçili anahtar
  const selectedKeys = useMemo(() => {
    const flat = menuItems.flatMap((it:any) => it.children ? it.children : [it]);
    const hit = flat.find((it:any) => it.key === pathname);
    if (hit) return [hit.key];
    const cand = ["/admin/feature-flags", "/admin"].find(k => pathname.startsWith(k));
    return [cand ?? "/admin"];
  }, [pathname, menuItems]);

  return (
    <Layout style={{ minHeight: "100vh" }}>
      <Sider collapsible collapsed={collapsed} onCollapse={setCollapsed} width={240}>
        <div style={{ height: 56, display: "flex", alignItems: "center", padding: "0 16px", color: "#fff", fontWeight: 600 }}>
          <AppstoreOutlined style={{ marginRight: 8 }} />
          {!collapsed && <span>Admin</span>}
        </div>
        <Menu theme="dark" mode="inline" selectedKeys={selectedKeys} items={menuItems} />
      </Sider>

      <Layout>
        <Header style={{ background: "#fff", padding: "0 16px", display: "flex", alignItems: "center", gap: 12 }}>
          <Space style={{ flexWrap: "wrap", alignItems: "center" }}>
            <Button
              type="text"
              aria-label="Collapse"
              onClick={() => setCollapsed((c) => !c)}
              icon={collapsed ? <MenuUnfoldOutlined /> : <MenuFoldOutlined />}
            />
            <Typography.Title level={5} style={{ margin: 0 }}>Yönetim Paneli</Typography.Title>
          </Space>

          <Menu mode="horizontal" selectedKeys={selectedKeys} items={menuItems} style={{ borderBottom: "none", marginLeft: 12, flex: 1 }} />
          <Space style={{ color: "#999" }}>admin@example.com</Space>
        </Header>

        <Content style={{ margin: 16 }}>
          <div style={{ background: "#fff", padding: 16, borderRadius: 12, minHeight: "calc(100vh - 56px - 32px)" }}>
            {children}
          </div>
        </Content>
      </Layout>
    </Layout>
  );
}
