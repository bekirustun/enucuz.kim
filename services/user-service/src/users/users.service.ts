import { Injectable } from '@nestjs/common';

@Injectable()
export class UsersService {
  health() {
    return { ok: true, service: 'user-service', ts: new Date().toISOString() };
  }

  list() {
    return [
      { id: 1, name: 'Ada Lovelace' },
      { id: 2, name: 'Alan Turing' },
    ];
  }
}
