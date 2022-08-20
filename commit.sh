# Commit all untracked files as 'Add <FILENAME>'
git status --short \
    | grep '?? ' \
    | sed "s/?? //" \
    | xargs -I file sh -c 'git add file && git commit -m "Add file"'

# Commit all deleted files as 'Delete <FILENAME>'
git status --short --untracked-files \
    | grep 'D ' \
    | sed "s/D //" \
    | xargs -I file sh -c 'git add file && git commit -m "Delete file"'

# Commit all modified files as 'Modify <FILENAME>'
git status --short \
    | grep 'M ' \
    | sed "s/M //" \
    | xargs -I file sh -c 'git add file && git commit -m "Modify file"'