# README

1. install *imagemagick* and *postgresql dev*

```bash
sudo apt-get update
sudo apt-get install imagemagick postgresql-server-dev-<version> libpq-dev
```

2. this app use 'whenever gem' to scheduled task overnight. run

```bash
bundle exec whenever
```
copy and paste the output on 'crontab'. make sure the crontab user has privileges over app files.