I want to use `pytest-django` to spin up a test `MySQL` database for every test run.  By default `pytest-django` creates a test database called `test_NAME`, and the default USER does not have the necessary PRIVILEGES to create it.  

[Yurii Halapup from this Stackoverflow thread](https://stackoverflow.com/questions/14186055/django-test-app-error-got-an-error-creating-the-test-database-permission-deni) recommends explictely naming the test database in `settings.py` ...

```python
    DATABASES = {
    'default': {
        ...
        'TEST': {
            'NAME': 'test_finance',
        },
    }
}
```

... starting the `MySQL` shell ...

```bash
mysql -u root -p
```

... and running ...

```bash
GRANT ALL PRIVILEGES ON test_NAME.* TO 'USER'@'HOST';
```

The test database creation now works as expected

#django