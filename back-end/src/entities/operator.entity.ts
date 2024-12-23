import {BaseEntity, Column, Entity, OneToMany, PrimaryColumn} from "typeorm";

import { Station } from "./station.entity";
import {Tag} from "./tag.entity";

@Entity()
export class Operator extends BaseEntity {
    @PrimaryColumn({ type: 'varchar', length: 5 })
    id: string;

    @Column()
    name: string;

    @Column()
    road: string;

    @Column()
    email: string;

    @OneToMany(() => Station, station => station.operator)
    stations: Station[];

    @OneToMany(() => Tag, tag => tag.operator)
    tags: Tag[];
}