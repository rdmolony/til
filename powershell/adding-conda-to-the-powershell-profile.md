# Adding conda to the powershell profile

I wanted to automatically activate [`conda`](https://github.com/conda/conda) in powershell on startup.

In `zsh` I can edit the `~/.zshrc`, in `powershell` the equivalent is the unwieldy `C:\Users\Rowan.Molony\OneDrive - Mainstream Renewable Power\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1` or `$PROFILE`.  `conda` supports editing this profile by running `conda init powershell` in the `Anaconda powershell prompt` that comes installed with `miniconda` or `Anaconda`. 

By default `powershell` does not allow the user to run unsigned scripts!  To override this I had to change the execution policy to `RemoteSigned` for the `CurrentUser` as I don't have admin rights beyond this.

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

From the [microsoft docs](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies) `RemoteSigned` means:

> - Requires a digital signature from a trusted publisher on scripts and configuration files that are downloaded from the internet which includes email and instant messaging programs.
> - Doesn't require digital signatures on scripts that are written on the local computer and not downloaded from the internet.
> - Runs scripts that are downloaded from the internet and not signed, if the scripts are unblocked, such as by using the Unblock-File cmdlet.
> - Risks running unsigned scripts from sources other than the internet and signed scripts that could be malicious.

Now `powershell` boots with `conda` initialised and visible in the prompt!

This means that the powershell shell in `vscode` now has access to `conda`.  It also means that I can now style my prompt using `oh-my-posh` (see [Styling powershell with oh-my-posh](https://github.com/rdmolony/til/blob/main/powershell/styling-powershell-with-oh-my-posh.md)) and make it permanent.
