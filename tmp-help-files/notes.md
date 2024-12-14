# Notes

## Requirements

- Node.js
```
node -v
```
- npm
```
npm -v
```
If not, run `sudo apt install npm`
- pnpm
```
pnpm -v
```

## Database

start:
```
cd tmp-help-files # contains compose.yaml
docker compose up -d
```
stop:
```
cd tmp-help-files # contains compose.yaml
docker compose down
```

initialize db by adding the first (admin) user and stations:
```
curl -X POST http://localhost:9115/api/admin/resetstations
curl -X POST http://localhost:9115/api/admin/resetpasses
```

## Backend

start:
```
cd backend
pnpm install
pnpm run dev
```

## CLI

start:
```
cd cli-client
npm install commander
```
use:
```
./cli.js login --username admin --passw freepasses4all
./cli.js admin --addpasses --source /home/aa/Downloads/passes-sample.csv
```

## Frontend

setup:
```
cd frontend
npm init -y # creates package.json
npm install express ejs cookie-parser
```
start:
```
cd frontend
node server.js
```
Go to `http://localhost:3000`.

### Routes

- `/`: landing page if not logged in, dashboard if logged in
- `/login`: login page
- `/signup`: signup page
- `/admin`: admin page
- `/tollStationPasses`: toll station passes
- `/passAnalysis`: pass analysis
- `/passesCost`: passes cost
- `/chargesBy`: charges by


## Test requests

### Healthcheck
curl -X GET http://localhost:9115/api/admin/healthcheck

### Reset Passes
curl -X POST http://localhost:9115/api/admin/resetpasses

### Reset Stations
curl -X POST http://localhost:9115/api/admin/resetstations

### Toll Station Passes
curl -X GET "http://localhost:9115/api/tollStationPasses/<station>/<from>/<to>?format=json" -H "X-OBSERVATORY-AUTH: <token>"

### Charges By
curl -X GET "http://localhost:9115/api/chargesBy/<opid>/<from>/<to>?format=json" -H "X-OBSERVATORY-AUTH: <token>"
curl -X GET "http://localhost:9115/api/chargesBy/AM/20220101/20230101?format=json" -H "X-OBSERVATORY-AUTH: <token>"
curl -X GET "http://localhost:9115/api/chargesBy/AM/20220101/20230101?format=csv" -H "X-OBSERVATORY-AUTH: <token>"

### Passes Cost
curl -X GET "http://localhost:9115/api/passesCost/<stationop>/<tagop>/<from>/<to>?format=json" -H "X-OBSERVATORY-AUTH: <token>"

### Pass Analysis
curl -X GET "http://localhost:9115/api/passAnalysis/<stationop>/<tagop>/<from>/<to>?format=json" -H "X-OBSERVATORY-AUTH: <token>"

### Login
curl -X POST http://localhost:9115/api/login -H "Content-Type: application/json" -d '{"username":"<username>", "password":"<password>"}'

### Logout
rm ~/.se2456_token.json

### Admin: User Modification
curl -X POST http://localhost:9115/api/admin/users -H "X-OBSERVATORY-AUTH: <token>" -H "Content-Type: application/json" -d '{"username":"<username>", "password":"<password>"}'

### Admin: List Users
curl -X GET http://localhost:9115/api/admin/users -H "X-OBSERVATORY-AUTH: <token>"

### Admin: Add Passes (CSV)
curl -X POST http://localhost:9115/api/admin/addpasses -H "X-OBSERVATORY-AUTH: <token>" -H "Content-Type: multipart/form-data" -F "file=@<path_to_csv>;type=text/csv"
curl -X POST http://localhost:9115/api/admin/addpasses -H "X-OBSERVATORY-AUTH: <token>" -H "Content-Type: multipart/form-data" -F "file=@<path_to_csv>;type=text/csv"




