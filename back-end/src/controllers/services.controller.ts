import { Request, Response } from 'express';
import { Pass } from '../entities/pass.entity';
import { Station } from '../entities/station.entity';
import { Operator } from '../entities/operator.entity';
import { Not, Between } from 'typeorm';

export const getTollStationPasses = async (req: Request, res: Response) => {
    const { tollStationID, date_from, date_to } = req.params;

    const periodFrom = `${date_from.slice(0, 4)}-${date_from.slice(4, 6)}-${date_from.slice(6, 8)}`;
    const periodTo = `${date_to.slice(0, 4)}-${date_to.slice(4, 6)}-${date_to.slice(6, 8)}`;

    // Find passes within the date range for the given toll station
    try{
            const passes = await Pass.find({
                where: {
                    // Filter by station ID and date range
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
    } catch (error) {
        console.error('Error fetching toll station passes:', error);
        res.status(500).json({ error: 'Failed to fetch data' });
    }
    
};

export const getPassAnalysis = async (req: Request, res: Response) => {
    const { stationOpID, tagOpID, date_from, date_to } = req.params;

    const periodFrom = `${date_from.slice(0, 4)}-${date_from.slice(4, 6)}-${date_from.slice(6, 8)}`;
    const periodTo = `${date_to.slice(0, 4)}-${date_to.slice(4, 6)}-${date_to.slice(6, 8)}`;

    try {
        
        const passes = await Pass.find({
            where: {
                // Filter by station ID, tagOpID and date range
                station: { operator: { id: stationOpID } }, 
                tag: { operator: { id: tagOpID } }, 
                timestamp: Between(new Date(periodFrom), new Date(periodTo)), 
            },
            relations: ['tag', 'station'], // Fetch related data
        });

        // Response 
        const response = {
            stationOpID,
            tagOpID,
            requestTimestamp: new Date().toISOString(),
            periodFrom,
            periodTo,
            n_passes: passes.length,
            passList: passes.map((pass, index) => ({
                passIndex: index + 1, // Sequential numbering
                passID: pass.id,
                stationID: pass.station.id,
                timestamp: pass.timestamp.toISOString(),
                tagID: pass.tag.id,
                passCharge: pass.charge,
            })),
        };

        // Response the json file
        res.status(200).json(response);
    } catch (error) {
        console.error('Error analyzing passes:', error);
        res.status(500).json({ error: 'Failed to analyze passes' });
    }
    
};

export const getChargesBy = async (req: Request, res: Response) => {
    const { tollOpID, date_from, date_to } = req.params;
    
    const periodFrom = `${date_from.slice(0, 4)}-${date_from.slice(4, 6)}-${date_from.slice(6, 8)}`;
    const periodTo = `${date_to.slice(0, 4)}-${date_to.slice(4, 6)}-${date_to.slice(6, 8)}`;

   try {

    const passes = await Pass.find({
        where: {
            // Filter by tollOPID, exclude the tolls of the OP and date range
            station: { operator: { id: tollOpID } }, 
            tag: { operator: { id: Not(tollOpID) } },
            timestamp: Between(new Date(periodFrom), new Date(periodTo)), 
        },
        relations: ['tag', 'station', 'station.operator', 'tag.operator'], // Fetch related data
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

    // Convert grouped operators to a list
    const vOpList = Object.entries(visitingOperators).map(([visitingOpID, data]) => ({
        visitingOpID,
        nPasses: data.nPasses,
        passesCost: data.passesCost,
    }));

    // Response
    const response = {
        tollOpID,
        requestTimestamp: new Date().toISOString(),
        periodFrom,
        periodTo,
        vOpList,
    };
    // Response the json file
    res.status(200).json(response);
   } catch (error) {
    console.error('Error fetching charges by operators:', error);
    res.status(500).json({ error: 'Failed to fetch charges by operators' });
   }
};

export const getPassesCost = async (req: Request, res: Response) => {
    const { tollOpID, tagOpID, date_from, date_to } = req.params;
    
    const periodFrom = `${date_from.slice(0, 4)}-${date_from.slice(4, 6)}-${date_from.slice(6, 8)}`;
    const periodTo = `${date_to.slice(0, 4)}-${date_to.slice(4, 6)}-${date_to.slice(6, 8)}`;

    try {
        
        const passes = await Pass.find({
            where: {
                // Filter by  toll ID, tagOpID and date range
                station: { operator: { id: tollOpID } }, 
                tag: { operator: { id: tagOpID } }, 
                timestamp: Between(new Date(periodFrom), new Date(periodTo)), 
            },
            relations: ['tag', 'station', 'station.operator', 'tag.operator'], // Fetch related data
        });
        // Calculate total cost
        const totalCost = passes.reduce((sum, pass) => sum + pass.charge, 0);

        // Response  
        const response = {
            tollOpID,
            tagOpID,
            requestTimestamp: new Date().toISOString(),
            periodFrom,
            periodTo,
            n_passes: passes.length,
            passesCost: totalCost,
        };

        // Response the json file
        res.status(200).json(response);
    } catch (error) {
        console.error('Error analyzing passes:', error);
        res.status(500).json({ error: 'Failed to analyze passes' });
    }

};



export const getTollStations = async (req: Request, res: Response) => {
    console.log("Route hit: /TollStations/:tollOpID");
    const { tollOpID  } = req.params;
    
    console.log("Toll Operator ID received:", tollOpID);

    try {
        const stations = await Station.find({
            where: { operator: { id: tollOpID  } },
        });

        console.log("Toll stations found:", stations);
        
        
        res.status(200).json(stations.map(station => ({
            id: station.id,
            name: station.name,
        })));

    } catch (error) 
    {
        console.error('Error fetching toll stations:', error);
        res.status(500).json({ error: 'Failed to fetch toll stations' });
    }
};

