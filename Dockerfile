FROM composer:2.9 AS vendor

# Set the locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ARG MOODLE_LMS_TAG=v5.1.3

WORKDIR /app

RUN set -ex \
    && curl -O https://raw.githubusercontent.com/moodle/moodle/refs/tags/${MOODLE_LMS_TAG}/composer.json \
    && curl -O https://raw.githubusercontent.com/moodle/moodle/refs/tags/${MOODLE_LMS_TAG}/composer.lock

RUN composer install \
    --no-dev \
    --classmap-authoritative \
    --ignore-platform-reqs

FROM php:8.2-apache-bullseye AS php

ARG MOODLE_LMS_TAG=v5.1.3
ARG MOODLE_AUTH_ENROLKEY_COMMIT=5648363
ARG MOODLE_AVAILABILITY_COURSECOMPLETED_TAG=v5.3.1
ARG MOODLE_ENROL_APPLY_TAG=v.4.1-a
ARG MOODLE_FORMAT_FLEXSECTIONS_TAG=v5.0.1
ARG MOODLE_MOD_COURSECERTIFICATE_TAG=v5.0.4
ARG MOODLE_MOD_CUSTOMCERT_TAG=v5.0.3
ARG MOODLE_MOD_HVP_COMMIT=ad38335
ARG MOODLE_MOD_PULSE_TAG=v2.4-r1
ARG MOODLE_MOD_SCHEDULER_TAG=v4.0.0
ARG MOODLE_THEME_MOOVE_PRIME_COMMIT=3996868
ARG MOODLE_TOOL_CERTIFICATE_TAG=v5.0.6
ARG MOODLE_TOOL_FORCEDCACHE_COMMIT=68d0619
ARG MOODLE_LOCAL_TPC_COMMIT=7a4e3b5

# Install PHP extensionsmysql bin/moodle-docker-compose udown
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
    && mkdir -p /var/www/html/public/auth/enrolkey \
    && curl -L https://github.com/catalyst/moodle-auth_enrolkey/archive/${MOODLE_AUTH_ENROLKEY_COMMIT}.tar.gz | tar -C /var/www/html/public/auth/enrolkey --strip-components=1 -xz \
    && mkdir -p /var/www/html/public/availability/condition/coursecompleted \
    && curl -L https://github.com/ewallah/moodle-availability_coursecompleted/archive/refs/tags/${MOODLE_AVAILABILITY_COURSECOMPLETED_TAG}.tar.gz | tar -C /var/www/html/public/availability/condition/coursecompleted --strip-components=1 -xz \
    && mkdir -p /var/www/html/public/enrol/apply \
    && curl -L https://github.com/emeneo/moodle-enrol_apply/archive/refs/tags/${MOODLE_ENROL_APPLY_TAG}.tar.gz | tar -C /var/www/html/public/enrol/apply --strip-components=1 -xz \
    && mkdir -p /var/www/html/public/course/format/flexsections \
    && curl -L https://github.com/marinaglancy/moodle-format_flexsections/archive/refs/tags/${MOODLE_FORMAT_FLEXSECTIONS_TAG}.tar.gz | tar -C /var/www/html/public/course/format/flexsections --strip-components=1 -xz \
    && mkdir -p /var/www/html/public/mod/coursecertificate \
    && curl -L https://github.com/moodleworkplace/moodle-mod_coursecertificate/archive/refs/tags/${MOODLE_MOD_COURSECERTIFICATE_TAG}.tar.gz | tar -C /var/www/html/public/mod/coursecertificate --strip-components=1 -xz \
    && mkdir -p /var/www/html/public/mod/customcert \
    && curl -L https://github.com/mdjnelson/moodle-mod_customcert/archive/refs/tags/${MOODLE_MOD_CUSTOMCERT_TAG}.tar.gz | tar -C /var/www/html/public/mod/customcert --strip-components=1 -xz \
    && mkdir -p /var/www/html/public/mod/hvp \
    && git clone https://github.com/h5p/moodle-mod_hvp.git /var/www/html/public/mod/hvp \
    && git -C /var/www/html/public/mod/hvp checkout ${MOODLE_MOD_HVP_COMMIT} \
    && git -C /var/www/html/public/mod/hvp submodule update --init \
    && mkdir -p /var/www/html/public/mod/pulse \
    && curl -L https://github.com/bdecentgmbh/moodle-mod_pulse/archive/refs/tags/${MOODLE_MOD_PULSE_TAG}.tar.gz | tar -C /var/www/html/public/mod/pulse --strip-components=1 -xz \
    && mkdir -p /var/www/html/public/mod/scheduler \
    && curl -L https://github.com/bostelm/moodle-mod_scheduler/archive/refs/tags/${MOODLE_MOD_SCHEDULER_TAG}.tar.gz | tar -C /var/www/html/public/mod/scheduler --strip-components=1 -xz \
    && mkdir -p /var/www/html/public/theme/moove \
    && curl -L https://github.com/the-pilot-club/moode_moove-theme/archive/${MOODLE_THEME_MOOVE_PRIME_COMMIT}.tar.gz | tar -C /var/www/html/public/theme/moove --strip-components=1 -xz \
    && mkdir -p /var/www/html/public/admin/tool/certificate \
    && curl -L https://github.com/moodleworkplace/moodle-tool_certificate/archive/refs/tags/${MOODLE_TOOL_CERTIFICATE_TAG}.tar.gz | tar -C /var/www/html/public/admin/tool/certificate --strip-components=1 -xz \
    && mkdir -p /var/www/html/public/admin/tool/forcedcache \
    && curl -L https://github.com/catalyst/moodle-tool_forcedcache/archive/${MOODLE_TOOL_FORCEDCACHE_COMMIT}.tar.gz | tar -C /var/www/html/public/admin/tool/forcedcache --strip-components=1 -xz \
    && mkdir -p /var/www/html/public/local/tpc \
    && curl -L https://github.com/the-pilot-club/moodle-tpc-local/archive/${MOODLE_LOCAL_TPC_COMMIT}.tar.gz | tar -C /var/www/html/public/local/tpc --strip-components=1 -xz \
    && chown -R www-data:www-data /var/www/html



# Configure PHP/Apache
COPY php.ini /usr/local/etc/php/php.ini
COPY moodle.conf /etc/apache2/sites-available/moodle.conf
RUN set -ex \
    && a2disconf docker-php other-vhosts-access-log serve-cgi-bin \
    && a2dissite 000-default \
    && a2enmod rewrite \
    && a2ensite moodle

# Configure Moodle
WORKDIR /var/www/html/
COPY config.php /var/www/html/public/config.php
COPY config.php /var/www/html/config.php
COPY --from=vendor /app/vendor /var/www/html/vendor


# CMD and ENTRYPOINT are inherited from the Apache image
