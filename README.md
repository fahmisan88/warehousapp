# README

Current version of RoR is 5.0.1

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


upgrade ruby version to 2.4.1, then
```bash
gem install rake -v 12.1.0
gem install minitest -v 5.10.3
gem install activesupport -v 5.0.6
gem install mini_portile2 -v 2.3.0
gem install nokogiri -v 1.8.1
gem install crass -v 1.0.2
```