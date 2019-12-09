# GithubBackup

[toc]

## 1. Introduction

I have used `josegonzalez`'s script to create an script for backing up whole Github account and its related (forked, starred) repositories.

**Features:**

- Backup private, forked and starred repositories.
- Abort if using metered connection

**References:**

- https://github.com/josegonzalez/python-github-backup
- https://stackoverflow.com/questions/43228973/detect-if-current-connection-is-metered-with-networkmanager

## 2. Installation

- Install required packages:

```bash
$ sudo apt install python-pip git nmcli
$ sudo -H pip install github-backup
```

- Edit `ACCESS_TOKEN` and `USERNAME` located in the script.

```bash
$ gedit github_backup.sh
```

- Copy the script to the root:

```bash
$ sudo cp github_backup.sh /etc/github_backup.sh
$ sudo chmod 500 /etc/github_backup.sh
```

- Set automatic backup (cron):

```bash
$ sudo crontab -e
```

- Then paste the following line:

```
00 20 * * * /bin/bash /etc/github_backup.sh # everyday at 20:00
```

## FAQ

- How to convert bare repository to a normal repository?

  - ```bash
    $ cd /path/to/repository
    $ mkdir .git
    $ mv *!(.git) .git/
    $ git config --local --bool core.bare false
    $ git reset --hard
    ```

