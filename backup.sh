#!/bin/bash

# Variables de conexión para la base de datos de origen
DB_HOST_ORIG=${DB_HOST_ORIG}
DB_PORT_ORIG=${DB_PORT_ORIG}
DB_USER_ORIG=${DB_USER_ORIG}
DB_PASS_ORIG=${DB_PASS_ORIG}
DB_NAME_ORIG=${DB_NAME_ORIG}  # Base de datos de origen (de donde se realiza el dump)

# Variables de conexión para la base de datos de destino
DB_HOST_DEST=${DB_HOST_DEST}
DB_PORT_DEST=${DB_PORT_DEST}
DB_USER_DEST=${DB_USER_DEST}
DB_PASS_DEST=${DB_PASS_DEST}
DB_NAME_DEST=${DB_NAME_DEST}  # Base de datos de destino (donde se va a restaurar)

BACKUP_DIR="/backups"
DATE=$(date +\%Y-\%m-\%d_\%H-\%M-\%S)

echo "Creando la carpeta de backups..."

# Crear directorio de backups si no existe
mkdir -p $BACKUP_DIR

# Verificar que el cliente de MySQL está instalado
echo "Verificando que el cliente de MySQL está instalado..."
mysql --version
if [ $? -ne 0 ]; then
  echo "Error: El cliente de MySQL no está instalado."
  exit 1
fi


# Verificar conexión a la base de datos de origen
echo "Verificando conexión a la base de datos de origen..."
mysql -h $DB_HOST_ORIG -P $DB_PORT_ORIG -u $DB_USER_ORIG -p$DB_PASS_ORIG -e "SELECT 1"
if [ $? -ne 0 ]; then
  echo "Error: No se pudo conectar a la base de datos de origen."
  exit 1
fi

# Realizar el dump de la base de datos de origen
echo "Realizando dump de la base de datos $DB_NAME_ORIG en el host $DB_HOST_ORIG..."
mysqldump -h $DB_HOST_ORIG -P $DB_PORT_ORIG -u $DB_USER_ORIG -p$DB_PASS_ORIG $DB_NAME_ORIG > $BACKUP_DIR/backup_$DATE.sql
if [ $? -ne 0 ]; then
  echo "Error: No se pudo realizar el dump de la base de datos de origen."
  exit 1
fi

# Opcional: Comprimir el archivo
gzip $BACKUP_DIR/backup_$DATE.sql
if [ $? -ne 0 ]; then
  echo "Error: No se pudo comprimir el archivo de dump."
  exit 1
fi

# Verificar conexión a la base de datos de destino
echo "Verificando conexión a la base de datos de destino..."
mysql -h $DB_HOST_DEST -P $DB_PORT_DEST -u $DB_USER_DEST -p$DB_PASS_DEST -e "SELECT 1"
if [ $? -ne 0 ]; then
  echo "Error: No se pudo conectar a la base de datos de destino."
  exit 1
fi

# Borrar todos los datos de la base de datos destino
echo "Borrando todos los datos de la base de datos $DB_NAME_DEST en el host $DB_HOST_DEST..."
mysql -h $DB_HOST_DEST -P $DB_PORT_DEST -u $DB_USER_DEST -p$DB_PASS_DEST -e "DROP DATABASE IF EXISTS $DB_NAME_DEST; CREATE DATABASE $DB_NAME_DEST;"
if [ $? -ne 0 ]; then
  echo "Error: No se pudo borrar y crear la base de datos de destino."
  exit 1
fi

# Restaurar el dump en la base de datos destino
echo "Restaurando el dump en la base de datos $DB_NAME_DEST..."
gunzip < $BACKUP_DIR/backup_$DATE.sql.gz | mysql -h $DB_HOST_DEST -P $DB_PORT_DEST -u $DB_USER_DEST -p$DB_PASS_DEST $DB_NAME_DEST
if [ $? -ne 0 ]; then
  echo "Error: No se pudo restaurar el dump en la base de datos de destino."
  exit 1
fi

# Borrar el fichero de copia de seguridad
echo "Borrando el fichero de copia de seguridad..."
rm $BACKUP_DIR/backup_$DATE.sql.gz

echo "Restauración completada."