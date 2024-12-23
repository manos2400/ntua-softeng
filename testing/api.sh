#!/bin/bash

# Test the API using curl

## config

API_URL="http://localhost:9115/api"
PASSES_CSV_PATH="../back-end/src/data/passes-sample.csv"

## imports

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
source ./expected-outputs/get-stations.sh
source ./expected-outputs/get-operators.sh
source ./expected-outputs/get-debt.sh
source ./expected-outputs/pay-debt.sh
source ./expected-outputs/tollstats.sh
source ./expected-outputs/logout.sh

## runtime vars

VERBOSE=$1
AUTH_HEADER_BAD="X-OBSERVATORY-AUTH:11111111111111"
AUTH_HEADER_GOOD="set later in the script (after login)" # at login.sh

## driver

eko true YELLOW "Testing the API\n"

## tests

# ======================= Healthcheck ======================= #
test_healthcheck "curl -s -X GET $API_URL/admin/healthcheck" $VERBOSE "healthcheck"

# ======================= reset passes ======================= #
test_resetpasses "curl -s -X POST $API_URL/admin/resetpasses" $VERBOSE "resetpasses"

# ======================= resetstations ======================= #
test_resetstations "curl -s -X POST $API_URL/admin/resetstations" $VERBOSE "resetstations"

# ======================= login ======================= #
test_login "curl -s -X POST $API_URL/login -H 'Content-Type: application/x-www-form-urlencoded' -d username=admin&password=wrong" $VERBOSE "login [wrong pass]"
test_login "curl -s -X POST $API_URL/login -H 'Content-Type: application/x-www-form-urlencoded' -d username=wrong&password=freepasses4all" $VERBOSE "login [wrong username]"
test_login "curl -s -X POST $API_URL/login -H 'Content-Type: application/x-www-form-urlencoded' -d username=wrong&password=" $VERBOSE "login [wrong username, no password]"
test_login "curl -s -X POST $API_URL/login -H 'Content-Type: application/x-www-form-urlencoded' -d username=admin&password=" $VERBOSE "login [correct username, no password]"
test_login "curl -s -X POST $API_URL/login -H 'Content-Type: application/x-www-form-urlencoded' -d username=&password=" $VERBOSE "login [no username, no password]"
test_login "curl -s -X POST $API_URL/login -H 'Content-Type: application/x-www-form-urlencoded' -d username=&password=wrong" $VERBOSE "login [no username, wrong password]"
test_login "curl -s -X POST $API_URL/login -H 'Content-Type: application/x-www-form-urlencoded' -d username=&password=freepasses4all" $VERBOSE "login [no username, correct password]"
test_login "curl -s -X POST $API_URL/login -H 'Content-Type: application/x-www-form-urlencoded' -d username=" $VERBOSE "login [no username, no password field]"
test_login "curl -s -X POST $API_URL/login -H 'Content-Type: application/x-www-form-urlencoded'" $VERBOSE "login [no username and password fields]"
test_login "curl -s -X POST $API_URL/login -H 'Content-Type: application/x-www-form-urlencoded' -d username=admin&password=freepasses4all" $VERBOSE "login [correct credentials]"
test_login "curl -s -X POST $API_URL/login -H 'Content-Type: application/x-www-form-urlencoded' -d username=admin&password=freepasses4all" $VERBOSE "login [correct credentials (again)]"

eko $VERBOSE CYAN "got token: $AUTH_HEADER_GOOD\n"

# ======================= tollStationPasses ======================= #
test_tollStationPasses "curl -s -X GET $API_URL/tollStationPasses/AM03/20220101/20230101?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "tollStationPasses [JSON, good token]"
test_tollStationPasses "curl -s -X GET $API_URL/tollStationPasses/AM03/20220101/20230101?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "tollStationPasses [CSV, good token]"
test_tollStationPasses "curl -s -X GET $API_URL/tollStationPasses/AMBB/20220101/20230101?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "tollStationPasses [JSON, good token, wrong toll station]"
test_tollStationPasses "curl -s -X GET $API_URL/tollStationPasses/AMBB/20220101/20230101?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "tollStationPasses [CSV, good token, wrong toll station]"
test_tollStationPasses "curl -s -X GET $API_URL/tollStationPasses/AM03/20240101/20230101?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "tollStationPasses [JSON, good token, inverse dates]"
test_tollStationPasses "curl -s -X GET $API_URL/tollStationPasses/AM03/20240101/20230101?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "tollStationPasses [CSV, good token, inverse dates]"
test_tollStationPasses "curl -s -X GET $API_URL/tollStationPasses/AM03/20220101/20230101?format=json -H $AUTH_HEADER_BAD" $VERBOSE "tollStationPasses [JSON, bad token]"
test_tollStationPasses "curl -s -X GET $API_URL/tollStationPasses/AM03/1/1?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "tollStationPasses [JSON, bad dates]"
test_tollStationPasses "curl -s -X GET $API_URL/tollStationPasses/AM03/1/1?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "tollStationPasses [CSV, bad dates]"
test_tollStationPasses "curl -s -X GET $API_URL/tollStationPasses/AM03/20220101/20230101?format=csv -H $AUTH_HEADER_BAD" $VERBOSE "tollStationPasses [CSV, bad token]"
test_tollStationPasses "curl -s -X GET $API_URL/tollStationPasses/AM03/20220101/20230101?format=json" $VERBOSE "tollStationPasses [JSON, no token]"
test_tollStationPasses "curl -s -X GET $API_URL/tollStationPasses/AM03/20220101/20230101?format=csv" $VERBOSE "tollStationPasses [CSV, no token]"

# ======================= chargesBy ======================= #
test_chargesby "curl -s -X GET $API_URL/chargesBy/AM/20220101/20230101?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "chargesBy [JSON, good token]"
test_chargesby "curl -s -X GET $API_URL/chargesBy/AM/20220101/20230101?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "chargesBy [CSV, good token]"
test_chargesby "curl -s -X GET $API_URL/chargesBy/AM/20220101/20230101?format=json -H $AUTH_HEADER_BAD" $VERBOSE "chargesBy [JSON, bad token]"
test_chargesby "curl -s -X GET $API_URL/chargesBy/AM/20220101/20230101?format=csv -H $AUTH_HEADER_BAD" $VERBOSE "chargesBy [CSV, bad token]"
test_chargesby "curl -s -X GET $API_URL/chargesBy/AM/20220101/20230101?format=json" $VERBOSE "chargesBy [JSON, no token]"
test_chargesby "curl -s -X GET $API_URL/chargesBy/AM/20220101/20230101?format=csv" $VERBOSE "chargesBy [CSV, no token]"
test_chargesby "curl -s -X GET $API_URL/chargesBy/AM/202401/2023?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "chargesBy [JSON, bad dates]"
test_chargesby "curl -s -X GET $API_URL/chargesBy/AM/202401/2023?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "chargesBy [CSV, bad dates]"
test_chargesby "curl -s -X GET $API_URL/chargesBy/AM/1/1?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "chargesBy [JSON, bad dates]"
test_chargesby "curl -s -X GET $API_URL/chargesBy/AM/1/1?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "chargesBy [CSV, bad dates]"
test_chargesby "curl -s -X GET $API_URL/chargesBy/AA/202401/202301?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "chargesBy [JSON, wrong toll operator]"
test_chargesby "curl -s -X GET $API_URL/chargesBy/AA/202401/202301?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "chargesBy [CSV, wrong toll operator]"

# ======================= passesCost ======================= #
test_passescost "curl -s -X GET $API_URL/passesCost/AM/AM/20220101/20230101?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "passesCost [JSON, good token]"
test_passescost "curl -s -X GET $API_URL/passesCost/AM/AM/20220101/20230101?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "passesCost [CSV, good token]"
test_passescost "curl -s -X GET $API_URL/passesCost/AM/AM/20220101/20230101?format=json -H $AUTH_HEADER_BAD" $VERBOSE "passesCost [JSON, bad token]"
test_passescost "curl -s -X GET $API_URL/passesCost/AM/AM/20220101/20230101?format=csv -H $AUTH_HEADER_BAD" $VERBOSE "passesCost [CSV, bad token]"
test_passescost "curl -s -X GET $API_URL/passesCost/AM/AM/20220101/20230101?format=json" $VERBOSE "passesCost [JSON, no token]"
test_passescost "curl -s -X GET $API_URL/passesCost/AM/AM/20220101/20230101?format=csv" $VERBOSE "passesCost [CSV, no token]"
test_passescost "curl -s -X GET $API_URL/passesCost/AM/AM/202401/2023?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "passesCost [JSON, bad dates]"
test_passescost "curl -s -X GET $API_URL/passesCost/AM/AM/202401/2023?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "passesCost [CSV, bad dates]"
test_passescost "curl -s -X GET $API_URL/passesCost/AM/AM/1/1?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "passesCost [JSON, bad dates]"
test_passescost "curl -s -X GET $API_URL/passesCost/AM/AM/1/1?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "passesCost [CSV, bad dates]"
test_passescost "curl -s -X GET $API_URL/passesCost/AA/AM/202401/202301?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "passesCost [JSON, wrong toll operator]"
test_passescost "curl -s -X GET $API_URL/passesCost/AA/AM/202401/202301?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "passesCost [CSV, wrong toll operator]"
test_passescost "curl -s -X GET $API_URL/passesCost/AM/AA/202401/202301?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "passesCost [JSON, wrong 2nd toll operator]"
test_passescost "curl -s -X GET $API_URL/passesCost/AM/AA/202401/202301?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "passesCost [CSV, wrong 2nd toll operator]"

# ======================= passAnalysis ======================= #
test_passanalysis "curl -s -X GET $API_URL/passAnalysis/AM/AM/20220101/20230101?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "passAnalysis [JSON, good token]"
test_passanalysis "curl -s -X GET $API_URL/passAnalysis/AM/AM/20220101/20230101?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "passAnalysis [CSV, good token]"
test_passanalysis "curl -s -X GET $API_URL/passAnalysis/AM/AM/20220101/20230101?format=json -H $AUTH_HEADER_BAD" $VERBOSE "passAnalysis [JSON, bad token]"
test_passanalysis "curl -s -X GET $API_URL/passAnalysis/AM/AM/20220101/20230101?format=csv -H $AUTH_HEADER_BAD" $VERBOSE "passAnalysis [CSV, bad token]"
test_passanalysis "curl -s -X GET $API_URL/passAnalysis/AM/AM/20220101/20230101?format=json" $VERBOSE "passAnalysis [JSON, no token]"
test_passanalysis "curl -s -X GET $API_URL/passAnalysis/AM/AM/20220101/20230101?format=csv" $VERBOSE "passAnalysis [CSV, no token]"
test_passanalysis "curl -s -X GET $API_URL/passAnalysis/AM/AM/202401/2023?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "passAnalysis [JSON, bad dates]"
test_passanalysis "curl -s -X GET $API_URL/passAnalysis/AM/AM/202401/2023?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "passAnalysis [CSV, bad dates]"
test_passanalysis "curl -s -X GET $API_URL/passAnalysis/AM/AM/1/1?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "passAnalysis [JSON, bad dates]"
test_passanalysis "curl -s -X GET $API_URL/passAnalysis/AM/AM/1/1?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "passAnalysis [CSV, bad dates]"
test_passanalysis "curl -s -X GET $API_URL/passAnalysis/AA/AM/202401/202301?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "passAnalysis [JSON, wrong toll operator]"
test_passanalysis "curl -s -X GET $API_URL/passAnalysis/AA/AM/202401/202301?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "passAnalysis [CSV, wrong toll operator]"
test_passanalysis "curl -s -X GET $API_URL/passAnalysis/AM/AA/202401/202301?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "passAnalysis [JSON, wrong 2nd toll operator]"
test_passanalysis "curl -s -X GET $API_URL/passAnalysis/AM/AA/202401/202301?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "passAnalysis [CSV, wrong 2nd toll operator]"
test_passanalysis "curl -s -X GET $API_URL/passAnalysis/AM/AM/202401/202301?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "passAnalysis [JSON, inverse dates]"
test_passanalysis "curl -s -X GET $API_URL/passAnalysis/AM/AM/202401/202301?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "passAnalysis [CSV, inverse dates]"

# ======================= Admin: User Modification ======================= #
test_admin_user_mod "curl -s -X POST $API_URL/admin/users -H $AUTH_HEADER_GOOD -H 'Content-Type: application/x-www-form-urlencoded' -d username=test1&password=test2" $VERBOSE "Admin: User Modification [good token]"
test_admin_user_mod "curl -s -X POST $API_URL/admin/users -H $AUTH_HEADER_BAD -H 'Content-Type: application/x-www-form-urlencoded' -d username=test1&password=test2" $VERBOSE "Admin: User Modification [bad token]"
test_admin_user_mod "curl -s -X POST $API_URL/admin/users -H 'Content-Type: application/x-www-form-urlencoded' -d username=test1&password=test2" $VERBOSE "Admin: User Modification [no token]"
test_admin_user_mod "curl -s -X POST $API_URL/admin/users -H $AUTH_HEADER_GOOD -H 'Content-Type: application/x-www-form-urlencoded' -d username=&password=" $VERBOSE "Admin: User Modification [empty fields]"
test_admin_user_mod "curl -s -X POST $API_URL/admin/users -H $AUTH_HEADER_GOOD -H 'Content-Type: application/x-www-form-urlencoded' -d username=test1&password=" $VERBOSE "Admin: User Modification [empty password]"
test_admin_user_mod "curl -s -X POST $API_URL/admin/users -H $AUTH_HEADER_GOOD -H 'Content-Type: application/x-www-form-urlencoded' -d username=&password=test2" $VERBOSE "Admin: User Modification [empty username]"
test_admin_user_mod "curl -s -X POST $API_URL/admin/users -H $AUTH_HEADER_GOOD -H 'Content-Type: application/x-www-form-urlencoded' -d username=test" $VERBOSE "Admin: User Modification [no password field]"
test_admin_user_mod "curl -s -X POST $API_URL/admin/users -H $AUTH_HEADER_GOOD -H 'Content-Type: application/x-www-form-urlencoded' -d password=test" $VERBOSE "Admin: User Modification [no username field]"
test_admin_user_mod "curl -s -X POST $API_URL/admin/users -H $AUTH_HEADER_GOOD -H 'Content-Type: application/x-www-form-urlencoded'" $VERBOSE "Admin: User Modification [no fields]"

# ======================= Admin: List Users ======================= #
test_admin_list_users "curl -s -X GET $API_URL/admin/users -H $AUTH_HEADER_GOOD" $VERBOSE "Admin: List Users [good token]"
test_admin_list_users "curl -s -X GET $API_URL/admin/users -H $AUTH_HEADER_BAD" $VERBOSE "Admin: List Users [bad token]"
test_admin_list_users "curl -s -X GET $API_URL/admin/users" $VERBOSE "Admin: List Users [no token]"

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
test_admin_add_passes "curl -s -X POST $API_URL/admin/addpasses -H $AUTH_HEADER_GOOD -H 'Content-Type: multipart/form-data' -F file=@$PASSES_CSV_PATH;type=text/csv" $VERBOSE "Admin: Add Passes [good token]"
test_admin_add_passes "curl -s -X POST $API_URL/admin/addpasses -H $AUTH_HEADER_BAD -H 'Content-Type: multipart/form-data' -F 'file=@$PASSES_CSV_PATH;type=text/csv'" $VERBOSE "Admin: Add Passes [bad token]"
test_admin_add_passes "curl -s -X POST $API_URL/admin/addpasses -H 'Content-Type: multipart/form-data' -F 'file=@$PASSES_CSV_PATH;type=text/csv'" $VERBOSE "Admin: Add Passes [no token]"

# ======================= Get Stations ======================= #
test_get_stations "curl -s -X GET $API_URL/stations -H $AUTH_HEADER_GOOD" $VERBOSE "Get Stations [good token]"
test_get_stations "curl -s -X GET $API_URL/stations -H $AUTH_HEADER_BAD" $VERBOSE "Get Stations [bad token]"
test_get_stations "curl -s -X GET $API_URL/stations" $VERBOSE "Get Stations [no token]"

# ======================= Get Operators ======================= #
test_get_operators "curl -s -X GET $API_URL/operators -H $AUTH_HEADER_GOOD" $VERBOSE "Get Operators [good token]"
test_get_operators "curl -s -X GET $API_URL/operators -H $AUTH_HEADER_BAD" $VERBOSE "Get Operators [bad token]"
test_get_operators "curl -s -X GET $API_URL/operators" $VERBOSE "Get Operators [no token]"

# ======================= Get Debt ======================= #
test_get_debt "curl -s -X GET $API_URL/getDebt/AM/20220101/20220101?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "Get Debt [JSON, good token]"
test_get_debt "curl -s -X GET $API_URL/getDebt/AM/20220101/20220101?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "Get Debt [CSV, good token]"
test_get_debt "curl -s -X GET $API_URL/getDebt/AM/20220101/20220101?format=json -H $AUTH_HEADER_BAD" $VERBOSE "Get Debt [JSON, bad token]"
test_get_debt "curl -s -X GET $API_URL/getDebt/AM/20220101/20220101?format=csv -H $AUTH_HEADER_BAD" $VERBOSE "Get Debt [CSV, bad token]"
test_get_debt "curl -s -X GET $API_URL/getDebt/AM/20220101/20220101?format=json" $VERBOSE "Get Debt [JSON, no token]"
test_get_debt "curl -s -X GET $API_URL/getDebt/AM/20220101/20220101?format=csv" $VERBOSE "Get Debt [CSV, no token]"
test_get_debt "curl -s -X GET $API_URL/getDebt/AM/202401/2023?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "Get Debt [JSON, bad dates]"
test_get_debt "curl -s -X GET $API_URL/getDebt/AM/202401/2023?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "Get Debt [CSV, bad dates]"
test_get_debt "curl -s -X GET $API_URL/getDebt/AM/1/1?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "Get Debt [JSON, bad dates]"
test_get_debt "curl -s -X GET $API_URL/getDebt/AM/1/1?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "Get Debt [CSV, bad dates]"
test_get_debt "curl -s -X GET $API_URL/getDebt/AA/202401/202301?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "Get Debt [JSON, wrong toll operator]"
test_get_debt "curl -s -X GET $API_URL/getDebt/AA/202401/202301?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "Get Debt [CSV, wrong toll operator]"

# ======================= Pay Debt ======================= #
test_pay_debt "curl -s -X PUT $API_URL/payDebt/AM/AM/20220101/20220101?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "Pay Debt [JSON, zero debt]"
test_pay_debt "curl -s -X PUT $API_URL/payDebt/AM/AM/20220101/20230101?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "Pay Debt [JSON, good token]"
test_pay_debt "curl -s -X PUT $API_URL/payDebt/AM/AM/20220101/20230101?format=json -H $AUTH_HEADER_BAD" $VERBOSE "Pay Debt [JSON, bad token]"
test_pay_debt "curl -s -X PUT $API_URL/payDebt/AM/AM/20220101/20230101?format=json" $VERBOSE "Pay Debt [JSON, no token]"
test_pay_debt "curl -s -X PUT $API_URL/payDebt/AM/AM/202401/2023?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "Pay Debt [JSON, bad dates]"
test_pay_debt "curl -s -X PUT $API_URL/payDebt/AM/AM/1/1?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "Pay Debt [JSON, bad dates]"
test_pay_debt "curl -s -X PUT $API_URL/payDebt/AA/AM/202401/202301?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "Pay Debt [JSON, wrong toll operator]"
test_pay_debt "curl -s -X PUT $API_URL/payDebt/EG/AA/202401/202301?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "Pay Debt [JSON, wrong toll operator (2nd)]"
test_pay_debt "curl -s -X PUT $API_URL/payDebt/AM/AM/20220101/20220101?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "Pay Debt [JSON, debt already paid]"
test_pay_debt "curl -s -X PUT $API_URL/payDebt/AM/AM/20220101/20220101?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "Pay Debt [JSON, debt already paid (again)]"
test_pay_debt "curl -s -X PUT $API_URL/payDebt/AM/EG/20220101/20220101?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "Pay Debt [JSON, pay to other op]"
test_pay_debt "curl -s -X PUT $API_URL/payDebt/AM/EG/20220101/20220101?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "Pay Debt [JSON, pay to other op (again)]"

# ======================= Toll Stats ======================= #
test_tollstats "curl -s -X GET $API_URL/tollStats/AM/20220101/20230101?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "Toll Stats [JSON, good token]"
test_tollstats "curl -s -X GET $API_URL/tollStats/AM/20220101/20230101?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "Toll Stats [CSV, good token]"
test_tollstats "curl -s -X GET $API_URL/tollStats/AM/20220101/20230101?format=json -H $AUTH_HEADER_BAD" $VERBOSE "Toll Stats [JSON, bad token]"
test_tollstats "curl -s -X GET $API_URL/tollStats/AM/20220101/20230101?format=csv -H $AUTH_HEADER_BAD" $VERBOSE "Toll Stats [CSV, bad token]"
test_tollstats "curl -s -X GET $API_URL/tollStats/AM/20220101/20230101?format=json" $VERBOSE "Toll Stats [JSON, no token]"
test_tollstats "curl -s -X GET $API_URL/tollStats/AM/20220101/20230101?format=csv" $VERBOSE "Toll Stats [CSV, no token]"
test_tollstats "curl -s -X GET $API_URL/tollStats/AM/202401/2023?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "Toll Stats [JSON, bad dates]"
test_tollstats "curl -s -X GET $API_URL/tollStats/AM/202401/2023?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "Toll Stats [CSV, bad dates]"
test_tollstats "curl -s -X GET $API_URL/tollStats/AM/1/1?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "Toll Stats [JSON, bad dates]"
test_tollstats "curl -s -X GET $API_URL/tollStats/AM/1/1?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "Toll Stats [CSV, bad dates]"
test_tollstats "curl -s -X GET $API_URL/tollStats/AA/202401/202301?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "Toll Stats [JSON, wrong toll operator]"
test_tollstats "curl -s -X GET $API_URL/tollStats/AA/202401/202301?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "Toll Stats [CSV, wrong toll operator]"

# ======================= logout ======================= #
test_logout "curl -s -X POST $API_URL/logout -H $AUTH_HEADER_BAD" $VERBOSE "logout [bad token]"
test_logout "curl -s -X POST $API_URL/logout -H $AUTH_HEADER_GOOD" $VERBOSE "logout [good token]"
test_logout "curl -s -X POST $API_URL/logout" $VERBOSE "logout [no token]"
test_logout "curl -s -X POST $API_URL/logout -H $AUTH_HEADER_GOOD" $VERBOSE "logout [good token (again)]"

# ======================= tests after reset passes ======================= #
curl -s -X POST $API_URL/admin/resetpasses -H $AUTH_HEADER_GOOD >> /dev/null
test_healthcheck "curl -s -X GET $API_URL/admin/healthcheck" $VERBOSE "healthcheck [after reset passes]"
test_resetstations "curl -s -X POST $API_URL/admin/resetstations" $VERBOSE "resetstations [after reset passes]"
test_tollStationPasses "curl -s -X GET $API_URL/tollStationPasses/AM03/20220101/20230101?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "tollStationPasses [JSON, good token, after reset passes]"
test_tollStationPasses "curl -s -X GET $API_URL/tollStationPasses/AM03/20220101/20230101?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "tollStationPasses [CSV, good token, after reset passes]"
test_chargesby "curl -s -X GET $API_URL/chargesBy/AM/20220101/20230101?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "chargesBy [JSON, good token, after reset passes]"
test_chargesby "curl -s -X GET $API_URL/chargesBy/AM/20220101/20230101?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "chargesBy [CSV, good token, after reset passes]"
test_passescost "curl -s -X GET $API_URL/passesCost/AM/AM/20220101/20230101?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "passesCost [JSON, good token, after reset passes]"
test_passescost "curl -s -X GET $API_URL/passesCost/AM/AM/20220101/20230101?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "passesCost [CSV, good token, after reset passes]"
test_passanalysis "curl -s -X GET $API_URL/passAnalysis/AM/AM/20220101/20230101?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "passAnalysis [JSON, good token, after reset passes]"
test_passanalysis "curl -s -X GET $API_URL/passAnalysis/AM/AM/20220101/20230101?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "passAnalysis [CSV, good token, after reset passes]"
test_get_debt "curl -s -X GET $API_URL/getDebt/AM/20220101/20220101?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "Get Debt [JSON, good token, after reset passes]"
test_get_debt "curl -s -X GET $API_URL/getDebt/AM/20220101/20220101?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "Get Debt [CSV, good token, after reset passes]"
test_pay_debt "curl -s -X PUT $API_URL/payDebt/AM/AM/20220101/20230101?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "Pay Debt [JSON, good token, after reset passes]"
test_pay_debt "curl -s -X PUT $API_URL/payDebt/AM/AM/20220101/20230101?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "Pay Debt [JSON, good token, after reset passes (again)]"
test_tollstats "curl -s -X GET $API_URL/tollStats/AM/20220101/20230101?format=json -H $AUTH_HEADER_GOOD" $VERBOSE "Toll Stats [JSON, good token, after reset passes]"
test_tollstats "curl -s -X GET $API_URL/tollStats/AM/20220101/20230101?format=csv -H $AUTH_HEADER_GOOD" $VERBOSE "Toll Stats [CSV, good token, after reset passes]"
test_logout "curl -s -X POST $API_URL/logout -H $AUTH_HEADER_GOOD" $VERBOSE "logout [good token, after reset passes]"
test_login "curl -s -X POST $API_URL/login -H 'Content-Type: application/x-www-form-urlencoded' -d username=admin&password=freepasses4all" $VERBOSE "login [correct credentials, after reset passes]"
test_login "curl -s -X POST $API_URL/login -H 'Content-Type: application/x-www-form-urlencoded' -d username=admin&password=freepasses4all" $VERBOSE "login [correct credentials, after reset passes (again)]"

## end

eko true GREEN "===================\nAll tests completed successfully\n"
