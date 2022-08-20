I wanted to adapt my `zshrc` so that `oh-my-zsh`, `powerlevel10k`, `conda` & `nix` install on startup

I can check for directories via `-d` ...

```zsh
if ! [ -d "$HOME/.oh-my-zsh" ]; then

    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh "$HOME/.oh-my-zsh"

fi
```

I tried to check for commands via `command -v MYCOMMAND` ...

```zsh
if ! [ -x "$(command -v nix)" ]; then

    sh <(curl -L https://nixos.org/nix/install) --no-daemon

fi
```

... however, this reinstalled the packages on every startup!  Why?

Not a big deal.  I can just use the same directory check; `.nix-profiles` for `nix` and `mambaforge` for `conda`!

> [How can I check if a program exists from a Bash script? - Stack Overflow](https://stackoverflow.com/questions/592620/how-can-i-check-if-a-program-exists-from-a-bash-script)

#date/2022-07-11
#til
#shell
