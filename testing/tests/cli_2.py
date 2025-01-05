import unittest
import os

import utils.config as config
from utils.cli_commands import get_token, run_cli_command

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# ~~~~~~~~~~~~~~~~~~~~~ PART 2: TESTS POPULATED WITH PASSES ~~~~~~~~~~~~~~~~~~~~~ #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

class CLI(unittest.TestCase):

    @classmethod
    def setUpClass(cls):

        out, err, code = run_cli_command(cls, "login --username admin --passw freepasses4all")

        instance = cls()
        if not os.path.isfile(config.PASSES_SAMPLE_FILE):
            instance.fail(f"File not found: {config.PASSES_SAMPLE_FILE}")
        out, err, code = run_cli_command(instance, f"admin --addpasses --source {config.PASSES_SAMPLE_FILE}")
        if code != 0:
            print("Failed to add passes")
            exit(1)

    # ======================= Populated tests ======================= #

    def test_healthcheck_populated(self):
        out, err, code = run_cli_command(self, "healthcheck")
        self.assertEqual(code, 0)
        self.assertIn('n_stations', out)
        self.assertIn('n_tags', out)
        self.assertIn('n_passes', out)
        self.assertIsInstance(out['n_stations'], int)
        self.assertIsInstance(out['n_tags'], int)
        self.assertIsInstance(out['n_passes'], int)

    def test_tollstationpasses_good_token_json_format_populated(self):
        out, err, code = run_cli_command(self, "tollstationpasses --station AM03 --from 20220101 --to 20230101 --format json")
        self.assertEqual(code, 0)
        self.assertIn('stationID', out)
        self.assertIn('stationOperator', out)
        self.assertIn('periodFrom', out)
        self.assertIn('periodTo', out)
        self.assertIn('n_passes', out)
        self.assertIsInstance(out['n_passes'], int)
        self.assertIn('passList', out)
        self.assertEqual(out['stationID'], "AM03")
        self.assertEqual(out['stationOperator'], "aegeanmotorway")
        self.assertEqual(out['periodFrom'], "2022-01-01 00:00")
        self.assertEqual(out['periodTo'], "2023-01-01 23:59")
        self.assertTrue(isinstance(out['n_passes'], int))
        self.assertIsInstance(out['passList'], list)
        self.assertGreater(len(out['passList']), 0, "passList should not be empty")

    def test_tollstationpasses_good_token_csv_format_populated(self):
        out, err, code = run_cli_command(self, "tollstationpasses --station AM03 --from 20220101 --to 20230101 --format csv")
        self.assertEqual(code, 0)
        self.assertTrue("stationID,stationOperator,requestTimestamp,periodFrom,periodTo,n_passes,passID,timestamp,tagID,tagProvider,passType,passCharge" in out)
        lines = out.strip().split('\n')
        expected_line_count = 12
        self.assertEqual(len(lines), expected_line_count, f"CSV should contain exactly {expected_line_count} lines")
        expected_length = 1369
        self.assertEqual(len(out), expected_length, f"CSV response should have exactly {expected_length} characters")

    def test_tollstationpasses_good_token_inverse_dates_json_format_populated(self):
        out, err, code = run_cli_command(self, "tollstationpasses --station AM03 --from 20240101 --to 20230101 --format json")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Invalid date range\n")

    def test_tollstationpasses_good_token_inverse_dates_csv_format_populated(self):
        out, err, code = run_cli_command(self, "tollstationpasses --station AM03 --from 20240101 --to 20230101 --format csv")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Invalid date range\n")

    def test_chargesby_good_token_json_format_populated(self):
        out, err, code = run_cli_command(self, "chargesby --opid AM --from 20220101 --to 20230101 --format json")
        self.assertEqual(code, 0)
        self.assertIn('tollOpID', out)
        self.assertIn('requestTimestamp', out)
        self.assertIn('periodFrom', out)
        self.assertIn('periodTo', out)
        self.assertIn('vOpList', out)

    def test_chargesby_good_token_csv_format_populated(self):
        out, err, code = run_cli_command(self, "chargesby --opid AM --from 20220101 --to 20230101 --format csv")
        self.assertEqual(code, 0)
        self.assertIn('tollOpID,requestTimestamp,periodFrom,periodTo,visitingOpID,n_passes,passesCost', out)

    def test_chargesby_good_token_inverse_dates_json_format_populated(self):
        out, err, code = run_cli_command(self, "chargesby --opid AM --from 20240101 --to 20230101 --format json")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Invalid date range\n")

    def test_chargesby_good_token_inverse_dates_csv_format_populated(self):
        out, err, code = run_cli_command(self, "chargesby --opid AM --from 20240101 --to 20230101 --format csv")
        self.assertEqual(code, 0)
        self.assertEqual(err, "Error: 400 - Invalid date range\n")

    def test_passes_cost_good_token_json_format_populated(self):
        out, err, code = run_cli_command(self, "passescost --stationop AM --tagop EG --from 20220101 --to 20230101 --format json")
        self.assertEqual(code, 0)
        self.assertIn('tollOpID', out)
        self.assertIn('tagOpID', out)
        self.assertIn('requestTimestamp', out)
        self.assertIn('periodFrom', out)
        self.assertIn('periodTo', out)
        self.assertIn('n_passes', out)
        self.assertIn('passesCost', out)

    def test_passes_cost_good_token_csv_format_populated(self):
        out, err, code = run_cli_command(self, "passescost --stationop AM --tagop EG --from 20220101 --to 20230101 --format csv")
        self.assertEqual(code, 0)
        self.assertIn('tollOpID,tagOpID,requestTimestamp,periodFrom,periodTo,n_passes,passesCost', out)

    def test_pass_analysis_good_token_json_format_populated(self):
        out, err, code = run_cli_command(self, "passanalysis --stationop AM --tagop EG --from 20220101 --to 20230101 --format json")
        self.assertEqual(code, 0)
        self.assertIn('stationOpID', out)
        self.assertIn('tagOpID', out)
        self.assertIn('requestTimestamp', out)
        self.assertIn('periodFrom', out)
        self.assertIn('periodTo', out)
        self.assertIn('n_passes', out)
        self.assertIn('passList', out)
        self.assertEqual(out['stationOpID'], "AM")
        self.assertEqual(out['tagOpID'], "EG")
        self.assertEqual(out['periodFrom'], "2022-01-01 00:00")
        self.assertEqual(out['periodTo'], "2023-01-01 23:59")
        self.assertTrue(isinstance(out['n_passes'], int))
        self.assertIsInstance(out['passList'], list)
        self.assertGreater(len(out['passList']), 0, "passList should not be empty")

    def test_pass_analysis_good_token_csv_format_populated(self):
        out, err, code = run_cli_command(self, "passanalysis --stationop AM --tagop EG --from 20220101 --to 20230101 --format csv")
        self.assertEqual(code, 0)
        self.assertTrue("stationOpID,tagOpID,requestTimestamp,periodFrom,periodTo,n_passes,passID,stationID,timestamp,tagID,passCharge" in out)
        lines = out.strip().split('\n')
        expected_line_count = 15
        self.assertEqual(len(lines), expected_line_count, f"CSV should contain exactly {expected_line_count} lines")
        expected_length = 1601
        self.assertEqual(len(out), expected_length, f"CSV response should have exactly {expected_length} characters")

if __name__ == "__main__":
    unittest.main()



    
    
