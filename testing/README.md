# Testing

## Initialize

Launch the back-end and the database:
```bash
cd tmp-help-files # contains compose.yaml
docker compose up -d # start DB

cd ../back-end
pnpm install
pnpm run dev
```

After back-end launches and successfully connects to the database, initialize the daatabse by adding the first (admin) user. In a new terminal:
```bash
curl -X POST http://localhost:9115/api/admin/resetpasses
```

If you want to test the CLI, make sure you have commander installed:
```bash
cd cli-client
npm install commander
```

## Test
```
cd testing
```

API Functional Tests:
```bash
./test.sh api
```

CLI Tests:
```bash
./test.sh cli
```
