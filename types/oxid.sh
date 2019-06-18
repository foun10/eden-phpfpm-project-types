#!/usr/bin/env bash

if [[ ! -f "${HTDOCS_DIR}/config.local.inc.php" ]]; then
echo "create config.local.inc.php"
cat <<EOF > ${HTDOCS_DIR}/config.local.inc.php
<?php
\$this->dbHost = '${DB_HOST}'; // database host name
\$this->dbName = '${DB_NAME}'; // database name
\$this->dbUser = '${DB_USER}'; // database user name
\$this->dbPwd = '${DB_PASS}'; // database user password
\$this->sShopURL = 'http://${PROJECT_URL}'; // eShop base url, required
\$this->sSSLShopURL = 'https://${PROJECT_URL}'; // eShop SSL url, optional
\$this->sAdminSSLURL = 'https://${PROJECT_URL}/admin'; // eShop Admin SSL url, optional
\$this->sShopDir = '${HTDOCS_DIR}';
\$this->sCompileDir = '${HTDOCS_DIR}/tmp';
EOF
fi

if [[ ${USER_MAIL} != '' ]] && [[ ${USER_PASS} != '' ]]; then
    create_user_sql="
    INSERT INTO oxuser (
        OXID,
        OXACTIVE,
        OXRIGHTS,
        OXSHOPID,
        OXUSERNAME,
        OXPASSWORD,
        OXPASSSALT
    ) VALUES (
        'devadmin',
        1,
        'malladmin',
        1,
        '${USER_MAIL}',
        MD5('${USER_PASS}'),
        ''
    ) ON DUPLICATE KEY UPDATE
        OXUSERNAME='${USER_MAIL}',
        OXPASSWORD=MD5('${USER_PASS}'),
        OXPASSSALT=''
    "
    mysql -h${DB_HOST} -u${DB_USER} -p${DB_PASS} ${DB_NAME} -e "${create_user_sql}"
fi