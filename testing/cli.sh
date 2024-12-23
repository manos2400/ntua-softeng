#!/bin/bash

# Test the CLI

## config

CLI_PATH="../cli-client/cli.js"
PASSES_CSV_PATH="../back-end/src/data/passes-sample.csv"

# imports

source ./utils.sh
source ./expected-outputs/healthcheck.sh
source ./expected-outputs/resetpasses.sh
source ./expected-outputs/resetstations.sh
source ./expected-outputs/login.sh
source ./expected-outputs/tollstationpasses.sh
source ./expected-outputs/chargesby.sh
source ./expected-outputs/passescost.sh
source ./expected-outputs/passanalysis.sh
source ./expected-outputs/admin-user-mod.sh
source ./expected-outputs/admin-list-users.sh
source ./expected-outputs/admin-add-passes.sh
source ./expected-outputs/logout.sh

# runtime vars

VERBOSE=$1

## driver

eko true YELLOW "Testing the CLI\n"

## tests

# ======================= Healthcheck ======================= #
test_healthcheck "$CLI_PATH healthcheck" $VERBOSE "healthcheck"

# ======================= reset passes ======================= #
test_resetpasses "$CLI_PATH resetpasses" $VERBOSE "resetpasses"

# ======================= resetstations ======================= #
test_resetstations "$CLI_PATH resetstations" $VERBOSE "resetstations"

# ======================= login ======================= #
test_login "$CLI_PATH login --username admin --passw wrong" $VERBOSE "login [wrong pass]"
test_login "$CLI_PATH login --username wrong --passw freepasses4all" $VERBOSE "login [wrong username]"
test_login "$CLI_PATH login --username wrong --passw" $VERBOSE "login [wrong username, no password]"
test_login "$CLI_PATH login --username admin --passw" $VERBOSE "login [correct username, no password]"
test_login "$CLI_PATH login --username --passw" $VERBOSE "login [no username, no password]"
test_login "$CLI_PATH login --username --passw wrong" $VERBOSE "login [no username, wrong password]"
test_login "$CLI_PATH login --username --passw freepasses4all" $VERBOSE "login [no username, correct password]"
test_login "$CLI_PATH login --username" $VERBOSE "login [no username, no password field]"
test_login "$CLI_PATH login" $VERBOSE "login [no username and password fields]"
test_login "$CLI_PATH login --username admin --passw freepasses4all" $VERBOSE "login [correct credentials (again)]"
test_login "$CLI_PATH login --username admin --passw freepasses4all" $VERBOSE "login [correct credentials (again)]"

# ======================= tollStationPasses ======================= #
test_tollStationPasses "$CLI_PATH tollstationpasses --station AM03 --from 20220101 --to 20230101 --format json" $VERBOSE "tollStationPasses [JSON]"
test_tollStationPasses "$CLI_PATH tollstationpasses --station AM03 --from 20220101 --to 20230101 --format csv" $VERBOSE "tollStationPasses [CSV]"
test_tollStationPasses "$CLI_PATH tollstationpasses --station AMBB --from 20220101 --to 20230101 --format json" $VERBOSE "tollStationPasses [JSON, wrong toll station]"
test_tollStationPasses "$CLI_PATH tollstationpasses --station AMBB --from 20220101 --to 20230101 --format csv" $VERBOSE "tollStationPasses [CSV, wrong toll station]"
test_tollStationPasses "$CLI_PATH tollstationpasses --station AM03 --from 20240101 --to 20230101 --format json" $VERBOSE "tollStationPasses [JSON, inverse dates]"
test_tollStationPasses "$CLI_PATH tollstationpasses --station AM03 --from 20240101 --to 20230101 --format csv" $VERBOSE "tollStationPasses [CSV, inverse dates]"
test_tollStationPasses "$CLI_PATH tollstationpasses --station AM03 --from 1 --to 1 --format json" $VERBOSE "tollStationPasses [JSON, bad dates]"
test_tollStationPasses "$CLI_PATH tollstationpasses --station AM03 --from 1 --to 1 --format csv" $VERBOSE "tollStationPasses [CSV, bad dates]"

# ======================= chargesBy ======================= #
test_chargesby "$CLI_PATH chargesby --opid AM --from 20220101 --to 20230101 --format json" $VERBOSE "chargesBy [JSON]"
test_chargesby "$CLI_PATH chargesby --opid AM --from 20220101 --to 20230101 --format csv" $VERBOSE "chargesBy [CSV]"
test_chargesby "$CLI_PATH chargesby --opid AM --from 20240101 --to 20230101 --format json" $VERBOSE "chargesBy [JSON, bad dates]"
test_chargesby "$CLI_PATH chargesby --opid AM --from 20240101 --to 20230101 --format csv" $VERBOSE "chargesBy [CSV, bad dates]"
test_chargesby "$CLI_PATH chargesby --opid AM --from 1 --to 1 --format json" $VERBOSE "chargesBy [JSON, bad dates]"
test_chargesby "$CLI_PATH chargesby --opid AM --from 1 --to 1 --format csv" $VERBOSE "chargesBy [CSV, bad dates]"
test_chargesby "$CLI_PATH chargesby --opid AA --from 20240101 --to 20230101 --format json" $VERBOSE "chargesBy [JSON, wrong toll operator]"
test_chargesby "$CLI_PATH chargesby --opid AA --from 20240101 --to 20230101 --format csv" $VERBOSE "chargesBy [CSV, wrong toll operator]"

# ======================= passesCost ======================= #
test_passescost "$CLI_PATH passescost --stationop AM --tagop AM --from 20220101 --to 20230101 --format json" $VERBOSE "passesCost [JSON]"
test_passescost "$CLI_PATH passescost --stationop AM --tagop AM --from 20220101 --to 20230101 --format csv" $VERBOSE "passesCost [CSV]"
test_passescost "$CLI_PATH passescost --stationop AM --tagop AM --from 202401 --to 2023 --format json" $VERBOSE "passesCost [JSON, bad dates]"
test_passescost "$CLI_PATH passescost --stationop AM --tagop AM --from 202401 --to 2023 --format csv" $VERBOSE "passesCost [CSV, bad dates]"
test_passescost "$CLI_PATH passescost --stationop AM --tagop AM --from 1 --to 1 --format json" $VERBOSE "passesCost [JSON, bad dates]"
test_passescost "$CLI_PATH passescost --stationop AM --tagop AM --from 1 --to 1 --format csv" $VERBOSE "passesCost [CSV, bad dates]"
test_passescost "$CLI_PATH passescost --stationop AA --tagop AM --from 202401 --to 202301 --format json" $VERBOSE "passesCost [JSON, wrong toll operator]"
test_passescost "$CLI_PATH passescost --stationop AA --tagop AM --from 202401 --to 202301 --format csv" $VERBOSE "passesCost [CSV, wrong toll operator]"
test_passescost "$CLI_PATH passescost --stationop AM --tagop AA --from 202401 --to 202301 --format json" $VERBOSE "passesCost [JSON, wrong 2nd toll operator]"
test_passescost "$CLI_PATH passescost --stationop AM --tagop AA --from 202401 --to 202301 --format csv" $VERBOSE "passesCost [CSV, wrong 2nd toll operator]"


# ======================= passAnalysis ======================= #
test_passanalysis "$CLI_PATH passanalysis --stationop AM --tagop AM --from 20220101 --to 20230101 --format json" $VERBOSE "passAnalysis [JSON]"
test_passanalysis "$CLI_PATH passanalysis --stationop AM --tagop AM --from 20220101 --to 20230101 --format csv" $VERBOSE "passAnalysis [CSV]"
test_passanalysis "$CLI_PATH passanalysis --stationop AM --tagop AM --from 202401 --to 2023 --format json" $VERBOSE "passAnalysis [JSON, bad dates]"
test_passanalysis "$CLI_PATH passanalysis --stationop AM --tagop AM --from 202401 --to 2023 --format csv" $VERBOSE "passAnalysis [CSV, bad dates]"
test_passanalysis "$CLI_PATH passanalysis --stationop AM --tagop AM --from 1 --to 1 --format json" $VERBOSE "passAnalysis [JSON, bad dates]"
test_passanalysis "$CLI_PATH passanalysis --stationop AM --tagop AM --from 1 --to 1 --format csv" $VERBOSE "passAnalysis [CSV, bad dates]"
test_passanalysis "$CLI_PATH passanalysis --stationop AA --tagop AM --from 202401 --to 202301 --format json" $VERBOSE "passAnalysis [JSON, wrong toll operator]"
test_passanalysis "$CLI_PATH passanalysis --stationop AA --tagop AM --from 202401 --to 202301 --format csv" $VERBOSE "passAnalysis [CSV, wrong toll operator]"
test_passanalysis "$CLI_PATH passanalysis --stationop AM --tagop AA --from 202401 --to 202301 --format json" $VERBOSE "passAnalysis [JSON, wrong 2nd toll operator]"
test_passanalysis "$CLI_PATH passanalysis --stationop AM --tagop AA --from 202401 --to 202301 --format csv" $VERBOSE "passAnalysis [CSV, wrong 2nd toll operator]"
test_passanalysis "$CLI_PATH passanalysis --stationop AM --tagop AM --from 202401 --to 202301 --format json" $VERBOSE "passAnalysis [JSON, inverse dates]"
test_passanalysis "$CLI_PATH passanalysis --stationop AM --tagop AM --from 202401 --to 202301 --format csv" $VERBOSE "passAnalysis [CSV, inverse dates]"


# ======================= Admin: User Modification ======================= #
test_admin_user_mod "$CLI_PATH admin --usermod --username test1 --passw test2" $VERBOSE "Admin: User Modification"
test_admin_user_mod "$CLI_PATH admin --usermod --username '' --passw ''" $VERBOSE "Admin: User Modification [empty fields]"
test_admin_user_mod "$CLI_PATH admin --usermod --username test1 --passw ''" $VERBOSE "Admin: User Modification [empty password]"
test_admin_user_mod "$CLI_PATH admin --usermod --username '' --passw test2" $VERBOSE "Admin: User Modification [empty username]"
test_admin_user_mod "$CLI_PATH admin --usermod --username test" $VERBOSE "Admin: User Modification [no password field]"
test_admin_user_mod "$CLI_PATH admin --usermod --passw test" $VERBOSE "Admin: User Modification [no username field]"
test_admin_user_mod "$CLI_PATH admin --usermod" $VERBOSE "Admin: User Modification [no fields]"


# ======================= Admin: List Users ======================= #
test_admin_list_users "$CLI_PATH admin --users" $VERBOSE "Admin: List Users"

# ======================= Admin: Add Passes ======================= #
if [ ! -f "$PASSES_CSV_PATH" ]; then
    eko true RED "File not found: $PASSES_CSV_PATH"
    exit 1
fi
if [ $VERBOSE = "true" ]; then
    eko $VERBOSE CYAN "First 3 lines of $PASSES_CSV_PATH:"
    echo -e $CYAN
    head -n 3 $PASSES_CSV_PATH
    echo -e "$NC\n"
fi
test_admin_add_passes "$CLI_PATH admin --addpasses --source $PASSES_CSV_PATH" $VERBOSE "Admin: Add Passes"

# ======================= logout ======================= #
test_logout "$CLI_PATH logout" $VERBOSE "logout"
test_logout "$CLI_PATH logout" $VERBOSE "logout [again]"

# ======================= tests after reset passes ======================= #
curl -s -X POST $API_URL/admin/resetpasses -H $AUTH_HEADER_GOOD >> /dev/null
test_healthcheck "$CLI_PATH healthcheck" $VERBOSE "healthcheck [after reset passes]"
test_resetstations "$CLI_PATH resetstations" $VERBOSE "resetstations [after reset passes]"
test_tollStationPasses "$CLI_PATH tollstationpasses --station AM03 --from 20220101 --to 20230101 --format json" $VERBOSE "tollStationPasses [JSON, after reset passes]"
test_tollStationPasses "$CLI_PATH tollstationpasses --station AM03 --from 20220101 --to 20230101 --format csv" $VERBOSE "tollStationPasses [CSV, after reset passes]"
test_chargesby "$CLI_PATH chargesby --opid AM --from 20220101 --to 20230101 --format json" $VERBOSE "chargesBy [JSON, after reset passes]"
test_chargesby "$CLI_PATH chargesby --opid AM --from 20220101 --to 20230101 --format csv" $VERBOSE "chargesBy [CSV, after reset passes]"
test_passescost "$CLI_PATH passescost --stationop AM --tagop AM --from 20220101 --to 20230101 --format json" $VERBOSE "passesCost [JSON, after reset passes]"
test_passescost "$CLI_PATH passescost --stationop AM --tagop AM --from 20220101 --to 20230101 --format csv" $VERBOSE "passesCost [CSV, after reset passes]"
test_passanalysis "$CLI_PATH passanalysis --stationop AM --tagop AM --from 20220101 --to 20230101 --format json" $VERBOSE "passAnalysis [JSON, after reset passes]"
test_passanalysis "$CLI_PATH passanalysis --stationop AM --tagop AM --from 20220101 --to 20230101 --format csv" $VERBOSE "passAnalysis [CSV, after reset passes]"
test_get_debt "$CLI_PATH getdebt --opid AM --from 20220101 --to 20220101 --format json" $VERBOSE "Get Debt [JSON, after reset passes]"
test_get_debt "$CLI_PATH getdebt --opid AM --from 20220101 --to 20220101 --format csv" $VERBOSE "Get Debt [CSV, after reset passes]"
test_pay_debt "$CLI_PATH paydebt --opid AM --from 20220101 --to 20230101 --format json" $VERBOSE "Pay Debt [JSON, after reset passes]"
test_logout "$CLI_PATH logout" $VERBOSE "logout [after reset passes]"
test_login "$CLI_PATH login --username admin --passw freepasses4all" $VERBOSE "login [correct credentials, after reset passes]"
test_login "$CLI_PATH login --username admin --passw freepasses4all" $VERBOSE "login [correct credentials, after reset passes (again)]"

## end

eko true GREEN "===================\nAll tests completed successfully\n"
