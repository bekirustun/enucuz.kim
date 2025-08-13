import { NextResponse } from "next/server";
export const runtime = "nodejs";
export const dynamic = "force-dynamic";

const ORIGIN = "http://localhost:3006/api/admin/settings/features";

function toFeatures(payload: any): any[] {
  if (!payload) return [];
  if (Array.isArray(payload)) return payload;
  if (Array.isArray(payload.features)) return payload.features;
  if (Array.isArray(payload.items)) return payload.items;
  if (payload.key) return [payload];
  return [];
}

export async function GET() {
  try {
    const res = await fetch(ORIGIN, { cache: "no-store" });
    const data = await res.json();
    return NextResponse.json(data, { headers: { "Cache-Control": "no-store" } });
  } catch (e: any) {
    return NextResponse.json({ ok: false, error: e?.message ?? "fetch-failed" }, { status: 500 });
  }
}

export async function POST(req: Request) {
  try {
    const incoming = await req.json().catch(() => ({}));
    const features = toFeatures(incoming);

    const upstream = await fetch(ORIGIN, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ features }),
    });

    const ct = upstream.headers.get("content-type") || "";
    const text = await upstream.text();
    let data: any;
    try { data = ct.includes("application/json") ? JSON.parse(text) : { ok: upstream.ok, text }; }
    catch { data = { ok: upstream.ok, text }; }

    if (!upstream.ok) {
      return NextResponse.json({ ok: false, status: upstream.status, upstream: data }, { status: 500 });
    }
    return NextResponse.json({ ok: true, forwarded: { count: features.length }, upstream: data });
  } catch (e: any) {
    return NextResponse.json({ ok: false, error: e?.message ?? "post-failed" }, { status: 500 });
  }
}
