I can now cache `poetry` dependencies in `GitHub Actions` even if a previous action step fails thanks to `actions/restore` & `actions/save`.

I can combine `always()` with `steps.cache.outputs.cache-hit != 'true'` using `if` ...

```yml
name: "Test"

on:
  pull_request:
  push:

jobs:
  tests:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Restore python poetry dependencies from cache
      uses: actions/cache/restore@v3
      id: cache
      with:
        path:  ~/.cache/pypoetry
        key: ${{ runner.os }}-poetry-${{ hashFiles('poetry.lock') }}
    - run: exit 1
    - name: Cache python dependencies
      uses: actions/cache/save@v3
      if: always() && steps.cache.outputs.cache-hit != 'true'
      with:
        path: ~/.cache/pypoetry
        key: ${{ runner.os }}-poetry-${{ hashFiles('poetry.lock') }}
```

#github-actions
