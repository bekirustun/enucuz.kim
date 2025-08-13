export type Permission = string; // "users.read" gibi
export type Session = { user?: { id:string; role?: string; permissions?: Permission[] } } | null;

export function can(perm: Permission, session?: Session): boolean {
  if (!session?.user) return false;
  const list = session.user.permissions ?? [];
  return list.includes(perm);
}
