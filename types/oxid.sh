#!/usr/bin/env bash
set -euo pipefail

ACTION=${1}

wait_for_db() {
  while ! mysqladmin ping -h"${1}" --silent; do
    echo "Waiting for mysql service."
    sleep 5
  done
}

case $ACTION in
  CREATE_CONFIG)
    DIR=${2}
    DB_HOST=${3}
    DB_NAME=${4}
    DB_USER=${5}
    DB_PASS=${6}
    PROJECT_URL=${7}

    if [[ ! -f "${DIR}/config.local.inc.php" ]]; then
      echo "create config.local.inc.php"
      cat <<EOF > "${DIR}/config.local.inc.php"
<?php
\$this->dbHost = '${DB_HOST}'; // database host name
\$this->dbName = '${DB_NAME}'; // database name
\$this->dbUser = '${DB_USER}'; // database user name
\$this->dbPwd = '${DB_PASS}'; // database user password
\$this->sShopURL = 'https://${PROJECT_URL}'; // eShop base url, required
\$this->sSSLShopURL = 'https://${PROJECT_URL}'; // eShop SSL url, optional
\$this->sAdminSSLURL = 'https://${PROJECT_URL}/admin'; // eShop Admin SSL url, optional
\$this->sShopDir = '${DIR}';
\$this->sCompileDir = '${DIR}/tmp';
EOF
    fi
    ;;
  CREATE_USER)
    DB_HOST=${2}
    DB_NAME=${3}
    DB_USER=${4}
    DB_PASS=${5}
    USER_MAIL=${5}
    USER_PASS=${5}

    wait_for_db "${DB_HOST}"

    echo "Create user ${USER_MAIL}."

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

    echo "User ${USER_MAIL} created."
    ;;
  CREATE_DEFAULT_DIRECTORIES)
    DIR=${2}
    # Create log DIR
    LOG_DIR="${DIR}/log"

    if [[ ! -d ${LOG_DIR} ]]; then
      mkdir "${LOG_DIR}"
    fi

    # Create export DIR
    EXPORT_DIR="${DIR}/export"

    if [[ ! -d ${EXPORT_DIR} ]]; then
      mkdir "${EXPORT_DIR}"
    fi

    # Flush temp DIR
    rm -rf "${DIR}/tmp/*"

    if [[ ! -d ${DIR}/tmp ]]; then
      mkdir "${DIR}/tmp"
    fi

    echo "Default directories created."
    ;;
  FLUSH_MODULES_DB)
    DB_HOST=${2}
    DB_NAME=${3}
    DB_USER=${4}
    DB_PASS=${5}

    echo "Flush aModules database entry."
    wait_for_db "${DB_HOST}"
    mysql -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" -e "UPDATE oxconfig SET OXVARNAME = 'aModules_old' WHERE OXVARNAME = 'aModules';"
    echo "Entries flushed."
    ;;
esac