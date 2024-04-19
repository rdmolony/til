I want to backup source code saved in a `Windows Subsystems for Linux (WSL)` subfolder to `OneDrive` daily to add an extra degree of redundancy on top of `GitHub`.

I have a local `OneDrive` folder that syncs automatically and `Task Scheduler` can run `bat` files at a given time.  I created a simple file `backup-stationmanager.bat` ...

```cmd
xcopy ^
  "\\wsl$\Ubuntu\home\rdmolony\Code\StationManager\.git" ^
  "C:\Users\Rowan.Molony\OneDrive - Mainstream Renewable Power\Documents\Backups\StationManager\.git" ^
  /y /s
```

... that uses `^` instead of `\` for multiline, `\y` to accept all and `\s` to copy subfolders


#windows
