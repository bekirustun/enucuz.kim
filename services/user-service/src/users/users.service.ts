import { Injectable } from "@nestjs/common";

type User = { id: number; name: string; email?: string };

@Injectable()
export class UsersService {
  private data: User[] = [
    { id: 1, name: "Ali", email: "ali@example.com" },
    { id: 2, name: "Veli", email: "veli@example.com" }
  ];

  list() { return this.data; }
  get(id: string) { return this.data.find(u => u.id === Number(id)) ?? null; }
  create(dto: Partial<User>) {
    const id = (this.data.at(-1)?.id ?? 0) + 1;
    const item = { id, name: dto.name ?? `User ${id}`, email: dto.email };
    this.data.push(item); return item;
  }
  update(id: string, dto: Partial<User>) {
    const idx = this.data.findIndex(u => u.id === Number(id));
    if (idx === -1) return null;
    this.data[idx] = { ...this.data[idx], ...dto, id: Number(id) };
    return this.data[idx];
  }
  remove(id: string) {
    const idx = this.data.findIndex(u => u.id === Number(id));
    if (idx === -1) return { deleted: 0 };
    this.data.splice(idx, 1); return { deleted: 1 };
  }
}
