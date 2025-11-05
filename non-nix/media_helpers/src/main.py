import sys
from datetime import datetime
from move_directories import move_directories, remove_all_folders_in_directory
from convert_flac_downsample_44_16 import downsample_flac
from shared_utils import load_env
from check_audio_corruption import check_audio_corruption

def timestamp_name(name):
    current_time = datetime.now().strftime('%Y-%m-%d %H:%M')
    return current_time + " - " + name

def main():
    env_vars = load_env()

    src_dir: str = env_vars["NEW_INCOMING_DIR"]
    in_dir: str = env_vars["INCOMING_DIR"]
    lib_dir: str = env_vars["LIB_DIR"]
    in_bckp_dir: str = in_dir + "-bckp"
    in_reports_dir: str = env_vars["INCOMING_REPORTS_DIR"]
    lib_reports_dir: str = env_vars["LIB_REPORTS_DIR"]
    report_corrupted_name: str = env_vars["PATHS_CORRUPTED"]

    while True:
        print("\nOptions:")
        print("1. NEW: Move files from new to import (and backup)")
        print("2. IMPORTED: Flac and mp3: check for any corruption")
        print("3. IMPORTED: Flac: convert to 44khz/16bit and check for any corruption")
        print("4. IMPORTED: Restore incoming dir from incoming-backup")
        print("5. IMPORTED: Delete all files in the incoming and incoming-backup dir")
        print("6. EXISTING: Flac and mp3: check for any corruption")
        print("10. Exit")

        choice = input("Select an option: ")

        if choice == '1':
            move_directories(src_dir, in_dir)
            move_directories(in_dir, in_bckp_dir)
            remove_all_folders_in_directory(src_dir)
            print("\n-------------------------------------------------------\n")
        elif choice == '2':
            check_audio_corruption(in_dir, in_reports_dir, timestamp_name(report_corrupted_name))
            print("\n-------------------------------------------------------\n")
        elif choice == '3':
            downsample_flac(in_dir)
            print("\n-------------------------------------------------------\n")
            check_audio_corruption(in_dir, in_reports_dir, timestamp_name(report_corrupted_name))
            print("\n-------------------------------------------------------\n")
        elif choice == '4':
            remove_all_folders_in_directory(in_dir)
            move_directories(in_bckp_dir, in_dir)
        elif choice == '5':
            print("Deleting backup dir, incoming dir")
            remove_all_folders_in_directory(in_dir)
            remove_all_folders_in_directory(in_bckp_dir)
            print("\n-------------------------------------------------------\n")
        elif choice == "6":
            check_audio_corruption(lib_dir, lib_reports_dir, timestamp_name(report_corrupted_name))
            print("\n-------------------------------------------------------\n")
        elif choice == '10':
            print("Exiting program")
            sys.exit(0)
        else:
            print("Invalid option. Please try again.")

if __name__ == "__main__":
    main()
