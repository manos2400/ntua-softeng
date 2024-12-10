#!/usr/bin/env node

const { Command } = require('commander');
const axios = require('axios');
const fs = require('fs');
const path = require('path');

const program = new Command();
const API_BASE_URL = 'http://localhost:9115/api';
const TOKEN_FILE = path.join(require('os').homedir(), '.se2456_token.json');

// Helper function to read the saved token
function getToken() {
    if (fs.existsSync(TOKEN_FILE)) {
        try {
            const data = fs.readFileSync(TOKEN_FILE, 'utf8');
            return JSON.parse(data).token;
        } catch (err) {
            console.error('Error reading token file:', err.message);
            return null;
        }
    }
    return null;
}

// Helper function to save the token
function saveToken(token) {
    try {
        fs.writeFileSync(TOKEN_FILE, JSON.stringify({ token }), { mode: 0o600 });
        console.log('Token saved successfully.');
    } catch (err) {
        console.error('Error saving token:', err.message);
    }
}

// Helper function to make API calls
async function callApi(endpoint, method = 'GET', data = null, requiresAuth = false, headers = {}) {
    if (requiresAuth) {
        const token = getToken();
        if (!token) {
            console.error('Error: No token found. Please log in first.');
            process.exit(1);
        }
        headers['X-OBSERVATORY-AUTH'] = `${token}`;
    }

    try {
        const response = await axios({
            url: `${API_BASE_URL}${endpoint}`,
            method,
            data,
            headers,
        });
        console.log(JSON.stringify(response.data, null, 2));
    } catch (error) {
        if (error.response) {
            console.error(`Error: ${error.response.status} - ${error.response.data}`);
        } else {
            console.error(`Error: ${error.message}`);
        }
    }
}

// Define CLI commands
program
    .name('se2456')
    .description('CLI for interacting with se2456 API')
    .version('1.0.0');

// Healthcheck
program
    .command('healthcheck')
    .description('Check if the server is running')
    .action(() => {
        callApi('/admin/healthcheck');
    });

// Reset Passes
program
    .command('resetpasses')
    .description('Reset all toll passes')
    .action(() => {
        callApi('/admin/resetpasses', 'POST');
    });

// Reset Stations
program
    .command('resetstations')
    .description('Reset all toll stations')
    .action(() => {
        callApi('/admin/resetstations', 'POST');
    });

// Toll Station Passes
program
    .command('tollstationpasses')
    .description('Get toll station passes for a specific period')
    .requiredOption('--station <station>', 'Station ID')
    .requiredOption('--from <from>', 'Start date (YYYYMMDD)')
    .requiredOption('--to <to>', 'End date (YYYYMMDD)')
    .option('--format <format>', 'Output format (csv or json)', 'json')
    .action((options) => {
        const { station, from, to, format } = options;
        callApi(`/tollStationPasses/${station}/${from}/${to}?format=${format}`, 'GET', null, true);
    });

// Login
program
    .command('login')
    .description('Login as a user')
    .requiredOption('--username <username>', 'Username')
    .requiredOption('--passw <password>', 'Password')
    .action(async (options) => {
        const { username, passw } = options;
        try {
            const response = await axios.post(`${API_BASE_URL}/login`, { username, password: passw });
            const { token } = response.data;
            if (token) {
                saveToken(token);
            } else {
                console.error('Error: No token received from server.');
            }
        } catch (error) {
            if (error.response) {
                console.error(`Error: ${error.response.status} - ${error.response}`);
            } else {
                console.error(`Error: ${error.message}`);
            }
        }
    });

// Logout
program
    .command('logout')
    .description('Logout the current user')
    .action(() => {
        if (fs.existsSync(TOKEN_FILE)) {
            fs.unlinkSync(TOKEN_FILE);
            console.log('Logged out successfully.');
        } else {
            console.log('No active session found.');
        }
    });


program
    .command('admin')
    .description('Admin operations')
    .option('--usermod', 'Add a new user or modify an existing one')
    .option('--users', 'List all users')
    .option('--addpasses', 'Add toll station passes from a CSV file')
    .option('--source <file>', 'Path to the CSV file for adding passes')
    .option('--username <username>', 'Username for usermod')
    .option('--passw <password>', 'Password for usermod')
    .action((options) => {
        const { usermod, users, addpasses } = options;

        if(usermod) {
            const { username, passw } = options;
            callApi('/admin/users', 'POST', { username, password: passw }, true);
        } else if (users) {
            callApi('/admin/users', 'GET', null, true);
        } else if (addpasses) {
            const {source} = options;

            if (!source) {
                console.error('Error: No source file provided');
                return;
            }

            const fs = require('fs');

            // Read the CSV file
            fs.readFile(source, 'utf8', (err, data) => {
                if (err) {
                    console.error(`Error reading file: ${err.message}`);
                    return;
                }
                //pass the csv as content type: multipart/form-data and mime type: 'text/csv'
                const FormData = require('form-data');
                const formData = new FormData();
                formData.append('file', data, {
                    filename: source,
                    contentType: 'text/csv',
                });


                callApi('/admin/addpasses', 'POST', formData, true, formData.getHeaders());
            });
        }
    });

// Parse the command-line arguments
program.parse(process.argv);
