import { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import {User} from "../entities/user.entity";

const secretKey = process.env.JWT_SECRET || 'your_secret_key';
const tokenExpiry = '1h';

export const login = async (req: Request, res: Response): Promise<void> => {
    try {
        const { username, password } = req.body;

        if (!username || !password) {
            res.status(400).json({ error: 'Username and password are required' });
            return;
        }

        const user = await User.findOneBy({ username });

        if (!user || !(await bcrypt.compare(password, user.password))) {
            res.status(401).json({ error: 'Invalid username or password' });
            return;
        }

        const token = jwt.sign({ username: user.username, role: user.isAdmin ? "admin" : "user" }, secretKey, { expiresIn: tokenExpiry });
        res.status(200).json({ token });
    } catch (error) {
        res.status(500).json({ error: 'Internal server error' });
    }
};

export const logout = (req: Request, res: Response) => {
    // For stateless JWT, we simply inform the client to discard the token
    res.status(200).send();
};
