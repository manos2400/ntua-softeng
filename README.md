# NTUA ECE SOFTWARE ENGINEERING 2024-25 PROJECT
  
## TEAM 24-56
  
## Description
The project focuses on interoperability in highway toll systems, analyzing toll transaction data across platforms like aodos.gr and egnatia.eu. It involves developing software to manage inter-operator financial settlements, store transit data, and provide analytics services. The system operates independently, ensuring streamlined data handling and insightful analyses for third parties.

## Setup

### Prerequisites

- Docker
- Linux

### Launch

Build the docker images and launch the containers:
```bash
docker compose up -d --build
```

After the **first** launch, you need to initialize the database, with the following calls to the API. You can use curl, Postman (or other GUI tools): 
```bash
curl -X POST -k https://localhost:9115/api/admin/resetstations
curl -X POST -k https://localhost:9115/api/admin/resetpasses
```
or our CLI client:
```bash
./se2456 resetstations
./se2456 resetpasses
```

### Access

#### Web Application 
The Web Application is available at [https://localhost:9115](https://localhost:9115)
#### API
The API is available at [https://localhost:9115/api](https://localhost:9115/api)
#### CLI
The CLI client is given in the `cli-client` directory. You can use it like this:
```bash
cd cli-client
./se2456 --help
```

## More features

### OpenAPI Documentation

After you have launched the back-end, you can access the OpenAPI documentation at [https://localhost:9115/api-docs](https://localhost:9115/api-docs)

### Testing

After you have launched the back-end and the database, and initialized the database, you can run the tests:
```bash
cd test
./test.sh api
./test.sh cli
```

