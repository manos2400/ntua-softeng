import { Request, Response } from 'express';
import { Station } from '../entities/station.entity';
import { Tag } from '../entities/tag.entity';
import { Pass } from '../entities/pass.entity';
import { dataSource } from '../config/database';
import multer from 'multer';
import * as fs from 'fs';
import {Operator} from "../entities/operator.entity";
import {User} from "../entities/user.entity";
import bcrypt from "bcrypt";


const upload = multer({ dest: 'uploads/' });

export const healthCheck = async (req: Request, res: Response) => {
    try {
        const dbConnection = dataSource.isInitialized ? "connected" : "disconnected";
        const n_stations = await Station.count();
        const n_tags = await Tag.count();
        const n_passes = await Pass.count();

        res.status(200).json({
            status: "OK",
            dbconnection: dbConnection,
            n_stations: n_stations,
            n_tags: n_tags,
            n_passes: n_passes
        });
    } catch (error) {
        res.status(500).json({ status: "failed", dbconnection: "disconnected" });
    }
};

export const resetStations = async (req: Request, res: Response) => {
    try {
        const stationsData = fs.readFileSync(__dirname + '/../data/tollstations2024.csv', 'utf-8');
        const stations = stationsData.split('\n');

        stations.shift(); // remove the header

        for (const station of stations) {
            if (!station.trim()) continue; // Skip empty lines
            const [opID, operator, tollID, name, pm, locality, road, lat, long, email, price1, price2, price3, price4] = station.split(',');

            let operatorEntity = await Operator.findOneBy({ id: opID });
            if (!operatorEntity) {
                operatorEntity = new Operator();
                operatorEntity.id = opID;
                operatorEntity.name = operator;
                operatorEntity.road = road;
                operatorEntity.email = email;
                await operatorEntity.save();
            }

            const newStation = new Station();
            newStation.id = tollID;
            newStation.name = name;
            newStation.locality = locality;
            newStation.latitude = parseFloat(lat);
            newStation.longitude = parseFloat(long);
            newStation.price1 = parseFloat(price1) || 0;
            newStation.price2 = parseFloat(price2) || 0;
            newStation.price3 = parseFloat(price3) || 0;
            newStation.price4 = parseFloat(price4) || 0;
            newStation.operator = operatorEntity;

            await newStation.save();
        }

        res.status(200).json({ status: 'OK' });
    } catch (error) {
        console.error('Error resetting stations:', error);
        res.status(500).json({ status: 'failed', info: error });
    }
};


export const resetPasses = async (req: Request, res: Response) => {
    try {
        await Pass.delete({});
        await Tag.delete({});

        // check if admin exists
        let admin = await User.findOneBy({ username: 'admin' });

        if(!admin) {
            admin = new User();
            admin.username = 'admin';
            admin.password = await bcrypt.hash('freepasses4all', 12);
            admin.isAdmin = true;
            await admin.save();
        }

        res.status(200).json({ status: 'OK' });
    } catch (error) {
        res.status(500).json({ status: 'failed', info: error });
    }

};

export const addPasses =
    [
        upload.single('file'),
        async (req: Request, res: Response) => {
            try {
                if(!req.file) {
                    res.status(400).json({ status: 'failed', info: 'No file uploaded' });
                    return;
                }
                const passesData = fs.readFileSync(req.file.path, 'utf-8');
                const passes = passesData.split('\n');

                passes.shift(); // remove the header

                for (const pass of passes) {
                    if (!pass.trim()) continue; // Skip empty lines
                    const [timestamp, tollID, tagRef, tagHomeID, charge] = pass.split(',');

                    const station = await Station.findOne({
                        where: { id: tollID },
                        relations: ['operator']
                    });

                    if(!station) {
                        throw new Error(`Station not found for pass: ${pass}`);
                    }

                    let tag = await Tag.findOne({
                        where: { id: tagRef },
                        relations: ['operator']
                    })

                    if(!tag) {
                        const operator = await Operator.findOneBy({ id: tagHomeID });
                        tag = new Tag();
                        tag.id = tagRef;
                        tag.operator = operator!;
                        await tag.save();
                    }

                    const newPass = new Pass();
                    newPass.charge = parseFloat(charge);
                    newPass.timestamp = new Date(timestamp);
                    newPass.paid = station.operator.id === tag.operator.id;
                    newPass.station = station;
                    newPass.tag = tag;
                    await newPass.save();
                }

                res.status(200).json({ status: 'OK' });
                // Delete the file after processing
                fs.unlinkSync(req.file.path);
            } catch (error) {
                console.error('Error adding passes:', error);
                res.status(500).json({ status: 'failed', info: error });
            }
        }
    ]


export const getUsers = async (req: Request, res: Response) => {
    try {
        const users = await User.find();

        const usernames = users.map(user => user.username);

        res.status(200).json(usernames);
    } catch (error) {
        res.status(500).json({ status: 'failed', info: error });
    }
}

export const userMod = async (req: Request, res: Response) => {
    try {
        const { username, password } = req.body;

        if (!username || !password) {
            res.status(400).json({ message: 'Username and password are required' });
            return;
        }

        let user = await User.findOneBy({ username });

        if (!user) {
            user = new User();
            user.username = username;
        }

        user.password = await bcrypt.hash(password, 12);
        user.isAdmin = false;
        await user.save();

        res.status(200).json({ status: 'OK' });
    } catch (error) {
        res.status(500).json({ status: 'failed', info: error });
    }
}
