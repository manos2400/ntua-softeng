import {NextFunction, Request, Response} from 'express';
import jwt from 'jsonwebtoken';

const secretKey = process.env.JWT_SECRET || 'your_secret_key';


export const authMiddleware = (req: Request, res: Response, next: NextFunction): void => {
    const token = req.headers['x-observatory-auth'] as string;

    if (!token) {
        res.status(401).json({ message: 'Unauthorized: No token provided' });
        return; // Ensure we do not proceed to the next middleware
    }

    try {
        // @ts-ignore
        req.user = jwt.verify(token, secretKey);
        next();
    } catch (err) {
        res.status(403).json({ message: 'Forbidden: Invalid token' });
    }
};