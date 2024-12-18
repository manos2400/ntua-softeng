import express from 'express';
import cors from 'cors';
import adminRoutes from './routes/admin.routes';
import servicesRoutes from './routes/services.routes';
import authRoutes from "./routes/auth.routes";
import utilsRoutes from "./routes/utils.routes";

import swaggerUi from 'swagger-ui-express';
import YAML from 'yaml';
import * as fs from "fs";

import { errorHandler } from './middlewares/error.middleware';
import {authMiddleware} from "./middlewares/auth.middleware";


const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(cors());

const swaggerDocument = YAML.parse(fs.readFileSync(__dirname + '/../../documentation/openapi.yaml', 'utf-8'));

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));

// API Routes
app.use('/api', authRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api', authMiddleware, servicesRoutes);
app.use('/api', authMiddleware, utilsRoutes);

// Error Middleware
app.use(errorHandler);

export default app;