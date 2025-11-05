IMPORTANT:

1. Read what each script does before you run it!
2. Use the flake.nix in devshell OR go and install the dependencies from there on your system
3. Copy and set up your `.env` in the same folder as `.env.example`
4. Run the script `python3 ./src/main.py` from the ROOT path, otherwise they won't be able to read `.env` file.
5. Be careful, not all scripts modify the files, but which do, they often do in place, have backups!
6. Do not use network shares for in place modifications. Copy to local ssd, run modification, rsync it back!

Example command to move back modified or updated files (from mp3 to flac or similar):

```bash
# Trailing slashes are important!
# Ommit the `--delete` if you did not deleted files (better safe than sorry)
rsync -avz  --no-owner --no-group --delete /home/username/Music/music/ /mnt/media/library/music/
```
