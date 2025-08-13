export const features = {
  products: { enabled: true, variants: true, bulkImport: false, priceRules: true },
  affiliates:{ enabled: true, sources: ["hepsiburada","trendyol","amazon"], autoLinking: true },
  content:  { enabled: true, menus: true, pages: true, banners: true },
  seo:      { enabled: true, structuredData: true, redirects: true }
} as const;

export function getFlag(path: string): boolean {
  const parts = path.split(".");
  // @ts-ignore
  let cur:any = features;
  for (const p of parts) { cur = cur?.[p]; if (cur === undefined) return false; }
  return Boolean(cur);
}
