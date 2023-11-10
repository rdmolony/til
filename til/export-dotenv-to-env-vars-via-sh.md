I can save my environment variables in a `.env` file in my home directory ...

```
GITHUB_TOKEN="i-am-secret"
```

... & load them as environment variables via `sh` ...

```sh
if [ -f "$HOME/.env" ]
then
  export $(cat "$HOME/.env" | xargs)
fi
```

#shell-scripting
#sh