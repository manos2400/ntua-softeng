import app from './app';
import { dataSource } from "./config/database";
import 'reflect-metadata';
import 'dotenv/config';
import {User} from "./entities/user.entity";
import bcrypt from "bcrypt";

const PORT = process.env.PORT || 9115;

// Initialize the database connection
dataSource.initialize().then(async () => {
    // Create an admin user if it doesn't exist
    if(!(await User.findOneBy({username: 'admin'}))) {
        const user = new User();
        user.username = 'admin';
        user.password = bcrypt.hashSync('freepasses4all', 12);
        user.isAdmin = true;
        await user.save();
        console.log('First run detected. Admin user created');
    }
    console.log('Database connected');
}).catch((err) => {
    console.error('Database connection error', err);
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});

