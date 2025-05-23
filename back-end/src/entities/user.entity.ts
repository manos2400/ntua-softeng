import {BaseEntity, Column, Entity} from "typeorm";
import { PrimaryGeneratedColumn } from "typeorm";

@Entity()
export class User extends BaseEntity {
    @PrimaryGeneratedColumn()
    id: number;

    @Column({
        unique: true
    })
    username: string;

    @Column()
    password: string;

    @Column()
    isAdmin: boolean;
}