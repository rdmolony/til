# How to run django and mysql on docker compose

I want to run a `Django` application on `docker-compose` so that I can define the required infrastructure and dependencies as code and run this application on any machine.

The [Official `Docker` `Django` tutorial](https://docs.docker.com/samples/django/) demonstrates how to setup a minimal `Django` application on `docker-compose`.  I want to use a `mysql` database instead of `postgres` which means that I need to configure my `docker-compose.yml` differently.

Following the [Official `MySQL` `Docker` guide](https://hub.docker.com/_/mysql/) & [dockerizing-a-django-mysql-project-g4m](https://dev.to/foadmoha/dockerizing-a-django-mysql-project-g4m) I can use ...

```yml
...
version: '3.7'
services:
  db:
    image: mysql
    volumes:
      - ./data/db:/var/lib/mysql
      - /tmp/app/mysqld:/run/mysqld
    environment:
      - MYSQL_DATABASE=mysql
      - MYSQL_USER=mysql
      - MYSQL_PASSWORD=mysql
    ports:
      - "3406:3306"
  web:
    build: .
    command: python manage.py runserver 0.0.0.0:8000
    ports:
      - "8000:8000"
    volumes:
      - .:/app
      - /tmp/app/mysqld:/run/mysqld
    depends_on:
      - db
...
```

**Note:**
    - I had to change the default port on my host (`Windows Subsystem for Linux 2`) to `3406` as `3306` wasn't available - [how-do-i-change-the-default-port-on-which-my-docker-mysql-instance-runs](https://stackoverflow.com/questions/59957719/how-do-i-change-the-default-port-on-which-my-docker-mysql-instance-runs)
    - `/tmp/app/mysqld:/run/mysqld` maps the contents of `var/run/mysqld` of the container to a local folder. This file contains socket information that enables the web service to talk to the database service


I also need to edit my application's `settings.py` to point to this `docker-compose` database ...

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'mysql',
        'USER': 'mysql',
        'PASSWORD': 'mysql',
        'HOST': 'db',
        'PORT': 3306,
    }
}
```

Now when I run `docker-compose up`, both images build fine but `MySQL` causes problems ...

```
Plugin mysqlx reported: 'Setup of socket: '/var/run/mysqld/mysqlx.sock' failed, can't create lock file /var/run/mysqld/mysqlx.sock.lock'
```

[django-container-deployment-mysql-docker-deployment/](https://developpaper.com/django-container-deployment-mysql-docker-deployment/) suggests installing a `MySQL` connector in the `Django` application ...

```Dockerfile
...
RUN apt-get install python3-dev default-libmysqlclient-dev -y
...
```

If this is a connector issue this should resolve it.