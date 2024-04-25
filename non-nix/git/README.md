# Github ssh

Run:
```sh
ln -s ~/pathToConfig/git/.gitconfig ~/
ln -s ~/pathToConfig/git/config ~/.ssh/
```

Make sure you start you ssh agent from the terminal (one time?):
* `eval "$(ssh-agent -s)"`
* `ssh-add -l`

Then make sure that the key is added both as signing key and auth key to github.
Make sure that the name of the default key is `id` and `id.pub`. This is what is
set for signing in `.gitconfig` and as a default key in `config` for ssh.
