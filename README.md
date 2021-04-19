# Fanficker

Story downloader I'm working on for fun.

Should work with any recent version XenForo forums (i.e. SpaceBattles, Sufficient Velocity).

## Using the app

Open up http://localhost:3000

Submit thread URL from a compatible message board on the main page.

Currently only works with base URL.  I.e. https://forums.spacebattles.com/threads/maplebird-test.1234 will work,
but https://forums.spacebattles.com/threads/maplebird-test.1234/page-30#post-75438880 will NOT work.

## Requirements

Standard rails app.

Requires:
* Ruby 2.6.6
* Node
* Postgresql

Database default creds:
* User: `fanficker`
* Password: `fanficker`
* Database: `fanficker`

For development mode, requires permissions to create and modify a new database.

## Installation

```shell
bundle install
yarn install || npm install
bundle exec rails db:setup
```

## Run the server

```shell
rails s
```

App will be available at http://localhost:3000