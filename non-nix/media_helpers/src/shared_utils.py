import os
import sys
from dotenv import load_dotenv

def load_env(file_path=".env"):

    if not os.path.exists(file_path):
        print(".env file not found")
        sys.exit(1)
    load_dotenv(file_path)

    required_vars = [
        "ROOT_DIR",
        "NEW_INCOMING_DIR",
        "INCOMING_DIR",
        "INCOMING_REPORTS_DIR",
        "LIB_DIR",
        "LIB_REPORTS_DIR",
        "PATHS_MP3_FILE",
        "PATHS_FLAC_FILE",
        "PATHS_OTHERS_FILE",
        "PATHS_LOW_QUALITY",
        "PATHS_LOW_QUALITY_FILTERED",
        "PATHS_CORRUPTED"
    ]

    env_vars = {}

    for var in required_vars:
        value = os.getenv(var)
        if not value:
            print(f"Error: {var} is not set")
            sys.exit(1)
        env_vars[var] = value

    return env_vars
