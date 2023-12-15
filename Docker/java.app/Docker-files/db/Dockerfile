FROM mysql:8.0.33
LABEL Project="Vprofile"
LABEL Env="prod"

ENV MYSQL_ROOT_PASSWORD="fakepass"
ENV MYSQL_DATABASE="accounts"

ADD db_backup.sql /docker-entrypoint-initdb.d/db_backup.sql