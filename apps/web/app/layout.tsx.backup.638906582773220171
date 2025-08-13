import type { Metadata } from "next";
import AntdProvider from "./AntdProvider";
export const metadata: Metadata = { title: "Enucuz.kim", description: "Web" };
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="tr">
      <body>
        <AntdProvider>{children}</AntdProvider>
      </body>
    </html>
  );
}
