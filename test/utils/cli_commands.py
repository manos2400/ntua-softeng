import requests
import json
import subprocess

import utils.config as config

def get_token():
    username = "admin"
    password = "freepasses4all"
    response = requests.post(
        f"{config.API_URL}/login",
        headers={"Content-Type": "application/x-www-form-urlencoded"},
        data=f"username={username}&password={password}",
        verify=False
    )
    if response.status_code == 200:
        return response.json().get("token")
    return None

def run_cli_command(self, command):
    command = f"{config.CLI_PATH} {command}"
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    try:
        stdout = json.loads(result.stdout)
    except json.JSONDecodeError:
        stdout = result.stdout
    return stdout, result.stderr, result.returncode
