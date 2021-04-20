# Fanficker

Story downloader I'm working on for fun.

Should work with any recent version XenForo forums (i.e. SpaceBattles, Sufficient Velocity).

## Using the app

Open up http://localhost:3000

Submit thread URL from a compatible message board on the main page.

Currently only works with base URL.  I.e. https://forums.spacebattles.com/threads/maplebird-test.1234 will work,
but https://forums.spacebattles.com/threads/maplebird-test.1234/page-30#post-75438880 will NOT work.

If you want to refresh a previously downloaded story, submit its thread URL again on the main page.

## Requirements

Standard rails app.

Requires:
* Ruby 2.6.6
* Postgresql

Database default creds:
* User: `fanficker`
* Password: `fanficker`
* Database: `fanficker`

For development mode, requires permissions to create and modify a new database.

## Installation

```shell
bundle install
bundle exec rails db:setup
```

## Run the server

```shell
rails server -b 0.0.0.0
```

App will be available at http://localhost:3000

## Running in production mode

Set `RAILS_ENV=production` first.

Set the following environment variables if they're different from defaults.

```shell
DATABASE_USER=
DATABASE_PASSWORD=
DATABASE_NAME=
DATABASE_HOST=
DATABASE_PORT=
```

Fanficker also uses AWS S3 as the backend for ActiveStorage.  Set the following environment variables as well:

```shell
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_S3_BUCKET=
AWS_REGION=
```

Create the database, run migrations, then start the server:

```shell
# Create the database (if doesn't exist)
bundle exec rails db:create

# Run migrations and start
bundle exec rails db:migrate
bundle exec rails server -b 0.0.0.0
```