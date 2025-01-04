import unittest
import requests
import csv
from io import StringIO

import utils.config as config
from utils.api_requests import Reqs, get_token_from_login

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# ~~~~~~~~~~~~~~~~~~~~~ PART 2: TESTS POPULATED WITH PASSES ~~~~~~~~~~~~~~~~~~~~~ #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

class API(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.api_client = Reqs()
        cls.token = get_token_from_login()  # Store the token at the class level
        cls.assertIsNotNone(cls.token, "Login failed, no token received")  # Use cls to refer to class attributes
        response = requests.post(f"{config.API_URL}/admin/resetpasses")
        if response.json().get('status') != 'OK':
            print("Failed to reset passes")
            exit(1)
        instance = cls()
        response_json, status_code = cls.api_client.add_passes_request(
            cls.token, config.PASSES_SAMPLE_FILE
        )
        if status_code != 200:
            print("Failed to add passes")
            exit(1)


    # ~~~~~~~~~~~~~~~~~~~~~ POPULATED TESTS ~~~~~~~~~~~~~~~~~~~~~ #
    
    def test_healthcheck_populated(self):
        response = requests.get(f"{config.API_URL}/admin/healthcheck")
        if response.status_code == 200:
            json_response = response.json()
            self.assertIn('n_stations', json_response)
            self.assertIn('n_tags', json_response)
            self.assertIn('n_passes', json_response)
            self.assertIsInstance(json_response['n_stations'], int)
            self.assertIsInstance(json_response['n_tags'], int)
            self.assertIsInstance(json_response['n_passes'], int)
        elif response.status_code == 500:
            json_response = response.json()
            self.assertEqual(json_response.get('dbconnection'), 'disconnected')
            self.assertEqual(json_response.get('status'), 'failed')
        else:
            self.fail(f"Unexpected status code: {response.status_code}")

    def test_tollstationpasses_good_token_json_format_populated(self):
        response_json, status_code = self.api_client.toll_station_passes_request("AM03", "20220101", "20230101", self.token, "json")
        self.assertEqual(status_code, 200)
        self.assertIn('stationID', response_json)
        self.assertIn('stationOperator', response_json)
        self.assertIn('periodFrom', response_json)
        self.assertIn('periodTo', response_json)
        self.assertIn('n_passes', response_json)
        self.assertIsInstance(response_json['n_passes'], int)
        self.assertIn('passList', response_json)
        self.assertEqual(response_json['stationID'], "AM03")
        self.assertEqual(response_json['stationOperator'], "aegeanmotorway")
        self.assertEqual(response_json['periodFrom'], "2022-01-01 00:00")
        self.assertEqual(response_json['periodTo'], "2023-01-01 23:59")
        self.assertTrue(isinstance(response_json['n_passes'], int))
        self.assertIsInstance(response_json['passList'], list)
        self.assertGreater(len(response_json['passList']), 0, "passList should not be empty")

    def test_tollstationpasses_good_token_csv_format_populated(self):
        response_csv, status_code = self.api_client.toll_station_passes_request("AM03", "20220101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 200)
        self.assertTrue("stationID,stationOperator,requestTimestamp,periodFrom,periodTo,n_passes,passID,timestamp,tagID,tagProvider,passType,passCharge" in response_csv)
        lines = response_csv.strip().split('\n')
        expected_line_count = 12
        self.assertEqual(len(lines), expected_line_count, f"CSV should contain exactly {expected_line_count} lines")
        expected_length = 1368
        self.assertEqual(len(response_csv), expected_length, f"CSV response should have exactly {expected_length} characters")

    def test_tollstationpasses_good_token_inverse_dates_json_format_populated(self):
        response_json, status_code = self.api_client.toll_station_passes_request("AM03", "20240101", "20230101", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date range")

    def test_tollstationpasses_good_token_inverse_dates_csv_format_populated(self):
        response_json, status_code = self.api_client.toll_station_passes_request("AM03", "20240101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date range")
    
    def test_chargesby_good_token_json_format_populated(self):
        response_json, status_code = self.api_client.charges_by_request("AM", "20220101", "20230101", self.token, "json")
        self.assertEqual(status_code, 200)
        self.assertIn('tollOpID', response_json)
        self.assertIn('requestTimestamp', response_json)
        self.assertIn('periodFrom', response_json)
        self.assertIn('periodTo', response_json)
        self.assertIn('vOpList', response_json)
        self.assertEqual(response_json['tollOpID'], "AM")
        self.assertEqual(response_json['periodFrom'], "2022-01-01 00:00")
        self.assertEqual(response_json['periodTo'], "2023-01-01 23:59")
        self.assertIsInstance(response_json['vOpList'], list)


    def test_chargesby_good_token_csv_format_populated(self):
        response_csv, status_code = self.api_client.charges_by_request("AM", "20220101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 200)
        self.assertTrue("tollOpID,requestTimestamp,periodFrom,periodTo,visitingOpID,n_passes,passesCost" in response_csv)
        lines = response_csv.strip().split('\n')
        expected_line_count = 9
        self.assertEqual(len(lines), expected_line_count, f"CSV should contain exactly {expected_line_count} lines")
        expected_length = 570
        self.assertEqual(len(response_csv), expected_length, f"CSV response should have exactly {expected_length} characters")

    def test_chargesby_good_token_inverse_dates_json_format_populated(self):
        response_json, status_code = self.api_client.charges_by_request("AM", "20240101", "20230101", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date range")

    def test_chargesby_good_token_inverse_dates_csv_format_populated(self):
        response_json, status_code = self.api_client.charges_by_request("AM", "20240101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date range")
    
    def test_passes_cost_good_token_json_format_populated(self):
        response_json, status_code = self.api_client.passes_cost_request("AM", "EG", "20220101", "20230101", self.token, "json")
        self.assertEqual(status_code, 200)
        self.assertIn('tollOpID', response_json)
        self.assertIn('tagOpID', response_json)
        self.assertIn('requestTimestamp', response_json)
        self.assertIn('periodFrom', response_json)
        self.assertIn('periodTo', response_json)
        self.assertIn('n_passes', response_json)
        self.assertIn('passesCost', response_json)
        self.assertEqual(response_json['tollOpID'], "AM")
        self.assertEqual(response_json['tagOpID'], "EG")
        self.assertEqual(response_json['periodFrom'], "2022-01-01")
        self.assertEqual(response_json['periodTo'], "2023-01-01")
        self.assertTrue(isinstance(response_json['passesCost'], (int, float)))

    def test_passes_cost_good_token_csv_format_populated(self):
        response_csv, status_code = self.api_client.passes_cost_request("AM", "EG", "20220101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 200)
        self.assertTrue("tollOpID,tagOpID,requestTimestamp,periodFrom,periodTo,n_passes,passesCost" in response_csv)
        lines = response_csv.strip().split('\n')
        expected_line_count = 2
        self.assertEqual(len(lines), expected_line_count, f"CSV should contain exactly {expected_line_count} lines")
        expected_length = 135
        self.assertEqual(len(response_csv), expected_length, f"CSV response should have exactly {expected_length} characters")

    def test_pass_analysis_good_token_json_format_populated(self):
        response_json, status_code = self.api_client.pass_analysis_request("AM", "EG", "20220101", "20230101", self.token, "json")
        self.assertEqual(status_code, 200)
        self.assertIn('stationOpID', response_json)
        self.assertIn('tagOpID', response_json)
        self.assertIn('requestTimestamp', response_json)
        self.assertIn('periodFrom', response_json)
        self.assertIn('periodTo', response_json)
        self.assertIn('n_passes', response_json)
        self.assertIn('passList', response_json)
        self.assertEqual(response_json['stationOpID'], "AM")
        self.assertEqual(response_json['tagOpID'], "EG")
        self.assertEqual(response_json['periodFrom'], "2022-01-01 00:00")
        self.assertEqual(response_json['periodTo'], "2023-01-01 23:59")
        self.assertTrue(isinstance(response_json['n_passes'], int))
        self.assertIsInstance(response_json['passList'], list)
        self.assertGreater(len(response_json['passList']), 0, "passList should not be empty")

    def test_pass_analysis_good_token_csv_format_populated(self):
        response_csv, status_code = self.api_client.pass_analysis_request("AM", "EG", "20220101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 200)
        self.assertTrue("stationOpID,tagOpID,requestTimestamp,periodFrom,periodTo,n_passes,passID,stationID,timestamp,tagID,passCharge" in response_csv)
        lines = response_csv.strip().split('\n')
        expected_line_count = 15
        self.assertEqual(len(lines), expected_line_count, f"CSV should contain exactly {expected_line_count} lines")
        expected_length = 1600
        self.assertEqual(len(response_csv), expected_length, f"CSV response should have exactly {expected_length} characters")

    def test_getdebt_good_token_json_format_populated(self):
        response_json, status_code = self.api_client.get_debt_request("AM", "20220101", "20230101", self.token, "json")
        self.assertEqual(status_code, 200)
        self.assertIn('tagOpID', response_json)
        self.assertIn('requestTimestamp', response_json)
        self.assertIn('periodFrom', response_json)
        self.assertIn('periodTo', response_json)
        self.assertIn('hOpList', response_json)

    def test_getdebt_good_token_csv_format_populated(self):
        response_csv, status_code = self.api_client.get_debt_request(
            "AM", "20220101", "20230101", self.token, "csv"
        )
        self.assertEqual(status_code, 200)
        lines = response_csv.strip().split('\n')
        expected_line_count = 8
        self.assertEqual(len(lines), expected_line_count, f"CSV should contain exactly {expected_line_count} lines")
        expected_length = 503
        self.assertEqual(len(response_csv), expected_length, f"CSV response should have exactly {expected_length} characters")


    def test_getdebt_bad_syntax_json_format_populated(self):
        response_json, status_code = self.api_client.get_debt_request("AM", "1", "2", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")
        response_json, status_code = self.api_client.get_debt_request("AM", "20240177", "20230177", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")
    
    def test_getdebt_inverse_dates_json_format_populated(self):
        response_json, status_code = self.api_client.get_debt_request("AM", "20240101", "20230101", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date range")

    def test_getdebt_inverse_dates_csv_format_populated(self):
        response_json, status_code = self.api_client.get_debt_request("AM", "20240101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date range")

    def test_pay_debt_good_token_json_format_populated(self):
        response_json, status_code = self.api_client.pay_debt_request("AM", "EG", "20220101", "20230101", self.token, "json")
        self.assertEqual(status_code, 200)
        self.assertEqual(response_json['status'], "OK")
        self.assertEqual(round(response_json['totalCost'], 1), 18.8)

    def test_tollstats_good_token_json_format_populated(self):
        response_json, status_code = self.api_client.toll_stats_request("AM", "20220101", "20230101", self.token, "json")
        self.assertEqual(status_code, 200)
        self.assertIn('tollOpID', response_json)
        self.assertIn('requestTimestamp', response_json)
        self.assertIn('periodFrom', response_json)
        self.assertIn('periodTo', response_json)
        self.assertIn('stats', response_json)
        self.assertIn('totalPasses', response_json['stats'])
        self.assertIn('totalRevenue', response_json['stats'])
        self.assertIn('mostPasses', response_json['stats'])
        self.assertIn('mostRevenue', response_json['stats'])
        self.assertIn('mostPassesWithHomeTag', response_json['stats'])
        self.assertIn('mostRevenueWithHomeTag', response_json['stats'])

    def test_tollstats_good_token_csv_format_populated(self):
        response_csv, status_code = self.api_client.toll_stats_request("AM", "20220101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 200)
        self.assertTrue("tollOpID,requestTimestamp,periodFrom,periodTo,totalPasses,totalRevenue,mostPasses,mostRevenue,mostPassesWithHomeTag,mostRevenueWithHomeTag" in response_csv)
        lines = response_csv.strip().split('\n')
        expected_line_count = 2
        self.assertEqual(len(lines), expected_line_count, f"CSV should contain exactly {expected_line_count} lines")
        expected_length = 220
        self.assertEqual(len(response_csv), expected_length, f"CSV response should have exactly {expected_length} characters")


if __name__ == "__main__":
    unittest.main()



    
    
