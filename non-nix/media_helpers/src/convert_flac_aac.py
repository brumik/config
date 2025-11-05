#!/usr/bin/env python3
import subprocess
from pathlib import Path
from multiprocessing import Pool, cpu_count
import argparse
import sys

# Set up argument parser
parser = argparse.ArgumentParser(
    description="Convert all FLAC files in a directory (recursively) to M4A using AAC encoding."
)
parser.add_argument(
    "base_dir",
    type=str,
    nargs="?",
    help="Path to the base directory containing FLAC files"
)

args = parser.parse_args()

# If base_dir is not provided, print help and exit
if not args.base_dir:
    parser.print_help()
    sys.exit(1)

BASE_DIR = Path(args.base_dir)
if not BASE_DIR.is_dir():
    print(f"Error: {BASE_DIR} is not a valid directory.")
    sys.exit(1)

MAX_PROCESSES = cpu_count()  # Use number of CPU cores

# Function to convert a single file
def convert_flac(f):
    out = f.with_suffix(".m4a")
    try:
        cmd = [
            "ffmpeg",
            "-y",                # overwrite output
            "-v", "error",       # only show errors
            "-stats",
            "-i", str(f),
            "-vn",
            "-c:a", "aac",
            "-b:a", "256k",
            "-map_metadata", "0",
            "-map", "0:a",
            "-f", "mp4",
            "-movflags", "+faststart",
            str(out)
        ]
        subprocess.run(cmd, check=True)

        # Check output
        if out.is_file() and out.stat().st_size > 1024:
            f.unlink()  # delete original
            return ("success", str(f))
        else:
            return ("fail", str(f))
    except subprocess.CalledProcessError:
        return ("fail", str(f))

# Collect all FLAC files
flac_files = list(BASE_DIR.rglob("*.flac"))

if not flac_files:
    print(f"No FLAC files found in {BASE_DIR}")
    sys.exit(0)

print(f"Found {len(flac_files)} FLAC files. Starting conversion with {MAX_PROCESSES} parallel processes...\n")

# Run conversions in parallel
with Pool(processes=MAX_PROCESSES) as pool:
    results = pool.map(convert_flac, flac_files)

# Count successes and failures
success_count = sum(1 for r in results if r[0] == "success")
fail_count = sum(1 for r in results if r[0] == "fail")

# Print summary
print("\nConversion complete!")
print(f"Successful conversions: {success_count}")
print(f"Failed conversions: {fail_count}")

