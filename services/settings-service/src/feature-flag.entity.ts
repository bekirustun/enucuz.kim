import { Column, Entity, PrimaryGeneratedColumn, Index } from "typeorm";

@Entity("feature_flags")
export class FeatureFlag {
  @PrimaryGeneratedColumn()
  id!: number;

  @Index({ unique: true })
  @Column({ type: "varchar", length: 160 })
  key!: string;

  @Column({ type: "varchar", length: 160 })
  name!: string;

  @Column({ type: "boolean", default: false })
  enabled!: boolean;

  @Column({ type: "varchar", length: 160, nullable: true })
  parentKey!: string | null;

  @Column({ type: "jsonb", nullable: true })
  meta!: Record<string, any> | null;
}
