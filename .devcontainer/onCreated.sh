#! /bin/sh
echo -e "\e[1;41m Es necesario iniciar sesión \e[0m"
gh auth login
gh auth setup-git

if [ ! -d /workspace/MinInteriorFRONT ]; then
    (gh repo clone Col50/MinInteriorFRONT /workspace/MinInteriorFRONT) &
fi

if [ ! -d /workspace/MinInteriorBACK ]; then
    export TOKEN_SECRET=$(node -e "console.log(require('crypto').randomBytes(64).toString('hex'))")
    (gh repo clone Col50/MinInteriorBACK /workspace/MinInteriorBACK &&
        cd /workspace/MinInteriorBACK &&
        cp .env.example .env &&
        sed -i s/TOKEN_SECRET=/TOKEN_SECRET=$TOKEN_SECRET/g .env) &
fi

# if [ ! -d /workspace/ATVTemplate ]; then
#     (gh repo clone DamapiCorp/ATVTemplate /workspace/ATVTemplate && cd /workspace/ATVTemplate && cp .env.example .env) &
# fi

wait
echo -e "\e[1;42m Proyectos descargados correctamente \e[0m"

if [ -z "$(ls -A /var/lib/mysql)" ]; then
    echo ""
    echo -e "\e[1;42m Inicializando base de datos \e[0m"

    sed -i 's/#bind/bind/g' /etc/my.cnf.d/mariadb-server.cnf
    sed -i 's/skip-networking/#skip-networking/g' /etc/my.cnf.d/mariadb-server.cnf

    mariadb-install-db --user=root --datadir=/var/lib/mysql/ && mariadbd-safe --user=root &

    sleep 15

    mariadb -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$MYSQL_ROOT_PASSWORD');" &&
        mariadb -u root -p"$MYSQL_ROOT_PASSWORD" -e "DROP USER ''@localhost;" &&
        mariadb -u root -p"$MYSQL_ROOT_PASSWORD" -e "DROP DATABASE IF EXISTS test;" &&
        mariadb -u root -p"$MYSQL_ROOT_PASSWORD" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';" &&
        mariadb -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;" &&
        mariadb -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" &&
        mariadb -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%';" &&
        mariadb -u root -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;" &&
        echo "Importando tablas y datos de prueba desde devenv.sql"

    echo -e "\e[1;42m Base de datos inicializada \e[0m"
fi

if [ ! -d /run/mysqld ]; then
    echo ""
    echo -e "\e[1;42m Parece que ya existe una base de datos inicializada. Realizando últimos ajustes \e[0m"

    sed -i 's/#bind/bind/g' /etc/my.cnf.d/mariadb-server.cnf
    sed -i 's/skip-networking/#skip-networking/g' /etc/my.cnf.d/mariadb-server.cnf

    chown -R root:root /var/lib/mysql
    mkdir -p /run/mysqld

    echo -e "\e[1;42m Ajustes realizados \e[0m"
fi

sleep 5
