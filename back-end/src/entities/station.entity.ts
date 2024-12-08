import {BaseEntity, Column, Entity, ManyToOne, OneToMany, PrimaryGeneratedColumn} from "typeorm";
import { Pass}  from "./pass.entity";
import {Operator} from "./operator.entity";

@Entity()
export class Station extends BaseEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @ManyToOne(() => Operator, operator => operator.stations)
  operator: Operator;

  @OneToMany(() => Pass, pass => pass.station)
  passes: Pass[];
}