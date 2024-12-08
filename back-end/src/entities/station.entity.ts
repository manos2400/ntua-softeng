import {BaseEntity, Column, Entity, ManyToOne, OneToMany, PrimaryColumn} from "typeorm";
import { Pass}  from "./pass.entity";
import {Operator} from "./operator.entity";

@Entity()
export class Station extends BaseEntity {
    @PrimaryColumn({ type: 'varchar', length: 5 })
    id: string;

    @Column()
    name: string;

    @Column()
    locality: string;

    @Column({ type: 'float' })
    latitude: number;

    @Column({ type: 'float' })
    longitude: number;

    @Column({ type: 'float' })
    price1: number;

    @Column({ type: 'float' })
    price2: number;

    @Column({ type: 'float' })
    price3: number;

    @Column({ type: 'float' })
    price4: number;

    @ManyToOne(() => Operator, operator => operator.stations)
    operator: Operator;

    @OneToMany(() => Pass, pass => pass.station)
    passes: Pass[];
}