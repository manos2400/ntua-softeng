import { Router } from 'express';
import { getTollStationPasses, getPassAnalysis, getPassesCost, getChargesBy, getTollStations } from '../controllers/services.controller';

const router = Router();

router.get('/tollStationPasses/:tollStationID/:date_from/:date_to', getTollStationPasses);
router.get('/passAnalysis/:stationOpID/:tagOpID/:date_from/:date_to', getPassAnalysis);
router.get('/passesCost/:tollOpID/:tagOpID/:date_from/:date_to', getPassesCost);
router.get('/chargesBy/:tollOpID/:date_from/:date_to', getChargesBy);
router.get('/TollStations/:tollOpID', getTollStations);

export default router;
