import {Request, Response} from 'express';
import {Pass} from '../entities/pass.entity';
import {Station} from '../entities/station.entity';
import {Operator} from '../entities/operator.entity';
import {Between, Not} from 'typeorm';

const formatDate = (date: string) => `${date.slice(0, 4)}-${date.slice(4, 6)}-${date.slice(6, 8)}`;

const createCsv = (header: string, data: string[]) => {
    return [header, ...data, ''].join('\n');
}

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
            res.status(400).json({ error: 'Toll station not found' });
            return;
        }

        const passes = await Pass.find({
            where: { station, timestamp: Between(new Date(periodFrom), new Date(periodTo)) },
            relations: ['tag', 'tag.operator'],
        });

        if(req.query.format === 'csv') {
            const richPasses = passes.sort((a, b) => a.timestamp.getTime() - b.timestamp.getTime()).map(pass => `${station.id},${station.operator.id},${new Date().toISOString()},${periodFrom},${periodTo},${passes.length},${pass.id},${pass.timestamp.toISOString()},${pass.tag.id},${pass.tag.operator.id},${pass.paid ? 'home' : 'visitor'},${pass.charge}`);
            const csv = createCsv('stationID,stationOperator,requestTimestamp,periodFrom,periodTo,n_passes,passID,timestamp,tagID,tagProvider,passType,passCharge', richPasses);

            res.setHeader('Content-Type', 'text/csv');
            res.status(200).send(csv);
        } else {
            res.setHeader('Content-Type', 'application/json');
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
                })).sort((a, b) => a.timestamp.localeCompare(b.timestamp)),
            });
        }
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
             res.status(400).json({ error: 'Station or tag operator not found' });
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

        if(req.query.format === 'csv') {
            const richPasses = passes.sort((a, b) => a.timestamp.getTime() - b.timestamp.getTime()).map(pass => `${stationOpID},${tagOpID},${new Date().toISOString()},${periodFrom},${periodTo},${passes.length},${pass.id},${pass.station.id},${pass.timestamp.toISOString()},${pass.tag.id},${pass.charge}`);
            const csv = createCsv('stationOpID,tagOpID,requestTimestamp,periodFrom,periodTo,n_passes,passID,stationID,timestamp,tagID,passCharge', richPasses);

            res.setHeader('Content-Type', 'text/csv');
            res.status(200).send(csv);
        } else {
            res.setHeader('Content-Type', 'application/json');
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
                })).sort((a, b) => a.timestamp.localeCompare(b.timestamp))
            });
        }
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
            res.status(400).json({ error: 'Toll operator not found' });
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

        const vOpList = Object.entries(visitingOperators).map(([opID, {nPasses, passesCost}]) => ({
            visitingOpID: opID,
            nPasses,
            passesCost: passesCost.toFixed(2),
        }));


        if(req.query.format === 'csv') {
            const richVopList = vOpList.map(vop => `${tollOpID},${new Date().toISOString()},${periodFrom},${periodTo},${vop.visitingOpID},${vop.nPasses},${vop.passesCost}`);
            const csv = createCsv('tollOpID,requestTimestamp,periodFrom,periodTo,visitingOpID,n_passes,passesCost', richVopList);

            res.setHeader('Content-Type', 'text/csv');
            res.status(200).send(csv);
        } else {
            res.setHeader('Content-Type', 'application/json');
            res.status(200).json({
                tollOpID,
                requestTimestamp: new Date().toISOString(),
                periodFrom: periodFrom + ' 00:00',
                periodTo: periodTo + ' 23:59',
                vOpList,
            });
        }
    } catch (error) {
        handleError(res, error, 'Failed to fetch charges by operators');
    }
};

export const getPassesCost = async (req: Request, res: Response) => {
    const { tollOpID, tagOpID, date_from, date_to } = req.params;
    const periodFrom = formatDate(date_from);
    const periodTo = formatDate(date_to);

    try {
        const tollOp = await Operator.findOneBy({ id: tollOpID });
        const tagOp = await Operator.findOneBy({ id: tagOpID });

        if (!tollOp || !tagOp) {
            res.status(400).json({ error: 'Toll or tag operator not found' });
            return;
        }

        const passes = await Pass.find({
            where: {
                station: { operator: tollOp },
                tag: { operator: tagOp },
                timestamp: Between(new Date(periodFrom), new Date(periodTo)),
            },
            relations: ['tag', 'station', 'station.operator', 'tag.operator'],
        });

        const totalCost = passes.reduce((sum, pass) => sum + pass.charge, 0);

        if (req.query.format === 'csv') {
            const csv = createCsv('tollOpID,tagOpID,requestTimestamp,periodFrom,periodTo,n_passes,passesCost',
                [[tollOpID, tagOpID, new Date().toISOString(), periodFrom, periodTo, passes.length.toString(), totalCost.toString()].join(',')]
            );

            res.setHeader('Content-Type', 'text/csv');
            res.status(200).send(csv);
        } else {
            res.setHeader('Content-Type', 'application/json');
            res.status(200).json({
                tollOpID,
                tagOpID,
                requestTimestamp: new Date().toISOString(),
                periodFrom,
                periodTo,
                n_passes: passes.length,
                passesCost: totalCost,
            });
        }
    } catch (error) {
        handleError(res, error, 'Failed to analyze passes');
    }
};

export const getDebt = async (req: Request, res: Response) => {
    const { tagOpID, date_from, date_to } = req.params;
    const periodFrom = formatDate(date_from);
    const periodTo = formatDate(date_to);

    try {
        const tagOp = await Operator.findOneBy({ id: tagOpID });

        if (!tagOp) {
            res.status(400).json({ error: 'Tag operator not found' });
            return;
        }

        const passes = await Pass.find({
            where: {
                station: { operator: Not(tagOp) },
                tag: { operator: tagOp },
                timestamp: Between(new Date(periodFrom), new Date(periodTo)),
                paid: false,
            },
            relations: ['tag', 'station', 'station.operator'],
        });

        // Group passes by visiting operator (tag.operator.id)
        const homeOperators = passes.reduce((acc, pass) => {
            const homeOpID = pass.station.operator.id;

            // Initialize the operator in the accumulator if not present
            if (!acc[homeOpID]) {
                acc[homeOpID] = { nPasses: 0, passesCost: 0 };
            }

            // Increment passes count and add the charge
            acc[homeOpID].nPasses += 1;
            acc[homeOpID].passesCost += pass.charge;

            return acc;
        }, {} as Record<string, { nPasses: number; passesCost: number }>);

        const hOpList = Object.entries(homeOperators).map(([opID, {nPasses, passesCost}]) => ({
            homeOpID: opID,
            nPasses,
            passesCost: passesCost.toFixed(2),
        }));

        if(req.query.format === 'csv') {
            const richVopList = hOpList.map(hop => `${tagOpID},${new Date().toISOString()},${periodFrom},${periodTo},${hop.homeOpID},${hop.nPasses},${hop.passesCost}`);
            const csv = createCsv('tagOpID,requestTimestamp,periodFrom,periodTo,homeOpID,n_passes,passesCost', richVopList);

            res.setHeader('Content-Type', 'text/csv');
            res.status(200).send(csv);
        } else {
            res.setHeader('Content-Type', 'application/json');
            res.status(200).json({
                tagOpID,
                requestTimestamp: new Date().toISOString(),
                periodFrom: periodFrom + ' 00:00',
                periodTo: periodTo + ' 23:59',
                hOpList,
            });
        }
    } catch (error) {
        handleError(res, error, 'Failed to calculate debt');
    }
}

export const payDebt = async (req: Request, res: Response) => {
    const { tagOpID, tollOpID, date_from, date_to } = req.params;
    const periodFrom = formatDate(date_from);
    const periodTo = formatDate(date_to);

    try {
        const tollOp = await Operator.findOneBy({ id: tollOpID });
        const tagOp = await Operator.findOneBy({ id: tagOpID });

        if (!tollOp || !tagOp) {
            res.status(400).json({ error: 'Toll or tag operator not found' });
            return;
        }

        const passes = await Pass.find({
            where: {
                station: { operator: tollOp },
                tag: { operator: tagOp },
                timestamp: Between(new Date(periodFrom), new Date(periodTo)),
                paid: false,
            }
        });
        let totalCost = 0;

        for (const pass of passes) {
            pass.paid = true;
            totalCost += pass.charge;
            await pass.save();
        }

        res.status(200).json({ status: `OK`, totalCost });
    } catch (error) {
        handleError(res, error, 'Failed to pay debt');
    }
}

export const getTollStats = async (req: Request, res: Response) => {
    const { tollOpID, date_from, date_to } = req.params;
    const periodFrom = formatDate(date_from);
    const periodTo = formatDate(date_to);

    try {
        const tollOp = await Operator.findOneBy({ id: tollOpID });

        if (!tollOp) {
            res.status(400).json({ error: 'Toll operator not found' });
            return;
        }

        const passes = await Pass.find({
            where: {
                station: { operator: tollOp },
                timestamp: Between(new Date(periodFrom), new Date(periodTo)),
            },
            relations: ['tag', 'station', 'tag.operator', 'station.operator'],
        });

        if (passes.length === 0) {
            res.status(400).json({ error: 'No passes found in that time period' });
            return;
        }

        const stations = Object.values(passes.reduce((acc, pass) => {
            const stationID = pass.station.id;
            if (!acc[stationID]) {
                acc[stationID] = { id: stationID, nPasses: 0, revenue: 0, };
            }

            acc[stationID].nPasses += 1;
            acc[stationID].revenue += pass.charge;

            return acc;
        } , {} as Record<string, { id: string, nPasses: number; revenue: number }>));

        const homeStations = Object.values(passes.reduce((acc, pass) => {
            const stationID = pass.station.id;
            if(pass.station.operator.id === pass.tag.operator.id) {
                if (!acc[stationID]) {
                    acc[stationID] = { id: stationID, nPasses: 0, revenue: 0, };
                }

                acc[stationID].nPasses += 1;
                acc[stationID].revenue += pass.charge;
            }
            return acc;
        } , {} as Record<string, { id: string, nPasses: number; revenue: number }>));

        const totalPasses = passes.length;
        const totalRevenue = passes.reduce((sum, pass) => sum + pass.charge, 0);

        const mostPasses = stations.sort((a, b) => b.nPasses - a.nPasses)[0];
        const mostRevenue = stations.sort((a, b) => b.revenue - a.revenue)[0];

        const mostPassesWithHomeTag = homeStations.sort((a, b) => b.nPasses - a.nPasses)[0];
        const mostRevenueWithHomeTag = homeStations.sort((a, b) => b.revenue - a.revenue)[0];


        if(req.query.format === 'csv') {
            const csv = createCsv('tollOpID,requestTimestamp,periodFrom,periodTo,totalPasses,totalRevenue,mostPasses,mostRevenue,mostPassesWithHomeTag,mostRevenueWithHomeTag',
                [[tollOpID, new Date().toISOString(), periodFrom, periodTo, totalPasses.toString(), totalRevenue.toFixed(2), mostPasses.id, mostRevenue.id, mostPassesWithHomeTag.id, mostRevenueWithHomeTag.id].join(',')]
            );

            res.setHeader('Content-Type', 'text/csv');
            res.status(200).send(csv);
        } else {
            res.setHeader('Content-Type', 'application/json');
            res.status(200).json({
                tollOpID,
                requestTimestamp: new Date().toISOString(),
                periodFrom,
                periodTo,
                stats: {
                    totalPasses,
                    totalRevenue: totalRevenue.toFixed(2),
                    mostPasses: mostPasses.id,
                    mostRevenue: mostRevenue.id,
                    mostPassesWithHomeTag: mostPassesWithHomeTag.id,
                    mostRevenueWithHomeTag: mostRevenueWithHomeTag.id
                }

            });
        }
    } catch (error) {
        handleError(res, error, 'Failed to fetch toll stats');
    }
}