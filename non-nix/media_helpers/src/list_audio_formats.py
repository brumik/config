from pathlib import Path
from collections import defaultdict

AUDIO_EXTS = {
    ".mp3",
    ".flac",
    ".wav",
    ".aac",
    ".ogg",
    ".m4a",
    ".wma",
    ".alac",
    ".ape",
    ".aiff",
    ".aif",
    ".opus",
    ".ra",
    ".amr",
    ".wv",
    ".tta",
    ".dff",
    ".dsf",
    ".au",
    ".snd",
    ".voc",
    ".mid",
    ".midi",
}


def list_audio_formats(search_path: Path, report_path: Path, report_file: str):
    """Scan for all audio formats and write report with album counts."""
    if not search_path.is_dir() or not report_path.is_dir():
        print(
            f"Error: search path or report path is not a directory: {search_path}, {report_path}"
        )
        return

    # format_stats[ext][folder] = count
    format_stats = defaultdict(lambda: defaultdict(int))

    for filepath in search_path.rglob("*"):
        if filepath.is_file():
            ext = filepath.suffix.lower()
            if ext in AUDIO_EXTS:
                format_stats[ext][str(filepath.parent)] += 1

    if not format_stats:
        print("No audio files found.")
        return

    report_file_path = report_path / report_file

    # Write detailed report with number of albums
    with open(report_file_path, "w", encoding="utf-8") as rf:
        for ext in sorted(format_stats):
            album_count = len(format_stats[ext])
            file_count = sum(format_stats[ext].values())
            rf.write(
                f"[{ext.lstrip('.').lower()}] {album_count} album{'s' if album_count > 1 else ''}, {file_count} file{'s' if file_count > 1 else ''}\n"
            )
            for folder, count in sorted(format_stats[ext].items()):
                rf.write(f"{folder} ({count})\n")
            rf.write("\n")

    # Plain text summary
    summary_lines = []
    for ext in sorted(format_stats):
        album_count = len(format_stats[ext])
        file_count = sum(format_stats[ext].values())
        summary_lines.append(
            f"{ext.lstrip('.').lower()}: {file_count} file{'s' if file_count > 1 else ''}, {album_count} album{'s' if album_count > 1 else ''}"
        )

    summary_text = "\n".join(summary_lines)
    print(summary_text)
    print(f"Detailed report saved to {report_file_path}")
