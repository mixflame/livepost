# livepost

LivePost is a browser-based communication system that allows truely live forum-style communication with images.

Also, it is anonymous and encrypted with SSL.

[LivePost](https://livepost.mixflame.com)

Support LivePost Development: 1J71oJ9g6Z4L7kDzaSYjaXKA1z1QLWWWAj

Gather with the LivePost developers: irc.rizon.net #livepost

## Installation

Get Crystal [Crystal](https://crystal-lang.org)

* Install dependencies: ```apt-get install libmongoc-dev mongodb libbson-dev crystal build-essentials```

* Run MongoDB: ```mongod```

* Compile and install amber_cmd [amber_cmd](https://github.com/amber-crystal/amber_cmd)

* Install shards ```shards install```

* Set admin password ```export LIVEPOST_PASSWORD="something1212"```

* Run in development mode and reload on changes (watch): ```amber w```

* Run certbot on your domain ```certbot certonly``` and choose standalone mode

* Move fullchain.pem and privkey.pem to config/ after getting them from certbot (required)

* Run in production mode and daemonize: ```AMBER_ENV="production" ./livepost```

## Contributing

1. Fork and send your changes in a pull request. Branches are fine.

## Contributors

- [mixflame](https://github.com/mixflame) Jonathan Silverman - creator
