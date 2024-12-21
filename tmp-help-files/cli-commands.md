# CLI Commands

```
$CLI_PATH healthcheck
$CLI_PATH resetpasses
$CLI_PATH resetstations
$CLI_PATH tollstationpasses --station STATION_ID --from YYYYMMDD --to YYYYMMDD --format json
$CLI_PATH chargesby --opid OPERATOR_ID --from YYYYMMDD --to YYYYMMDD --format json
$CLI_PATH passescost --stationop STATION_OPERATOR_ID --tagop TAG_OPERATOR_ID --from YYYYMMDD --to YYYYMMDD --format json
$CLI_PATH passanalysis --stationop STATION_OPERATOR_ID --tagop TAG_OPERATOR_ID --from YYYYMMDD --to YYYYMMDD --format json
$CLI_PATH login --username USERNAME --passw PASSWORD
$CLI_PATH logout
$CLI_PATH admin --usermod --username USERNAME --passw PASSWORD
$CLI_PATH admin --users
$CLI_PATH admin --addpasses --source FILE_PATH
```

