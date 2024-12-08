import app from './app';
import { dataSource } from "./config/database";
import 'reflect-metadata';

const PORT = process.env.PORT || 9115;

// Initialize the database connection
dataSource.initialize().then(() => {
    console.log('Database connected');
}).catch((err) => {
    console.error('Database connection error', err);
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});

