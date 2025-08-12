/**
 * Nav öğesi şeması:
 * - key: benzersiz anahtar
 * - label: görünen ad
 * - href: tıklandığında gidilecek URL (opsiyonel; yoksa başlık gibi davranır)
 * - icon: AntD ikon adı (örn: "DashboardOutlined")
 * - featurePath: features objesinde ilgili özelliğin yolu (örn: "admin.dashboard.enabled")
 * - permissions: ileride gerçek yetkilendirme için alan (şimdilik opsiyonel)
 */
export type NavItem = {
  key: string;
  label: string;
  href?: string;
  icon?: string;
  featurePath?: string;
  permissions?: string[];
};

/** Örnek menü */
export const nav: NavItem[] = [
  {
    key: "dashboard",
    label: "Dashboard",
    href: "/dashboard",
    icon: "DashboardOutlined",
    featurePath: "admin.dashboard.enabled",
  },
  {
    key: "settings",
    label: "Ayarlar",
    href: "/settings",
    icon: "SettingOutlined",
    featurePath: "admin.settings.enabled",
  },
  // Genişletme örnekleri:
  {
    key: "products",
    label: "Ürünler",
    href: "/products",
    icon: "ShoppingOutlined",
    featurePath: "admin.products.enabled",
  },
];
