steam-sauna
===========

Because it gets a bunch of friends together and applies Steam

Getting Started
---------------

Get an API key at [http://steamcommunity.com/dev/registerkey](http://steamcommunity.com/dev/registerkey). Then add it:
```
# config/application.yml
STEAM_API_KEY: 'your steam key here'
SECRET_TOKEN: 'probably should do something here too'
```

We use Postgres, to get this working on your development machine, install Postgres ([Postgres.app on a Mac](http://postgresapp.com/)) and configure the db:

```
createdb steam_sauna_dev
createuser steamsauna
bundle install
rake db:migrate
```

Dependencies
---------------

* Memcached: `heroku addons:add memcachier`

Ackowledgements
---------------

Muchos gracias to [davefp](https://github.com/davefp) for the great name
