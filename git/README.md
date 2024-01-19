# Github ssh

Make sure you start you ssh agent from the terminal (one time?):
* `eval "$(ssh-agent -s)"`
* `ssh-add -l`

Then make sure that the key is added both as signing key and auth key to github.
Check if the name is the same in `.gitconfig` where specifies the `user.signingkey`
