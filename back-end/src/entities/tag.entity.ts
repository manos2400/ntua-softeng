import {BaseEntity, Entity, ManyToOne, OneToMany} from "typeorm";
import { PrimaryGeneratedColumn } from "typeorm";
import { Pass } from "./pass.entity";
import { Operator } from "./operator.entity";

@Entity()
export class Tag extends BaseEntity {
    @PrimaryGeneratedColumn()
    id: number;

    @ManyToOne(() => Operator, operator => operator.tags)
    operator: Operator;

    @OneToMany(() => Pass, pass => pass.tag)
    passes: Pass[];
}
