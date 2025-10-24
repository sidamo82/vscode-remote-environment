FROM mcr.microsoft.com/devcontainers/base:debian

# Install the xz-utils package
RUN apt-get update && apt-get install -y xz-utils

# Set environment variables to non-interactive to avoid prompts during package installation
#ENV DEBIAN_FRONTEND=noninteractive

# Allow service actions during package installations
RUN echo '#!/bin/sh\nexit 0' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d

# Install necessary dependencies and add the Sury PHP repository
RUN apt-get update && apt-get install -y \
    ca-certificates \
    apt-transport-https \
    lsb-release \
    wget \
    gnupg \
    curl \
    ksh \
    build-essential \
    default-jre \
    && curl -fsSL https://packages.sury.org/php/apt.gpg | tee /usr/share/keyrings/sury-archive-keyring.gpg > /dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/sury-archive-keyring.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && apt-get update

# Install PHP 7.3, common extensions, phpize, and Xdebug (version-specific)
RUN apt-get install -y \
    php7.3 \
    php7.3-cli \
    php7.3-fpm \
    php7.3-mysql \
    php7.3-xml \
    php7.3-mbstring \
    php7.3-curl \
    php7.3-zip \
    php7.3-gd \
    php7.3-opcache \
    php7.3-soap \
    php7.3-intl \
    php7.3-bcmath \
    php7.3-json \
    php7.3-dev \
    php7.3-xdebug \
    php7.4 \
    php7.4-cli \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-xml \
    php7.4-mbstring \
    php7.4-curl \
    php7.4-zip \
    php7.4-gd \
    php7.4-opcache \
    php7.4-soap \
    php7.4-intl \
    php7.4-bcmath \
    php7.4-json \
    php7.4-dev \
    php7.4-xdebug \
    php8.0 \
    php8.0-cli \
    php8.0-fpm \
    php8.0-mysql \
    php8.0-xml \
    php8.0-mbstring \
    php8.0-curl \
    php8.0-zip \
    php8.0-gd \
    php8.0-opcache \
    php8.0-soap \
    php8.0-intl \
    php8.0-bcmath \
    php8.0-dev \
    php8.0-xdebug \
    php8.2 \
    php8.2-cli \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-xml \
    php8.2-mbstring \
    php8.2-curl \
    php8.2-zip \
    php8.2-gd \
    php8.2-opcache \
    php8.2-soap \
    php8.2-intl \
    php8.2-bcmath \
    php8.2-dev \
    php8.2-xdebug \
    php8.4 \
    php8.4-cli \
    php8.4-fpm \
    php8.4-mysql \
    php8.4-xml \
    php8.4-mbstring \
    php8.4-curl \
    php8.4-zip \
    php8.4-gd \
    php8.4-opcache \
    php8.4-soap \
    php8.4-intl \
    php8.4-bcmath \
    php8.4-dev \
    php8.4-xdebug \
    && apt-get clean

# Install ping and ncat (tools used to test network in case of troubleshooting)
RUN apt-get install -y iputils-ping ncat

# Copy and install IBM DB2 client libraries from local folder
COPY ibmodbcdriver/linuxx64_odbc_cli.tar.gz /tmp/linuxx64_odbc_cli.tar.gz
RUN cd /tmp && \
    tar -xzf linuxx64_odbc_cli.tar.gz && \
    mkdir -p /opt/ibm && \
    cp -r clidriver /opt/ibm/ && \
    chmod -R 755 /opt/ibm/clidriver && \
    rm -rf /tmp/clidriver /tmp/linuxx64_odbc_cli.tar.gz

# Set IBM DB2 environment variables
ENV IBM_DB_HOME=/opt/ibm/clidriver
ENV LD_LIBRARY_PATH=/opt/ibm/clidriver/lib:$LD_LIBRARY_PATH
ENV CPPFLAGS="-I/opt/ibm/clidriver/include"
ENV LDFLAGS="-L/opt/ibm/clidriver/lib"

# Set the default PHP version to 7.3
RUN update-alternatives --set php /usr/bin/php7.3 \
    && update-alternatives --set phpize /usr/bin/phpize7.3 \
    && update-alternatives --set php-config /usr/bin/php-config7.3

# Install IBM DB2 PHP extension
RUN export IBM_DB_HOME=/opt/ibm/clidriver && \
    export CPPFLAGS="-I/opt/ibm/clidriver/include" && \
    export LDFLAGS="-L/opt/ibm/clidriver/lib" && \
    printf "/opt/ibm/clidriver\n" | pecl install ibm_db2 && \
    echo "extension=ibm_db2.so" > /etc/php/7.3/mods-available/ibm_db2.ini && \
    phpenmod ibm_db2

# Install PDO_IBM PHP extension
RUN printf "/opt/ibm/clidriver\n" | pecl install pdo_ibm

# Enable PDO_IBM PHP extension
RUN echo "extension=/usr/lib/php/20180731/pdo_ibm.so" > /etc/php/7.3/mods-available/pdo_ibm.ini \
    && phpenmod pdo_ibm