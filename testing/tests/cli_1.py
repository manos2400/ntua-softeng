import unittest
import requests
import os

import utils.config as config
from utils.cli_commands import get_token, run_cli_command

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# ~~~~~~~~~~~~~~~~~~~~~ PART 1: TESTS WITHOUT PASSES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

class CLI(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.token = get_token()
        cls.assertIsNotNone(cls.token, "Login failed, no token received")
        response = requests.post(f"{config.API_URL}/admin/resetpasses")
        if response.json()['status'] != 'OK':
            print("Failed to reset passes")
            exit(1)
        
        out, err, code = run_cli_command(cls, "login --username admin --passw freepasses4all")

    # ~~~~~~~~~~~~~~~~~~~~~ HEALTH CHECK ~~~~~~~~~~~~~~~~~~~~~ #

    def test_healthcheck(self):
        out, err, code = run_cli_command(self, "healthcheck")
        self.assertEqual(code, 0)
        self.assertEqual(out['status'], 'OK')
        self.assertEqual(out['dbconnection'], 'connected')
        self.assertEqual(out['n_stations'], 253)
        self.assertEqual(out['n_tags'], 0)
        self.assertEqual(out['n_passes'], 0)

    # ~~~~~~~~~~~~~~~~~~~~~ RESET PASSES ~~~~~~~~~~~~~~~~~~~~~ #

    def test_resetpasses(self):
        out, err, code = run_cli_command(self, "resetpasses")
        self.assertEqual(code, 0)
        self.assertEqual(out['status'], 'OK')

    # ~~~~~~~~~~~~~~~~~~~~~ RESET STATIONS ~~~~~~~~~~~~~~~~~~~~~ #

    def test_resetstations(self):
        out, err, code = run_cli_command(self, "resetstations")
        self.assertEqual(code, 0)
        self.assertEqual(out['status'], 'OK')

    # ~~~~~~~~~~~~~~~~~~~~~ LOGIN ~~~~~~~~~~~~~~~~~~~~~ #

    def test_login_wrong_password(self):
        out, err, code = run_cli_command(self, "login --username admin --passw WRONG")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 401 - Invalid username or password\n")

    def test_login_wrong_username(self):
        out, err, code = run_cli_command(self, "login --username WRONG --passw freepasses4all")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 401 - Invalid username or password\n")

    def test_login_wrong_username_no_password(self):
        out, err, code = run_cli_command(self, "login --username WRONG --passw ")
        self.assertEqual(code, 1)
        self.assertEqual(err, "error: option '--passw <password>' argument missing\n")

    def test_login_correct_username_no_password(self):
        out, err, code = run_cli_command(self, "login --username admin --passw ")
        self.assertEqual(code, 1)
        self.assertEqual(err, "error: option '--passw <password>' argument missing\n")

    def test_login_no_username_no_password(self):
        out, err, code = run_cli_command(self, "login --username  --passw ")
        self.assertEqual(code, 1)
        self.assertEqual(err, "error: required option '--passw <password>' not specified\n")

    def test_login_no_username_wrong_password(self):
        out, err, code = run_cli_command(self, "login --username  --passw WRONG")
        self.assertEqual(code, 1)
        self.assertEqual(err, "error: required option '--passw <password>' not specified\n")

    def test_login_no_username_correct_password(self):
        out, err, code = run_cli_command(self, "login --username  --passw freepasses4all")
        self.assertEqual(code, 1)
        self.assertEqual(err, "error: required option '--passw <password>' not specified\n")

    def test_login_no_username_and_password_fields(self):
        out, err, code = run_cli_command(self, "login")
        self.assertEqual(code, 1)
        self.assertEqual(err, "error: required option '--username <username>' not specified\n")

    def test_login_correct_credentials(self):
        out, err, code = run_cli_command(self, "login --username admin --passw freepasses4all")
        self.assertEqual(code, 0)
        self.assertIn('token', out)

    def test_login_correct_credentials_no_username_field(self):
        out, err, code = run_cli_command(self, "login --passw freepasses4all")
        self.assertEqual(code, 1)
        self.assertEqual(err, "error: required option '--username <username>' not specified\n")

    def test_login_correct_credentials_no_password_field(self):
        out, err, code = run_cli_command(self, "login --username admin")
        self.assertEqual(code, 1)
        self.assertEqual(err, "error: required option '--passw <password>' not specified\n")

    def test_login_correct_credentials_again(self):
        out, err, code = run_cli_command(self, "login --username admin --passw freepasses4all")
        self.assertEqual(code, 0)
        self.assertIn('token', out)
        out, err, code = run_cli_command(self, "login --username admin --passw freepasses4all")
        self.assertEqual(code, 0)
        self.assertIn('token', out)

    # ======================= tollStationPasses ======================= #

    def test_tollStationPasses_json(self):
        out, err, code = run_cli_command(self, "tollstationpasses --station AM03 --from 20220101 --to 20230101 --format json")
        print(out)
        self.assertEqual(code, 0)
        self.assertIn('', out)

    def test_tollStationPasses_csv(self):
        out, err, code = run_cli_command(self, "tollstationpasses --station AM03 --from 20220101 --to 20230101 --format csv")
        self.assertEqual(code, 0)
        self.assertIn('\n', out)

    def test_tollStationPasses_wrong_station_json(self):
        out, err, code = run_cli_command(self, "tollstationpasses --station AMBB --from 20220101 --to 20230101 --format json")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Toll station not found\n")

    def test_tollStationPasses_wrong_station_csv(self):
        out, err, code = run_cli_command(self, "tollstationpasses --station AMBB --from 20220101 --to 20230101 --format csv")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Toll station not found\n")

    def test_tollStationPasses_inverse_dates_json(self):
        out, err, code = run_cli_command(self, "tollstationpasses --station AM03 --from 20240101 --to 20230101 --format json")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Invalid date range\n")

    def test_tollStationPasses_inverse_dates_csv(self):
        out, err, code = run_cli_command(self, "tollstationpasses --station AM03 --from 20240101 --to 20230101 --format csv")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Invalid date range\n")

    def test_tollStationPasses_bad_dates_json(self):
        out, err, code = run_cli_command(self, "tollstationpasses --station AM03 --from 1 --to 1 --format json")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Invalid date\n")

    def test_tollStationPasses_bad_dates_csv(self):
        out, err, code = run_cli_command(self, "tollstationpasses --station AM03 --from 1 --to 1 --format csv")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Invalid date\n")

    # ======================= chargesBy ======================= #

    def test_chargesby_json(self):
        out, err, code = run_cli_command(self, "chargesby --opid AM --from 20220101 --to 20230101 --format json")
        self.assertEqual(code, 0)
        self.assertIn('', out)

    def test_chargesby_csv(self):
        out, err, code = run_cli_command(self, "chargesby --opid AM --from 20220101 --to 20230101 --format csv")
        self.assertEqual(code, 0)
        self.assertIn('', out)

    def test_chargesby_bad_dates_json(self):
        out, err, code = run_cli_command(self, "chargesby --opid AM --from 20240101 --to 20230101 --format json")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Invalid date range\n")

    def test_chargesby_bad_dates_csv(self):
        out, err, code = run_cli_command(self, "chargesby --opid AM --from 20240101 --to 20230101 --format csv")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Invalid date range\n")

    def test_chargesby_wrong_toll_operator_json(self):
        out, err, code = run_cli_command(self, "chargesby --opid AA --from 20220101 --to 20230101 --format json")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Toll operator not found\n")

    def test_chargesby_wrong_toll_operator_csv(self):
        out, err, code = run_cli_command(self, "chargesby --opid AA --from 20220101 --to 20230101 --format csv")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Toll operator not found\n")

    # ======================= passesCost ======================= #

    def test_passescost_json(self):
        out, err, code = run_cli_command(self, "passescost --stationop AM --tagop AM --from 20220101 --to 20230101 --format json")
        self.assertEqual(code, 0)
        self.assertEqual(out['tollOpID'], 'AM')
        self.assertEqual(out['tagOpID'], 'AM')
        self.assertEqual(out['periodFrom'], '2022-01-01')
        self.assertEqual(out['periodTo'], '2023-01-01')
        self.assertEqual(out['n_passes'], 0)
        self.assertEqual(out['passesCost'], 0)

    def test_passescost_csv(self):
        out, err, code = run_cli_command(self, "passescost --stationop AM --tagop AM --from 20220101 --to 20230101 --format csv")
        self.assertEqual(code, 0)
        self.assertIn(',2022-01-01,2023-01-01,0,0\n\n', out)
        self.assertIn('tollOpID,tagOpID,requestTimestamp,periodFrom,periodTo,n_passes,passesCost\nAM,AM,', out)

    def test_passescost_bad_dates_json(self):
        out, err, code = run_cli_command(self, "passescost --stationop AM --tagop AM --from 202401 --to 2023 --format json")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Invalid date\n")

    def test_passescost_bad_dates_csv(self):
        out, err, code = run_cli_command(self, "passescost --stationop AM --tagop AM --from 202401 --to 2023 --format csv")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Invalid date\n")

    def test_passescost_wrong_toll_operator_json(self):
        out, err, code = run_cli_command(self, "passescost --stationop AA --tagop AM --from 20220101 --to 20230101 --format json")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Toll or tag operator not found\n")

    def test_passescost_wrong_toll_operator_csv(self):
        out, err, code = run_cli_command(self, "passescost --stationop AA --tagop AM --from 20220101 --to 20230101 --format csv")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Toll or tag operator not found\n")

    # ======================= passAnalysis ======================= #

    def test_passanalysis_json(self):
        out, err, code = run_cli_command(self, "passanalysis --stationop AM --tagop AM --from 20220101 --to 20230101 --format json")
        self.assertEqual(code, 0)
        self.assertIn('', out)

    def test_passanalysis_csv(self):
        out, err, code = run_cli_command(self, "passanalysis --stationop AM --tagop AM --from 20220101 --to 20230101 --format csv")
        self.assertEqual(code, 0)
        self.assertIn('', out)

    def test_passanalysis_bad_dates_json(self):
        out, err, code = run_cli_command(self, "passanalysis --stationop AM --tagop AM --from 202401 --to 2023 --format json")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Invalid date\n")

    def test_passanalysis_bad_dates_csv(self):
        out, err, code = run_cli_command(self, "passanalysis --stationop AM --tagop AM --from 202401 --to 2023 --format csv")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Invalid date\n")

    def test_passanalysis_wrong_toll_operator_json(self):
        out, err, code = run_cli_command(self, "passanalysis --stationop AA --tagop AM --from 20220101 --to 20230101 --format json")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Station or tag operator not found\n")

    def test_passanalysis_wrong_toll_operator_csv(self):
        out, err, code = run_cli_command(self, "passanalysis --stationop AA --tagop AM --from 20220101 --to 20230101 --format csv")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Station or tag operator not found\n")

    # ======================= Admin: User Modification ======================= #

    def test_admin_user_mod(self):
        out, err, code = run_cli_command(self, "admin --usermod --username test1 --passw test2")
        self.assertEqual(code, 0)
        self.assertEqual(out['status'], "OK")

    def test_admin_user_mod_empty_fields(self):
        out, err, code = run_cli_command(self, "admin --usermod --username '' --passw ''")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Username and password are required\n")

    def test_admin_user_mod_empty_password(self):
        out, err, code = run_cli_command(self, "admin --usermod --username test1 --passw ''")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Username and password are required\n")

    def test_admin_user_mod_empty_username(self):
        out, err, code = run_cli_command(self, "admin --usermod --username '' --passw test2")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Username and password are required\n")

    def test_admin_user_mod_no_password_field(self):
        out, err, code = run_cli_command(self, "admin --usermod --username test")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Username and password are required\n")

    def test_admin_user_mod_no_username_field(self):
        out, err, code = run_cli_command(self, "admin --usermod --passw test")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Username and password are required\n")

    def test_admin_user_mod_no_fields(self):
        out, err, code = run_cli_command(self, "admin --usermod")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Username and password are required\n")

    # ======================= Admin: List Users ======================= #

    def test_admin_list_users(self):
        out, err, code = run_cli_command(self, "admin --users")
        self.assertEqual(code, 0)
        self.assertIn('admin', out)

    # ======================= Admin: Add Passes ======================= #

    def test_admin_add_passes(self):
        if not os.path.isfile(config.PASSES_SAMPLE_FILE):
            self.fail(f"File not found: {config.PASSES_SAMPLE_FILE}")
        out, err, code = run_cli_command(self, f"admin --addpasses --source {config.PASSES_SAMPLE_FILE}")
        self.assertEqual(code, 0)
        self.assertEqual(out['status'], "OK")

        # reset, for this testing part
        response = requests.post(f"{config.API_URL}/admin/resetpasses")
        if response.json()['status'] != 'OK':
            print("Failed to reset passes")
            exit(1)


if __name__ == "__main__":
    unittest.main()



    
    
