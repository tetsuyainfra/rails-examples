<?php
require_once('plugins/auto-login.php');
return new AdminerAutoLogin (
    array(
        'PostgreSQL' => array(
            'server' => 'postgresql', // db-service name in docker-compose.yaml
            'driver' => 'pgsql', // for MySQL / MariaDb
            'db' => $_ENV["POSTGRES_DB"],
            'username' => $_ENV["POSTGRES_USER"],
            'password' => $_ENV["POSTGRES_PASSWORD"],
				),
        'MySQL' => array(
            'server' => 'mysql', // db-service name in docker-compose.yaml
            'driver' => 'server', // for MySQL / MariaDb
            'db' => $_ENV["MYSQL_DATABASE"],
            'username' => $_ENV["MYSQL_USER"],
            'password' => $_ENV["MYSQL_PASSWORD"],
        )
    )
);