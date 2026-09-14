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

### Memory tuning

Apache runs PHP in-process (prefork + mod_php), so every Apache worker is a full PHP process and the worker count is what
drives the container's memory use. These variables are read when Apache starts, so they can be changed per deployment
without rebuilding the image:

* `APACHE_MAX_REQUEST_WORKERS` - Maximum simultaneous requests (worker processes). Defaults to `20`. Size it as roughly
  `(container memory - 300MB) / 60MB`, e.g. `12` for 1GB, `28` for 2GB.
* `APACHE_START_SERVERS` - Workers started at boot. Defaults to `2`.
* `APACHE_MIN_SPARE_SERVERS` / `APACHE_MAX_SPARE_SERVERS` - Idle workers kept around; extras above the maximum are
  shut down so memory is released after traffic spikes. Default to `2` / `5`.
* `APACHE_MAX_CONNECTIONS_PER_CHILD` - Connections a worker serves before it is recycled, returning any memory it has
  accumulated. Defaults to `1000`.
