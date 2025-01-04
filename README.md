# NTUA ECE SOFTWARE ENGINEERING 2024-25 PROJECT
  
## TEAM 24-56
  
## Description
The project focuses on interoperability in highway toll systems, analyzing toll transaction data across platforms like aodos.gr and egnatia.eu. It involves developing software to manage inter-operator financial settlements, store transit data, and provide analytics services. The system operates independently, ensuring streamlined data handling and insightful analyses for third parties.

## Setup

### Prerequisites

- Linux
- Node.js | `node -v`
- npm | `npm -v` | `sudo apt install npm`
- pnpm | `pnpm -v` | `curl -fsSL https://get.pnpm.io/install.sh | sh -`

### Launch

Launch the back-end and the database:
```bash
cd database
docker compose up -d
cd ../back-end
pnpm install
pnpm run dev
```

After back-end launches and successfully connects to the database, initialize the database by adding the first (admin) user. In a new terminal:
```bash
curl -X POST http://localhost:9115/api/admin/resetpasses
```

If you intend to use the CLI, make sure you have commander installed:
```bash
cd cli-client
npm install commander
```

Launch the front-end:
```bash
cd front-end
npm init -y # creates package.json (once)
npm install express ejs cookie-parser # (once)
node server.js # start
```

Go to [https://localhost:3000](https://localhost:3000)


## More features

### OpenAPI Documentation

After you have launched the back-end, you can access the OpenAPI documentation at [https://localhost:9115/api-docs](https://localhost:9115/api-docs)

### Testing

After you have launched the back-end and the database, and initialized the database, you can run the tests:
```bash
cd testing
./test.sh api
./test.sh cli
```

### CLI

You can use the CLI like this:
```bash
cd cli-client
./cli.js healthcheck
```

