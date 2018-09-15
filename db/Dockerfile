FROM mysql:8.0

ENV MYSQL_ROOT_PASSWORD=pwd
ENV MYSQL_DATABASE=nss_db
ENV MYSQL_USER=nss
ENV MYSQL_PASSWORD=password

COPY ./dump/schema.sql docker-entrypoint-initdb.d/

EXPOSE 3306
