import "./globals.css";
import "antd/dist/reset.css";
import { ReactNode } from "react";

export const metadata = { title: "Admin", description: "enucuz.kim admin" };

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="tr">
      <body>{children}</body>
    </html>
  );
}
