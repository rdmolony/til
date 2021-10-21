# Running scripts on launch

I wanted to set some aliases for `conda` in a separate `conda-aliases.ps1` script and activate custom [`oh-my-posh`](https://github.com/JanDeDobbeleer/oh-my-posh) configuration `rdmolony.omp.json` on startup both of which are saved in the same directory as `$PROFILE` so I can track them in the same repository.

Running `. .\conda-aliases.ps1` works fine when opening in a shell in the `$PROFILE` directory, however, when changing directory `powershell` can no longer find the file!  I need to pass an absolute path to the script instead, however, I need to make use of an environmental variable holding the `$PROFILE` directory to make this generalisable.  I can use either `(Get-ChildItem $PROFILE)` (see [here](https://www.sean-lloyd.com/post/get-path-relative-script-location-powershell/)) or for the parent of any file `$PSScriptRoot)` ([here](https://thinkpowershell.com/add-script-flexibility-relative-file-paths/))

> :book: I can use `dir env:` to get a list of all environmental variables

Replacing

```powershell
. ".\conda-aliases.ps1"
```

With

```powershell
. (Join-Path  $PSScriptRoot ".\conda-aliases.ps1")
```

Does the trick ([here](https://stackoverflow.com/questions/13783759/concatenate-network-path-variable)!