import { Request, Response } from 'express';
import { Pass } from '../entities/pass.entity';
import { Station } from '../entities/station.entity';
import { Operator } from '../entities/operator.entity';
import { Not, Between } from 'typeorm';

const formatDate = (date: string) => `${date.slice(0, 4)}-${date.slice(4, 6)}-${date.slice(6, 8)}`;

const handleError = (res: Response, error: any, message: string) => {
    console.error(message, error);
    res.status(500).json({ error: message });
};

export const getTollStationPasses = async (req: Request, res: Response) => {
    const { tollStationID, date_from, date_to } = req.params;
    const periodFrom = formatDate(date_from);
    const periodTo = formatDate(date_to);

    try {
        const station = await Station.findOne({ where: { id: tollStationID }, relations: ['operator'] });
        if (!station) {
            res.status(404).json({ error: 'Toll station not found' });
            return;
        }

        const passes = await Pass.find({
            where: { station, timestamp: Between(new Date(periodFrom), new Date(periodTo)) },
            relations: ['tag', 'tag.operator'],
        });

        res.status(200).json({
            stationID: station.id,
            stationOperator: station.operator.name,
            requestTimestamp: new Date().toISOString(),
            periodFrom: periodFrom + ' 00:00',
            periodTo: periodTo + ' 23:59',
            n_passes: passes.length,
            passList: passes.map((pass, index) => ({
                passIndex: index + 1,
                passID: pass.id,
                timestamp: pass.timestamp.toISOString(),
                tagID: pass.tag.id,
                tagProvider: pass.tag.operator.name,
                passType: pass.paid ? "home" : "visitor",
                passCharge: pass.charge,
            }))
        });
    } catch (error) {
        handleError(res, error, 'Failed to fetch toll station passes');
    }
};

export const getPassAnalysis = async (req: Request, res: Response) => {
    const { stationOpID, tagOpID, date_from, date_to } = req.params;
    const periodFrom = formatDate(date_from);
    const periodTo = formatDate(date_to);

    try {

         const stationOp = await Operator.findOneBy({ id: stationOpID });
         const tagOp = await Operator.findOneBy({ id: tagOpID });

         if (!stationOp || !tagOp) {
             res.status(404).json({ error: 'Station or tag operator not found' });
             return;
         }

         const passes = await Pass.find({
             where: {
                station: { operator: stationOp },
                tag: { operator: tagOp },
                timestamp: Between(new Date(periodFrom), new Date(periodTo)),
             },
            relations: ['tag', 'station'],
        });

        res.status(200).json({
            stationOpID,
            tagOpID,
            requestTimestamp: new Date().toISOString(),
            periodFrom: periodFrom + ' 00:00',
            periodTo: periodTo + ' 23:59',
            n_passes: passes.length,
            passList: passes.map((pass, index) => ({
                passIndex: index + 1,
                passID: pass.id,
                stationID: pass.station.id,
                timestamp: pass.timestamp.toISOString(),
                tagID: pass.tag.id,
                passCharge: pass.charge,
            }))
        });
    } catch (error) {
        handleError(res, error, 'Failed to analyze passes');
    }
};

export const getChargesBy = async (req: Request, res: Response) => {
    const { tollOpID, date_from, date_to } = req.params;
    const periodFrom = formatDate(date_from);
    const periodTo = formatDate(date_to);

    try {
        const tollOp = await Operator.findOneBy({ id: tollOpID });

        if (!tollOp) {
            res.status(404).json({ error: 'Toll operator not found' });
            return;
        }

        const passes = await Pass.find({
            where: {
                station: { operator: tollOp },
                tag: { operator: Not(tollOp) },
                timestamp: Between(new Date(periodFrom), new Date(periodTo)),
            },
            relations: ['tag', 'station', 'tag.operator'],
        });


        // Group passes by visiting operator (tag.operator.id)
        const visitingOperators = passes.reduce((acc, pass) => {
            const visitingOpID = pass.tag.operator.id;

            // Initialize the operator in the accumulator if not present
            if (!acc[visitingOpID]) {
                acc[visitingOpID] = { nPasses: 0, passesCost: 0 };
            }

            // Increment passes count and add the charge
            acc[visitingOpID].nPasses += 1;
            acc[visitingOpID].passesCost += pass.charge;

            return acc;
        }, {} as Record<string, { nPasses: number; passesCost: number }>);

        const vOpList = Object.entries(visitingOperators).map(([opID, { nPasses, passesCost }]) => ({
            visitingOpID: opID,
            nPasses,
            passesCost: passesCost.toFixed(2),
        }));

        res.status(200).json({
            tollOpID,
            requestTimestamp: new Date().toISOString(),
            periodFrom: periodFrom + ' 00:00',
            periodTo: periodTo + ' 23:59',
            vOpList,
        });
    } catch (error) {
        handleError(res, error, 'Failed to fetch charges by operators');
    }
};

export const getPassesCost = async (req: Request, res: Response) => {
    const { tollOpID, tagOpID, date_from, date_to } = req.params;
    const periodFrom = formatDate(date_from);
    const periodTo = formatDate(date_to);

    try {
        const passes = await Pass.find({
            where: {
                station: { operator: { id: tollOpID } },
                tag: { operator: { id: tagOpID } },
                timestamp: Between(new Date(periodFrom), new Date(periodTo)),
            },
            relations: ['tag', 'station', 'station.operator', 'tag.operator'],
        });

        const totalCost = passes.reduce((sum, pass) => sum + pass.charge, 0);

        res.status(200).json({
            tollOpID,
            tagOpID,
            requestTimestamp: new Date().toISOString(),
            periodFrom,
            periodTo,
            n_passes: passes.length,
            passesCost: totalCost,
        });
    } catch (error) {
        handleError(res, error, 'Failed to analyze passes');
    }
};

export const getTollStations = async (req: Request, res: Response) => {
    const { tollOpID } = req.params;

    try {
        const tollOp = await Operator.findOneBy({ id: tollOpID });

        if (!tollOp) {
            res.status(404).json({ error: 'Toll operator not found' });
            return;
        }

        const stations = await Station.find({ where: { operator: tollOp } });

        res.status(200).json(stations.map(station => ({
            id: station.id,
            name: station.name,
        })));
    } catch (error) {
        handleError(res, error, 'Failed to fetch toll stations');
    }
};