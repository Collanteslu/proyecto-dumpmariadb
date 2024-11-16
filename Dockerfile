FROM alpine:3.18

# Instalar mariadb-client, dcron, bash y supervisord
RUN apk update && \
    apk add --no-cache mariadb-client dcron bash supervisor

# Copiar el script de backup al contenedor
COPY backup.sh /usr/local/bin/backup.sh

# Dar permisos de ejecución al script
RUN chmod +x /usr/local/bin/backup.sh

# Configurar cron para ejecutar el script cada día a las 2 AM
RUN echo "0 2 * * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1" > /etc/crontabs/root

# Copiar el archivo de configuración de supervisord
COPY supervisord.conf /etc/supervisord.conf

# Definir argumentos de construcción para las variables de entorno
ARG DB_HOST_ORIG
ARG DB_PORT_ORIG
ARG DB_USER_ORIG
ARG DB_PASS_ORIG
ARG DB_NAME_ORIG
ARG DB_HOST_DEST
ARG DB_PORT_DEST
ARG DB_USER_DEST
ARG DB_PASS_DEST
ARG DB_NAME_DEST

# Establecer variables de entorno
ENV DB_HOST_ORIG=$DB_HOST_ORIG
ENV DB_PORT_ORIG=$DB_PORT_ORIG
ENV DB_USER_ORIG=$DB_USER_ORIG
ENV DB_PASS_ORIG=$DB_PASS_ORIG
ENV DB_NAME_ORIG=$DB_NAME_ORIG
ENV DB_HOST_DEST=$DB_HOST_DEST
ENV DB_PORT_DEST=$DB_PORT_DEST
ENV DB_USER_DEST=$DB_USER_DEST
ENV DB_PASS_DEST=$DB_PASS_DEST
ENV DB_NAME_DEST=$DB_NAME_DEST

# Ejecutar el script de backup al iniciar el contenedor y registrar la salida
RUN /usr/local/bin/backup.sh

# Ejecutar supervisord en primer plano
CMD ["supervisord", "-c", "/etc/supervisord.conf"]