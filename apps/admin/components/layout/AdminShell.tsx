"use client";
import { Layout, ConfigProvider, theme } from "antd";
import { ReactNode } from "react";
import SideNav from "./SideNav";

export default function AdminShell({ children }: { children: ReactNode }) {
  return (
    <ConfigProvider theme={{ algorithm: theme.defaultAlgorithm }}>
      <Layout style={{ minHeight: "100vh" }}>
        <SideNav />
        <Layout>
          <Layout.Header style={{ color:"#fff", fontWeight:600 }}>Admin</Layout.Header>
          <Layout.Content style={{ padding: 24 }}>{children}</Layout.Content>
        </Layout>
      </Layout>
    </ConfigProvider>
  );
}
