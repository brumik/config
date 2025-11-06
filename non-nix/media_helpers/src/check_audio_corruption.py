import os
import sys
import subprocess
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

def check_file(filepath: str) -> tuple[str, bool, str]:
    """
    Runs flac/mp3val to check file integrity.
    Returns (filepath, is_good)
    """
    ext = Path(filepath).suffix.lower()

    if ext == ".flac":
        cmd = ["flac", "-t", "-s", filepath]
    elif ext == ".mp3":
        cmd = ["mp3val", filepath, "-f", "-nb"]
    else:
        return (filepath, True, "")  # skip unsupported files

    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    output = (result.stdout + result.stderr).strip()

    return (filepath, result.returncode == 0, output)

def check_audio_corruption(search_path, report_path, report_file, verbose = False):
    root_dir = Path(search_path)
    if not root_dir.is_dir():
        print(f"Error: search path is not a directory: {search_path}")
        sys.exit(1)

    print(report_path)
    Path(report_path).mkdir(parents=True, exist_ok=True)

    # Collect files
    print(f"Scanning directory: {search_path}")
    files = [
        os.path.join(root, f)
        for root, _, fs in os.walk(root_dir)
        for f in fs
        if f.lower().endswith((".mp3", ".flac"))
    ]
    print(f"Found {len(files)} audio files to check.\n")

    bad_count = 0
    good_count = 0
    unique_paths = set()
    verbose_logs = []

    # Run in parallel using threads (I/O bound -> best performance)
    max_workers = (os.cpu_count() or 4) * 2
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {executor.submit(check_file, f): f for f in files}
        for future in as_completed(futures):
            filepath, is_good, out = future.result()
            if verbose and out:
                verbose_logs.append(out)
            if is_good:
                print(".", end="", flush=True)
                good_count += 1
            else:
                print("f", end="", flush=True)
                bad_count += 1
                unique_paths.add(os.path.dirname(filepath))

    # Write results
    with open(os.path.join(report_path, report_file), "w") as rf:
        for path in sorted(unique_paths):
            rf.write(f"{path}\n")

    print()
    total = bad_count + good_count
    
    for item in sorted(verbose_logs):
        print(item)

    print(f"Corrupted {bad_count}/{total} files.")
    print(f"Report saved to: {report_file}")
