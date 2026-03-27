<?php

/*
 * Moodle configuration file
 */

unset($CFG);
global $CFG;
$CFG = new stdClass();

/*
 * Database configuration
 */

$CFG->dbtype = getenv('DB_TYPE') ?: 'mysqli';
$CFG->dblibrary = 'native';
$CFG->dbhost = getenv('DB_HOST') ?: '127.0.0.1';
$CFG->dbname = getenv('DB_DATABASE') ?: 'moodle';
$CFG->dbuser = getenv('DB_USERNAME') ?: 'moodle';
$CFG->dbpass = getenv('DB_PASSWORD') ?: '';
$CFG->prefix = 'mdl_';
$CFG->dboptions = [
    'dbpersist' => 0,
    'dbport' => intval(getenv('DB_PORT') ?: 3306),
    'dbsocket' => getenv('DB_SOCKET') ?: '',
    'dbcollation' => 'utf8mb4_unicode_ci',
];

/*
 * Redis cache / session store configuration
 */

$redisHost = getenv('REDIS_HOST') ?: '127.0.0.1';
$redisPort = intval(getenv('REDIS_PORT') ?: 6379);
$redisPassword = getenv('REDIS_PASSWORD') ?: '';
$redisDatabase = intval(getenv('REDIS_DATABASE') ?: 0);

$CFG->alternative_cache_factory_class = 'tool_forcedcache_cache_factory';
$CFG->tool_forcedcache_config_array = [
    'stores' => [
        'apcu' => [
            'type' => 'apcu',
            'config' => [
                'prefix' => 'apcu_',
            ],
        ],
        'redis' => [
            'type' => 'redis',
            'config' => [
                'server' => sprintf('%s:%s', $redisHost, $redisPort),
                'password' => $redisPassword,
                'prefix' => 'mdl_cache_',
                'serializer' => 1, // \Redis::SERIALIZER_PHP
                'compressor' => 0, // \cachestore_redis::COMPRESSOR_NONE
            ],
        ],
        'local_file' => [
            'type' => 'file',
            'config' => [
                'path' => '/tmp/local-cache-file',
                'autocreate' => 1,
            ],
        ],
    ],
    'rules' => [
        'application' => [
            // These get queried on almost every page
            // and don't need to be shared between instances,
            // so let's stick them on APCu for speeeeeeeed
            [
                'conditions' => [
                    'name' => 'core/plugin_functions',
                ],
                'stores' => ['APCu', 'redis'],
            ],
            [
                'conditions' => [
                    'name' => 'core/string',
                ],
                'stores' => ['APCu', 'redis'],
            ],
            [
                'conditions' => [
                    'name' => 'core/langmenu',
                ],
                'stores' => ['APCu', 'redis'],
            ],
            // This is another special case similar to coursemodinfo below,
            // this cache has a very large number items so we would put it
            // into local and shared files, but don't due to MDL-69088.
            // In practice this doesn't matter as rebuilding these items is
            // relatively quick, unlike coursemodinfo which is very costly.
            [
                'conditions' => [
                    'name' => 'core/htmlpurifier',
                ],
                'stores' => ['local_file'],
            ],
            // Course mod info is a special case because it is so large so we
            // use files instead of redis for the shared stacked cache.
            [
                'conditions' => [
                    'name' => 'core/coursemodinfo',
                ],
                'stores' => ['local_file', 'shared_file'],
            ],
            // Everything else which is localizable we have in both a local
            // cache backed by a shared case to warm up the local caches faster
            // while auto scaling in new front ends.
            [
                'conditions' => [
                    'canuselocalstore' => true,
                ],
                'stores' => ['local_file', 'redis'],
            ],
            // Anything left over which cannot be localized just goes into shared
            // redis as is.
            [
                'stores' => ['redis'],
            ]
        ],
        'session' => [
            ['stores' => ['redis']],
        ],
        'request' => [],
    ],
    'definitionoverrides' => [
        'core/plugin_functions' => [
            'canuselocalstore' => true,
        ],
    ],
];

$CFG->session_handler_class = '\core\session\redis';
$CFG->session_redis_host = $redisHost;
$CFG->session_redis_port = $redisPort;
$CFG->session_redis_database = $redisDatabase;
$CFG->session_redis_auth = $redisPassword;
$CFG->session_redis_prefix = 'mdl_session_';

/*
 * URL and filesystem configuration
 */

$CFG->wwwroot = getenv('WWW_ROOT') ?: 'http://localhost';
$CFG->sslproxy = getenv('SSL_PROXY') !== false;

$CFG->dataroot = getenv('DATA_ROOT') ?: '';
$CFG->directorypermissions = 0777;

/*
 * Administration configuration
 */

$CFG->alternative_component_cache = __DIR__ . '/core_component.php';
$CFG->upgradekey = getenv('UPGRADE_KEY') ?: null;
$CFG->disableupdateautodeploy = true;
$CFG->preventexecpath = true;
$CFG->routerconfigured = true;

/*
 * Pass it off to Moodle core
 */

require_once __DIR__ . '/lib/setup.php';
