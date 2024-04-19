I'm playing with `Erlang` & want to send messages between these two machines

I found that I couldn't access one from the other in `Erlang` so I tried `ping` ...

- Same network?

- Host names?

I can run `hostname` on both machines

> On `Mac` the hostname here is wrong!  It tells me I'm `Rowan-MBP`, however, I can see in `Sharing` that it is `Rowans-MacBook-Pro`. Weird.

Or I can run `ipconfig` on `Windows` & check IPv4
And `ifconfig` on `Mac` & check `inet`

- Ping

I should be able to ping one machine from the other ...
```sh
ping Windows.local
```
... got through, however ...
```cmd
ping Rowans-MacBook-Pro.local
```
... resolved to the correct IP but didn't manage to send any messages!

This means I have a Firewall issue on my Mac!

So I disabled "Block all incoming connections" in `System Preferences > Security & Privacy > Firewall` & immediately I'm prompted with ...

> Do you want the application "epmd" to accept incoming network connections?

... & `epmd` is the `Erlang Port Mapper Daemon`!  
https://www.erlang.org/doc/man/epmd.html

And now I can `ping` my `MacBook` from `Windows`

#networking