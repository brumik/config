import os
import sys
import subprocess
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor

FFPROBE_CMD = [
    "ffprobe", "-v", "error", "-select_streams", "a:0",
    "-show_entries", "stream=bit_rate",
    "-of", "default=noprint_wrappers=1:nokey=1"
]

def get_bitrate(filepath: str) -> int:
    """Return bitrate in bits per second, or 0 on error."""
    try:
        result = subprocess.run(
            FFPROBE_CMD + [filepath],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            check=False
        )
        return int(result.stdout.strip() or 0)
    except Exception:
        return 0

def folder_has_low_quality(folder: Path, min_bitrate: int) -> bool:
    """Return True if any MP3 in folder has bitrate below min_bitrate."""
    for mp3 in folder.glob("*.mp3"):
        if get_bitrate(str(mp3)) < min_bitrate:
            return True
    return False

def check_mp3_bitrate(search_path: Path, report_path: Path, report_file: str, min_bitrate: int = 250_000):
    """Recursively scan for folders containing MP3s and report low-quality ones."""

    if not search_path.is_dir() or not report_path.is_dir():
        print(f"Error: search path or report path is not a directory: {search_path}, {report_path}")
        sys.exit(1)

    bad, good = 0, 0
    unique_paths = set()

    # Find all folders under search_path that contain at least one MP3
    mp3_dirs = {p.parent for p in search_path.rglob("*.mp3")}

    if not mp3_dirs:
        print("No MP3 files found.")
        return

    # Threaded scanning for performance
    with ThreadPoolExecutor(max_workers=os.cpu_count() or 4) as pool:
        futures = {pool.submit(folder_has_low_quality, folder, min_bitrate): folder for folder in mp3_dirs}
        for fut in futures:
            folder = futures[fut]
            if fut.result():
                unique_paths.add(str(folder))
                print("f", end="", flush=True)
                bad += 1
            else:
                print(".", end="", flush=True)
                good += 1

    with open(report_path / report_file, "w") as rf:
        for path in sorted(unique_paths):
            rf.write(f"{path}\n")

    total = bad + good
    print(f"\nLow Quality MP3 folders {bad}/{total}. Results saved to: {report_path / report_file}")
