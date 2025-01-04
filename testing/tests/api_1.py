import unittest
import requests

import utils.config as config
from utils.api_requests import Reqs, get_token_from_login

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# ~~~~~~~~~~~~~~~~~~~~~ PART 1: TESTS WITHOUT PASSES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
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

    # ~~~~~~~~~~~~~~~~~~~~~ HEALTH CHECK ~~~~~~~~~~~~~~~~~~~~~ #
    
    def test_healthcheck(self):
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

    # ~~~~~~~~~~~~~~~~~~~~~ RESET PASSES ~~~~~~~~~~~~~~~~~~~~~ #
    
    def test_resetpasses(self):
        response = requests.post(f"{config.API_URL}/admin/resetpasses")
        if response.status_code == 200:
            json_response = response.json()
            self.assertEqual(json_response.get('status'), 'OK')
        elif response.status_code == 500:
            json_response = response.json()
            self.assertEqual(json_response.get('status'), 'failed')
            self.assertIn('info', json_response)
            self.assertIn('errno', json_response['info'])
            self.assertIn('code', json_response['info'])
            self.assertIn('syscall', json_response['info'])
            self.assertIn('address', json_response['info'])
            self.assertIn('port', json_response['info'])
            self.assertIsInstance(json_response['info']['errno'], int)
            self.assertIsInstance(json_response['info']['port'], int)
        else:
            self.fail(f"Unexpected status code: {response.status_code}")

    # ~~~~~~~~~~~~~~~~~~~~~ RESET STATIONS ~~~~~~~~~~~~~~~~~~~~~ #
    
    def test_resetstations(self):
        response = requests.post(f"{config.API_URL}/admin/resetstations")
        if response.status_code == 200:
            json_response = response.json()
            self.assertEqual(json_response.get('status'), 'OK')
        elif response.status_code == 500:
            json_response = response.json()
            self.assertEqual(json_response.get('status'), 'failed')
            self.assertIn('info', json_response)
            self.assertIn('errno', json_response['info'])
            self.assertIn('code', json_response['info'])
            self.assertIn('syscall', json_response['info'])
            self.assertIn('address', json_response['info'])
            self.assertIn('port', json_response['info'])
            self.assertIsInstance(json_response['info']['errno'], int)
            self.assertIsInstance(json_response['info']['port'], int)
        else:
            self.fail(f"Unexpected status code: {response.status_code}")

    # ~~~~~~~~~~~~~~~~~~~~~ LOGIN ~~~~~~~~~~~~~~~~~~~~~ #

    def test_login_wrong_password(self):
        data = "username=admin&password=wrong"
        json_response, status_code = self.api_client.login_request(data)
        if status_code == 500:
            self.assertEqual(json_response['error'], "Internal server error")
        else:
            self.assertEqual(status_code, 401)
            self.assertEqual(json_response['error'], "Invalid username or password")

    def test_login_wrong_username(self):
        data = "username=wrong&password=freepasses4all"
        json_response, status_code = self.api_client.login_request(data)
        if status_code == 500:
            self.assertEqual(json_response['error'], "Internal server error")
        else:
            self.assertEqual(status_code, 401)
            self.assertEqual(json_response['error'], "Invalid username or password")

    def test_login_wrong_username_no_password(self):
        data = "username=wrong&password="
        json_response, status_code = self.api_client.login_request(data)
        if status_code == 500:
            self.assertEqual(json_response['error'], "Internal server error")
        else:
            self.assertEqual(status_code, 400)
            self.assertEqual(json_response['error'], "Username and password are required")

    def test_login_correct_username_no_password(self):
        data = "username=admin&password="
        json_response, status_code = self.api_client.login_request(data)
        if status_code == 500:
            self.assertEqual(json_response['error'], "Internal server error")
        else:
            self.assertEqual(status_code, 400)
            self.assertEqual(json_response['error'], "Username and password are required")

    def test_login_no_username_no_password(self):
        data = "username=&password="
        json_response, status_code = self.api_client.login_request(data)
        if status_code == 500:
            self.assertEqual(json_response['error'], "Internal server error")
        else:
            self.assertEqual(status_code, 400)
            self.assertEqual(json_response['error'], "Username and password are required")

    def test_login_no_username_wrong_password(self):
        data = "username=&password=wrong"
        json_response, status_code = self.api_client.login_request(data)
        if status_code == 500:
            self.assertEqual(json_response['error'], "Internal server error")
        else:
            self.assertEqual(status_code, 400)
            self.assertEqual(json_response['error'], "Username and password are required")

    def test_login_no_username_correct_password(self):
        data = "username=&password=freepasses4all"
        json_response, status_code = self.api_client.login_request(data)
        if status_code == 500:
            self.assertEqual(json_response['error'], "Internal server error")
        else:
            self.assertEqual(status_code, 400)
            self.assertEqual(json_response['error'], "Username and password are required")

    def test_login_no_username_no_password_field(self):
        data = "username="
        json_response, status_code = self.api_client.login_request(data)
        if status_code == 500:
            self.assertEqual(json_response['error'], "Internal server error")
        else:
            self.assertEqual(status_code, 400)
            self.assertEqual(json_response['error'], "Username and password are required")

    def test_login_no_username_and_password_fields(self):
        data = ""
        json_response, status_code = self.api_client.login_request(data)
        if status_code == 500:
            self.assertEqual(json_response['error'], "Internal server error")
        else:
            self.assertEqual(status_code, 400)
            self.assertEqual(json_response['error'], "Username and password are required")

    def test_login_correct_credentials(self):
        data = "username=admin&password=freepasses4all"
        json_response, status_code = self.api_client.login_request(data)
        if status_code == 500:
            self.assertEqual(json_response['error'], "Internal server error")
        else:
            self.assertEqual(status_code, 200)
            self.assertIn('token', json_response)

    def test_login_correct_credentials_again(self):
        data = "username=admin&password=freepasses4all"
        json_response, status_code = self.api_client.login_request(data)
        if status_code == 500:
            self.assertEqual(json_response['error'], "Internal server error")
        else:
            self.assertEqual(status_code, 200)
            self.assertIn('token', json_response)
        
    # ~~~~~~~~~~~~~~~~~~~~~ TOLL STATION PASSES ~~~~~~~~~~~~~~~~~~~~~ #

    def test_tollstationpasses_good_token_json_format_no_data(self):
        response_json, status_code = self.api_client.toll_station_passes_request("AM03", "20220101", "20230101", self.token, "json")
        self.assertEqual(status_code, 204)

    def test_tollstationpasses_good_token_csv_format(self):
        response_json, status_code = self.api_client.toll_station_passes_request("AM03", "20220101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 204)

    def test_tollstationpasses_good_token_wrong_toll_station_json_format(self):
        response_json, status_code = self.api_client.toll_station_passes_request("AMBB", "20220101", "20230101", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Toll station not found")

    def test_tollstationpasses_good_token_wrong_toll_station_csv_format(self):
        response_json, status_code = self.api_client.toll_station_passes_request("AMBB", "20220101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], 'Toll station not found')

    def test_tollstationpasses_good_token_inverse_dates_json_format(self):
        response_json, status_code = self.api_client.toll_station_passes_request("AM03", "20240101", "20230101", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date range")

    def test_tollstationpasses_good_token_inverse_dates_csv_format(self):
        response_json, status_code = self.api_client.toll_station_passes_request("AM03", "20240101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date range")

    def test_tollstationpasses_bad_token_json_format(self):
        response_json, status_code = self.api_client.toll_station_passes_request("AM03", "20220101", "20230101", "INVALID_TOKEN", "json")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: Invalid token")

    def test_tollstationpasses_bad_dates_json_format(self):
        response_json, status_code = self.api_client.toll_station_passes_request("AM03", "1", "1", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")
        response_json, status_code = self.api_client.toll_station_passes_request("AM03", "20230177", "20240177", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")

    def test_tollstationpasses_bad_dates_csv_format(self):
        response_json, status_code = self.api_client.toll_station_passes_request("AM03", "1", "1", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")
        response_json, status_code = self.api_client.toll_station_passes_request("AM03", "20230177", "20240177", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")

    def test_tollstationpasses_bad_token_csv_format(self):
        response_json, status_code = self.api_client.toll_station_passes_request("AM03", "20220101", "20230101", "INVALID_TOKEN", "csv")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: Invalid token")

    def test_tollstationpasses_no_token_json_format(self):
        response_json, status_code = self.api_client.toll_station_passes_request("AM03", "20220101", "20230101", "", "json")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], 'Unauthorized: No token provided')

    def test_tollstationpasses_no_token_csv_format(self):
        response_json, status_code = self.api_client.toll_station_passes_request("AM03", "20220101", "20230101", "", "csv")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], 'Unauthorized: No token provided')

    # ~~~~~~~~~~~~~~~~~~~~~ CHARGES BY ~~~~~~~~~~~~~~~~~~~~~ #

    def test_chargesby_good_token_json_format(self):
        response_json, status_code = self.api_client.charges_by_request("AM", "20220101", "20230101", self.token, "json")
        self.assertEqual(status_code, 204)


    def test_chargesby_good_token_csv_format_no_data(self):
        response_json, status_code = self.api_client.charges_by_request("AM", "20220101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 204)

    def test_chargesby_good_token_inverse_dates_json_format(self):
        response_json, status_code = self.api_client.charges_by_request("AM", "20240101", "20230101", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date range")

    def test_chargesby_good_token_inverse_dates_csv_format(self):
        response_json, status_code = self.api_client.charges_by_request("AM", "20240101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date range")

    def test_chargesby_good_token_wrong_toll_operator_json_format(self):
        response_json, status_code = self.api_client.charges_by_request("AA", "20220101", "20230101", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Toll operator not found")

    def test_chargesby_good_token_wrong_toll_operator_csv_format(self):
        response_json, status_code = self.api_client.charges_by_request("AA", "20220101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Toll operator not found")

    def test_chargesby_good_token_bad_dates_json_format(self):
        response_json, status_code = self.api_client.charges_by_request("AM", "1", "1", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")
        response_json, status_code = self.api_client.charges_by_request("AM", "20230177", "20240177", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")

    def test_chargesby_good_token_bad_dates_csv_format(self):
        response_json, status_code = self.api_client.charges_by_request("AM", "1", "1", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")
        response_json, status_code = self.api_client.charges_by_request("AM", "20230177", "20240177", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")

    def test_chargesby_bad_token_json_format(self):
        response_json, status_code = self.api_client.charges_by_request("AM", "20220101", "20230101", "INVALID_TOKEN", "json")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: Invalid token")

    def test_chargesby_bad_token_csv_format(self):
        response_json, status_code = self.api_client.charges_by_request("AM", "20220101", "20230101", "INVALID_TOKEN", "csv")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: Invalid token")

    def test_chargesby_no_token_json_format(self):
        response_json, status_code = self.api_client.charges_by_request("AM", "20220101", "20230101", "", "json")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: No token provided")

    def test_chargesby_no_token_csv_format(self):
        response_json, status_code = self.api_client.charges_by_request("AM", "20220101", "20230101", "", "csv")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: No token provided")

    # ~~~~~~~~~~~~~~~~~~~~~ PASSES COST ~~~~~~~~~~~~~~~~~~~~~ #

    def test_passes_cost_good_token_json_format_no_data(self):
        response_json, status_code = self.api_client.passes_cost_request("AM", "AM", "20220101", "33330101", self.token, "json")
        self.assertEqual(status_code, 200)
        self.assertIn('tollOpID', response_json)
        self.assertIn('tagOpID', response_json)
        self.assertIn('requestTimestamp', response_json)
        self.assertIn('periodFrom', response_json)
        self.assertIn('periodTo', response_json)
        self.assertIn('n_passes', response_json)
        self.assertIn('passesCost', response_json)
        self.assertEqual(response_json['tollOpID'], "AM")
        self.assertEqual(response_json['tagOpID'], "AM")
        self.assertEqual(response_json['periodFrom'], "2022-01-01")
        self.assertEqual(response_json['periodTo'], "3333-01-01")
        self.assertTrue(isinstance(response_json['passesCost'], (int, float)))
    
    def test_passes_cost_good_token_json_format_no_data_good_2nd(self):
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

    def test_passes_cost_good_token_csv_format_no_data(self):
        response_json, status_code = self.api_client.passes_cost_request("AM", "AM", "20220101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 200)
        self.assertTrue("tollOpID,tagOpID,requestTimestamp,periodFrom,periodTo,n_passes,passesCost" in response_json)
    
    def test_passes_cost_good_token_csv_format_no_data_good_2nd(self):
        response_json, status_code = self.api_client.passes_cost_request("AM", "EG", "20220101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 200)
        self.assertTrue("tollOpID,tagOpID,requestTimestamp,periodFrom,periodTo,n_passes,passesCost" in response_json)

    def test_passes_cost_good_token_inverse_dates_json_format(self):
        response_json, status_code = self.api_client.passes_cost_request("AM", "AM", "20240101", "20230101", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date range")

    def test_passes_cost_good_token_inverse_dates_csv_format(self):
        response_json, status_code = self.api_client.passes_cost_request("AM", "AM", "20240101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date range")

    def test_passes_cost_good_token_wrong_toll_operator_json_format(self):
        response_json, status_code = self.api_client.passes_cost_request("AA", "AM", "20220101", "20230101", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Toll or tag operator not found")

    def test_passes_cost_good_token_wrong_toll_operator_csv_format(self):
        response_json, status_code = self.api_client.passes_cost_request("AA", "AM", "20220101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Toll or tag operator not found")

    def test_passes_cost_good_token_bad_dates_json_format(self):
        response_json, status_code = self.api_client.passes_cost_request("AM", "AM", "1", "1", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")
        response_json, status_code = self.api_client.passes_cost_request("AM", "AM", "20230101", "20240177", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")

    def test_passes_cost_good_token_bad_dates_csv_format(self):
        response_json, status_code = self.api_client.passes_cost_request("AM", "AM", "1", "1", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")
        response_json, status_code = self.api_client.passes_cost_request("AM", "AM", "20230101", "20240177", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")

    def test_passes_cost_bad_token_json_format(self):
        response_json, status_code = self.api_client.passes_cost_request("AM", "AM", "20220101", "20230101", "INVALID_TOKEN", "json")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: Invalid token")

    def test_passes_cost_bad_token_csv_format(self):
        response_json, status_code = self.api_client.passes_cost_request("AM", "AM", "20220101", "20230101", "INVALID_TOKEN", "csv")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: Invalid token")

    def test_passes_cost_no_token_json_format(self):
        response_json, status_code = self.api_client.passes_cost_request("AM", "AM", "20220101", "20230101", "", "json")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: No token provided")

    def test_passes_cost_no_token_csv_format(self):
        response_json, status_code = self.api_client.passes_cost_request("AM", "AM", "20220101", "20230101", "", "csv")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: No token provided")

    # ~~~~~~~~~~~~~~~~~~~~~ PASS ANALYSIS ~~~~~~~~~~~~~~~~~~~~~ #

    def test_pass_analysis_good_token_json_format_no_data(self):
        response_json, status_code = self.api_client.pass_analysis_request("AM", "AM", "20220101", "20230101", self.token, "json")
        self.assertEqual(status_code, 204)
    
    def test_pass_analysis_good_token_json_format_no_data_2(self):
        response_json, status_code = self.api_client.pass_analysis_request("AM", "EG", "20220101", "20230101", self.token, "json")
        self.assertEqual(status_code, 204)

    def test_pass_analysis_good_token_csv_format_no_data(self):
        response_json, status_code = self.api_client.pass_analysis_request("AM", "AM", "20220101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 204)
    
    def test_pass_analysis_good_token_csv_format_no_data_2(self):
        response_json, status_code = self.api_client.pass_analysis_request("AM", "EG", "20220101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 204)

    def test_pass_analysis_bad_token_json_format(self):
        response_json, status_code = self.api_client.pass_analysis_request("AM", "AM", "20220101", "20230101", "11111111111111", "json")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: Invalid token")

    def test_pass_analysis_bad_token_csv_format(self):
        response_json, status_code = self.api_client.pass_analysis_request("AM", "AM", "20220101", "20230101", "11111111111111", "csv")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: Invalid token")

    def test_pass_analysis_no_token_json_format(self):
        response_json, status_code = self.api_client.pass_analysis_request("AM", "AM", "20220101", "20230101", None, "json")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json["error"], "Unauthorized: No token provided")

    def test_pass_analysis_no_token_csv_format(self):
        response_json, status_code = self.api_client.pass_analysis_request("AM", "AM", "20220101", "20230101", None, "csv")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json["error"], "Unauthorized: No token provided")

    def test_pass_analysis_inverse_dates_json_format(self):
        response_json, status_code = self.api_client.pass_analysis_request("AM", "AM", "20240101", "20230101", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date range")

    def test_pass_analysis_inverse_dates_csv_format(self):
        response_json, status_code = self.api_client.pass_analysis_request("AM", "AM", "20240101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date range")

    def test_pass_analysis_bad_dates_json_format(self):
        response_json, status_code = self.api_client.pass_analysis_request("AM", "AM", "1", "1", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")
        response_json, status_code = self.api_client.pass_analysis_request("AM", "AM", "2023001", "2024077", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")

    def test_pass_analysis_bad_dates_csv_format(self):
        response_json, status_code = self.api_client.pass_analysis_request("AM", "AM", "1", "1", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")
        response_json, status_code = self.api_client.pass_analysis_request("AM", "AM", "2023001", "2024077", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")

    def test_pass_analysis_wrong_toll_operator_json_format(self):
        response_json, status_code = self.api_client.pass_analysis_request("AA", "AM", "20220101", "20230101", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json["error"], "Station or tag operator not found")

    def test_pass_analysis_wrong_toll_operator_csv_format(self):
        response_json, status_code = self.api_client.pass_analysis_request("AA", "AM", "20220101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json["error"], "Station or tag operator not found")

    def test_pass_analysis_wrong_2nd_toll_operator_json_format(self):
        response_json, status_code = self.api_client.pass_analysis_request("AM", "AA", "20220101", "20230101", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json["error"], "Station or tag operator not found")

    def test_pass_analysis_wrong_2nd_toll_operator_csv_format(self):
        response_json, status_code = self.api_client.pass_analysis_request("AM", "AA", "20220101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json["error"], "Station or tag operator not found")

    # ~~~~~~~~~~~~~~~~~~~~~ USER MODIFICATION ANALYSIS ~~~~~~~~~~~~~~~~~~~~~ #

    def test_user_modification_good_token(self):
        response_json, status_code = self.api_client.user_modification_request("test1", "test2", self.token)
        self.assertEqual(status_code, 200)
        self.assertEqual(response_json["status"], "OK")

    def test_user_modification_bad_token(self):
        response_json, status_code = self.api_client.user_modification_request("test1", "test2", "11111111111111")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: Invalid token")

    def test_user_modification_no_token(self):
        response_json, status_code = self.api_client.user_modification_request("test1", "test2", None)
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json["error"], "Unauthorized: No token provided")

    def test_user_modification_empty_fields(self):
        response_json, status_code = self.api_client.user_modification_request("", "", self.token)
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json["error"], "Username and password are required")

    def test_user_modification_empty_password(self):
        response_json, status_code = self.api_client.user_modification_request("test1", "", self.token)
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json["error"], "Username and password are required")

    def test_user_modification_empty_username(self):
        response_json, status_code = self.api_client.user_modification_request("", "test2", self.token)
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json["error"], "Username and password are required")

    def test_user_modification_no_password_field(self):
        response_json, status_code = self.api_client.user_modification_request("test", "", self.token)
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json["error"], "Username and password are required")

    def test_user_modification_no_username_field(self):
        response_json, status_code = self.api_client.user_modification_request("", "test", self.token)
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json["error"], "Username and password are required")

    def test_user_modification_no_fields(self):
        response_json, status_code = self.api_client.user_modification_request("", "", self.token)
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json["error"], "Username and password are required")

    # ~~~~~~~~~~~~~~~~~~~~~ USER LISTING ~~~~~~~~~~~~~~~~~~~~~ #

    def test_list_users_good_token(self):
        response_json, status_code = self.api_client.list_users_request(self.token)
        self.assertEqual(status_code, 200)
        self.assertIn("admin", response_json)

    def test_list_users_bad_token(self):
        response_json, status_code = self.api_client.list_users_request("11111111111111")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: Invalid token")

    def test_list_users_no_token(self):
        response_json, status_code = self.api_client.list_users_request(None)
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json["error"], "Unauthorized: No token provided")

    # ~~~~~~~~~~~~~~~~~~~~~ ADD PASSES ~~~~~~~~~~~~~~~~~~~~~ #

    def test_add_passes_good_token_and_twice(self):
        response_json, status_code = self.api_client.add_passes_request(self.token, config.PASSES_SAMPLE_FILE)
        self.assertEqual(status_code, 200)
        self.assertEqual(response_json["status"], "OK")
        response_json, status_code = self.api_client.add_passes_request(self.token, config.PASSES_SAMPLE_FILE)
        self.assertEqual(status_code, 200)
        self.assertEqual(response_json["status"], "OK")
        # then, reset passes again to continue testing without them:
        response = requests.post(f"{config.API_URL}/admin/resetpasses")
        if response.json().get('status') != 'OK':
            print("Failed to reset passes (2)")
            exit(1)

    def test_add_passes_bad_token(self):
        response_json, status_code = self.api_client.add_passes_request("11111111111111", config.PASSES_SAMPLE_FILE)
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: Invalid token")

    def test_add_passes_no_token(self):
        response_json, status_code = self.api_client.add_passes_request(None, config.PASSES_SAMPLE_FILE)
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json["error"], "Unauthorized: No token provided")
    
    def test_add_passes_file_bad_contents(self):
        response_json, status_code = self.api_client.add_passes_request(self.token, "./README.md")
        self.assertEqual(status_code, 500)
        self.assertEqual(response_json["status"], "failed")

    # ~~~~~~~~~~~~~~~~~~~~~ GET STATIONS ~~~~~~~~~~~~~~~~~~~~~ #

    def test_list_stations_good_token(self):
        response_json, status_code = self.api_client.list_stations_request(self.token)
        self.assertEqual(status_code, 200)
        self.assertIn("stations", response_json)

    def test_list_stations_bad_token(self):
        response_json, status_code = self.api_client.list_stations_request("11111111111111")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: Invalid token")

    def test_list_stations_no_token(self):
        response_json, status_code = self.api_client.list_stations_request(None)
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json["error"], "Unauthorized: No token provided")

    # ~~~~~~~~~~~~~~~~~~~~~ GET OPERATORS ~~~~~~~~~~~~~~~~~~~~~ #

    def test_list_operators_good_token(self):
        response_json, status_code = self.api_client.list_operators_request(self.token)
        self.assertEqual(status_code, 200)
        self.assertIn("operators", response_json)

    def test_list_operators_bad_token(self):
        response_json, status_code = self.api_client.list_operators_request("11111111111111")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: Invalid token")

    def test_list_operators_no_token(self):
        response_json, status_code = self.api_client.list_operators_request(None)
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json["error"], "Unauthorized: No token provided")

    # ~~~~~~~~~~~~~~~~~~~~~ GET DEBT ~~~~~~~~~~~~~~~~~~~~~ #

    def test_getdebt_good_token_json_format(self):
        response_json, status_code = self.api_client.get_debt_request("AM", "20220101", "20230101", self.token, "json")
        self.assertEqual(status_code, 204)

    def test_getdebt_good_token_csv_format(self):
        response_csv, status_code = self.api_client.get_debt_request("AM", "20220101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 204)

    def test_getdebt_bad_token_json_format(self):
        response_json, status_code = self.api_client.get_debt_request("AM", "20220101", "20220101", "INVALID_TOKEN", "json")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: Invalid token")

    def test_getdebt_bad_token_csv_format(self):
        response_json, status_code = self.api_client.get_debt_request("AM", "20220101", "20220101", "INVALID_TOKEN", "csv")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: Invalid token")

    def test_getdebt_no_token_json_format(self):
        response_json, status_code = self.api_client.get_debt_request("AM", "20220101", "20220101", "", "json")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: No token provided")

    def test_getdebt_no_token_csv_format(self):
        response_csv, status_code = self.api_client.get_debt_request("AM", "20220101", "20220101", "", "csv")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_csv['error'], "Unauthorized: No token provided")

    def test_getdebt_inverse_dates_json_format(self):
        response_json, status_code = self.api_client.get_debt_request("AM", "20240101", "20230101", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date range")

    def test_getdebt_inverse_dates_csv_format(self):
        response_json, status_code = self.api_client.get_debt_request("AM", "20240101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date range")

    def test_getdebt_bad_dates_json_format(self):
        response_json, status_code = self.api_client.get_debt_request("AM", "1", "1", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")
        response_json, status_code = self.api_client.get_debt_request("AM", "20230177", "20240177", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")

    def test_getdebt_bad_dates_csv_format(self):
        response_json, status_code = self.api_client.get_debt_request("AM", "1", "1", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")
        response_json, status_code = self.api_client.get_debt_request("AM", "20230177", "20240177", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")

    def test_getdebt_wrong_tag_operator_json_format(self):
        response_json, status_code = self.api_client.get_debt_request("AA", "20220101", "20230101", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Tag operator not found")

    def test_getdebt_wrong_tag_operator_csv_format(self):
        response_csv, status_code = self.api_client.get_debt_request("AA", "20220101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_csv['error'], "Tag operator not found")

    # ~~~~~~~~~~~~~~~~~~~~~ PAY DEBT ~~~~~~~~~~~~~~~~~~~~~ #

    def test_pay_debt_good_token_zero_debt_json_format(self):
        response_json, status_code = self.api_client.pay_debt_request("AM", "AM", "20220101", "20220101", self.token, "json")
        self.assertEqual(status_code, 200)
        self.assertEqual(response_json['status'], "OK")
        self.assertEqual(response_json['totalCost'], 0)

    def test_pay_debt_good_token_json_format(self):
        response_json, status_code = self.api_client.pay_debt_request("AM", "AM", "20220101", "20230101", self.token, "json")
        self.assertEqual(status_code, 200)
        self.assertEqual(response_json['status'], "OK")
        self.assertEqual(response_json['totalCost'], 0)

    def test_pay_debt_bad_token_json_format(self):
        response_json, status_code = self.api_client.pay_debt_request("AM", "AM", "20220101", "20230101", "INVALID_TOKEN", "json")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: Invalid token")

    def test_pay_debt_no_token_json_format(self):
        response_json, status_code = self.api_client.pay_debt_request("AM", "AM", "20220101", "20230101", "", "json")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: No token provided")

    def test_pay_debt_inverse_dates_json_format(self):
        response_json, status_code = self.api_client.pay_debt_request("AM", "AM", "20240101", "20230101", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date range")

    def test_pay_debt_bad_dates_json_format(self):
        response_json, status_code = self.api_client.pay_debt_request("AM", "AM", "1", "1", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")
        response_json, status_code = self.api_client.pay_debt_request("AM", "AM", "20230001", "20240101", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")

    def test_pay_debt_wrong_toll_operator_json_format(self):
        response_json, status_code = self.api_client.pay_debt_request("AA", "AM", "20220101", "20230101", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Toll or tag operator not found")

    def test_pay_debt_wrong_toll_operator_second_json_format(self):
        response_json, status_code = self.api_client.pay_debt_request("AM", "AA", "20220101", "20230101", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Toll or tag operator not found")

    def test_pay_debt_already_paid_json_format(self):
        response_json, status_code = self.api_client.pay_debt_request("AM", "AM", "20220101", "20220101", self.token, "json")
        self.assertEqual(status_code, 200)
        self.assertEqual(response_json['status'], "OK")
        self.assertEqual(response_json['totalCost'], 0)

    def test_pay_debt_pay_to_other_operator_json_format(self):
        response_json, status_code = self.api_client.pay_debt_request("AM", "EG", "20220101", "20240101", self.token, "json")
        self.assertEqual(status_code, 200)
        self.assertEqual(response_json['status'], "OK")
        self.assertTrue(isinstance(response_json['totalCost'], (int, float)))

    # ~~~~~~~~~~~~~~~~~~~~~ TOLL STATS ~~~~~~~~~~~~~~~~~~~~~ #

    def test_tollstats_good_token_json_format_on_data(self):
        response_json, status_code = self.api_client.toll_stats_request("AM", "20220101", "20230101", self.token, "json")
        self.assertEqual(status_code, 204)

    def test_tollstats_good_token_csv_format_no_data(self):
        response_json, status_code = self.api_client.toll_stats_request("AM", "20220101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 204)

    def test_tollstats_bad_token_json_format(self):
        response_json, status_code = self.api_client.toll_stats_request("AM", "20220101", "20230101", "INVALID_TOKEN", "json")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: Invalid token")

    def test_tollstats_bad_token_csv_format(self):
        response_json, status_code = self.api_client.toll_stats_request("AM", "20220101", "20230101", "INVALID_TOKEN", "csv")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: Invalid token")

    def test_tollstats_no_token_json_format(self):
        response_json, status_code = self.api_client.toll_stats_request("AM", "20220101", "20230101", "", "json")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], 'Unauthorized: No token provided')

    def test_tollstats_no_token_csv_format(self):
        response_json, status_code = self.api_client.toll_stats_request("AM", "20220101", "20230101", "", "csv")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], 'Unauthorized: No token provided')

    def test_tollstats_inverse_dates_json_format(self):
        response_json, status_code = self.api_client.toll_stats_request("AM", "20240101", "20230101", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date range")

    def test_tollstats_inverse_dates_csv_format(self):
        response_json, status_code = self.api_client.toll_stats_request("AM", "20240101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date range")

    def test_tollstats_bad_dates_json_format(self):
        response_json, status_code = self.api_client.toll_stats_request("AM", "1", "1", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")
        response_json, status_code = self.api_client.toll_stats_request("AM", "00000000", "11111111", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")

    def test_tollstats_bad_dates_csv_format(self):
        response_json, status_code = self.api_client.toll_stats_request("AM", "1", "1", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")
        response_json, status_code = self.api_client.toll_stats_request("AM", "00000000", "11111111", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Invalid date")

    def test_tollstats_wrong_toll_operator_json_format(self):
        response_json, status_code = self.api_client.toll_stats_request("AA", "20220101", "20230101", self.token, "json")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Toll operator not found")

    def test_tollstats_wrong_toll_operator_csv_format(self):
        response_json, status_code = self.api_client.toll_stats_request("AA", "20220101", "20230101", self.token, "csv")
        self.assertEqual(status_code, 400)
        self.assertEqual(response_json['error'], "Toll operator not found")

    # ~~~~~~~~~~~~~~~~~~~~~ LOGOUT ~~~~~~~~~~~~~~~~~~~~~ #

    def test_logout_bad_token(self):
        response_json, status_code = self.api_client.logout_request("11111111111111")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: Invalid token")

    def test_logout_good_token(self):
        response_json, status_code = self.api_client.logout_request(self.token)
        self.assertEqual(status_code, 200)
        self.assertEqual(response_json, '')

    def test_logout_no_token(self):
        response_json, status_code = self.api_client.logout_request("")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: No token provided")

    def test_logout_good_token_twice(self):
        response_json, status_code = self.api_client.logout_request(self.token)
        self.assertEqual(status_code, 200)
        self.assertEqual(response_json, '')
        response_json, status_code = self.api_client.logout_request(self.token)
        self.assertEqual(status_code, 200)
        self.assertEqual(response_json, '')

    def test_logout_bad_token_again(self):
        response_json, status_code = self.api_client.logout_request(self.token)
        self.assertEqual(status_code, 200)
        self.assertEqual(response_json, '')
        response_json, status_code = self.api_client.logout_request("11111111111111")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: Invalid token")

    def test_logout_no_token_again(self):
        response_json, status_code = self.api_client.logout_request(self.token)
        self.assertEqual(status_code, 200)
        self.assertEqual(response_json, '')
        response_json, status_code = self.api_client.logout_request("")
        self.assertEqual(status_code, 401)
        self.assertEqual(response_json['error'], "Unauthorized: No token provided")


if __name__ == "__main__":
    unittest.main()



    
    
