import { Router } from 'express';
import {
    getTollStationPasses,
    getPassAnalysis,
    getPassesCost,
    getChargesBy,
    payDebt,
    getDebt,
    getTollStats
} from '../controllers/services.controller';

const router = Router();

router.get('/tollStationPasses/:tollStationID/:date_from/:date_to', getTollStationPasses);
router.get('/passAnalysis/:stationOpID/:tagOpID/:date_from/:date_to', getPassAnalysis);
router.get('/passesCost/:tollOpID/:tagOpID/:date_from/:date_to', getPassesCost);
router.get('/chargesBy/:tollOpID/:date_from/:date_to', getChargesBy);
router.put('/payDebt/:tagOpID/:tollOpID/:date_from/:date_to', payDebt);
router.get('/getDebt/:tagOpID/:date_from/:date_to', getDebt);
router.get('/tollStats/:tollOpID/:date_from/:date_to', getTollStats)

export default router;
