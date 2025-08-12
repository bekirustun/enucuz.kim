export const API_BASE = process.env.NEXT_PUBLIC_GATEWAY_URL || "http://localhost:3015";
export async function apiGet<T>(path: string): Promise<T> {
  const r = await fetch(`${API_BASE}${path}`, { credentials:"include" });
  if (!r.ok) throw new Error(`${r.status} ${r.statusText}`);
  return r.json();
}
