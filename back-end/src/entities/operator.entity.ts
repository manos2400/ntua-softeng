import {BaseEntity, Column, Entity, OneToMany, OneToOne, PrimaryGeneratedColumn} from "typeorm";

import { Station } from "./station.entity";
import {Tag} from "./tag.entity";
import {User} from "./user.entity";

@Entity()
export class Operator extends BaseEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @OneToMany(() => Station, station => station.operator)
  stations: Station[];

  @OneToMany(() => Tag, tag => tag.operator)
  tags: Tag[];

  @OneToOne(() => User, user => user.operator)
  user: User;
}