I want to run `python manage.py collectstatic` on startup.  I have a file called `startup.sh` that includes this command as part of its startup.  Trouble is that I often run `docker compose run web bash` in which case this command is skipped.  

> When you run docker like this: `docker run -i -t ubuntu bash` the entrypoint is the default `/bin/sh -c`, the image is `ubuntu` and the command is `bash`.
> If you were executing  `docker run -i -t ubuntu <cmd>`.  The parameter of the entrypoint is `<cmd>`.
> [docker - What is the difference between CMD and ENTRYPOINT in a Dockerfile? - Stack Overflow](https://stackoverflow.com/questions/21553353/what-is-the-difference-between-cmd-and-entrypoint-in-a-dockerfile#:~:text=Docker%20has%20a%20default%20entrypoint%20which%20is%20%2Fbin%2Fsh,thing%20that%20gets%20executed%20is%20%2Fbin%2Fsh%20-c%20bash.)

It makes sense to create a `debug.sh` command like ...

```bash
#!/bin/sh
python manage.py collectstatic
bash
```

... which will be my `command` via `docker compose run web sh debug.sh` 

#docker
#django