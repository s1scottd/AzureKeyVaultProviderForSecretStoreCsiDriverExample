import subprocess
import json
import sys

def run_azure_command():
    # Run the Azure CLI command.
    command = ["az", "ad", "sp", "create-for-rbac", "-n", "http://secrets-store-test", "-o", "json"]
    result = subprocess.run(command, text=True, capture_output=True)

    # If the command was successful.
    if result.returncode == 0:
        # Parse the JSON output.
        json_output = json.loads(result.stdout)

        # Access JSON fields. Adjust these according to your needs.
        app_id = json_output['appId']
        password = json_output['password']

        # Write to stdout
        sys.stdout.write(f"{app_id}\n")
        sys.stdout.write(f"{password}\n")
    else:
        sys.stderr.write(f"Error running command: {result.stderr}")
        sys.exit(result.returncode)

run_azure_command()