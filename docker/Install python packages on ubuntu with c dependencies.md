A C-compiler is sometimes required to `pip install` `Python` packages.  I'm trying to `pip install` `StationManager` dependencies from a frozen `requirements.txt` from within a `python:3.7-slim` `Docker` container which doesn't come with the required compiler `gcc`.  Frustratingly it's not as simple as adding the line `apt-get install -y gcc` to the `Dockerfile` to install this to the system before attempting this `pip install`.

Some deeper digging reveals that `pyodbc` is where the issue lies ...

```python-traceback
...
Running setup.py install for pyodbc: finished with status 'error'
...
gcc: fatal error: cannot execute ‘cc1plus’: execvp: No such file or directory
compilation terminated.
error: command 'gcc' failed with exit status 1
...
```

A bit of searching reveals that `g++` not `gcc` is required ([#165 mkleehammer/pyodbc](https://github.com/mkleehammer/pyodbc/issues/165)) because the problematic file is a C++ file not a C file so `gcc` needs `cc1plus`!

Adding the suggested lines fixes the issue:

```Dockerfile
FROM python:3.7-slim
ENV PYTHONUNBUFFERED=1
WORKDIR /code
RUN apt-get update && apt-get install -y \
    g++ \
    unixodbc-dev \
    git 
COPY requirements.txt /code/
RUN pip install -r requirements.txt
COPY . /code/
```

#docker