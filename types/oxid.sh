#!/usr/bin/env bash

if [[ ! -f "cust_config.inc.php" ]]; then
echo "create cust_config.inc.php"
cat <<EOF > ${htdocs_dir}/config.local.inc.php
<?php
\$this->dbHost = '${db_host}'; // database host name
\$this->dbName = '${db_name}'; // database name
\$this->dbUser = '${db_user}'; // database user name
\$this->dbPwd = '${db_pass}'; // database user password
\$this->sShopURL = 'http://${project_url}'; // eShop base url, required
\$this->sSSLShopURL = 'https://${project_url}'; // eShop SSL url, optional
\$this->sAdminSSLURL = 'https://${project_url}/admin'; // eShop Admin SSL url, optional
\$this->sShopDir = '${htdocs_dir}';
\$this->sCompileDir = '${htdocs_dir}/tmp';
EOF
fi

if [[ ${user_mail} != '' ]] && [[ ${user_pass} != '' ]]; then
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
        '${user_mail}',
        MD5('${user_pass}'),
        ''
    ) ON DUPLICATE KEY UPDATE
        OXUSERNAME='${user_mail}',
        OXPASSWORD=MD5('${user_pass}'),
        OXPASSSALT=''
    "
    mysql -h${db_host} -u${db_user} -p${db_pass} ${db_name} -e "${create_user_sql}"
fi