FROM php:8.2-apache-bullseye

ARG MOODLE_LMS_TAG=v4.4.1
ARG MOODLE_AUTH_ENROLKEY_COMMIT=5648363
ARG MOODLE_AVAILABILITY_COURSECOMPLETED_TAG=v4.4.1
ARG MOODLE_ENROL_APPLY_TAG=v.4.1-a
ARG MOODLE_FORMAT_FLEXSECTIONS_TAG=v4.0.4
ARG MOODLE_MOD_BOOKING_TAG=v8.6.3
ARG MOODLE_MOD_COURSECERTIFICATE_TAG=v4.2
ARG MOODLE_MOD_CUSTOMCERT_TAG=v4.4.1
ARG MOODLE_MOD_HVP_COMMIT=b1105da
ARG MOODLE_MOD_PULSE_TAG=v1.3
ARG MOODLE_MOD_SCHEDULER_TAG=v4.0.0
ARG MOODLE_THEME_MOOVE_COMMIT=571b74a
ARG MOODLE_TOOL_CERTIFICATE_TAG=v4.4.1
ARG MOODLE_TOOL_FORCEDCACHE_COMMIT=049b0e4
ARG MOODLE_LOCAL_BOOKING_COMMIT=790315c
ARG WUNDERBYTE_TABLE_TAG=v2.0.10

# Install PHP extensions
RUN set -ex \
    && apt-get update \
    && apt-get install --no-install-recommends -y git libfreetype6 libfreetype6-dev libjpeg62-turbo libjpeg62-turbo-dev libpng16-16 libpng-dev libwebp6 libwebp-dev libxml2-dev libxslt1.1 libxslt-dev libzip-dev unzip uuid-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-configure zip --with-zip \
    && docker-php-ext-install -j$(nproc) exif gd intl mysqli opcache soap xsl zip \
    && pecl install apcu-5.1.22 redis-5.3.7 timezonedb-2023.3 uuid-1.2.0 \
    && docker-php-ext-enable apcu redis timezonedb uuid \
    && apt-get purge -y --auto-remove libfreetype6-dev libjpeg62-turbo-dev libpng-dev libwebp-dev libxml2-dev libxslt-dev uuid-dev \
    && rm -rf /tmp/pear /var/lib/apt/lists/*

# Install Moodle
RUN set -ex \
    && curl -L https://github.com/moodle/moodle/archive/refs/tags/${MOODLE_LMS_TAG}.tar.gz | tar -C /var/www/html --strip-components=1 -xz \
    && mkdir -p /var/www/html/local/booking \
    && curl -L https://github.com/the-pilot-club/session-booking/archive/${MOODLE_LOCAL_BOOKING_COMMIT}.tar.gz | tar -C /var/www/html/local/booking --strip-components=1 -xz \
    && mkdir -p /var/www/html/auth/enrolkey \
    && curl -L https://github.com/catalyst/moodle-auth_enrolkey/archive/${MOODLE_AUTH_ENROLKEY_COMMIT}.tar.gz | tar -C /var/www/html/auth/enrolkey --strip-components=1 -xz \
    && mkdir -p /var/www/html/availability/condition/coursecompleted \
    && curl -L https://github.com/ewallah/moodle-availability_coursecompleted/archive/refs/tags/${MOODLE_AVAILABILITY_COURSECOMPLETED_TAG}.tar.gz | tar -C /var/www/html/availability/condition/coursecompleted --strip-components=1 -xz \
    && mkdir -p /var/www/html/enrol/apply \
    && curl -L https://github.com/emeneo/moodle-enrol_apply/archive/refs/tags/${MOODLE_ENROL_APPLY_TAG}.tar.gz | tar -C /var/www/html/enrol/apply --strip-components=1 -xz \
    && mkdir -p /var/www/html/course/format/flexsections \
    && curl -L https://github.com/marinaglancy/moodle-format_flexsections/archive/refs/tags/${MOODLE_FORMAT_FLEXSECTIONS_TAG}.tar.gz | tar -C /var/www/html/course/format/flexsections --strip-components=1 -xz \
    && mkdir -p /var/www/html/mod/booking \
    && curl -L https://github.com/Wunderbyte-GmbH/moodle-mod_booking/archive/refs/tags/${MOODLE_MOD_BOOKING_TAG}.tar.gz | tar -C /var/www/html/mod/booking --strip-components=1 -xz \
    && mkdir -p /var/www/html/local/wunderbyte_table \
    && curl -L https://github.com/Wunderbyte-GmbH/moodle-local_wunderbyte_table/archive/${WUNDERBYTE_TABLE_TAG}.tar.gz | tar -C /var/www/html/local/wunderbyte_table --strip-components=1 -xz \
    && mkdir -p /var/www/html/mod/coursecertificate \
    && curl -L https://github.com/moodleworkplace/moodle-mod_coursecertificate/archive/refs/tags/${MOODLE_MOD_COURSECERTIFICATE_TAG}.tar.gz | tar -C /var/www/html/mod/coursecertificate --strip-components=1 -xz \
    && mkdir -p /var/www/html/mod/customcert \
    && curl -L https://github.com/mdjnelson/moodle-mod_customcert/archive/refs/tags/${MOODLE_MOD_CUSTOMCERT_TAG}.tar.gz | tar -C /var/www/html/mod/customcert --strip-components=1 -xz \
    && mkdir -p /var/www/html/mod/hvp \
    && git clone https://github.com/h5p/moodle-mod_hvp.git /var/www/html/mod/hvp \
    && git -C /var/www/html/mod/hvp checkout ${MOODLE_MOD_HVP_COMMIT} \
    && git -C /var/www/html/mod/hvp submodule update --init \
    && mkdir -p /var/www/html/mod/pulse \
    && curl -L https://github.com/bdecentgmbh/moodle-mod_pulse/archive/refs/tags/${MOODLE_MOD_PULSE_TAG}.tar.gz | tar -C /var/www/html/mod/pulse --strip-components=1 -xz \
    && mkdir -p /var/www/html/mod/scheduler \
    && curl -L https://github.com/bostelm/moodle-mod_scheduler/archive/refs/tags/${MOODLE_MOD_SCHEDULER_TAG}.tar.gz | tar -C /var/www/html/mod/scheduler --strip-components=1 -xz \
    && mkdir -p /var/www/html/theme/moove \
    && curl -L https://github.com/willianmano/moodle-theme_moove/archive/${MOODLE_THEME_MOOVE_COMMIT}.tar.gz | tar -C /var/www/html/theme/moove --strip-components=1 -xz \
    && mkdir -p /var/www/html/admin/tool/certificate \
    && curl -L https://github.com/moodleworkplace/moodle-tool_certificate/archive/refs/tags/${MOODLE_TOOL_CERTIFICATE_TAG}.tar.gz | tar -C /var/www/html/admin/tool/certificate --strip-components=1 -xz \
    && mkdir -p /var/www/html/admin/tool/forcedcache \
    && curl -L https://github.com/catalyst/moodle-tool_forcedcache/archive/${MOODLE_TOOL_FORCEDCACHE_COMMIT}.tar.gz | tar -C /var/www/html/admin/tool/forcedcache --strip-components=1 -xz \
    && chown -R www-data:www-data /var/www/html

# Apply page_compression.patch (MDL-69196)
COPY page_compression.patch /tmp/page_compression.patch
RUN set -ex \
    && cd /var/www/html \
    && patch -p1 < /tmp/page_compression.patch \
    && rm /tmp/page_compression.patch

# Configure PHP/Apache
COPY php.ini /usr/local/etc/php/php.ini
COPY moodle.conf /etc/apache2/sites-available/moodle.conf
RUN set -ex \
    && a2disconf docker-php other-vhosts-access-log serve-cgi-bin \
    && a2dissite 000-default \
    && a2enmod rewrite \
    && a2ensite moodle

# Configure Moodle
WORKDIR /var/www/html
COPY config.php /var/www/html/config.php
RUN set -ex \
    && php admin/cli/alternative_component_cache.php --rebuild

# CMD and ENTRYPOINT are inherited from the Apache image
