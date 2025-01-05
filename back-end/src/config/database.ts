import { DataSource } from "typeorm";

import { Operator } from "../entities/operator.entity";
import { Pass } from "../entities/pass.entity";
import { Station } from "../entities/station.entity";
import { Tag } from "../entities/tag.entity";
import { User } from "../entities/user.entity";

export const dataSource = new DataSource({
    type: "postgres",
    host: process.env.DB_HOST || "localhost",
    port: 5432,
    username: process.env.DB_USER || "softeng",
    password: process.env.DB_PASS || "softeng2024",
    database: process.env.DB_NAME || "tolls",
    entities: [Operator, Pass, Station, Tag, User],
    synchronize: true,
});