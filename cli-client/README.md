# CLI client

### Usage
``se2456 [options] [command]``


### Commands
- **healthcheck**                  `Check if the server is running`
- **resetpasses**                  `Reset all toll passes`
- **resetstations**                `Reset all toll stations`
- **tollstationpasses** [options]  `Get toll station passes for a specific period`
- **chargesby** [options]          `Get charges from all other tag operators for a specific period`
- **getdebt** [options]            `Get Debt of an Operator`
- **paydebt** [options]            `Pays the debt of a tag operator to a toll operator within a specified period.`
- **tollstats** [options]          `Get statistics for a toll operator`
- **passescost** [options]         `Get the cost of passes performed by a specific tag operator in the road of another operator`
- **passanalysis** [options]       `Get the analysis of passes performed by a specific tag operator in the road of another operator`
- **login** [options]              `Login as a user`
- **logout**                       `Logout the current user`
- **admin** [options]              `Admin operations`
- **help** [command]               `Display help for command`