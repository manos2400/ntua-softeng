import {BaseEntity, Column, Entity, OneToOne} from "typeorm";
import { PrimaryGeneratedColumn } from "typeorm";
import {Operator} from "./operator.entity";

@Entity()
export class User extends BaseEntity {
    @PrimaryGeneratedColumn()
    id: number;

    @Column()
    username: string;

    @Column()
    password: string;

    @Column()
    isAdmin: boolean;

    @OneToOne(() => Operator, operator => operator.user)
    operator: Operator;
}