import {Entity, PrimaryGeneratedColumn, Column, ManyToOne, BaseEntity} from 'typeorm';
import {Station} from "./station.entity";
import {Tag} from "./tag.entity";

@Entity()
export class Pass extends BaseEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'float' })
  charge: number;

  @Column()
  timestamp: Date;

  @Column()
  paid: boolean;

  @ManyToOne(() => Station, station => station.passes)
  station: Station;

  @ManyToOne(() => Tag, tag => tag.passes)
  tag: Tag;
}