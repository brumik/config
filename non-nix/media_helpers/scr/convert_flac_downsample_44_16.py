#!/usr/bin/env python3
import os
import sys
import subprocess
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
from dotenv import load_dotenv

# Load environment variables
if not os.path.exists(".env"):
    print(".env file not found")
    sys.exit(1)

load_dotenv(".env")

# Validate argument
if len(sys.argv) != 2 or sys.argv[1] not in ("incoming", "lib"):
    print(f"Usage: {sys.argv[0]} {{incoming|lib}}")
    sys.exit(1)

mode = sys.argv[1]

# Resolve paths based on mode
if mode == "incoming":
    search_path = os.getenv("INCOMING_DIR", "")
else:
    search_path = os.getenv("LIB_DIR", "")

if not search_path:
    print("Missing required environment variables in .env")
    sys.exit(1)

# Configuration
TARGET_SR = 44100
TARGET_BD = 16
MAX_WORKERS = os.cpu_count() or 1  # use number of CPU cores

def get_flac_info(file_path):
    """Return (sample_rate, bit_depth) of a FLAC file using soxi."""
    try:
        sr = int(subprocess.check_output(["soxi", "-r", str(file_path)]).decode().strip())
        bd = int(subprocess.check_output(["soxi", "-b", str(file_path)]).decode().strip())
        return sr, bd
    except subprocess.CalledProcessError:
        return None, None

def process_file(file_path):
    sr, bd = get_flac_info(file_path)
    if sr is None or bd is None:
        print(f"Skipping (could not read): {file_path}")
        return

    if sr > TARGET_SR or bd > TARGET_BD:
        temp_file = file_path.with_suffix(".tmp.flac")
        cmd = [
            "sox", str(file_path),
            "-b", str(TARGET_BD),
            str(temp_file),
            "rate", "-v", str(TARGET_SR),
            "dither"
        ]
        try:
            subprocess.run(cmd, check=True)
            # Replace original with downsampled file
            temp_file.replace(file_path)
            print(f"Downsampled in place: {file_path}")
        except subprocess.CalledProcessError:
            print(f"Failed to process: {file_path}")
            if temp_file.exists():
                temp_file.unlink()  # remove temp file
    else:
        print(f"Skipped (already ≤ target): {file_path}")
        
# def process_file(file_path):
#     sr, bd = get_flac_info(file_path)
#     if sr is None or bd is None:
#         print(f"Skipping (could not read): {file_path}")
#         return
#
#     if sr > TARGET_SR or bd > TARGET_BD:
#         output_file = file_path.with_name(file_path.stem + "_down.flac")
#         cmd = [
#             "sox", str(file_path),
#             "-b", str(TARGET_BD),
#             str(output_file),
#             "rate", "-v", str(TARGET_SR),
#             "dither"
#         ]
#         try:
#             subprocess.run(cmd, check=True)
#             print(f"Downsampled: {file_path} -> {output_file}")
#         except subprocess.CalledProcessError:
#             print(f"Failed to process: {file_path}")
#     else:
#         print(f"Skipped (already ≤ target): {file_path}")

def main():
    root_dir = Path(search_path)
    if not root_dir.is_dir():
        print(f"Error: search path is not a directory: {search_path}")
        sys.exit(1)

    flac_files = list(root_dir.rglob("*.flac"))
    print(f"Found {len(flac_files)} FLAC files in {search_path}")

    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        executor.map(process_file, flac_files)

if __name__ == "__main__":
    main()

