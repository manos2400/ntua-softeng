import express from 'express';
import cors from 'cors';
import adminRoutes from './routes/admin.routes';
import servicesRoutes from './routes/services.routes';
import authRoutes from "./routes/auth.routes";
import { errorHandler } from './middlewares/error.middleware';
import {authMiddleware} from "./middlewares/auth.middleware";
import {roleMiddleware} from "./middlewares/role.middleware";

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(cors());

// API Routes
app.use('/api', authRoutes);
app.use('/api/admin', authMiddleware, roleMiddleware('admin'), adminRoutes);
app.use('/api', authMiddleware, servicesRoutes);


// Error Middleware
app.use(errorHandler);

export default app;