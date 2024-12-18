import { Router } from 'express';
import { getStations, getOperators } from '../controllers/utils.controller';

const router = Router();

router.get('/stations', getStations);
router.get('/operators', getOperators);

export default router;
