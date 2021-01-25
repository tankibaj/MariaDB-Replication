FROM mariadb:latest

COPY master-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/master-entrypoint.sh
ENTRYPOINT ["master-entrypoint.sh"]

CMD ["mysqld"]
