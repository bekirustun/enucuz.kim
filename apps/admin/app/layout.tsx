'use client';

import 'antd/dist/reset.css';
import { ConfigProvider, App as AntApp } from 'antd';
import React from 'react';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="tr">
      <body>
        <ConfigProvider>
          <AntApp>{children}</AntApp>
        </ConfigProvider>
      </body>
    </html>
  );
}
