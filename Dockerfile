FROM debian:wheezy

ADD ./supervisord.conf /etc/supervisor/conf.d/

ADD ./postfix.main.cf /etc/postfix/main.cf
ADD ./postfix.master.cf.append /etc/postfix/master-additional.cf
ADD ./postfix.sh /opt/postfix.sh

ADD ./dovecot.mail /etc/dovecot/conf.d/10-mail.conf
ADD ./dovecot.ssl /etc/dovecot/conf.d/10-ssl.conf
ADD ./dovecot.auth /etc/dovecot/conf.d/10-auth.conf
ADD ./dovecot.master /etc/dovecot/conf.d/10-master.conf
ADD ./dovecot.lda /etc/dovecot/conf.d/15-lda.conf
ADD ./dovecot.imap /etc/dovecot/conf.d/20-imap.conf
ADD ./configure.sh /configure.sh
ADD ./run.sh /run.sh

RUN apt-get update &&  apt-get upgrade -y &&  apt-get install -y  apache2 php5  php5-curl  curl ssl-cert vim postfix dovecot-imapd mailutils supervisor rsyslog tcpdump && apt-get clean && rm -rf /var/lib/apt/lists/* \
    &&  mkdir -p /var/log/supervisor && chmod 755 /opt/postfix.sh && cp /etc/hostname /etc/mailname && chmod 755 /configure.sh &&  chmod 755 /run.sh \
    &&  openssl req -new -x509 -days 1000 -nodes -out "/etc/ssl/certs/dovecot.pem" -keyout "/etc/ssl/private/dovecot.pem" -subj "/C=US/ST=Test/L=Test/O=Dis/CN=example.com" \
    &&  mkdir -p /var/www/rainloop  && cd /var/www/rainloop && curl -sL https://repository.rainloop.net/installer.php | php  \ 
    &&  chmod -R 755 /var/www/rainloop &&  chown -R www-data:www-data /var/www/rainloop  && php /var/www/rainloop/index.php 

ENV CERTIFICATE dovecot.pem
ENV KEYFILE dovecot.pem

VOLUME ["/etc/postfix/virtual","/etc/postfix/virtual-mailbox-domains","/etc/dovecot/passwd"]

EXPOSE 25 143 587 

CMD ["/run.sh"]

