# Moodle Docker image

This is a somewhat opinionated Docker image for running Moodle, currently used by The Pilot Club.
It is based on the official PHP+Apache image and includes the following:

* Moodle and its required PHP extensions
* [auth_enrolkey](https://moodle.org/plugins/auth_enrolkey) plugin
* [availability_coursecompleted](https://moodle.org/plugins/availability_coursecompleted) plugin
* [enrol_apply](https://moodle.org/plugins/enrol_apply) plugin
* [format_flexsections](https://moodle.org/plugins/format_flexsections) plugin
* [mod_booking](https://moodle.org/plugins/mod_booking) plugin
* [mod_coursecertificate](https://moodle.org/plugins/mod_coursecertificate) plugin
* [mod_customcert](https://moodle.org/plugins/mod_customcert) plugin
* [mod_hvp](https://moodle.org/plugins/mod_hvp) plugin
* [mod_pulse](https://moodle.org/plugins/mod_pulse) plugin
* [mod_scheduler](https://moodle.org/plugins/mod_scheduler) plugin
* [theme_moove](https://moodle.org/plugins/theme_moove) theme
* [tool_certificate](https://moodle.org/plugins/tool_certificate) plugin
* [tool_forcedcache](https://moodle.org/plugins/tool_forcedcache) plugin

## Usage

MySQL/MariaDB and Redis are required to run this image.
You'll also need to configure some way of running Moodle's cron job, such as a cron container or a Kubernetes CronJob.

### Environment variables

* `WWW_ROOT` - The URL of the Moodle instance, used for generating links in emails and other places. Defaults to `http://localhost`.
* `SSL_PROXY` - The presence of this environment variable will enable the `sslproxy` setting in Moodle.
* `DB_TYPE` - The type of database to use, currently either `mysqli` or `mariadb`. Defaults to `mysqli`.
* `DB_HOST` - The hostname of the database server. Defaults to `127.0.0.1`.
* `DB_PORT` - The port of the database server. Defaults to `3306`.
* `DB_DATABASE` - The name of the database to use. Defaults to `moodle`.
* `DB_USERNAME` - The username to use when connecting to the database. Defaults to `moodle`.
* `DB_PASSWORD` - The password to use when connecting to the database. Defaults to an empty string.
* `REDIS_HOST` - The hostname of the Redis server. Defaults to `127.0.0.1`.
* `REDIS_PORT` - The port of the Redis server. Defaults to `6379`.
* `REDIS_PASSWORD` - The password to use when connecting to the Redis server. Defaults to an empty string.
* `DATA_ROOT` - The path to the Moodle data directory. Defaults to an empty string.
* `UPGRADE_KEY` - The upgrade key to use when upgrading Moodle. Defaults to null, thus disabling the feature.
