import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'users' })
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 50 })
  name: string;

  @Column({ unique: true, length: 100 })
  email: string;

  // Güvenlik için select: false, sorgularda görünmez
  @Column({ select: false })
  password: string;

  // AI veya profil özetleri için ilerde kullanılabilecek örnek alan
  @Column({ nullable: true, length: 255 })
  aiProfileSummary?: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
