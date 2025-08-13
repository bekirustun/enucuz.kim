import { getFlag } from "@/lib/feature-flags";
export function useFeature(path:string){ return getFlag(path); }
