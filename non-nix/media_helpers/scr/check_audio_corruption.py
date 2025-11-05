#!/usr/bin/env python3
import os
import sys
import subprocess
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
from dotenv import load_dotenv

def check_file(filepath: str) -> tuple[str, bool]:
    """
    Runs flac/mp3val to check file integrity.
    Returns (filepath, is_good)
    """
    ext = Path(filepath).suffix.lower()

    if ext == ".flac":
        cmd = ["flac", "-t", filepath]
    elif ext == ".mp3":
        cmd = ["mp3val", filepath, "-f", "-nb"]
    else:
        return (filepath, True)  # skip unsupported files

    result = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return (filepath, result.returncode == 0)

def main():
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
        search_path = os.getenv("INCOMING_DIR")
        report_path = os.getenv("INCOMING_REPORTS_DIR")
        report_file = os.path.join(report_path, os.getenv("PATHS_CORRUPTED", "corrupted.txt"))
    else:
        search_path = os.getenv("LIB_DIR")
        report_path = os.getenv("LIB_REPORTS_DIR")
        report_file = os.path.join(report_path, os.getenv("PATHS_CORRUPTED", "corrupted.txt"))

    if not search_path or not report_path:
        print("Missing required environment variables in .env")
        sys.exit(1)

    Path(report_path).mkdir(parents=True, exist_ok=True)

    # Collect files
    print(f"Scanning directory: {search_path}")
    files = [
        os.path.join(root, f)
        for root, _, fs in os.walk(search_path)
        for f in fs
        if f.lower().endswith((".mp3", ".flac"))
    ]
    print(f"Found {len(files)} audio files to check.\n")

    bad_count = 0
    good_count = 0
    unique_paths = set()

    # Run in parallel using threads (I/O bound -> best performance)
    max_workers = os.cpu_count() * 2 if os.cpu_count() else 8
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {executor.submit(check_file, f): f for f in files}
        for future in as_completed(futures):
            filepath, is_good = future.result()
            if is_good:
                print(".", end="", flush=True)
                good_count += 1
            else:
                print("f", end="", flush=True)
                bad_count += 1
                unique_paths.add(os.path.dirname(filepath))

    # Write results
    with open(report_file, "w") as rf:
        for path in sorted(unique_paths):
            rf.write(f"{path}\n")

    print()
    total = bad_count + good_count
    print(f"Corrupted {bad_count}/{total} files.")
    print(f"Report saved to: {report_file}")

if __name__ == "__main__":
    main()
