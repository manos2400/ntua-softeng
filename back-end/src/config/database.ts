import { DataSource } from "typeorm";

import { Operator } from "../entities/operator.entity";
import { Pass } from "../entities/pass.entity";
import { Station } from "../entities/station.entity";
import { Tag } from "../entities/tag.entity";
import { User } from "../entities/user.entity";

export const dataSource = new DataSource({
    type: "postgres",
    host: "localhost",
    port: 5432,
    username: "softeng",
    password: "softeng2024",
    database: "tolls",
    entities: [Operator, Pass, Station, Tag, User],
    synchronize: true,
});