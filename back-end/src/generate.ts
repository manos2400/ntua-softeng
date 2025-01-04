import { Station } from "./entities/station.entity";
import { Tag } from "./entities/tag.entity";
import { Pass } from "./entities/pass.entity";
import * as fs from 'fs';
import {dataSource} from "./config/database";

export const generatePasses = async (stations: Station[], tags: Tag[], count: number): Promise<void> => {
    // Generate passes
    let passCSV = 'timestamp,tollID,tagRef,tagHomeID,charge\n';
    for (let i = 0; i < count; i++) {
        const station = stations[Math.floor(Math.random() * stations.length)];
        const tag = tags[Math.floor(Math.random() * tags.length)];

        const pass = new Pass();
        pass.tag = tag;
        pass.station = station;
        const i = Math.floor(Math.random() * 4) + 1;
        switch (i) {
            case 1:
                pass.charge = station.price1;
                break;
            case 2:
                pass.charge = station.price2;
                break;
            case 3:
                pass.charge = station.price3;
                break;
            case 4:
                pass.charge = station.price4;
                break;
        }
        pass.paid = tag.operator.id === station.operator.id;
        // random date in the last 3 months
        pass.timestamp = new Date(Date.now() - Math.floor(Math.random() * 1000 * 60 * 60 * 24 * 30 * 3));

        passCSV += `${pass.timestamp.toISOString()},${station.id},${tag.id},${tag.operator.id},${pass.charge}\n`;
    }

    // Write to file
    fs.writeFileSync(__dirname + '/data/passes.csv', passCSV);
}

dataSource.initialize().then(() => {
    const stations = Station.find({
        relations: ['operator']
    });
    const tags = Tag.find({
        relations: ['operator']
    });
    Promise.all([stations, tags]).then(([stations, tags]) => {
        generatePasses(stations, tags, 1000).then(() => {
            console.log('Passes generated');
        });
    });
}).catch((err) => {
    console.error('Database connection error', err);
});