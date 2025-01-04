import requests

import utils.config as config

def get_token_from_login():
    username = "admin"
    password = "freepasses4all"
    response = requests.post(
        f"{config.API_URL}/login",
        headers={"Content-Type": "application/x-www-form-urlencoded"},
        data=f"username={username}&password={password}",
    )
    if response.status_code == 200:
        return response.json().get("token")
    return None

class Reqs():

    def login_request(self, data):
        response = requests.post(
            f"{config.API_URL}/login",
            headers={"Content-Type": "application/x-www-form-urlencoded"},
            data=data,
        )
        return response.json(), response.status_code

    def toll_station_passes_request(self, toll_station, start_date, end_date, token, format_type="json"):
        url = f"{config.API_URL}/tollStationPasses/{toll_station}/{start_date}/{end_date}?format={format_type}"
        headers = {"X-OBSERVATORY-AUTH": token} if token else {}
        response = requests.get(url, headers=headers)
        # try response.json(), else return response
        try:
            return response.json(), response.status_code
        except:
            return response.text, response.status_code

    def charges_by_request(self, toll_operator, start_date, end_date, token, format_type="json"):
        url = f"{config.API_URL}/chargesBy/{toll_operator}/{start_date}/{end_date}?format={format_type}"
        headers = {"X-OBSERVATORY-AUTH": token} if token else {}
        response = requests.get(url, headers=headers)
        try:
            return response.json(), response.status_code
        except:
            return response.text, response.status_code

    def passes_cost_request(self, toll_operator, tag_operator, start_date, end_date, token, format_type="json"):
        url = f"{config.API_URL}/passesCost/{toll_operator}/{tag_operator}/{start_date}/{end_date}?format={format_type}"
        headers = {"X-OBSERVATORY-AUTH": token} if token else {}
        response = requests.get(url, headers=headers)
        try:
            return response.json(), response.status_code
        except:
            return response.text, response.status_code

    def pass_analysis_request(self, station_operator, tag_operator, start_date, end_date, token, format_type="json"):
        url = f"{config.API_URL}/passAnalysis/{station_operator}/{tag_operator}/{start_date}/{end_date}?format={format_type}"
        headers = {"X-OBSERVATORY-AUTH": token} if token else {}
        response = requests.get(url, headers=headers)
        try:
            return response.json(), response.status_code
        except:
            return response.text, response.status_code

    def user_modification_request(self, username, password, token):
        url = f"{config.API_URL}/admin/users"
        headers = {"X-OBSERVATORY-AUTH": token} if token else {}
        data = {"username": username, "password": password}
        response = requests.post(url, headers=headers, data=data)
        try:
            return response.json(), response.status_code
        except:
            return response.text, response.status_code

    def list_users_request(self, token):
        url = f"{config.API_URL}/admin/users"
        headers = {"X-OBSERVATORY-AUTH": token} if token else {}
        response = requests.get(url, headers=headers)
        try:
            return response.json(), response.status_code
        except:
            return response.text, response.status_code

    def add_passes_request(self, token, file_path):
        url = f"{config.API_URL}/admin/addpasses"
        headers = {"X-OBSERVATORY-AUTH": token} if token else {}
        with open(file_path, "rb") as file:
            files = {"file": file}
            response = requests.post(url, headers=headers, files=files)
        try:
            return response.json(), response.status_code
        except:
            return response.text, response.status_code

    def list_stations_request(self, token):
        url = f"{config.API_URL}/stations"
        headers = {"X-OBSERVATORY-AUTH": token} if token else {}
        response = requests.get(url, headers=headers)
        try:
            return response.json(), response.status_code
        except:
            return response.text, response.status_code

    def list_operators_request(self, token):
        url = f"{config.API_URL}/operators"
        headers = {"X-OBSERVATORY-AUTH": token} if token else {}
        response = requests.get(url, headers=headers)
        try:
            return response.json(), response.status_code
        except:
            return response.text, response.status_code

    def get_debt_request(self, tag_operator, start_date, end_date, token, format_type="json"):
        url = f"{config.API_URL}/getDebt/{tag_operator}/{start_date}/{end_date}?format={format_type}"
        headers = {"X-OBSERVATORY-AUTH": token} if token else {}
        response = requests.get(url, headers=headers)
        try:
            return response.json(), response.status_code
        except:
            return response.text, response.status_code

    def pay_debt_request(self, from_operator, to_operator, start_date, end_date, token, format_type="json"):
        url = f"{config.API_URL}/payDebt/{from_operator}/{to_operator}/{start_date}/{end_date}?format={format_type}"
        headers = {"X-OBSERVATORY-AUTH": token} if token else {}
        response = requests.put(url, headers=headers)
        # try response.json(), else return response
        try:
            return response.json(), response.status_code
        except:
            return response.text, response.status_code

    def toll_stats_request(self, toll_operator, start_date, end_date, token, format_type="json"):
        url = f"{config.API_URL}/tollStats/{toll_operator}/{start_date}/{end_date}?format={format_type}"
        headers = {"X-OBSERVATORY-AUTH": token} if token else {}
        response = requests.get(url, headers=headers)
        try:
            return response.json(), response.status_code
        except:
            return response.text, response.status_code

    def logout_request(self, token):
        url = f"{config.API_URL}/logout"
        headers = {"X-OBSERVATORY-AUTH": token} if token else {}
        response = requests.post(url, headers=headers)
        try:
            return response.json(), response.status_code
        except:
            return response.text, response.status_code

    
    
