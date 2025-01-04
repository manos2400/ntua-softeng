import { Request, Response, NextFunction } from 'express';

export const roleMiddleware = (requiredRole: string) => {
    return (req: Request, res: Response, next: NextFunction): void => {
        // @ts-ignore
        if (!req.user || req.user.role !== requiredRole) {
            res.status(403).json({ error: 'Forbidden: You do not have the required permissions' });
            return;
        }
        next();
    };
};
