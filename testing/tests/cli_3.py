import unittest

from utils.cli_commands import run_cli_command

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# ~~~~~~~~~~~~~~~~~~~~~ PART 3: LOGOUT TESTS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

class CLI(unittest.TestCase):

    # ~~~~~~~~~~~~~~~~~~~~~ LOGOUT ~~~~~~~~~~~~~~~~~~~~~ #

    def test_logout(self):
        out, err, code = run_cli_command(self, "logout")
        self.assertEqual(code, 0)
        self.assertEqual(out, "Logged out successfully.\n")

    def test_logout_again(self):
        out, err, code = run_cli_command(self, "logout")
        self.assertEqual(code, 0)
        self.assertEqual(out, "No active session found.\n")


if __name__ == "__main__":
    unittest.main()


    
