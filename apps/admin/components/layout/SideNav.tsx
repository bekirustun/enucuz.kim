"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Layout, Menu } from "antd";
import { nav } from "@/config/nav.schema";
import { features } from "@/config/feature-flags";
import { AntIcon } from "@/components/common/Icon";

function get(obj: any, path?: string) {
  if (!path) return true;
  return path.split(".").reduce((acc, k) => (acc ? acc[k] : undefined), obj);
}

// TODO: gerçek izinleri bağlayın; şimdilik tüm izinler açık gibi davranıyoruz.
const hasPerm = (_need?: string[]) => true;

export default function SideNav() {
  const pathname = usePathname();

  const items = nav
    .filter(i => get(features, i.featurePath) && hasPerm(i.permissions))
    .map(it => ({
      key: it.key,
      icon: it.icon ? <AntIcon name={it.icon} /> : undefined,
      label: it.href ? <Link href={it.href}>{it.label}</Link> : it.label,
    }));

  // aktif menüyü URL başlangıcına göre tahmin et
  const selected = items.find(i => {
    const original = nav.find(n => n.key === i.key);
    return original?.href && pathname?.startsWith(original.href);
  })?.key;

  return (
    <Layout.Sider breakpoint="lg" collapsedWidth={64}>
      <div style={{ color: "#fff", padding: 16, fontWeight: 600 }}>enucuz.kim</div>
      <Menu
        theme="dark"
        mode="inline"
        selectedKeys={selected ? [selected] : []}
        items={items}
      />
    </Layout.Sider>
  );
}
