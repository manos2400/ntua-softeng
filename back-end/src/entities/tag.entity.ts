import {BaseEntity, Entity, ManyToOne, OneToMany, PrimaryColumn} from "typeorm";
import { Pass } from "./pass.entity";
import { Operator } from "./operator.entity";

@Entity()
export class Tag extends BaseEntity {
    @PrimaryColumn()
    id: string;

    @ManyToOne(() => Operator, operator => operator.tags)
    operator: Operator;

    @OneToMany(() => Pass, pass => pass.tag)
    passes: Pass[];
}
