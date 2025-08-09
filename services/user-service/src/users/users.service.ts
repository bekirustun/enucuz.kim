import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { User } from './entities/user.entity';

@Injectable()
export class UsersService {
  private seq = 2;
  private readonly users = new Map<number, User>([
    [1, { id: 1, name: 'Ada Lovelace', email: 'ada@example.com', role: 'admin', createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() }],
    [2, { id: 2, name: 'Alan Turing',  email: 'alan@example.com', role: 'user',  createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() }],
  ]);

  health() {
    return { ok: true, service: 'user-service', ts: new Date().toISOString() };
  }

  findAll(): User[] {
    return Array.from(this.users.values());
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
