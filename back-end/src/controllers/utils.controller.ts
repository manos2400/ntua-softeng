import { Request, Response } from 'express';
import {Station} from "../entities/station.entity";
import {Operator} from "../entities/operator.entity";


export const getStations = async (req: Request, res: Response) => {
    try {
        const stations = await Station.find();

        const stationData = stations.map(station => ({
            id: station.id,
            name: station.name
        }));

        res.status(200).json({ stations: stationData });

    } catch (error) {
        res.status(500).json({ error: 'Failed to retrieve stations' });
    }
};

export const getOperators = async (req: Request, res: Response) => {
    try {
        const operators = await Operator.find();


        const operatorData = operators.map(operator => ({
            id: operator.id,
            name: operator.name
        }));

        res.status(200).json({ operators: operatorData });

    } catch (error) {
        res.status(500).json({ error: 'Failed to retrieve operators' });
    }
};