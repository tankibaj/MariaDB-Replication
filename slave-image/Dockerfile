FROM mariadb:latest

COPY slave-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/slave-entrypoint.sh
ENTRYPOINT ["slave-entrypoint.sh"]

CMD ["mysqld"]
