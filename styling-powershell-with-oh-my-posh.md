# Styling Powershell with [`oh-my-posh`](https://github.com/jandedobbeleer/oh-my-posh)

Coming from [`oh-my-zsh`](https://github.com/ohmyzsh/ohmyzsh) I wanted to style my
prompt to a [fancy theme](https://ohmyposh.dev/docs/themes) and enable answering the 
following questions with my shell prompt:

- What git branch am I on? 
- Am I up to date with upstream?
- Is my virtual environment activated?

The only catch was installing a font which can display all of the emojis used by each
theme.  [`nerd-fonts`](https://github.com/ryanoasis/nerd-fonts) `Meslo` is recommended
by `oh-my-posh`, however, even the mono `Meslo` fonts have too much whitespace between
characters and look weird in `vscode`.  The [`powerlevel10k`](https://github.com/romkatv/powerlevel10k)
`MesloLGS NF Regular.ttf` does work.

After installing my font I checked it was installed by going to `C:\Windows\Fonts` and
finally I copied and pasted the filename into `Settings > Terminal > Font Family` to
set it as the default in `vscode`

:exclamation: See profile [here](https://github.com/rdmolony/dotfiles-windows)

#powershell
