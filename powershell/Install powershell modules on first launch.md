I wanted to setup my `$PROFILE` so that any external modules ([`oh-my-posh`](https://github.com/JanDeDobbeleer/oh-my-posh), [`posh-git`](https://github.com/dahlbyk/posh-git) and [`powershell-git-aliases`](https://github.com/gluons/powershell-git-aliases)) install on first launch.

I added a simple if statement to the top of my profile ([here](https://stackoverflow.com/questions/28740320/how-do-i-check-if-a-powershell-module-is-installed))

```powershell
if (-Not (Get-Module -Name oh-my-posh)) {
    Install-Module oh-my-posh -Scope CurrentUser
} 
if (-Not (Get-Module -Name git-aliases)) {
    Install-Module git-aliases -Scope CurrentUser
}
```

This creates two problems:

1. If one of the modules is not at the latest version, `powershell` tries to install it alongside the existing version in a new directory alongside the old version so I then have

```
oh-my-posh
    > 5.9.0
    > 5.12.1
```

2. For whatever reason it's a really really slow operation to run on every startup: 16888ms vs 1892ms

For now I'm keeping all external modules as a comment at the bottom of my profile

:exclamation: See profile [here](https://github.com/rdmolony/dotfiles-windows)

#powershell
