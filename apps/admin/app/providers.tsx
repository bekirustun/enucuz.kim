"use client";
import { ReactNode } from "react";
import { ConfigProvider, theme } from "antd";
export default function Providers({ children }: { children: ReactNode }) {
  return (
    <ConfigProvider theme={{ algorithm: theme.defaultAlgorithm }}>
      {children}
    </ConfigProvider>
  );
}
