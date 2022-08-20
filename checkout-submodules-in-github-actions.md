I wanted to store `til` markdown files in `Obsidian` markdown file in a dedicated repository & link to an `mkdocs` static site via `git submodule`.

It turns out that `actions/checkout@v2` does not automatically fetch submodules!  I had to ask it to do so via ...

```yml
        ...
        - uses: actions/checkout@v2
        with:
            submodules: true
        ...
```

#mkdocs
#github-actions
