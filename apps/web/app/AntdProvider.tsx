"use client";
import React from "react";
import { ConfigProvider, App as AntApp } from "antd";
import { StyleProvider } from "@ant-design/cssinjs";
export default function AntdProvider({ children }: { children: React.ReactNode }) {
  return (
    <StyleProvider hashPriority="high">
      <ConfigProvider>
        <AntApp>{children}</AntApp>
      </ConfigProvider>
    </StyleProvider>
  );
}
