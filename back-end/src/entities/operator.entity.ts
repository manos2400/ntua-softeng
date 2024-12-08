import {BaseEntity, Column, Entity, OneToMany, OneToOne, PrimaryColumn} from "typeorm";

import { Station } from "./station.entity";
import {Tag} from "./tag.entity";
import {User} from "./user.entity";

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

    @OneToOne(() => User, user => user.operator)
    user: User;
}