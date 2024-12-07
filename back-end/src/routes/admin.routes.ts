import { Router } from 'express';
import { healthCheck, resetStations, resetPasses, addPasses } from '../controllers/admin.controller';

const router = Router();

router.get('/healthcheck', healthCheck);
router.post('/resetstations', resetStations);
router.post('/resetpasses', resetPasses);
router.post('/addpasses', addPasses);


export default router;
