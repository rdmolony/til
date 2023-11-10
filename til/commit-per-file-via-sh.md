I have multiple new files in `til` that I have not yet committed to source control.

I'd like to commit each individually with a generic name `Add <FILENAME>`

I'd also like each update too look like `Update <FILEPATH>`

I can get a list of all files via ...

```zsh
git status --short
# ?? <FILENAME>
```

... and select only untracked files via `--untracked` or via `grep` ... 

```zsh
git status --short | grep "??"
# <FILENAME>
```

... and remove the string `?? ` via `sed` ...

```zsh
git status --short | grep "??" | sed 's/?? //"
# <FILENAME>
```

... and loop through and commit via `xargs` ...

```zsh
# Commit all untracked files as 'Add <FILENAME>'
git status --short --untracked-files \
    | grep "??" \
    | sed "s/?? //" \
    | xargs -I file sh -c 'git add file && git commit -m "Add file"'
```

... where `-I` means `replace-str`

> i.e. replace occurrences of replace-str in the initial-arguments with names read from  standard  input.

I can modify this slightly to update or delete each file via ...

```zsh
# Commit all modified files as 'Modify <FILENAME>'
git status --short --untracked-files=no \
    | grep "M " \
    | sed "s/M //" \
    | xargs -I file sh -c 'git add file && git commit -m "Modify file"'
```

#shell
#git
