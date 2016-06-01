Trogdir API [![Build Status](https://travis-ci.org/biola/trogdir-api.png)](https://travis-ci.org/biola/trogdir-api)
===========
RESTful APIs for the Trogdir directory project.

Requirements
------------
- [Ruby](https://www.ruby-lang.org)
- [MongoDB](https://www.mongodb.org)
- [Rack web server](http://rack.github.io)

Installation
------------
```bash
git clone git@github.com:biola/trogdir-api.git
cd trogdir-api
bundle install
cp config/mongoid.yml.example config/mongoid.yml
cp config/newrelic.yml.example config/newrelic.yml
```

Configuration
-------------
- Edit `config/mongoid.yml` accordingly.
- Edit `config/newrelic.yml` accordingly.

Console
-------
To launch a console, `cd` into the app directory and run `irb -r ./config/environment.rb`

GUI Frontend
------------
See [three-keepers](https://github.com/biola/three-keepers) for a frontend GUI to the trogdir-api data.

Consuming the API
-----------------
See [trogdir-api-client](https://github.com/biola/trogdir-api-client) for details on consuming the API.

Client (Syncinator) Setup
------------
There is currently no GUI for creating syncinators. To create a new client, lanunch the console and run the following command.
```ruby
Syncinator.create name: 'my-app', queue_changes: false
```
This will automatically generate an `access_id` and `secret_key` that you will need to provide to `trogdir-api-client` in your application so that it can authhenticate with `trogdir-api`

_Note: for details on whether or not you want to set `queue_changes`, see **Change Tracking and Syncing** below._
Change Tracking and Syncing
---------------------------
__TODO__
