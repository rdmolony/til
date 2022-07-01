# How to unit test huey tasks

I want to unit test some `huey` tasks that are periodically run by `Django` to import `csv` files to a `MSSQL` database.  To do so I must run them in **immediate mode**, however, this is set in `settings.py` which is tricky to override in `pytest-django`.  

`pytest-django` implements a `pytest` fixture called `settings` that enables overriding `settings.py` on a test-by-test basis.  So I tried `settings.HUEY['immediate'] = True` prior to importing the `huey` task.  Checking the `huey` task via `import_datafile.huey.immediate` shows this doesn't work.  Instead, I can override the task manually via `import_datafile.huey.immediate = True` prior to calling it.  This does the trick

#django