'use client';
import React, { useMemo } from "react";
import Link from "next/link";
import { Layout, Menu, theme } from "antd";
import { AppstoreOutlined, ShoppingCartOutlined, UserOutlined } from "@ant-design/icons";
const { Header, Sider, Content } = Layout;

const items = [
  { key: "/products", icon: <AppstoreOutlined />, label: <Link href="/products">Ürünler</Link> },
  { key: "/orders",   icon: <ShoppingCartOutlined />, label: <Link href="/orders">Siparişler</Link> },
  { key: "/users",    icon: <UserOutlined />, label: <Link href="/users">Kullanıcılar</Link> },
];

export default function PanelLayout({ children }: { children: React.ReactNode }) {
  const { token: { colorBgContainer, borderRadiusLG } } = theme.useToken();

  const selected = useMemo(() => {
    if (typeof window === "undefined") return ["/products"];
    const path = window.location.pathname;
    const hit = items.find(i => path.startsWith(i.key));
    return [hit?.key ?? "/products"];
  }, []);

  return (
    <Layout style={{ minHeight: "100vh" }}>
      <Sider breakpoint="lg" collapsedWidth={64}>
        <div style={{ color: "white", padding: 16, fontWeight: 600 }}>Admin</div>
        <Menu theme="dark" mode="inline" items={items} selectedKeys={selected} />
      </Sider>
      <Layout>
        <Header style={{ background: colorBgContainer, padding: "0 16px" }}>
          <div style={{ fontWeight: 600 }}>Enucuz.kim Yönetim</div>
        </Header>
        <Content style={{ margin: 16 }}>
          <div style={{ padding: 16, background: colorBgContainer, borderRadius: borderRadiusLG }}>
            {children}
          </div>
        </Content>
      </Layout>
    </Layout>
  );
}
