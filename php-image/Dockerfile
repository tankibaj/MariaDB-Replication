FROM php:7.4-fpm
COPY ./app/ /usr/src/app
WORKDIR /usr/src/app
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/
RUN docker-php-ext-install mysqli pdo pdo_mysql
CMD [ "bash", "loop.sh" ]