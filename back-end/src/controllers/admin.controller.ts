import { Request, Response } from 'express';
import { Station } from '../entities/station.entity';
import { Tag } from '../entities/tag.entity';
import { Pass } from '../entities/pass.entity';
import { dataSource } from '../config/database';

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

export const resetStations = (req: Request, res: Response) => {
    // Placeholder: Implement reset stations logic
    res.status(200).json({ message: 'Stations reset successfully' });
}

export const resetPasses = (req: Request, res: Response) => {
    // Placeholder: Implement reset passes logic
    res.status(200).json({ message: 'Passes reset successfully' });
};

export const addPasses = (req: Request, res: Response) => {
    // Placeholder: Implement add passes logic
    res.status(201).json({ message: 'Passes added successfully' });
};
