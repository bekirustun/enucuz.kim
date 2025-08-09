import '../styles/globals.css';
import { ReactNode } from 'react';

export const metadata = {
  title: 'Enucuz.kim - En İyi Fiyat Karşılaştırma',
  description: 'Aynı ürünü en ucuz kim satıyor, bul! AI destekli, hızlı ve güvenilir alışveriş rehberi.',
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang='tr'>
      <body>
        {/* Global layout (Navbar, Footer vs.) ekleyebilirsin */}
        {children}
      </body>
    </html>
  );
}
