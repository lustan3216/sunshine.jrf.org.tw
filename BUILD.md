Build Project
===============

Making sure you have already start PostgreSql & Redis

```
bundle install
```

```
cp config/database.yml.example config/database.yml
cp config/application.yml.example config/application.yml
```

Setup database.yml & start postgresql.

```
bundle exec rake dev:build
```

Redis
================

- install

```
brew install redis
```

- start redis ( ctrl + c to stop)

```
redis-server
```

PostgreSql
=================

- install

```
brew install postgresql
brew install postgis
brew unlink postgresql
brew link postgresql
ARCHFLAGS="-arch x86_64" gem install pg
```

- goto http://postgresapp.com/ download and start it.

- setup user & password

```
psql
```

- replace your_name & your_password

```
CREATE USER your_name WITH PASSWORD 'your_password';
CREATE DATABASE "your_name";
GRANT ALL PRIVILEGES ON DATABASE "your_name" to "your_name";
ALTER USER "your_name" WITH SUPERUSER;
```

Qt(qmake) (use by webkit)
=================

- find your os here https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit

