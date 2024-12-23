import { Router } from 'express';
import {healthCheck, resetStations, resetPasses, addPasses, getUsers, userMod} from '../controllers/admin.controller';
import {authMiddleware} from "../middlewares/auth.middleware";
import {roleMiddleware} from "../middlewares/role.middleware";

const router = Router();

router.get('/healthcheck', healthCheck);
router.post('/resetstations', resetStations);
router.post('/resetpasses', resetPasses);
router.post('/addpasses', authMiddleware, roleMiddleware('admin'), addPasses);
router.get('/users', authMiddleware, roleMiddleware('admin'), getUsers);
router.post('/users', authMiddleware, roleMiddleware('admin'), userMod);

export default router;
