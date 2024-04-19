`Erlang` requires that ...
> ... the `.erlang.cookie` file accessible only by the owner of the file. This is a requirement.
> -- https://www.erlang.org/docs/26/getting_started/conc_prog

In `UNIX` I can ...
```sh
cd
cat > .erlang.cookie
this_is_very_secret
chmod 400 .erlang.cookie
```

In `Windows` I can use `icalcs` to do the same thing ...
```cmd
icacls .erlang.cookie /inheritance:r
icacls .erlang.cookie /grant %USERNAME%:R
```

I reckon I could equivalently set this via `Properties > Security` by removing all & then adding myself