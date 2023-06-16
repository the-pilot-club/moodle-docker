# Moodle Docker image

This is a somewhat opinionated Docker image for running Moodle, currently used by VATSIM.
It is based on the official PHP+Apache image and includes the following:

* Moodle and its required PHP extensions
* [atto_morefontcolors](https://moodle.org/plugins/atto_morefontcolors) plugin
* [mod_customcert](https://moodle.org/plugins/mod_customcert) plugin
* [tool_forcedcache](https://moodle.org/plugins/tool_forcedcache) plugin

## Usage

MySQL/MariaDB and Redis are required to run this image.
You'll also need to configure some way of running Moodle's cron job, such as a cron container or a Kubernetes CronJob.

### Environment variables

* `WWW_ROOT` - The URL of the Moodle instance, used for generating links in emails and other places. Defaults to `http://localhost`.
* `DB_HOST` - The hostname of the database server. Defaults to `127.0.0.1`.
* `DB_PORT` - The port of the database server. Defaults to `3306`.
* `DB_DATABASE` - The name of the database to use. Defaults to `moodle`.
* `DB_USERNAME` - The username to use when connecting to the database. Defaults to `moodle`.
* `DB_PASSWORD` - The password to use when connecting to the database. Defaults to an empty string.
* `REDIS_HOST` - The hostname of the Redis server. Defaults to `127.0.0.1`.
* `REDIS_PORT` - The port of the Redis server. Defaults to `6379`.
* `REDIS_PASSWORD` - The password to use when connecting to the Redis server. Defaults to an empty string.
* `DATA_ROOT` - The path to the Moodle data directory. Defaults to `/var/www/moodledata`.
* `UPGRADE_KEY` - The upgrade key to use when upgrading Moodle. Defaults to null, thus disabling the feature.
* `SITE_ADMINS` - The IDs of the users to make site administrators, separated by commas. Defaults to null.
