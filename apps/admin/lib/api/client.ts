export const API_BASE = process.env.NEXT_PUBLIC_GATEWAY_URL || "http://localhost:3015";
export async function apiGet<T>(path:string):Promise<T>{
  const r = await fetch(`${API_BASE}${path}`, { cache: "no-store", credentials: "include" });
  if(!r.ok) throw new Error(`${r.status} ${r.statusText}`);
  return r.json();
}
export async function apiPost<T>(path:string, body:any):Promise<T>{
  const r = await fetch(`${API_BASE}${path}`, {
    method:"POST",
    headers:{ "Content-Type":"application/json" },
    body: JSON.stringify(body), credentials:"include"
  });
  if(!r.ok) throw new Error(`${r.status} ${r.statusText}`);
  return r.json();
}
