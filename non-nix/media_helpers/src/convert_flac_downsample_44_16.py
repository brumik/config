import os
import sys
import subprocess
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

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
        print("Skipping (could not read): {file_path}")
        return False

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
            print(".", end="", flush=True)
            return True
        except subprocess.CalledProcessError:
            print("f", end="", flush=True)
            if temp_file.exists():
                temp_file.unlink()  # remove temp file
            return False
    else:
        print("s", end="", flush=True)
        return True
        
def downsample_flac(search_path):
    root_dir = Path(search_path)
    if not root_dir.is_dir():
        print(f"Error: search path is not a directory: {search_path}")
        sys.exit(1)

    files = list(root_dir.rglob("*.flac"))
    print(f"Found {len(files)} FLAC files in {search_path}")
    print("Legend: '.' - done, 's' - skip (already good), 'f' - failed")

    converted_count = 0

    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        futures = {executor.submit(process_file, f): f for f in files}
        for future in as_completed(futures):
            is_good = future.result()
            if is_good:
                converted_count += 1

    print()
    print(f"Converted {converted_count}/{len(files)} files.")
