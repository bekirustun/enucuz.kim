"use client";
import * as Icons from "@ant-design/icons";

export function AntIcon({ name, className }: { name?: string; className?: string }) {
  if (!name) return null;
  const Cmp = (Icons as any)[name];
  return Cmp ? <Cmp className={className} /> : null;
}
