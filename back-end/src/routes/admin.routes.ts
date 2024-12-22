import { Router } from 'express';
import {healthCheck, resetStations, resetPasses, addPasses, getUsers, userMod} from '../controllers/admin.controller';
import {authMiddleware} from "../middlewares/auth.middleware";
import {roleMiddleware} from "../middlewares/role.middleware";

const router = Router();

router.get('/healthcheck', authMiddleware, roleMiddleware('admin'), healthCheck);
router.post('/resetstations', authMiddleware, roleMiddleware('admin'), resetStations);
router.post('/resetpasses', authMiddleware, roleMiddleware('admin'), resetPasses);
router.post('/addpasses', authMiddleware, roleMiddleware('admin'), addPasses);
router.get('/users', authMiddleware, roleMiddleware('admin'), getUsers);
router.post('/users', authMiddleware, roleMiddleware('admin'), userMod);

export default router;
