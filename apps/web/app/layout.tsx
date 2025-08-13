import "./globals.css";
import { ReactNode } from "react";

export const metadata = { title: "enucuz.kim", description: "Ürün karşılaştırma" };

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="tr">
      <body>{children}</body>
    </html>
  );
}
