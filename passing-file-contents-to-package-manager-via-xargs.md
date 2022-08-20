I want to install multiple packages specified in `dev-requirements.txt` via `conda`

```txt
jupyter-packaging>=0.10
pytest
pytest-cov
flake8
nbclassic
```

I can concatenate the file contents to one-line via `cat dev-requirements.txt | xargs` or `jupyter-packaging>=0.10 pytest pytest-cov flake8 nbclassic`, and then pass this string to `mamba` via `cat dev-requirements.txt | xargs mamba install -y`