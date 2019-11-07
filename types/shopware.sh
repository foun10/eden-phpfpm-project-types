#!/usr/bin/env bash
mysql -h ${DB_HOST} -u ${DB_USER} -p${DB_PASS} ${DB_NAME} -e "UPDATE s_core_shops SET base_path=NULL, base_url=NULL,hosts='${PROJECT_URL}',host='${PROJECT_URL}', secure=0, always_secure=0 WHERE s_core_shops.default=1;"
mysql -h ${DB_HOST} -u ${DB_USER} -p${DB_PASS} ${DB_NAME} -e "INSERT s_core_auth (roleID, localeID, username, name, email, encoder, password, failedlogins, active, lockeduntil) VALUES (1, 1, '${USER_MAIL}', 'admin', '${USER_MAIL}', 'md5', MD5('${USER_PASS}'), 0, 1, '0001-01-01 00:00:00');"

echo "create config.php"
cat <<EOF > config.php
<?php return array(
    'db' =>
        array(
            'username' => '${DB_USER}',
            'password' => '${DB_PASS}',
            'host' => '${DB_HOST}',
            'port' => '3306',
            'dbname' => '${DB_NAME}',
        ),
    'front' => array(
        'noErrorHandler' => true,
        'throwExceptions' => true,
        'useDefaultControllerAlways' => true,
        'disableOutputBuffering' => true,
        'showException' => true,
    ),
    'template' => array(
        'forceCompile' => true,
    )
);
EOF

if [[ -f "${HTDOCS_DIR}/cache/clear_cache.sh" ]]; then
    echo "clearing caches!"
    chmod 777 "${HTDOCS_DIR}/cache/clear_cache.sh"
    "${HTDOCS_DIR}/cache/clear_cache.sh"
    chmod -R 777 "${HTDOCS_DIR}/cache"
elif [[ -f "${HTDOCS_DIR}/var/cache/clear_cache.sh" ]]; then
    echo "clearing caches!"
    chmod 777 ${HTDOCS_DIR}/var/cache/clear_cache.sh
    "${HTDOCS_DIR}/var/cache/clear_cache.sh"
    chmod -R 777 "${HTDOCS_DIR}/var"
fi

if [[ ! -f "${HTDOCS_DIR}/index.php" ]]; then
    echo "create index.php"
    cat <<EOF > index.php
<?php
include 'shopware.php';
EOF
fi

echo "Add media dirs"
rm -rf ${HTDOCS_DIR}/media
mkdir -p ${HTDOCS_DIR}/media
mkdir -p ${HTDOCS_DIR}/media/archive
mkdir -p ${HTDOCS_DIR}/media/image
mkdir -p ${HTDOCS_DIR}/media/image/thumbnail
mkdir -p ${HTDOCS_DIR}/media/music
mkdir -p ${HTDOCS_DIR}/media/pdf
mkdir -p ${HTDOCS_DIR}/media/temp
mkdir -p ${HTDOCS_DIR}/media/unkown
mkdir -p ${HTDOCS_DIR}/media/video