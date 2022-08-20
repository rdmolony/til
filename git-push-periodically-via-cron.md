I want to sync my Obsidian notes with `GitHub` 

I can create a simple shell script to `cd` & `git push` ...
```sh
#!/bin/sh/
cd '/mnt/c/Users/Rowan.Molony/OneDrive - Mainstream Renewable Power/Documents/Obsidian Vault'
echo $(pwd)
git add .
git commit -m "$(date)"
git push
```

... and run via `crontab` by editing its entries with `crontab -e` and adding ...

```sh
00 09 * * 1-5 sh ~/Code/cronjobs/push_obsidian_notes_to_github.sh
```

... where ...

```
* * * * * command to be executed
- - - - -
| | | | |
| | | | ----- Day of week (0 - 7) (Sunday=0 or 7)
| | | ------- Month (1 - 12)
| | --------- Day of month (1 - 31)
| ----------- Hour (0 - 23)
------------- Minute (0 - 59)
```

> [How To Add Jobs To cron Under Linux or UNIX - nixCraft (cyberciti.biz)](https://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/)
> [Crontab.guru - The cron schedule expression editor](https://crontab.guru/)
> [Crontab MAILTO Parameter to Send Notification (linuxhint.com)](https://linuxhint.com/configure_crontab_mailto_parameter/#:~:text=Whenever%20a%20Crontab%20job%20is%20executed%2C%20an%20email,are%20the%20default%20settings%20of%20the%20Crontab%20service.)
> [Crontab Explained in Linux [With Examples] (linuxhandbook.com)](https://linuxhandbook.com/crontab/)
> 