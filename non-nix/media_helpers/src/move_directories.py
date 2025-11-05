import subprocess
import os
import shutil

def remove_all_folders_in_directory(src_dir):
    for item in os.listdir(src_dir):
        item_path = os.path.join(src_dir, item)
        if os.path.isdir(item_path):
            shutil.rmtree(item_path)

def move_directories(src, target):
    command = [
        'rsync',
        '-a',  # Archive mode
        '--progress',  # Show progress during transfer
        '--update',  # Skip files that are newer on the receiver
        src + "/",
        target + "/"
    ]
    subprocess.run(command)

