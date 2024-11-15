#!/bin/bash

# Variables de conexión para la base de datos de origen
DB_HOST_ORIG="mariadb_host_origen"
DB_USER_ORIG="usuario_origen"
DB_PASS_ORIG="contraseña_origen"
DB_NAME_ORIG="nombre_base_datos_origen"  # Base de datos de origen (de donde se realiza el dump)

# Variables de conexión para la base de datos de destino
DB_HOST_DEST="mariadb_host_destino"
DB_USER_DEST="usuario_destino"
DB_PASS_DEST="contraseña_destino"
DB_NAME_DEST="nombre_base_datos_destino"  # Base de datos de destino (donde se va a restaurar)

BACKUP_DIR="/backups"
DATE=$(date +\%Y-\%m-\%d_\%H-\%M-\%S)

# Crear directorio de backups si no existe
mkdir -p $BACKUP_DIR

# Realizar el dump de la base de datos de origen
echo "Realizando dump de la base de datos $DB_NAME_ORIG en el host $DB_HOST_ORIG..."
mysqldump -h $DB_HOST_ORIG -u $DB_USER_ORIG -p$DB_PASS_ORIG $DB_NAME_ORIG > $BACKUP_DIR/backup_$DATE.sql

# Opcional: Comprimir el archivo
gzip $BACKUP_DIR/backup_$DATE.sql

# Borrar todos los datos de la base de datos destino
echo "Borrando todos los datos de la base de datos $DB_NAME_DEST en el host $DB_HOST_DEST..."
mysql -h $DB_HOST_DEST -u $DB_USER_DEST -p$DB_PASS_DEST -e "DROP DATABASE IF EXISTS $DB_NAME_DEST; CREATE DATABASE $DB_NAME_DEST;"

# Restaurar el dump en la base de datos destino
echo "Restaurando el dump en la base de datos $DB_NAME_DEST..."
gunzip < $BACKUP_DIR/backup_$DATE.sql.gz | mysql -h $DB_HOST_DEST -u $DB_USER_DEST -p$DB_PASS_DEST $DB_NAME_DEST

echo "Restauración completada."