import { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

const secretKey = process.env.JWT_SECRET || 'your_secret_key';
const tokenExpiry = '1h';

export const login = async (req: Request, res: Response): Promise<void> => {
    try {
        const { username, password } = req.body;

        if (!username || !password) {
            res.status(400).json({ message: 'Username and password are required' });
            return;
        }

        const users = [
            // this will be replaced with a database query later
            {
                username: 'admin',
                passwordHash: '$2a$12$eFRUN.kWYtcCI7Caj8SQI.I1jAGBKRCYOKb04MSCXt1XzM7RZPOc6', // admin
                role: 'admin'
            },
            {
                username: 'user',
                passwordHash: '$2a$12$J6ymq/1XycanVrnVW8bf7uAqP2kCdKP0u3iHddOrV1buUDelQK9ke', // user
                role: 'user'
            }
        ]

        const user = users.find(u => u.username === username);

        if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
            res.status(401).json({ message: 'Invalid username or password' });
            return;
        }

        const token = jwt.sign({ username: user.username, role: user.role }, secretKey, { expiresIn: tokenExpiry });
        res.status(200).json({ token });
    } catch (error) {
        res.status(500).json({ message: 'Internal server error' });
    }
};

export const logout = (req: Request, res: Response) => {
    // For stateless JWT, we simply inform the client to discard the token
    res.status(200).send();
};
