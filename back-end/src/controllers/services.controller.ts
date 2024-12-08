import { Request, Response } from 'express';
import { Pass } from '../entities/pass.entity';
import { Station } from '../entities/station.entity';
import { Between } from 'typeorm';

export const getTollStationPasses = async (req: Request, res: Response) => {
    const { tollStationID, date_from, date_to } = req.params;

    const periodFrom = `${date_from.slice(0, 4)}-${date_from.slice(4, 6)}-${date_from.slice(6, 8)}`;
    const periodTo = `${date_to.slice(0, 4)}-${date_to.slice(4, 6)}-${date_to.slice(6, 8)}`;

    // Find passes within the date range for the given toll station
    try{
            const passes = await Pass.find({
                where: {
                    // Filter by station ID
                    station: { id: tollStationID }, 
                    timestamp: Between(new Date(periodFrom), new Date(periodTo)), // Filter by date range
                },
                //Fetching Pass
                relations: ['tag', 'station', 'station.operator', 'tag.operator'],
            });

            const response = {
                stationID: tollStationID,
                stationOperator: passes[0]?.station.operator?.name || 'Unknown',
                requestTimestamp: new Date().toISOString(),
                periodFrom: date_from,
                periodTo: date_to,
                n_passes: passes.length,
                passList: passes.map((pass, index) =>({
                    passIndex: index + 1,
                    passID: pass.id,
                    timestamp: pass.timestamp.toISOString(),
                    tagID: pass.tag.id,
                    tagProvider: pass.tag.operator?.name || 'Unknown',
                    passType: pass.paid ? "home" : "visitor",
                    passCharge: pass.charge,
                }))
            }

            res.status(200).json(response);
    } catch {
        console.error('Error fetching toll station passes:');
        res.status(500).json({ error: 'Failed to fetch data' });
    }
    // Placeholder: Implement logic to get toll station passes
    //res.status(200).json({ message: `Fetched passes for ${tollStationID}` });
};

export const getPassAnalysis = (req: Request, res: Response) => {
    const { stationOpID, tagOpID, date_from, date_to } = req.params;
    // Placeholder: Implement logic to analyze passes
    res.status(200).json({ message: `Analyzed passes for ${stationOpID} and ${tagOpID}` });
}

export const getChargesBy = (req: Request, res: Response) => {
    const { tollOpID, date_from, date_to } = req.params;
    // Placeholder: Implement logic to get charges by toll operator
    res.status(200).json({ message: `Fetched charges for ${tollOpID}` });
}

export const getPassesCost = (req: Request, res: Response) => {
    const { tollOpID, tagOpID, date_from, date_to } = req.params;
    // Placeholder: Implement logic to calculate passes cost
    res.status(200).json({ message: `Fetched costs for ${tollOpID} and ${tagOpID}` });
};
