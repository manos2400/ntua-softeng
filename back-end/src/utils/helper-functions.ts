import {Response} from "express";

export const createCsv = (header: string, data: string[]) => {
    return [header, ...data, ''].join('\n');
}

export const formatDate = (dateString: string)=> {
    if (dateString.length !== 8) {
        throw new Error("Invalid date");
    }

    const regex = /^\d{8}$/;
    if (!regex.test(dateString)) {
        throw new Error("Invalid date");
    }

    const year = parseInt(dateString.substring(0, 4), 10);
    const month = parseInt(dateString.substring(4, 6), 10);
    const day = parseInt(dateString.substring(6, 8), 10);

    const date = new Date(year, month - 1, day);
    if (date.getFullYear() === year && date.getMonth() + 1 === month && date.getDate() === day) {
        return `${dateString.slice(0, 4)}-${dateString.slice(4, 6)}-${dateString.slice(6, 8)}`;
    } else {
        throw new Error("Invalid date");
    }
}

export const handleError = (res: Response, error: any, message: string) => {
    console.error(message, error);
    res.status(500).json({ error: message });
};