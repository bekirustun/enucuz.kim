# scripts\fix-user-service-quotes.ps1
$BaseDir = "D:\U\S\enucuz.kim\services\user-service\src\user"
$File    = Join-Path $BaseDir "user.service.ts"

@'
import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { ListUsersDto } from './dto/list-users.dto';
import { User } from './entities/user.entity';

type Order = 'asc' | 'desc';

@Injectable()
export class UserService {
  private seq = 2;
  private readonly users = new Map<number, User>([
    [1, { id: 1, name: 'Ada Lovelace', email: 'ada@example.com',  role: 'admin', createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() }],
    [2, { id: 2, name: 'Alan Turing',  email: 'alan@example.com', role: 'user',  createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() }],
  ]);

  health() {
    return { ok: true, service: 'user-service', ts: new Date().toISOString() };
  }

  findAll(): User[] {
    const { items } = this.list({ page: 1, pageSize: 1000, sortBy: 'createdAt', order: 'desc' });
    return items;
  }

  list(query: ListUsersDto) {
    const page     = query.page     ?? 1;
    const pageSize = query.pageSize ?? 10;
    const sortBy   = query.sortBy   ?? 'createdAt';
    const order    = ((query.order ?? 'desc').toLowerCase() as Order);
    const q        = (query.q ?? '').toLowerCase().trim();
    const role     = query.role?.trim();

    let arr = Array.from(this.users.values());

    if (role) arr = arr.filter(u => (u.role ?? '').toLowerCase() === role.toLowerCase());
    if (q) {
      arr = arr.filter(u =>
        (u.name  ?? '').toLowerCase().includes(q) ||
        (u.email ?? '').toLowerCase().includes(q)
      );
    }

    const norm = (v: any) => (v == null ? '' : typeof v === 'number' ? v : String(v).toLowerCase());
    arr.sort((a, b) => {
      const av: any = (a as any)[sortBy];
      const bv: any = (b as any)[sortBy];
      if (av === bv) return 0;
      const na = norm(av), nb = norm(bv);
      return na < nb ? -1 : 1;
    });
    if (order === 'desc') arr.reverse();

    const total = arr.length;
    const totalPages = Math.max(1, Math.ceil(total / pageSize));
    const start = (page - 1) * pageSize;
    const items = arr.slice(start, start + pageSize);

    return { page, pageSize, total, totalPages, sortBy, order, items };
  }

  findOne(id: number): User {
    const u = this.users.get(id);
    if (!u) throw new NotFoundException(`User ${id} not found`);
    return u;
  }

  create(dto: CreateUserDto): User {
    const id = ++this.seq;
    const now = new Date().toISOString();
    const u: User = { id, createdAt: now, updatedAt: now, ...dto };
    this.users.set(id, u);
    return u;
  }

  update(id: number, dto: UpdateUserDto): User {
    const u = this.findOne(id);
    const merged: User = { ...u, ...dto, updatedAt: new Date().toISOString() };
    this.users.set(id, merged);
    return merged;
  }

  remove(id: number): { deleted: boolean } {
    const ok = this.users.delete(id);
    if (!ok) throw new NotFoundException(`User ${id} not found`);
    return { deleted: true };
  }
}
'@ | Set-Content $File -Encoding UTF8

Write-Host "user.service.ts düzeltildi." -ForegroundColor Green
