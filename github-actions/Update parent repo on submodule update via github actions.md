I want to update my blog `rdmolony.github.io` on updating `til`.

I can add an action to the `til` repo to ...

- Checkout the parent repo or `rdmolony/rdmolony.github.io`
- Fetch the latest `til`
- Commit the latest SHA

... via ...

```yml
name: ci
on:
  push:
    branches:
      - main
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          repository: 'rdmolony/rdmolony.github.io'
          submodules: true
      - name: Setup git config
        run: |
          git config --global user.name "GitHub Actions Bot"
          git config --global user.email "<>"
      - run: git submodule foreach --recursive git pull
      - run: git add docs/til && git commit -m "Update til"
```

> https://stackoverflow.com/questions/62960533/how-to-use-git-commands-during-a-github-action

#github-actions
#git