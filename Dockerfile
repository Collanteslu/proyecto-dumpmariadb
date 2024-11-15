FROM alpine:3.18

# Instalar MariaDB client y cron
RUN apk update && \
    apk add --no-cache mariadb-client cron bash

# Copiar el script de backup al contenedor
COPY backup.sh /backup.sh
RUN chmod +x /backup.sh

# Crear un cron job que ejecute el backup semanalmente
RUN echo "0 0 * * 0 /bin/bash /backup.sh" > /etc/crontabs/root

# Ejecutar cron en primer plano para mantener el contenedor corriendo
CMD ["crond", "-f"]
